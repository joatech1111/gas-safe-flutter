import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../models/combo_data.dart';
import '../models/meters_customer_result_data.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/date_util.dart';
import '../widgets/common_widgets.dart';

class MeteringScreen extends StatefulWidget {
  const MeteringScreen({super.key});

  @override
  State<MeteringScreen> createState() => _MeteringScreenState();
}

class _MeteringScreenState extends State<MeteringScreen> {
  final _searchController = TextEditingController();
  List<MetersCustomerResultData> _resultList = [];
  bool _isSearchExpanded = true;

  // Filter state
  ComboData? _selectedApt;
  ComboData? _selectedSw;
  ComboData? _selectedMan;
  ComboData? _selectedJy;
  ComboData? _selectedSort;
  String _gumDate = DateUtil.today();
  int _cycleType = 0; // 0=전체, 1=회차별, 2=주기별
  ComboData? _selectedGumm;

  List<ComboData> _aptList = [];
  List<ComboData> _swList = [];
  List<ComboData> _manList = [];
  List<ComboData> _jyList = [];
  List<ComboData> _sortList = [];
  List<ComboData> _gummList = [];

  @override
  void initState() {
    super.initState();
    _loadSearchConditions();
  }

  Future<void> _loadSearchConditions() async {
    final resp = await NetHelper.request(
      context,
      () => NetHelper.api.metersCustomerSearchCondition(AppState.areaCode),
    );
    if (!mounted) return;
    if (NetHelper.isSuccess(resp) && resp['resultData'] != null) {
      final data = resp['resultData'];
      AppState.parseMetersCondition(data);
      setState(() {
        _aptList = AppState.comboApt;
        _swList = AppState.comboSw;
        _manList = AppState.comboMan;
        _jyList = AppState.comboJy;
        _sortList = AppState.comboSort;
        _gummList = AppState.comboGumm;
      });
    }
  }

