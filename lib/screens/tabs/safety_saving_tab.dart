import '../../widgets/logo_loader.dart';
import '../../widgets/signature_pad.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/combo_data.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_saving_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';
import '../../widgets/common_widgets.dart';

/// 점검항목 정의
class _ItemDef {
  final int index;
  final String label;
  final bool hasNone; // true = 3-option (적합/부적합/해당없음), false = 2-option
  final List<String> subLabels;
  final bool hasEtcText; // "기타" 서브항목에 텍스트 필드 연결
  final String? etcLabel; // 기타 체크박스의 라벨 (null이면 표시 안 함)
  final String? textKey;
  final String? text1Key;
  final String? text2Key;
  final String? text1Label;
  final String? text2Label;

  const _ItemDef({
    required this.index,
    required this.label,
    this.hasNone = true,
    this.subLabels = const [],
    this.hasEtcText = false,
    this.etcLabel,
    this.textKey,
    this.text1Key,
    this.text2Key,
    this.text1Label,
    this.text2Label,
  });

  int get subCount => subLabels.length + (hasEtcText ? 1 : 0);
}

const _items = <_ItemDef>[
  _ItemDef(
    index: 1,
    label: '1. LPG용기(소형저장탱크)',
    hasNone: true,
    subLabels: [
      '설치장소',
      '차량 또는 용기보관실 설치',
      '고정상태',
      '용기보관실 재료(불연재사용)',
      '환기상태',
      '화기와의 거리',
      '부식방지(용기바닥면) 조치',
      '경계표지, 연락처 설치',
      '소화기',
      '침하여부',
      '정전기제거설비',
      '방출관 설치',
      '탱크 재검사 여부',
    ],
    hasEtcText: true,
    etcLabel: '기타',
    textKey: 'ANZ_Item1_Text',
  ),
  _ItemDef(
    index: 2,
    label: '2. 압력조정기',
    hasNone: true,
    subLabels: ['조정압력', '용량', '검사품 여부'],
  ),
  _ItemDef(
    index: 3,
    label: '3. 기화장치',
    hasNone: true,
    subLabels: [
      '출구측 가스압력(1㎫미만)',
      '기화장치 재검사 여부',
      '비상전력확보 여부 등',
    ],
    hasEtcText: true,
    etcLabel: '기타',
    textKey: 'ANZ_Item3_Text',
  ),
  _ItemDef(
    index: 4,
    label: '4. 가스계량기',
    hasNone: true,
    subLabels: ['전기설비, 화기와의 이격', '환기상태', '화기와의 거리'],
  ),
  _ItemDef(
    index: 5,
    label: '5. 중간밸브',
    hasNone: false,
    subLabels: ['설치위치', '퓨즈콕 설치', '검사품 여부'],
    hasEtcText: true,
    etcLabel: '기타',
    textKey: 'ANZ_Item5_Text',
  ),
  _ItemDef(
    index: 6,
    label: '6. 노출배관(호스포함)',
    hasNone: false,
    subLabels: [
      '배관재료',
      '고정상태',
      '설치위치',
      '벽관통부 보호관 및 부식방지조치',
      '전기설비 등과의 이격거리',
      '도색상태',
      '배관의 표시',
      '호스 3m이내',
      'T형 사용',
      '배관 막음조치',
    ],
  ),
  _ItemDef(
    index: 7,
    label: '7. 연소기',
    hasNone: false,
    subLabels: [
      '검사품 사용',
      '온수기나 보일러 등의 설치장소',
      '급·배기구 설치 및 환기상태',
      '빌트연소기 가스누출 확인조치',
      '배기통 설치상태(처짐, 연결상태, 배기통위치, 배기통재질, 인증품 여부 등)',
    ],
  ),
  _ItemDef(
    index: 8,
    label: '8. 가스누출경보기(차단장치)',
    hasNone: true,
    subLabels: ['설치위치', '작동상태'],
    hasEtcText: true,
    etcLabel: '검지부 설치수량',
    textKey: 'ANZ_Item8_Text',
  ),
  _ItemDef(
    index: 9,
    label: '9. 가스누출 여부',
    hasNone: false,
    subLabels: ['누출없음', '누출있음'],
    text1Key: 'ANZ_Item9_Text1',
    text2Key: 'ANZ_Item9_Text2',
    text1Label: '누출부위',
    text2Label: '현장조치',
  ),
  _ItemDef(
    index: 10,
    label: '10. 그밖의 사항',
    hasNone: true,
    text1Key: 'ANZ_Item10_Text1',
    text2Key: 'ANZ_Item10_Text2',
    text1Label: '기타',
    text2Label: '기타',
  ),
];

