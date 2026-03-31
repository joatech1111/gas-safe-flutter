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
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _phoneAgreed = false;
  String _uuid = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _uuid = iosInfo.identifierForVendor ?? '';
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        _uuid = androidInfo.id;
      }
      setState(() {});
    } catch (_) {}
  }

  Future<void> _signUp() async {
    if (!_phoneAgreed) {
      Fluttertoast.showToast(msg: '전화번호 수집여부는 필수 입니다.');
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
    if (_idController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '아이디를 입력하세요.');
      return;
    }
    if (_passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: '비밀번호를 입력하세요.');
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      Fluttertoast.showToast(msg: '비밀번호가 일치하지 않습니다.');
      return;
    }

    String model = '';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        model = iosInfo.model;
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        model = androidInfo.model;
      }
    } catch (_) {}

    final req = {
      'HP_IMEI': _uuid,
      'HP_Model': model,
      'HP_SNO': '',
      'APP_VER': '3.0.1010',
      'Login_Co': _companyController.text.trim(),
      'Login_Name': _usernameController.text.trim(),
      'Login_User': _idController.text.trim(),
      'Login_Pass': _passwordController.text,
    };

    if (!mounted) return;
    final resp = await NetHelper.request(context, () => NetHelper.api.authSignUp(req));
    if (!mounted) return;

    if (NetHelper.isSuccess(resp)) {
      final resultData = resp['resultData'];
      if (resultData != null && resultData['po_TRAN_INFO'] != null) {
        final msg = resultData['po_TRAN_INFO'].toString();
        Fluttertoast.showToast(msg: msg.length > 4 ? msg.substring(4) : msg);
      } else {
        Fluttertoast.showToast(msg: '가입신청이 완료되었습니다.');
      }
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  void _showAgreementPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('전화번호 수집 동의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          '가스안전관리 앱 서비스 제공을 위해 사용자의 전화번호 정보를 수집합니다.\n\n'
          '수집된 정보는 서비스 이용 목적으로만 사용되며, 관련 법령에 따라 안전하게 관리됩니다.\n\n'
          '동의하시겠습니까?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
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
              // UUID 표시
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('인증번호 (UUID)', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _uuid.isNotEmpty ? _uuid : '로딩중...',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A90D9)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20, color: Color(0xFF4A90D9)),
                          tooltip: '복사',
                          onPressed: _uuid.isNotEmpty ? () {
                            Clipboard.setData(ClipboardData(text: _uuid));
                            Fluttertoast.showToast(msg: '인증번호가 복사되었습니다.');
                          } : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 회사명
              _buildInputField('회사명', _companyController, '회사명을 입력하세요'),
              const SizedBox(height: 12),

              // 사용자명
              _buildInputField('사용자명', _usernameController, '사용자명을 입력하세요'),
              const SizedBox(height: 12),

              // 아이디
              _buildInputField('아이디', _idController, '아이디를 입력하세요'),
              const SizedBox(height: 12),

              // 비밀번호
              _buildInputField('비밀번호', _passwordController, '비밀번호를 입력하세요', obscure: true),
              const SizedBox(height: 12),

              // 비밀번호 확인
              _buildInputField('비밀번호 확인', _passwordConfirmController, '비밀번호를 다시 입력하세요', obscure: true),
              const SizedBox(height: 20),

              // 전화번호 수집 동의
              Row(
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
                    child: Text('전화번호 수집 동의 (필수)', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 가입신청 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('가입신청', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),

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
                  '* 인증번호(UUID)를 관리자에게 알려주세요.\n'
                  '* 고객지원센터: 1566-2399',
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool obscure = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _usernameController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }
}
