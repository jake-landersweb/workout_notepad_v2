import 'package:http/http.dart' as http;
import 'package:workout_notepad_v2/otel.dart';
import 'env.dart';

class Client {
  // base url that entire app will run off
  static var host = HOST;
  static var defaultHeaders = {
    "Content-type": "application/json",
    "Authorization": "Bearer $API_KEY"
  };

  // http client, needed for all requests
  final http.Client client;

  // init the class and make sure it has an inherited client
  const Client({
    required this.client,
  });

  // generic fetch function
  Future<http.Response> fetch(String path) async {
    return GlobalTelemetry.traceHttp(
      'GET',
      path,
      () => client.get(
        Uri.parse("$HOST$path"),
        headers: defaultHeaders,
      ),
      headers: defaultHeaders,
    );
  }

  Future<http.Response> post(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final mergedHeaders = {...headers, ...defaultHeaders};
    return GlobalTelemetry.traceHttp(
      'POST',
      path,
      () => client.post(
        Uri.parse("$HOST$path"),
        body: body,
        headers: mergedHeaders,
      ),
      headers: mergedHeaders,
      body: body,
    );
  }

  Future<http.Response> put(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final mergedHeaders = {...headers, ...defaultHeaders};
    return GlobalTelemetry.traceHttp(
      'PUT',
      path,
      () => client.put(
        Uri.parse("$HOST$path"),
        body: body,
        headers: mergedHeaders,
      ),
      headers: mergedHeaders,
      body: body,
    );
  }

  Future<http.Response> delete(String path) async {
    return GlobalTelemetry.traceHttp(
      'DELETE',
      path,
      () => client.delete(
        Uri.parse("$HOST$path"),
        headers: defaultHeaders,
      ),
      headers: defaultHeaders,
    );
  }
}

class GoClient {
  // base url that entire app will run off
  static var host = GO_HOST;
  static var defaultHeaders = {
    "Content-type": "application/json",
    "x-api-key": GO_API_KEY,
  };

  // http client, needed for all requests
  final http.Client client;

  // init the class and make sure it has an inherited client
  const GoClient({
    required this.client,
  });

  // generic fetch function
  // generic fetch function
  Future<http.Response> fetch(String path) async {
    return GlobalTelemetry.traceHttp(
      'GET',
      path,
      () => client.get(
        Uri.parse("$host$path"),
        headers: defaultHeaders,
      ),
      customHost: GO_HOST,
      headers: defaultHeaders,
    );
  }

  Future<http.Response> post(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final mergedHeaders = {...headers, ...defaultHeaders};
    return GlobalTelemetry.traceHttp(
      'POST',
      path,
      () => client.post(
        Uri.parse("$host$path"),
        body: body,
        headers: mergedHeaders,
      ),
      customHost: GO_HOST,
      headers: mergedHeaders,
      body: body,
    );
  }

  Future<http.Response> put(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final mergedHeaders = {...headers, ...defaultHeaders};
    return GlobalTelemetry.traceHttp(
      'PUT',
      path,
      () => client.put(
        Uri.parse("$host$path"),
        body: body,
        headers: mergedHeaders,
      ),
      customHost: GO_HOST,
      headers: mergedHeaders,
      body: body,
    );
  }

  Future<http.Response> delete(String path) async {
    return GlobalTelemetry.traceHttp(
      'DELETE',
      path,
      () => client.delete(
        Uri.parse("$host$path"),
        headers: defaultHeaders,
      ),
      customHost: GO_HOST,
      headers: defaultHeaders,
    );
  }
}
