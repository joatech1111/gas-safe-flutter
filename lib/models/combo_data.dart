class ComboData {
  static String? _s(dynamic v) => v?.toString();
  String? gubun;
  String? cd;
  String? cdName;
  String? cdNameAlt;
  String? bigo;

  ComboData({this.cd = '', this.cdName = '', this.cdNameAlt = '', this.gubun, this.bigo});

  ComboData.fromJson(Map<String, dynamic> json) {
    gubun = _s(json['GUBUN']);
    cd = _s(json['CD']);
    cdName = _s(json['CD_NAME']);
    cdNameAlt = _s(json['CD_Name']);
    bigo = _s(json['BIGO']);
  }

  Map<String, dynamic> toJson() => {
    'GUBUN': gubun,
    'CD': cd,
    'CD_NAME': cdName,
    'CD_Name': cdNameAlt,
    'BIGO': bigo,
  };

  String getCdName() {
    if (cdName != null && cdName!.isNotEmpty) return cdName!;
    if (cdNameAlt != null && cdNameAlt!.isNotEmpty) return cdNameAlt!;
    return '';
  }

  ComboData toTrim() {
    gubun = gubun?.trim();
    cd = cd?.trim();
    cdName = cdName?.trim();
    cdNameAlt = cdNameAlt?.trim();
    bigo = bigo?.trim();
    return this;
  }

  @override
  String toString() => getCdName();

  @override
  bool operator ==(Object other) =>
      other is ComboData && cd == other.cd && cdName == other.cdName && cdNameAlt == other.cdNameAlt;

  @override
  int get hashCode => Object.hash(cd, cdName, cdNameAlt);
}
