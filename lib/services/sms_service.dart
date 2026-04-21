import 'package:dio/dio.dart';

import '../network/net_config.dart';

class SmsService {
  final Dio _dio = Dio();

  Future<SmsResult> sendSms({
    required String recvNo,
    required String text,
    String? subject,
  }) async {
    final url = '${NetConfig.baseUrl}sms/send';

    try {
      final response = await _dio.post(
        url,
        data: {
          'recvNo': recvNo,
          'text': text.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
          if (subject != null) 'subject': subject,
        },
        options: Options(
          contentType: 'application/json',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data;
      final ok = response.statusCode == 200 &&
          data is Map &&
          data['result'] == 'success';

      return SmsResult(
        success: ok,
        statusCode: response.statusCode,
        body: data?.toString() ?? '',
      );
    } on DioException catch (e) {
      return SmsResult(
        success: false,
        statusCode: e.response?.statusCode,
        body: e.message ?? 'Unknown error',
        error: e,
      );
    }
  }
}

class SmsResult {
  final bool success;
  final int? statusCode;
  final String body;
  final Object? error;

  SmsResult({
    required this.success,
    this.statusCode,
    required this.body,
    this.error,
  });

  @override
  String toString() => 'SmsResult(success=$success, status=$statusCode, body=$body)';
}
