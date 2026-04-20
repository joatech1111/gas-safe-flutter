import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../models/combo_data.dart';
import '../models/meters_check_status_result_data.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/date_util.dart';
import '../widgets/common_widgets.dart';

class MeteringStatusScreen extends StatefulWidget {
  const MeteringStatusScreen({super.key});

  @override
  State<MeteringStatusScreen> createState() => _MeteringStatusScreenState();
}

class _MeteringStatusScreenState extends State<MeteringStatusScreen> {
  final _searchController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _includeAddressController = TextEditingController();
  List<MetersCheckStatusResultData> _resultList = [];
  bool _isSearchExpanded = true;
  bool _excludeRemoteMetering = false;

  ComboData? _selectedApt;
  ComboData? _selectedSw;
  ComboData? _selectedMan;
  ComboData? _selectedJy;
  ComboData? _selectedSort;
  String _dateFrom = DateUtil.beforeDays(7);
  String _dateTo = DateUtil.today();

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
      AppState.parseMetersCondition(resp['resultData']);
      setState(() {
        _selectedSw = _findComboByCode(AppState.comboSw, AppState.swCode);
        _selectedMan = _findComboByCode(AppState.comboMan, AppState.gubunCode);
        _selectedJy = _findComboByCode(AppState.comboJy, AppState.jyCode);
        _selectedSort = _findComboByCode(AppState.comboSort, AppState.orderBy);
      });
    }
  }

  ComboData? _findComboByCode(List<ComboData> items, String code) {
    if (code.trim().isEmpty) return null;
    for (final item in items) {
      if ((item.cd ?? '').trim() == code.trim() || (item.bigo ?? '').trim() == code.trim()) {
        return item;
      }
    }
    return null;
  }

  String _buildAppUser() {
    final hpSno = (AppState.loginUser?.hpSno ?? '').trim();
    final loginName = (AppState.loginUser?.loginName ?? '').trim();
    final combined = '$hpSno$loginName';
    return combined.isNotEmpty ? combined : AppState.loginUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonWidgets.buildAppBar(context, '검침 현황'),
      bottomNavigationBar: CommonWidgets.buildBottomStatusBar(
        workerName: AppState.safeSwName,
        rightText: '조회: ${_resultList.length}건',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 8, 13, 0),
              child: CommonWidgets.buildSearchField(controller: _searchController, onSearch: _searchByKeyword, onGpsSearch: _searchByLocation),
            ),
            _buildSearchPanel(),
            Expanded(child: _buildResultList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 3, 20, 0),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
            child: Row(
              children: [
                Text('검색조건', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.7, color: AppColors.textDefault)),
                const Spacer(),
                Icon(_isSearchExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textDefault),
              ],
            ),
          ),
          if (_isSearchExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFA0A0A0)),
                borderRadius: BorderRadius.circular(1.3),
              ),
              padding: const EdgeInsets.fromLTRB(7, 8.3, 7, 0),
              child: Column(
                children: [
                  // Date range with ~ separator
                  Row(
                    children: [
                      SizedBox(width: 50, child: Text('기간', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await CommonWidgets.showKoreanDatePicker(
                              context: context,
                              initialDate: _parseYyyyMmDd(_dateFrom) ?? DateTime.now(),
                              firstDate: DateTime(2000), lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => _dateFrom = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
                            }
                          },
                          child: Container(
                            height: 24,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white, Color(0xFFE5E4DD)],
                              ),
                              border: Border.all(color: const Color(0xFFB2B2B2)),
                              borderRadius: BorderRadius.circular(1.3),
                            ),
                            alignment: Alignment.center,
                            child: Text(DateUtil.toDisplay(_dateFrom), style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('~', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDefault)),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await CommonWidgets.showKoreanDatePicker(
                              context: context,
                              initialDate: _parseYyyyMmDd(_dateTo) ?? DateTime.now(),
                              firstDate: DateTime(2000), lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              final v = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
                              if (v.compareTo(_dateFrom) < 0) {
                                Fluttertoast.showToast(msg: '종료일자가 시작일자보다 빠를 수 없습니다.');
                                return;
                              }
                              setState(() => _dateTo = v);
                            }
                          },
                          child: Container(
                            height: 24,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white, Color(0xFFE5E4DD)],
                              ),
                              border: Border.all(color: const Color(0xFFB2B2B2)),
                              borderRadius: BorderRadius.circular(1.3),
                            ),
                            alignment: Alignment.center,
                            child: Text(DateUtil.toDisplay(_dateTo), style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (AppState.comboApt.isNotEmpty)
                    Row(
                      children: [
                        SizedBox(width: 80, child: Text('건물명', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 24,
                            child: TextField(
                              controller: _buildingNameController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: '건물명',
                                hintStyle: TextStyle(fontSize: 12.7, color: AppColors.editHint),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.3), borderSide: BorderSide(color: AppColors.editStroke)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(1.3), borderSide: BorderSide(color: AppColors.editStroke)),
                                isDense: true,
                              ),
                              style: TextStyle(fontSize: 12.7, color: AppColors.textDefault),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: _buildInlineDropdown(
                            items: _filteredAptList,
                            selectedItem: _selectedApt,
                            onChanged: (v) => setState(() => _selectedApt = v),
                          ),
                        ),
                      ],
                    ),
                  if (AppState.comboApt.isNotEmpty) const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledDropdownField(
                          label: '담당사원',
                          items: AppState.comboSw,
                          selectedItem: _selectedSw,
                          onChanged: (v) => setState(() => _selectedSw = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildLabeledDropdownField(
                          label: '관리분류',
                          items: AppState.comboMan,
                          selectedItem: _selectedMan,
                          onChanged: (v) => setState(() => _selectedMan = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledDropdownField(
                          label: '지역분류',
                          items: AppState.comboJy,
                          selectedItem: _selectedJy,
                          onChanged: (v) => setState(() => _selectedJy = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(width: 60, child: Text('포함주소', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 24,
                          child: TextField(
                            controller: _includeAddressController,
                            decoration: InputDecoration(
                              hintText: '포함주소',
                              hintStyle: TextStyle(fontSize: 12.7, color: AppColors.editHint),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.3), borderSide: BorderSide(color: AppColors.editStroke)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(1.3), borderSide: BorderSide(color: AppColors.editStroke)),
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 12.7, color: AppColors.textDefault),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledDropdownField(
                          label: '조회순서',
                          items: AppState.comboSort,
                          selectedItem: _selectedSort,
                          onChanged: (v) => setState(() => _selectedSort = v),
                          addAll: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _excludeRemoteMetering,
                                onChanged: (v) => setState(() => _excludeRemoteMetering = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('원격검침 거래처 제외', style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _buildReq() => {
    'AREA_CODE': AppState.areaCode,
    'FIND_STR': _searchController.text.trim().isNotEmpty
        ? _searchController.text.trim()
        : _buildingNameController.text.trim(),
    'GUM_DATE_F': _dateFrom,
    'GUM_DATE_T': _dateTo,
    'CU_CODE': '',
    'APT_CD': _selectedApt?.cd ?? '',
    'SW_CD': _selectedSw?.cd ?? '',
    'MAN_CD': _selectedMan?.cd ?? '',
    'JY_CD': _selectedJy?.cd ?? '',
    'ADDR_TEXT': _includeAddressController.text.trim(),
    'SMART_METER_YN': _excludeRemoteMetering ? 'Y' : '',
    'OrderBy': _selectedSort?.bigo ?? _selectedSort?.cd ?? '',
    'SAFE_CD': AppState.safeSwCode,
    'APP_User': _buildAppUser(),
  };

  List<ComboData> get _filteredAptList {
    final keyword = _buildingNameController.text.trim().toLowerCase();
    if (keyword.isEmpty) return AppState.comboApt;
    final filtered = AppState.comboApt.where((e) => e.getCdName().toLowerCase().contains(keyword)).toList();
    return filtered.isEmpty ? AppState.comboApt : filtered;
  }

  DateTime? _parseYyyyMmDd(String value) {
    if (value.length != 8) return null;
    try {
      return DateTime(
        int.parse(value.substring(0, 4)),
        int.parse(value.substring(4, 6)),
        int.parse(value.substring(6, 8)),
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildLabeledDropdownField({
    required String label,
    required List<ComboData> items,
    required ComboData? selectedItem,
    required ValueChanged<ComboData?> onChanged,
    bool addAll = true,
  }) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
        const SizedBox(width: 6),
        Expanded(
          child: _buildInlineDropdown(
            items: items,
            selectedItem: selectedItem,
            onChanged: onChanged,
            addAll: addAll,
          ),
        ),
      ],
    );
  }

  Widget _buildInlineDropdown({
    required List<ComboData> items,
    required ComboData? selectedItem,
    required ValueChanged<ComboData?> onChanged,
    bool addAll = true,
  }) {
    final allItems = <ComboData>[
      if (addAll) ComboData(cdName: '전체'),
      ...items,
    ];
    final selected = _findMatchingItem(allItems, selectedItem);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFE5E4DD)],
        ),
        border: Border.all(color: const Color(0xFFB2B2B2)),
        borderRadius: BorderRadius.circular(1.3),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ComboData>(
          isExpanded: true,
          isDense: true,
          value: selected,
          items: allItems
              .map(
                (e) => DropdownMenuItem<ComboData>(
                  value: e,
                  child: Text(e.getCdName(), style: TextStyle(fontSize: 12.7, color: AppColors.textDefault), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  ComboData? _findMatchingItem(List<ComboData> items, ComboData? selected) {
    if (items.isEmpty) return null;
    if (selected == null) return items.first;
    for (final item in items) {
      if (item == selected) return item;
    }
    return items.first;
  }

  Future<void> _searchByKeyword() async {
    final resp = await NetHelper.request(context, () => NetHelper.api.metersCheckStatusSearchKeyword(_buildReq()));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      final list = resp['resultData'];
      setState(() {
        _resultList = (list is List) ? list.map((e) => MetersCheckStatusResultData.fromJson(e)).toList() : [];
        _isSearchExpanded = false;
      });
      Fluttertoast.showToast(msg: '${_resultList.length}건 조회되었습니다.');
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  Future<void> _searchByLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: '위치 서비스를 활성화해주세요.');
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: '설정에서 위치 권한을 허용해주세요.');
        await Geolocator.openAppSettings();
        return;
      }
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
          Fluttertoast.showToast(msg: 'GPS 권한이 필요합니다.');
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      final req = _buildReq();
      // Android와 동일: GPS_X = 위도(latitude), GPS_Y = 경도(longitude)
      req['GPS_X'] = pos.latitude.toString();
      req['GPS_Y'] = pos.longitude.toString();

      if (!mounted) return;
      final resp = await NetHelper.request(context, () => NetHelper.api.metersCheckStatusSearchLocation(req));
      if (!mounted) return;
      if (NetHelper.isSuccess(resp)) {
        final list = resp['resultData'];
        setState(() {
          _resultList = (list is List) ? list.map((e) => MetersCheckStatusResultData.fromJson(e)).toList() : [];
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

  Widget _buildResultList() {
    if (_resultList.isEmpty) {
      return const Center(child: Text('조회된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)));
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(13, 8.3, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.listStroke),
        borderRadius: BorderRadius.circular(1.3),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            color: const Color(0xFF666666),
            child: Row(
              children: [
                _tableHeaderCell('고객명', flex: 3),
                _tableHeaderCell('검침일', flex: 2),
                _tableHeaderCell('지침', flex: 2),
                _tableHeaderCell('사용량', flex: 2),
                _tableHeaderCell('잔량', flex: 2),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              itemCount: _resultList.length,
              itemBuilder: (context, index) {
                final item = _resultList[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      _tableDataCell(item.cuNameView ?? item.cuName ?? '', flex: 3),
                      _tableDataCell(DateUtil.convertFormat(item.appGjDate ?? '', DateUtil.formatYyyymmdd, DateUtil.formatMmDd), flex: 2),
                      _tableDataCell(item.appGjGum ?? '', flex: 2),
                      _tableDataCell(item.appGjGage ?? '', flex: 2),
                      _tableDataCell(item.appGjJankg ?? '', flex: 2),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade500, width: 0.5)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _tableDataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        child: Text(text, style: TextStyle(fontSize: 11, color: AppColors.textDefault), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _buildingNameController.dispose();
    _includeAddressController.dispose();
    super.dispose();
  }
}
