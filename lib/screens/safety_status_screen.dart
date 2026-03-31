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
  List<SafetyStatusResultData> _resultList = [];
  bool _isSearchExpanded = true;

  ComboData? _selectedApt;
  ComboData? _selectedSw;
  ComboData? _selectedMan;
  ComboData? _selectedJy;

  int _cuType = 0;
  String _dateFrom = DateUtil.beforeDays(7);
  String _dateTo = DateUtil.today();

  Map<String, dynamic> _buildReq() => {
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
    'ADDR_TEXT': '',
    'SUPP_YN': '',
    'Conformity_YN': '',
    'OrderBy': '',
    'SAFE_CD': '',
    'APP_User': AppState.loginUserId,
  };

  Future<void> _searchByKeyword() async {
    final resp = await NetHelper.request(context, () => NetHelper.api.safetyStatusSearchKeyword(_buildReq()));
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
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      final req = _buildReq();
      req['GPS_X'] = pos.longitude.toString();
      req['GPS_Y'] = pos.latitude.toString();

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
      appBar: CommonWidgets.buildAppBar(context, '점검현황'),
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
                  // Date range with ~ separator
                  Row(
                    children: [
                      const SizedBox(width: 50, child: Text('기간', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (date != null) {
                              setState(() => _dateFrom = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
                            }
                          },
                          child: Container(
                            height: 36, padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                            alignment: Alignment.center,
                            child: Text(DateUtil.toDisplay(_dateFrom), style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('~', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
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
                            height: 36, padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                            alignment: Alignment.center,
                            child: Text(DateUtil.toDisplay(_dateTo), style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 80, child: Text('거래구분', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      _buildCuTypeRadio('전체', 0),
                      _buildCuTypeRadio('중량', 1),
                      _buildCuTypeRadio('체적', 2),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (AppState.comboApt.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '건물명', items: AppState.comboApt, selectedItem: _selectedApt, onChanged: (v) => setState(() => _selectedApt = v)),
                  if (AppState.comboApt.isNotEmpty) const SizedBox(height: 6),
                  if (AppState.comboSw.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '담당사원', items: AppState.comboSw, selectedItem: _selectedSw, onChanged: (v) => setState(() => _selectedSw = v)),
                  if (AppState.comboSw.isNotEmpty) const SizedBox(height: 6),
                  if (AppState.comboMan.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '관리분류', items: AppState.comboMan, selectedItem: _selectedMan, onChanged: (v) => setState(() => _selectedMan = v)),
                  if (AppState.comboMan.isNotEmpty) const SizedBox(height: 6),
                  if (AppState.comboJy.isNotEmpty)
                    CommonWidgets.buildDropdown(label: '지역분류', items: AppState.comboJy, selectedItem: _selectedJy, onChanged: (v) => setState(() => _selectedJy = v)),
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

  Widget _buildCuTypeRadio(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(value: value, groupValue: _cuType, onChanged: (v) => setState(() => _cuType = v ?? 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildResultList() {
    if (_resultList.isEmpty) {
      return const Center(child: Text('조회된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)));
    }
    return Column(
      children: [
        // Table header
        Container(
          color: const Color(0xFF666666),
          child: Row(
            children: [
              _tableHeaderCell('거래구분', flex: 2),
              _tableHeaderCell('점검구분', flex: 2),
              _tableHeaderCell('고객명', flex: 3),
              _tableHeaderCell('점검일', flex: 2),
              _tableHeaderCell('적합', flex: 1),
              _tableHeaderCell('서명', flex: 1),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _resultList.length,
            itemBuilder: (context, index) {
              final item = _resultList[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    _tableDataCell(item.cuTypeName ?? '', flex: 2),
                    _tableDataCell(item.safeName ?? '', flex: 2),
                    _tableDataCell(item.anzCustName ?? '', flex: 3),
                    _tableDataCell(DateUtil.toDisplay(item.anzDate ?? ''), flex: 2),
                    _tableDataCellColored(item.safeResultYN ?? '', flex: 1,
                        color: item.safeResultYN == 'Y' ? Colors.green : Colors.red),
                    _tableDataCell(item.anzSignYN ?? '', flex: 1),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
        child: Text(text, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _tableDataCellColored(String text, {int flex = 1, Color color = Colors.black}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
