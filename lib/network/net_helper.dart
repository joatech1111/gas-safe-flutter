import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api_service.dart';
import '../screens/login_screen.dart';
import '../widgets/logo_loader.dart';

class NetHelper {
  static final ApiService api = ApiService();

  static Future<Map<String, dynamic>> request(
    BuildContext context,
    Future<Map<String, dynamic>> Function() apiCall, {
    bool showProgress = true,
  }) async {
    if (!context.mounted) return {'resultCode': 9999, 'result': '화면이 닫혀 요청을 처리할 수 없습니다.'};

    OverlayEntry? overlayEntry;

    if (showProgress && context.mounted) {
      overlayEntry = OverlayEntry(
        builder: (_) => Container(
          color: Colors.black38,
          child: const Center(child: LogoLoader(size: 120)),
        ),
      );
      // 빌드 중이면 한 프레임 뒤에 삽입
      final overlay = Overlay.of(context);
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        overlay.insert(overlayEntry);
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (overlayEntry!.mounted) return; // 이미 제거됨
          overlay.insert(overlayEntry);
        });
      }
    }

    try {
      final resp = await apiCall().timeout(
        const Duration(seconds: 20),
        onTimeout: () => {'resultCode': 9999, 'result': '요청 시간이 초과되었습니다.'},
      );
      return resp;
    } catch (e) {
      return {'resultCode': 9999, 'result': e.toString()};
    } finally {
      if (overlayEntry != null && overlayEntry.mounted) {
        overlayEntry.remove();
      }
    }
  }

  static void handleError(BuildContext context, Map<String, dynamic> resp) {
    final resultCode = resp['resultCode'] ?? -1;
    final resultMsg = resp['result']?.toString() ?? '';
    switch (resultCode) {
      case 9999:
        Fluttertoast.showToast(msg: resultMsg.isNotEmpty ? resultMsg : '알 수 없는 에러가 발생했습니다.');
        break;
      case 12:
      case 1:
      case 1003:
        Fluttertoast.showToast(msg: resultMsg.isNotEmpty ? resultMsg : '알 수 없는 에러가 발생했습니다.');
        break;
      case 111:
        Fluttertoast.showToast(msg: '세션이 만료되었습니다. 다시 로그인해주세요.');
        _goLogin(context);
        break;
      case 112:
        Fluttertoast.showToast(msg: '알 수 없는 에러가 발생했습니다.');
        _goLogin(context);
        break;
    }
  }

  static void _goLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  static bool isSuccess(Map<String, dynamic> resp) => resp['resultCode'] == 0;
}
