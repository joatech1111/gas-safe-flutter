class MetersCustomerResultData {
  static String? _s(dynamic v) => v?.toString();
  String? areaCode;
  String? cuCode;
  String? cuType;
  String? cuTypeName;
  String? cuNameView;
  String? cuName;
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
  String? cuSTae;
  String? cuSTaeName;
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
  String? smartMeterYN;
  String? transmYN;
  String? barcodeYN;
  String? transm01YN;
  String? transm02YN;
  String? cuTankYN;
  String? tankVol01;
  String? tankMax01;
  String? tankVol02;
  String? tankMax02;
  String? gjDate;
  String? gjGum;
  String? gjJankg;
  String? gjGage;
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
  String? lastGumDate;

  MetersCustomerResultData();

  MetersCustomerResultData.fromJson(Map<String, dynamic> json) {
    areaCode = _s(json['AREA_Code']);
    cuCode = _s(json['CU_Code']);
    cuType = _s(json['CU_Type']);
    cuTypeName = _s(json['CU_Type_Name']);
    cuNameView = _s(json['CU_Name_View']);
    cuName = _s(json['CU_Name']);
    cuUserName = _s(json['CU_UserName']);
    cuTel = _s(json['CU_Tel']);
    cuHp = _s(json['CU_HP']);
    cuZipcode = _s(json['CU_ZIPCODE']);
    cuAddr1 = _s(json['CU_ADDR1']);
    cuAddr2 = _s(json['CU_ADDR2']);
    cuAddr = _s(json['CU_ADDR']);
    cuBigo1 = _s(json['CU_Bigo1']);
    cuBigo2 = _s(json['CU_Bigo2']);
    cuSwCode = _s(json['CU_SW_CODE']);
    cuSwName = _s(json['CU_SW_NAME']);
    cuCuType = _s(json['CU_CUType']);
    cuCuTypeName = _s(json['CU_CUTYPE_Name']);
    cuSTae = _s(json['CU_STae']);
    cuSTaeName = _s(json['CU_STae_Name']);
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
    smartMeterYN = _s(json['SMART_METER_YN']);
    transmYN = _s(json['TRANSM_YN']);
    barcodeYN = _s(json['BARCODE_YN']);
    transm01YN = _s(json['TRANSM_01_YN']);
    transm02YN = _s(json['TRANSM_02_YN']);
    cuTankYN = _s(json['CU_TANK_YN']);
    tankVol01 = _s(json['TANK_VOL_01']);
    tankMax01 = _s(json['TANK_MAX_01']);
    tankVol02 = _s(json['TANK_VOL_02']);
    tankMax02 = _s(json['TANK_MAX_02']);
    gjDate = _s(json['GJ_DATE']);
    gjGum = _s(json['GJ_GUM']);
    gjJankg = _s(json['GJ_JANKG']);
    gjGage = _s(json['GJ_GAGE']);
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
    lastGumDate = _s(json['LAST_GUM_DATE']);
  }

  Map<String, dynamic> toJson() => {
    'AREA_Code': areaCode,
    'CU_Code': cuCode,
    'CU_Type': cuType,
    'CU_Type_Name': cuTypeName,
    'CU_Name_View': cuNameView,
    'CU_Name': cuName,
    'CU_UserName': cuUserName,
    'CU_Tel': cuTel,
    'CU_HP': cuHp,
    'CU_ZIPCODE': cuZipcode,
    'CU_ADDR1': cuAddr1,
    'CU_ADDR2': cuAddr2,
    'CU_ADDR': cuAddr,
    'CU_Bigo1': cuBigo1,
    'CU_Bigo2': cuBigo2,
    'CU_SW_CODE': cuSwCode,
    'CU_SW_NAME': cuSwName,
    'CU_CUType': cuCuType,
    'CU_CUTYPE_Name': cuCuTypeName,
    'CU_STae': cuSTae,
    'CU_STae_Name': cuSTaeName,
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
    'SMART_METER_YN': smartMeterYN,
    'TRANSM_YN': transmYN,
    'BARCODE_YN': barcodeYN,
    'TRANSM_01_YN': transm01YN,
    'TRANSM_02_YN': transm02YN,
    'CU_TANK_YN': cuTankYN,
    'TANK_VOL_01': tankVol01,
    'TANK_MAX_01': tankMax01,
    'TANK_VOL_02': tankVol02,
    'TANK_MAX_02': tankMax02,
    'GJ_DATE': gjDate,
    'GJ_GUM': gjGum,
    'GJ_JANKG': gjJankg,
    'GJ_GAGE': gjGage,
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
    'LAST_GUM_DATE': lastGumDate,
  };
}
