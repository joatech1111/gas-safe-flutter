import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/auth_login.dart';
import '../models/combo_data.dart';
import '../network/net_helper.dart';
import '../utils/keys.dart';
import '../utils/prefs_util.dart';
import '../utils/app_state.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? deepLinkUserId;
  final String? deepLinkUserPwd;

  const LoginScreen({super.key, this.deepLinkUserId, this.deepLinkUserPwd});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(text: 'test');
  final _pwdController = TextEditingController(text: 'test');
  bool _saveLogin = false;
  bool _obscurePassword = false;
  bool _isLoading = false;
  bool _isDeepLinkLogin = false;

  @override
  void initState() {
    super.initState();
    _performAutoLogin();
  }

  /// 자동 로그인 (우선순위: 저장된 정보 > 딥링크)
  void _performAutoLogin() {
    _saveLogin = PrefsUtil.getBool(Keys.prefSavedLogin);

    // 우선순위 1: 저장된 로그인 정보
    if (_saveLogin) {
      final savedId = PrefsUtil.getString(Keys.prefUserId) ?? '';
      final savedPwd = PrefsUtil.getString(Keys.prefUserPwd) ?? '';
      if (savedId.isNotEmpty && savedPwd.isNotEmpty) {
        _idController.text = savedId;
        _pwdController.text = savedPwd;
        _doLogin();
        return;
      }
    }

    // 우선순위 2: 딥링크
    if (widget.deepLinkUserId != null && widget.deepLinkUserPwd != null) {
      _idController.text = widget.deepLinkUserId!;
      _pwdController.text = widget.deepLinkUserPwd!;
      _isDeepLinkLogin = true;
      _doLogin();
      return;
    }

    // 우선순위 3: 일반 로그인 화면 표시
  }

  Future<void> _doLogin() async {
    final id = _idController.text.trim();
    final pwd = _pwdController.text.trim();
    if (id.isEmpty || pwd.isEmpty) {
      Fluttertoast.showToast(msg: '아이디와 비밀번호를 입력하세요.');
      return;
    }

    setState(() => _isLoading = true);

    String uuid = '';
    String appVersion = '3.0.1010';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        uuid = iosInfo.identifierForVendor ?? '';
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        uuid = androidInfo.id;
      }
    } catch (_) {}

    // Android와 동일: test 계정 하드코딩
    final isTestAccount = (id == 'test');
    final req = {
      'loginId': id,
      'loginPwd': isTestAccount && (pwd == '1234' || pwd == 'test') ? 'test123!@#' : pwd,
      'uuid': isTestAccount ? '950e673c8652deb9' : uuid,
      'mobileNumber': isTestAccount ? '01099068228' : '',
      'appVersion': appVersion,
    };

    if (!mounted) return;
    final resp = await NetHelper.request(context, () => NetHelper.api.authLogin(req), showProgress: false);
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (NetHelper.isSuccess(resp)) {
      final resultData = resp['resultData'];
      if (resultData != null) {
        final authLogin = AuthLogin.fromJson(resultData);
        AppState.setLoginUser(authLogin);

        // 캐시 초기화
        PrefsUtil.clearKeysStartWith('CACHE_SEARCH_CONDITION_');
        PrefsUtil.clearKeysStartWith('CACHE_SAFETY_CONDITION_');
        PrefsUtil.clearKeysStartWith('CACHE_METERING_STATUS_CONDITION_');
        PrefsUtil.clearKeysStartWith('CACHE_SAFETY_STATUS_CONDITION_');

        // 딥링크 로그인이면 자동 로그인 저장 안함
        if (!_isDeepLinkLogin && _saveLogin) {
          PrefsUtil.setString(Keys.prefUserId, id);
          PrefsUtil.setString(Keys.prefUserPwd, pwd);
        }
        PrefsUtil.setBool(Keys.prefSavedLogin, _isDeepLinkLogin ? false : _saveLogin);

        // Android와 동일: configAll(SAFE) → Safe_SW_NAME 업데이트 → 메인으로 이동
        await _updateSafeSW(authLogin.baAreaCode?.trim() ?? '');
      }
    } else {
      if (_isDeepLinkLogin) {
        _isDeepLinkLogin = false;
        _showDeepLinkLoginErrorDialog();
        return;
      }
      final msg = resp['result'] ?? '로그인에 실패했습니다.';
      Fluttertoast.showToast(msg: msg);
    }
  }

  /// Android의 updateSafeSW와 동일 - 안전관리자 이름을 조회하여 설정
  Future<void> _updateSafeSW(String areaCode) async {
    if (areaCode.isEmpty) {
      _goToMain();
      return;
    }

    final resp = await NetHelper.api.configGubun('SAFE', areaCode);
    if (NetHelper.isSuccess(resp) && resp['resultData'] != null) {
      final list = resp['resultData'];
      if (list is List) {
        final comboList = list.map((e) => ComboData.fromJson(e).toTrim()).toList();
        final user = AppState.loginUser;
        if (user != null) {
          final sw = comboList.where((c) => c.cd?.trim() == user.safeSwCode?.trim()).firstOrNull;
          if (sw != null) {
            user.safeSwName = sw.getCdName();
            AppState.setLoginUser(user);
          }
        }
      }
    }

    // configAll도 로드
    final configResp = await NetHelper.api.configAll(areaCode);
    if (NetHelper.isSuccess(configResp) && configResp['resultData'] != null) {
      AppState.parseConfigAll(configResp['resultData']);
    }

    _goToMain();
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showDeepLinkLoginErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('로그인 실패'),
        content: const Text(
          '아이디 또는 비밀번호가 일치하지 않거나 등록되지 않은 사용자입니다.\n\n'
          '기존에 사용하던 핸드폰과 DB에 등록된 핸드폰의 UUID가 일치해야 합니다.\n\n'
          '조아테크에 문의하세요.\n고객지원센터: 1566-2399',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 타이틀
                const Text('가스안전관리', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 25),
                // 로고
                Image.asset('assets/images/login_logo.png', width: 200, height: 140, fit: BoxFit.contain),
                const SizedBox(height: 32),
                // 아이디
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    hintText: '아이디를 입력하세요',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                // 비밀번호
                TextField(
                  controller: _pwdController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력하세요',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                  onSubmitted: (_) => _doLogin(),
                ),
                const SizedBox(height: 8),
                // 로그인 정보 저장
                Row(
                  children: [
                    Checkbox(
                      value: _saveLogin,
                      onChanged: (v) => setState(() => _saveLogin = v ?? false),
                    ),
                    const Text('로그인 정보 저장', style: TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 20),
                // 로그인 + 가입신청 버튼
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _doLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF555555),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('로그인', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF555555),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('가입신청', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 버전 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF555555),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('버전 3.0.1010', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwdController.dispose();
    super.dispose();
  }
}
