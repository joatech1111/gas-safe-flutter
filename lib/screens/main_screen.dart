import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/keys.dart';
import '../utils/prefs_util.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'metering_screen.dart';
import 'metering_status_screen.dart';
import 'safety_screen.dart';
import 'safety_status_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  bool _isSetSafeSW() {
    final user = AppState.loginUser;
    return user != null && user.safeSwName != null;
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.loginUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            title: const Text('앱 종료', style: TextStyle(color: AppColors.textDefault)),
            content: const Text('앱을 종료하시겠습니까?', style: TextStyle(color: AppColors.textDefault)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('종료')),
            ],
          ),
        );
        if (confirm == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            child: Column(
              children: [
                // 사용자 정보 (Android bg_user_info 스타일)
                Container(
                  height: 79,
                  decoration: BoxDecoration(
                    color: AppColors.buttonBg,
                    border: Border.all(color: AppColors.buttonStroke, width: 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    children: [
                      // 상단: 회사명 + 설정 + 로그아웃 버튼
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user?.loginCo ?? '',
                                  style: const TextStyle(fontSize: 17.3, fontWeight: FontWeight.bold, color: AppColors.textDefault),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                                child: Image.asset('assets/images/settings.png', width: 24, height: 24,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.settings, size: 24, color: AppColors.textDefault),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _logout(context),
                                child: Image.asset('assets/images/logout.png', width: 22, height: 22,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.logout, size: 22, color: AppColors.textDefault),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 구분선
                      Container(height: 1.3, color: AppColors.lineBg),
                      // 하단: 사용자 이름 + 마지막 로그인
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user?.safeSwName ?? "(미지정)"} 님',
                                  style: const TextStyle(fontSize: 12.8, color: AppColors.textDefault),
                                ),
                              ),
                              Text(
                                user?.loginLastDate ?? '',
                                style: const TextStyle(fontSize: 12.8, color: AppColors.textDefault),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6.3),
                // 모바일 검침
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6.3),
                    child: _buildMenuButton(
                      context,
                      'assets/images/metering.png',
                      () {
                        if (!_isSetSafeSW()) {
                          Fluttertoast.showToast(msg: '안전관리자를 설정해주세요.');
                          return;
                        }
                        if (user!.certMenu(['0', '1'])) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MeteringScreen()));
                        } else {
                          Fluttertoast.showToast(msg: '해당 메뉴에 대한 권한이 없습니다.');
                        }
                      },
                    ),
                  ),
                ),
                // 안전 점검
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6.3),
                    child: _buildMenuButton(
                      context,
                      'assets/images/safety.png',
                      () {
                        if (!_isSetSafeSW()) {
                          Fluttertoast.showToast(msg: '안전관리자를 설정해주세요.');
                          return;
                        }
                        if (user!.certMenu(['0', '2'])) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyScreen()));
                        } else {
                          Fluttertoast.showToast(msg: '해당 메뉴에 대한 권한이 없습니다.');
                        }
                      },
                    ),
                  ),
                ),
                // 검침현황 + 점검현황 (가로 2열)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6.3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 3.15),
                            child: _buildMenuButton(
                              context,
                              'assets/images/metering_status.png',
                              () {
                                if (!_isSetSafeSW()) {
                                  Fluttertoast.showToast(msg: '안전관리자를 설정해주세요.');
                                  return;
                                }
                                if (user!.certMenu(['0', '1'])) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MeteringStatusScreen()));
                                } else {
                                  Fluttertoast.showToast(msg: '해당 메뉴에 대한 권한이 없습니다.');
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.15),
                            child: _buildMenuButton(
                              context,
                              'assets/images/safety_status.png',
                              () {
                                if (!_isSetSafeSW()) {
                                  Fluttertoast.showToast(msg: '안전관리자를 설정해주세요.');
                                  return;
                                }
                                if (user!.certMenu(['0', '2'])) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyStatusScreen()));
                                } else {
                                  Fluttertoast.showToast(msg: '해당 메뉴에 대한 권한이 없습니다.');
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 하단 풋터
                Container(
                  height: 52,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonBg,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '(주)조아테크 | 대표 : 하명현',
                        style: TextStyle(fontSize: 10, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black.withValues(alpha: 0.5))]),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'TEL : 1566-2399, 1800-7148',
                        style: TextStyle(fontSize: 10, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black.withValues(alpha: 0.5))]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('로그아웃', style: TextStyle(color: AppColors.textDefault)),
        content: const Text('로그아웃 하시겠습니까?', style: TextStyle(color: AppColors.textDefault)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await NetHelper.api.authLogout();
      AppState.clearLoginUser();
      PrefsUtil.remove(Keys.prefSavedLogin);
      PrefsUtil.remove(Keys.prefUserId);
      PrefsUtil.remove(Keys.prefUserPwd);
      PrefsUtil.remove('PREF_PHONE_LOGIN');
      PrefsUtil.remove('PREF_PHONE_NUMBER');
      PrefsUtil.remove('PREF_PHONE_PWD');
      PrefsUtil.remove('PREF_PHONE_IMEI');
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
