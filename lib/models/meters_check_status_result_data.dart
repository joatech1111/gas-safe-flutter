class MetersCheckStatusResultData {
  static String? _s(dynamic v) => v?.toString();
  String? areaCode;
  String? cuCode;
  String? cuNameView;
  String? cuName;
  String? cuUserName;
  String? gjCuSwCode;
  String? gjCuSwName;
  String? appGjDate;
  String? appGjJungum;
  String? appGjGum;
  String? appGjGage;
  String? appGjT1Per;
  String? appGjT1Kg;
  String? appGjT2Per;
  String? appGjT2Kg;
  String? appGjJankg;
  String? appGjBigo;
  String? smartMeterYN;

  MetersCheckStatusResultData();

  MetersCheckStatusResultData.fromJson(Map<String, dynamic> json) {
    areaCode = _s(json['AREA_CODE']);
    cuCode = _s(json['CU_CODE']);
    cuNameView = _s(json['CU_Name_View']);
    cuName = _s(json['CU_NAME']);
    cuUserName = _s(json['CU_USERNAME']);
    gjCuSwCode = _s(json['GJ_CU_SW_CODE']);
    gjCuSwName = _s(json['GJ_CU_SW_NAME']);
    appGjDate = _s(json['APP_GJ_DATE']);
    appGjJungum = _s(json['APP_GJ_JUNGUM']);
    appGjGum = _s(json['APP_GJ_GUM']);
    appGjGage = _s(json['APP_GJ_GAGE']);
    appGjT1Per = _s(json['APP_GJ_T1_Per']);
    appGjT1Kg = _s(json['APP_GJ_T1_kg']);
    appGjT2Per = _s(json['APP_GJ_T2_Per']);
    appGjT2Kg = _s(json['APP_GJ_T2_kg']);
    appGjJankg = _s(json['APP_GJ_JANKG']);
    appGjBigo = _s(json['APP_GJ_BIGO']);
    smartMeterYN = _s(json['SMART_METER_YN']);
  }

  Map<String, dynamic> toJson() => {
    'AREA_CODE': areaCode,
    'CU_CODE': cuCode,
    'CU_Name_View': cuNameView,
    'CU_NAME': cuName,
    'CU_USERNAME': cuUserName,
    'GJ_CU_SW_CODE': gjCuSwCode,
    'GJ_CU_SW_NAME': gjCuSwName,
    'APP_GJ_DATE': appGjDate,
    'APP_GJ_JUNGUM': appGjJungum,
    'APP_GJ_GUM': appGjGum,
    'APP_GJ_GAGE': appGjGage,
    'APP_GJ_T1_Per': appGjT1Per,
    'APP_GJ_T1_kg': appGjT1Kg,
    'APP_GJ_T2_Per': appGjT2Per,
    'APP_GJ_T2_kg': appGjT2Kg,
    'APP_GJ_JANKG': appGjJankg,
    'APP_GJ_BIGO': appGjBigo,
    'SMART_METER_YN': smartMeterYN,
  };
}
