class SafetySavingResultData {
  static String? _s(dynamic v) => v?.toString();
  String? areaCode;
  String? anzCuCode;
  String? anzSno;
  String? anzDate;
  String? anzSwCode;
  String? anzSwName;
  String? anzLpKg01;
  String? anzLpKg02;
  String? anzItem1, anzItem1Sub, anzItem1Text;
  String? anzItem2, anzItem2Sub;
  String? anzItem3, anzItem3Sub, anzItem3Text;
  String? anzItem4, anzItem4Sub;
  String? anzItem5, anzItem5Sub, anzItem5Text;
  String? anzItem6, anzItem6Sub;
  String? anzItem7, anzItem7Sub;
  String? anzItem8, anzItem8Sub, anzItem8Text;
  String? anzItem9, anzItem9Sub, anzItem9Text1, anzItem9Text2;
  String? anzItem10, anzItem10Text1, anzItem10Text2;
  String? anzCuConfirm;
  String? anzCuConfirmTel;
  String? anzSignYN;
  String? anzUserId;
  String? anzDateTime;

  SafetySavingResultData();

  SafetySavingResultData.fromJson(Map<String, dynamic> json) {
    areaCode = _s(json['AREA_CODE']);
    anzCuCode = _s(json['ANZ_Cu_Code']);
    anzSno = _s(json['ANZ_Sno']);
    anzDate = _s(json['ANZ_Date']);
    anzSwCode = _s(json['ANZ_SW_Code']);
    anzSwName = _s(json['ANZ_SW_Name']);
    anzLpKg01 = _s(json['ANZ_LP_KG_01']);
    anzLpKg02 = _s(json['ANZ_LP_KG_02']);
    anzItem1 = _s(json['ANZ_Item1']); anzItem1Sub = _s(json['ANZ_Item1_SUB']); anzItem1Text = _s(json['ANZ_Item1_Text']);
    anzItem2 = _s(json['ANZ_Item2']); anzItem2Sub = _s(json['ANZ_Item2_SUB']);
    anzItem3 = _s(json['ANZ_Item3']); anzItem3Sub = _s(json['ANZ_Item3_SUB']); anzItem3Text = _s(json['ANZ_Item3_Text']);
    anzItem4 = _s(json['ANZ_Item4']); anzItem4Sub = _s(json['ANZ_Item4_SUB']);
    anzItem5 = _s(json['ANZ_Item5']); anzItem5Sub = _s(json['ANZ_Item5_SUB']); anzItem5Text = _s(json['ANZ_Item5_Text']);
    anzItem6 = _s(json['ANZ_Item6']); anzItem6Sub = _s(json['ANZ_Item6_SUB']);
    anzItem7 = _s(json['ANZ_Item7']); anzItem7Sub = _s(json['ANZ_Item7_SUB']);
    anzItem8 = _s(json['ANZ_Item8']); anzItem8Sub = _s(json['ANZ_Item8_SUB']); anzItem8Text = _s(json['ANZ_Item8_Text']);
    anzItem9 = _s(json['ANZ_Item9']); anzItem9Sub = _s(json['ANZ_Item9_SUB']); anzItem9Text1 = _s(json['ANZ_Item9_Text1']); anzItem9Text2 = _s(json['ANZ_Item9_Text2']);
    anzItem10 = _s(json['ANZ_Item10']); anzItem10Text1 = _s(json['ANZ_Item10_Text1']); anzItem10Text2 = _s(json['ANZ_Item10_Text2']);
    anzCuConfirm = _s(json['ANZ_CU_Confirm']);
    anzCuConfirmTel = _s(json['ANZ_CU_Confirm_TEL']);
    anzSignYN = _s(json['ANZ_Sign_YN']);
    anzUserId = _s(json['ANZ_User_ID']);
    anzDateTime = _s(json['ANZ_Date_Time']);
  }

  Map<String, dynamic> toJson() => {
    'AREA_CODE': areaCode, 'ANZ_Cu_Code': anzCuCode, 'ANZ_Sno': anzSno,
    'ANZ_Date': anzDate, 'ANZ_SW_Code': anzSwCode, 'ANZ_SW_Name': anzSwName,
    'ANZ_LP_KG_01': anzLpKg01, 'ANZ_LP_KG_02': anzLpKg02,
    'ANZ_Item1': anzItem1, 'ANZ_Item1_SUB': anzItem1Sub, 'ANZ_Item1_Text': anzItem1Text,
    'ANZ_Item2': anzItem2, 'ANZ_Item2_SUB': anzItem2Sub,
    'ANZ_Item3': anzItem3, 'ANZ_Item3_SUB': anzItem3Sub, 'ANZ_Item3_Text': anzItem3Text,
    'ANZ_Item4': anzItem4, 'ANZ_Item4_SUB': anzItem4Sub,
    'ANZ_Item5': anzItem5, 'ANZ_Item5_SUB': anzItem5Sub, 'ANZ_Item5_Text': anzItem5Text,
    'ANZ_Item6': anzItem6, 'ANZ_Item6_SUB': anzItem6Sub,
    'ANZ_Item7': anzItem7, 'ANZ_Item7_SUB': anzItem7Sub,
    'ANZ_Item8': anzItem8, 'ANZ_Item8_SUB': anzItem8Sub, 'ANZ_Item8_Text': anzItem8Text,
    'ANZ_Item9': anzItem9, 'ANZ_Item9_SUB': anzItem9Sub, 'ANZ_Item9_Text1': anzItem9Text1, 'ANZ_Item9_Text2': anzItem9Text2,
    'ANZ_Item10': anzItem10, 'ANZ_Item10_Text1': anzItem10Text1, 'ANZ_Item10_Text2': anzItem10Text2,
    'ANZ_CU_Confirm': anzCuConfirm, 'ANZ_CU_Confirm_TEL': anzCuConfirmTel,
    'ANZ_Sign_YN': anzSignYN, 'ANZ_User_ID': anzUserId, 'ANZ_Date_Time': anzDateTime,
  };
}
