import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../models/combo_data.dart';
import '../models/meters_customer_result_data.dart';
import '../models/safety_customer_result_data.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/date_util.dart';
import '../utils/keys.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_edit_dialog.dart';

class MeteringScreen extends StatefulWidget {
  const MeteringScreen({super.key});

  @override
  State<MeteringScreen> createState() => _MeteringScreenState();
}

class _MeteringScreenState extends State<MeteringScreen> {
  final _searchController = TextEditingController();
  final _includeAddressController = TextEditingController();
  final _roundController = TextEditingController();
  final _monthDayController = TextEditingController();
  List<MetersCustomerResultData> _resultList = [];
  bool _isSearchExpanded = true;
  bool _showUnmeteringOnly = false;
  bool _excludeRemoteMetering = false;

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
        _selectedSw = _findComboByCode(_swList, AppState.swCode);
        _selectedMan = _findComboByCode(_manList, AppState.gubunCode);
        _selectedJy = _findComboByCode(_jyList, AppState.jyCode);
        _selectedSort = _findComboByCode(_sortList, AppState.orderBy);
      });
    }
  }

  ComboData? _findComboByCode(List<ComboData> items, String code) {
    if (code.trim().isEmpty) return null;
    for (final item in items) {
      if ((item.cd ?? '').trim() == code.trim()) return item;
    }
    return null;
  }

  Map<String, dynamic> _buildReq({bool forLocation = false, String? gpsX, String? gpsY}) {
    final isRound = _cycleType == 1;
    final isMonth = _cycleType == 2;
    final defaultEmpty = forLocation ? '0' : '';
    return {
      'AREA_CODE': AppState.areaCode,
      'FIND_STR': _searchController.text.trim(),
      'GUM_Date': _gumDate,
      'SUPP_YN': _showUnmeteringOnly ? Keys.y : defaultEmpty,
      'GUM_TYPE': _cycleType.toString(),
      'GUM_YMSNO': isRound
          ? (_roundController.text.trim().isEmpty ? '0' : _roundController.text.trim())
          : defaultEmpty,
      'GUM_TURM': isMonth ? (_selectedGumm?.cd ?? defaultEmpty) : defaultEmpty,
      'GUM_MMDD': isMonth
          ? (forLocation
                ? (_monthDayController.text.trim().isEmpty ? '0' : _monthDayController.text.trim())
                : _monthDayController.text.trim())
          : defaultEmpty,
      'CU_CODE': forLocation ? '0' : '',
      'APT_CD': _selectedApt?.cd ?? defaultEmpty,
      'SW_CD': _selectedSw?.cd ?? defaultEmpty,
      'MAN_CD': _selectedMan?.cd ?? defaultEmpty,
      'JY_CD': _selectedJy?.cd ?? defaultEmpty,
      'ADDR_TEXT': _includeAddressController.text.trim().isEmpty
          ? defaultEmpty
          : _includeAddressController.text.trim(),
      'SMART_METER_YN': _excludeRemoteMetering ? Keys.y : defaultEmpty,
      'OrderBy': (_selectedSort?.bigo ?? _selectedSort?.cd ?? '').trim(),
      if (gpsX != null) 'GPS_X': gpsX,
      if (gpsY != null) 'GPS_Y': gpsY,
    };
  }

  Future<void> _searchByKeyword() async {
    final req = _buildReq(forLocation: false);

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
      final req = _buildReq(
        forLocation: true,
        gpsX: pos.longitude.toString(),
        gpsY: pos.latitude.toString(),
      );

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
      appBar: CommonWidgets.buildAppBar(context, '모바일 검침'),
      bottomNavigationBar: CommonWidgets.buildBottomStatusBar(
        workerName: AppState.safeSwName,
        rightText: '조회: ${_resultList.length}건',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchPanel(),
            Expanded(child: _buildResultList()),
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
                  Row(
                    children: [
                      Expanded(
                        child: CommonWidgets.buildDateField(
                          context: context,
                          label: '검침일자',
                          value: _gumDate,
                          onChanged: (v) => setState(() => _gumDate = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('미검침 세대만 보기', style: TextStyle(fontSize: 12)),
                          value: _showUnmeteringOnly,
                          onChanged: (v) => setState(() => _showUnmeteringOnly = v ?? false),
                        ),
                      ),
                    ],
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
                  if (_cycleType == 1) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('회차', style: TextStyle(fontSize: 13))),
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: _roundController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              hintText: '회차',
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_cycleType == 2) ...[
                    const SizedBox(height: 6),
                    if (_gummList.isNotEmpty)
                      CommonWidgets.buildDropdown(
                        label: '검침주기',
                        items: _gummList,
                        selectedItem: _selectedGumm,
                        onChanged: (v) => setState(() => _selectedGumm = v),
                        addAll: false,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('일', style: TextStyle(fontSize: 13))),
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: _monthDayController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              hintText: '일',
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 80, child: Text('포함주소', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      Expanded(
                        child: TextField(
                          controller: _includeAddressController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            hintText: '포함주소',
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 80),
                      Expanded(
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('원격검침 거래처 제외', style: TextStyle(fontSize: 12)),
                          value: _excludeRemoteMetering,
                          onChanged: (v) => setState(() => _excludeRemoteMetering = v ?? false),
                        ),
                      ),
                    ],
                  ),
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
      onLongPress: () => _showMeteringContextMenu(item),
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

  void _showMeteringContextMenu(MetersCustomerResultData item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.cuNameView ?? item.cuName ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(item.cuTel ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  Text(item.cuAddr ?? '${item.cuAddr1 ?? ''} ${item.cuAddr2 ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('검침 등록/수정'),
              onTap: () {
                Navigator.pop(ctx);
                _showMeteringDialog(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('거래처 정보'),
              onTap: () async {
                Navigator.pop(ctx);
                await _showCustomerInfoDialog(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('계량기 정보'),
              onTap: () async {
                Navigator.pop(ctx);
                await _showMeterInfoDialog(item);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomerInfoDialog(MetersCustomerResultData item) async {
    final safetyData = SafetyCustomerResultData()
      ..areaCode = item.areaCode
      ..cuCode = item.cuCode
      ..cuType = item.cuType
      ..cuName = item.cuName
      ..cuNameView = item.cuNameView
      ..cuUserName = item.cuUserName
      ..cuTel = item.cuTel
      ..cuHp = item.cuHp
      ..cuZipcode = item.cuZipcode
      ..cuAddr1 = item.cuAddr1
      ..cuAddr2 = item.cuAddr2
      ..cuBigo1 = item.cuBigo1
      ..cuBigo2 = item.cuBigo2
      ..cuSwCode = item.cuSwCode
      ..cuSwName = item.cuSwName
      ..cuCuType = item.cuCuType;

    final edited = await CustomerEditDialog.show(context, safetyData);
    if (!mounted || edited == null) return;
    await _searchByKeyword();
  }

  Future<void> _showMeterInfoDialog(MetersCustomerResultData item) async {
    final gumDayController = TextEditingController(text: item.cuGumDate ?? '');
    final barcodeController = TextEditingController(text: item.cuBarcode ?? '');
    final meterNoController = TextEditingController(text: item.cuMeterNo ?? '');
    final meterCoController = TextEditingController(text: item.cuMeterCo ?? '');
    final meterM3Controller = TextEditingController(text: item.cuMeterM3 ?? '');
    final meterDtController = TextEditingController(
      text: DateUtil.convertFormat(item.cuMeterDT ?? '', DateUtil.formatYyyymmdd, DateUtil.formatYyyyMmDd),
    );

    int gumTermIndex = ((int.tryParse(item.cuGumTurm ?? '') ?? 0).clamp(0, AppState.comboGumm.isEmpty ? 0 : AppState.comboGumm.length - 1)).toInt();
    int meterLrIndex = ((int.tryParse(item.cuMeterLR ?? '') ?? 0).clamp(0, AppState.comboMLR.isEmpty ? 0 : AppState.comboMLR.length - 1)).toInt();
    ComboData? selectedMeterType;
    if (AppState.comboMTY.isNotEmpty) {
      for (final v in AppState.comboMTY) {
        if (v.cd == (item.cuMeterType ?? '')) {
          selectedMeterType = v;
          break;
        }
      }
    }

    if (selectedMeterType == null && AppState.comboMTY.isNotEmpty) {
      selectedMeterType = AppState.comboMTY.first;
      meterM3Controller.text = selectedMeterType.bigo ?? meterM3Controller.text;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('계량기 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: Column(
                children: [
                  if (AppState.comboGumm.isNotEmpty)
                    DropdownButtonFormField<int>(
                      value: gumTermIndex,
                      isExpanded: true,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      items: List.generate(AppState.comboGumm.length, (i) => DropdownMenuItem<int>(value: i, child: Text(AppState.comboGumm[i].getCdName()))),
                      onChanged: (v) => setDialogState(() => gumTermIndex = v ?? gumTermIndex),
                    ),
                  const SizedBox(height: 6),
                  _dialogInputRow('검침일', gumDayController, TextInputType.number),
                  _dialogInputRow('바코드', barcodeController, TextInputType.text),
                  _dialogInputRow('제조사', meterCoController, TextInputType.text),
                  if (AppState.comboMeter.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: null,
                      isExpanded: true,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), hintText: '제조사 선택'),
                      items: AppState.comboMeter.map((e) => DropdownMenuItem<String>(value: e.getCdName(), child: Text(e.getCdName()))).toList(),
                      onChanged: (v) => setDialogState(() => meterCoController.text = v ?? meterCoController.text),
                    ),
                  const SizedBox(height: 6),
                  _dialogInputRow('계량기번호', meterNoController, TextInputType.text),
                  if (AppState.comboMLR.isNotEmpty)
                    DropdownButtonFormField<int>(
                      value: meterLrIndex,
                      isExpanded: true,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), hintText: '좌/우'),
                      items: List.generate(AppState.comboMLR.length, (i) => DropdownMenuItem<int>(value: i, child: Text(AppState.comboMLR[i].getCdName()))),
                      onChanged: (v) => setDialogState(() => meterLrIndex = v ?? meterLrIndex),
                    ),
                  const SizedBox(height: 6),
                  if (AppState.comboMTY.isNotEmpty)
                    DropdownButtonFormField<ComboData>(
                      value: selectedMeterType,
                      isExpanded: true,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), hintText: '계량기 형식'),
                      items: AppState.comboMTY.map((e) => DropdownMenuItem<ComboData>(value: e, child: Text(e.getCdName()))).toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          selectedMeterType = v;
                          meterM3Controller.text = v?.bigo ?? '';
                        });
                      },
                    ),
                  const SizedBox(height: 6),
                  _dialogInputRow('계량기 용량', meterM3Controller, TextInputType.text),
                  _dialogInputRow('교체일', meterDtController, TextInputType.datetime),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final picked = await CommonWidgets.showKoreanDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          meterDtController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        }
                      },
                      child: const Text('날짜선택'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('저장')),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final req = {
      'AREA_CODE': item.areaCode ?? AppState.areaCode,
      'CU_CODE': item.cuCode,
      'CU_Gum_Turm': gumTermIndex.toString(),
      'CU_GumDate': gumDayController.text.trim(),
      'CU_Barcode': barcodeController.text.trim(),
      'CU_Meter_No': meterNoController.text.trim(),
      'CU_Meter_Co': meterCoController.text.trim(),
      'CU_Meter_LR': meterLrIndex.toString(),
      'CU_Meter_TYPE': selectedMeterType?.cd ?? '',
      'CU_Meter_M3': meterM3Controller.text.trim(),
      'CU_Meter_DT': DateUtil.fromDisplay(meterDtController.text),
      'APP_User': AppState.loginUserId,
    };

    final resp = await NetHelper.request(context, () => NetHelper.api.metersInfoUpdate(req));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: '저장되었습니다.');
      _searchByKeyword();
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  void _showMeteringDialog(MetersCustomerResultData item) {
    final isTank = item.cuTankYN == 'Y';
    final isExisting = item.appGjDate != null && item.appGjDate!.isNotEmpty;
    final prevGum = (isExisting ? item.appGjJungum : item.gjGum) ?? '';
    final currentGumController = TextEditingController(text: (isExisting ? item.appGjGum : item.gjGum) ?? '');
    final usageController = TextEditingController(
      text: (isExisting ? item.appGjGage : null) ?? _calcUsage((isExisting ? item.appGjGum : item.gjGum) ?? '', prevGum),
    );
    final bigoController = TextEditingController(text: item.appGjBigo ?? '');
    final t1PerController = TextEditingController(text: item.appGjT1Per ?? '');
    final t1KgController = TextEditingController(text: item.appGjT1Kg ?? '');
    final t2PerController = TextEditingController(text: item.appGjT2Per ?? '');
    final t2KgController = TextEditingController(text: item.appGjT2Kg ?? '');
    final lpRemainingController = TextEditingController(text: isTank ? '' : (item.appGjJankg ?? ''));
    final gumOptions = AppState.comboGum;
    int? selectedGumOptionIndex;
    if (gumOptions.isNotEmpty && bigoController.text.trim().isNotEmpty) {
      for (var i = 0; i < gumOptions.length; i++) {
        final name = gumOptions[i].getCdName().trim().isNotEmpty
            ? gumOptions[i].getCdName().trim()
            : (gumOptions[i].cd ?? '').trim();
        if (name == bigoController.text.trim()) {
          selectedGumOptionIndex = i;
          break;
        }
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          void recalcUsage() {
            usageController.text = _calcUsage(currentGumController.text, prevGum);
          }

          void recalcT1Kg() {
            final ratio = _tankRatio(item.tankVol01, item.tankMax01);
            final raw = _toDouble(t1PerController.text);
            final per = (raw < 0.0 || raw > 85.0) ? 0.0 : raw;
            if (raw < 0.0 || raw > 85.0) {
              t1PerController.text = '0';
              t1PerController.selection = TextSelection.fromPosition(TextPosition(offset: t1PerController.text.length));
            }
            t1KgController.text = (ratio * per).floor().toString();
          }

          void recalcT2Kg() {
            final ratio = _tankRatio(item.tankVol02, item.tankMax02);
            final raw = _toDouble(t2PerController.text);
            final per = (raw < 0.0 || raw > 85.0) ? 0.0 : raw;
            if (raw < 0.0 || raw > 85.0) {
              t2PerController.text = '0';
              t2PerController.selection = TextSelection.fromPosition(TextPosition(offset: t2PerController.text.length));
            }
            t2KgController.text = (ratio * per).floor().toString();
          }

          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    '검침 등록/수정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 330,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        '${item.areaCode ?? ''}-${item.cuCode ?? ''}',
                        style: const TextStyle(fontSize: 20, color: Color(0xFF555555)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        item.cuNameView ?? item.cuName ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: Color(0xFF1D3C7E)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    _dialogInfoRow('검침일자', DateUtil.toDisplay(item.appGjDate ?? '')),
                    const Divider(height: 1),
                    _dialogDualRow('전월검침', DateUtil.toDisplay(item.gjDate ?? ''), prevGum, unit: 'm³'),
                    _dialogInputRow(
                      '당월검침',
                      currentGumController,
                      TextInputType.number,
                      unit: 'm³',
                      onChanged: (_) => setDialogState(recalcUsage),
                    ),
                    _dialogInputRow(
                      '사용량',
                      usageController,
                      TextInputType.number,
                      unit: 'm³',
                      readOnly: true,
                    ),
                    const Divider(height: 1),
                    if (!isTank)
                      _dialogInputRow('잔량', lpRemainingController, TextInputType.number, unit: 'kg')
                    else ...[
                      if (_toDouble(item.tankVol01) > 0.0) ...[
                        _dialogInputRow(
                          '잔량',
                          t1PerController,
                          TextInputType.number,
                          unit: '%',
                          onChanged: (_) => setDialogState(recalcT1Kg),
                        ),
                        _dialogInputRow('잔량', t1KgController, TextInputType.number, unit: 'kg'),
                      ],
                      if (_toDouble(item.tankVol02) > 0.0) ...[
                        _dialogInputRow(
                          '잔량',
                          t2PerController,
                          TextInputType.number,
                          unit: '%',
                          onChanged: (_) => setDialogState(recalcT2Kg),
                        ),
                        _dialogInputRow('잔량', t2KgController, TextInputType.number, unit: 'kg'),
                      ],
                    ],
                    const SizedBox(height: 8),
                    if (gumOptions.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: selectedGumOptionIndex,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          hintText: '비고',
                        ),
                        items: List.generate(
                          gumOptions.length,
                          (i) => DropdownMenuItem<int>(
                            value: i,
                            child: Text(
                              gumOptions[i].getCdName().trim().isNotEmpty
                                  ? gumOptions[i].getCdName().trim()
                                  : (gumOptions[i].cd ?? '').trim(),
                            ),
                          ),
                        ),
                        onChanged: (v) {
                          if (v == null) return;
                          final selectedText = gumOptions[v].getCdName().trim().isNotEmpty
                              ? gumOptions[v].getCdName().trim()
                              : (gumOptions[v].cd ?? '').trim();
                          setDialogState(() {
                            selectedGumOptionIndex = v;
                            bigoController.text = selectedText;
                            bigoController.selection = TextSelection.fromPosition(
                              TextPosition(offset: bigoController.text.length),
                            );
                          });
                        },
                      ),
                    if (gumOptions.isNotEmpty) const SizedBox(height: 6),
                    _dialogInputRow('비고', bigoController, TextInputType.text),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final current = _toInt(currentGumController.text);
                  final prev = _toInt(prevGum);
                  if (current < prev) {
                    Fluttertoast.showToast(msg: '당월검침 값은 전월검침 값보다 작을 수 없습니다.');
                    return;
                  }

                  final effectiveDate = isExisting
                      ? (item.appGjDate ?? DateUtil.today())
                      : DateUtil.today();

                  Navigator.pop(ctx);
                  _saveMetering(
                    item: item,
                    currentGum: currentGumController.text,
                    usage: usageController.text,
                    bigo: bigoController.text,
                    t1Per: t1PerController.text,
                    t1Kg: t1KgController.text,
                    t2Per: t2PerController.text,
                    t2Kg: t2KgController.text,
                    lpRemainingKg: lpRemainingController.text,
                    isTank: isTank,
                    isUpdate: isExisting,
                    prevGum: prevGum,
                    effectiveDate: effectiveDate,
                  );
                },
                child: Text(isExisting ? '수정' : '저장'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 68, child: Text(label, style: const TextStyle(fontSize: 15))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(value, style: const TextStyle(fontSize: 17)),
          ),
        ),
      ],
    );
  }

  Widget _dialogDualRow(String label, String date, String value, {String unit = ''}) {
    return Row(
      children: [
        SizedBox(width: 68, child: Text(label, style: const TextStyle(fontSize: 15))),
        SizedBox(width: 90, child: Text(date, style: const TextStyle(fontSize: 16))),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 17))),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(unit, style: const TextStyle(fontSize: 15, color: Colors.black54)),
        ],
      ],
    );
  }

  Widget _dialogInputRow(
    String label,
    TextEditingController ctrl,
    TextInputType type, {
    String unit = '',
    bool readOnly = false,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 68, child: Text(label, style: const TextStyle(fontSize: 15))),
          Expanded(
            child: SizedBox(
              height: 32,
              child: TextField(
                controller: ctrl,
                keyboardType: type,
                readOnly: readOnly,
                onChanged: onChanged,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 4),
            SizedBox(width: 24, child: Text(unit, style: const TextStyle(fontSize: 15, color: Colors.black54))),
          ],
        ],
      ),
    );
  }

  int _toInt(String? value) => int.tryParse((value ?? '').trim()) ?? 0;
  double _toDouble(String? value) => double.tryParse((value ?? '').trim()) ?? 0.0;
  String _calcUsage(String current, String prev) {
    final diff = _toInt(current) - _toInt(prev);
    return diff < 0 ? '' : diff.toString();
  }
  double _tankRatio(String? vol, String? max) {
    final maxValue = _toDouble(max);
    if (maxValue <= 0) return 0;
    return _toDouble(vol) / maxValue;
  }

  Future<void> _saveMetering({
    required MetersCustomerResultData item,
    required String currentGum,
    required String usage,
    required String bigo,
    required String t1Per,
    required String t1Kg,
    required String t2Per,
    required String t2Kg,
    required String lpRemainingKg,
    required bool isTank,
    required bool isUpdate,
    required String prevGum,
    required String effectiveDate,
  }) async {
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition();
    } catch (_) {}

    final jankg = isTank ? (_toInt(t1Kg) + _toInt(t2Kg)).toString() : lpRemainingKg;
    final req = {
      'AREA_CODE': item.areaCode ?? AppState.areaCode,
      'CU_CODE': item.cuCode,
      'GJ_DATE': effectiveDate,
      'GJ_GUM_YM': effectiveDate.length >= 6 ? effectiveDate.substring(0, 6) : effectiveDate,
      'CU_NAME': item.cuName,
      'CU_USERNAME': item.cuUserName,
      'GJ_JUNGUM': prevGum,
      'GJ_GUM': currentGum,
      'GJ_GAGE': usage,
      'GJ_T1_Per': isTank ? t1Per : '',
      'GJ_T1_kg': isTank ? t1Kg : lpRemainingKg,
      'GJ_T2_Per': isTank ? t2Per : '',
      'GJ_T2_kg': isTank ? t2Kg : '',
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
    _includeAddressController.dispose();
    _roundController.dispose();
    _monthDayController.dispose();
    super.dispose();
  }
}
