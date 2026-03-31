import '../../widgets/logo_loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_check_contract_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';
import '../../widgets/signature_pad.dart';

class SafetyContractTab extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final String? anzSno;

  const SafetyContractTab({super.key, required this.customer, this.anzSno});

  @override
  State<SafetyContractTab> createState() => _SafetyContractTabState();
}

class _SafetyContractTabState extends State<SafetyContractTab> with AutomaticKeepAliveClientMixin {
  SafetyCheckContractResultData? _data;
  bool _isLoading = true;
  bool _isNew = false;
  String? _anzSno;
  String? _pdfFileUrl;
  bool _contractContentExpanded = true;

  String? _signatureCustomer;
  String? _signatureSupplier;
  final _custSignKey = GlobalKey<SignaturePadState>();
  final _comSignKey = GlobalKey<SignaturePadState>();

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
  final _cuAddr1Controller = TextEditingController();
  final _cuAddr2Controller = TextEditingController();
  final _cuGongNameController = TextEditingController();
  final _cuGongNoController = TextEditingController();
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
  bool _loaded = false;

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
        _data = d;
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
    _cuAddr1Controller.text = d.cuAddr1 ?? '';
    _cuAddr2Controller.text = d.cuAddr2 ?? '';
    _cuGongNameController.text = d.cuGongName ?? '';
    _cuGongNoController.text = d.cuGongNo ?? '';
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
  }

  void _setDefaults() {
    _anzDateController.text = DateUtil.toDisplay(DateUtil.today());
    _anzDateFController.text = DateUtil.toDisplay(DateUtil.today());
    _anzDateTController.text = DateUtil.toDisplay(DateUtil.afterDays(365));
    _cuAddr1Controller.text = widget.customer.cuAddr1 ?? '';
    _cuAddr2Controller.text = widget.customer.cuAddr2 ?? '';
    _cuGongNameController.text = widget.customer.cuGongName ?? '';
    _cuGongNoController.text = widget.customer.cuGongNo ?? '';
    _custTelController.text = widget.customer.cuTel ?? '';
    _anzCuConfirmTelController.text = widget.customer.cuHp ?? '';
  }

  String _ensureDate(String displayDate, String fallback) {
    final converted = DateUtil.fromDisplay(displayDate);
    if (converted.isEmpty || converted.length < 8) return fallback;
    return converted;
  }

  Future<void> _save({bool sendSMS = false}) async {
    String custSign = '';
    String comSign = '';
    if (_custSignKey.currentState != null && !_custSignKey.currentState!.isEmpty) {
      custSign = await _custSignKey.currentState!.toBase64() ?? '';
    } else if (_signatureCustomer != null) {
      custSign = _signatureCustomer!;
    }
    if (_comSignKey.currentState != null && !_comSignKey.currentState!.isEmpty) {
      comSign = await _comSignKey.currentState!.toBase64() ?? '';
    } else if (_signatureSupplier != null) {
      comSign = _signatureSupplier!;
    }

    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}

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
      'CU_GONGNO': _cuGongNoController.text,
      'CUST_COM_NO': _custComNoController.text,
      'CUST_COM_NAME': _custComNameController.text,
      'CU_ADDR1': _cuAddr1Controller.text,
      'CU_ADDR2': _cuAddr2Controller.text,
      'CUST_TEL': _custTelController.text,
      'CU_GONGNAME': _cuGongNameController.text,
      'CUST_SIGN': custSign.isNotEmpty ? Keys.y : Keys.n,
      'CONT_FILE_URL': _pdfFileUrl ?? '',
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
        if (rd['po_CONT_FILE_URL'] != null) { _pdfFileUrl = rd['po_CONT_FILE_URL'].toString(); }
      }
      if (sendSMS) _sendSMS(req);
      setState(() {});
    } else {
      NetHelper.handleError(context, resp);
    }
  }

  Future<void> _sendSMS(Map<String, dynamic> req) async {
    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final smsResp = await NetHelper.api.safetySms(areaCode, Keys.smsDivContract);
    String smsMsg = '';
    if (NetHelper.isSuccess(smsResp) && smsResp['resultData'] != null) {
      smsMsg = smsResp['resultData']['SMS_Msg']?.toString() ?? '';
    }
    smsMsg = smsMsg
        .replaceAll('{공급자상호}', _comNameController.text)
        .replaceAll('{거래처명}', widget.customer.cuNameView ?? widget.customer.cuName ?? '')
        .replaceAll('{영업소코드}', areaCode)
        .replaceAll('{거래처코드}', widget.customer.cuCode ?? '')
        .replaceAll('{주소}', '${_cuAddr1Controller.text} ${_cuAddr2Controller.text}')
        .replaceAll('{계약일}', _anzDateController.text)
        .replaceAll('{점검자}', AppState.safeSwName);
    if (_pdfFileUrl != null && _pdfFileUrl!.isNotEmpty) {
      final gUrl = 'https://docs.google.com/gview?embedded=true&url=$_pdfFileUrl';
      smsMsg += '\n\n[가스안전점검표]\n다운로드: $_pdfFileUrl\n앱 없이 보기: $gUrl';
    }
    final tel = _anzCuConfirmTelController.text.trim();
    if (tel.isEmpty) { Fluttertoast.showToast(msg: '확인 연락처를 입력해주세요.'); return; }
    final uri = Uri(scheme: 'sms', path: tel, queryParameters: {'body': smsMsg});
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
  }

  Future<void> _delete() async {
    if (_isNew || _anzSno == null) return;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('삭제'), content: const Text('삭제하시겠습니까?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (ok != true || !mounted) return;
    final resp = await NetHelper.request(context, () => NetHelper.api.safetyCheckContractDelete({
      'AREA_CODE': widget.customer.areaCode ?? AppState.areaCode,
      'ANZ_Cu_Code': widget.customer.cuCode, 'ANZ_Sno': _anzSno,
    }));
    if (!mounted) return;
    if (NetHelper.isSuccess(resp)) {
      Fluttertoast.showToast(msg: '삭제되었습니다.');
      _isNew = true; _anzSno = null; _data = null; _pdfFileUrl = null;
      _signatureCustomer = null; _signatureSupplier = null;
      _setDefaults(); setState(() {});
    } else { NetHelper.handleError(context, resp); }
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
        // 타이틀
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Text('공급계약', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 고객정보 카드
                _buildCustomerCard(),
                const SizedBox(height: 8),
                // 기본 정보
                _buildBaseInfo(),
                const SizedBox(height: 8),
                // 공급계약 내용 토글
                _buildContractContentToggle(),
                const SizedBox(height: 8),
                // 공급자 소유 설비
                _buildSupplierEquipSection(),
                const SizedBox(height: 8),
                // 소비자 불만신고 센터
                _buildComplaintCenterSection(),
                const SizedBox(height: 8),
                // 공급자 정보
                _buildSupplierSection(),
                const SizedBox(height: 8),
                // 소비자 정보
                _buildConsumerSection(),
                const SizedBox(height: 16),
                // 저장 버튼
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildBaseInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 계약번호
          _fieldRow('계약번호', SizedBox(width: 100, child: _miniInput(_contractNoController)), isLabel: true, labelColor: Colors.orange.shade800),
          const SizedBox(height: 8),
          // 계약일자
          _fieldRow('계약일자', Row(children: [
            SizedBox(width: 100, child: _dateInput(_anzDateController)),
          ])),
          const SizedBox(height: 8),
          // 계약기간
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

  Widget _miniInput(TextEditingController ctrl) {
    return Container(
      height: 32,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
      child: TextField(
        controller: ctrl,
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _dateInput(TextEditingController ctrl) {
    return GestureDetector(
      onTap: () => _pickDate(ctrl),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.centerLeft,
        child: Text(ctrl.text.isEmpty ? '-' : ctrl.text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _miniDropdown({String? value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 32, width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(value: value, items: items, onChanged: onChanged, isDense: true, isExpanded: true,
            style: const TextStyle(fontSize: 13, color: Colors.black87), icon: const Icon(Icons.arrow_drop_down, size: 18)),
      ),
    );
  }

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

  // 공급계약 내용 토글
  Widget _buildContractContentToggle() {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // 헤더 (검정 배경)
          GestureDetector(
            onTap: () => setState(() => _contractContentExpanded = !_contractContentExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: const Radius.circular(4), bottom: Radius.circular(_contractContentExpanded ? 0 : 4)),
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('공급계약 내용', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white))),
                  Icon(_contractContentExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          // 아이템
          if (_contractContentExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
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
            ),
        ],
      ),
    );
  }

  Widget _buildSupplierEquipSection() {
    return _expandableSection('공급자 소유 설비', [
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
    ]);
  }

  Widget _equipRow(String label, TextEditingController qtyCtrl, TextEditingController memoCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 55, child: Text(label, style: const TextStyle(fontSize: 12))),
          SizedBox(width: 60, child: Container(
            height: 30,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
            child: TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), isDense: true),
              style: const TextStyle(fontSize: 12),
            ),
          )),
          const SizedBox(width: 8),
          const Text('비고:', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(width: 4),
          Expanded(child: Container(
            height: 30,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
            child: TextField(
              controller: memoCtrl,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), isDense: true),
              style: const TextStyle(fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildComplaintCenterSection() {
    return _expandableSection('소비자 불만신고 센터', [
      _formField('시.군.구청', _centerSiController),
      _formField('소비자단체', _centerConsumerController),
      _formField('한국가스공사', _centerKgsController),
      _formField('가스공급자단체', _centerGasController),
    ]);
  }

  Widget _buildSupplierSection() {
    final hasSign = _signatureSupplier != null && _signatureSupplier!.isNotEmpty;
    return _expandableSection('공급자 정보', [
      _formField('사업자번호', _comNoController),
      _formField('상호', _comNameController),
      _formField('대표자', _comCeoNameController),
      _formField('전화번호', _comTelController, type: TextInputType.phone),
      _formField('휴대폰', _comHpController, type: TextInputType.phone),
      const SizedBox(height: 8),
      _signatureRow('공급자 서명', hasSign, () => _showSignatureDialog(
        title: '공급자 서명', initial: _signatureSupplier,
        onSave: (d) => setState(() => _signatureSupplier = d),
      )),
      if (hasSign) SignaturePad(key: _comSignKey, initialSignature: _signatureSupplier, canWrite: false),
    ]);
  }

  Widget _buildConsumerSection() {
    final hasSign = _signatureCustomer != null && _signatureCustomer!.isNotEmpty;
    return _expandableSection('소비자 정보', [
      _formField('공급관리번호', _cuGongNoController),
      _formField('사업자번호', _custComNoController),
      _formField('상호(성명)', _custComNameController),
      _formField('주소', _cuAddr1Controller),
      _formField('상세주소', _cuAddr2Controller),
      _formField('전화번호', _custTelController, type: TextInputType.phone),
      _formField('공급시설명', _cuGongNameController),
      _formField('확인 연락처', _anzCuConfirmTelController, type: TextInputType.phone),
      const SizedBox(height: 8),
      _signatureRow('소비자 서명', hasSign, () => _showSignatureDialog(
        title: '소비자 서명', initial: _signatureCustomer,
        onSave: (d) => setState(() => _signatureCustomer = d),
      )),
      if (hasSign) SignaturePad(key: _custSignKey, initialSignature: _signatureCustomer, canWrite: false),
    ]);
  }

  Widget _expandableSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            child: Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
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
          Expanded(child: Container(
            height: 32,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
            child: TextField(
              controller: ctrl, keyboardType: type,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true),
              style: const TextStyle(fontSize: 12),
            ),
          )),
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
            child: Text(hasSign ? '재서명' : '서명', style: const TextStyle(fontSize: 11, color: Colors.white)),
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
          if (!_isNew) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _actionBtn('삭제', Colors.red, _delete),
            ),
          ],
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
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
    _cuAddr1Controller.dispose(); _cuAddr2Controller.dispose();
    _cuGongNameController.dispose(); _cuGongNoController.dispose(); _anzCuConfirmTelController.dispose();
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
