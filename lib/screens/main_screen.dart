import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/keys.dart';
import '../utils/prefs_util.dart';
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('앱 종료'),
            content: const Text('앱을 종료하시겠습니까?'),
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
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: AppBar(
          title: const Text('가스안전관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          backgroundColor: const Color(0xFF555555),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 상단 그라데이션 사용자 정보 영역
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF555555), Color(0xFF444444)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.loginCo ?? '',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${user?.safeSwName ?? "(미지정)"} 님',
                              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        user?.loginLastDate ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 메뉴 버튼들
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // 모바일 검침
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildImageCard(
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
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildImageCard(
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
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: _buildImageCard(
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
                                  padding: const EdgeInsets.only(left: 5),
                                  child: _buildImageCard(
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
                    ],
                  ),
                ),
              ),
              // 하단 조아테크 정보
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: const Column(
                  children: [
                    Text('(주)조아테크 | 대표 : 하명현', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                    SizedBox(height: 2),
                    Text('사업자등록번호 : 206-86-17457', style: TextStyle(fontSize: 10, color: Colors.black38)),
                    SizedBox(height: 1),
                    Text('서울시 강동구 고덕비즈밸리로 26 강동U1센터 A동 1701호', style: TextStyle(fontSize: 10, color: Colors.black38), textAlign: TextAlign.center),
                    SizedBox(height: 1),
                    Text('TEL : 1566-2399, 1800-7148 | Fax : 02-452-4336', style: TextStyle(fontSize: 10, color: Colors.black38)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, String imagePath, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
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
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
