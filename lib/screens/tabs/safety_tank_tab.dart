import 'dart:convert';
import '../../widgets/logo_loader.dart';
import '../../widgets/signature_pad.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/combo_data.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_tank_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';
import '../../widgets/common_widgets.dart';

class SafetyTankTab extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final String? anzSno;

  const SafetyTankTab({super.key, required this.customer, this.anzSno});

  @override
  State<SafetyTankTab> createState() => _SafetyTankTabState();
}

class _SafetyTankTabState extends State<SafetyTankTab> with AutomaticKeepAliveClientMixin {
  SafetyTankResultData? _data;
  bool _isLoading = true;
  bool _isNew = false;
  String? _anzSno;

  final _anzDateController = TextEditingController();
  final _tankKg01Controller = TextEditingController();
  final _tankKg02Controller = TextEditingController();
  final _bigo1Controller = TextEditingController();
  final _bigo2Controller = TextEditingController();
  final _anzCuConfirmTelController = TextEditingController();
  final _anzCustNameController = TextEditingController();

  // Editable labels for items 10-12
  final _checkItem10Controller = TextEditingController(text: '발신기 작동 여부');
  final _checkItem11Controller = TextEditingController(text: '');
  final _checkItem12Controller = TextEditingController(text: '');

  final Map<String, String> _tankItems = {};
  final Map<String, TextEditingController> _bigoControllers = {};

  // Employee dropdown
  ComboData? _selectedSw;

  // Signature
  String? _signatureBase64;
  final GlobalKey<SignaturePadState> _signatureKey = GlobalKey<SignaturePadState>();

