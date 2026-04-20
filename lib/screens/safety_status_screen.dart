import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../models/combo_data.dart';
import '../models/safety_status_result_data.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/date_util.dart';
import '../widgets/common_widgets.dart';

class SafetyStatusScreen extends StatefulWidget {
  const SafetyStatusScreen({super.key});

  @override
  State<SafetyStatusScreen> createState() => _SafetyStatusScreenState();
}

class _SafetyStatusScreenState extends State<SafetyStatusScreen> {
  final _searchController = TextEditingController();
  final _includeAddressController = TextEditingController();
  List<SafetyStatusResultData> _resultList = [];
  bool _isSearchExpanded = true;

  ComboData? _selectedApt;
  ComboData? _selectedSw;
  ComboData? _selectedMan;
  ComboData? _selectedJy;

  int _cuType = 0;
  String _dateFrom = DateUtil.beforeDays(7);
  String _dateTo = DateUtil.today();
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
      AppState.parseSafetyCondition(resp['resultData']);
      setState(() {
        _selectedSw = _findComboByCode(AppState.comboSw, AppState.swCode);
        _selectedMan = _findComboByCode(AppState.comboMan, AppState.gubunCode);
        _selectedJy = _findComboByCode(AppState.comboJy, AppState.jyCode);
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

  String _buildAppUser() {
    final hpSno = (AppState.loginUser?.hpSno ?? '').trim();
    final loginName = (AppState.loginUser?.loginName ?? '').trim();
    final combined = '$hpSno$loginName';
    return combined.isNotEmpty ? combined : AppState.loginUserId;
  }

  Map<String, dynamic> _buildReqKeyword() => {
    'AREA_CODE': AppState.areaCode,
    'FIND_STR': _searchController.text.trim(),
    'GUM_DATE_F': _dateFrom,
    'GUM_DATE_T': _dateTo,
    'CU_TYPE': _cuType.toString(),
    'CU_CODE': '',
    'APT_CD': _selectedApt?.cd ?? '',
    'SW_CD': _selectedSw?.cd ?? '',
    'MAN_CD': _selectedMan?.cd ?? '',
    'JY_CD': _selectedJy?.cd ?? '',
    'ADDR_TEXT': _includeAddressController.text.trim(),
    'SUPP_YN': _showSuppOnly ? 'Y' : 'N',
    'Conformity_YN': _showConformityOnly ? 'N' : 'Y',
    'OrderBy': '',
    'SAFE_CD': AppState.safeSwCode,
    'APP_User': _buildAppUser(),
  };

  Map<String, dynamic> _buildReqLocation() => {
    'AREA_CODE': AppState.areaCode,
    'FIND_STR': '',
    'GUM_DATE_F': _dateFrom,
    'GUM_DATE_T': _dateTo,
    'CU_TYPE': _cuType.toString(),
    'CU_CODE': '',
    'APT_CD': _selectedApt?.cd ?? '',
    'SW_CD': _selectedSw?.cd ?? '',
    'MAN_CD': _selectedMan?.cd ?? '',
    'JY_CD': _selectedJy?.cd ?? '',
    'ADDR_TEXT': _includeAddressController.text.trim(),
    'SUPP_YN': _showSuppOnly ? 'Y' : 'N',
    'Conformity_YN': _showConformityOnly ? 'N' : 'Y',
    'OrderBy': '',
    'SAFE_CD': AppState.safeSwCode,
    'APP_User': _buildAppUser(),
  };

  Future<void> _searchByKeyword() async {
    final resp = await NetHelper.request(context, () => NetHelper.api.safetyStatusSearchKeyword(_buildReqKeyword()));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      final list = resp['resultData'];
      setState(() {
        _resultList = (list is List) ? list.map((e) => SafetyStatusResultData.fromJson(e)).toList() : [];
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
      final req = _buildReqLocation();
      // Android와 동일: GPS_X = 위도(latitude), GPS_Y = 경도(longitude)
      req['GPS_X'] = pos.latitude.toString();
      req['GPS_Y'] = pos.longitude.toString();

      if (!mounted) return;
      final resp = await NetHelper.request(context, () => NetHelper.api.safetyStatusSearchLocation(req));
      if (!mounted) return;
      if (NetHelper.isSuccess(resp)) {
        final list = resp['resultData'];
        setState(() {
          _resultList = (list is List) ? list.map((e) => SafetyStatusResultData.fromJson(e)).toList() : [];
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
      appBar: CommonWidgets.buildAppBar(context, '점검 현황'),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
              child: Row(
                children: [
                  const Text('검색조건', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDefault)),
                  const Spacer(),
                  Icon(_isSearchExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.accent),
                ],
              ),
            ),
          ),
          if (_isSearchExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.listStroke),
                borderRadius: BorderRadius.circular(1.3),
              ),
              padding: const EdgeInsets.fromLTRB(7, 8.3, 7, 0),
              child: Column(
                children: [
                  // Date range with ~ separator
                  Row(
                    children: [
                      const SizedBox(width: 50, child: Text('기간', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await CommonWidgets.showKoreanDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => _dateFrom = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
                            }
                          },
                          child: Container(
                            height: 24, padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFFFFF), Color(0xFFE5E4DD)],
                              ),
                              border: Border.all(color: AppColors.searchStroke, width: 1),
                              borderRadius: BorderRadius.circular(0.3),
                            ),
                            alignment: Alignment.center,
                            child: Text(DateUtil.toDisplay(_dateFrom), style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('~', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDefault))),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await CommonWidgets.showKoreanDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
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
                            height: 24, padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFFFFF), Color(0xFFE5E4DD)],
                              ),
                              border: Border.all(color: AppColors.searchStroke, width: 1),
                              borderRadius: BorderRadius.circular(0.3),
                            ),
                            alignment: Alignment.center,
                            child: Text(DateUtil.toDisplay(_dateTo), style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 80, child: Text('거래구분', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
                      _buildCuTypeRadio('전체', 0),
                      _buildCuTypeRadio('중량(6개월)', 1),
                      _buildCuTypeRadio('체적(1년)', 2),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CommonWidgets.buildDropdown(
                    label: '건물명',
                    items: AppState.comboApt,
                    selectedItem: _selectedApt,
                    onChanged: (v) => setState(() => _selectedApt = v),
                  ),
                  const SizedBox(height: 6),
                  CommonWidgets.buildDropdown(
                    label: '담당사원',
                    items: AppState.comboSw,
                    selectedItem: _selectedSw,
                    onChanged: (v) => setState(() => _selectedSw = v),
                  ),
                  const SizedBox(height: 6),
                  CommonWidgets.buildDropdown(
                    label: '관리분류',
                    items: AppState.comboMan,
                    selectedItem: _selectedMan,
                    onChanged: (v) => setState(() => _selectedMan = v),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: CommonWidgets.buildDropdown(
                          label: '지역분류',
                          items: AppState.comboJy,
                          selectedItem: _selectedJy,
                          onChanged: (v) => setState(() => _selectedJy = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 80,
                        child: Text('포함주소', style: TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault)),
                      ),
                      Expanded(child: AppInput(controller: _includeAddressController, hint: '포함주소')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _showConformityOnly,
                                onChanged: (v) => setState(() => _showConformityOnly = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(() => _showConformityOnly = !_showConformityOnly),
                              child: const Text('부적합 거래처', style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _showSuppOnly,
                                onChanged: (v) => setState(() => _showSuppOnly = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(() => _showSuppOnly = !_showSuppOnly),
                              child: const Text('공급계약 거래처만 조회', style: TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
                            ),
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

  Widget _buildCuTypeRadio(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(value: value, groupValue: _cuType, onChanged: (v) => setState(() => _cuType = v ?? 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDefault)),
      ],
    );
  }

  Color _getBadgeColor(SafetyStatusResultData item) {
    final cuType = (item.cuTypeName ?? '').trim();
    if (cuType.contains('중량')) return AppColors.supplyWeight;
    if (cuType.contains('체적')) return AppColors.supplyVolume;
    return AppColors.textDefault;
  }

  Color _getDateColor(SafetyStatusResultData item) {
    final result = (item.safeResultYN ?? '').trim();
    if (result == 'N') return AppColors.dateOver;
    final dateStr = item.anzDate ?? '';
    if (dateStr.isEmpty) return AppColors.dateDefault;
    try {
      final anzDate = DateTime(
        int.parse(dateStr.substring(0, 4)),
        int.parse(dateStr.substring(4, 6)),
        int.parse(dateStr.substring(6, 8)),
      );
      final now = DateTime.now();
      final diff = anzDate.difference(now).inDays;
      if (diff < 0) return AppColors.dateOver;
      if (diff <= 30) return AppColors.dateSoon;
    } catch (_) {}
    return AppColors.dateDefault;
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
          itemBuilder: (context, index) {
            final item = _resultList[index];
            final badgeColor = _getBadgeColor(item);
            final dateColor = _getDateColor(item);
            final displayDate = DateUtil.convertFormat(item.anzDate ?? '', DateUtil.formatYyyymmdd, DateUtil.formatYyMmDd);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: index < _resultList.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.listStroke, width: 0.5))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Badge
                      Container(
                        width: 27,
                        height: 19,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          (item.cuTypeName ?? '').length > 2
                              ? (item.cuTypeName ?? '').substring(0, 2)
                              : item.cuTypeName ?? '',
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Customer name
                      Expanded(
                        child: Text(
                          item.anzCustName ?? '',
                          style: const TextStyle(fontSize: 20, color: AppColors.textDefault, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Safe result
                      Text(
                        item.safeResultYN == 'Y' ? '적합' : '부적합',
                        style: TextStyle(
                          fontSize: 12.7,
                          color: item.safeResultYN == 'Y' ? AppColors.dateSoon : AppColors.dateOver,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Check type + worker name
                  Text(
                    '${item.safeName ?? ''}  ${item.anzSwName ?? ''}',
                    style: const TextStyle(fontSize: 20, color: AppColors.textDefault),
                  ),
                  const SizedBox(height: 2),
                  // Date row
                  Row(
                    children: [
                      Text(
                        '점검일: $displayDate',
                        style: TextStyle(fontSize: 12.7, color: dateColor),
                      ),
                      const Spacer(),
                      Text(
                        '서명: ${item.anzSignYN ?? ''}',
                        style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _includeAddressController.dispose();
    super.dispose();
  }
}
