import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:http_retry/http_retry.dart';

class ClientWithAuthHeaders extends http.BaseClient {
  final Map<String, String> headers;

  http.Client client;


  ClientWithAuthHeaders(this.headers) {
    client = RetryClient(http.Client(),
        when: (r) => r.statusCode >= 400, retries: 5);
//    dio = Dio(BaseOptions(
//      headers: headers,
//    ));
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.remove("content-length");
    request.headers.remove("user-agent");
    var baseRequest = request..headers.addAll(headers);

    return client.send(baseRequest);

//    Response<ResponseBody> rs = await dio.request<ResponseBody>(
//        "https://www.googleapis.com" + request.url.path,
//        queryParameters: request.url.queryParameters,
//        options: Options(
//            method: request.method,
//            headers: request.headers,
//            responseType: ResponseType.stream));
//
//    Map<String, String> responseHeaders = Map();
//    rs.headers.forEach((name, values) {
//      responseHeaders.putIfAbsent(name, () => values.join());
//    });
//
//    return http.StreamedResponse(rs.data.stream, rs.statusCode,
//        request: request, headers: responseHeaders);
  }
}

class ClientWithGoogleDriveKey extends http.BaseClient {
  http.Client client;

  ClientWithGoogleDriveKey() {
    client = RetryClient(http.Client(),
        when: (r) => r.statusCode >= 400, retries: 5);
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.remove("content-length");
    request.headers.remove("user-agent");

    Map<String, String> newParameters = Map.from(request.url.queryParameters);
    newParameters.putIfAbsent(
        "key", () => "AIzaSyAqIRv5ZxTwthkOQQXvi4jpdn6k5Gx3afk");
    Uri uri1 = request.url.replace(queryParameters: newParameters);
    http.BaseRequest baseRequest = http.Request(request.method, uri1);
    baseRequest.headers.addAll(request.headers);

    return client.send(baseRequest);
  }
}
