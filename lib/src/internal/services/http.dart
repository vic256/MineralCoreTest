import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mineral/exception.dart';
import 'package:mineral/helper.dart';

class Http {
  String baseUrl;
  final Map<String, String> _headers = {};

  Http({ required this.baseUrl });

  void defineHeader ({ required String header, required String value }) {
    _headers.putIfAbsent(header, () => value);
  }

  void removeHeader (String header) {
    _headers.remove(header);
  }

  Future<http.Response> get ({ required String url, Map<String, String>? headers }) async {
    return http.get(Uri.parse("$baseUrl$url"), headers: _getHeaders(headers));
  }

  Future<http.Response> post ({ required String url, required dynamic payload, Map<String, String>? headers }) async {
    return http.post(Uri.parse("$baseUrl$url"), body: jsonEncode(payload), headers: _getHeaders(headers));
  }

  Future<http.Response> put ({ required String url, required dynamic payload, Map<String, String>? headers }) async {
    return http.put(Uri.parse("$baseUrl$url"), body: jsonEncode(payload), headers: _getHeaders(headers));
  }

  Future<http.Response> patch ({ required String url, required dynamic payload, Map<String, String>? headers }) async {
    return http.patch(Uri.parse("$baseUrl$url"), body: jsonEncode(payload), headers: _getHeaders(headers));
  }

  Future<http.Response> destroy ({ required String url, Map<String, String>? headers }) async {
    return http.delete(Uri.parse("$baseUrl$url"), headers: _getHeaders(headers));
  }

  Map<String, String> _getHeaders (Map<String, String>? headers) {
    Map<String, String> map = Map.from(_headers);

    if (headers != null) {
      map.addAll(headers);
    }

    return map;
  }

  http.Response responseWrapper<T> (http.Response response) {
    final dynamic payload = jsonDecode(response.body);

    if (response.statusCode == 400) {
      if (Helper.hasKey('components', payload)) {
        final List<int> components = payload['components'];

        throw ApiException(
          code: response.statusCode,
          cause: payload['components'].length > 1
            ? 'Components at ${components.join(', ')} positions are invalid'
            : 'The component at position ${components.first} is invalid'
        );
      }

      if (Helper.hasKey('embeds', payload)) {
        final List<int> components = payload['embeds'];

        throw ApiException(
          code: response.statusCode,
          cause: payload['embeds'].length > 1
            ? 'Embeds at ${components.join(', ')} positions are invalid'
            : 'The embed at position ${components.first} is invalid'
        );
      }

      throw HttpException(
        code: response.statusCode,
        cause: response.body,
      );
    }

    return response;
  }
}
