import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final _phoneController = TextEditingController();
  final _pwdController = TextEditingController();
  bool _saveLogin = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  List<dynamic> _userList = [];
  Map<String, dynamic>? _selectedUser;
  bool _userSelected = false; // 업체 선택 완료 여부

  @override
  void initState() {
    super.initState();
    _performAutoLogin();
  }

  /// 자동 로그인
  void _performAutoLogin() {
    _saveLogin = PrefsUtil.getBool(Keys.prefSavedLogin);

    final savedPhone = PrefsUtil.getString('PREF_PHONE_NUMBER') ?? '';
    final savedPwd = PrefsUtil.getString('PREF_PHONE_PWD') ?? '';
    final savedImei = PrefsUtil.getString('PREF_PHONE_IMEI') ?? '';

    if (_saveLogin && savedPhone.isNotEmpty && savedPwd.isNotEmpty) {
      _phoneController.text = savedPhone;
      _pwdController.text = savedPwd;
      _userSelected = true;
      _doPhoneLogin(selectedImei: savedImei.isNotEmpty ? savedImei : null);
    }
  }

  /// [Step 1] 전화번호로 업체 목록 조회
  Future<void> _doPhoneLookup() async {
    final phone = _phoneController.text.trim().replaceAll('-', '');
    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: '전화번호를 입력하세요.');
      return;
    }

    setState(() => _isLoading = true);

    if (!mounted) return;
    final resp = await NetHelper.request(
      context,
      () => NetHelper.api.authSearchByPhone(phone),
      showProgress: false,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);

    debugPrint('📱 [PhoneLookup] resp: ${jsonEncode(resp)}');

    final resultData = resp['resultData'];

    if (resultData is List && resultData.isNotEmpty) {
      _userList = resultData;
      if (_userList.length == 1) {
        // 단일 사용자 → 자동 선택
        setState(() {
          _selectedUser = _userList.first as Map<String, dynamic>;
          _userSelected = true;
        });
      } else {
        // 복수 사용자 → BottomSheet
        _showUserSelectSheet();
      }
      return;
    }

    if (resultData is Map<String, dynamic>) {
      _userList = [resultData];
      setState(() {
        _selectedUser = resultData;
        _userSelected = true;
      });
      return;
    }

    final msg = _toKoreanLoginError(resp['result']) ??
        '등록된 업체가 없습니다.\n전화번호를 확인해주세요.';
    Fluttertoast.showToast(msg: msg);
  }

  /// [Step 2] 비밀번호로 로그인
  Future<void> _doPhoneLogin({String? selectedImei}) async {
    final phone = _phoneController.text.trim().replaceAll('-', '');
    final pwd = _pwdController.text.trim();

    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: '전화번호를 입력하세요.');
      return;
    }
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
    final resp = await NetHelper.request(
      context,
      () => NetHelper.api.authLoginByPhone(req),
      showProgress: false,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);

    debugPrint('📱 [PhoneLogin] resp: ${jsonEncode(resp)}');

    if (NetHelper.isSuccess(resp)) {
      final resultData = resp['resultData'];
      dynamic singleData;
      if (resultData is List && resultData.isNotEmpty) {
        if (imei != null) {
          singleData = resultData
                  .where((u) => u['HP_IMEI'] == imei)
                  .firstOrNull ??
              resultData.first;
        } else {
          singleData = resultData.first;
        }
      } else {
        singleData = resultData;
      }

      if (singleData != null) {
        final authLogin =
            AuthLogin.fromJson(singleData as Map<String, dynamic>);
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
      final msg =
          _toKoreanLoginError(resp['result']) ?? '비밀번호가 일치하지 않습니다.';
      Fluttertoast.showToast(msg: msg);
    }
  }

  /// 로그인 버튼 클릭 시 실행
  Future<void> _onLoginPressed() async {
    final phone = _phoneController.text.trim().replaceAll('-', '');
    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: '전화번호를 입력하세요.');
      return;
    }
    final pwd = _pwdController.text.trim();
    if (pwd.isEmpty) {
      Fluttertoast.showToast(msg: '비밀번호를 입력하세요.');
      return;
    }

    // 이미 업체가 선택되어 있으면 바로 로그인
    if (_userSelected && _selectedUser != null) {
      _doPhoneLogin();
      return;
    }

    // 업체 조회 → 단일이면 바로 로그인, 복수면 BottomSheet
    setState(() => _isLoading = true);

    if (!mounted) return;
    final resp = await NetHelper.request(
      context,
      () => NetHelper.api.authSearchByPhone(phone),
      showProgress: false,
    );
    if (!mounted) return;

    final resultData = resp['resultData'];

    if (resultData is List && resultData.isNotEmpty) {
      _userList = resultData;
      if (_userList.length == 1) {
        _selectedUser = _userList.first as Map<String, dynamic>;
        _userSelected = true;
        setState(() => _isLoading = false);
        _doPhoneLogin();
      } else {
        setState(() => _isLoading = false);
        _showUserSelectSheet();
      }
      return;
    }

    if (resultData is Map<String, dynamic>) {
      _userList = [resultData];
      _selectedUser = resultData;
      _userSelected = true;
      setState(() => _isLoading = false);
      _doPhoneLogin();
      return;
    }

    setState(() => _isLoading = false);
    final msg = _toKoreanLoginError(resp['result']) ??
        '등록된 업체가 없습니다.\n전화번호를 확인해주세요.';
    Fluttertoast.showToast(msg: msg);
  }

  /// 서버 로그인 에러 메시지 → 한글 변환
  String? _toKoreanLoginError(dynamic result) {
    if (result == null) return null;
    final msg = result.toString();
    if (RegExp(r'[\uAC00-\uD7A3]').hasMatch(msg)) return msg;
    final lower = msg.toLowerCase();
    if (lower.contains('password') || lower.contains('pwd')) {
      return '비밀번호가 일치하지 않습니다.';
    }
    if (lower.contains('not found') ||
        lower.contains('not exist') ||
        lower.contains('no user')) {
      return '등록되지 않은 사용자입니다.';
    }
    if (lower.contains('unauthorized') || lower.contains('auth')) {
      return '인증에 실패했습니다.';
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
    return '로그인에 실패했습니다.\n전화번호와 비밀번호를 확인해주세요.';
  }

  /// 사용자 선택 BottomSheet
  void _showUserSelectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
                child: Row(
                  children: [
                    const Icon(Icons.people,
                        color: Color(0xFF1976D2), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '사용자 선택 (${_userList.length}건)',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Color(0xFF999999)),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 안내 문구
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: const Color(0xFFFFF8E1),
                child: const Text(
                  '해당 전화번호로 등록된 사용자가 여러 명입니다.\n로그인할 사용자를 선택해주세요.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF795548)),
                ),
              ),
              // 목록
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _userList.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 60, endIndent: 16),
                  itemBuilder: (_, i) {
                    final user = _userList[i];
                    final name = (user['Login_Name'] ?? '').toString();
                    final id = (user['Login_User'] ?? '').toString();
                    final company = (user['Login_Co'] ?? '').toString();
                    final model = (user['HP_Model'] ?? '').toString();
                    final hpState = (user['HP_State'] ?? '').toString();
                    final isActive = hpState == 'Y';

                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedUser = user;
                          _userSelected = true;
                        });
                        // 선택 후 바로 로그인 시도
                        _doPhoneLogin();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF1976D2)
                                    : const Color(0xFFBBBBBB),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                name.isNotEmpty
                                    ? name.substring(0, 1)
                                    : '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          company.isNotEmpty
                                              ? company
                                              : (name.isNotEmpty ? name : id),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF333333),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4CAF50),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '사용중',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${name.isNotEmpty ? "$name / " : ""}$id${model.isNotEmpty ? " / $model" : ""}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Color(0xFFCCCCCC), size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 안전관리자 이름 조회 후 메인 이동
  Future<void> _updateSafeSW(String areaCode) async {
    if (areaCode.isEmpty) {
      _goToMain();
      return;
    }

    final resp = await NetHelper.api.configGubun('SAFE', areaCode);
    if (NetHelper.isSuccess(resp) && resp['resultData'] != null) {
      final list = resp['resultData'];
      if (list is List) {
        final comboList =
            list.map((e) => ComboData.fromJson(e).toTrim()).toList();
        final user = AppState.loginUser;
        if (user != null) {
          final sw = comboList
              .where((c) => c.cd?.trim() == user.safeSwCode?.trim())
              .firstOrNull;
          if (sw != null) {
            user.safeSwName = sw.getCdName();
            AppState.setLoginUser(user);
          }
        }
      }
    }

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
                const Text(
                  '가스 안전관리 2026',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 25),
                Image.asset(
                  'assets/images/login_logo.png',
                  width: 200,
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                // 전화번호 입력
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: '전화번호',
                    hintText: '전화번호 (- 없이)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  style: const TextStyle(fontSize: 18),
                  onChanged: (_) {
                    // 전화번호 변경 시 이전 선택 초기화
                    if (_userSelected) {
                      setState(() {
                        _userList = [];
                        _selectedUser = null;
                        _userSelected = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // 선택된 사용자 표시
                if (_userSelected && _selectedUser != null)
                  _buildSelectedUserChip(),

                // 비밀번호 입력
                TextField(
                  controller: _pwdController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력하세요',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                  onSubmitted: (_) => _onLoginPressed(),
                ),
                const SizedBox(height: 8),

                // 로그인 정보 저장
                Row(
                  children: [
                    Checkbox(
                      value: _saveLogin,
                      onChanged: (v) =>
                          setState(() => _saveLogin = v ?? false),
                    ),
                    const Text('로그인 정보 저장',
                        style: TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 20),

                // 로그인 / 가입신청 버튼
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  '로그인',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D1B3E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            '가입신청',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 버전 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF555555),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '버전 3.0.1010',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 선택된 사용자 칩 위젯
  Widget _buildSelectedUserChip() {
    final company = (_selectedUser!['Login_Co'] ?? '').toString();
    final name = (_selectedUser!['Login_Name'] ?? '').toString();
    final id = (_selectedUser!['Login_User'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1976D2), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF1976D2), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${company.isNotEmpty ? "$company · " : ""}${name.isNotEmpty ? name : id}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_userList.length > 1)
              GestureDetector(
                onTap: _showUserSelectSheet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '변경',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pwdController.dispose();
    super.dispose();
  }
}
