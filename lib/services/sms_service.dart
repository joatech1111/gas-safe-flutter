import 'dart:convert';

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
      final cleanText = text
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceAll('▶', '>')
          .replaceAll('☏', 'TEL')
          .replaceAll('★', '*')
          .replaceAll('☆', '*')
          .replaceAll('●', '-')
          .replaceAll('■', '-')
          .replaceAll('□', '-')
          .replaceAll('◆', '-')
          .replaceAll('◇', '-')
          .replaceAll('▷', '>')
          .replaceAll('◁', '<')
          .replaceAll('△', '-')
          .replaceAll('▲', '-');

      // Delphi 원본 로직과 동일: 90바이트 초과 시 MMS 자동 전환
      final textBytes = utf8.encode(cleanText.trim());
      final smsType = textBytes.length > 90 ? 'MMS' : 'SMS';

      final response = await _dio.post(
        url,
        data: {
          'recvNo': recvNo,
          'text': cleanText,
          'type': smsType,
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
