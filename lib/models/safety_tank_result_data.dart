class SafetyTankResultData {
  static String? _s(dynamic v) => v?.toString();
  String? areaCode;
  String? anzCuCode;
  String? anzSno;
  String? anzDate;
  String? anzSwCode;
  String? anzSwName;
  String? anzTankKg01;
  String? anzTankKg02;
  String? anzTank01, anzTank01Bigo;
  String? anzTank02, anzTank02Bigo;
  String? anzTank03, anzTank03Bigo;
  String? anzTank04, anzTank04Bigo;
  String? anzTank05, anzTank05Bigo;
  String? anzTank06, anzTank06Bigo;
  String? anzTank07, anzTank07Bigo;
  String? anzTank08, anzTank08Bigo;
  String? anzTank09, anzTank09Bigo;
  String? anzCheckItem10;
  String? anzTank10, anzTank10Bigo;
  String? anzCheckItem11;
  String? anzTank11, anzTank11Bigo;
  String? anzCheckItem12;
  String? anzTank12, anzTank12Bigo;
  String? anzTankSwBigo1;
  String? anzTankSwBigo2;
  String? anzCustName;
  String? anzCuConfirmTel;
  String? anzSignYN;
  String? anzUserId;
  String? anzDateTime;

  SafetyTankResultData();

  SafetyTankResultData.fromJson(Map<String, dynamic> json) {
    areaCode = _s(json['Area_Code']);
    anzCuCode = _s(json['ANZ_Cu_Code']);
    anzSno = _s(json['ANZ_Sno']);
    anzDate = _s(json['ANZ_Date']);
    anzSwCode = _s(json['ANZ_SW_Code']);
    anzSwName = _s(json['ANZ_SW_Name']);
    anzTankKg01 = _s(json['ANZ_TANK_KG_01']);
    anzTankKg02 = _s(json['ANZ_TANK_KG_02']);
    anzTank01 = _s(json['ANZ_TANK_01']); anzTank01Bigo = _s(json['ANZ_TANK_01_Bigo']);
    anzTank02 = _s(json['ANZ_TANK_02']); anzTank02Bigo = _s(json['ANZ_TANK_02_Bigo']);
    anzTank03 = _s(json['ANZ_TANK_03']); anzTank03Bigo = _s(json['ANZ_TANK_03_Bigo']);
    anzTank04 = _s(json['ANZ_TANK_04']); anzTank04Bigo = _s(json['ANZ_TANK_04_Bigo']);
    anzTank05 = _s(json['ANZ_TANK_05']); anzTank05Bigo = _s(json['ANZ_TANK_05_Bigo']);
    anzTank06 = _s(json['ANZ_TANK_06']); anzTank06Bigo = _s(json['ANZ_TANK_06_Bigo']);
    anzTank07 = _s(json['ANZ_TANK_07']); anzTank07Bigo = _s(json['ANZ_TANK_07_Bigo']);
    anzTank08 = _s(json['ANZ_TANK_08']); anzTank08Bigo = _s(json['ANZ_TANK_08_Bigo']);
    anzTank09 = _s(json['ANZ_TANK_09']); anzTank09Bigo = _s(json['ANZ_TANK_09_Bigo']);
    anzCheckItem10 = _s(json['ANZ_Check_item_10']);
    anzTank10 = _s(json['ANZ_TANK_10']); anzTank10Bigo = _s(json['ANZ_TANK_10_Bigo']);
    anzCheckItem11 = _s(json['ANZ_Check_item_11']);
    anzTank11 = _s(json['ANZ_TANK_11']); anzTank11Bigo = _s(json['ANZ_TANK_11_Bigo']);
    anzCheckItem12 = _s(json['ANZ_Check_item_12']);
    anzTank12 = _s(json['ANZ_TANK_12']); anzTank12Bigo = _s(json['ANZ_TANK_12_Bigo']);
    anzTankSwBigo1 = _s(json['ANZ_TANK_SW_Bigo1']);
    anzTankSwBigo2 = _s(json['ANZ_TANK_SW_Bigo2']);
    anzCustName = _s(json['ANZ_CustName']);
    anzCuConfirmTel = _s(json['ANZ_CU_Confirm_TEL']);
    anzSignYN = _s(json['ANZ_Sign_YN']);
    anzUserId = _s(json['ANZ_User_ID']);
    anzDateTime = _s(json['ANZ_Date_Time']);
  }

  Map<String, dynamic> toJson() => {
    'Area_Code': areaCode, 'ANZ_Cu_Code': anzCuCode, 'ANZ_Sno': anzSno,
    'ANZ_Date': anzDate, 'ANZ_SW_Code': anzSwCode, 'ANZ_SW_Name': anzSwName,
    'ANZ_TANK_KG_01': anzTankKg01, 'ANZ_TANK_KG_02': anzTankKg02,
    'ANZ_TANK_01': anzTank01, 'ANZ_TANK_01_Bigo': anzTank01Bigo,
    'ANZ_TANK_02': anzTank02, 'ANZ_TANK_02_Bigo': anzTank02Bigo,
    'ANZ_TANK_03': anzTank03, 'ANZ_TANK_03_Bigo': anzTank03Bigo,
    'ANZ_TANK_04': anzTank04, 'ANZ_TANK_04_Bigo': anzTank04Bigo,
    'ANZ_TANK_05': anzTank05, 'ANZ_TANK_05_Bigo': anzTank05Bigo,
    'ANZ_TANK_06': anzTank06, 'ANZ_TANK_06_Bigo': anzTank06Bigo,
    'ANZ_TANK_07': anzTank07, 'ANZ_TANK_07_Bigo': anzTank07Bigo,
    'ANZ_TANK_08': anzTank08, 'ANZ_TANK_08_Bigo': anzTank08Bigo,
    'ANZ_TANK_09': anzTank09, 'ANZ_TANK_09_Bigo': anzTank09Bigo,
    'ANZ_Check_item_10': anzCheckItem10, 'ANZ_TANK_10': anzTank10, 'ANZ_TANK_10_Bigo': anzTank10Bigo,
    'ANZ_Check_item_11': anzCheckItem11, 'ANZ_TANK_11': anzTank11, 'ANZ_TANK_11_Bigo': anzTank11Bigo,
    'ANZ_Check_item_12': anzCheckItem12, 'ANZ_TANK_12': anzTank12, 'ANZ_TANK_12_Bigo': anzTank12Bigo,
    'ANZ_TANK_SW_Bigo1': anzTankSwBigo1, 'ANZ_TANK_SW_Bigo2': anzTankSwBigo2,
    'ANZ_CustName': anzCustName, 'ANZ_CU_Confirm_TEL': anzCuConfirmTel,
    'ANZ_Sign_YN': anzSignYN, 'ANZ_User_ID': anzUserId, 'ANZ_Date_Time': anzDateTime,
  };
}
