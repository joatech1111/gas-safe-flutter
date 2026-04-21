import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../network/net_config.dart';
import 'platform_util_stub.dart' if (dart.library.html) 'platform_util_web.dart';

class SmsService {
  final Dio _dio = Dio();

  /// PC 크롬 환경인지 판별 (모바일 크롬은 false)
  static bool get isDesktopWeb {
    if (!kIsWeb) return false;
    final ua = getUserAgent();
    if (ua.isEmpty) return true; // UA 못 가져오면 PC로 간주
    const mobileKeywords = ['Android', 'iPhone', 'iPad', 'iPod', 'Mobile', 'webOS', 'BlackBerry'];
    for (final keyword in mobileKeywords) {
      if (ua.contains(keyword)) return false;
    }
    return true;
  }

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
