import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _idController = TextEditingController(text: 'test2');
  final _pwdController = TextEditingController(text: 'test2');
  final _phoneController = TextEditingController();
  final _phonePwdController = TextEditingController();
  bool _saveLogin = false;
  bool _obscurePassword = false;
  bool _obscurePhonePwd = false;
  bool _isLoading = false;
  bool _isDeepLinkLogin = false;
  bool _isPhoneLogin = false; // false = ID/PWD 로그인, true = 전화번호 로그인
  List<dynamic> _multiUserList = []; // 복수 사용자 목록
  int _phoneStep = 0; // 0=전화번호 입력, 1=업체 선택 완료→비밀번호 입력
  Map<String, dynamic>? _selectedUser; // 선택된 업체/사용자

  @override
  void initState() {
    super.initState();
    _performAutoLogin();
  }

  /// 자동 로그인 (우선순위: 저장된 정보 > 딥링크)
  void _performAutoLogin() {
    _saveLogin = PrefsUtil.getBool(Keys.prefSavedLogin);

    // 저장된 전화번호 로그인 모드 확인
    final savedPhoneLogin = PrefsUtil.getBool('PREF_PHONE_LOGIN');
    if (savedPhoneLogin) {
      _isPhoneLogin = true;
      final savedPhone = PrefsUtil.getString('PREF_PHONE_NUMBER') ?? '';
      final savedPhonePwd = PrefsUtil.getString('PREF_PHONE_PWD') ?? '';
      final savedImei = PrefsUtil.getString('PREF_PHONE_IMEI') ?? '';
      if (_saveLogin && savedPhone.isNotEmpty && savedPhonePwd.isNotEmpty) {
        _phoneController.text = savedPhone;
        _phonePwdController.text = savedPhonePwd;
        // 자동 로그인: 저장된 IMEI로 바로 로그인 시도
        _phoneStep = 1;
        _doPhoneLogin(selectedImei: savedImei.isNotEmpty ? savedImei : null);
        return;
      }
    }

    // 우선순위 1: 저장된 로그인 정보
    if (_saveLogin && !savedPhoneLogin) {
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
          PrefsUtil.setBool('PREF_PHONE_LOGIN', false);
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
      final msg = _toKoreanLoginError(resp['result']) ?? '로그인에 실패했습니다.';
      Fluttertoast.showToast(msg: msg);
    }
  }

  /// 서버 로그인 에러 메시지 → 한글 변환
  String? _toKoreanLoginError(dynamic result) {
    if (result == null) return null;
    final msg = result.toString();
    // 이미 한글이면 그대로
    if (RegExp(r'[\uAC00-\uD7A3]').hasMatch(msg)) return msg;
    // 영어 에러 메시지 → 한글
    final lower = msg.toLowerCase();
    if (lower.contains('password') || lower.contains('pwd')) {
      return '비밀번호가 일치하지 않습니다.';
    }
    if (lower.contains('not found') || lower.contains('not exist') || lower.contains('no user')) {
      return '등록되지 않은 사용자입니다.';
    }
    if (lower.contains('unauthorized') || lower.contains('auth')) {
      return '인증에 실패했습니다. 아이디와 비밀번호를 확인해주세요.';
    }
    if (lower.contains('locked') || lower.contains('block')) {
      return '계정이 잠겼습니다. 관리자에게 문의해주세요.';
    }
    if (lower.contains('uuid') || lower.contains('device')) {
      return '등록되지 않은 기기입니다.\n조아테크에 문의해주세요. (1566-2399)';
    }
    if (lower.contains('expired')) {
      return '계정이 만료되었습니다. 관리자에게 문의해주세요.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return '서버 연결 시간이 초과되었습니다.';
    }
    if (lower.contains('connection') || lower.contains('network')) {
      return '네트워크 연결에 실패했습니다.';
    }
    // 알 수 없는 영어 메시지는 기본 한글로
    return '로그인에 실패했습니다.\n아이디와 비밀번호를 확인해주세요.';
  }

  /// [Step 0] 전화번호로 업체 목록 조회
  Future<void> _doPhoneLookup() async {
    final phone = _phoneController.text.trim().replaceAll('-', '');
    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: '전화번호를 입력하세요.');
      return;
    }

    setState(() => _isLoading = true);

    if (!mounted) return;
    final resp = await NetHelper.request(context, () => NetHelper.api.authSearchByPhone(phone), showProgress: false);
    if (!mounted) return;

    setState(() => _isLoading = false);

    debugPrint('📱 [PhoneLookup] resp: ${jsonEncode(resp)}');

    final resultData = resp['resultData'];

    // resultData가 List이면 (복수 또는 단일) 업체 목록 표시
    if (resultData is List && resultData.isNotEmpty) {
      setState(() {
        _multiUserList = resultData;
        _selectedUser = null;
        _phoneStep = 0;
      });
      return;
    }

    // resultData가 Map이면 단일 사용자 → 바로 목록 1건으로 표시
    if (resultData is Map<String, dynamic>) {
      setState(() {
        _multiUserList = [resultData];
        _selectedUser = null;
        _phoneStep = 0;
      });
      return;
    }

    // 실패
    final msg = _toKoreanLoginError(resp['result']) ?? '등록된 업체가 없습니다.\n전화번호를 확인해주세요.';
    Fluttertoast.showToast(msg: msg);
  }

  /// [Step 1] 업체 선택 후 비밀번호로 로그인
  Future<void> _doPhoneLogin({String? selectedImei}) async {
    final phone = _phoneController.text.trim().replaceAll('-', '');
    final pwd = _phonePwdController.text.trim();
    if (pwd.isEmpty) {
      Fluttertoast.showToast(msg: '비밀번호를 입력하세요.');
      return;
    }

    setState(() => _isLoading = true);

    final req = <String, dynamic>{
      'phoneNumber': phone,
      'loginPwd': pwd,
      'appVersion': '3.0.1010',
    };
    final imei = selectedImei ?? _selectedUser?['HP_IMEI'];
    if (imei != null && imei.toString().isNotEmpty) {
      req['selectedImei'] = imei;
    }

    if (!mounted) return;
    final resp = await NetHelper.request(context, () => NetHelper.api.authLoginByPhone(req), showProgress: false);
    if (!mounted) return;

    setState(() => _isLoading = false);

    debugPrint('📱 [PhoneLogin] resp: ${jsonEncode(resp)}');

    if (NetHelper.isSuccess(resp)) {
      final resultData = resp['resultData'];
      // resultData가 List인 경우 selectedImei로 필터링 또는 첫번째 사용
      dynamic singleData;
      if (resultData is List && resultData.isNotEmpty) {
        if (imei != null) {
          singleData = resultData.where((u) => u['HP_IMEI'] == imei).firstOrNull ?? resultData.first;
        } else {
          singleData = resultData.first;
        }
      } else {
        singleData = resultData;
      }

      if (singleData != null) {
        final authLogin = AuthLogin.fromJson(singleData as Map<String, dynamic>);
        AppState.setLoginUser(authLogin);

        PrefsUtil.clearKeysStartWith('CACHE_SEARCH_CONDITION_');
        PrefsUtil.clearKeysStartWith('CACHE_SAFETY_CONDITION_');
        PrefsUtil.clearKeysStartWith('CACHE_METERING_STATUS_CONDITION_');
        PrefsUtil.clearKeysStartWith('CACHE_SAFETY_STATUS_CONDITION_');

        if (_saveLogin) {
          PrefsUtil.setString('PREF_PHONE_NUMBER', phone);
          PrefsUtil.setString('PREF_PHONE_PWD', pwd);
          PrefsUtil.setBool('PREF_PHONE_LOGIN', true);
          if (imei != null) {
            PrefsUtil.setString('PREF_PHONE_IMEI', imei.toString());
          }
        }
        PrefsUtil.setBool(Keys.prefSavedLogin, _saveLogin);

        await _updateSafeSW(authLogin.baAreaCode?.trim() ?? '');
      }
    } else {
      final msg = _toKoreanLoginError(resp['result']) ?? '비밀번호가 일치하지 않습니다.';
      Fluttertoast.showToast(msg: msg);
    }
  }

  /// 업체 목록 선택 UI
  Widget _buildCompanyList() {
    if (_multiUserList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1976D2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '업체 선택 (${_multiUserList.length}건)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _multiUserList = [];
                  _selectedUser = null;
                  _phoneStep = 0;
                  _phonePwdController.clear();
                }),
                child: const Icon(Icons.close, color: Colors.white70, size: 20),
              ),
            ],
          ),
        ),
        // 목록
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _multiUserList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 12, endIndent: 12),
            itemBuilder: (_, i) {
              final user = _multiUserList[i];
              final name = user['Login_Name'] ?? '';
              final id = user['Login_User'] ?? '';
              final company = user['Login_Co'] ?? '';
              final model = user['HP_Model'] ?? '';
              final imei = user['HP_IMEI'] ?? '';
              final hpState = user['HP_State'] ?? '';
              final isActive = hpState == 'Y';
              final isSelected = _selectedUser != null && _selectedUser!['HP_IMEI'] == imei;

              return Material(
                color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                borderRadius: i == _multiUserList.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(8))
                    : BorderRadius.zero,
                child: InkWell(
                  borderRadius: i == _multiUserList.length - 1
                      ? const BorderRadius.vertical(bottom: Radius.circular(8))
                      : BorderRadius.zero,
                  onTap: () {
                    setState(() {
                      _selectedUser = user;
                      _phoneStep = 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        // 선택 상태 아이콘
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1976D2)
                                : (isActive ? const Color(0xFF90CAF9) : const Color(0xFFBBBBBB)),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : Text(
                                  '${i + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      company.isNotEmpty ? company : (name.isNotEmpty ? name : id),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? const Color(0xFF1976D2) : const Color(0xFF333333),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('사용중', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${name.isNotEmpty ? "$name / " : ""}$id${model.isNotEmpty ? " / $model" : ""}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFF1976D2) : const Color(0xFFCCCCCC),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
                const Text('가스 안전관리 2026', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 25),
                // 로고
                Image.asset('assets/images/login_logo.png', width: 200, height: 140, fit: BoxFit.contain),
                const SizedBox(height: 24),
                // 로그인 모드 전환 탭
                _buildLoginModeToggle(),
                const SizedBox(height: 20),
                // 로그인 폼
                _isPhoneLogin ? _buildPhoneLoginForm() : _buildIdPwdLoginForm(),
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
                // 로그인 / 가입신청 버튼
                if (!_isPhoneLogin)
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

  /// 로그인 모드 전환 토글 (ID/PWD <-> 전화번호)
  Widget _buildLoginModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() { _isPhoneLogin = false; _multiUserList = []; _selectedUser = null; _phoneStep = 0; _phonePwdController.clear(); }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isPhoneLogin ? const Color(0xFF555555) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'UUID / ID / 비밀번호',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: !_isPhoneLogin ? Colors.white : const Color(0xFF888888),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isPhoneLogin = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isPhoneLogin ? const Color(0xFF1976D2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '전화번호',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _isPhoneLogin ? Colors.white : const Color(0xFF888888),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ID/PWD 로그인 폼
  Widget _buildIdPwdLoginForm() {
    return Column(
      children: [
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
      ],
    );
  }

  /// 전화번호 로그인 폼 (3단계)
  Widget _buildPhoneLoginForm() {
    return Column(
      children: [
        // ── Step 0: 전화번호 입력 + 조회 버튼 ──
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: '전화번호',
                  hintText: '전화번호 (- 없이)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (_) {
                  // 전화번호 변경 시 이전 조회 결과 초기화
                  if (_multiUserList.isNotEmpty) {
                    setState(() {
                      _multiUserList = [];
                      _selectedUser = null;
                      _phoneStep = 0;
                      _phonePwdController.clear();
                    });
                  }
                },
                onSubmitted: (_) => _doPhoneLookup(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 56,
              width: 80,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _doPhoneLookup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                ),
                child: _isLoading && _phoneStep == 0
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('조회', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),

        // ── Step 1: 업체 목록 ──
        _buildCompanyList(),

        // ── Step 2: 선택된 업체 표시 + 비밀번호 ──
        if (_phoneStep == 1 && _selectedUser != null) ...[
          const SizedBox(height: 16),
          // 선택된 업체 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1976D2), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.business, color: Color(0xFF1976D2), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_selectedUser!['Login_Co'] ?? '').toString().isNotEmpty
                            ? _selectedUser!['Login_Co']
                            : _selectedUser!['Login_Name'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                      ),
                      Text(
                        '${_selectedUser!['Login_Name'] ?? ''} (${_selectedUser!['Login_User'] ?? ''})',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedUser = null;
                    _phoneStep = 0;
                    _phonePwdController.clear();
                  }),
                  child: const Icon(Icons.edit, color: Color(0xFF1976D2), size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 비밀번호 입력
          TextField(
            controller: _phonePwdController,
            obscureText: _obscurePhonePwd,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '비밀번호를 입력하세요',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePhonePwd ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePhonePwd = !_obscurePhonePwd),
              ),
            ),
            style: const TextStyle(fontSize: 18),
            onSubmitted: (_) => _doPhoneLogin(),
          ),
          const SizedBox(height: 12),
          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _doPhoneLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading && _phoneStep == 1
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('로그인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwdController.dispose();
    _phoneController.dispose();
    _phonePwdController.dispose();
    super.dispose();
  }
}
