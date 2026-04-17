import 'dart:convert';
import '../../widgets/logo_loader.dart';
import '../../widgets/signature_pad.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/combo_data.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_equip_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';
import '../../widgets/common_widgets.dart';

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

  // Base info controllers
  final _anzGongNoController = TextEditingController();
  final _anzGongNameController = TextEditingController();
  final _anzTelController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _cuAddr1Controller = TextEditingController();
  final _cuAddr2Controller = TextEditingController();
  final _finishDateController = TextEditingController();
  final _circuitDateController = TextEditingController();
  final _gongDateController = TextEditingController();
  final _anzDateController = TextEditingController();

  // 배관 (Pipe) A01~A05
  final _a01Controller = TextEditingController(); // 강관
  final _a02Controller = TextEditingController(); // 통관
  final _a03Controller = TextEditingController(); // 호스
  final _a04Controller = TextEditingController(); // custom label
  final _a05Controller = TextEditingController(); // custom value

  // 중간밸브 (Valve) B01~B05
  final _b01Controller = TextEditingController(); // 볼밸브
  final _b02Controller = TextEditingController(); // 퓨즈콕
  final _b03Controller = TextEditingController(); // 호스콕
  final _b04Controller = TextEditingController(); // custom label
  final _b05Controller = TextEditingController(); // custom value

  // 기타 C01~C08 + Gita01
  final _c01Controller = TextEditingController(); // item label
  final _c02Controller = TextEditingController(); // value
  final _c03Controller = TextEditingController(); // item label
  final _c04Controller = TextEditingController(); // value
  final _c05Controller = TextEditingController(); // item label
  final _c06Controller = TextEditingController(); // value
  final _c07Controller = TextEditingController(); // item label
  final _c08Controller = TextEditingController(); // value
  final _gita01Controller = TextEditingController();

  // 연소기 - 렌지 D01~D05
  final _d01Controller = TextEditingController(); // 2구렌지
  final _d02Controller = TextEditingController(); // 3구렌지
  final _d03Controller = TextEditingController(); // 오븐렌지
  final _d04Controller = TextEditingController(); // custom label
  final _d05Controller = TextEditingController(); // custom value

  // 연소기 - 보일러 E01~E04
  int _e01 = 0; // 형식 spinner index
  int _e02 = 0; // 위치 spinner index
  final _e03Controller = TextEditingController(); // 소비량
  final _e04Controller = TextEditingController(); // 3구렌지

  // 연소기 - 온수기 F01~F04
  int _f01 = 0; // 형식 spinner index
  int _f02 = 0; // 위치 spinner index
  final _f03Controller = TextEditingController(); // 소비량
  final _f04Controller = TextEditingController(); // 3구렌지

  // 연소기 - 기타 G01~G08 + Gita02
  final _g01Controller = TextEditingController();
  final _g02Controller = TextEditingController();
  final _g03Controller = TextEditingController();
  final _g04Controller = TextEditingController();
  final _g05Controller = TextEditingController();
  final _g06Controller = TextEditingController();
  final _g07Controller = TextEditingController();
  final _g08Controller = TextEditingController();
  final _gita02Controller = TextEditingController();

  // 점검결과 (가~파, 카) - spinner indices
  final Map<String, int> _checkResults = {};

  // 개선통지 + 가스용품 교체 권장
  final _gae01Controller = TextEditingController();
  final _gae02Controller = TextEditingController();
  final _gae03Controller = TextEditingController();
  final _gae04Controller = TextEditingController();

  // 확인자
  final _confirmNameController = TextEditingController();
  final _confirmTelController = TextEditingController();

  // Employee dropdown
  ComboData? _selectedSw;

  // Signature
  String? _signatureData;

  bool _loaded = false;

  // Spinner options
  static const _burnerTypes = ['', 'FF', 'FE', 'CF'];
  static const _burnerLocations = ['', '옥내', '옥외', '전용'];
  static const _burnerLocations2 = ['', '옥내', '옥외'];
  static const _checkResultOptions = [
    MapEntry('0', ''),
    MapEntry('1', '적합'),
    MapEntry('2', '부적합'),
  ];

  static const _checkLabels = [
    MapEntry('ANZ_Ga', '가. 가스누출여부와 마감조치 여부'),
    MapEntry('ANZ_Na', '나. 검사품의 검사표시 유무'),
    MapEntry('ANZ_Da', '다. 중간밸브 연소기마다 설치여부'),
    MapEntry('ANZ_Ra', '라. 호스 T형 연결금지및 밴드 접속 여부'),
    MapEntry('ANZ_Ma', '마. 보일러, 온수기 설치규정 준수 여부'),
    MapEntry('ANZ_Ba', '바. 전용보일러실에 보일러 설치 여부'),
    MapEntry('ANZ_Sa', '사. 배기통재료 내식성, 불안성 여부'),
    MapEntry('ANZ_AA', '아. 배기통의 막힘 여부'),
    MapEntry('ANZ_Ja', '자. 용기의 옥내설치(보관) 여부'),
    MapEntry('ANZ_Cha_IN', '차. 중간밸브까지 배관 적합설치 여부'),
    MapEntry('ANZ_Cha', '타. 그 밖에 가스사고 유발 우려 여부'),
    MapEntry('ANZ_Car', '파. 가스용품의 권장사용기간 경과 여부'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _anzSno = widget.anzSno;
    for (final entry in _checkLabels) {
      _checkResults[entry.key] = 0;
    }
    _initSelectedSw();
  }

  void _initSelectedSw() {
    final swCode = AppState.safeSwCode;
    if (AppState.comboSw.isNotEmpty) {
      final match = AppState.comboSw.where((c) => c.cd == swCode);
      _selectedSw = match.isNotEmpty ? match.first : AppState.comboSw.first;
    }
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
    _anzGongNoController.text = d.anzGongNo ?? '';
    _anzGongNameController.text = d.anzGongName ?? '';
    _anzTelController.text = d.anzTel ?? '';
    _zipcodeController.text = d.cuZipcode ?? '';
    _cuAddr1Controller.text = d.cuAddr1 ?? '';
    _cuAddr2Controller.text = d.cuAddr2 ?? '';
    _finishDateController.text = DateUtil.toDisplay(d.anzFinishDate ?? '');
    _circuitDateController.text = DateUtil.toDisplay(d.anzCircuitDate ?? '');
    _gongDateController.text = DateUtil.toDisplay(d.anzGongDate ?? '');
    _anzDateController.text = DateUtil.toDisplay(d.anzDate ?? '');

    // Employee
    if (d.anzSwCode != null && d.anzSwCode!.isNotEmpty) {
      final match = AppState.comboSw.where((c) => c.cd == d.anzSwCode);
      if (match.isNotEmpty) _selectedSw = match.first;
    }

    // 배관
    _a01Controller.text = d.anzA01 ?? '';
    _a02Controller.text = d.anzA02 ?? '';
    _a03Controller.text = d.anzA03 ?? '';
    _a04Controller.text = d.anzA04 ?? '';
    _a05Controller.text = d.anzA05 ?? '';

    // 중간밸브
    _b01Controller.text = d.anzB01 ?? '';
    _b02Controller.text = d.anzB02 ?? '';
    _b03Controller.text = d.anzB03 ?? '';
    _b04Controller.text = d.anzB04 ?? '';
    _b05Controller.text = d.anzB05 ?? '';

    // 기타
    _c01Controller.text = d.anzC01 ?? '';
    _c02Controller.text = d.anzC02 ?? '';
    _c03Controller.text = d.anzC03 ?? '';
    _c04Controller.text = d.anzC04 ?? '';
    _c05Controller.text = d.anzC05 ?? '';
    _c06Controller.text = d.anzC06 ?? '';
    _c07Controller.text = d.anzC07 ?? '';
    _c08Controller.text = d.anzC08 ?? '';
    _gita01Controller.text = d.anzGita01 ?? '';

    // 렌지
    _d01Controller.text = d.anzD01 ?? '';
    _d02Controller.text = d.anzD02 ?? '';
    _d03Controller.text = d.anzD03 ?? '';
    _d04Controller.text = d.anzD04 ?? '';
    _d05Controller.text = d.anzD05 ?? '';

    // 보일러
    _e01 = int.tryParse(d.anzE01 ?? '') ?? 0;
    _e02 = int.tryParse(d.anzE02 ?? '') ?? 0;
    _e03Controller.text = d.anzE03 ?? '';
    _e04Controller.text = d.anzE04 ?? '';

    // 온수기
    _f01 = int.tryParse(d.anzF01 ?? '') ?? 0;
    _f02 = int.tryParse(d.anzF02 ?? '') ?? 0;
    _f03Controller.text = d.anzF03 ?? '';
    _f04Controller.text = d.anzF04 ?? '';

    // 연소기 기타
    _g01Controller.text = d.anzG01 ?? '';
    _g02Controller.text = d.anzG02 ?? '';
    _g03Controller.text = d.anzG03 ?? '';
    _g04Controller.text = d.anzG04 ?? '';
    _g05Controller.text = d.anzG05 ?? '';
    _g06Controller.text = d.anzG06 ?? '';
    _g07Controller.text = d.anzG07 ?? '';
    _g08Controller.text = d.anzG08 ?? '';
    _gita02Controller.text = d.anzGita02 ?? '';

    // 점검결과
    _checkResults['ANZ_Ga'] = int.tryParse(d.anzGa ?? '') ?? 0;
    _checkResults['ANZ_Na'] = int.tryParse(d.anzNa ?? '') ?? 0;
    _checkResults['ANZ_Da'] = int.tryParse(d.anzDa ?? '') ?? 0;
    _checkResults['ANZ_Ra'] = int.tryParse(d.anzRa ?? '') ?? 0;
    _checkResults['ANZ_Ma'] = int.tryParse(d.anzMa ?? '') ?? 0;
    _checkResults['ANZ_Ba'] = int.tryParse(d.anzBa ?? '') ?? 0;
    _checkResults['ANZ_Sa'] = int.tryParse(d.anzSa ?? '') ?? 0;
    _checkResults['ANZ_AA'] = int.tryParse(d.anzAA ?? '') ?? 0;
    _checkResults['ANZ_Ja'] = int.tryParse(d.anzJa ?? '') ?? 0;
    _checkResults['ANZ_Cha_IN'] = int.tryParse(d.anzChaIn ?? '') ?? 0;
    _checkResults['ANZ_Cha'] = int.tryParse(d.anzCha ?? '') ?? 0;
    _checkResults['ANZ_Car'] = int.tryParse(d.anzCar ?? '') ?? 0;

    // 개선통지 + 권장
    _gae01Controller.text = d.anzGae01 ?? '';
    _gae02Controller.text = d.anzGae02 ?? '';
    _gae03Controller.text = d.anzGae03 ?? '';
    _gae04Controller.text = d.anzGae04 ?? '';

    // 확인자
    _confirmNameController.text = d.anzCuConfirm ?? '';
    _confirmTelController.text = d.anzCuConfirmTel ?? '';

    // Signature
    if (d.anzSignYN == 'Y') {
      _signatureData = '';
    }
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
    _anzTelController.text = widget.customer.cuTel ?? '';
    _zipcodeController.text = widget.customer.cuZipcode ?? '';
    _cuAddr1Controller.text = widget.customer.cuAddr1 ?? '';
    _cuAddr2Controller.text = widget.customer.cuAddr2 ?? '';
    _anzGongNoController.text = widget.customer.cuGongNo ?? '';
    _anzGongNameController.text = widget.customer.cuGongName ?? '';
    _gongDateController.text = widget.customer.cuGongDate ?? '';
    _confirmTelController.text = widget.customer.cuHp ?? '';
  }

  Future<void> _save({bool sendSMS = false}) async {
    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}

    final swCode = _selectedSw?.cd ?? AppState.safeSwCode;
    final swName = _selectedSw?.getCdName() ?? AppState.safeSwName;
    final hasSign = _signatureData != null && _signatureData!.isNotEmpty;

    final req = <String, dynamic>{
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': _isNew ? widget.customer.cuCode : (_data?.anzCuCode ?? widget.customer.cuCode),
      'ANZ_Sno': _isNew ? '' : (_anzSno ?? ''),
      'ANZ_Date': DateUtil.fromDisplay(_anzDateController.text),
      'ANZ_Finish_DATE': DateUtil.fromDisplay(_finishDateController.text),
      'ANZ_Circuit_DATE': DateUtil.fromDisplay(_circuitDateController.text),
      'ANZ_SW_Code': swCode,
      'ANZ_SW_Name': swName,
      'ANZ_CustName': widget.customer.cuNameView ?? widget.customer.cuName ?? '',
      'ANZ_Tel': _anzTelController.text,
      'Zip_Code': _zipcodeController.text,
      'CU_ADDR1': _cuAddr1Controller.text,
      'CU_ADDR2': _cuAddr2Controller.text,
      'ANZ_A_01': _a01Controller.text, 'ANZ_A_02': _a02Controller.text,
      'ANZ_A_03': _a03Controller.text, 'ANZ_A_04': _a04Controller.text, 'ANZ_A_05': _a05Controller.text,
      'ANZ_B_01': _b01Controller.text, 'ANZ_B_02': _b02Controller.text,
      'ANZ_B_03': _b03Controller.text, 'ANZ_B_04': _b04Controller.text, 'ANZ_B_05': _b05Controller.text,
      'ANZ_C_01': _c01Controller.text, 'ANZ_C_02': _c02Controller.text,
      'ANZ_C_03': _c03Controller.text, 'ANZ_C_04': _c04Controller.text,
      'ANZ_C_05': _c05Controller.text, 'ANZ_C_06': _c06Controller.text,
      'ANZ_C_07': _c07Controller.text, 'ANZ_C_08': _c08Controller.text,
      'ANZ_Gita_01': _gita01Controller.text,
      'ANZ_D_01': _d01Controller.text, 'ANZ_D_02': _d02Controller.text,
      'ANZ_D_03': _d03Controller.text, 'ANZ_D_04': _d04Controller.text, 'ANZ_D_05': _d05Controller.text,
      'ANZ_E_01': _e01.toString(), 'ANZ_E_02': _e02.toString(),
      'ANZ_E_03': _e03Controller.text, 'ANZ_E_04': _e04Controller.text,
      'ANZ_F_01': _f01.toString(), 'ANZ_F_02': _f02.toString(),
      'ANZ_F_03': _f03Controller.text, 'ANZ_F_04': _f04Controller.text,
      'ANZ_G_01': _g01Controller.text, 'ANZ_G_02': _g02Controller.text,
      'ANZ_G_03': _g03Controller.text, 'ANZ_G_04': _g04Controller.text,
      'ANZ_G_05': _g05Controller.text, 'ANZ_G_06': _g06Controller.text,
      'ANZ_G_07': _g07Controller.text, 'ANZ_G_08': _g08Controller.text,
      'ANZ_Gita_02': _gita02Controller.text,
      'ANZ_Ga': (_checkResults['ANZ_Ga'] ?? 0).toString(),
      'ANZ_Na': (_checkResults['ANZ_Na'] ?? 0).toString(),
      'ANZ_Da': (_checkResults['ANZ_Da'] ?? 0).toString(),
      'ANZ_Ra': (_checkResults['ANZ_Ra'] ?? 0).toString(),
      'ANZ_Ma': (_checkResults['ANZ_Ma'] ?? 0).toString(),
      'ANZ_Ba': (_checkResults['ANZ_Ba'] ?? 0).toString(),
      'ANZ_Sa': (_checkResults['ANZ_Sa'] ?? 0).toString(),
      'ANZ_AA': (_checkResults['ANZ_AA'] ?? 0).toString(),
      'ANZ_Ja': (_checkResults['ANZ_Ja'] ?? 0).toString(),
      'ANZ_Cha_IN': (_checkResults['ANZ_Cha_IN'] ?? 0).toString(),
      'ANZ_Cha': (_checkResults['ANZ_Cha'] ?? 0).toString(),
      'ANZ_Car': (_checkResults['ANZ_Car'] ?? 0).toString(),
      'ANZ_Gae_01': _gae01Controller.text, 'ANZ_Gae_02': _gae02Controller.text,
      'ANZ_Gae_03': _gae03Controller.text, 'ANZ_Gae_04': _gae04Controller.text,
      'ANZ_GongDate': DateUtil.fromDisplay(_gongDateController.text),
      'ANZ_CU_Confirm': _confirmNameController.text,
      'ANZ_CU_Confirm_TEL': _confirmTelController.text.replaceAll('-', ''),
      'ANZ_CU_SMS_YN': sendSMS ? 'Y' : 'N',
      'ANZ_GongNo': _anzGongNoController.text,
      'ANZ_GongName': _anzGongNameController.text,
      'ANZ_Sign_YN': hasSign ? 'Y' : 'N',
      'GPS_X': pos?.longitude.toString() ?? '',
      'GPS_Y': pos?.latitude.toString() ?? '',
      'APP_User': AppState.loginUserId,
      'ANZ_Sign': hasSign ? _signatureData! : '',
    };

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

  Future<void> _sendSMS() async {
    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final smsResp = await NetHelper.api.safetySms(areaCode, Keys.smsDivEquip);
    String smsMsg = '';
    if (NetHelper.isSuccess(smsResp) && smsResp['resultData'] != null) {
      smsMsg = smsResp['resultData']['SMS_Msg']?.toString() ?? '';
    }

    String result = '적합';
    for (final v in _checkResults.values) {
      if (v == 2) { result = '부적합'; break; }
    }

    final swName = _selectedSw?.getCdName() ?? AppState.safeSwName;
    smsMsg = smsMsg
        .replaceAll('{거래처명}', widget.customer.cuNameView ?? widget.customer.cuName ?? '')
        .replaceAll('{영업소코드}', areaCode)
        .replaceAll('{거래처코드}', widget.customer.cuCode ?? '')
        .replaceAll('{주소}', '${widget.customer.cuAddr1 ?? ''} ${widget.customer.cuAddr2 ?? ''}')
        .replaceAll('{점검일}', _anzDateController.text)
        .replaceAll('{점검원}', swName)
        .replaceAll('{점검결과}', result);

    final tel = _confirmTelController.text.trim().replaceAll('-', '');
    if (tel.isEmpty) { Fluttertoast.showToast(msg: 'SMS번호를 입력해주세요.'); return; }
    final uri = Uri(scheme: 'sms', path: tel, queryParameters: {'body': smsMsg});
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
  }

  void _showSignatureDialog() {
    final padKey = GlobalKey<SignaturePadState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('서명', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SignaturePad(key: padKey, initialSignature: _signatureData, canWrite: true),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => padKey.currentState?.clear(), child: const Text('지우기', style: TextStyle(fontSize: 14))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(fontSize: 14))),
          TextButton(
            onPressed: () async {
              final data = await padKey.currentState?.toBase64();
              setState(() => _signatureData = data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('확인', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return Center(child: LogoLoader(size: 100));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey.shade100,
          child: const Text('소비설비 안전점검', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerCard(),
                const SizedBox(height: 6),
                _buildBaseInfoSection(),
                const SizedBox(height: 6),
                _buildEquipTable(),
                const SizedBox(height: 6),
                _buildBurnerTable(),
                const SizedBox(height: 6),
                _buildCheckResultSection(),
                const SizedBox(height: 6),
                _buildImprovementSection(),
                const SizedBox(height: 6),
                _buildConfirmSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  // ── Customer card ──
  Widget _buildCustomerCard() {
    final typeName = widget.customer.cuTypeName ?? widget.customer.cuCuTypeName ?? '';
    final displayName = widget.customer.cuNameView ?? widget.customer.cuName ?? '';
    final tel = widget.customer.cuTel ?? '';
    final addr = '${widget.customer.cuAddr1 ?? ''} ${widget.customer.cuAddr2 ?? ''}';
    final checkDate = widget.customer.cuSafeDate ?? '';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (typeName.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF5B9BD5), borderRadius: BorderRadius.circular(3)),
                child: Text(typeName, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(child: Text(displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          ]),
          if (tel.isNotEmpty) ...[const SizedBox(height: 3), Text(tel, style: const TextStyle(fontSize: 12, color: Colors.black54))],
          const SizedBox(height: 2),
          Text(addr.trim(), style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis),
          if (checkDate.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text('점검일: ${DateUtil.toDisplay(checkDate)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ],
      ),
    );
  }

  // ── Base Info ──
  Widget _buildBaseInfoSection() {
    return Column(
      children: [
        // 계약번호 + 계약자명
        Row(children: [
          const _Label('계약번호'),
          Expanded(child: _SmallInput(controller: _anzGongNoController)),
          const SizedBox(width: 8),
          const _Label('계약자명'),
          Expanded(child: _SmallInput(controller: _anzGongNameController)),
        ]),
        const SizedBox(height: 4),
        // 전화
        Row(children: [
          const _Label('전화'),
          Expanded(child: _SmallInput(controller: _anzTelController, keyboardType: TextInputType.phone)),
        ]),
        const SizedBox(height: 4),
        // 우편번호
        Row(children: [
          Expanded(child: _SmallInput(controller: _zipcodeController, hint: '우편번호')),
          const SizedBox(width: 6),
          _miniBtn('우편번호찾기', () {}),
        ]),
        const SizedBox(height: 4),
        _SmallInput(controller: _cuAddr1Controller, hint: '주소'),
        const SizedBox(height: 4),
        _SmallInput(controller: _cuAddr2Controller, hint: '상세주소'),
        const SizedBox(height: 4),
        // 완성검사일 + 정기검사일
        Row(children: [
          const _Label('완성검사일'),
          Expanded(child: _dateInput(_finishDateController)),
          const SizedBox(width: 8),
          const _Label('정기검사일'),
          Expanded(child: _dateInput(_circuitDateController)),
        ]),
        const SizedBox(height: 4),
        // 공급계약일
        Row(children: [
          const _Label('공급계약일'),
          Expanded(child: _dateInput(_gongDateController)),
        ]),
        const SizedBox(height: 4),
        // 점검일자 + 점검사원
        Row(children: [
          const _Label('점검일자'),
          Expanded(child: _dateInput(_anzDateController)),
          const SizedBox(width: 8),
          const _Label('점검사원'),
          Expanded(child: _buildSwDropdown()),
        ]),
      ],
    );
  }

  // ── Equipment Table (배관, 중간밸브, 기타) ──
  Widget _buildEquipTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400, width: 0.5),
      columnWidths: const {
        0: FixedColumnWidth(36),
        1: FixedColumnWidth(44),
        2: FlexColumnWidth(1),
        3: FixedColumnWidth(44),
        4: FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // 배관 row 1: 강관 + 통관
        TableRow(children: [
          _tableHeader('배\n관', rowSpan: true),
          _tableCellText('강관'),
          _tableCellInputWithUnit(_a01Controller, 'm'),
          _tableCellText('통관'),
          _tableCellInputWithUnit(_a02Controller, 'm'),
        ]),
        // 배관 row 2: 호스 + custom
        TableRow(children: [
          const SizedBox(),
          _tableCellText('호스'),
          _tableCellInputWithUnit(_a03Controller, 'm'),
          _tableCellInput(_a04Controller),
          _tableCellInputWithUnit(_a05Controller, 'm'),
        ]),
        // 중간밸브 row 1: 볼밸브 + 퓨즈콕
        TableRow(children: [
          _tableHeader('중간\n밸브', rowSpan: true),
          _tableCellText('볼밸브'),
          _tableCellInputWithUnit(_b01Controller, '개'),
          _tableCellText('퓨즈콕'),
          _tableCellInputWithUnit(_b02Controller, '개'),
        ]),
        // 중간밸브 row 2: 호스콕 + custom
        TableRow(children: [
          const SizedBox(),
          _tableCellText('호스콕'),
          _tableCellInputWithUnit(_b03Controller, '개'),
          _tableCellInput(_b04Controller),
          _tableCellInputWithUnit(_b05Controller, '개'),
        ]),
        // 기타 row 1
        TableRow(children: [
          _tableHeader('기\n타', rowSpan: true),
          _tableCellInput(_c01Controller),
          _tableCellInputWithUnit(_c02Controller, '개'),
          _tableCellInput(_c03Controller),
          _tableCellInputWithUnit(_c04Controller, '개'),
        ]),
        // 기타 row 2
        TableRow(children: [
          const SizedBox(),
          _tableCellInput(_c05Controller),
          _tableCellInputWithUnit(_c06Controller, '개'),
          _tableCellInput(_c07Controller),
          _tableCellInputWithUnit(_c08Controller, '개'),
        ]),
      ],
    );
  }

  // ── Burner Table (연소기) ──
  Widget _buildBurnerTable() {
    return Column(
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey.shade400, width: 0.5),
          columnWidths: const {
            0: FixedColumnWidth(26),
            1: FixedColumnWidth(26),
            2: FixedColumnWidth(44),
            3: FlexColumnWidth(1),
            4: FixedColumnWidth(44),
            5: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // 렌지 row 1: 2구렌지 + 3구렌지
            TableRow(children: [
              _tableHeader('연\n소\n기', rowSpan: true),
              _tableHeader('렌\n지', rowSpan: true),
              _tableCellText('2구렌지'),
              _tableCellInputWithUnit(_d01Controller, '개'),
              _tableCellText('3구렌지'),
              _tableCellInputWithUnit(_d02Controller, '개'),
            ]),
            // 렌지 row 2: 오븐렌지 + custom
            TableRow(children: [
              const SizedBox(), const SizedBox(),
              _tableCellText('오븐렌지'),
              _tableCellInputWithUnit(_d03Controller, '개'),
              _tableCellInput(_d04Controller),
              _tableCellInputWithUnit(_d05Controller, '개'),
            ]),
            // 보일러 row 1: 형식 + 위치
            TableRow(children: [
              const SizedBox(),
              _tableHeader('보\n일\n러', rowSpan: true),
              _tableCellText('형식'),
              _tableCellSpinner(_burnerTypes, _e01, (v) => setState(() => _e01 = v)),
              _tableCellText('위치'),
              _tableCellSpinner(_burnerLocations, _e02, (v) => setState(() => _e02 = v)),
            ]),
            // 보일러 row 2: 소비량 + 3구렌지
            TableRow(children: [
              const SizedBox(), const SizedBox(),
              _tableCellText('소비량'),
              _tableCellInputWithUnit(_e03Controller, 'kg/h'),
              _tableCellText('3구렌지'),
              _tableCellInput(_e04Controller),
            ]),
            // 온수기 row 1: 형식 + 위치
            TableRow(children: [
              const SizedBox(),
              _tableHeader('온\n수\n기', rowSpan: true),
              _tableCellText('형식'),
              _tableCellSpinner(_burnerTypes, _f01, (v) => setState(() => _f01 = v)),
              _tableCellText('위치'),
              _tableCellSpinner(_burnerLocations2, _f02, (v) => setState(() => _f02 = v)),
            ]),
            // 온수기 row 2: 소비량 + 3구렌지
            TableRow(children: [
              const SizedBox(), const SizedBox(),
              _tableCellText('소비량'),
              _tableCellInputWithUnit(_f03Controller, 'kg/h'),
              _tableCellText('3구렌지'),
              _tableCellInput(_f04Controller),
            ]),
            // 기타 row 1
            TableRow(children: [
              const SizedBox(),
              _tableHeader('기\n타', rowSpan: true),
              _tableCellInput(_g01Controller),
              _tableCellInputWithUnit(_g02Controller, '개'),
              _tableCellInput(_g03Controller),
              _tableCellInputWithUnit(_g04Controller, '개'),
            ]),
            // 기타 row 2
            TableRow(children: [
              const SizedBox(), const SizedBox(),
              _tableCellInput(_g05Controller),
              _tableCellInputWithUnit(_g06Controller, '개'),
              _tableCellInput(_g07Controller),
              _tableCellInputWithUnit(_g08Controller, '개'),
            ]),
          ],
        ),
        // 기타 free text (gita02)
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 0.5)),
          child: TextField(
            controller: _gita02Controller,
            maxLines: 2,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(6),
              border: InputBorder.none, isDense: true,
            ),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ── Check Result Section (가~파) ──
  Widget _buildCheckResultSection() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
          child: const Row(children: [
            Expanded(child: Text('점검내용', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            SizedBox(width: 80, child: Text('판정', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          ]),
        ),
        for (final entry in _checkLabels)
          _buildCheckResultRow(entry.key, entry.value),
      ],
    );
  }

  Widget _buildCheckResultRow(String key, String label) {
    final val = _checkResults[key] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
          SizedBox(
            width: 80,
            height: AppInput.height,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: val < _checkResultOptions.length ? val : 0,
                  isExpanded: true, isDense: true,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  items: _checkResultOptions.asMap().entries.map((e) => DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(e.value.value, style: TextStyle(
                      fontSize: 11,
                      color: e.key == 2 ? Colors.red : Colors.black87,
                    )),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _checkResults[key] = v);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Improvement Section ──
  Widget _buildImprovementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('개선통지사항', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        _SmallInput(controller: _gae01Controller),
        const SizedBox(height: 3),
        _SmallInput(controller: _gae02Controller),
        const SizedBox(height: 8),
        const Text('가스용품 교체\n권장사항', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        _SmallInput(controller: _gae03Controller),
        const SizedBox(height: 3),
        _SmallInput(controller: _gae04Controller),
      ],
    );
  }

  // ── Confirm Section ──
  Widget _buildConfirmSection() {
    final hasSigned = _signatureData != null && _signatureData!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const _Label('확인자명'),
          Expanded(child: _SmallInput(controller: _confirmNameController)),
          const SizedBox(width: 8),
          _miniBtn(hasSigned ? '서명확인' : '서명등록', _showSignatureDialog),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const _Label('SMS번호'),
          Expanded(child: _SmallInput(controller: _confirmTelController, keyboardType: TextInputType.phone)),
        ]),
        if (hasSigned) ...[
          const SizedBox(height: 8),
          _buildSignaturePreview(),
        ],
      ],
    );
  }

  Widget _buildSignaturePreview() {
    if (_signatureData == null || _signatureData!.isEmpty) return const SizedBox();
    try {
      String s = _signatureData!;
      if (s.contains(',')) s = s.split(',').last;
      final bytes = base64Decode(s);
      return Container(
        height: 80, width: double.infinity,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
        child: Image.memory(bytes, fit: BoxFit.contain),
      );
    } catch (_) {
      return const SizedBox();
    }
  }

  // ── Bottom Buttons ──
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(child: _actionBtn('점검 저장', const Color(0xFF555555), () async {
              if (await _confirmDialog('정말 저장하시겠습니까?')) _save();
            })),
            const SizedBox(width: 8),
            Expanded(child: _actionBtn('저장 후 SMS 전송', const Color(0xFF5CB85C), () async {
              if (await _confirmDialog('정말로 SMS를 발송하시겠습니까?')) _save(sendSMS: true);
            })),
          ]),
        ],
      ),
    );
  }

  // ── Helper widgets ──
  Widget _buildSwDropdown() {
    final items = AppState.comboSw;
    if (items.isEmpty) return _SmallInput(controller: TextEditingController(text: AppState.safeSwName), readOnly: true);
    return Container(
      height: AppInput.height,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ComboData>(
          value: _selectedSw, isExpanded: true, isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          items: items.map((c) => DropdownMenuItem<ComboData>(
            value: c, child: Text(c.getCdName(), style: const TextStyle(fontSize: 12)),
          )).toList(),
          onChanged: (v) => setState(() => _selectedSw = v),
        ),
      ),
    );
  }

  Widget _dateInput(TextEditingController ctrl) {
    return GestureDetector(
      onTap: () => _pickDate(ctrl),
      child: AbsorbPointer(
        child: _SmallInput(controller: ctrl, readOnly: true),
      ),
    );
  }

  Widget _miniBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF555555), borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44, alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<bool> _confirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인')),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await CommonWidgets.showKoreanDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (date != null) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  // ── Table cell helpers ──
  Widget _tableHeader(String text, {bool rowSpan = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey.shade100,
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }

  Widget _tableCellText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      color: Colors.grey.shade50,
      child: Text(text, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
    );
  }

  Widget _tableCellInput(TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: AppInput(controller: ctrl),
    );
  }

  Widget _tableCellInputWithUnit(TextEditingController ctrl, String unit) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: AppInput(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        suffixText: unit,
      ),
    );
  }

  Widget _tableCellSpinner(List<String> items, int value, ValueChanged<int> onChanged) {
    final safeVal = value < items.length ? value : 0;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: AppInput.height,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(AppInput.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: safeVal, isExpanded: true, isDense: true,
              style: TextStyle(fontSize: AppInput.fontSize, color: Colors.black87),
              items: items.asMap().entries.map((e) => DropdownMenuItem<int>(
                value: e.key,
                child: Text(e.value.isEmpty ? ' ' : e.value, style: TextStyle(fontSize: AppInput.fontSize)),
              )).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _anzGongNoController.dispose(); _anzGongNameController.dispose();
    _anzTelController.dispose(); _zipcodeController.dispose();
    _cuAddr1Controller.dispose(); _cuAddr2Controller.dispose();
    _finishDateController.dispose(); _circuitDateController.dispose();
    _gongDateController.dispose(); _anzDateController.dispose();
    _a01Controller.dispose(); _a02Controller.dispose(); _a03Controller.dispose();
    _a04Controller.dispose(); _a05Controller.dispose();
    _b01Controller.dispose(); _b02Controller.dispose(); _b03Controller.dispose();
    _b04Controller.dispose(); _b05Controller.dispose();
    _c01Controller.dispose(); _c02Controller.dispose(); _c03Controller.dispose();
    _c04Controller.dispose(); _c05Controller.dispose(); _c06Controller.dispose();
    _c07Controller.dispose(); _c08Controller.dispose(); _gita01Controller.dispose();
    _d01Controller.dispose(); _d02Controller.dispose(); _d03Controller.dispose();
    _d04Controller.dispose(); _d05Controller.dispose();
    _e03Controller.dispose(); _e04Controller.dispose();
    _f03Controller.dispose(); _f04Controller.dispose();
    _g01Controller.dispose(); _g02Controller.dispose(); _g03Controller.dispose();
    _g04Controller.dispose(); _g05Controller.dispose(); _g06Controller.dispose();
    _g07Controller.dispose(); _g08Controller.dispose(); _gita02Controller.dispose();
    _gae01Controller.dispose(); _gae02Controller.dispose();
    _gae03Controller.dispose(); _gae04Controller.dispose();
    _confirmNameController.dispose(); _confirmTelController.dispose();
    super.dispose();
  }
}

// ── Reusable small widgets ──
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _SmallInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final TextInputType keyboardType;

  const _SmallInput({
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: controller,
      hint: hint,
      readOnly: readOnly,
      keyboardType: keyboardType,
    );
  }
}
