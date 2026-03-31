import '../../widgets/logo_loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_equip_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';

class SafetyEquipTab extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final String? anzSno;

  const SafetyEquipTab({super.key, required this.customer, this.anzSno});

  @override
  State<SafetyEquipTab> createState() => _SafetyEquipTabState();
}

class _SafetyEquipTabState extends State<SafetyEquipTab> with AutomaticKeepAliveClientMixin {
  SafetyEquipResultData? _data;
  bool _isLoading = true;
  bool _isNew = false;
  String? _anzSno;

  final _anzDateController = TextEditingController();
  final _anzGongDateController = TextEditingController();
  final _anzCustNameController = TextEditingController();
  final _anzTelController = TextEditingController();
  final _cuAddr1Controller = TextEditingController();
  final _cuAddr2Controller = TextEditingController();
  final _anzGongNoController = TextEditingController();
  final _anzGongNameController = TextEditingController();
  final _anzCuConfirmTelController = TextEditingController();
  final _gita01Controller = TextEditingController();
  final _gita02Controller = TextEditingController();

  // Inspection items
  final Map<String, String> _checkItems = {};

  bool _loaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _anzSno = widget.anzSno;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final cuCode = widget.customer.cuCode ?? '';

    try {
      Map<String, dynamic> resp;
      if (_anzSno != null && _anzSno!.isNotEmpty) {
        resp = await NetHelper.api.safetyEquip(areaCode, cuCode, _anzSno!);
      } else {
        resp = await NetHelper.api.safetyEquipLast(areaCode, cuCode);
      }
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (resp['resultCode'] == 0 && resp['resultData'] != null) {
        final resultData = resp['resultData'];
        final dataList = resultData['data'];
        if (dataList is List && dataList.isNotEmpty) {
          final d = SafetyEquipResultData.fromJson(dataList.first);
          _data = d;
          _anzSno = d.anzSno;
          _populateFields(d);
        } else {
          _isNew = true;
          _setDefaults();
        }
      } else {
        _isNew = true;
        _setDefaults();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _isNew = true;
      _setDefaults();
    }
    setState(() {});
  }

  void _populateFields(SafetyEquipResultData d) {
    _anzDateController.text = DateUtil.toDisplay(d.anzDate ?? '');
    _anzGongDateController.text = DateUtil.toDisplay(d.anzGongDate ?? '');
    _anzCustNameController.text = d.anzCustName ?? '';
    _anzTelController.text = d.anzTel ?? '';
    _cuAddr1Controller.text = d.cuAddr1 ?? '';
    _cuAddr2Controller.text = d.cuAddr2 ?? '';
    _anzGongNoController.text = d.anzGongNo ?? '';
    _anzGongNameController.text = d.anzGongName ?? '';
    _anzCuConfirmTelController.text = d.anzCuConfirmTel ?? '';
    _gita01Controller.text = d.anzGita01 ?? '';
    _gita02Controller.text = d.anzGita02 ?? '';

    // Load all check items
    _checkItems['ANZ_A_01'] = d.anzA01 ?? '';
    _checkItems['ANZ_A_02'] = d.anzA02 ?? '';
    _checkItems['ANZ_A_03'] = d.anzA03 ?? '';
    _checkItems['ANZ_A_04'] = d.anzA04 ?? '';
    _checkItems['ANZ_A_05'] = d.anzA05 ?? '';
    _checkItems['ANZ_B_01'] = d.anzB01 ?? '';
    _checkItems['ANZ_B_02'] = d.anzB02 ?? '';
    _checkItems['ANZ_B_03'] = d.anzB03 ?? '';
    _checkItems['ANZ_B_04'] = d.anzB04 ?? '';
    _checkItems['ANZ_B_05'] = d.anzB05 ?? '';
    _checkItems['ANZ_C_01'] = d.anzC01 ?? '';
    _checkItems['ANZ_C_02'] = d.anzC02 ?? '';
    _checkItems['ANZ_C_03'] = d.anzC03 ?? '';
    _checkItems['ANZ_C_04'] = d.anzC04 ?? '';
    _checkItems['ANZ_C_05'] = d.anzC05 ?? '';
    _checkItems['ANZ_C_06'] = d.anzC06 ?? '';
    _checkItems['ANZ_C_07'] = d.anzC07 ?? '';
    _checkItems['ANZ_C_08'] = d.anzC08 ?? '';
    _checkItems['ANZ_D_01'] = d.anzD01 ?? '';
    _checkItems['ANZ_D_02'] = d.anzD02 ?? '';
    _checkItems['ANZ_D_03'] = d.anzD03 ?? '';
    _checkItems['ANZ_D_04'] = d.anzD04 ?? '';
    _checkItems['ANZ_D_05'] = d.anzD05 ?? '';
    _checkItems['ANZ_E_01'] = d.anzE01 ?? '';
    _checkItems['ANZ_E_02'] = d.anzE02 ?? '';
    _checkItems['ANZ_E_03'] = d.anzE03 ?? '';
    _checkItems['ANZ_E_04'] = d.anzE04 ?? '';
    _checkItems['ANZ_F_01'] = d.anzF01 ?? '';
    _checkItems['ANZ_F_02'] = d.anzF02 ?? '';
    _checkItems['ANZ_F_03'] = d.anzF03 ?? '';
    _checkItems['ANZ_F_04'] = d.anzF04 ?? '';
    _checkItems['ANZ_G_01'] = d.anzG01 ?? '';
    _checkItems['ANZ_G_02'] = d.anzG02 ?? '';
    _checkItems['ANZ_G_03'] = d.anzG03 ?? '';
    _checkItems['ANZ_G_04'] = d.anzG04 ?? '';
    _checkItems['ANZ_G_05'] = d.anzG05 ?? '';
    _checkItems['ANZ_G_06'] = d.anzG06 ?? '';
    _checkItems['ANZ_G_07'] = d.anzG07 ?? '';
    _checkItems['ANZ_G_08'] = d.anzG08 ?? '';
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
    _anzGongDateController.text = DateUtil.toDisplay(widget.customer.cuGongDate ?? DateUtil.today());
    _anzCustNameController.text = widget.customer.cuName ?? '';
    _anzTelController.text = widget.customer.cuTel ?? '';
    _cuAddr1Controller.text = widget.customer.cuAddr1 ?? '';
    _cuAddr2Controller.text = widget.customer.cuAddr2 ?? '';
    _anzGongNoController.text = widget.customer.cuGongNo ?? '';
    _anzGongNameController.text = widget.customer.cuGongName ?? '';
    _anzCuConfirmTelController.text = widget.customer.cuHp ?? '';
  }

