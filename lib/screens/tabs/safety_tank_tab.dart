import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_tank_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';

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

  final Map<String, String> _tankItems = {};
  final Map<String, String> _tankBigos = {};
  final Map<String, TextEditingController> _bigoControllers = {};

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

    final items = [d.anzTank01, d.anzTank02, d.anzTank03, d.anzTank04, d.anzTank05,
      d.anzTank06, d.anzTank07, d.anzTank08, d.anzTank09, d.anzTank10, d.anzTank11, d.anzTank12];
    final bigos = [d.anzTank01Bigo, d.anzTank02Bigo, d.anzTank03Bigo, d.anzTank04Bigo, d.anzTank05Bigo,
      d.anzTank06Bigo, d.anzTank07Bigo, d.anzTank08Bigo, d.anzTank09Bigo, d.anzTank10Bigo, d.anzTank11Bigo, d.anzTank12Bigo];

    for (int i = 0; i < 12; i++) {
      final key = (i + 1).toString().padLeft(2, '0');
      _tankItems['ANZ_TANK_$key'] = items[i] ?? '';
      _bigoControllers['ANZ_TANK_${key}_Bigo']!.text = bigos[i] ?? '';
    }
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
    _anzCuConfirmTelController.text = widget.customer.cuHp ?? '';
  }

  Future<void> _save() async {
    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}

    final req = <String, dynamic>{
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': widget.customer.cuCode,
      'ANZ_Sno': _isNew ? '' : (_anzSno ?? ''),
      'ANZ_Date': DateUtil.fromDisplay(_anzDateController.text),
      'ANZ_SW_Code': AppState.safeSwCode,
      'ANZ_SW_Name': AppState.safeSwName,
      'ANZ_TANK_KG_01': _tankKg01Controller.text,
      'ANZ_TANK_KG_02': _tankKg02Controller.text,
      'ANZ_TANK_SW_Bigo1': _bigo1Controller.text,
      'ANZ_TANK_SW_Bigo2': _bigo2Controller.text,
      'ANZ_CustName': widget.customer.cuName ?? '',
      'ANZ_Sign_YN': '',
      'ANZ_CU_Confirm_TEL': _anzCuConfirmTelController.text,
      'GPS_X': pos?.longitude.toString() ?? '',
      'GPS_Y': pos?.latitude.toString() ?? '',
      'ANZ_User_ID': AppState.loginUserId,
      'ANZ_Sign': '',
    };

    for (int i = 1; i <= 12; i++) {
      final key = i.toString().padLeft(2, '0');
      req['ANZ_TANK_$key'] = _tankItems['ANZ_TANK_$key'] ?? '';
      req['ANZ_TANK_${key}_Bigo'] = _bigoControllers['ANZ_TANK_${key}_Bigo']!.text;
    }
    req['ANZ_Check_item_10'] = '';
    req['ANZ_Check_item_11'] = '';
    req['ANZ_Check_item_12'] = '';

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
    final resp = await NetHelper.request(context, () => NetHelper.api.safetyTankDelete(req));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: '삭제되었습니다.');
      _isNew = true; _anzSno = null; _data = null;
      _tankItems.clear();
      _setDefaults();
      setState(() {});
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  static const _tankLabels = [
    '1. 저장탱크 외면상태',
    '2. 저장탱크 기초 침하상태',
    '3. 사고예방 장치 설치 및 적합성',
    '4. 안전밸브 설치 및 적합성',
    '5. 액면계 설치 및 기능',
    '6. 압력계 설치 및 기능',
    '7. 가스누출 검지(경보) 장치',
    '8. 방류둑 설치 및 적합성',
    '9. 살수장치 작동',
    '10. 기타항목1',
    '11. 기타항목2',
    '12. 기타항목3',
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey.shade100,
          child: const Text('저장탱크', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _textField('탱크용량(kg)1', _tankKg01Controller, keyboardType: TextInputType.number),
                _textField('탱크용량(kg)2', _tankKg02Controller, keyboardType: TextInputType.number),
                _textField('확인 연락처', _anzCuConfirmTelController, keyboardType: TextInputType.phone),
                const Divider(),
                _sectionTitle('점검항목'),
                for (int i = 0; i < 12; i++) ...[
                  _checkRow(_tankLabels[i], 'ANZ_TANK_${(i + 1).toString().padLeft(2, '0')}'),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: SizedBox(
                      height: 30,
                      child: TextField(
                        controller: _bigoControllers['ANZ_TANK_${(i + 1).toString().padLeft(2, '0')}_Bigo'],
                        decoration: InputDecoration(
                          hintText: '비고', hintStyle: const TextStyle(fontSize: 11),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8), isDense: true,
                        ),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
                const Divider(),
                _textField('점검자 의견1', _bigo1Controller),
                _textField('점검자 의견2', _bigo2Controller),
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
      child: Row(
        children: [
          if (!_isNew)
            Expanded(child: ElevatedButton(onPressed: _delete,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('삭제'))),
          if (!_isNew) const SizedBox(width: 8),
          Expanded(flex: 2, child: ElevatedButton(onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF555555), foregroundColor: Colors.white),
              child: Text(_isNew ? '저장' : '수정'))),
        ],
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

  Widget _checkRow(String label, String key) {
    final value = _tankItems[key] ?? '';
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
      _checkBtn('적합', Keys.tankPassed, value, key),
      _checkBtn('부적합', Keys.tankFailed, value, key),
      _checkBtn('해당없음', Keys.tankNone, value, key),
    ]));
  }

  Widget _checkBtn(String label, String itemValue, String currentValue, String key) {
    final isSelected = currentValue == itemValue;
    return GestureDetector(
      onTap: () => setState(() => _tankItems[key] = itemValue),
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
    _tankKg01Controller.dispose();
    _tankKg02Controller.dispose();
    _bigo1Controller.dispose();
    _bigo2Controller.dispose();
    _anzCuConfirmTelController.dispose();
    for (final c in _bigoControllers.values) c.dispose();
    super.dispose();
  }
}
