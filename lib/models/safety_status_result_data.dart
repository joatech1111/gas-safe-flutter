class SafetyStatusResultData {
  static String? _s(dynamic v) => v?.toString();
  String? checkType;
  String? safeName;
  String? cuTypeName;
  String? areaCode;
  String? anzCuCode;
  String? anzSno;
  String? anzCustName;
  String? anzDate;
  String? anzSwCode;
  String? anzSwName;
  String? safeResultYN;
  String? anzSignYN;
  String? anzDateTime;

  SafetyStatusResultData();

  SafetyStatusResultData.fromJson(Map<String, dynamic> json) {
    checkType = _s(json['Check_TYPE']);
    safeName = _s(json['SAFE_Name']);
    cuTypeName = _s(json['CU_Type_Name']);
    areaCode = _s(json['Area_Code']);
    anzCuCode = _s(json['ANZ_Cu_Code']);
    anzSno = _s(json['ANZ_Sno']);
    anzCustName = _s(json['ANZ_CustName']);
    anzDate = _s(json['ANZ_Date']);
    anzSwCode = _s(json['ANZ_SW_Code']);
    anzSwName = _s(json['ANZ_SW_Name']);
    safeResultYN = _s(json['SAFE_RESULT_YN']);
    anzSignYN = _s(json['ANZ_Sign_YN']);
    anzDateTime = _s(json['ANZ_Date_Time']);
  }

  Map<String, dynamic> toJson() => {
    'Check_TYPE': checkType, 'SAFE_Name': safeName, 'CU_Type_Name': cuTypeName,
    'Area_Code': areaCode, 'ANZ_Cu_Code': anzCuCode, 'ANZ_Sno': anzSno,
    'ANZ_CustName': anzCustName, 'ANZ_Date': anzDate,
    'ANZ_SW_Code': anzSwCode, 'ANZ_SW_Name': anzSwName,
    'SAFE_RESULT_YN': safeResultYN, 'ANZ_Sign_YN': anzSignYN, 'ANZ_Date_Time': anzDateTime,
  };
}