  Future<void> _searchByKeyword() async {
    final req = {
      'AREA_CODE': AppState.areaCode,
      'FIND_STR': _searchController.text.trim(),
      'GUM_Date': _gumDate,
      'SUPP_YN': '',
      'GUM_TYPE': _cycleType.toString(),
      'GUM_YMSNO': _selectedGumm?.cd ?? '',
      'GUM_TURM': _selectedGumm?.cd ?? '',
      'GUM_MMDD': '',
      'CU_CODE': '',
      'APT_CD': _selectedApt?.cd ?? '',
      'SW_CD': _selectedSw?.cd ?? '',
      'MAN_CD': _selectedMan?.cd ?? '',
      'JY_CD': _selectedJy?.cd ?? '',
      'ADDR_TEXT': '',
      'SMART_METER_YN': '',
      'OrderBy': _selectedSort?.cd ?? '',
    };

    final resp = await NetHelper.request(context, () => NetHelper.api.metersCustomerSearchKeyword(req));
    if (!mounted) return;

    if (NetHelper.isSuccess(resp)) {
      final list = resp['resultData'];
      setState(() {
        _resultList = (list is List)
            ? list.map((e) => MetersCustomerResultData.fromJson(e)).toList()
            : [];
        _isSearchExpanded = false;
      });
      Fluttertoast.showToast(msg: '${_resultList.length}건 조회되었습니다.');
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  Future<void> _searchByLocation() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied || req == LocationPermission.deniedForever) {
          Fluttertoast.showToast(msg: 'GPS 권한이 필요합니다.');
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition();
      final req = {
        'AREA_CODE': AppState.areaCode,
        'FIND_STR': _searchController.text.trim(),
        'GUM_Date': _gumDate,
        'SUPP_YN': '',
        'GUM_TYPE': _cycleType.toString(),
        'GUM_YMSNO': _selectedGumm?.cd ?? '',
        'GUM_TURM': _selectedGumm?.cd ?? '',
        'GUM_MMDD': '',
        'CU_CODE': '',
        'APT_CD': _selectedApt?.cd ?? '',
        'SW_CD': _selectedSw?.cd ?? '',
        'MAN_CD': _selectedMan?.cd ?? '',
        'JY_CD': _selectedJy?.cd ?? '',
        'ADDR_TEXT': '',
        'SMART_METER_YN': '',
        'OrderBy': _selectedSort?.cd ?? '',
        'GPS_X': pos.longitude.toString(),
        'GPS_Y': pos.latitude.toString(),
      };

      if (!mounted) return;
      final resp = await NetHelper.request(context, () => NetHelper.api.metersCustomerSearchLocation(req));
      if (!mounted) return;

      if (NetHelper.isSuccess(resp)) {
        final list = resp['resultData'];
        setState(() {
          _resultList = (list is List)
              ? list.map((e) => MetersCustomerResultData.fromJson(e)).toList()
              : [];
          _isSearchExpanded = false;
        });
        Fluttertoast.showToast(msg: '${_resultList.length}건 조회되었습니다.');
      } else {
        NetHelper.handleError(context, resp);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'GPS 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonWidgets.buildAppBar(context, '모바일검침'),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchPanel(),
            Expanded(child: _buildResultList()),
            if (_resultList.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.grey.shade200,
                child: Text('총 ${_resultList.length}건', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF555555),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(3),
                  topRight: const Radius.circular(3),
                  bottomLeft: Radius.circular(_isSearchExpanded ? 0 : 3),
                  bottomRight: Radius.circular(_isSearchExpanded ? 0 : 3),
                ),
              ),
              child: Row(
                children: [
                  const Text('검색조건', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  const Spacer(),
                  Icon(_isSearchExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white),
                ],
              ),
            ),
          ),
          if (_isSearchExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  CommonWidgets.buildDateField(
                    context: context,
                    label: '검침일자',
                    value: _gumDate,
                    onChanged: (v) => setState(() => _gumDate = v),
                  ),
                  const SizedBox(height: 6),
                  // Cycle type radio
                  Row(
                    children: [
                      const SizedBox(width: 80, child: Text('검침주기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      _buildRadio('전체', 0),
                      _buildRadio('회차별', 1),
                      _buildRadio('주기별', 2),
                    ],
                  ),
                  if (_cycleType > 0 && _gummList.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    CommonWidgets.buildDropdown(
                      label: _cycleType == 1 ? '회차' : '주기',
                      items: _gummList,
                      selectedItem: _selectedGumm,
                      onChanged: (v) => setState(() => _selectedGumm = v),
                      addAll: false,
                    ),
                  ],
                  const SizedBox(height: 6),
                  if (_aptList.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '건물명', items: _aptList, selectedItem: _selectedApt, onChanged: (v) => setState(() => _selectedApt = v)),
                  if (_aptList.isNotEmpty) const SizedBox(height: 6),
                  if (_swList.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '담당사원', items: _swList, selectedItem: _selectedSw, onChanged: (v) => setState(() => _selectedSw = v)),
                  if (_swList.isNotEmpty) const SizedBox(height: 6),
                  if (_manList.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '관리분류', items: _manList, selectedItem: _selectedMan, onChanged: (v) => setState(() => _selectedMan = v)),
                  if (_manList.isNotEmpty) const SizedBox(height: 6),
                  if (_jyList.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '지역분류', items: _jyList, selectedItem: _selectedJy, onChanged: (v) => setState(() => _selectedJy = v)),
                  if (_jyList.isNotEmpty) const SizedBox(height: 6),
                  if (_sortList.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '조회순서', items: _sortList, selectedItem: _selectedSort, onChanged: (v) => setState(() => _selectedSort = v), addAll: false),
                  const SizedBox(height: 8),
                  CommonWidgets.buildSearchField(controller: _searchController, onSearch: _searchByKeyword, onGpsSearch: _searchByLocation),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadio(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(
          value: value,
          groupValue: _cycleType,
          onChanged: (v) => setState(() => _cycleType = v ?? 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildResultList() {
    if (_resultList.isEmpty) {
      return const Center(child: Text('조회된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: _resultList.length,
      itemBuilder: (context, index) => _buildMeteringItem(_resultList[index], index),
    );
  }

  Widget _buildMeteringItem(MetersCustomerResultData item, int index) {
    return InkWell(
      onTap: () => _showMeteringDialog(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Customer name (large) + phone + metering value
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.cuNameView ?? item.cuName ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(item.cuTel ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 8),
                Text('지침: ${item.gjGum ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 3),
            // Row 2: Address + tank reading
            Row(
              children: [
                Expanded(
                  child: Text('${item.cuAddr1 ?? ''} ${item.cuAddr2 ?? ''}',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      overflow: TextOverflow.ellipsis),
                ),
                Text('전검침: ${DateUtil.toDisplay(item.gjDate ?? '')}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ),
            if (item.appGjDate != null && item.appGjDate!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('검침완료: ${DateUtil.toDisplay(item.appGjDate!)}  지침: ${item.appGjGum ?? ''}',
                      style: const TextStyle(fontSize: 11, color: Colors.green)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMeteringDialog(MetersCustomerResultData item) {
    final gumController = TextEditingController(text: item.appGjGum ?? '');
    final gageController = TextEditingController(text: item.appGjGage ?? '');
    final bigoController = TextEditingController(text: item.appGjBigo ?? '');
    final t1PerController = TextEditingController(text: item.appGjT1Per ?? '');
    final t1KgController = TextEditingController(text: item.appGjT1Kg ?? '');
    final t2PerController = TextEditingController(text: item.appGjT2Per ?? '');
    final t2KgController = TextEditingController(text: item.appGjT2Kg ?? '');
    final jankgController = TextEditingController(text: item.appGjJankg ?? '');

    final isTank = item.cuTankYN == 'Y';
    final isExisting = item.appGjDate != null && item.appGjDate!.isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.cuNameView ?? item.cuName ?? '', style: const TextStyle(fontSize: 15)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('전검침 지침: ${item.gjGum ?? '-'}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              if (!isTank) ...[
                _dialogField('지침', gumController, TextInputType.number),
                const SizedBox(height: 8),
                _dialogField('게이지', gageController, TextInputType.number),
              ],
              if (isTank) ...[
                _dialogField('1탱크 %', t1PerController, TextInputType.number),
                const SizedBox(height: 6),
                _dialogField('1탱크 kg', t1KgController, TextInputType.number),
                const SizedBox(height: 6),
                _dialogField('2탱크 %', t2PerController, TextInputType.number),
                const SizedBox(height: 6),
                _dialogField('2탱크 kg', t2KgController, TextInputType.number),
                const SizedBox(height: 6),
                _dialogField('잔량 kg', jankgController, TextInputType.number),
              ],
              const SizedBox(height: 8),
              _dialogField('비고', bigoController, TextInputType.text),
            ],
          ),
        ),
        actions: [
          if (isExisting)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deleteMetering(item);
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveMetering(item, gumController.text, gageController.text, bigoController.text,
                  t1PerController.text, t1KgController.text, t2PerController.text, t2KgController.text, jankgController.text, isExisting);
            },
            child: Text(isExisting ? '수정' : '저장'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl, TextInputType type) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: SizedBox(
            height: 34,
            child: TextField(
              controller: ctrl,
              keyboardType: type,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveMetering(MetersCustomerResultData item, String gum, String gage, String bigo,
      String t1Per, String t1Kg, String t2Per, String t2Kg, String jankg, bool isUpdate) async {
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition();
    } catch (_) {}

    final req = {
      'AREA_CODE': item.areaCode ?? AppState.areaCode,
      'CU_CODE': item.cuCode,
      'GJ_DATE': _gumDate,
      'GJ_GUM_YM': _gumDate.length >= 6 ? _gumDate.substring(0, 6) : _gumDate,
      'CU_NAME': item.cuName,
      'CU_USERNAME': item.cuUserName,
      'GJ_JUNGUM': item.gjGum,
      'GJ_GUM': gum,
      'GJ_GAGE': gage,
      'GJ_T1_Per': t1Per,
      'GJ_T1_kg': t1Kg,
      'GJ_T2_Per': t2Per,
      'GJ_T2_kg': t2Kg,
      'GJ_JANKG': jankg,
      'GJ_BIGO': bigo,
      'SAFE_SW_CODE': AppState.safeSwCode,
      'SAFE_SW_NAME': AppState.safeSwName,
      'GPS_X': pos?.longitude.toString() ?? '',
      'GPS_Y': pos?.latitude.toString() ?? '',
      'APP_User': AppState.loginUserId,
    };

    final resp = await NetHelper.request(
      context,
      () => isUpdate ? NetHelper.api.metersCheckInfoUpdate(req) : NetHelper.api.metersCheckInfoInsert(req),
    );
    if (!mounted) return;

    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: isUpdate ? '수정되었습니다.' : '저장되었습니다.');
      _searchByKeyword();
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  Future<void> _deleteMetering(MetersCustomerResultData item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final req = {
      'AREA_CODE': item.areaCode ?? AppState.areaCode,
      'CU_CODE': item.cuCode,
      'GJ_DATE': item.appGjDate,
      'APP_User': AppState.loginUserId,
    };

    final resp = await NetHelper.request(context, () => NetHelper.api.metersCheckInfoDelete(req));
    if (!mounted) return;

    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: '삭제되었습니다.');
      _searchByKeyword();
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
