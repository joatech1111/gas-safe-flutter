import '../widgets/logo_loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/combo_data.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';
import '../utils/keys.dart';
import '../utils/prefs_util.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<ComboData> _areaList = [];
  ComboData? _selectedArea;
  ComboData? _selectedSw;
  ComboData? _selectedMan;
  ComboData? _selectedJy;
  ComboData? _selectedSort;
  ComboData? _selectedSafe;
  bool _isLoading = true;
  bool _hideBottomNavigation = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load area list
    final areaResp = await NetHelper.request(context, () => NetHelper.api.configArea());
    if (!mounted) return;

    if (NetHelper.isSuccess(areaResp) && areaResp['resultData'] != null) {
      final list = areaResp['resultData'];
      _areaList = (list is List) ? list.map((e) => ComboData.fromJson(e).toTrim()).toList() : [];

      // Set current selection
      for (final a in _areaList) {
        if (a.cd == AppState.areaCode) {
          _selectedArea = a;
          break;
        }
      }
    }

    // Load config for current area
    if (AppState.areaCode.isNotEmpty) {
      final configResp = await NetHelper.request(context, () => NetHelper.api.configAll(AppState.areaCode));
      if (!mounted) return;
      if (NetHelper.isSuccess(configResp) && configResp['resultData'] != null) {
        AppState.parseConfigAll(configResp['resultData']);
      }
    }

    // Set current selections
    _setCurrentSelections();
    _hideBottomNavigation = PrefsUtil.getBool(Keys.prefHideBottomNav, defaultValue: false);
    setState(() => _isLoading = false);
  }

  void _setCurrentSelections() {
    for (final s in AppState.comboSw) {
      if (s.cd == AppState.swCode) { _selectedSw = s; break; }
    }
    for (final m in AppState.comboMan) {
      if (m.cd == AppState.gubunCode) { _selectedMan = m; break; }
    }
    for (final j in AppState.comboJy) {
      if (j.cd == AppState.jyCode) { _selectedJy = j; break; }
    }
    for (final s in AppState.comboSort) {
      if (s.cd == AppState.orderBy) { _selectedSort = s; break; }
    }
    for (final s in AppState.comboSafe) {
      if (s.cd == AppState.safeSwCode) { _selectedSafe = s; break; }
    }
  }

  Future<void> _saveSettings() async {
    final user = AppState.loginUser;
    if (user == null) return;

    final req = {
      'HP_IMEI': '',
      'Login_User': user.loginUser,
      'Login_Pass': user.loginPass,
      'Safe_SW_CODE': _selectedSafe?.cd ?? '',
      'Area_CODE': _selectedArea?.cd ?? AppState.areaCode,
      'SW_CODE': _selectedSw?.cd ?? '',
      'Gubun_CODE': _selectedMan?.cd ?? '',
      'JY_CODE': _selectedJy?.cd ?? '',
      'OrderBy': _selectedSort?.cd ?? '',
    };

    final resp = await NetHelper.request(context, () => NetHelper.api.configInfoUpdate(req));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      // Update local state
      user.baAreaCode = _selectedArea?.cd ?? user.baAreaCode;
      user.baSwCode = _selectedSw?.cd ?? '';
      user.baGubunCode = _selectedMan?.cd ?? '';
      user.baJyCode = _selectedJy?.cd ?? '';
      user.baOrderBy = _selectedSort?.cd ?? '';
      user.safeSwCode = _selectedSafe?.cd ?? '';
      user.safeSwName = _selectedSafe?.getCdName() ?? '';
      AppState.setLoginUser(user);
      await PrefsUtil.setBool(Keys.prefHideBottomNav, _hideBottomNavigation);

      Fluttertoast.showToast(msg: '설정이 저장되었습니다.');
      if (mounted) Navigator.pop(context);
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonWidgets.buildAppBar(context, '설정'),
      bottomNavigationBar: CommonWidgets.buildBottomStatusBar(
        workerName: _selectedSafe?.getCdName() ?? AppState.safeSwName,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: LogoLoader(size: 100))
            : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: 사용자정보
                  _sectionHeader('사용자정보'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        if (AppState.comboSafe.isNotEmpty)
                          CommonWidgets.buildDropdown(label: '검침, 점검원', items: AppState.comboSafe, selectedItem: _selectedSafe, onChanged: (v) => setState(() => _selectedSafe = v), addAll: false),
                        if (AppState.comboSafe.isNotEmpty) const SizedBox(height: 10),
                        _buildReadOnlyField('사용자명', AppState.loginUser?.loginUser ?? ''),
                        const SizedBox(height: 10),
                        _buildReadOnlyField('비밀번호', AppState.loginUser?.loginPass ?? '', obscure: true),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Section 2: 거래처 검색 조건
                  _sectionHeader('거래처 검색 조건'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        if (_areaList.isNotEmpty)
                          CommonWidgets.buildDropdown(
                            label: '영업소',
                            items: _areaList,
                            selectedItem: _selectedArea,
                            onChanged: (v) async {
                              setState(() => _selectedArea = v);
                              if (v != null && v.cd != null && v.cd!.isNotEmpty) {
                                final configResp = await NetHelper.request(context, () => NetHelper.api.configAll(v.cd!));
                                if (mounted && NetHelper.isSuccess(configResp) && configResp['resultData'] != null) {
                                  AppState.parseConfigAll(configResp['resultData']);
                                  _setCurrentSelections();
                                  setState(() {});
                                }
                              }
                            },
                            addAll: false,
                          ),
                        if (_areaList.isNotEmpty) const SizedBox(height: 10),
                        if (AppState.comboSw.isNotEmpty)
                          CommonWidgets.buildDropdown(label: '담당사원', items: AppState.comboSw, selectedItem: _selectedSw, onChanged: (v) => setState(() => _selectedSw = v), addAll: false),
                        if (AppState.comboSw.isNotEmpty) const SizedBox(height: 10),
                        if (AppState.comboMan.isNotEmpty)
                          CommonWidgets.buildDropdown(label: '관리분류', items: AppState.comboMan, selectedItem: _selectedMan, onChanged: (v) => setState(() => _selectedMan = v)),
                        if (AppState.comboMan.isNotEmpty) const SizedBox(height: 10),
                        if (AppState.comboJy.isNotEmpty)
                          CommonWidgets.buildDropdown(label: '지역분류', items: AppState.comboJy, selectedItem: _selectedJy, onChanged: (v) => setState(() => _selectedJy = v)),
                        if (AppState.comboJy.isNotEmpty) const SizedBox(height: 10),
                        if (AppState.comboSort.isNotEmpty)
                          CommonWidgets.buildDropdown(label: '조회순서', items: AppState.comboSort, selectedItem: _selectedSort, onChanged: (v) => setState(() => _selectedSort = v), addAll: false),
                        if (AppState.comboSort.isNotEmpty) const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Section 3: 화면설정
                  _sectionHeader('화면설정'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('하단 네비게이션 바 숨기기', style: TextStyle(fontSize: 14, color: Colors.black87)),
                            ),
                            Switch(
                              value: _hideBottomNavigation,
                              onChanged: (v) => setState(() => _hideBottomNavigation = v),
                            ),
                          ],
                        ),
                        const Text(
                          '하단 네비게이션 바를 숨겨 더 넓은 화면을 사용할 수 있습니다.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Save button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF555555),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('저장', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF555555),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {bool obscure = false}) {
    final display = obscure && value.isNotEmpty ? '•' * value.length : value;
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(
          child: SizedBox(
            height: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: Text(display, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ),
          ),
        ),
      ],
    );
  }
}
