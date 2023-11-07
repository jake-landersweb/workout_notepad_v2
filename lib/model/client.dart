import 'package:http/http.dart' as http;
import 'env.dart';

class Client {
  // base url that entire app will run off
  static const host = HOST;
  static const defaultHeaders = {
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
    // start the response
    final response = await client.get(
      Uri.parse("$HOST$path"),
      headers: defaultHeaders,
    );
    return response;
  }

  Future<http.Response> post(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    var response = await http.post(
      Uri.parse("$HOST$path"),
      body: body,
      headers: {...headers, ...defaultHeaders},
    );

    return response;
  }

  Future<http.Response> put(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    var response = await http.put(
      Uri.parse("$HOST$path"),
      body: body,
      headers: {...headers, ...defaultHeaders},
    );

    return response;
  }

  Future<http.Response> delete(String path) async {
    // start the response
    final response = await client.delete(
      Uri.parse("$HOST$path"),
      headers: defaultHeaders,
    );
    return response;
  }
}

class PurchaseClient {
  // base url that entire app will run off
  static const host = PURCHASE_HOST;
  static const defaultHeaders = {
    "Content-type": "application/json",
    "x-api-key": PURCHASE_API_KEY,
  };

  // http client, needed for all requests
  final http.Client client;

  // init the class and make sure it has an inherited client
  const PurchaseClient({
    required this.client,
  });

  // generic fetch function
  Future<http.Response> fetch(String path) async {
    // start the response
    final response = await client.get(
      Uri.parse("$host$path"),
      headers: defaultHeaders,
    );
    return response;
  }

  Future<http.Response> post(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    var response = await http.post(
      Uri.parse("$host$path"),
      body: body,
      headers: {...headers, ...defaultHeaders},
    );

    return response;
  }

  Future<http.Response> put(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    var response = await http.put(
      Uri.parse("$host$path"),
      body: body,
      headers: {...headers, ...defaultHeaders},
    );

    return response;
  }

  Future<http.Response> delete(String path) async {
    // start the response
    final response = await client.delete(
      Uri.parse("$host$path"),
      headers: defaultHeaders,
    );
    return response;
  }
}
