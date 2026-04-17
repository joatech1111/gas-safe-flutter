import '../../widgets/logo_loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_check_contract_result_data.dart';
import '../../network/net_helper.dart';
import '../../services/contract_pdf_service.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/signature_pad.dart';

class SafetyContractTab extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final String? anzSno;

  const SafetyContractTab({super.key, required this.customer, this.anzSno});

  @override
  State<SafetyContractTab> createState() => _SafetyContractTabState();
}

class _SafetyContractTabState extends State<SafetyContractTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _isNew = false;
  String? _anzSno;
  String? _pdfFileUrl;
  bool _contractContentExpanded = true;
  bool _supplierEquipExpanded = true;
  bool _complaintCenterExpanded = true;
  bool _supplierExpanded = true;
  bool _customerExpanded = true;

  String? _signatureCustomer;
  String? _signatureSupplier;

  final _contractNoController = TextEditingController();
  final _anzDateController = TextEditingController();
  final _anzDateFController = TextEditingController();
  final _anzDateTController = TextEditingController();
  final _comNoController = TextEditingController();
  final _comNameController = TextEditingController();
  final _comTelController = TextEditingController();
  final _comHpController = TextEditingController();
  final _comCeoNameController = TextEditingController();
  final _custComNoController = TextEditingController();
  final _custComNameController = TextEditingController();
  final _custTelController = TextEditingController();
  final _cuGongNameController = TextEditingController();
  final _anzCuConfirmTelController = TextEditingController();

  // 공급자 소유 설비
  final _cylController = TextEditingController();
  final _cylMemoController = TextEditingController();
  final _meterController = TextEditingController();
  final _meterMemoController = TextEditingController();
  final _transController = TextEditingController();
  final _transMemoController = TextEditingController();
  final _vaporController = TextEditingController();
  final _vaporMemoController = TextEditingController();
  final _pipeController = TextEditingController();
  final _pipeMemoController = TextEditingController();
  final _facilityController = TextEditingController();

  // 소비자 불만신고 센터
  final _centerSiController = TextEditingController();
  final _centerConsumerController = TextEditingController();
  final _centerKgsController = TextEditingController();
  final _centerGasController = TextEditingController();

  String _saleType = '';
  String _contType = '';
  int _contractPeriodIndex = 0; // 계약기간 스피너 (0=1년, 1=2년, ...)
  bool _loaded = false;

  // 저장 시 사용할 주소/공급관리번호 (UI에 표시하지 않지만 데이터 유지)
  String _cuAddr1 = '';
  String _cuAddr2 = '';
  String _cuGongNo = '';

  static const _contractPeriodOptions = ['1년', '2년', '3년', '4년', '5년'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _anzSno = widget.anzSno;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) { _loaded = true; _loadData(); }
  }

  Future<void> _loadData() async {
    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final cuCode = widget.customer.cuCode ?? '';

    Map<String, dynamic> resp;
    try {
      if (_anzSno != null && _anzSno!.isNotEmpty) {
        resp = await NetHelper.api.safetyCheckContract(areaCode, cuCode, _anzSno!);
      } else {
        resp = await NetHelper.api.safetyCheckContractLast(areaCode, cuCode);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _isNew = true; });
      _setDefaults();
      return;
    }
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (resp['resultCode'] == 0 && resp['resultData'] != null) {
      final resultData = resp['resultData'];
      final dataList = resultData['data'];
      final sign = resultData['sign']?.toString();
      final sign1 = resultData['sign1']?.toString();
      if (dataList is List && dataList.isNotEmpty) {
        final d = SafetyCheckContractResultData.fromJson(dataList.first);
        _anzSno = d.anzSno;
        _pdfFileUrl = d.contFileUrl;
        _signatureCustomer = sign;
        _signatureSupplier = sign1;
        _populateFields(d);
      } else {
        _isNew = true;
        _setDefaults();
      }
    } else {
      _isNew = true;
      _setDefaults();
    }
    setState(() {});
  }

  void _populateFields(SafetyCheckContractResultData d) {
    _contractNoController.text = d.cuGongNo ?? '';
    _anzDateController.text = DateUtil.toDisplay(d.anzDate ?? '');
    _anzDateFController.text = DateUtil.toDisplay(d.anzDateF ?? '');
    _anzDateTController.text = DateUtil.toDisplay(d.anzDateT ?? '');
    _comNoController.text = d.comNo ?? '';
    _comNameController.text = d.comName ?? '';
    _comTelController.text = d.comTel ?? '';
    _comHpController.text = d.comHp ?? '';
    _comCeoNameController.text = d.comCeoName ?? '';
    _custComNoController.text = d.custComNo ?? '';
    _custComNameController.text = d.custComName ?? '';
    _custTelController.text = d.custTel ?? '';
    _cuGongNameController.text = d.cuGongName ?? '';
    _anzCuConfirmTelController.text = d.anzCuConfirmTel ?? '';
    _cylController.text = d.useCyl ?? '';
    _cylMemoController.text = d.useCylMemo ?? '';
    _meterController.text = d.useMeter ?? '';
    _meterMemoController.text = d.useMeterMemo ?? '';
    _transController.text = d.useTrans ?? '';
    _transMemoController.text = d.useTransMemo ?? '';
    _vaporController.text = d.useVapor ?? '';
    _vaporMemoController.text = d.useVaporMemo ?? '';
    _pipeController.text = d.usePipe ?? '';
    _pipeMemoController.text = d.usePipeMemo ?? '';
    _facilityController.text = d.useFacility ?? '';
    _centerSiController.text = d.centerSi ?? '';
    _centerConsumerController.text = d.centerConsumer ?? '';
    _centerKgsController.text = d.centerKgs ?? '';
    _centerGasController.text = d.centerGas ?? '';
    _saleType = d.saleType ?? '';
    _contType = d.contType ?? '';
    _cuAddr1 = d.cuAddr1 ?? '';
    _cuAddr2 = d.cuAddr2 ?? '';
    _cuGongNo = d.cuGongNo ?? '';
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
    _anzDateFController.text = DateUtil.toDisplay(DateUtil.today());
    _anzDateTController.text = DateUtil.toDisplay(DateUtil.afterDays(365));
    _cuAddr1 = widget.customer.cuAddr1 ?? '';
    _cuAddr2 = widget.customer.cuAddr2 ?? '';
    _cuGongNo = widget.customer.cuGongNo ?? '';
    _cuGongNameController.text = widget.customer.cuGongName ?? '';
    _custTelController.text = widget.customer.cuTel ?? '';
    _anzCuConfirmTelController.text = widget.customer.cuHp ?? '';
  }

  String _ensureDate(String displayDate, String fallback) {
    final converted = DateUtil.fromDisplay(displayDate);
    if (converted.isEmpty || converted.length < 8) return fallback;
    return converted;
  }

  /// 계약기간 스피너 변경 시 종료일 자동 계산
  void _onContractPeriodChanged(int index) {
    setState(() => _contractPeriodIndex = index);
    final startText = _anzDateFController.text;
    if (startText.isEmpty) return;
    try {
      final parts = startText.split('-');
      if (parts.length != 3) return;
      final startDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final years = index + 1;
      final endDate = DateTime(startDate.year + years, startDate.month, startDate.day);
      _anzDateTController.text = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    } catch (_) {}
  }

  Future<void> _save({bool sendSMS = false}) async {
    final custSign = _signatureCustomer ?? '';
    final comSign = _signatureSupplier ?? '';

    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}

    // ─── 1. 클라이언트에서 PDF 생성 ───
    String pdfUrl = _pdfFileUrl ?? '';
    try {
      final pdfData = ContractPdfData(
        comNo: _comNoController.text,
        comName: _comNameController.text,
        comTel: _comTelController.text,
        comHp: _comHpController.text,
        comCeoName: _comCeoNameController.text,
        custComNo: _custComNoController.text,
        custComName: _custComNameController.text,
        custTel: _custTelController.text,
        cuGongName: _cuGongNameController.text,
        cuAddr1: _cuAddr1,
        cuAddr2: _cuAddr2,
        cuGongNo: _cuGongNo.isNotEmpty ? _cuGongNo : _contractNoController.text,
        anzDate: _ensureDate(_anzDateController.text, DateUtil.today()),
        anzDateF: _ensureDate(_anzDateFController.text, DateUtil.today()),
        anzDateT: _ensureDate(_anzDateTController.text, DateUtil.afterDays(365)),
        saleType: _saleType,
        contType: _contType,
        useCyl: _cylController.text,
        useMeter: _meterController.text,
        useTrans: _transController.text,
        useVapor: _vaporController.text,
        usePipe: _pipeController.text,
        useFacility: _facilityController.text,
        centerSi: _centerSiController.text,
        centerConsumer: _centerConsumerController.text,
        centerKgs: _centerKgsController.text,
        centerGas: _centerGasController.text,
        supplierSign: comSign.isNotEmpty ? comSign : null,
        customerSign: custSign.isNotEmpty ? custSign : null,
      );

      final pdfBytes = await ContractPdfService.generate(pdfData);
      final filename = _generatePdfFilename();

      // ─── 2. PDF 서버 업로드 ───
      final uploadResp = await NetHelper.api.uploadContractPdf(pdfBytes, filename);
      if (uploadResp['resultCode'] == 0 && uploadResp['resultData'] != null) {
        pdfUrl = uploadResp['resultData']['url'] ?? pdfUrl;
        _pdfFileUrl = pdfUrl;
      }
    } catch (e) {
      debugPrint('[PDF] 생성/업로드 실패: $e');
      // PDF 실패해도 계약 저장은 계속 진행
    }

    // ─── 3. 계약 데이터 저장 ───
    final req = {
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': widget.customer.cuCode,
      'ANZ_Sno': _isNew ? '' : (_anzSno ?? ''),
      'ANZ_Date': _ensureDate(_anzDateController.text, DateUtil.today()),
      'ANZ_Date_F': _ensureDate(_anzDateFController.text, DateUtil.today()),
      'ANZ_Date_T': _ensureDate(_anzDateTController.text, DateUtil.afterDays(365)),
      'SALE_TYPE': _saleType,
      'CONT_TYPE': _contType,
      'USE_CYL': _cylController.text, 'USE_CYL_MEMO': _cylMemoController.text,
      'USE_METER': _meterController.text, 'USE_METER_MEMO': _meterMemoController.text,
      'USE_TRANS': _transController.text, 'USE_TRANS_MEMO': _transMemoController.text,
      'USE_VAPOR': _vaporController.text, 'USE_VAPOR_MEMO': _vaporMemoController.text,
      'USE_PIPE': _pipeController.text, 'USE_PIPE_MEMO': _pipeMemoController.text,
      'USE_Facility': _facilityController.text,
      'CENTER_SI': _centerSiController.text, 'CENTER_Consumer': _centerConsumerController.text,
      'CENTER_KGS': _centerKgsController.text, 'CENTER_GAS': _centerGasController.text,
      'COM_BEFORE': '',
      'COM_NO': _comNoController.text,
      'COM_NAME': _comNameController.text,
      'COM_TEL': _comTelController.text,
      'COM_HP': _comHpController.text,
      'COM_CEO_NAME': _comCeoNameController.text,
      'COM_SIGN_YN': comSign.isNotEmpty ? Keys.y : Keys.n,
      'CU_GONGNO': _cuGongNo.isNotEmpty ? _cuGongNo : _contractNoController.text,
      'CUST_COM_NO': _custComNoController.text,
      'CUST_COM_NAME': _custComNameController.text,
      'CU_ADDR1': _cuAddr1,
      'CU_ADDR2': _cuAddr2,
      'CUST_TEL': _custTelController.text,
      'CU_GONGNAME': _cuGongNameController.text,
      'CUST_SIGN': custSign.isNotEmpty ? Keys.y : Keys.n,
      'CONT_FILE_URL': pdfUrl,
      'ANZ_CU_Confirm_TEL': _anzCuConfirmTelController.text,
      'ANZ_CU_SMS_YN': sendSMS ? Keys.y : Keys.n,
      'REG_DT': '', 'REG_USER_ID': AppState.loginUserId,
      'REG_SW_CODE': AppState.safeSwCode, 'REG_SW_NAME': AppState.safeSwName,
      'USERNO': '',
      'GPS_X': pos?.longitude.toString() ?? '',
      'GPS_Y': pos?.latitude.toString() ?? '',
      'ANZ_Sign': custSign,
      'ANZ_Sign_C': comSign,
      'REG_TYPE': '',
    };

    if (!mounted) return;
    final resp = await NetHelper.request(context,
      () => _isNew ? NetHelper.api.safetyCheckContractInsert(req, useLong: true)
                    : NetHelper.api.safetyCheckContractUpdate(req, useLong: true));
    if (!mounted) return;

    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: _isNew ? '저장되었습니다.' : '수정되었습니다.');
      final rd = resp['resultData'];
      if (rd != null) {
        if (rd['po_ANZ_Sno'] != null) { _anzSno = rd['po_ANZ_Sno'].toString(); _isNew = false; }
        // 서버에서 URL 반환하면 사용, 아니면 클라이언트에서 생성한 URL 유지
        if (rd['po_CONT_FILE_URL'] != null && rd['po_CONT_FILE_URL'].toString().trim().isNotEmpty) {
          _pdfFileUrl = rd['po_CONT_FILE_URL'].toString();
        }
        if (rd['CONT_FILE_URL'] != null && rd['CONT_FILE_URL'].toString().trim().isNotEmpty) {
          _pdfFileUrl = rd['CONT_FILE_URL'].toString();
        }
      }
      if (sendSMS) {
        final contractUrl = await _resolveContractFileUrl(req);
        await _sendSMS(contractUrl: contractUrl);
      }
      setState(() {});
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  String _generatePdfFilename() {
    final now = DateTime.now();
    final ts = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
               '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}'
               '${now.second.toString().padLeft(2, '0')}';
    final cuCode = widget.customer.cuCode ?? 'unknown';
    return 'contract_${cuCode}_$ts';
  }

  Future<String?> _resolveContractFileUrl(Map<String, dynamic> req) async {
    String? contractUrl = _pdfFileUrl?.trim();
    if (contractUrl != null && contractUrl.isNotEmpty) return contractUrl;

    final reqUrl = req['CONT_FILE_URL']?.toString().trim();
    if (reqUrl != null && reqUrl.isNotEmpty) {
      _pdfFileUrl = reqUrl;
      return reqUrl;
    }

    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final cuCode = widget.customer.cuCode ?? '';
    final sno = (_anzSno ?? '').trim();
    if (sno.isEmpty) return null;

    try {
      final contractResp = await NetHelper.api.safetyCheckContract(areaCode, cuCode, sno);
      if (NetHelper.isSuccess(contractResp) && contractResp['resultData'] != null) {
        final resultData = contractResp['resultData'];
        final dataList = resultData['data'];
        if (dataList is List && dataList.isNotEmpty) {
          final first = dataList.first;
          if (first is Map) {
            final url = (first['CONT_FILE_URL'] ?? '').toString().trim();
            if (url.isNotEmpty) {
              _pdfFileUrl = url;
              return url;
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  String _replaceTemplateTokens(String message, List<String> keys, String value) {
    var result = message;
    for (final key in keys) {
      final escaped = RegExp.escape(key);
      result = result.replaceAll(
        RegExp('\\{\\s*$escaped\\s*\\}', caseSensitive: false),
        value,
      );
      result = result.replaceAll(
        RegExp('\\[\\s*$escaped\\s*\\]', caseSensitive: false),
        value,
      );
    }
    return result;
  }

  Future<void> _sendSMS({String? contractUrl}) async {
    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final normalizedContractUrl = (contractUrl ?? _pdfFileUrl ?? '').trim();
    final gUrl = normalizedContractUrl.isEmpty
        ? ''
        : 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(normalizedContractUrl)}';
    final customerName =
        (widget.customer.cuNameView ?? widget.customer.cuName ?? '').trim();
    final contractName = _cuGongNameController.text.trim().isNotEmpty
        ? _cuGongNameController.text.trim()
        : customerName;
    final address = '$_cuAddr1 $_cuAddr2'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final smsResp = await NetHelper.api.safetySms(
      areaCode,
      Keys.smsDivContract,
      extraQuery: {
        if (normalizedContractUrl.isNotEmpty) 'cont_file_url': normalizedContractUrl,
        if (gUrl.isNotEmpty) 'preview_url': gUrl,
        if ((widget.customer.cuCode ?? '').trim().isNotEmpty) 'anz_cu_code': (widget.customer.cuCode ?? '').trim(),
        if ((_anzSno ?? '').trim().isNotEmpty) 'anz_sno': (_anzSno ?? '').trim(),
        if (_comNameController.text.trim().isNotEmpty) 'supplier_name': _comNameController.text.trim(),
        if (customerName.isNotEmpty) 'customer_name': customerName,
        if (contractName.isNotEmpty) 'contract_name': contractName,
        if (address.isNotEmpty) 'address': address,
        if (AppState.safeSwName.trim().isNotEmpty) 'inspector_name': AppState.safeSwName.trim(),
        if (_anzDateController.text.trim().isNotEmpty) 'contract_date': _anzDateController.text.trim(),
      },
    );
    String smsMsg = '';
    if (NetHelper.isSuccess(smsResp) && smsResp['resultData'] != null) {
      smsMsg = smsResp['resultData']['SMS_Msg']?.toString() ?? '';
    }
    smsMsg = _replaceTemplateTokens(smsMsg, ['공급자상호'], _comNameController.text);
    smsMsg = _replaceTemplateTokens(smsMsg, ['거래처명', '고객명'], customerName);
    smsMsg = _replaceTemplateTokens(smsMsg, ['계약자명', '계약자'], contractName);
    smsMsg = _replaceTemplateTokens(smsMsg, ['영업소코드'], areaCode);
    smsMsg = _replaceTemplateTokens(smsMsg, ['거래처코드'], widget.customer.cuCode ?? '');
    smsMsg = _replaceTemplateTokens(smsMsg, ['주소', '거래처주소'], address);
    smsMsg = _replaceTemplateTokens(smsMsg, ['계약일'], _anzDateController.text);
    smsMsg = _replaceTemplateTokens(smsMsg, ['점검자', '점검원'], AppState.safeSwName);
    smsMsg = _replaceTemplateTokens(
      smsMsg,
      [
        'CONT_FILE_URL',
        'PDF_URL',
        'DOWNLOAD_URL',
        'download_url',
        'cont_file_url',
        '계약서URL',
        '계약서링크',
        '계약서다운로드링크',
        '다운로드링크',
        '다운로드 링크',
        '다운링크',
      ],
      normalizedContractUrl,
    );
    smsMsg = _replaceTemplateTokens(
      smsMsg,
      ['앱없이보기', '앱없이 보기', '미리보기링크', '미리보기 링크', 'preview_url'],
      gUrl,
    );
    if (normalizedContractUrl.isNotEmpty &&
        !smsMsg.contains(normalizedContractUrl) &&
        !smsMsg.contains(gUrl)) {
      smsMsg += '\n\n[가스안전점검표]\n다운로드: $normalizedContractUrl\n앱 없이 보기: $gUrl';
    }
    final tel = _anzCuConfirmTelController.text.trim();
    if (tel.isEmpty) { Fluttertoast.showToast(msg: '확인 연락처를 입력해주세요.'); return; }
    final uri = Uri(scheme: 'sms', path: tel, queryParameters: {'body': smsMsg});
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
  }

  void _showSignatureDialog({required String title, required String? initial, required ValueChanged<String?> onSave}) {
    final padKey = GlobalKey<SignaturePadState>();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      content: SizedBox(width: 300, child: Column(mainAxisSize: MainAxisSize.min, children: [
        SignaturePad(key: padKey, initialSignature: initial, canWrite: true),
        const SizedBox(height: 8),
        const Text('위 영역에 서명해주세요.', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ])),
      actions: [
        TextButton(onPressed: () { padKey.currentState?.clear(); }, child: const Text('지우기', style: TextStyle(color: Colors.orange))),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
        TextButton(onPressed: () async {
          final data = await padKey.currentState?.toBase64();
          onSave(data);
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('저장')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return Center(child: LogoLoader(size: 100));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Text('공급계약', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCustomerCard(),
                const SizedBox(height: 8),
                _buildBaseInfo(),
                const SizedBox(height: 8),
                _buildContractContentToggle(),
                const SizedBox(height: 8),
                _buildSupplierEquipSection(),
                const SizedBox(height: 8),
                _buildComplaintCenterSection(),
                const SizedBox(height: 8),
                _buildSupplierSection(),
                const SizedBox(height: 8),
                _buildCustomerSection(),
                const SizedBox(height: 8),
                // SMS번호 (고객 섹션 바깥 - Kotlin과 동일)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _fieldRow('SMS번호', Expanded(child: _miniInput(_anzCuConfirmTelController, type: TextInputType.phone))),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 고객 정보 카드 - Kotlin과 동일 (이름, 주소+GPS, 전화, 담당사원)
  Widget _buildCustomerCard() {
    final c = widget.customer;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.cuNameView ?? c.cuName ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(child: Text(c.cuAddr ?? '${c.cuAddr1 ?? ''} ${c.cuAddr2 ?? ''}'.trim(), style: const TextStyle(fontSize: 13))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(c.cuTel ?? c.cuHp ?? '', style: const TextStyle(fontSize: 13)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.local_shipping, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(c.cuSwName ?? '', style: const TextStyle(fontSize: 13)),
          ]),
        ],
      ),
    );
  }

  /// 기본 정보 - Kotlin과 동일 (계약번호, 계약일자, 계약기간 스피너, 계약기간 날짜, 판매방법, 거래현황)
  Widget _buildBaseInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 계약번호
          _fieldRow('계약번호', SizedBox(width: 100, child: _miniInput(_contractNoController)), isLabel: true, labelColor: Colors.orange.shade800),
          const SizedBox(height: 8),
          // 계약일자 + 계약기간 스피너 (신규일 때만 표시 - Kotlin과 동일)
          Row(
            children: [
              const SizedBox(width: 70, child: Text('계약일자', style: TextStyle(fontSize: 13, color: Colors.black87))),
              SizedBox(width: 100, child: _dateInput(_anzDateController)),
              if (_isNew || _anzSno == null) ...[
                const SizedBox(width: 12),
                const Text('계약기간', style: TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(width: 8),
                _miniDropdown(
                  value: _contractPeriodOptions[_contractPeriodIndex],
                  items: _contractPeriodOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) {
                    if (v != null) _onContractPeriodChanged(_contractPeriodOptions.indexOf(v));
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // 계약기간 날짜
          _fieldRow('계약기간', Row(children: [
            SizedBox(width: 100, child: _dateInput(_anzDateFController)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('~')),
            SizedBox(width: 100, child: _dateInput(_anzDateTController)),
          ])),
          const SizedBox(height: 8),
          // 판매방법
          _fieldRow('판매방법', _miniDropdown(
            value: ['1', '2'].contains(_saleType) ? _saleType : '1',
            items: const [
              DropdownMenuItem(value: '1', child: Text('중량', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: '2', child: Text('체적', style: TextStyle(fontSize: 13))),
            ],
            onChanged: (v) => setState(() => _saleType = v ?? '1'),
          )),
          const SizedBox(height: 8),
          // 거래현황
          _fieldRow('거래현황', _miniDropdown(
            value: ['1', '2'].contains(_contType) ? _contType : '1',
            items: const [
              DropdownMenuItem(value: '1', child: Text('신규', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: '2', child: Text('재계약', style: TextStyle(fontSize: 13))),
            ],
            onChanged: (v) => setState(() => _contType = v ?? '1'),
          )),
        ],
      ),
    );
  }

  Widget _fieldRow(String label, Widget child, {bool isLabel = false, Color? labelColor}) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: TextStyle(fontSize: 13, color: labelColor ?? Colors.black87))),
        child,
      ],
    );
  }

  Widget _miniInput(TextEditingController ctrl, {TextInputType type = TextInputType.text}) {
    return AppInput(controller: ctrl, keyboardType: type);
  }

  Widget _dateInput(TextEditingController ctrl) {
    return AppInput(controller: ctrl, readOnly: true, onTap: () => _pickDate(ctrl));
  }

  Widget _miniDropdown({String? value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: AppInput.height, width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(value: value, items: items, onChanged: onChanged, isDense: true, isExpanded: true,
            style: const TextStyle(fontSize: 13, color: Colors.black87), icon: const Icon(Icons.arrow_drop_down, size: 18)),
      ),
    );
  }

  // ── 공급계약 내용 (11개 항목) ──

  static const _contractTitles = [
    '가스의 전달방법',
    '가스의 계량방법과 가스요금',
    '공급설비와 소비설비에 대한 비용부담 등',
    '계약기간',
    '계약의 해지',
    '공급설비와 소비설비의 관리방법',
    '가스안전 계도물',
    '안전책임에 관한 사항',
    '소비자 보장책임보험 가입 확인',
    '긴급 시 연락처',
    '소비자 불편신고',
  ];

  static const _contractContents = [
    '당사는 액화석유가스(LPG)가 충전된 용기를 가스사용에 지장이 없도록, 계획된 배달날짜 또는 고객이 주문할 때마다 신속히 배달하겠으며, 사용시설에 직접 연결하여 드립니다. 다만, 체적으로 판매할 경우에는 사용중인 용기 안에 있는 가스가 떨어지면 자동적으로 다른 용기에서 가스가 공급될 수 있도록 항상 충전된 예비용기를 연결하여 드리겠습니다.',
    '가스의 계량방법과 소비설비에 대한 비용부담 등,\n1. 체적(계량기로 계량함)으로 판매할 경우\n가. 가스요금은 매월 계량기에 의해 검침된 사용량에 단위요금(원/㎥)을 곱하여 산정합니다.\n나. 단위요금은 당사(점)가 산업통상자원부에 신고한 가격표에 의합니다.',
    '공급설비와 소비설비에 대한 비용부담 등,\n1. 공급설비와 소비설비의 설치·변경 등의 비용부담 방법은 다음과 같습니다.\n가. 공급설비: 당사(점) 부담\n나. 소비설비: 고객 부담',
    '이 계약의 유효기간은 계약시작일부터 계약종료일까지로 하고, 당사(점)는 계약만료일 15일 전에 고객에게 계약만료를 알리며, 고객이 계약만료일 전에 계약해지를 알리지 않은 경우 계약기간은 6개월씩 연장됩니다.\n\n※ 계약기간: 체적판매방법으로 공급하는 경우 최초의 안전공급계약은 1년(주택의 경우에는 2년) 이상으로 합니다.',
    '고객이 당사(점)와 계약한 안전공급계약의 해지를 요청할 경우 당사(점)는 5일 이내에 고객과 가스요금 등을 정산 및 납부하고 계약을 해지하여야 하며, 다음의 방법에 따라야 합니다.\n1. 계약기간이 만료되어 고객이 계약해지를 요구하는 경우 당사(점)는 그 설비를 철거하거나 고객이 원하는 새로운 가스공급자에게 양도양수합니다.',
    '1. 공급설비에 대해서는, 당사(점)가 법규에서 정하는 바에 따라 설비의 유지·관리를 위한 점검을 합니다.\n2. 소비설비에 대해서는, 당사(점)가 법규에서 정하는 바에 따라 점검을 실시하나, 일상의 관리는 「가스안전 계도물」 등을 참고하여 관리하여 주시기 바랍니다.',
    '당사(점)는 액화석유가스의 안전사용을 위한 주의사항을 적은 서면을 6개월에 1회 이상 전달하겠으며, 고객은 반드시 그 내용을 확인하고, 가스를 안전하게 사용하시기 바랍니다.',
    '1. 고객의 안전책임\n가. 고객은 가스를 사용할 때 이 계약서와 가스안전 계도물에 적힌 안전에 관한 주의사항을 준수해야 합니다.\n나. 고객은 가스시설의 설치·변경·수리 또는 철거를 직접 하여서는 안 됩니다.',
    '당사(점)는 가스사고를 대비하여 소비자보장책임보험에 가입하였고, 가스사용 중 불의의 가스사고로 피해가 발생한 경우에는 고객은 사망(후유장애 포함)의 경우 1명당 8천만원, 부상의 경우 1명당 1천5백만원, 재산피해의 경우 3억원의 범위에서 피해보상을 받으실 수 있습니다.',
    '1. 당사(점)는 재해가 발생하거나 발생할 우려가 있을 경우에 대비해 24시간 체제를 유지해야 하고, 고객은 긴급 시 아래의 연락처로 전화하여 주시기 바랍니다.\n2. 긴급 시에는 다음의 조치를 하여 주시기 바랍니다.\n가. 가스가 누출되면 즉시 밸브를 잠그고 창문을 열어 환기시킵니다.\n나. 전기 스위치를 만지지 마십시오.',
    '부당요금 징수, 가스공급 지연, 서비스 불이행 등 소비자불편사항이 발생한 경우에는 소비자불만신고센터로 전화하여 주시기 바랍니다.',
  ];

  void _showContractDetailPopup(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_contractTitles[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Text(_contractContents[index], style: const TextStyle(fontSize: 14, height: 1.6)),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF555555)),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 공급계약 내용 토글 ──
  Widget _buildContractContentToggle() {
    return _buildToggleSection(
      title: '공급계약 내용',
      isExpanded: _contractContentExpanded,
      onToggle: () => setState(() => _contractContentExpanded = !_contractContentExpanded),
      headerColor: Colors.black87,
      headerTextColor: Colors.white,
      child: Column(
        children: List.generate(_contractTitles.length, (i) => Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(_contractTitles[i], style: const TextStyle(fontSize: 13)),
            trailing: Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade500),
            onTap: () => _showContractDetailPopup(i),
          ),
        )),
      ),
    );
  }

  // ── 공급자 소유 설비 ──
  Widget _buildSupplierEquipSection() {
    return _buildToggleSection(
      title: '공급자 소유 설비',
      isExpanded: _supplierEquipExpanded,
      onToggle: () => setState(() => _supplierEquipExpanded = !_supplierEquipExpanded),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _equipRow('용기', _cylController, _cylMemoController),
            _equipRow('계량기', _meterController, _meterMemoController),
            _equipRow('절체기', _transController, _transMemoController),
            _equipRow('기화기', _vaporController, _vaporMemoController),
            _equipRow('공급관', _pipeController, _pipeMemoController),
            const SizedBox(height: 6),
            const Text('부속설비', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Container(
              height: 60,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
              child: TextField(
                controller: _facilityController,
                maxLines: 3,
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8), isDense: true),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _equipRow(String label, TextEditingController qtyCtrl, TextEditingController memoCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 55, child: Text(label, style: const TextStyle(fontSize: 12))),
          SizedBox(width: 60, child: AppInput(controller: qtyCtrl, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          const Text('비고:', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(width: 4),
          Expanded(child: AppInput(controller: memoCtrl)),
        ],
      ),
    );
  }

  // ── 소비자 불만신고 센터 ──
  Widget _buildComplaintCenterSection() {
    return _buildToggleSection(
      title: '소비자 불만신고 센터',
      isExpanded: _complaintCenterExpanded,
      onToggle: () => setState(() => _complaintCenterExpanded = !_complaintCenterExpanded),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _formField('시.군.구청', _centerSiController),
            _formField('소비자단체', _centerConsumerController),
            _formField('한국가스공사', _centerKgsController),
            _formField('가스공급자단체', _centerGasController),
          ],
        ),
      ),
    );
  }

  // ── 공급자 (Kotlin과 동일: 사업자번호, 상호, 전화, 긴급연락처, 대표자 + 서명) ──
  Widget _buildSupplierSection() {
    final hasSign = _signatureSupplier != null && _signatureSupplier!.isNotEmpty;
    return _buildToggleSection(
      title: '공급자',
      isExpanded: _supplierExpanded,
      onToggle: () => setState(() => _supplierExpanded = !_supplierExpanded),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formField('사업자번호', _comNoController),
            _formField('상호', _comNameController),
            _formField('전화', _comTelController, type: TextInputType.phone),
            _formField('긴급연락처', _comHpController, type: TextInputType.phone),
            _formField('대표자', _comCeoNameController),
            const SizedBox(height: 8),
            _signatureRow('대표자 서명', hasSign, () => _showSignatureDialog(
              title: '공급자 서명', initial: _signatureSupplier,
              onSave: (d) => setState(() => _signatureSupplier = d),
            )),
            if (hasSign) SignaturePad(key: ValueKey(_signatureSupplier), initialSignature: _signatureSupplier, canWrite: false),
          ],
        ),
      ),
    );
  }

  // ── 고객 (Kotlin과 동일: 사업자번호, 상호, 전화, 고객서명 + 서명) ──
  Widget _buildCustomerSection() {
    final hasSign = _signatureCustomer != null && _signatureCustomer!.isNotEmpty;
    return _buildToggleSection(
      title: '고객',
      isExpanded: _customerExpanded,
      onToggle: () => setState(() => _customerExpanded = !_customerExpanded),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formField('사업자번호', _custComNoController),
            _formField('상호', _custComNameController),
            _formField('전화', _custTelController, type: TextInputType.phone),
            _formField('고객서명', _cuGongNameController),
            const SizedBox(height: 8),
            _signatureRow('고객 서명', hasSign, () => _showSignatureDialog(
              title: '고객 서명', initial: _signatureCustomer,
              onSave: (d) => setState(() => _signatureCustomer = d),
            )),
            if (hasSign) SignaturePad(key: ValueKey(_signatureCustomer), initialSignature: _signatureCustomer, canWrite: false),
          ],
        ),
      ),
    );
  }

  // ── 공통 토글 섹션 위젯 ──
  Widget _buildToggleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    Color headerColor = const Color(0xFFEEEEEE),
    Color headerTextColor = Colors.black87,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(4),
                  bottom: Radius.circular(isExpanded ? 0 : 4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: headerTextColor))),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: headerTextColor, size: 20),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 85, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(child: AppInput(controller: ctrl, keyboardType: type)),
        ],
      ),
    );
  }

  Widget _signatureRow(String title, bool hasSign, VoidCallback onTap) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (hasSign) Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
          child: const Text('완료', style: TextStyle(fontSize: 10, color: Colors.green)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(4)),
            child: Text(hasSign ? '확인' : '서명', style: const TextStyle(fontSize: 11, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
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
        ],
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
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await CommonWidgets.showKoreanDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _contractNoController.dispose();
    _anzDateController.dispose(); _anzDateFController.dispose(); _anzDateTController.dispose();
    _comNoController.dispose(); _comNameController.dispose(); _comTelController.dispose();
    _comHpController.dispose(); _comCeoNameController.dispose();
    _custComNoController.dispose(); _custComNameController.dispose(); _custTelController.dispose();
    _cuGongNameController.dispose(); _anzCuConfirmTelController.dispose();
    _cylController.dispose(); _cylMemoController.dispose();
    _meterController.dispose(); _meterMemoController.dispose();
    _transController.dispose(); _transMemoController.dispose();
    _vaporController.dispose(); _vaporMemoController.dispose();
    _pipeController.dispose(); _pipeMemoController.dispose();
    _facilityController.dispose();
    _centerSiController.dispose(); _centerConsumerController.dispose();
    _centerKgsController.dispose(); _centerGasController.dispose();
    super.dispose();
  }
}
