import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// 계약 데이터를 담는 DTO
class ContractPdfData {
  // 공급자 정보
  final String comNo;
  final String comName;
  final String comTel;
  final String comHp;
  final String comCeoName;

  // 고객 정보
  final String custComNo;
  final String custComName;
  final String custTel;
  final String cuGongName;
  final String cuAddr1;
  final String cuAddr2;
  final String cuGongNo;

  // 계약 정보
  final String anzDate;
  final String anzDateF;
  final String anzDateT;
  final String saleType; // 1=중량, 2=체적
  final String contType; // 1=신규, 2=재계약

  // 공급설비
  final String useCyl;
  final String useMeter;
  final String useTrans;
  final String useVapor;
  final String usePipe;
  final String useFacility;

  // 불만신고센터
  final String centerSi;
  final String centerConsumer;
  final String centerKgs;
  final String centerGas;

  // 서명 (base64 data URI)
  final String? supplierSign;
  final String? customerSign;

  // 종전 가스공급자 상호 (재계약 시)
  final String comBefore;

  const ContractPdfData({
    this.comNo = '',
    this.comName = '',
    this.comTel = '',
    this.comHp = '',
    this.comCeoName = '',
    this.custComNo = '',
    this.custComName = '',
    this.custTel = '',
    this.cuGongName = '',
    this.cuAddr1 = '',
    this.cuAddr2 = '',
    this.cuGongNo = '',
    this.anzDate = '',
    this.anzDateF = '',
    this.anzDateT = '',
    this.saleType = '',
    this.contType = '',
    this.useCyl = '',
    this.useMeter = '',
    this.useTrans = '',
    this.useVapor = '',
    this.usePipe = '',
    this.useFacility = '',
    this.centerSi = '',
    this.centerConsumer = '',
    this.centerKgs = '',
    this.centerGas = '',
    this.supplierSign,
    this.customerSign,
    this.comBefore = '',
  });
}

class ContractPdfService {
  static pw.Font? _fontRegular;
  static pw.Font? _fontBold;
  static pw.ImageProvider? _contImg;

  static Future<void> _loadFonts() async {
    if (_fontRegular != null) return;
    final regularData = await rootBundle.load('assets/fonts/AppleSDGothicNeoR.ttf');
    final boldData = await rootBundle.load('assets/fonts/AppleSDGothicNeoB.ttf');
    _fontRegular = pw.Font.ttf(regularData);
    _fontBold = pw.Font.ttf(boldData);
    try {
      final imgData = await rootBundle.load('assets/images/CONT_IMG.png');
      _contImg = pw.MemoryImage(imgData.buffer.asUint8List());
    } catch (e) {
      debugPrint('[PDF] CONT_IMG.png 로드 실패: $e');
    }
  }

  /// PDF 바이트 생성
  static Future<Uint8List> generate(ContractPdfData data) async {
    await _loadFonts();

    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(base: _fontRegular!, bold: _fontBold!);

    // 서명 이미지 변환
    pw.ImageProvider? supplierImg;
    pw.ImageProvider? customerImg;
    if (data.supplierSign != null && data.supplierSign!.isNotEmpty) {
      supplierImg = _decodeSignature(data.supplierSign!);
    }
    if (data.customerSign != null && data.customerSign!.isNotEmpty) {
      customerImg = _decodeSignature(data.customerSign!);
    }

    // 날짜 포맷
    final dateF = _formatDate(data.anzDateF);
    final dateT = _formatDate(data.anzDateT);
    final dateSign = _formatDate(data.anzDate);

    // ─── 1페이지: 계약서 앞쪽 ───
    doc.addPage(_buildPage1(theme, data, dateF, dateT));

    // ─── 2페이지: 계약서 뒤쪽 ───
    doc.addPage(_buildPage2(theme, data, supplierImg, customerImg, dateSign));

    return doc.save();
  }