  Future<void> _save({bool sendSMS = false}) async {
    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}

    final req = <String, dynamic>{
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': widget.customer.cuCode,
      'ANZ_Sno': _isNew ? '' : (_anzSno ?? ''),
      'ANZ_Date': DateUtil.fromDisplay(_anzDateController.text),
      'ANZ_SW_Code': AppState.safeSwCode,
      'ANZ_SW_Name': AppState.safeSwName,
      'ANZ_CustName': _anzCustNameController.text,
      'ANZ_Tel': _anzTelController.text,
      'Zip_Code': '',
      'CU_ADDR1': _cuAddr1Controller.text,
      'CU_ADDR2': _cuAddr2Controller.text,
      'ANZ_GongDate': DateUtil.fromDisplay(_anzGongDateController.text),
      'ANZ_GongNo': _anzGongNoController.text,
      'ANZ_GongName': _anzGongNameController.text,
      'ANZ_CU_Confirm_TEL': _anzCuConfirmTelController.text,
      'ANZ_Gita_01': _gita01Controller.text,
      'ANZ_Gita_02': _gita02Controller.text,
      'ANZ_CU_Confirm': '',
      'ANZ_CU_SMS_YN': sendSMS ? 'Y' : 'N',
      'ANZ_Sign_YN': '',
      'GPS_X': pos?.longitude.toString() ?? '',
      'GPS_Y': pos?.latitude.toString() ?? '',
      'APP_User': AppState.loginUserId,
      'ANZ_Sign': '',
      'ANZ_Finish_DATE': '',
      'ANZ_Circuit_DATE': '',
    };

    // Add all check items
    _checkItems.forEach((key, value) {
      req[key] = value;
    });

    // Add remaining empty fields
    for (final k in ['ANZ_Ga', 'ANZ_Na', 'ANZ_Da', 'ANZ_Ra', 'ANZ_Ma', 'ANZ_Ba', 'ANZ_Sa', 'ANZ_AA', 'ANZ_Ja',
        'ANZ_Cha_IN', 'ANZ_Cha', 'ANZ_Car', 'ANZ_Gae_01', 'ANZ_Gae_02', 'ANZ_Gae_03', 'ANZ_Gae_04']) {
      req[k] = req[k] ?? '';
    }

