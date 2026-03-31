class SafetyCustomerResultData {
  String? areaCode;
  String? cuCode;
  String? cuType;
  String? cuTypeName;
  String? cuNameView;
  String? cuName;
  String? cuFullName;
  String? cuUserName;
  String? cuTel;
  String? cuHp;
  String? cuZipcode;
  String? cuAddr1;
  String? cuAddr2;
  String? cuAddr;
  String? cuBigo1;
  String? cuBigo2;
  String? cuSwCode;
  String? cuSwName;
  String? cuCuType;
  String? cuCuTypeName;
  String? cuStae;
  String? cuStaeName;
  String? cuBarcode;
  String? cuMeterNo;
  String? cuGumTurm;
  String? cuGumDate;
  String? cuMeterCo;
  String? cuMeterLR;
  String? cuMeterType;
  String? cuMeterM3;
  String? cuMeterDT;
  String? cuCNo;
  String? cuSisulYN;
  String? cuGongNo;
  String? cuGongName;
  String? cuGongDate;
  String? cuSafeDate;
  String? cuSafeFlan;
  String? cuTankYN;

  SafetyCustomerResultData();

  static String? _s(dynamic v) => v?.toString();

  SafetyCustomerResultData.fromJson(Map<String, dynamic> json) {
    areaCode = _s(json['AREA_CODE']);
    cuCode = _s(json['CU_CODE']);
    cuType = _s(json['CU_Type']);
    cuTypeName = _s(json['CU_Type_Name']);
    cuNameView = _s(json['CU_Name_View']);
    cuName = _s(json['CU_NAME']);
    cuFullName = _s(json['CU_FULL_NAME']);
    cuUserName = _s(json['CU_USERNAME']);
    cuTel = _s(json['CU_TEL']);
    cuHp = _s(json['CU_HP']);
    cuZipcode = _s(json['CU_ZIPCODE']);
    cuAddr1 = _s(json['CU_ADDR1']);
    cuAddr2 = _s(json['CU_ADDR2']);
    cuAddr = _s(json['CU_ADDR']);
    cuBigo1 = _s(json['CU_Bigo1']);
    cuBigo2 = _s(json['CU_Bigo2']);
    cuSwCode = _s(json['CU_SW_CODE']);
    cuSwName = _s(json['CU_SW_NAME']);
    cuCuType = _s(json['CU_CUTYPE']);
    cuCuTypeName = _s(json['CU_CUTYPE_Name']);
    cuStae = _s(json['CU_Stae']);
    cuStaeName = _s(json['CU_STae_Name']);
    cuBarcode = _s(json['CU_Barcode']);
    cuMeterNo = _s(json['CU_Meter_No']);
    cuGumTurm = _s(json['CU_Gum_Turm']);
    cuGumDate = _s(json['CU_GumDate']);
    cuMeterCo = _s(json['CU_Meter_Co']);
    cuMeterLR = _s(json['CU_Meter_LR']);
    cuMeterType = _s(json['CU_Meter_TYPE']);
    cuMeterM3 = _s(json['CU_Meter_M3']);
    cuMeterDT = _s(json['CU_Meter_DT']);
    cuCNo = _s(json['CU_CNo']);
    cuSisulYN = _s(json['CU_SisulYN']);
    cuGongNo = _s(json['CU_GongNo']);
    cuGongName = _s(json['CU_GongName']);
    cuGongDate = _s(json['CU_GongDate']);
    cuSafeDate = _s(json['CU_SAFE_DATE']);
    cuSafeFlan = _s(json['CU_SAFE_FLAN']);
    cuTankYN = _s(json['CU_Tank_YN']);
  }

  Map<String, dynamic> toJson() => {
    'AREA_CODE': areaCode,
    'CU_CODE': cuCode,
    'CU_Type': cuType,
    'CU_Type_Name': cuTypeName,
    'CU_Name_View': cuNameView,
    'CU_NAME': cuName,
    'CU_FULL_NAME': cuFullName,
    'CU_USERNAME': cuUserName,
    'CU_TEL': cuTel,
    'CU_HP': cuHp,
    'CU_ZIPCODE': cuZipcode,
    'CU_ADDR1': cuAddr1,
    'CU_ADDR2': cuAddr2,
    'CU_ADDR': cuAddr,
    'CU_Bigo1': cuBigo1,
    'CU_Bigo2': cuBigo2,
    'CU_SW_CODE': cuSwCode,
    'CU_SW_NAME': cuSwName,
    'CU_CUTYPE': cuCuType,
    'CU_CUTYPE_Name': cuCuTypeName,
    'CU_Stae': cuStae,
    'CU_STae_Name': cuStaeName,
    'CU_Barcode': cuBarcode,
    'CU_Meter_No': cuMeterNo,
    'CU_Gum_Turm': cuGumTurm,
    'CU_GumDate': cuGumDate,
    'CU_Meter_Co': cuMeterCo,
    'CU_Meter_LR': cuMeterLR,
    'CU_Meter_TYPE': cuMeterType,
    'CU_Meter_M3': cuMeterM3,
    'CU_Meter_DT': cuMeterDT,
    'CU_CNo': cuCNo,
    'CU_SisulYN': cuSisulYN,
    'CU_GongNo': cuGongNo,
    'CU_GongName': cuGongName,
    'CU_GongDate': cuGongDate,
    'CU_SAFE_DATE': cuSafeDate,
    'CU_SAFE_FLAN': cuSafeFlan,
    'CU_Tank_YN': cuTankYN,
  };
}
