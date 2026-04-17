import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kpostal/kpostal.dart';
import '../models/safety_customer_result_data.dart';
import '../models/combo_data.dart';
import '../network/net_helper.dart';
import '../utils/app_state.dart';

class CustomerEditDialog {
  static Future<SafetyCustomerResultData?> show(BuildContext context, SafetyCustomerResultData data) async {
    // 먼저 거래처 조건 조회
    final condResp = await NetHelper.request(
      context,
      () => NetHelper.api.customerSearchCondition(data.areaCode ?? AppState.areaCode),
    );

    if (!context.mounted) return null;
    if (!NetHelper.isSuccess(condResp) || condResp['resultData'] == null) {
      Fluttertoast.showToast(msg: '거래처 조건 조회에 실패했습니다.');
      return null;
    }

    final rd = condResp['resultData'];
    final cutyList = (rd['CUTY'] as List?)?.map((e) => ComboData.fromJson(e).toTrim()).toList() ?? [];
    final sobiList = (rd['SOBI'] as List?)?.map((e) => ComboData.fromJson(e).toTrim()).toList() ?? [];

    // 폼 컨트롤러
    final nameCtrl = TextEditingController(text: data.cuName ?? '');
    final userNameCtrl = TextEditingController(text: data.cuUserName ?? '');
    final telCtrl = TextEditingController(text: data.cuTel ?? '');
    final hpCtrl = TextEditingController(text: data.cuHp ?? '');
    final zipCtrl = TextEditingController(text: data.cuZipcode ?? '');
    final addr1Ctrl = TextEditingController(text: data.cuAddr1 ?? '');
    final addr2Ctrl = TextEditingController(text: data.cuAddr2 ?? '');
    final bigo1Ctrl = TextEditingController(text: data.cuBigo1 ?? '');
    final bigo2Ctrl = TextEditingController(text: data.cuBigo2 ?? '');

    String? selectedCuType = data.cuType;
    String? selectedCuCuType = data.cuCuType;

    final result = await showDialog<SafetyCustomerResultData>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            Future<void> searchAddress() async {
              final Kpostal? addressData = await Navigator.push<Kpostal>(
                ctx2,
                MaterialPageRoute(builder: (_) => KpostalView()),
              );
              if (addressData == null) return;
              setDialogState(() {
                zipCtrl.text = addressData.postCode;
                addr1Ctrl.text = addressData.address;
              });
            }

            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(child: Text('거래처 정보 수정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(4)),
                      child: const Text('닫기', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cutyList.isNotEmpty)
                        _dropdownRow('거래구분', cutyList, selectedCuType, (v) {
                          setDialogState(() => selectedCuType = v);
                        }),
                      _inputRow('상호(성명)', nameCtrl),
                      _inputRow('대표자', userNameCtrl),
                      _inputRow('전화번호', telCtrl, type: TextInputType.phone),
                      _inputRow('휴대폰', hpCtrl, type: TextInputType.phone),
                      _inputRow(
                        '우편번호',
                        zipCtrl,
                        readOnly: true,
                        actionLabel: '우편번호찾기',
                        onActionTap: searchAddress,
                      ),
                      _inputRow(
                        '주소',
                        addr1Ctrl,
                        readOnly: true,
                        onTap: searchAddress,
                      ),
                      _inputRow('상세주소', addr2Ctrl),
                      _inputRow('비고1', bigo1Ctrl),
                      _inputRow('비고2', bigo2Ctrl),
                      if (sobiList.isNotEmpty)
                        _dropdownRow('소비형태', sobiList, selectedCuCuType, (v) {
                          setDialogState(() => selectedCuCuType = v);
                        }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final req = {
                      'AREA_CODE': data.areaCode ?? AppState.areaCode,
                      'CU_CODE': data.cuCode,
                      'CU_type': selectedCuType ?? '',
                      'CU_NAME': nameCtrl.text,
                      'CU_USERNAME': userNameCtrl.text,
                      'CU_TEL': telCtrl.text,
                      'CU_HP': hpCtrl.text,
                      'Zip_Code': zipCtrl.text,
                      'CU_ADDR1': addr1Ctrl.text,
                      'CU_ADDR2': addr2Ctrl.text,
                      'CU_Bigo1': bigo1Ctrl.text,
                      'CU_Bigo2': bigo2Ctrl.text,
                      'CU_SW_CODE': data.cuSwCode ?? '',
                      'CU_SW_NAME': data.cuSwName ?? '',
                      'CU_CUTYPE': selectedCuCuType ?? '',
                      'GPS_X': '',
                      'GPS_Y': '',
                      'APP_User': AppState.loginUserId,
                    };

                    final resp = await NetHelper.request(ctx2, () => NetHelper.api.customerInfoUpdate(req));
                    if (!ctx2.mounted) return;

                    if (NetHelper.isSuccess(resp)) {
                      Fluttertoast.showToast(msg: '저장되었습니다.');
                      // 업데이트된 데이터 반영
                      final updated = resp['resultData'];
                      data.cuName = updated?['CU_NAME']?.toString() ?? nameCtrl.text;
                      data.cuUserName = updated?['CU_USERNAME']?.toString() ?? userNameCtrl.text;
                      data.cuNameView = '${data.cuName} ${data.cuUserName}';
                      data.cuFullName = '${data.cuName} ${data.cuUserName}';
                      data.cuAddr1 = updated?['CU_ADDR1']?.toString() ?? addr1Ctrl.text;
                      data.cuAddr2 = updated?['CU_ADDR2']?.toString() ?? addr2Ctrl.text;
                      data.cuTel = telCtrl.text;
                      data.cuHp = hpCtrl.text;
                      Navigator.pop(ctx, data);
                    } else {
                      NetHelper.handleError(ctx2, resp);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF555555)),
                  child: const Text('저장', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    userNameCtrl.dispose();
    telCtrl.dispose();
    hpCtrl.dispose();
    zipCtrl.dispose();
    addr1Ctrl.dispose();
    addr2Ctrl.dispose();
    bigo1Ctrl.dispose();
    bigo2Ctrl.dispose();

    return result;
  }

  static Widget _inputRow(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 75, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: ctrl,
                      keyboardType: type,
                      readOnly: readOnly,
                      onTap: onTap,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                if (actionLabel != null && onActionTap != null) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onActionTap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        backgroundColor: const Color(0xFF777777),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dropdownRow(String label, List<ComboData> items, String? selectedValue, ValueChanged<String?> onChanged) {
    ComboData? selected;
    for (final item in items) {
      if (item.cd == selectedValue) {
        selected = item;
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 75, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ComboData>(
                  isExpanded: true,
                  isDense: true,
                  value: selected,
                  items: items.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.getCdName(), style: const TextStyle(fontSize: 12)),
                  )).toList(),
                  onChanged: (v) => onChanged(v?.cd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
