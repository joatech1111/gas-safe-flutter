import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../models/combo_data.dart';
import '../models/safety_customer_result_data.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/date_util.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_edit_dialog.dart';
import 'safety_check_screen.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final _searchController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _includeAddressController = TextEditingController();
  List<SafetyCustomerResultData> _resultList = [];
  bool _isSearchExpanded = true;

  ComboData? _selectedApt;
  ComboData? _selectedSw;
  ComboData? _selectedMan;
  ComboData? _selectedJy;

  List<ComboData> _aptList = [];
  List<ComboData> _swList = [];
  List<ComboData> _manList = [];
  List<ComboData> _jyList = [];

  int _cuType = 0; // 0=전체, 1=중량, 2=체적
  int _safeFlan = 0; // 0=전체, 1=특정일자
  String _safeFlanDate = DateUtil.today();
  bool _showConformityOnly = false;
  bool _showSuppOnly = false;

  @override
  void initState() {
    super.initState();
    _loadSearchConditions();
  }

  Future<void> _loadSearchConditions() async {
    final resp = await NetHelper.request(
      context,
      () => NetHelper.api.safetyCustomerSearchCondition(AppState.areaCode),
    );
    if (!mounted) return;
    if (NetHelper.isSuccess(resp) && resp['resultData'] != null) {
      final data = resp['resultData'];
      AppState.parseSafetyCondition(data);
      setState(() {
        _aptList = AppState.comboApt;
        _swList = AppState.comboSw;
        _manList = AppState.comboMan;
        _jyList = AppState.comboJy;
        _selectedSw = _findComboByCode(_swList, AppState.swCode);
        _selectedMan = _findComboByCode(_manList, AppState.gubunCode);
        _selectedJy = _findComboByCode(_jyList, AppState.jyCode);
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

  Map<String, dynamic> _buildReq() {
    // Android와 동일: 전체일 때 '99991231', 특정일자일 때 날짜값
    String safeFlan = '99991231';
    if (_safeFlan == 1) {
      safeFlan = _safeFlanDate;
    }

    return {
      'AREA_CODE': AppState.areaCode,
      'FIND_STR': _searchController.text.trim().isNotEmpty
          ? _searchController.text.trim()
          : _buildingNameController.text.trim(),
      'SAFE_FLAN': safeFlan,
      'CU_TYPE': _cuType.toString(),
      'CU_CODE': '',
      'APT_CD': _selectedApt?.cd ?? '',
      'SW_CD': _selectedSw?.cd ?? '',
      'MAN_CD': _selectedMan?.cd ?? '',
      'JY_CD': _selectedJy?.cd ?? '',
      'ADDR_TEXT': _includeAddressController.text.trim(),
      'SUPP_YN': _showSuppOnly ? 'Y' : 'N',
      'Conformity_YN': _showConformityOnly ? 'Y' : 'N',
      'OrderBy': '',
    };
  }

  Future<void> _searchByKeyword() async {
    final resp = await NetHelper.request(context, () => NetHelper.api.safetyCustomerSearchKeyword(_buildReq()));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      final list = resp['resultData'];
      setState(() {
        _resultList = (list is List) ? list.map((e) => SafetyCustomerResultData.fromJson(e)).toList() : [];
        _isSearchExpanded = false;
      });
      Fluttertoast.showToast(msg: '${_resultList.length}건 조회되었습니다.');
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  Future<void> _searchByLocation() async {
    try {
      // 위치 서비스 활성화 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: '위치 서비스를 활성화해주세요.');
        return;
      }

      // 권한 확인 및 요청
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
      final resp = await NetHelper.request(context, () => NetHelper.api.safetyCustomerSearchLocation(req));
      if (!mounted) return;
      if (NetHelper.isSuccess(resp)) {
        final list = resp['resultData'];
        setState(() {
          _resultList = (list is List) ? list.map((e) => SafetyCustomerResultData.fromJson(e)).toList() : [];
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
      appBar: CommonWidgets.buildAppBar(context, '안전점검'),
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
          // 검색조건 헤더 (예정기간 라디오 + 토글 버튼)
          InkWell(
            onTap: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
            child: Row(
              children: [
                const Text('예정기간', style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                _buildRadio2('전체', 0),
                _buildRadio2('특정일자', 1),
                const SizedBox(width: 9),
                Expanded(child: _buildScheduledDateField()),
                const SizedBox(width: 8),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(
                    _isSearchExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 24, color: AppColors.textDefault,
                  ),
                ),
              ],
            ),
          ),
          if (_isSearchExpanded)
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.fromLTRB(7, 8.3, 7, 0),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.listStroke, width: 1),
                borderRadius: BorderRadius.circular(1.3),
              ),
              child: Column(
                children: [
                  // 거래구분
                  Row(
                    children: [
                      const SizedBox(width: 60, child: Text('거래구분', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                      _buildCuTypeRadio('전체', 0),
                      _buildCuTypeRadio('중량(6개월)', 1),
                      _buildCuTypeRadio('체적(1년)', 2),
                    ],
                  ),
                  const SizedBox(height: 7.7),
                  // 건물명 + 스피너 (2단)
                  if (_aptList.isNotEmpty)
                    Row(
                      children: [
                        const SizedBox(width: 60, child: Text('건물명', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                        Expanded(
                          child: AppInput(
                            controller: _buildingNameController,
                            hint: '건물명',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _buildInlineDropdown(
                            items: _filteredAptList,
                            selectedItem: _selectedApt,
                            onChanged: (v) => setState(() => _selectedApt = v),
                          ),
                        ),
                      ],
                    ),
                  if (_aptList.isNotEmpty) const SizedBox(height: 8.7),
                  // 담당사원 + 관리분류
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledDropdownField(
                          label: '담당사원',
                          items: _swList,
                          selectedItem: _selectedSw,
                          onChanged: (v) => setState(() => _selectedSw = v),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _buildLabeledDropdownField(
                          label: '관리분류',
                          items: _manList,
                          selectedItem: _selectedMan,
                          onChanged: (v) => setState(() => _selectedMan = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.7),
                  // 지점분류 + 포함주소
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledDropdownField(
                          label: '지점분류',
                          items: _jyList,
                          selectedItem: _selectedJy,
                          onChanged: (v) => setState(() => _selectedJy = v),
                        ),
                      ),
                      const SizedBox(width: 7),
                      const SizedBox(width: 50, child: Text('포함주소', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                      Expanded(child: AppInput(controller: _includeAddressController, hint: '포함주소')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 체크박스
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20, height: 20,
                              child: Checkbox(
                                value: _showConformityOnly,
                                onChanged: (v) => setState(() => _showConformityOnly = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('부적합 거래처', style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20, height: 20,
                              child: Checkbox(
                                value: _showSuppOnly,
                                onChanged: (v) => setState(() => _showSuppOnly = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('공급계약 거래처만 조회', style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadio2(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(value: value, groupValue: _safeFlan, onChanged: (v) => setState(() => _safeFlan = v ?? 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
        Text(label, style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
      ],
    );
  }

  List<ComboData> get _filteredAptList {
    final keyword = _buildingNameController.text.trim().toLowerCase();
    if (keyword.isEmpty) return _aptList;
    final filtered = _aptList.where((e) => e.getCdName().toLowerCase().contains(keyword)).toList();
    return filtered.isEmpty ? _aptList : filtered;
  }

  Widget _buildScheduledDateField() {
    final enabled = _safeFlan == 1;
    return GestureDetector(
      onTap: enabled ? _pickSafeFlanDate : null,
      child: Container(
        height: AppInput.height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(AppInput.borderRadius),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          DateUtil.toDisplay(_safeFlanDate),
          style: TextStyle(fontSize: AppInput.fontSize, color: enabled ? Colors.black87 : Colors.black45),
        ),
      ),
    );
  }

  Future<void> _pickSafeFlanDate() async {
    final initialDate = _parseYyyyMmDd(_safeFlanDate) ?? DateTime.now();
    final date = await CommonWidgets.showKoreanDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() {
      _safeFlanDate = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    });
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
  }) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
        const SizedBox(width: 6),
        Expanded(
          child: _buildInlineDropdown(
            items: items,
            selectedItem: selectedItem,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildInlineDropdown({
    required List<ComboData> items,
    required ComboData? selectedItem,
    required ValueChanged<ComboData?> onChanged,
  }) {
    final allItems = <ComboData>[ComboData(cdName: '전체'), ...items];
    final selected = _findMatchingItem(allItems, selectedItem);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFE5E4DD)],
        ),
        border: Border.all(color: AppColors.searchStroke, width: 1),
        borderRadius: BorderRadius.circular(0.3),
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
                  child: Text(e.getCdName(), style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.accent),
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

  Widget _buildCuTypeRadio(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(value: value, groupValue: _cuType, onChanged: (v) => setState(() => _cuType = v ?? 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
        Text(label, style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
      ],
    );
  }

  Widget _buildResultList() {
    if (_resultList.isEmpty) {
      return const Center(child: Text('조회된 데이터가 없습니다.', style: TextStyle(color: AppColors.textDisabled)));
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(13, 8.3, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.listStroke, width: 1),
        borderRadius: BorderRadius.circular(1.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1.3),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          itemCount: _resultList.length,
          itemBuilder: (context, index) => _buildSafetyItem(_resultList[index]),
        ),
      ),
    );
  }

  Widget _buildSafetyItem(SafetyCustomerResultData item) {
    final safeFlan = item.cuSafeFlan ?? '';
    final safeDate = item.cuSafeDate ?? '';
    final gongDate = item.cuGongDate ?? '';
    final today = DateUtil.today();

    // Android와 동일: 점검예정일 색상 처리
    Color flanColor = AppColors.dateDefault;
    if (safeFlan.isNotEmpty && safeFlan != '99991231') {
      final diff = DateUtil.dayDiff(safeFlan, today);
      if (diff > 0) {
        flanColor = AppColors.dateOver; // 기한 초과
      } else if (diff.abs() <= 30) {
        flanColor = AppColors.dateSoon; // 임박
      }
    }

    // Android와 동일: 거래구분 색상 (중량=파랑, 체적=빨강)
    final cuType = item.cuTypeName ?? '';
    final Color badgeColor = cuType.contains('체적') ? AppColors.supplyVolume : AppColors.supplyWeight;

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => SafetyCheckScreen(customer: item),
        ));
      },
      onLongPress: () => _showContextMenu(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 11),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.lineBg.withValues(alpha: 0.5))),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: 거래구분 뱃지 + 거래처명(20dp) + 공급계약일(12.7dp)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 27, height: 19,
                  alignment: Alignment.center,
                  color: badgeColor,
                  child: Text(cuType, style: const TextStyle(fontSize: 11.3, color: Colors.white)),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(item.cuNameView ?? item.cuName ?? '',
                      style: const TextStyle(fontSize: 20, color: AppColors.textDefault),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Text(DateUtil.toDisplay(gongDate), style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: 전화번호(20dp) + 최종점검일(12.7dp)
            Row(
              children: [
                Expanded(
                  child: Text(item.cuTel ?? item.cuHp ?? '',
                      style: const TextStyle(fontSize: 20, color: AppColors.textDefault)),
                ),
                const SizedBox(width: 8),
                Text(DateUtil.toDisplay(safeDate), style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
              ],
            ),
            const SizedBox(height: 8),
            // Row 3: 주소(12.7dp) + 점검예정일(12.7dp, 상태 색상)
            Row(
              children: [
                Expanded(
                  child: Text(item.cuAddr ?? '${item.cuAddr1 ?? ''} ${item.cuAddr2 ?? ''}',
                      style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Text(DateUtil.toDisplay(safeFlan),
                    style: TextStyle(fontSize: 12.7, color: flanColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Android와 동일: 롱프레스 팝업 메뉴
  void _showContextMenu(SafetyCustomerResultData item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
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
                leading: const Icon(Icons.store, color: Color(0xFF666666)),
                title: const Text('거래처 정보'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final edited = await CustomerEditDialog.show(context, item);
                  if (!mounted || edited == null) return;
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF666666)),
                title: const Text('점검 이력'),
                onTap: () { Navigator.pop(ctx); _goToSafetyCheck(item, 0); },
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Color(0xFF5CB85C)),
                title: const Text('공급계약서 작성'),
                onTap: () { Navigator.pop(ctx); _goToSafetyCheck(item, 1); },
              ),
              ListTile(
                leading: const Icon(Icons.build, color: Color(0xFFF0AD4E)),
                title: const Text('소비설비 안전점검'),
                onTap: () { Navigator.pop(ctx); _goToSafetyCheck(item, 2); },
              ),
              ListTile(
                leading: const Icon(Icons.propane_tank, color: Color(0xFFD9534F)),
                title: const Text('저장탱크 안전점검'),
                onTap: () { Navigator.pop(ctx); _goToSafetyCheck(item, 3); },
              ),
              ListTile(
                leading: const Icon(Icons.home_work, color: Colors.purple),
                title: const Text('사용시설 안전점검'),
                onTap: () { Navigator.pop(ctx); _goToSafetyCheck(item, 4); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _goToSafetyCheck(SafetyCustomerResultData item, int tabIndex) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SafetyCheckScreen(customer: item, initialTab: tabIndex),
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _buildingNameController.dispose();
    _includeAddressController.dispose();
    super.dispose();
  }
}
