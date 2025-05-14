import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workout_notepad_v2/model/env.dart';

class SpanContextManager {
  static final _globalStack = <Span>[];

  static void push(Span span) {
    _globalStack.add(span);
  }

  static void pop(Span span) {
    if (_globalStack.isNotEmpty && _globalStack.last == span) {
      _globalStack.removeLast();
    }
  }

  static Span? get currentSpan =>
      _globalStack.isNotEmpty ? _globalStack.last : null;
}

// Global helper to maintain consistent tracing throughout the app
class GlobalTelemetry {
  static Future<void> initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final tracerProvider = TracerProviderBase(
      processors: [
        kDebugMode
            ? SimpleSpanProcessor(ConsoleExporter())
            : BatchSpanProcessor(
                CollectorExporter(
                  Uri.parse('$OTEL_BACKEND_HOST/v1/traces'),
                  headers: {
                    "x-api-key": OTEL_BACKEND_API_KEY,
                  },
                ),
              ),
      ],
      resource: Resource([
        Attribute.fromString("service_name", OTEL_INSTRUMENTATION_NAME),
        Attribute.fromString("session_id", OTEL_SESSION_ID),
        Attribute.fromString("app_version", packageInfo.version),
        Attribute.fromString("app_buildNumber", packageInfo.buildNumber),
        Attribute.fromString(
            "app_store", packageInfo.installerStore ?? "unknown"),
      ]),
    );

    registerGlobalTracerProvider(tracerProvider);
  }

  // Use your existing global tracer provider
  static Tracer getTracer() {
    return globalTracerProvider.getTracer(OTEL_INSTRUMENTATION_NAME);
  }

  // Create a span and optionally attach it to the current context
  static Span startSpan(
    String name, {
    List<Attribute> attributes = const [],
    bool attachToContext = true,
  }) {
    final tracer = getTracer();
    final span = tracer.startSpan(name, attributes: attributes);

    if (attachToContext) {
      SpanContextManager.push(span);
    }

    return span;
  }

  // End a span and detach its context if it was attached
  static void endSpan(Span span) {
    SpanContextManager.pop(span);
    span.end();
  }

  // Trace an async operation with proper context propagation
  static Future<T> trace<T>(
    String name,
    Future<T> Function() operation, {
    List<Attribute> attributes = const [],
    bool manualEnd = false,
  }) async {
    final span = startSpan(name, attributes: attributes, attachToContext: true);

    try {
      // Run with span attached to context
      final token = Context.attach(contextWithSpan(Context.current, span));
      try {
        return await operation();
      } finally {
        Context.detach(token);
      }
    } catch (e, stackTrace) {
      span.recordException(e, stackTrace: stackTrace);
      span.setStatus(StatusCode.error, e.toString());
      rethrow;
    } finally {
      if (!manualEnd) {
        endSpan(span);
      }
    }
  }

  static Future<http.Response> traceHttp<T extends http.Response>(
    String method,
    String path,
    Future<T> Function() httpOperation, {
    Map<String, dynamic>? headers,
    dynamic body,
    String? customHost,
  }) async {
    final hostUrl = customHost ?? HOST;
    final attributes = [
      Attribute.fromString('http.method', method),
      Attribute.fromString('http.url', '$hostUrl$path'),
    ];

    // Add headers as attributes (with sensitive info removed)
    if (headers != null) {
      final sanitizedHeaders = Map<String, dynamic>.from(headers);
      // Remove sensitive headers
      sanitizedHeaders.remove('Authorization');
      sanitizedHeaders.remove('x-api-key');
      attributes.add(Attribute.fromString(
          'http.request.headers', sanitizedHeaders.toString()));
    }

    // Add body size as attribute if present
    if (body != null) {
      String bodyStr = body is String ? body : jsonEncode(body);
      attributes
          .add(Attribute.fromInt('http.request.body.size', bodyStr.length));
    }

    return GlobalTelemetry.trace<http.Response>(
      'HTTP $method $path',
      httpOperation,
      attributes: attributes,
      manualEnd: true,
    ).then((response) {
      // Add response information to the span
      final span = SpanContextManager.currentSpan;
      if (span != null) {
        span.setAttribute(
            Attribute.fromInt('http.status_code', response.statusCode));
        span.setAttribute(
            Attribute.fromInt('http.response.body.size', response.body.length));

        // Set span status based on HTTP response code
        if (response.statusCode >= 400) {
          span.setStatus(StatusCode.error, 'HTTP error ${response.statusCode}');

          // Add error details when possible
          try {
            final errorBody = jsonDecode(response.body);
            span.setAttribute(
                Attribute.fromString('error.details', errorBody.toString()));
          } catch (_) {
            // If we can't parse the error body, just continue
          }
        }
        endSpan(span);
      }
      return response;
    });
  }
}
