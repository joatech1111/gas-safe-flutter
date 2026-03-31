import '../../widgets/logo_loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_saving_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';

class SafetySavingTab extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final String? anzSno;

  const SafetySavingTab({super.key, required this.customer, this.anzSno});

  @override
  State<SafetySavingTab> createState() => _SafetySavingTabState();
}

class _SafetySavingTabState extends State<SafetySavingTab> with AutomaticKeepAliveClientMixin {
  SafetySavingResultData? _data;
  bool _isLoading = true;
  bool _isNew = false;
  String? _anzSno;

  final _anzDateController = TextEditingController();
  final _lpKg01Controller = TextEditingController();
  final _lpKg02Controller = TextEditingController();
  final _anzCuConfirmTelController = TextEditingController();

  final Map<String, String> _items = {};
  final Map<String, TextEditingController> _textControllers = {};

  bool _loaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _anzSno = widget.anzSno;
    for (int i = 1; i <= 10; i++) {
      _textControllers['ANZ_Item${i}_Text'] = TextEditingController();
      _textControllers['ANZ_Item${i}_Text1'] = TextEditingController();
      _textControllers['ANZ_Item${i}_Text2'] = TextEditingController();
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
        resp = await NetHelper.api.safetySaving(areaCode, cuCode, _anzSno!);
      } else {
        resp = await NetHelper.api.safetySavingLast(areaCode, cuCode);
      }
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (resp['resultCode'] == 0 && resp['resultData'] != null) {
        final resultData = resp['resultData'];
        final dataList = resultData['data'];
        if (dataList is List && dataList.isNotEmpty) {
          final d = SafetySavingResultData.fromJson(dataList.first);
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

  void _populateFields(SafetySavingResultData d) {
    _anzDateController.text = DateUtil.toDisplay(d.anzDate ?? '');
    _lpKg01Controller.text = d.anzLpKg01 ?? '';
    _lpKg02Controller.text = d.anzLpKg02 ?? '';
    _anzCuConfirmTelController.text = d.anzCuConfirmTel ?? '';

    _items['ANZ_Item1'] = d.anzItem1 ?? '';
    _items['ANZ_Item1_SUB'] = d.anzItem1Sub ?? '';
    _items['ANZ_Item2'] = d.anzItem2 ?? '';
    _items['ANZ_Item2_SUB'] = d.anzItem2Sub ?? '';
    _items['ANZ_Item3'] = d.anzItem3 ?? '';
    _items['ANZ_Item3_SUB'] = d.anzItem3Sub ?? '';
    _items['ANZ_Item4'] = d.anzItem4 ?? '';
    _items['ANZ_Item4_SUB'] = d.anzItem4Sub ?? '';
    _items['ANZ_Item5'] = d.anzItem5 ?? '';
    _items['ANZ_Item5_SUB'] = d.anzItem5Sub ?? '';
    _items['ANZ_Item6'] = d.anzItem6 ?? '';
    _items['ANZ_Item6_SUB'] = d.anzItem6Sub ?? '';
    _items['ANZ_Item7'] = d.anzItem7 ?? '';
    _items['ANZ_Item7_SUB'] = d.anzItem7Sub ?? '';
    _items['ANZ_Item8'] = d.anzItem8 ?? '';
    _items['ANZ_Item8_SUB'] = d.anzItem8Sub ?? '';
    _items['ANZ_Item9'] = d.anzItem9 ?? '';
    _items['ANZ_Item9_SUB'] = d.anzItem9Sub ?? '';
    _items['ANZ_Item10'] = d.anzItem10 ?? '';

    _textControllers['ANZ_Item1_Text']!.text = d.anzItem1Text ?? '';
    _textControllers['ANZ_Item3_Text']!.text = d.anzItem3Text ?? '';
    _textControllers['ANZ_Item5_Text']!.text = d.anzItem5Text ?? '';
    _textControllers['ANZ_Item8_Text']!.text = d.anzItem8Text ?? '';
    _textControllers['ANZ_Item9_Text1']!.text = d.anzItem9Text1 ?? '';
    _textControllers['ANZ_Item9_Text2']!.text = d.anzItem9Text2 ?? '';
    _textControllers['ANZ_Item10_Text1']!.text = d.anzItem10Text1 ?? '';
    _textControllers['ANZ_Item10_Text2']!.text = d.anzItem10Text2 ?? '';
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
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
      'ANZ_LP_KG_01': _lpKg01Controller.text,
      'ANZ_LP_KG_02': _lpKg02Controller.text,
      'ANZ_CU_Confirm': '',
      'ANZ_CU_Confirm_TEL': _anzCuConfirmTelController.text,
      'ANZ_Sign_YN': '',
      'ANZ_CU_SMS_YN': sendSMS ? Keys.y : Keys.n,
      'GPS_X': pos?.longitude.toString() ?? '',
      'GPS_Y': pos?.latitude.toString() ?? '',
      'ANZ_User_ID': AppState.loginUserId,
      'ANZ_Sign': '',
    };

    for (int i = 1; i <= 10; i++) {
      req['ANZ_Item$i'] = _items['ANZ_Item$i'] ?? '';
      if (i <= 9) req['ANZ_Item${i}_SUB'] = _items['ANZ_Item${i}_SUB'] ?? '';
    }
    req['ANZ_Item1_Text'] = _textControllers['ANZ_Item1_Text']!.text;
    req['ANZ_Item3_Text'] = _textControllers['ANZ_Item3_Text']!.text;
    req['ANZ_Item5_Text'] = _textControllers['ANZ_Item5_Text']!.text;
    req['ANZ_Item8_Text'] = _textControllers['ANZ_Item8_Text']!.text;
    req['ANZ_Item9_Text1'] = _textControllers['ANZ_Item9_Text1']!.text;
    req['ANZ_Item9_Text2'] = _textControllers['ANZ_Item9_Text2']!.text;
    req['ANZ_Item10_Text1'] = _textControllers['ANZ_Item10_Text1']!.text;
    req['ANZ_Item10_Text2'] = _textControllers['ANZ_Item10_Text2']!.text;

    if (!mounted) return;
    final resp = await NetHelper.request(
      context,
      () => _isNew ? NetHelper.api.safetySavingInsert(req) : NetHelper.api.safetySavingUpdate(req),
    );
    if (!mounted) return;

    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: _isNew ? '저장되었습니다.' : '수정되었습니다.');
      final resultData = resp['resultData'];
      if (resultData != null && resultData['po_ANZ_Sno'] != null) {
        _anzSno = resultData['po_ANZ_Sno'].toString();
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
    final smsResp = await NetHelper.api.safetySms(areaCode, Keys.smsDivSaving);
    String smsMsg = '';
    if (NetHelper.isSuccess(smsResp) && smsResp['resultData'] != null) {
      smsMsg = smsResp['resultData']['SMS_Msg']?.toString() ?? '';
    }

    // Calculate pass/fail result
    bool hasFailed = false;
    for (int i = 1; i <= 10; i++) {
      final val = _items['ANZ_Item$i'] ?? '';
      if (val == Keys.savingFailed) { hasFailed = true; break; }
    }
    final resultText = hasFailed ? '부적합' : '적합';

    smsMsg = smsMsg
        .replaceAll('{거래처명}', widget.customer.cuNameView ?? widget.customer.cuName ?? '')
        .replaceAll('{영업소코드}', areaCode)
        .replaceAll('{거래처코드}', widget.customer.cuCode ?? '')
        .replaceAll('{주소}', '${widget.customer.cuAddr1 ?? ''} ${widget.customer.cuAddr2 ?? ''}')
        .replaceAll('{점검일}', _anzDateController.text)
        .replaceAll('{점검원}', AppState.safeSwName)
        .replaceAll('{점검결과}', resultText);

    final tel = _anzCuConfirmTelController.text.trim();
    if (tel.isEmpty) { Fluttertoast.showToast(msg: '확인 연락처를 입력해주세요.'); return; }
    final uri = Uri(scheme: 'sms', path: tel, queryParameters: {'body': smsMsg});
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
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
    final resp = await NetHelper.request(context, () => NetHelper.api.safetySavingDelete(req));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: '삭제되었습니다.');
      _isNew = true; _anzSno = null; _data = null;
      _items.clear();
      _setDefaults();
      setState(() {});
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  static const _savingLabels = [
    '1. 가스계량기 설치 및 기능',
    '2. 호스 상태',
    '3. 배관 상태',
    '4. 연소기 설치 상태',
    '5. 환기시설',
    '6. 가스누출경보기',
    '7. 가스누출차단장치',
    '8. 배기통',
    '9. 기타1',
    '10. 기타2',
  ];

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
          child: const Text('사용시설', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _textField('LP가스(kg)1', _lpKg01Controller, keyboardType: TextInputType.number),
                _textField('LP가스(kg)2', _lpKg02Controller, keyboardType: TextInputType.number),
                _textField('확인 연락처', _anzCuConfirmTelController, keyboardType: TextInputType.phone),
                const Divider(),
                _sectionTitle('점검항목'),
                for (int i = 0; i < 10; i++) ...[
                  _checkRow(_savingLabels[i], 'ANZ_Item${i + 1}'),
                  if (i < 9) _subCheckRow('ANZ_Item${i + 1}_SUB'),
                  if ([0, 2, 4, 7].contains(i))
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: SizedBox(height: 30, child: TextField(
                        controller: i == 0 ? _textControllers['ANZ_Item1_Text']
                            : i == 2 ? _textControllers['ANZ_Item3_Text']
                            : i == 4 ? _textControllers['ANZ_Item5_Text']
                            : _textControllers['ANZ_Item8_Text'],
                        decoration: InputDecoration(hintText: '비고', hintStyle: const TextStyle(fontSize: 11),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8), isDense: true),
                        style: const TextStyle(fontSize: 11),
                      )),
                    ),
                  if (i == 8) ...[
                    _savingTextField('비고1', _textControllers['ANZ_Item9_Text1']!),
                    _savingTextField('비고2', _textControllers['ANZ_Item9_Text2']!),
                  ],
                  if (i == 9) ...[
                    _savingTextField('비고1', _textControllers['ANZ_Item10_Text1']!),
                    _savingTextField('비고2', _textControllers['ANZ_Item10_Text2']!),
                  ],
                ],
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
          Row(children: [
            const Icon(Icons.person, size: 14, color: Colors.black54),
            const SizedBox(width: 4),
            Expanded(child: Text(widget.customer.cuName ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.phone, size: 13, color: Colors.black45),
            const SizedBox(width: 4),
            Text(widget.customer.cuTel ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
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
            if (!_isNew) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: _actionBtn('삭제', Colors.red, _delete),
              ),
            ],
          ],
        ),
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
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
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
      Expanded(child: SizedBox(height: 34, child: TextField(
        controller: ctrl, readOnly: readOnly, onTap: onTap, keyboardType: keyboardType,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8), isDense: true),
        style: const TextStyle(fontSize: 12),
      ))),
    ]));
  }

  Widget _savingTextField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: SizedBox(height: 30, child: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: label, hintStyle: const TextStyle(fontSize: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8), isDense: true),
        style: const TextStyle(fontSize: 11),
      )),
    );
  }

  Widget _checkRow(String label, String key) {
    final value = _items[key] ?? '';
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
      _checkBtn('적합', Keys.savingPassed, value, key),
      _checkBtn('부적합', Keys.savingFailed, value, key),
      _checkBtn('해당없음', Keys.savingNone, value, key),
    ]));
  }

  Widget _subCheckRow(String key) {
    final value = _items[key] ?? '';
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 2, bottom: 2),
      child: Row(children: [
        const Expanded(child: Text('세부항목', style: TextStyle(fontSize: 11, color: Colors.black54))),
        _checkBtn('적합', Keys.savingPassed, value, key),
        _checkBtn('부적합', Keys.savingFailed, value, key),
        _checkBtn('해당없음', Keys.savingNone, value, key),
      ]),
    );
  }

  Widget _checkBtn(String label, String itemValue, String currentValue, String key) {
    final isSelected = currentValue == itemValue;
    return GestureDetector(
      onTap: () => setState(() => _items[key] = itemValue),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF555555) : Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black54)),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (date != null) controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _anzDateController.dispose();
    _lpKg01Controller.dispose();
    _lpKg02Controller.dispose();
    _anzCuConfirmTelController.dispose();
    for (final c in _textControllers.values) c.dispose();
    super.dispose();
  }
}
