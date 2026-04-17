import 'dart:convert';
import 'dart:typed_data';
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
  final String contType; // 1=신규, 2=갱신

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
  });
}

class ContractPdfService {
  static pw.Font? _fontRegular;
  static pw.Font? _fontBold;

  static Future<void> _loadFonts() async {
    if (_fontRegular != null) return;
    final regularData = await rootBundle.load('assets/fonts/AppleSDGothicNeoR.ttf');
    final boldData = await rootBundle.load('assets/fonts/AppleSDGothicNeoB.ttf');
    _fontRegular = pw.Font.ttf(regularData);
    _fontBold = pw.Font.ttf(boldData);
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
    doc.addPage(_buildPage1(theme, data, dateF, dateT, supplierImg, customerImg, dateSign));

    // ─── 2페이지: 계약서 뒤쪽 (안전 계도물) ───
    doc.addPage(_buildPage2(theme, data, supplierImg, customerImg, dateSign));

    return doc.save();
  }

  static pw.Page _buildPage1(
    pw.ThemeData theme,
    ContractPdfData data,
    String dateF,
    String dateT,
    pw.ImageProvider? supplierImg,
    pw.ImageProvider? customerImg,
    String dateSign,
  ) {
    return pw.Page(
      pageFormat: const PdfPageFormat(257 * PdfPageFormat.mm, 364 * PdfPageFormat.mm),
      theme: theme,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 법률 참조
            pw.Text(' [별지 3의2]  <개정 2022.1.21.>', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 2),

            // 테이블 전체
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
              },
              children: [
                // 제목
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(children: [
                      pw.Text('[액법 시행규칙 별지 제50호서식]', style: const pw.TextStyle(fontSize: 8)),
                      pw.SizedBox(height: 4),
                      pw.Text('액화석유가스 안전공급계약서',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center),
                      pw.SizedBox(height: 4),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text(' ※ [ ]에는 해당되는 곳에 √표를 합니다.', style: const pw.TextStyle(fontSize: 8)),
                        pw.Text('(앞쪽)', style: const pw.TextStyle(fontSize: 8)),
                      ]),
                    ]),
                  ),
                ]),

                // 전문
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text(
                      '  「액화석유가스의 안전관리 및 사업법 시행규칙」 별표 13 제3호가목에 따라 당사(점)[이하 \'당사(점)\'이라 합니다]는 '
                      '고객(이하\'고객\'이라 합니다)과 액화석유가스의 안전공급에 관하여 다음과 같이 계약을 체결합니다.',
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ]),
              ],
            ),

            // 계약 내용 테이블
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(120),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                _contractRow('1. 가스의\n   전달방법', _section1Text()),
                _contractRow('2. 가스의 계량\n   방법과\n   가스요금', _section2Text(data)),
                _contractRow('3. 공급설비와\n   소비설비에\n   대한 비용\n   부담 등', _section3Text()),
                _contractRow('4. 계약기간', _section4Text(dateF, dateT)),
                _contractRow('5. 계약의 해지', _section5Text()),
                _contractRow('6. 공급설비와\n   소비설비의\n   관리방법', _section6Text()),
              ],
            ),
          ],
        );
      },
    );
  }

  static pw.Page _buildPage2(
    pw.ThemeData theme,
    ContractPdfData data,
    pw.ImageProvider? supplierImg,
    pw.ImageProvider? customerImg,
    String dateSign,
  ) {
    return pw.Page(
      pageFormat: const PdfPageFormat(257 * PdfPageFormat.mm, 364 * PdfPageFormat.mm),
      theme: theme,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 뒤쪽 제목
            pw.Center(child: pw.Text('(뒤쪽)', style: const pw.TextStyle(fontSize: 8))),
            pw.SizedBox(height: 4),

            // 가스안전 계도물
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {0: const pw.FlexColumnWidth(1)},
              children: [
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Center(child: pw.Text('가스안전 계도물',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
                  ),
                ]),
              ],
            ),

            // 안전책임에 관한 사항
            _safetySection(),

            pw.SizedBox(height: 4),

            // 소비자보장책임보험
            _insuranceSection(),

            pw.SizedBox(height: 4),

            // 긴급 시 연락처
            _emergencySection(),

            pw.SizedBox(height: 4),

            // 소비자 불편신고
            _complaintSection(data),

            pw.SizedBox(height: 4),

            // 점검항목 (안전점검 체크리스트)
            _checklistSection(),

            pw.SizedBox(height: 4),

            // 개선통지사항 / 가스용품 교체 권장사항
            _improvementSection(),

            pw.SizedBox(height: 6),

            // ─── 서명 블록 ───
            _signatureBlock(data, supplierImg, customerImg, dateSign),
          ],
        );
      },
    );
  }

  // ─── 계약조항 텍스트 ───

  static String _section1Text() =>
      '가. 당사(점)는 용기(이하 \'용기\'라 합니다)에 액화석유가스를 충전하여 고객에게 배달합니다.\n'
      '나. 체적식(가스미터에 의한 판매)인 경우 당사(점)는 예비용기를 고객의 용기보관장소에 비치하여 놓고 소비에 따른 용기교체는 고객이 합니다.';

  static String _section2Text(ContractPdfData data) {
    final saleDesc = data.saleType == '2' ? '[√] 체적(가스미터)' : '[√] 중량(Kg)';
    return '가. 가스의 계량은 $saleDesc으로 합니다.\n'
        '나. 가스요금의 기본요금, 사용요금 등은 별표 가격표에 의하며, 가스요금은 매월 정기검침일에 '
        '계량기의 지침을 확인하여 정산합니다.\n'
        '다. 계량기 고장 시의 사용량 산정: ①전3개월 평균사용량 ②전년동기 사용량 ③전후 검침기간의 사용량을 감안하여 산정';
  }

  static String _section3Text() =>
      '가. 공급설비(용기에서 계량기 출구까지)는 당사(점)의 비용으로 설치ㆍ유지하며, '
      '소비설비(계량기 출구에서 연소기까지)는 고객의 비용으로 설치ㆍ유지합니다.\n'
      '나. 고객은 당사(점) 외의 다른 액화석유가스 판매사업자로부터 액화석유가스를 공급받아서는 안됩니다.';

  static String _section4Text(String dateF, String dateT) =>
      '가. 계약기간은 $dateF 부터 $dateT 까지로 합니다.\n'
      '나. 계약만료일 1개월 전까지 양 당사자 중 어느 일방이 서면으로 계약해지를 통지하지 않는 경우 '
      '종전과 동일한 조건으로 6개월씩 자동 연장됩니다.\n'
      '다. 최초 계약기간은 체적식(가스미터에 의한 판매)인 경우 2년, 중량식(Kg에 의한 판매)인 경우 1년으로 합니다.';

  static String _section5Text() =>
      '가. 고객이 3회분 이상의 가스요금을 내지 않을 때\n'
      '나. 고객이 정당한 사유 없이 당사(점)의 안전점검을 거부할 때\n'
      '다. 고객이 가스시설의 안전유지를 위한 개선요청에 따르지 않을 때\n'
      '라. 가스사용시설이 안전관리기준에 적합하지 않은 경우로서 가스사고의 발생 우려가 있다고 '
      '인정될 때\n'
      '마. 고객이 당사(점) 외의 다른 판매사업자로부터 가스를 공급받은 경우\n'
      '바. 당사(점)가 정당한 이유 없이 15일 이상 가스를 공급하지 않은 경우\n'
      '사. 계약 해지 시 공급설비의 철거비용은 당사(점)이, 소비설비의 철거비용은 고객이 각각 부담합니다.';

  static String _section6Text() =>
      '가. 당사(점)는 1회/월 이상 가스공급시설의 안전점검을 실시합니다.\n'
      '나. 고객은 가스누출 여부 등 일상적인 안전관리를 하여야 합니다.\n'
      '다. 고객은 당사(점) 또는 한국가스안전공사의 시설개선 요청에 따라야 합니다.';

  // ─── 2페이지 섹션 ───

  static pw.Widget _safetySection() {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: const pw.FixedColumnWidth(120), 1: const pw.FlexColumnWidth(1)},
      children: [
        pw.TableRow(children: [
          _cellBold('안전책임에\n관한 사항'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '1. 고객의 안전책임\n'
              '  가. 고객은 가스를 사용하기 전에 가스가 새는지를 확인합니다.\n'
              '  나. 사용 중에 불이 꺼지지 않았는지 확인합니다.\n'
              '  다. 사용 후에는 연소기 콕과 중간밸브를 잠급니다.\n'
              '  라. 장기간 외출 시 용기밸브(체적식 메인밸브)를 잠급니다.\n\n'
              '2. 당사(점)의 안전책임\n'
              '  가. 당사(점)는 1회/월 이상 안전점검을 실시합니다.\n'
              '  나. 안전점검 결과 개선이 필요한 사항은 서면으로 통지합니다.\n'
              '  다. 가스사고 발생 시 신속한 응급조치를 합니다.',
              style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 2),
            ),
          ),
        ]),
      ],
    );
  }

  static pw.Widget _insuranceSection() {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: const pw.FixedColumnWidth(120), 1: const pw.FlexColumnWidth(1)},
      children: [
        pw.TableRow(children: [
          _cellBold('소비자보장\n책임보험\n가입 확인'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '「액화석유가스의 안전관리 및 사업법」제57조제3항에 따라 가입한 보험의 내용\n'
              '  • 사망: 1인당 8,000만원     • 부상: 1인당 1,500만원\n'
              '  • 재산피해: 사고 1건당 3억원',
              style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 2),
            ),
          ),
        ]),
      ],
    );
  }

  static pw.Widget _emergencySection() {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: const pw.FixedColumnWidth(120), 1: const pw.FlexColumnWidth(1)},
      children: [
        pw.TableRow(children: [
          _cellBold('긴급 시\n연락처'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '1. 화재 시: 119에 신고하고, 용기밸브를 잠근 후 용기를 안전한 곳으로 이동합니다.\n'
              '2. 가스누출 시: 창문을 열어 환기하고, 당사(점) 또는 한국가스안전공사(1544-4500)에 연락합니다.\n'
              '3. 침수 시: 용기밸브를 잠그고, 가스시설에 손대지 말고 당사(점)에 연락합니다.',
              style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 2),
            ),
          ),
        ]),
      ],
    );
  }

  static pw.Widget _complaintSection(ContractPdfData data) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: const pw.FixedColumnWidth(120), 1: const pw.FlexColumnWidth(1)},
      children: [
        pw.TableRow(children: [
          _cellBold('소비자\n불편신고'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '• 시ㆍ군ㆍ구: ${data.centerSi}\n'
              '• 소비자단체: ${data.centerConsumer}\n'
              '• 한국가스안전공사: ${data.centerKgs}\n'
              '• 가스공급자단체: ${data.centerGas}',
              style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 2),
            ),
          ),
        ]),
      ],
    );
  }

  static pw.Widget _checklistSection() {
    const items = [
      '가. 가스계량기 및 가스계량기 전단밸브의 설치장소가 적합한지 여부',
      '나. 배관에 부식 등 이상이 없는지 여부',
      '다. 호스 및 호스 연결부 상태가 적합한지 여부',
      '라. 연소기의 설치장소 및 배기통의 설치 상태가 적합한지 여부',
      '마. 가스누출경보차단장치 설치 및 작동 상태가 적합한지 여부',
      '바. 가스누출 여부',
      '사. 소비설비 주위에 화기 취급 여부',
      '아. 중간밸브 및 퓨즈콕의 설치 및 조작 상태가 적합한지 여부',
      '자. 용기의 저장 보관 상태가 적합한지 여부',
      '차. 용기 보관실의 관리 상태가 적합한지 여부',
      '카. 그 밖에 가스사고를 유발할 우려가 없는지 여부',
    ];

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FixedColumnWidth(60),
      },
      children: [
        pw.TableRow(children: [
          _cellBold('안전점검 항목'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Center(child: pw.Text('점검 내용', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Center(child: pw.Text('적ㆍ부', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
          ),
        ]),
        ...items.map((item) => pw.TableRow(children: [
          pw.SizedBox(),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: pw.Text(item, style: const pw.TextStyle(fontSize: 7)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Center(child: pw.Text('적 ㆍ 부', style: const pw.TextStyle(fontSize: 7))),
          ),
        ])),
        // 가스용품 권장사용기간
        pw.TableRow(children: [
          _cellBold('가스용품의\n권장사용기간'),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: pw.Text('파. 압력조정기ㆍ고압호스ㆍ저압호스ㆍ퓨즈콕 및 가스보일러의 권장사용기간 경과 여부',
              style: const pw.TextStyle(fontSize: 7)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Center(child: pw.Text('적 ㆍ 부', style: const pw.TextStyle(fontSize: 7))),
          ),
        ]),
      ],
    );
  }

  static pw.Widget _improvementSection() {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: const pw.FixedColumnWidth(120), 1: const pw.FlexColumnWidth(1)},
      children: [
        pw.TableRow(children: [
          _cellBold('개선통지사항'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(children: [
              pw.SizedBox(height: 16),
              pw.Text(
                '※ 압력조정기에서 중간밸브까지의 배관이 별표 20 제1호가목4)라)에 적합하게 강관ㆍ동관 또는 '
                '금속플렉시블호스로 설치되어 있지 않은 주택은 2030년 12월 31일까지 해당 배관으로 교체해야 합니다.',
                style: const pw.TextStyle(fontSize: 7),
              ),
            ]),
          ),
        ]),
        pw.TableRow(children: [
          _cellBold('가스용품 교체\n권장사항'),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.SizedBox(height: 20)),
        ]),
      ],
    );
  }

  // ─── 서명 블록 ───

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
        pw.TableRow(children: [
          // 공급자 정보
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(' 사업자등록번호: ${data.comNo}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(' 상호: ${data.comName}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(' 전화번호: ${data.comTel}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(' 긴급 시 연락처: ${data.comHp}', style: const pw.TextStyle(fontSize: 8)),
                pw.Row(children: [
                  pw.Text(' 대표자: ${data.comCeoName}', style: const pw.TextStyle(fontSize: 8)),
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
                pw.Text(' 상호: ${data.custComName}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(' 성명: ${data.cuGongName}    전화번호: ${data.custTel}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(' 주소: ${data.cuAddr1} ${data.cuAddr2}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('            $dateSign', style: const pw.TextStyle(fontSize: 8)),
                pw.Row(children: [
                  pw.Text(' 고객서명:', style: const pw.TextStyle(fontSize: 8)),
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

  // ─── 헬퍼 ───

  static pw.TableRow _contractRow(String title, String content) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(content, style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 2)),
      ),
    ]);
  }

  static pw.Widget _cellBold(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Center(
        child: pw.Text(text,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center),
      ),
    );
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
    } catch (_) {
      return null;
    }
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    // YYYYMMDD → YYYY년 MM월 DD일
    final clean = raw.replaceAll('-', '');
    if (clean.length < 8) return raw;
    return '${clean.substring(0, 4)}년 ${clean.substring(4, 6)}월 ${clean.substring(6, 8)}일';
  }
}
