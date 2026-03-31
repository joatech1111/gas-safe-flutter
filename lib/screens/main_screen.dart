import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('가스경영안전관리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          child: Column(
            children: [
              // 사용자 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user?.loginCo ?? '',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          child: Image.asset('assets/images/settings.png', width: 28, height: 28),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user?.safeSwName ?? "(미지정)"} 님',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                        Text(
                          user?.loginLastDate ?? '',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 메뉴 버튼들 - 항상 4개 모두 표시
              Expanded(
                child: Column(
                  children: [
                    // 모바일 검침
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _buildImageButton(
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
                        padding: const EdgeInsets.only(top: 6),
                        child: _buildImageButton(
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
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildImageButton(
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
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildImageButton(
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
                          ],
                        ),
                      ),
                    ),
                    // 푸터 여백
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(BuildContext context, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
