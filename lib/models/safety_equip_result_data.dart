class SafetyEquipResultData {
  static String? _s(dynamic v) => v?.toString();
  String? areaCode;
  String? anzCuCode;
  String? anzSno;
  String? anzCustName;
  String? anzGongNo;
  String? anzGongName;
  String? anzTel;
  String? cuZipcode;
  String? cuAddr1;
  String? cuAddr2;
  String? anzGongDate;
  String? anzDate;
  String? anzSwCode;
  String? anzSwName;
  String? anzA01, anzA02, anzA03, anzA04, anzA05;
  String? anzB01, anzB02, anzB03, anzB04, anzB05;
  String? anzC01, anzC02, anzC03, anzC04, anzC05, anzC06, anzC07, anzC08;
  String? anzGita01;
  String? anzD01, anzD02, anzD03, anzD04, anzD05;
  String? anzE01, anzE02, anzE03, anzE04;
  String? anzF01, anzF02, anzF03, anzF04;
  String? anzG01, anzG02, anzG03, anzG04, anzG05, anzG06, anzG07, anzG08;
  String? anzGita02;
  String? anzGa, anzNa, anzDa, anzRa, anzMa, anzBa, anzSa, anzAA, anzJa;
  String? anzChaIn, anzCha, anzCar;
  String? anzGae01, anzGae02, anzGae03, anzGae04;
  String? anzCuConfirm;
  String? anzCuConfirmTel;
  String? anzCuSmsYN;
  String? anzSignYN;
  String? anzAppUser;
  String? anzDateTime;
  String? anzFinishDate;
  String? anzCircuitDate;

  SafetyEquipResultData();

  SafetyEquipResultData.fromJson(Map<String, dynamic> json) {
    areaCode = _s(json['Area_Code']);
    anzCuCode = _s(json['ANZ_Cu_Code']);
    anzSno = _s(json['ANZ_Sno']);
    anzCustName = _s(json['ANZ_CustName']);
    anzGongNo = _s(json['ANZ_GongNo']);
    anzGongName = _s(json['ANZ_GongName']);
    anzTel = _s(json['ANZ_Tel']);
    cuZipcode = _s(json['CU_ZIPCODE']);
    cuAddr1 = _s(json['CU_ADDR1']);
    cuAddr2 = _s(json['CU_ADDR2']);
    anzGongDate = _s(json['ANZ_GongDate']);
    anzDate = _s(json['ANZ_Date']);
    anzSwCode = _s(json['ANZ_SW_Code']);
    anzSwName = _s(json['ANZ_SW_Name']);
    anzA01 = _s(json['ANZ_A_01']); anzA02 = _s(json['ANZ_A_02']); anzA03 = _s(json['ANZ_A_03']); anzA04 = _s(json['ANZ_A_04']); anzA05 = _s(json['ANZ_A_05']);
    anzB01 = _s(json['ANZ_B_01']); anzB02 = _s(json['ANZ_B_02']); anzB03 = _s(json['ANZ_B_03']); anzB04 = _s(json['ANZ_B_04']); anzB05 = _s(json['ANZ_B_05']);
    anzC01 = _s(json['ANZ_C_01']); anzC02 = _s(json['ANZ_C_02']); anzC03 = _s(json['ANZ_C_03']); anzC04 = _s(json['ANZ_C_04']); anzC05 = _s(json['ANZ_C_05']);
    anzC06 = _s(json['ANZ_C_06']); anzC07 = _s(json['ANZ_C_07']); anzC08 = _s(json['ANZ_C_08']);
    anzGita01 = _s(json['ANZ_Gita_01']);
    anzD01 = _s(json['ANZ_D_01']); anzD02 = _s(json['ANZ_D_02']); anzD03 = _s(json['ANZ_D_03']); anzD04 = _s(json['ANZ_D_04']); anzD05 = _s(json['ANZ_D_05']);
    anzE01 = _s(json['ANZ_E_01']); anzE02 = _s(json['ANZ_E_02']); anzE03 = _s(json['ANZ_E_03']); anzE04 = _s(json['ANZ_E_04']);
    anzF01 = _s(json['ANZ_F_01']); anzF02 = _s(json['ANZ_F_02']); anzF03 = _s(json['ANZ_F_03']); anzF04 = _s(json['ANZ_F_04']);
    anzG01 = _s(json['ANZ_G_01']); anzG02 = _s(json['ANZ_G_02']); anzG03 = _s(json['ANZ_G_03']); anzG04 = _s(json['ANZ_G_04']);
    anzG05 = _s(json['ANZ_G_05']); anzG06 = _s(json['ANZ_G_06']); anzG07 = _s(json['ANZ_G_07']); anzG08 = _s(json['ANZ_G_08']);
    anzGita02 = _s(json['ANZ_Gita_02']);
    anzGa = _s(json['ANZ_Ga']); anzNa = _s(json['ANZ_Na']); anzDa = _s(json['ANZ_Da']); anzRa = _s(json['ANZ_Ra']);
    anzMa = _s(json['ANZ_Ma']); anzBa = _s(json['ANZ_Ba']); anzSa = _s(json['ANZ_Sa']); anzAA = _s(json['ANZ_AA']); anzJa = _s(json['ANZ_Ja']);
    anzChaIn = _s(json['ANZ_Cha_IN']); anzCha = _s(json['ANZ_Cha']); anzCar = _s(json['ANZ_Car']);
    anzGae01 = _s(json['ANZ_Gae_01']); anzGae02 = _s(json['ANZ_Gae_02']); anzGae03 = _s(json['ANZ_Gae_03']); anzGae04 = _s(json['ANZ_Gae_04']);
    anzCuConfirm = _s(json['ANZ_CU_Confirm']);
    anzCuConfirmTel = _s(json['ANZ_CU_Confirm_TEL']);
    anzCuSmsYN = _s(json['ANZ_CU_SMS_YN']);
    anzSignYN = _s(json['ANZ_Sign_YN']);
    anzAppUser = _s(json['ANZ_APP_User']);
    anzDateTime = _s(json['ANZ_Date_Time']);
    anzFinishDate = _s(json['ANZ_Finish_DATE']);
    anzCircuitDate = _s(json['ANZ_Circuit_DATE']);
  }

  Map<String, dynamic> toJson() => {
    'Area_Code': areaCode, 'ANZ_Cu_Code': anzCuCode, 'ANZ_Sno': anzSno,
    'ANZ_CustName': anzCustName, 'ANZ_GongNo': anzGongNo, 'ANZ_GongName': anzGongName,
    'ANZ_Tel': anzTel, 'CU_ZIPCODE': cuZipcode, 'CU_ADDR1': cuAddr1, 'CU_ADDR2': cuAddr2,
    'ANZ_GongDate': anzGongDate, 'ANZ_Date': anzDate, 'ANZ_SW_Code': anzSwCode, 'ANZ_SW_Name': anzSwName,
    'ANZ_A_01': anzA01, 'ANZ_A_02': anzA02, 'ANZ_A_03': anzA03, 'ANZ_A_04': anzA04, 'ANZ_A_05': anzA05,
    'ANZ_B_01': anzB01, 'ANZ_B_02': anzB02, 'ANZ_B_03': anzB03, 'ANZ_B_04': anzB04, 'ANZ_B_05': anzB05,
    'ANZ_C_01': anzC01, 'ANZ_C_02': anzC02, 'ANZ_C_03': anzC03, 'ANZ_C_04': anzC04, 'ANZ_C_05': anzC05,
    'ANZ_C_06': anzC06, 'ANZ_C_07': anzC07, 'ANZ_C_08': anzC08,
    'ANZ_Gita_01': anzGita01,
    'ANZ_D_01': anzD01, 'ANZ_D_02': anzD02, 'ANZ_D_03': anzD03, 'ANZ_D_04': anzD04, 'ANZ_D_05': anzD05,
    'ANZ_E_01': anzE01, 'ANZ_E_02': anzE02, 'ANZ_E_03': anzE03, 'ANZ_E_04': anzE04,
    'ANZ_F_01': anzF01, 'ANZ_F_02': anzF02, 'ANZ_F_03': anzF03, 'ANZ_F_04': anzF04,
    'ANZ_G_01': anzG01, 'ANZ_G_02': anzG02, 'ANZ_G_03': anzG03, 'ANZ_G_04': anzG04,
    'ANZ_G_05': anzG05, 'ANZ_G_06': anzG06, 'ANZ_G_07': anzG07, 'ANZ_G_08': anzG08,
    'ANZ_Gita_02': anzGita02,
    'ANZ_Ga': anzGa, 'ANZ_Na': anzNa, 'ANZ_Da': anzDa, 'ANZ_Ra': anzRa,
    'ANZ_Ma': anzMa, 'ANZ_Ba': anzBa, 'ANZ_Sa': anzSa, 'ANZ_AA': anzAA, 'ANZ_Ja': anzJa,
    'ANZ_Cha_IN': anzChaIn, 'ANZ_Cha': anzCha, 'ANZ_Car': anzCar,
    'ANZ_Gae_01': anzGae01, 'ANZ_Gae_02': anzGae02, 'ANZ_Gae_03': anzGae03, 'ANZ_Gae_04': anzGae04,
    'ANZ_CU_Confirm': anzCuConfirm, 'ANZ_CU_Confirm_TEL': anzCuConfirmTel,
    'ANZ_CU_SMS_YN': anzCuSmsYN, 'ANZ_Sign_YN': anzSignYN,
    'ANZ_APP_User': anzAppUser, 'ANZ_Date_Time': anzDateTime,
    'ANZ_Finish_DATE': anzFinishDate, 'ANZ_Circuit_DATE': anzCircuitDate,
  };
}