class SafetySavingTab extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final String? anzSno;

  const SafetySavingTab({super.key, required this.customer, this.anzSno});

  @override
  State<SafetySavingTab> createState() => _SafetySavingTabState();
}

class _SafetySavingTabState extends State<SafetySavingTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _isNew = false;
  String? _anzSno;

  final _anzDateController = TextEditingController();
  final _lpKg01Controller = TextEditingController();
  final _lpKg02Controller = TextEditingController();
  final _anzCuConfirmController = TextEditingController();
  final _anzCuConfirmTelController = TextEditingController();

  // 점검결과 값 (ANZ_Item1 ~ ANZ_Item10)
  final Map<String, String> _resultValues = {};

  // 서브체크 상태 (ANZ_Item1_SUB ~ ANZ_Item9_SUB)
  final Map<String, List<bool>> _subChecks = {};

  // 텍스트 컨트롤러
  final Map<String, TextEditingController> _textControllers = {};

  ComboData? _selectedSw;
  String? _signatureData;
  bool _hasSignature = false;
  bool _loaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _anzSno = widget.anzSno;

    // 텍스트 컨트롤러 초기화
    for (final item in _items) {
      if (item.textKey != null) {
        _textControllers[item.textKey!] = TextEditingController();
      }
      if (item.text1Key != null) {
        _textControllers[item.text1Key!] = TextEditingController();
      }
      if (item.text2Key != null) {
        _textControllers[item.text2Key!] = TextEditingController();
      }
    }

    // 서브체크 초기화
    for (final item in _items) {
      if (item.subCount > 0) {
        _subChecks['ANZ_Item${item.index}_SUB'] = List.filled(item.subCount, false);
      }
    }

    _initSelectedSw();
  }

  void _initSelectedSw() {
    final swList = AppState.comboSw;
    if (swList.isNotEmpty) {
      final match = swList.where((e) => e.cd == AppState.safeSwCode);
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
    _anzCuConfirmController.text = d.anzCuConfirm ?? '';
    _anzCuConfirmTelController.text = d.anzCuConfirmTel ?? '';

    if (d.anzSwCode != null && d.anzSwCode!.isNotEmpty) {
      final swList = AppState.comboSw;
      final match = swList.where((e) => e.cd == d.anzSwCode);
      if (match.isNotEmpty) _selectedSw = match.first;
    }

    _hasSignature = d.anzSignYN == Keys.y;

    // 결과값 복원
    _resultValues['ANZ_Item1'] = d.anzItem1 ?? '';
    _resultValues['ANZ_Item2'] = d.anzItem2 ?? '';
    _resultValues['ANZ_Item3'] = d.anzItem3 ?? '';
    _resultValues['ANZ_Item4'] = d.anzItem4 ?? '';
    _resultValues['ANZ_Item5'] = d.anzItem5 ?? '';
    _resultValues['ANZ_Item6'] = d.anzItem6 ?? '';
    _resultValues['ANZ_Item7'] = d.anzItem7 ?? '';
    _resultValues['ANZ_Item8'] = d.anzItem8 ?? '';
    _resultValues['ANZ_Item9'] = d.anzItem9 ?? '';
    _resultValues['ANZ_Item10'] = d.anzItem10 ?? '';

    // 서브체크 바이너리 복원
    _decodeSub('ANZ_Item1_SUB', d.anzItem1Sub, _items[0].subCount);
    _decodeSub('ANZ_Item2_SUB', d.anzItem2Sub, _items[1].subCount);
    _decodeSub('ANZ_Item3_SUB', d.anzItem3Sub, _items[2].subCount);
    _decodeSub('ANZ_Item4_SUB', d.anzItem4Sub, _items[3].subCount);
    _decodeSub('ANZ_Item5_SUB', d.anzItem5Sub, _items[4].subCount);
    _decodeSub('ANZ_Item6_SUB', d.anzItem6Sub, _items[5].subCount);
    _decodeSub('ANZ_Item7_SUB', d.anzItem7Sub, _items[6].subCount);
    _decodeSub('ANZ_Item8_SUB', d.anzItem8Sub, _items[7].subCount);
    _decodeSub('ANZ_Item9_SUB', d.anzItem9Sub, _items[8].subCount);

    // 텍스트 복원
    _textControllers['ANZ_Item1_Text']?.text = d.anzItem1Text ?? '';
    _textControllers['ANZ_Item3_Text']?.text = d.anzItem3Text ?? '';
    _textControllers['ANZ_Item5_Text']?.text = d.anzItem5Text ?? '';
    _textControllers['ANZ_Item8_Text']?.text = d.anzItem8Text ?? '';
    _textControllers['ANZ_Item9_Text1']?.text = d.anzItem9Text1 ?? '';
    _textControllers['ANZ_Item9_Text2']?.text = d.anzItem9Text2 ?? '';
    _textControllers['ANZ_Item10_Text1']?.text = d.anzItem10Text1 ?? '';
    _textControllers['ANZ_Item10_Text2']?.text = d.anzItem10Text2 ?? '';
  }

  void _decodeSub(String key, String? binary, int count) {
    final list = List.filled(count, false);
    if (binary != null) {
      for (int i = 0; i < binary.length && i < count; i++) {
        list[i] = binary[i] == '1';
      }
    }
    _subChecks[key] = list;
  }

  String _encodeSub(String key, int count) {
    final list = _subChecks[key];
    if (list == null) return '0' * count;
    final buf = StringBuffer();
    for (int i = 0; i < count; i++) {
      buf.write((i < list.length && list[i]) ? '1' : '0');
    }
    return buf.toString();
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
    _anzCuConfirmTelController.text = widget.customer.cuHp ?? '';
  }

  Future<void> _save({bool sendSMS = false}) async {
    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}

    final swCode = _selectedSw?.cd ?? AppState.safeSwCode;
    final swName = _selectedSw?.getCdName() ?? AppState.safeSwName;

    final req = <String, dynamic>{
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': widget.customer.cuCode,
      'ANZ_Sno': _isNew ? '' : (_anzSno ?? ''),
      'ANZ_Date': DateUtil.fromDisplay(_anzDateController.text),
      'ANZ_SW_Code': swCode,
      'ANZ_SW_Name': swName,
      'ANZ_LP_KG_01': _lpKg01Controller.text,
      'ANZ_LP_KG_02': _lpKg02Controller.text,
      'ANZ_CU_Confirm': _anzCuConfirmController.text,
      'ANZ_CU_Confirm_TEL': _anzCuConfirmTelController.text,
      'ANZ_Sign_YN': _hasSignature ? Keys.y : Keys.n,
      'ANZ_CU_SMS_YN': sendSMS ? Keys.y : Keys.n,
      'GPS_X': pos?.longitude.toString() ?? '',
      'GPS_Y': pos?.latitude.toString() ?? '',
      'ANZ_User_ID': AppState.loginUserId,
      'ANZ_Sign': _signatureData ?? '',
    };

    for (final item in _items) {
      final i = item.index;
      req['ANZ_Item$i'] = _resultValues['ANZ_Item$i'] ?? '';
      if (item.subCount > 0) {
        req['ANZ_Item${i}_SUB'] = _encodeSub('ANZ_Item${i}_SUB', item.subCount);
      }
    }

    req['ANZ_Item1_Text'] = _textControllers['ANZ_Item1_Text']?.text ?? '';
    req['ANZ_Item3_Text'] = _textControllers['ANZ_Item3_Text']?.text ?? '';
    req['ANZ_Item5_Text'] = _textControllers['ANZ_Item5_Text']?.text ?? '';
    req['ANZ_Item8_Text'] = _textControllers['ANZ_Item8_Text']?.text ?? '';
    req['ANZ_Item9_Text1'] = _textControllers['ANZ_Item9_Text1']?.text ?? '';
    req['ANZ_Item9_Text2'] = _textControllers['ANZ_Item9_Text2']?.text ?? '';
    req['ANZ_Item10_Text1'] = _textControllers['ANZ_Item10_Text1']?.text ?? '';
    req['ANZ_Item10_Text2'] = _textControllers['ANZ_Item10_Text2']?.text ?? '';

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

    bool hasFailed = false;
    for (int i = 1; i <= 10; i++) {
      if ((_resultValues['ANZ_Item$i'] ?? '') == Keys.savingFailed) {
        hasFailed = true;
        break;
      }
    }
    final resultText = hasFailed ? '부적합' : '적합';

    final swName = _selectedSw?.getCdName() ?? AppState.safeSwName;
    smsMsg = smsMsg
        .replaceAll('{거래처명}', widget.customer.cuNameView ?? widget.customer.cuName ?? '')
        .replaceAll('{영업소코드}', areaCode)
        .replaceAll('{거래처코드}', widget.customer.cuCode ?? '')
        .replaceAll('{주소}', '${widget.customer.cuAddr1 ?? ''} ${widget.customer.cuAddr2 ?? ''}')
        .replaceAll('{점검일}', _anzDateController.text)
        .replaceAll('{점검원}', swName)
        .replaceAll('{점검결과}', resultText);

    final tel = _anzCuConfirmTelController.text.trim();
    if (tel.isEmpty) { Fluttertoast.showToast(msg: '확인 연락처를 입력해주세요.'); return; }
    final uri = Uri(scheme: 'sms', path: tel, queryParameters: {'body': smsMsg});
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
  }

  Future<void> _showSignatureDialog() async {
    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final padKey = GlobalKey<SignaturePadState>();
        return AlertDialog(
          title: const Text('서명등록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('아래 영역에 서명해 주세요.', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                SignaturePad(key: padKey, initialSignature: _signatureData),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => padKey.currentState?.clear(),
                    child: const Text('지우기', style: TextStyle(fontSize: 14, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('취소', style: TextStyle(fontSize: 14)),
            ),
            ElevatedButton(
              onPressed: () async {
                final base64 = await padKey.currentState?.toBase64();
                Navigator.pop(ctx, base64 ?? '');
              },
              child: const Text('확인', style: TextStyle(fontSize: 14)),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        if (result.isNotEmpty) {
          _signatureData = result;
          _hasSignature = true;
        } else {
          _signatureData = null;
          _hasSignature = false;
        }
      });
    }
  }

  // ─── BUILD ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return Center(child: LogoLoader(size: 100));

    return Column(
      children: [
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
                _buildCustomerCard(),
                const SizedBox(height: 10),
                _sectionTitle('기본정보'),
                const SizedBox(height: 4),
                _labeledRow('점검일자', _buildDateField()),
                const SizedBox(height: 6),
                _labeledRow('점검사원', _buildSwDropdown()),
                const SizedBox(height: 6),
                _buildLpGasRow(),
                const SizedBox(height: 6),
                const Divider(height: 20, thickness: 1),
                _sectionTitle('점검항목'),
                const SizedBox(height: 4),
                for (final item in _items) ...[
                  _buildItemSection(item),
                  const SizedBox(height: 4),
                ],
                const Divider(height: 20, thickness: 1),
                _labeledRow('확인자명', _buildTextField(_anzCuConfirmController)),
                const SizedBox(height: 6),
                _buildSignatureRow(),
                const SizedBox(height: 6),
                _labeledRow('SMS번호', _buildTextField(_anzCuConfirmTelController, keyboardType: TextInputType.phone)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  // ─── 점검항목 섹션 빌더 ─────────────────────────────

  Widget _buildItemSection(_ItemDef item) {
    final resultKey = 'ANZ_Item${item.index}';
    final subKey = 'ANZ_Item${item.index}_SUB';
    final resultValue = _resultValues[resultKey] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 라벨 + 결과 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Text(item.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                _resultBtn('적합', Keys.savingPassed, resultValue, resultKey),
                _resultBtn('부적합', Keys.savingFailed, resultValue, resultKey),
                if (item.hasNone)
                  _resultBtn('해당없음', Keys.savingNone, resultValue, resultKey),
              ],
            ),
          ),

          // 서브 체크박스
          if (item.subCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: [
                  for (int i = 0; i < item.subLabels.length; i++)
                    _subCheckbox(subKey, i, item.subLabels[i]),
                  if (item.hasEtcText)
                    _subCheckboxWithText(subKey, item.subLabels.length, item.etcLabel ?? '기타', item.textKey),
                ],
              ),
            ),

          // 텍스트 필드 (Item 9, 10 등)
          if (item.text1Key != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: _inlineTextField(item.text1Label ?? '비고', _textControllers[item.text1Key]!),
            ),
          if (item.text2Key != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 4),
              child: _inlineTextField(item.text2Label ?? '비고', _textControllers[item.text2Key]!),
            ),

          if (item.subCount == 0 && item.text1Key == null)
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// 결과 버튼 (적합/부적합/해당없음)
  Widget _resultBtn(String label, String itemValue, String currentValue, String key) {
    final isSelected = currentValue == itemValue;
    Color bgColor;
    if (isSelected) {
      if (itemValue == Keys.savingPassed) {
        bgColor = const Color(0xFF5CB85C);
      } else if (itemValue == Keys.savingFailed) {
        bgColor = const Color(0xFFD9534F);
      } else {
        bgColor = const Color(0xFF555555);
      }
    } else {
      bgColor = Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: () => setState(() => _resultValues[key] = itemValue),
      child: Container(
        margin: const EdgeInsets.only(left: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  /// 서브 체크박스
  Widget _subCheckbox(String subKey, int index, String label) {
    final checks = _subChecks[subKey];
    final isChecked = checks != null && index < checks.length && checks[index];

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 28,
            child: Checkbox(
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (checks != null && index < checks.length) {
                    checks[index] = val ?? false;
                  }
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2),
          ),
        ],
      ),
    );
  }

  /// 기타 체크박스 + 텍스트 필드
  Widget _subCheckboxWithText(String subKey, int index, String label, String? textKey) {
    final checks = _subChecks[subKey];
    final isChecked = checks != null && index < checks.length && checks[index];

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 28,
            child: Checkbox(
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (checks != null && index < checks.length) {
                    checks[index] = val ?? false;
                  }
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 2),
          Text('$label (', style: const TextStyle(fontSize: 12)),
          if (textKey != null)
            Expanded(
              child: SizedBox(
                height: 28,
                child: TextField(
                  controller: _textControllers[textKey],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          const Text(')', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// 인라인 텍스트 필드 (누출부위, 현장조치 등)
  Widget _inlineTextField(String label, TextEditingController ctrl) {
    return Row(
      children: [
        Text('$label (', style: const TextStyle(fontSize: 12)),
        Expanded(
          child: SizedBox(
            height: 30,
            child: TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const Text(')', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // ─── 기본정보/확인자 영역 위젯 ───────────────────────

  Widget _buildCustomerCard() {
    final c = widget.customer;
    final addr = (c.cuAddr != null && c.cuAddr!.isNotEmpty)
        ? c.cuAddr!
        : '${c.cuAddr1 ?? ''} ${c.cuAddr2 ?? ''}'.trim();
    final displayName = c.cuNameView ?? c.cuName ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (c.cuTypeName != null && c.cuTypeName!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF337AB7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(c.cuTypeName!, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (addr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 15, color: Colors.black45),
                  const SizedBox(width: 4),
                  Expanded(child: Text(addr, style: const TextStyle(fontSize: 14, color: Colors.black87))),
                ],
              ),
            ),
          const Divider(height: 12, thickness: 0.5),
          _infoRow('계약번호', c.cuGongNo ?? '-'),
          const SizedBox(height: 3),
          _infoRow('계약명', c.cuGongName ?? '-'),
          const SizedBox(height: 3),
          _infoRow('계약일자', _formatDateDisplay(c.cuGongDate)),
          const SizedBox(height: 3),
          _infoRow('최종점검일', _formatDateDisplay(c.cuSafeDate)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))),
      ],
    );
  }

  String _formatDateDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    return DateUtil.toDisplay(dateStr);
  }

  Widget _labeledRow(String label, Widget child) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildDateField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _anzDateController,
        readOnly: true,
        onTap: () => _pickDate(_anzDateController),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildSwDropdown() {
    final swList = AppState.comboSw;
    if (swList.isEmpty) {
      return SizedBox(
        height: 40,
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: AppState.safeSwName,
            hintStyle: const TextStyle(fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      );
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ComboData>(
          isExpanded: true,
          value: _selectedSw,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          items: swList.map((sw) => DropdownMenuItem<ComboData>(
            value: sw,
            child: Text(sw.getCdName(), style: const TextStyle(fontSize: 14)),
          )).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedSw = val);
          },
        ),
      ),
    );
  }

  Widget _buildLpGasRow() {
    return Row(
      children: [
        const SizedBox(width: 80, child: Text('LP가스(kg)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _lpKg01Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                isDense: true,
                suffixText: 'kg',
                suffixStyle: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _lpKg02Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                isDense: true,
                suffixText: 'kg',
                suffixStyle: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, {TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildSignatureRow() {
    return Row(
      children: [
        const SizedBox(width: 80, child: Text('서명', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Expanded(
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showSignatureDialog,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('서명등록', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF337AB7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 12),
              if (_hasSignature)
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green),
                    SizedBox(width: 4),
                    Text('서명완료', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                )
              else
                const Text('미등록', style: TextStyle(fontSize: 13, color: Colors.black45)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
      ),
    );
  }

  Future<bool> _confirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소', style: TextStyle(fontSize: 14))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인', style: TextStyle(fontSize: 14))),
        ],
      ),
    );
    return result == true;
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48, alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      margin: const EdgeInsets.only(bottom: 4),
      color: const Color(0xFF666666),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
    );
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
    _lpKg01Controller.dispose();
    _lpKg02Controller.dispose();
    _anzCuConfirmController.dispose();
    _anzCuConfirmTelController.dispose();
    for (final c in _textControllers.values) c.dispose();
    super.dispose();
  }
}
