import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../core/errors/failures.dart';

class ApiClient {
  final http.Client client;
  final Logger logger;

  ApiClient({http.Client? client, Logger? logger})
      : client = client ?? http.Client(),
        logger = logger ?? Logger();

  Future<dynamic> post(String uri, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      logger.d('POST Request: $uri\nBody: $body');
      
      final response = await client.post(
        Uri.parse(uri),
        body: body, // http package handles map -> form-url-encoded automatically for map body
        headers: headers,
      );

      logger.d('Response Status: ${response.statusCode}\nBody: ${response.body}');

      return _processResponse(response);
    } on SocketException {
      throw const ServerFailure('No Internet connection');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<dynamic> get(String uri, {Map<String, String>? headers}) async {
    try {
      logger.d('GET Request: $uri');
      
      final response = await client.get(
        Uri.parse(uri),
        headers: headers,
      );

      logger.d('Response Status: ${response.statusCode}\nBody: ${response.body}');

      return _processResponse(response);
    } on SocketException {
      throw const ServerFailure('No Internet connection');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        return json.decode(response.body);
      } catch (e) {
        return response.body; // Return string if not JSON
      }
    } else {
      throw ServerFailure('Error ${response.statusCode}: ${response.body}');
    }
  }
}