  bool _loaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _anzSno = widget.anzSno;
    for (int i = 1; i <= 12; i++) {
      final key = i.toString().padLeft(2, '0');
      _bigoControllers['ANZ_TANK_${key}_Bigo'] = TextEditingController();
    }
    // Initialize employee dropdown
    _initSelectedSw();
  }

  void _initSelectedSw() {
    final swList = AppState.comboSw;
    if (swList.isNotEmpty) {
      final match = swList.where((e) => e.cd == AppState.safeSwCode).toList();
      _selectedSw = match.isNotEmpty ? match.first : swList.first;
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
        resp = await NetHelper.api.safetyTank(areaCode, cuCode, _anzSno!);
      } else {
        resp = await NetHelper.api.safetyTankLast(areaCode, cuCode);
      }
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (resp['resultCode'] == 0 && resp['resultData'] != null) {
        final resultData = resp['resultData'];
        final dataList = resultData['data'];
        if (dataList is List && dataList.isNotEmpty) {
          final d = SafetyTankResultData.fromJson(dataList.first);
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

  void _populateFields(SafetyTankResultData d) {
    _anzDateController.text = DateUtil.toDisplay(d.anzDate ?? '');
    _tankKg01Controller.text = d.anzTankKg01 ?? '';
    _tankKg02Controller.text = d.anzTankKg02 ?? '';
    _bigo1Controller.text = d.anzTankSwBigo1 ?? '';
    _bigo2Controller.text = d.anzTankSwBigo2 ?? '';
    _anzCuConfirmTelController.text = d.anzCuConfirmTel ?? '';
    _anzCustNameController.text = d.anzCustName ?? '';
    _signatureBase64 = null; // Will be loaded if needed

    // Set employee dropdown from loaded data
    if (d.anzSwCode != null && d.anzSwCode!.isNotEmpty) {
      final swList = AppState.comboSw;
      final match = swList.where((e) => e.cd == d.anzSwCode).toList();
      if (match.isNotEmpty) _selectedSw = match.first;
    }

    // Editable labels for items 10-12
    _checkItem10Controller.text = (d.anzCheckItem10 != null && d.anzCheckItem10!.isNotEmpty) ? d.anzCheckItem10! : '발신기 작동 여부';
    _checkItem11Controller.text = (d.anzCheckItem11 != null && d.anzCheckItem11!.isNotEmpty) ? d.anzCheckItem11! : '';
    _checkItem12Controller.text = (d.anzCheckItem12 != null && d.anzCheckItem12!.isNotEmpty) ? d.anzCheckItem12! : '';

    final items = [d.anzTank01, d.anzTank02, d.anzTank03, d.anzTank04, d.anzTank05,
      d.anzTank06, d.anzTank07, d.anzTank08, d.anzTank09, d.anzTank10, d.anzTank11, d.anzTank12];
    final bigos = [d.anzTank01Bigo, d.anzTank02Bigo, d.anzTank03Bigo, d.anzTank04Bigo, d.anzTank05Bigo,
      d.anzTank06Bigo, d.anzTank07Bigo, d.anzTank08Bigo, d.anzTank09Bigo, d.anzTank10Bigo, d.anzTank11Bigo, d.anzTank12Bigo];

    for (int i = 0; i < 12; i++) {
      final key = (i + 1).toString().padLeft(2, '0');
      _tankItems['ANZ_TANK_$key'] = items[i] ?? '';
      _bigoControllers['ANZ_TANK_${key}_Bigo']!.text = bigos[i] ?? '';
    }

    // Sign YN
    if (d.anzSignYN == 'Y') {
      // Signature was previously saved; we don't have the image data from load
      // but we note that it exists
    }
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
    _anzCuConfirmTelController.text = widget.customer.cuHp ?? '';
    _anzCustNameController.text = widget.customer.cuName ?? '';
  }

  Future<void> _save({bool sendSMS = false}) async {
    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}

    // Get signature base64
    String signBase64 = '';
    String signYN = 'N';
    if (_signatureKey.currentState != null && !_signatureKey.currentState!.isEmpty) {
      final sig = await _signatureKey.currentState!.toBase64();
      if (sig != null && sig.isNotEmpty) {
        signBase64 = sig;
        signYN = 'Y';
      }
    } else if (_signatureBase64 != null && _signatureBase64!.isNotEmpty) {
      signBase64 = _signatureBase64!;
      signYN = 'Y';
    }

    final swCode = _selectedSw?.cd ?? AppState.safeSwCode;
    final swName = _selectedSw?.getCdName() ?? AppState.safeSwName;

    final req = <String, dynamic>{
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': widget.customer.cuCode,
      'ANZ_Sno': _isNew ? '' : (_anzSno ?? ''),
      'ANZ_Date': DateUtil.fromDisplay(_anzDateController.text),
      'ANZ_SW_Code': swCode,
      'ANZ_SW_Name': swName,
      'ANZ_TANK_KG_01': _tankKg01Controller.text,
      'ANZ_TANK_KG_02': _tankKg02Controller.text,
      'ANZ_TANK_SW_Bigo1': _bigo1Controller.text,
      'ANZ_TANK_SW_Bigo2': _bigo2Controller.text,
      'ANZ_CustName': _anzCustNameController.text,
      'ANZ_Sign_YN': signYN,
      'ANZ_CU_Confirm': _anzCustNameController.text,
      'ANZ_CU_Confirm_TEL': _anzCuConfirmTelController.text,
      'ANZ_CU_SMS_YN': sendSMS ? 'Y' : 'N',
      // Android와 동일: GPS_X = 위도(latitude), GPS_Y = 경도(longitude)
      'GPS_X': pos?.latitude.toString() ?? '',
      'GPS_Y': pos?.longitude.toString() ?? '',
      'ANZ_User_ID': AppState.loginUserId,
      'ANZ_Sign': signBase64,
    };

    for (int i = 1; i <= 12; i++) {
      final key = i.toString().padLeft(2, '0');
      req['ANZ_TANK_$key'] = _tankItems['ANZ_TANK_$key'] ?? '';
      req['ANZ_TANK_${key}_Bigo'] = _bigoControllers['ANZ_TANK_${key}_Bigo']!.text;
    }
    req['ANZ_Check_item_10'] = _checkItem10Controller.text;
    req['ANZ_Check_item_11'] = _checkItem11Controller.text;
    req['ANZ_Check_item_12'] = _checkItem12Controller.text;

    if (!mounted) return;
    final resp = await NetHelper.request(
      context,
      () => _isNew ? NetHelper.api.safetyTankInsert(req) : NetHelper.api.safetyTankUpdate(req),
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
    final smsResp = await NetHelper.api.safetySms(areaCode, Keys.smsDivTank);
    String smsMsg = '';
    if (NetHelper.isSuccess(smsResp) && smsResp['resultData'] != null) {
      smsMsg = smsResp['resultData']['SMS_Msg']?.toString() ?? '';
    }

    // Calculate pass/fail result
    String result = '적합';
    for (final entry in _tankItems.entries) {
      if (entry.value == Keys.tankFailed) { result = '부적합'; break; }
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

    final tel = _anzCuConfirmTelController.text.trim().replaceAll('-', '');
    if (tel.isEmpty) { Fluttertoast.showToast(msg: '확인 연락처를 입력해주세요.'); return; }
    final uri = Uri(scheme: 'sms', path: tel, queryParameters: {'body': smsMsg});
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
  }

  // Result dropdown values matching Kotlin spinner_default_check_result
  static const _resultOptions = [
    MapEntry('', '선택'),       // index 0 - empty
    MapEntry('1', '적합'),      // index 1
    MapEntry('2', '부적합'),    // index 2
  ];

  static const _tankLabels = [
    '1. 저장탱크 경계표시 및 도색',
    '2. 저장탱크 화기와의 거리',
    '3. 가스누설경보기 설치 및 상태',
    '4. 배관의 도색, 고정, 표시 상태',
    '5. 안전밸브의 설치 및 작동 상태',
    '6. 정기검사 실시 여부',
    '7. 안전관리자 선임 여부',
    '8. 손해배상 보험가입 여부',
    '9. 소화기 비치 여부 및 개수',
  ];

  void _openSignatureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final sigKey = GlobalKey<SignaturePadState>();
        return AlertDialog(
          title: const Text('서명', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SignaturePad(key: sigKey, initialSignature: _signatureBase64, canWrite: true),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => sigKey.currentState?.clear(),
                      child: const Text('지우기', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              onPressed: () async {
                final base64 = await sigKey.currentState?.toBase64();
                setState(() {
                  _signatureBase64 = base64;
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('확인', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
          child: const Text('안전관리 실시대장', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _buildSwDropdownRow(),
                const SizedBox(height: 4),
                _buildStorageRow(),
                const Divider(),
                _sectionTitle('점검항목'),
                _buildCheckTable(),
                const Divider(),
                _sectionTitle('점검자 의견'),
                _textField('의견1', _bigo1Controller),
                _textField('의견2', _bigo2Controller),
                const Divider(),
                _sectionTitle('확인자 정보'),
                _textField('확인자명', _anzCustNameController),
                _textField('SMS번호', _anzCuConfirmTelController, keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                _buildSignatureSection(),
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
    final typeName = widget.customer.cuTypeName ?? widget.customer.cuCuTypeName ?? '';
    final displayName = widget.customer.cuNameView ?? widget.customer.cuName ?? '';
    final tel = widget.customer.cuTel ?? '';
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
              if (typeName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9BD5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(typeName, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
          if (tel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.phone, size: 13, color: Colors.black45),
              const SizedBox(width: 4),
              Text(tel, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ],
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.location_on, size: 13, color: Colors.black45),
            const SizedBox(width: 4),
            Expanded(child: Text('${widget.customer.cuAddr1 ?? ''} ${widget.customer.cuAddr2 ?? ''}',
                style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSwDropdownRow() {
    final swList = AppState.comboSw;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('점검사원', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(
            child: Container(
              height: AppInput.height,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ComboData>(
                  value: _selectedSw,
                  isExpanded: true,
                  isDense: true,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  items: swList.map((e) => DropdownMenuItem<ComboData>(
                    value: e,
                    child: Text(e.getCdName(), style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedSw = v),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('저장량', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          SizedBox(width: 80, child: AppInput(controller: _tankKg01Controller, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('kg', style: TextStyle(fontSize: 13))),
          SizedBox(width: 80, child: AppInput(controller: _tankKg02Controller, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('kg', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckTable() {
    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
          ),
          child: const Row(
            children: [
              Expanded(flex: 5, child: Text('점검내용', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              SizedBox(width: 4),
              SizedBox(width: 80, child: Text('결과', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              SizedBox(width: 4),
              Expanded(flex: 3, child: Text('비고', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            ],
          ),
        ),
        // Items 1-9 (fixed labels)
        for (int i = 0; i < 9; i++)
          _buildCheckTableRow(
            _tankLabels[i],
            'ANZ_TANK_${(i + 1).toString().padLeft(2, '0')}',
            isEditable: false,
          ),
        // Items 10-12 (editable labels)
        _buildCheckTableRow(
          null,
          'ANZ_TANK_10',
          isEditable: true,
          labelPrefix: '10. ',
          labelController: _checkItem10Controller,
        ),
        _buildCheckTableRow(
          null,
          'ANZ_TANK_11',
          isEditable: true,
          labelPrefix: '11. ',
          labelController: _checkItem11Controller,
        ),
        _buildCheckTableRow(
          null,
          'ANZ_TANK_12',
          isEditable: true,
          labelPrefix: '12. ',
          labelController: _checkItem12Controller,
        ),
      ],
    );
  }

  Widget _buildCheckTableRow(
    String? label,
    String key, {
    bool isEditable = false,
    String labelPrefix = '',
    TextEditingController? labelController,
  }) {
    final value = _tankItems[key] ?? '';
    final bigoKey = '${key}_Bigo';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label column
          Expanded(
            flex: 5,
            child: isEditable && labelController != null
                ? Row(
                    children: [
                      Text(labelPrefix, style: const TextStyle(fontSize: 12)),
                      Expanded(
                        child: SizedBox(
                          height: AppInput.height,
                          child: TextField(
                            controller: labelController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(label ?? '', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          // Result dropdown
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
                child: DropdownButton<String>(
                  value: _resultOptions.any((e) => e.key == value) ? value : '',
                  isExpanded: true,
                  isDense: true,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  items: _resultOptions.map((e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value, style: TextStyle(
                      fontSize: 12,
                      color: e.key == '2' ? Colors.red : Colors.black87,
                    )),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _tankItems[key] = v);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Bigo text field
          Expanded(
            flex: 3,
            child: SizedBox(
              height: AppInput.height,
              child: TextField(
                controller: _bigoControllers[bigoKey],
                decoration: InputDecoration(
                  hintText: '비고',
                  hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    final hasSignature = _signatureBase64 != null && _signatureBase64!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('서명', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _openSignatureDialog,
              icon: const Icon(Icons.edit, size: 16),
              label: Text(hasSignature ? '서명수정' : '서명등록', style: const TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF555555),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            if (hasSignature) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => _signatureBase64 = null),
                child: const Text('서명삭제', style: TextStyle(fontSize: 13, color: Colors.red)),
              ),
            ],
          ],
        ),
        if (hasSignature) ...[
          const SizedBox(height: 8),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: _buildSignaturePreview(),
          ),
        ],
      ],
    );
  }

  Widget _buildSignaturePreview() {
    if (_signatureBase64 == null || _signatureBase64!.isEmpty) {
      return const Center(child: Text('서명 없음', style: TextStyle(color: Colors.grey)));
    }
    try {
      String base64Str = _signatureBase64!;
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: BoxFit.contain);
    } catch (_) {
      return const Center(child: Text('서명 미리보기 오류', style: TextStyle(color: Colors.grey)));
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(child: _actionBtn('점검 저장', const Color(0xFF555555), () async {
            final ok = await _confirmDialog('정말 저장하시겠습니까?');
            if (ok) _save();
          })),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn('저장 후 SMS 전송', const Color(0xFF5CB85C), () async {
            final ok = await _confirmDialog('정말로 SMS를 발송하시겠습니까?');
            if (ok) _save(sendSMS: true);
          })),
        ],
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

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      color: const Color(0xFF666666),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, {bool readOnly = false, VoidCallback? onTap, TextInputType keyboardType = TextInputType.text}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      Expanded(child: AppInput(controller: ctrl, readOnly: readOnly, onTap: onTap, keyboardType: keyboardType)),
    ]));
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await CommonWidgets.showKoreanDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _anzDateController.dispose();
    _tankKg01Controller.dispose();
    _tankKg02Controller.dispose();
    _bigo1Controller.dispose();
    _bigo2Controller.dispose();
    _anzCuConfirmTelController.dispose();
    _anzCustNameController.dispose();
    _checkItem10Controller.dispose();
    _checkItem11Controller.dispose();
    _checkItem12Controller.dispose();
    for (final c in _bigoControllers.values) c.dispose();
    super.dispose();
  }
}
