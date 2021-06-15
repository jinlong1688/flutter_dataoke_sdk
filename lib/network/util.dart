import 'package:dd_taoke_sdk/model/result.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DdTaokeUtil {
  DdTaokeUtil._();

  static DdTaokeUtil get instance => DdTaokeUtil._();

  factory DdTaokeUtil() => instance;

  static Dio? dio;
  final tkApi = '/tkapi/api/v1/dtk/apis';
  static var _ip = '';
  static var _port = '';
  static var _proxy = '';

  OnRequestStart? _onStart;

  /// 初始化服务器地址和端口
  void init(String host, String port,
      {String? proxy, OnRequestStart? onStart}) {
    _ip = host;
    _port = port;
    if (proxy != null) _proxy = proxy;
    _onStart = onStart;
  }

  ///发起http请求
  ///
  ///url 接口地址
  ///
  ///data 查询参数
  ///
  ///error 请求错误回传
  ///
  Future<String> get(String url,
      {Map<String, dynamic>? data,
      ApiError? error,
      OnRequestStart? onStart}) async {
    var _dio = createInstance()!;
    if (_proxy.isNotEmpty) addProxy(_dio, _proxy);

    _onStart?.call(_dio); // 全局的
    onStart?.call(_dio); // 局部的
    try {
      final response = await _dio.get<String>(url, queryParameters: data);
      if (response.statusCode == 200 && response.data != null) {
        final result = ddTaokeResultFromJson(response.data!);
        if (result.state == 200) {
          if (result.data != null) {
            return result.data!;
          }
          return '';
        } else {
          errorHandle(error, result.state, result.message);
          return '';
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        errorHandle(error, e.response!.statusCode, e.response!.statusMessage);
      }
      errorHandle(error, 500, '${e.toString()}');
    }

    return '';
  }

  /// POST 请求
  Future<String> post(String url,
      {Map<String, dynamic>? data,
      VoidCallback? onStart,
      ApiError? error}) async {
    var _dio = createInstance(absPath: '')!;
    if (_proxy.isNotEmpty) addProxy(_dio, _proxy);

    _onStart?.call(_dio);
    onStart?.call();

    try {
      final response = await _dio.post(url, data: data);
      if (response.statusCode == 200 && response.data != null) {
        final result = ddTaokeResultFromJson(response.data!);
        if (result.state == 200) {
          if (result.data != null) {
            return result.data!;
          }
          return '';
        } else {
          errorHandle(error, result.state, result.message);
          return '';
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        errorHandle(error, e.response!.statusCode, e.response!.statusMessage);
      }
      errorHandle(error, 500, '${e.toString()}');
    }

    return '';
  }

  /// 请求没有正常执行
  void errorHandle(ApiError? error, int? code, String? message) {
    if (error != null) {
      error(code, message);
    } else {
      print('请求失败:code=$code.message=$message');
    }
  }

  /// 创建dio实例
  Dio? createInstance({String? absPath}) {
    if (dio == null) {
      final url = '$_ip:$_port' + (absPath ?? tkApi);
      BaseOptions options = BaseOptions(baseUrl: url, connectTimeout: 20000);
      dio = Dio(options);
    }
    return dio;
  }
}

typedef ApiError = void Function(int? stateCode, String? message);

void addProxy(Dio dio, String ip) {
  var client;
  if (ip.isNotEmpty) {
    if (kIsWeb) {
    } else {
      client = dio.httpClientAdapter as DefaultHttpClientAdapter;
      client.onHttpClientCreate = (_client) {
        _client.findProxy = (uri) {
          return "PROXY $ip";
        };
      };
    }
  }
}

/// 发起请求前做的一些事
typedef OnRequestStart = void Function(Dio dio);
