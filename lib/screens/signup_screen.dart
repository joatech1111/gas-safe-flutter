import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../network/net_helper.dart';
import '../widgets/common_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _companyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _phoneAgreed = false;
  bool _isLoading = false;
  bool _obscurePwd = true;
  bool _obscurePwdConfirm = true;

  static const _phoneChannel = MethodChannel('com.joatech.gassafe/phone');

  @override
  void initState() {
    super.initState();
    _tryGetPhoneNumber();
  }

  /// Android에서 전화번호 자동 습득 시도
  Future<void> _tryGetPhoneNumber() async {
    if (kIsWeb) return;
    try {
      final platform = Theme.of(context).platform;
      if (platform == TargetPlatform.android) {
        final phoneNumber =
            await _phoneChannel.invokeMethod<String>('getPhoneNumber');
        if (phoneNumber != null && phoneNumber.isNotEmpty && mounted) {
          setState(() {
            _phoneController.text =
                phoneNumber.replaceAll('+82', '0').replaceAll('-', '');
          });
        }
      }
    } catch (_) {}
  }

  /// 기기 모델명 조회
  Future<String> _getDeviceModel() async {
    if (kIsWeb) return 'Web';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model;
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      }
    } catch (_) {
      return '';
    }
  }

  /// 기기 고유 ID 생성 (UUID 대체)
  String _generateDeviceId() {
    if (kIsWeb) {
      // 웹: 랜덤 ID 생성
      final random = Random();
      return 'WEB_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(99999).toString().padLeft(5, '0')}';
    }
    // 모바일: device_info_plus로 가져오되, 실패 시 랜덤 생성
    final random = Random();
    return 'APP_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(99999).toString().padLeft(5, '0')}';
  }

  Future<String> _getDeviceId() async {
    if (kIsWeb) return _generateDeviceId();
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? _generateDeviceId();
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      }
    } catch (_) {
      return _generateDeviceId();
    }
  }

  Future<void> _signUp() async {
    final phone = _phoneController.text.trim().replaceAll('-', '');
    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: '전화번호를 입력하세요.');
      return;
    }
    if (phone.length < 10) {
      Fluttertoast.showToast(msg: '올바른 전화번호를 입력하세요.');
      return;
    }
    if (_companyController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '회사명을 입력하세요.');
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '사용자명을 입력하세요.');
      return;
    }
    if (_passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: '비밀번호를 입력하세요.');
      return;
    }
    if (_passwordController.text.length < 4) {
      Fluttertoast.showToast(msg: '비밀번호는 4자 이상 입력하세요.');
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      Fluttertoast.showToast(msg: '비밀번호가 일치하지 않습니다.');
      return;
    }
    if (!_phoneAgreed) {
      Fluttertoast.showToast(msg: '전화번호 수집 동의는 필수입니다.');
      return;
    }

    setState(() => _isLoading = true);

    final model = await _getDeviceModel();
    final deviceId = await _getDeviceId();

    final req = {
      'HP_IMEI': deviceId,
      'HP_Model': model,
      'HP_SNO': phone,
      'APP_VER': '3.0.1010',
      'Login_Co': _companyController.text.trim(),
      'Login_Name': _usernameController.text.trim(),
      'Login_User': phone, // 전화번호를 아이디로 사용
      'Login_Pass': _passwordController.text,
    };

    if (!mounted) return;
    final resp =
        await NetHelper.request(context, () => NetHelper.api.authSignUp(req));
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (NetHelper.isSuccess(resp)) {
      final resultData = resp['resultData'];
      if (resultData != null && resultData['po_TRAN_INFO'] != null) {
        final msg = resultData['po_TRAN_INFO'].toString();
        _showSuccessDialog(msg.length > 4 ? msg.substring(4) : msg);
      } else {
        _showSuccessDialog('가입신청이 완료되었습니다.\n관리자 승인 후 로그인할 수 있습니다.');
      }
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('가입신청 완료',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // 로그인 화면으로 돌아가기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAgreementPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('전화번호 수집 동의',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          '가스안전관리 앱 서비스 제공을 위해 사용자의 전화번호 정보를 수집합니다.\n\n'
          '수집된 정보는 서비스 이용 목적으로만 사용되며, 관련 법령에 따라 안전하게 관리됩니다.\n\n'
          '동의하시겠습니까?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _phoneAgreed = true);
            },
            child: const Text('동의'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonWidgets.buildAppBar(context, '가입신청'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 전화번호 (가장 먼저, 로그인 ID 역할)
              const Text('전화번호 (로그인 ID)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333))),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '전화번호를 입력하세요 (- 없이)',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixIcon: const Icon(Icons.phone, size: 20),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // 비밀번호
              const Text('비밀번호',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333))),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePwd,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력하세요',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixIcon: const Icon(Icons.lock, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePwd
                        ? Icons.visibility_off
                        : Icons.visibility,
                        size: 20),
                    onPressed: () =>
                        setState(() => _obscurePwd = !_obscurePwd),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),

              // 비밀번호 확인
              const Text('비밀번호 확인',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333))),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordConfirmController,
                obscureText: _obscurePwdConfirm,
                decoration: InputDecoration(
                  hintText: '비밀번호를 다시 입력하세요',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePwdConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                        size: 20),
                    onPressed: () => setState(
                        () => _obscurePwdConfirm = !_obscurePwdConfirm),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // 구분선
              const Divider(height: 1),
              const SizedBox(height: 16),

              // 회사명
              const Text('회사명',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333))),
              const SizedBox(height: 6),
              TextField(
                controller: _companyController,
                decoration: InputDecoration(
                  hintText: '회사명을 입력하세요',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixIcon: const Icon(Icons.business, size: 20),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),

              // 사용자명
              const Text('사용자명',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333))),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: '사용자명을 입력하세요',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixIcon: const Icon(Icons.person, size: 20),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // 전화번호 수집 동의
              GestureDetector(
                onTap: () {
                  if (!_phoneAgreed) {
                    _showAgreementPopup();
                  } else {
                    setState(() => _phoneAgreed = false);
                  }
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: _phoneAgreed,
                      onChanged: (v) {
                        if (v == true && !_phoneAgreed) {
                          _showAgreementPopup();
                        } else {
                          setState(() => _phoneAgreed = false);
                        }
                      },
                    ),
                    const Expanded(
                      child: Text('전화번호 수집 동의 (필수)',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 가입신청 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
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
                              color: Colors.white, strokeWidth: 2))
                      : const Text('가입신청',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // 안내 문구
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '* 가입신청 후 관리자 승인이 필요합니다.\n'
                  '* 전화번호가 로그인 ID로 사용됩니다.\n'
                  '* 고객지원센터: 1566-2399',
                  style: TextStyle(
                      fontSize: 13, color: Colors.black54, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }
}
