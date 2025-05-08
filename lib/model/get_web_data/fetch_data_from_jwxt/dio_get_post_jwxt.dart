import 'dart:convert';
import 'package:dio/dio.dart';

Future<String> dioGETjwxt({
  required String url,
  required Map<String, dynamic>? headers,
}) async {
  try {
    var response = await Dio().get(
      url,
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
      ),
    );

    // print(response.statusCode);
    // print(response.headers);

    var head1 = response.headers['Content-type']![0];

    if (head1 == 'text/html;charset=GBK') {
      // print('登录失效');
      // var parsedata = gbk.decode(response.data);
      // var document = parse(encoding: '', parsedata);
      // var errorInfo = document
      //     .getElementsByClassName("dlmi1")[0]
      //     .children[0]
      //     .children[0]
      //     .children[2]
      //     .children[0]
      //     .children[0]
      //     .innerHtml;
      // print(errorInfo); //请先登录系统
      throw '登录失效，请重新登录';
    } else if (head1 == 'text/html;charset=UTF-8') {
      var parsedata = utf8.decode(response.data);
      // print(parsedata);
      return parsedata;
    } else {
      throw '';
    }
  } on DioException catch (e) {
    // print("error : $e");
    // print(e.error);
    // print(e.message);
    // print(e.response);
    // print(e.type);
    throw 'error : $e';
  }
}

Future<String> dioPOSTjwxt({
  required String url,
  required Object data,
  required Map<String, dynamic>? headers,
  Map<String, dynamic>? queryParameters,
}) async {
  try {
    var response = await Dio().post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
      ),
    );

    // print(response.statusCode);
    // print(response.headers);

    var head1 = response.headers['Content-type']![0];

    if (head1 == 'text/html;charset=GBK') {
      // print('登录失效');
      // var parsedata = gbk.decode(response.data);
      // var document = parse(encoding: '', parsedata);
      // var errorInfo = document
      //     .getElementsByClassName("dlmi1")[0]
      //     .children[0]
      //     .children[0]
      //     .children[2]
      //     .children[0]
      //     .children[0]
      //     .innerHtml;
      // print(errorInfo); //请先登录系统
      throw '登录失效，请重新登录';
    } else if (head1 == 'text/html;charset=UTF-8') {
      var parsedata = utf8.decode(response.data);
      // print(parsedata);
      return parsedata;
    } else {
      throw '';
    }
  } on DioException catch (e) {
    // print("error : $e");
    throw 'error : $e';
  }
}
