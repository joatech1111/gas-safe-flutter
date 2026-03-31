import '../../widgets/logo_loader.dart';
import 'package:flutter/material.dart';
import '../../models/safety_customer_result_data.dart';
import '../../models/safety_history_result_data.dart';
import '../../network/net_helper.dart';
import '../../utils/app_state.dart';
import '../../utils/date_util.dart';
import '../../utils/keys.dart';
import '../../widgets/customer_edit_dialog.dart';

class SafetyHistoryTab extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final void Function(int index, {String? sno}) onTabChange;

  const SafetyHistoryTab({super.key, required this.customer, required this.onTabChange});

  @override
  State<SafetyHistoryTab> createState() => _SafetyHistoryTabState();
}

class _SafetyHistoryTabState extends State<SafetyHistoryTab> with AutomaticKeepAliveClientMixin {
  List<SafetyHistoryResultData> _historyList = [];
  bool _isLoading = true;
  bool _loaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final areaCode = widget.customer.areaCode ?? AppState.areaCode;
    final cuCode = widget.customer.cuCode ?? '';
    // Android와 동일: 오늘 날짜를 기준으로 조회
    final shDate = DateUtil.today();

    debugPrint('★★★ 점검이력 API 호출: areaCode=[$areaCode] cuCode=[$cuCode] shDate=[$shDate]');

    try {
      final resp = await NetHelper.api.safetyHistory(areaCode, cuCode, shDate);
      if (!mounted) return;

      debugPrint('★★★ 점검이력 응답: resultCode=${resp['resultCode']} result=${resp['result']}');
      debugPrint('★★★ 점검이력 resultData type=${resp['resultData']?.runtimeType}');

      setState(() => _isLoading = false);

      final resultCode = resp['resultCode'];
      if (resultCode == 0 && resp['resultData'] != null) {
        final data = resp['resultData'];
        List items;
        if (data is List) {
          items = data;
        } else if (data is Map && data['data'] != null && data['data'] is List) {
          items = data['data'];
        } else {
          items = [];
        }
        debugPrint('★★★ 점검이력 items count=${items.length}');
        setState(() {
          _historyList = items.map((e) => SafetyHistoryResultData.fromJson(e as Map<String, dynamic>)).toList();
        });
      } else {
        debugPrint('★★★ 점검이력 실패 또는 데이터 없음');
      }
    } catch (e, st) {
      debugPrint('★★★ 점검이력 예외: $e');
      debugPrint('★★★ $st');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Center(child: LogoLoader(size: 100));
    }

    return Column(
      children: [
        // 점검이력 타이틀
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Text('점검이력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        // 고객정보 카드
        _buildCustomerInfo(),
        const SizedBox(height: 8),
        // 테이블 헤더
        _buildTableHeader(),
        // 테이블 바디
        Expanded(
          child: _historyList.isEmpty
              ? const Center(child: Text('점검 이력이 없습니다.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) => _buildTableRow(_historyList[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    final c = widget.customer;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1행: 거래구분 뱃지 + 고객명 + 수정 버튼
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(c.cuTypeName ?? '', style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(c.cuNameView ?? c.cuName ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () async {
                  final updated = await CustomerEditDialog.show(context, widget.customer);
                  if (updated != null && mounted) {
                    setState(() {}); // UI 갱신
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('수정', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 2행: 계약번호 + 고객명
          Row(
            children: [
              Expanded(child: Text('계약번호 : ${c.cuGongNo ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
              Expanded(child: Text(c.cuFullName ?? c.cuName ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54))),
            ],
          ),
          const SizedBox(height: 2),
          // 3행: 계약일 + 점검일
          Row(
            children: [
              Expanded(child: Text('계약일 : ${DateUtil.toDisplay(c.cuGongDate ?? '')}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
              Expanded(child: Text('점검일: ${DateUtil.toDisplay(c.cuSafeDate ?? '')}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Row(
        children: [
          SizedBox(width: 75, child: Center(child: Text('점검구분', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
          SizedBox(width: 75, child: Center(child: Text('점검일자', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
          SizedBox(width: 60, child: Center(child: Text('점검사원', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
          Expanded(child: Center(child: Text('점검결과', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
          SizedBox(width: 35, child: Center(child: Text('서명', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildTableRow(SafetyHistoryResultData item, int index) {
    int tabIndex = 1;
    switch (item.checkType) {
      case '1': tabIndex = 1; break;
      case '2': tabIndex = 2; break;
      case '3': tabIndex = 3; break;
      case '4': tabIndex = 4; break;
    }

    // 점검일자 yy-MM-dd 형식
    String displayDate = '';
    final d = item.anzDate ?? '';
    if (d.length >= 8) {
      displayDate = '${d.substring(2, 4)}-${d.substring(4, 6)}-${d.substring(6, 8)}';
    }

    return InkWell(
      onTap: () => widget.onTabChange(tabIndex, sno: item.anzSno),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            SizedBox(width: 75, child: Center(child: Text(item.safeName ?? '', style: const TextStyle(fontSize: 11)))),
            SizedBox(width: 75, child: Center(child: Text(displayDate, style: const TextStyle(fontSize: 11)))),
            SizedBox(width: 60, child: Center(child: Text(item.anzSwName ?? '', style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))),
            Expanded(child: Center(child: Text(item.safeResultYN ?? '', style: TextStyle(fontSize: 11, color: item.safeResultYN == '적합' ? Colors.black : Colors.red)))),
            SizedBox(width: 35, child: Center(child: Text(item.anzSignYN ?? '', style: const TextStyle(fontSize: 11)))),
          ],
        ),
      ),
    );
  }
}