  // ══════════════════════════════════════════════
  //  페이지 1 (앞쪽)
  // ══════════════════════════════════════════════

  static pw.Page _buildPage1(
    pw.ThemeData theme,
    ContractPdfData data,
    String dateF,
    String dateT,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 법률 참조 (상단)
            pw.Text('별지 3의2 개정 2022.1.21', style: const pw.TextStyle(fontSize: 7)),
            pw.SizedBox(height: 2),

            // 헤더
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(children: [
                      pw.Text('[액법 시행규칙 별지 제50호서식]', style: const pw.TextStyle(fontSize: 7)),
                      pw.SizedBox(height: 4),
                      pw.Text('액화석유가스 안전공급계약서',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center),
                      pw.SizedBox(height: 4),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text('※ [ ]에는 해당되는 곳에 √표를 합니다.', style: const pw.TextStyle(fontSize: 7)),
                        pw.Text('(앞쪽)', style: const pw.TextStyle(fontSize: 7)),
                      ]),
                    ]),
                  ),
                ]),
                // 전문
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text(
                      '「액화석유가스의 안전관리 및 사업법 시행규칙」 별표 13 제3호가목에 따라 당사(점)[이하 \'당사(점)\'이라 합니다]는 '
                      '고객(이하 \'고객\'이라 합니다)과 액화석유가스의 안전공급에 관하여 다음과 같이 계약을 체결합니다.',
                      style: const pw.TextStyle(fontSize: 7),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ]),
              ],
            ),

            // 계약 내용 테이블 (1~6)
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                _contractRow('가스의\n전달방법', _s1()),
                _contractRow('가스의\n계량방법과\n가스요금', _s2(data)),
                _contractRow('공급설비와\n소비설비에\n대한 비용\n부담 등', _s3()),
                _contractRow('계약기간', _s4(dateF, dateT)),
                _contractRow('계약의 해지', _s5()),
                _contractRow('공급설비와\n소비설비의\n관리방법', _s6()),
              ],
            ),

            pw.SizedBox(height: 4),

            // 페이지 1 하단
            pw.Text('※ 고객과 관련된 정보는 다른 목적으로 사용하거나 누출할 수 없습니다.', style: const pw.TextStyle(fontSize: 6)),
            pw.Text('210mm × 297mm(백상지 60g/㎡(재활용품))', style: const pw.TextStyle(fontSize: 6)),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  //  페이지 2 (뒤쪽)
  // ══════════════════════════════════════════════

  static pw.Page _buildPage2(
    pw.ThemeData theme,
    ContractPdfData data,
    pw.ImageProvider? supplierImg,
    pw.ImageProvider? customerImg,
    String dateSign,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('(뒤쪽)', style: const pw.TextStyle(fontSize: 7))),
            pw.SizedBox(height: 2),

            // 계약 내용 테이블 (7~11)
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                _contractRow('가스안전\n계도물', _s7()),
                _contractRow('안전책임에\n관한 사항', _s8()),
                _contractRow('소비자보장\n책임보험\n가입 확인', _s9()),
                _contractRow('긴급 시\n연락처', _s10()),
                _contractRow('소비자\n불편신고', _s11()),
              ],
            ),

            pw.SizedBox(height: 4),

            // ─── 공급설비/소비설비 구성도 (소비자불편신고 아래, 테이블 위) ───
            if (_contImg != null)
              pw.Center(
                child: pw.Image(_contImg!, width: 500, height: 120),
              ),

            pw.SizedBox(height: 4),

            // ─── 소비자불만신고센터 + 공급설비 테이블 ───
            _equipmentAndComplaintTable(data),

            pw.SizedBox(height: 4),

            // ─── 판매방법 / 거래현황 ───
            _saleAndTradeRow(data),

            pw.SizedBox(height: 4),

            // ─── 가스공급자 / 고객 서명 블록 ───
            _signatureBlock(data, supplierImg, customerImg, dateSign),

            pw.SizedBox(height: 2),
            pw.Text('※ 고객과 관련된 정보는 다른 목적으로 사용하거나 누출할 수 없습니다.', style: const pw.TextStyle(fontSize: 6)),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  //  계약조항 본문 (공식 서식)
  // ══════════════════════════════════════════════

  /// 1. 가스의 전달방법
  static String _s1() =>
      '당사(점)는 액화석유가스(LPG)가 충전된 용기를 가스사용에 지장이 없도록, 계획된 배달날짜 또는 고객이 주문할 때마다 신속히 배달하겠으며, '
      '사용시설에 직접 연결하여 드립니다. 다만, 체적으로 판매할 경우에는 사용 중인 용기 안에 있는 가스가 떨어지면 자동적으로 다른 용기에서 '
      '가스가 공급될 수 있도록 항상 충전된 예비용기를 연결하여 드리겠습니다.';

  /// 2. 가스의 계량방법과 가스요금
  static String _s2(ContractPdfData data) =>
      '1. 체적(계량기로 계량함)으로 판매할 경우\n'
      '가. 매월 가스사용량을 검침하여 별첨의 <체적판매 가스요금표>에 따라 계산된 가스요금을 받으며, 만약 가스계량기의 고장 등으로 계량이 잘 되지 않은 경우에는 '
      '최근 3개월간 검침된 양의 평균수치를 기준으로 하여 가스요금을 계산합니다.\n'
      '나. 가스요금의 가격구성과 요금체계의 설명은 가스요금표에 적혀 있고, 가스요금을 조정한 경우에는 조정된 가스요금을 적용하기 전에 알려드리겠습니다.\n'
      '2. 중량으로 판매할 경우\n'
      '정량표시를 한 용기로 배달하고, 별첨의 <중량판매 가스요금표>에 따라 가스요금을 받으며, 가스요금을 조정한 경우에는 조정된 가스요금을 적용하기 전에 알려드리겠습니다.\n'
      '3. 가스요금이 납기 내에 납부되지 않은 경우 당사(점)는 고객에게 납기 경과분에 대해 관할 허가관청이 인정하는 연체료(가산금)를 부과할 수 있고, '
      '사전 연락 후 가스공급을 중지할 수 있습니다.\n'
      '※ 별첨: 체적(중량)판매 가스요금표 1부';

  /// 3. 공급설비와 소비설비에 대한 비용부담 등
  static String _s3() =>
      '1. 공급설비와 소비설비의 설치·변경 등의 비용부담 방법은 다음과 같습니다.\n'
      '가. 당사(점) 소유의 공급설비(체적판매의 경우 용기 출구에서 계량기 출구까지의 설비를 말합니다)를 사용하여 고객이 당사(점)으로부터 가스를 공급받는 경우 '
      '그 설비의 사용에 대해 별도의 사용료를 부과하지 않습니다. 다만, 고객의 요청으로 계약기간을 정하지 않는 경우에는 당사(점)은 그 사용료를 부과할 수 있고, '
      '고객의 사정(건물 보수 등)으로 공급설비의 변경·교환·수리 등이 필요한 경우에는 고객이 부담합니다.\n'
      '나. 소비설비(체적판매의 경우 계량기 출구에서 연소기까지의 설비를 말하고, 중량판매의 경우 용기 출구에서 연소기까지의 설비를 말합니다)의 설치·변경 등은 '
      '고객이 부담합니다.\n'
      '2. 고객은 당사(점) 소유의 설비로 다른 가스공급자로부터 가스를 공급받을 수 없습니다.';

  /// 4. 계약기간
  static String _s4(String dateF, String dateT) =>
      '이 계약의 유효기간은 $dateF 부터 $dateT 까지로 하고, 당사(점)은 계약만료일 15일 전에 고객에게 계약만료를 알리며, '
      '고객이 계약만료일 전에 계약해지를 알리지 않은 경우 계약기간은 6개월씩 연장됩니다.\n\n'
      '※ 계약기간: 체적판매방법으로 공급하는 경우 및 중량판매방법(용기집합설비를 설치한 주택에 공급하는 경우만을 말합니다)으로 공급하는 경우로서 '
      '공급설비를 당사(점)의 부담으로 설치한 경우 당사(점)와 체결하는 최초의 안전공급계약은 1년(주택의 경우에는 2년) 이상으로 하고, '
      '공급설비와 소비설비 모두를 당사(점)의 부담으로 설치한 경우 당사(점)와 체결하는 최초의 안전공급계약은 2년(주택의 경우에는 3년) 이상으로 합니다.';

  /// 5. 계약의 해지
  static String _s5() =>
      '고객이 당사(점)와 계약한 안전공급계약의 해지를 요청할 경우 당사(점)는 5일 이내에 고객과 가스요금 등을 정산 및 납부하고 계약을 해지하여야 하며, '
      '다음의 방법에 따라야 합니다.\n'
      '1. 계약기간이 만료되어 고객이 계약해지를 요구하는 경우 당사(점)는 그 설비를 철거하거나 고객이 원하는 새로운 가스공급자에게 양도·양수합니다.\n'
      '2. 계약기간 내에 당사(점)이 무단으로 가스공급의 중단, 사전 협의 없는 요금의 인상, 안전점검 미실시, 그 밖에 안전관리 업무를 하지 않은 경우로서 '
      '고객이 그 설비의 철거를 원할 경우 당사(점)은 그 설비를 철거합니다.\n'
      '3. 제2호 외의 사유로 계약기간 내에 고객이 계약해지를 요청하는 경우 고객은 당사(점)가 설치한 설비에 대하여 철거비용을 부담해야 합니다. '
      '다만, 고객이 그 설비의 철거를 원하지 않고 새로운 가스공급자가 있는 경우 당사(점)는 제1호의 방법으로 할 수 있습니다.\n'
      '4. 공급설비가 고객의 소유인 경우 당사(점)이 구매·철거합니다. 다만, 고객이 공급설비의 철거를 원하지 않는 경우에는 당사(점)은 용기만 구매·철거하고, '
      '새로운 가스공급자는 고객의 공급설비를 구매해야 합니다.\n'
      '5. 당사(점)의 귀책사유 없이 고객이 계약을 해지하려면 고객은 다음의 방법에 따라 산정한 철거비용 등을 당사(점)에 납부하여야 합니다.\n'
      '  가. 당사(점)이 설치한 설비의 철거비용: 통계청의 건설임금단가(배관공)를 적용\n'
      '  나. 소비설비[당사(점)의 부담으로 설치한 경우만 해당합니다]의 시가 상당액: 계약해지 당시의 신규제품가격에서 1년에 20%씩 뺀 금액\n'
      '6. 계약기간이 지난 이후 당사(점)의 부담으로 설치한 소비설비는 계약서에 별도로 고객에게 소유권이 이전되는 것으로 명시한 경우에 한정하여 고객의 소유로 합니다.\n'
      '7. 계약의 해지는 요금의 정산과 공급설비에 대한 보상시 발행한 영수증 등으로 확인할 수 있어야 합니다.';

  /// 6. 공급설비와 소비설비의 관리방법
  static String _s6() =>
      '1. 공급설비에 대해서는, 당사(점)가 법규에서 정하는 바에 따라 설비의 유지·관리를 위한 점검을 합니다.\n'
      '2. 소비설비에 대해서는, 당사(점)가 법규에서 정하는 바에 따라 점검을 실시하나, 일상의 관리는 「가스안전 계도물」 등을 참고하여 관리하여 주시고, '
      '고객은 당사(점)의 점검을 거부해서는 안 되며, 점검 결과 기준에 맞지 않거나 가스누출 등의 우려가 있을 경우 당사(점)는 안전상 가스사용을 일시 중단시킬 수 있으며, '
      '중단조치 후 무단으로 가스를 사용하였을 경우 당사(점)는 그로 인한 책임을 지지 않습니다.\n'
      '3. 고객은 당사(점)의 시설개선 권고를 받은 경우 당사(점)가 정한 날까지 시설 개선을 해야 합니다. 시설 개선 권고를 이행하지 않는 경우 당사(점)는 '
      '그 사실을 관할 관청에 알려야 합니다.\n'
      '4. 고객은 당사(점)와 사전 협의 없이 당사(점) 소유의 설비를 임의로 철거하거나 변경할 수 없습니다. 다만, 협의가 이루어지지 않아 고객이 당사(점) 소유 설비의 '
      '철거를 요청한 경우 5일 이내에 철거하겠습니다.\n'
      '5. 당사(점)는 고객이 관할관청의 수리 또는 개선명령을 이행하기 위하여 당사(점)에게 고객의 소비설비의 수리 또는 개선을 요청한 경우 2일 이내에 고객의 '
      '소비설비를 개선하여 드리겠습니다. 다만, 이에 필요한 비용은 고객이 부담합니다.';

  /// 7. 가스안전 계도물
  static String _s7() =>
      '당사(점)는 액화석유가스의 안전사용을 위한 주의사항을 적은 서면을 6개월에 1회 이상 전달하겠으며, '
      '고객은 반드시 그 내용을 확인하고, 가스를 안전하게 사용하시기 바랍니다.';

  /// 8. 안전책임에 관한 사항
  static String _s8() =>
      '1. 고객의 안전책임\n'
      '가. 고객은 가스를 사용할 때 이 계약서와 가스안전 계도물에 적힌 안전에 관한 주의사항을 준수해야 합니다.\n'
      '나. 고객은 당사(점)와 사전협의 없이 당사(점) 소유의 설비를 임의로 철거하거나 변경하지 말아야 합니다.\n'
      '다. 당사(점)의 점검 결과 부적합한 것으로 지적·통지된 사항은 안전을 위하여 신속히 조치하여야 합니다.\n'
      '※ 위의 나목 및 다목의 사항을 위반하여 발생한 사고·재해의 책임은 고객에게 있으므로 소비자보장책임보험의 혜택을 받을 수 없습니다.\n'
      '※ 고객의 과실로 발생한 사고로 인한 고객의 재산피해에 대해서는 과실상계원칙에 따라 보험금액을 감하여 지급합니다.\n'
      '※ 법령에 따른 보험가입대상인 소비자에 대해서는 소비자보장책임보험을 적용하지 않습니다.\n\n'
      '2. 당사(점)의 안전책임\n'
      '가. 당사(점)가 유지·관리하는 공급설비의 결함으로 발생한 재해에 대해서는 당사(점)가 책임을 지고, 이를 위해 당사(점)는 소비자보장책임보험에 가입해야 합니다.\n'
      '나. 소비설비의 경우 당사(점)가 행하는 점검하자로 발생한 손해에 대해서는 당사(점)가 책임을 지고, 이를 위해 당사(점)는 소비자보장책임보험에 가입해야 합니다.\n'
      '※ 소비자보장책임보험의 보장 범위는 당사(점)가 계약체결 시 설명해 드립니다.';

  /// 9. 소비자보장책임보험 가입 확인
  static String _s9() =>
      '당사(점)는 가스사고를 대비하여 소비자보장책임보험에 가입하였고, 가스사용 중 불의의 가스사고로 피해가 발생한 경우에는 고객은 '
      '사망(후유장애 포함)의 경우 1명당 8천만원, 부상의 경우 1명당 1천5백만원, 재산피해의 경우 3억원의 범위에서 피해보상을 받으실 수 있습니다. '
      '다만, 소비자의 고의적인 사고(보험약관에 보상하도록 적혀 있는 경우는 제외합니다) 또는 계약서상의 기본적 준수사항 위반과 '
      '천재지변의 경우에는 보상이 이루어지지 않습니다.\n'
      '※ 법령에 따른 보험가입 대상인 소비자에게는 소비자보장책임보험을 적용하지 않습니다.';

  /// 10. 긴급 시 연락처
  static String _s10() =>
      '1. 당사(점)는 재해가 발생하거나 발생할 우려가 있을 경우에 대비해 24시간 체제를 유지해야 하고, 고객은 긴급 시 아래의 연락처로 전화하여 주시기 바랍니다.\n'
      '2. 긴급 시에는 다음의 조치를 하여 주시기 바랍니다.\n'
      '가. 화재발생 시 용기의 밸브를 잠그고(오른쪽으로 돌리면 잠김), 소방서 등 관계자에게 용기의 위치를 알린 후 당사(점)에 연락해 주시기 바랍니다.\n'
      '나. 수해의 위험이 있는 경우\n'
      '  (1) 용기 등이 떠내려가지 않도록 하여 주시기 바랍니다.\n'
      '  (2) 용기, 조정기 등이 침수된 경우에는 당사(점)의 점검을 받은 후 사용하시기 바랍니다.';

  /// 11. 소비자 불편신고
  static String _s11() =>
      '부당요금 징수, 가스공급 지연, 서비스 불이행 등 소비자불편사항이 발생한 경우에는 소비자불만신고센터로 전화하여 주시기 바랍니다.';

  // ══════════════════════════════════════════════
  //  소비자불만신고센터 + 공급설비 테이블
  // ══════════════════════════════════════════════

  static pw.Widget _equipmentAndComplaintTable(ContractPdfData data) {
    const fs = pw.TextStyle(fontSize: 7);
    final fsb = pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold);

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        // 헤더
        pw.TableRow(children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Center(child: pw.Text('소비자불만신고센터', style: fsb)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Center(child: pw.Text('당사(점)의 소유·관리에 속하는 공급설비', style: fsb)),
          ),
        ]),
        // 서브헤더
        pw.TableRow(children: [
          pw.Table(
            border: pw.TableBorder.all(width: 0.3),
            columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(1)},
            children: [
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('기관명', style: fsb))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('전화번호', style: fsb))),
              ]),
              _complaintRow('시·군·구청', data.centerSi),
              _complaintRow('소비자단체', data.centerConsumer.isEmpty ? '1372' : data.centerConsumer),
              _complaintRow('한국가스안전공사', data.centerKgs.isEmpty ? '1544-4500' : data.centerKgs),
              _complaintRow('가스공급자단체', data.centerGas.isEmpty ? '02-555-3114' : data.centerGas),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(width: 0.3),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FixedColumnWidth(35),
              2: const pw.FixedColumnWidth(40),
            },
            children: [
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('품명', style: fsb))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('수량', style: fsb))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('비고', style: fsb))),
              ]),
              _equipRow2('용기', data.useCyl),
              _equipRow2('가스계량기', data.useMeter),
              _equipRow2('자동절체기', data.useTrans),
              _equipRow2('기화기', data.useVapor),
              _equipRow2('공급관', data.usePipe),
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('부속설비', style: fs)),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(data.useFacility, style: fs),
                ),
                pw.SizedBox(),
              ]),
            ],
          ),
        ]),
        // 주석
        pw.TableRow(children: [
          pw.SizedBox(),
          pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Text('※ 계약체결시 공급설비가 고객의 소유인 경우 비고란에\n   \'소비자 소유\'로 표시합니다.',
              style: const pw.TextStyle(fontSize: 6)),
          ),
        ]),
      ],
    );
  }

  static pw.TableRow _complaintRow(String name, String tel) {
    const fs = pw.TextStyle(fontSize: 7);
    return pw.TableRow(children: [
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(name, style: fs)),
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(tel, style: fs)),
    ]);
  }

  static pw.TableRow _equipRow2(String name, String qty) {
    const fs = pw.TextStyle(fontSize: 7);
    return pw.TableRow(children: [
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(name, style: fs)),
      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text(qty, style: fs))),
      pw.SizedBox(),
    ]);
  }

  // ══════════════════════════════════════════════
  //  판매방법 / 거래현황
  // ══════════════════════════════════════════════

  static pw.Widget _saleAndTradeRow(ContractPdfData data) {
    final isVolume = data.saleType == '2';
    final isNew = data.contType == '1';
    const fs = pw.TextStyle(fontSize: 7);

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      children: [
        pw.TableRow(children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: pw.Row(children: [
              pw.Text('판매방법  ', style: fs),
              pw.Text('[ ${isVolume ? "√" : " "} ] 체적판매,  [ ${isVolume ? " " : "√"} ] 중량판매', style: fs),
              pw.SizedBox(width: 30),
              pw.Text('거래현황  ', style: fs),
              pw.Text('[ ${isNew ? "√" : " "} ] 신규,  [ ${isNew ? " " : "√"} ] 재계약', style: fs),
              if (!isNew && data.comBefore.isNotEmpty)
                pw.Text('  (종전 가스공급자 상호: ${data.comBefore})', style: fs),
            ]),
          ),
        ]),
      ],
    );
  }

  // ══════════════════════════════════════════════
  //  서명 블록
  // ══════════════════════════════════════════════

  static pw.Widget _signatureBlock(
    ContractPdfData data,
    pw.ImageProvider? supplierImg,
    pw.ImageProvider? customerImg,
    String dateSign,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        // 헤더
        pw.TableRow(children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Center(child: pw.Text('가스공급자', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Center(child: pw.Text('고  객', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
          ),
        ]),
        pw.TableRow(children: [
          // 공급자 정보
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('사업자등록번호: ${data.comNo}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('상호: ${data.comName}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('전화번호: ${data.comTel}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('긴급 시 연락처: ${data.comHp}', style: const pw.TextStyle(fontSize: 8)),
                pw.Row(children: [
                  pw.Text('대표자: ${data.comCeoName}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Spacer(),
                  if (supplierImg != null)
                    pw.Image(supplierImg, width: 100, height: 40)
                  else
                    pw.Text('(서명 또는 인)', style: const pw.TextStyle(fontSize: 8)),
                ]),
              ],
            ),
          ),
          // 고객 정보
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('성명: ${data.cuGongName}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('주소: ${data.cuAddr1} ${data.cuAddr2}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('상호: ${data.custComName}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('$dateSign', style: const pw.TextStyle(fontSize: 8)),
                pw.Row(children: [
                  pw.Text('고객서명:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Spacer(),
                  if (customerImg != null)
                    pw.Image(customerImg, width: 100, height: 40)
                  else
                    pw.Text('(서명 또는 인)', style: const pw.TextStyle(fontSize: 8)),
                ]),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // ══════════════════════════════════════════════
  //  헬퍼
  // ══════════════════════════════════════════════

  static pw.TableRow _contractRow(String title, String content) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Center(
          child: pw.Text(title,
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(content, style: const pw.TextStyle(fontSize: 6.5, lineSpacing: 1.5)),
      ),
    ]);
  }

  static pw.ImageProvider? _decodeSignature(String dataUri) {
    try {
      String base64Str = dataUri;
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      final bytes = base64Decode(base64Str);
      if (bytes.isEmpty) return null;
      return pw.MemoryImage(bytes);
    } catch (e) {
      debugPrint('[PDF] _decodeSignature 에러: $e');
      return null;
    }
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    final clean = raw.replaceAll('-', '');
    if (clean.length < 8) return raw;
    return '${clean.substring(0, 4)}년 ${clean.substring(4, 6)}월 ${clean.substring(6, 8)}일';
  }
}
