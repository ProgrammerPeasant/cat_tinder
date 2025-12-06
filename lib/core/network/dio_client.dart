import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Dio createDioClient() {
  final options = BaseOptions(
    baseUrl: 'https://api.thecatapi.com/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  );
  final dio = Dio(options);
  final apiKey = dotenv.env['CAT_API_KEY'];
  if (apiKey != null && apiKey.isNotEmpty) {
    dio.options.headers['x-api-key'] = apiKey;
  }
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true, error: true),
  );
  return dio;
}