    if (!mounted) return;
    final resp = await NetHelper.request(
      context,
      () => _isNew ? NetHelper.api.safetyEquipInsertNew(req) : NetHelper.api.safetyEquipUpdateNew(req),
    );
    if (!mounted) return;

    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: _isNew ? '저장되었습니다.' : '수정되었습니다.');
      final resultData = resp['resultData'];
      if (resultData != null && resultData['po_ANZ_Sno'] != null) {
        _anzSno = resultData['po_ANZ_Sno'];
        _isNew = false;
      }
      if (sendSMS) _sendSMS();
      setState(() {});
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  Future<void> _delete() async {
    if (_isNew || _anzSno == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'), content: const Text('삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final req = {
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': widget.customer.cuCode,
      'ANZ_Sno': _anzSno,
    };
    final resp = await NetHelper.request(context, () => NetHelper.api.safetyEquipDeleteNew(req));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: '삭제되었습니다.');
      _isNew = true; _anzSno = null; _data = null;
      _checkItems.clear();
      _setDefaults();
      setState(() {});
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return Center(child: LogoLoader(size: 100));

    return Column(
      children: [
        // Title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey.shade100,
          child: const Text('소비설비', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer card
                _buildCustomerCard(),
                const SizedBox(height: 8),
                _sectionTitle('기본정보'),
                _textField('점검일자', _anzDateController, readOnly: true, onTap: () => _pickDate(_anzDateController)),
                _textField('고객명', _anzCustNameController),
                _textField('연락처', _anzTelController, keyboardType: TextInputType.phone),
                _textField('주소', _cuAddr1Controller),
                _textField('상세주소', _cuAddr2Controller),
                _textField('공급관리번호', _anzGongNoController),
                _textField('공급시설명', _anzGongNameController),
                _textField('확인 연락처', _anzCuConfirmTelController, keyboardType: TextInputType.phone),
                const Divider(),
                _sectionTitle('A. 용기(실린더)'),
                _checkRow('1. 용기 상태', 'ANZ_A_01'),
                _checkRow('2. 밸브 상태', 'ANZ_A_02'),
                _checkRow('3. 호스 상태', 'ANZ_A_03'),
                _checkRow('4. 보관 장소', 'ANZ_A_04'),
                _checkRow('5. 보호조치', 'ANZ_A_05'),
                const Divider(),
                _sectionTitle('B. 압력조정기'),
                _checkRow('1. 설치 상태', 'ANZ_B_01'),
                _checkRow('2. 외관 상태', 'ANZ_B_02'),
                _checkRow('3. 기능 상태', 'ANZ_B_03'),
                _checkRow('4. 보호조치', 'ANZ_B_04'),
                _checkRow('5. 기타', 'ANZ_B_05'),
                const Divider(),
                _sectionTitle('C. 배관'),
                _checkRow('1. 배관 상태', 'ANZ_C_01'),
                _checkRow('2. 연결부', 'ANZ_C_02'),
                _checkRow('3. 고정 상태', 'ANZ_C_03'),
                _checkRow('4. 보호조치', 'ANZ_C_04'),
                _checkRow('5. 노출배관', 'ANZ_C_05'),
                _checkRow('6. 매몰배관', 'ANZ_C_06'),
                _checkRow('7. 관통부', 'ANZ_C_07'),
                _checkRow('8. 기타', 'ANZ_C_08'),
                _textField('비고', _gita01Controller),
                const Divider(),
                _sectionTitle('D. 호스'),
                _checkRow('1. 상태', 'ANZ_D_01'),
                _checkRow('2. 연결 상태', 'ANZ_D_02'),
                _checkRow('3. 길이', 'ANZ_D_03'),
                _checkRow('4. 고정 상태', 'ANZ_D_04'),
                _checkRow('5. 기타', 'ANZ_D_05'),
                const Divider(),
                _sectionTitle('E. 연소기'),
                _checkRow('1. 설치 상태', 'ANZ_E_01'),
                _checkRow('2. 환기 상태', 'ANZ_E_02'),
                _checkRow('3. 배기 상태', 'ANZ_E_03'),
                _checkRow('4. 기타', 'ANZ_E_04'),
                const Divider(),
                _sectionTitle('F. 가스계량기'),
                _checkRow('1. 설치 상태', 'ANZ_F_01'),
                _checkRow('2. 외관 상태', 'ANZ_F_02'),
                _checkRow('3. 기능 상태', 'ANZ_F_03'),
                _checkRow('4. 기타', 'ANZ_F_04'),
                const Divider(),
                _sectionTitle('G. 가스누출경보기'),
                _checkRow('1. 설치 위치', 'ANZ_G_01'),
                _checkRow('2. 경보 기능', 'ANZ_G_02'),
                _checkRow('3. 전원 상태', 'ANZ_G_03'),
                _checkRow('4. 센서 상태', 'ANZ_G_04'),
                _checkRow('5. 차단 연동', 'ANZ_G_05'),
                _checkRow('6. 타이머', 'ANZ_G_06'),
                _checkRow('7. 퓨즈콕', 'ANZ_G_07'),
                _checkRow('8. 기타', 'ANZ_G_08'),
                _textField('비고', _gita02Controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.customer.cuName ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone, size: 13, color: Colors.black45),
              const SizedBox(width: 4),
              Text(widget.customer.cuTel ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 13, color: Colors.black45),
              const SizedBox(width: 4),
              Expanded(child: Text('${widget.customer.cuAddr1 ?? ''} ${widget.customer.cuAddr2 ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _actionBtn('점검 저장', const Color(0xFF555555), () async {
                final ok = await _confirmDialog('정말 저장하시겠습니까?');
                if (ok) _save(sendSMS: false);
              })),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn('저장 후 SMS 전송', const Color(0xFF5CB85C), () async {
                final ok = await _confirmDialog('정말로 SMS를 발송하시겠습니까?');
                if (ok) _save(sendSMS: true);
              })),
            ],
          ),
          if (!_isNew) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _actionBtn('삭제', Colors.red, _delete),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44, alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<bool> _confirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인')),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _sendSMS() async {
    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final smsResp = await NetHelper.api.safetySms(areaCode, Keys.smsDivEquip);
    String smsMsg = '';
    if (NetHelper.isSuccess(smsResp) && smsResp['resultData'] != null) {
      smsMsg = smsResp['resultData']['SMS_Msg']?.toString() ?? '';
    }

    // Calculate pass/fail result
    String result = '적합';
    for (final entry in _checkItems.entries) {
      if (entry.value == '2') { result = '부적합'; break; }
    }

    smsMsg = smsMsg
        .replaceAll('{거래처명}', widget.customer.cuNameView ?? widget.customer.cuName ?? '')
        .replaceAll('{영업소코드}', areaCode)
        .replaceAll('{거래처코드}', widget.customer.cuCode ?? '')
        .replaceAll('{주소}', '${widget.customer.cuAddr1 ?? ''} ${widget.customer.cuAddr2 ?? ''}')
        .replaceAll('{점검일}', _anzDateController.text)
        .replaceAll('{점검원}', AppState.safeSwName)
        .replaceAll('{점검결과}', result);

    final tel = _anzCuConfirmTelController.text.trim().replaceAll('-', '');
    if (tel.isEmpty) { Fluttertoast.showToast(msg: '확인 연락처를 입력해주세요.'); return; }
    final uri = Uri(scheme: 'sms', path: tel, queryParameters: {'body': smsMsg});
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      color: const Color(0xFF666666),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, {
    bool readOnly = false, VoidCallback? onTap, TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
          Expanded(child: SizedBox(height: 34, child: TextField(
            controller: ctrl, readOnly: readOnly, onTap: onTap, keyboardType: keyboardType,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8), isDense: true),
            style: const TextStyle(fontSize: 12),
          ))),
        ],
      ),
    );
  }

  Widget _checkRow(String label, String key) {
    final value = _checkItems[key] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          _checkButton('적합', Keys.equipPassed, value, key),
          _checkButton('부적합', Keys.equipFailed, value, key),
          _checkButton('해당없음', Keys.equipNone, value, key),
        ],
      ),
    );
  }

  Widget _checkButton(String label, String itemValue, String currentValue, String key) {
    final isSelected = currentValue == itemValue;
    return GestureDetector(
      onTap: () => setState(() => _checkItems[key] = itemValue),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF555555) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black54)),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (date != null) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _anzDateController.dispose();
    _anzGongDateController.dispose();
    _anzCustNameController.dispose();
    _anzTelController.dispose();
    _cuAddr1Controller.dispose();
    _cuAddr2Controller.dispose();
    _anzGongNoController.dispose();
    _anzGongNameController.dispose();
    _anzCuConfirmTelController.dispose();
    _gita01Controller.dispose();
    _gita02Controller.dispose();
    super.dispose();
  }
}
