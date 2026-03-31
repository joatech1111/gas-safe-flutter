class SafetyCheckContractResultData {
  static String? _s(dynamic v) => v?.toString();
  String? areaCode;
  String? anzCuCode;
  String? anzSno;
  String? anzDate;
  String? anzDateF;
  String? anzDateT;
  String? saleType;
  String? contType;
  String? useCyl;
  String? useCylMemo;
  String? useMeter;
  String? useMeterMemo;
  String? useTrans;
  String? useTransMemo;
  String? useVapor;
  String? useVaporMemo;
  String? usePipe;
  String? usePipeMemo;
  String? useFacility;
  String? centerSi;
  String? centerConsumer;
  String? centerKgs;
  String? centerGas;
  String? comBefore;
  String? comNo;
  String? comName;
  String? comTel;
  String? comHp;
  String? comCeoName;
  String? comSignYN;
  String? cuGongNo;
  String? custComNo;
  String? custComName;
  String? cuAddr1;
  String? cuAddr2;
  String? custTel;
  String? cuGongName;
  String? custSign;
  String? contFileUrl;
  String? anzCuConfirmTel;
  String? anzCuSmsYN;
  String? regDt;
  String? regUserId;
  String? regSwCode;
  String? regSwName;
  String? userNo;
  String? gpsX;
  String? gpsY;
  String? anzSign;
  String? anzSign2;

  SafetyCheckContractResultData();

  SafetyCheckContractResultData.fromJson(Map<String, dynamic> json) {
    areaCode = _s(json['AREA_CODE']);
    anzCuCode = _s(json['ANZ_Cu_Code']);
    anzSno = _s(json['ANZ_Sno']);
    anzDate = _s(json['ANZ_Date']);
    anzDateF = _s(json['ANZ_Date_F']);
    anzDateT = _s(json['ANZ_Date_T']);
    saleType = _s(json['SALE_TYPE']);
    contType = _s(json['CONT_TYPE']);
    useCyl = _s(json['USE_CYL']);
    useCylMemo = _s(json['USE_CYL_MEMO']);
    useMeter = _s(json['USE_METER']);
    useMeterMemo = _s(json['USE_METER_MEMO']);
    useTrans = _s(json['USE_TRANS']);
    useTransMemo = _s(json['USE_TRANS_MEMO']);
    useVapor = _s(json['USE_VAPOR']);
    useVaporMemo = _s(json['USE_VAPOR_MEMO']);
    usePipe = _s(json['USE_PIPE']);
    usePipeMemo = _s(json['USE_PIPE_MEMO']);
    useFacility = _s(json['USE_Facility']);
    centerSi = _s(json['CENTER_SI']);
    centerConsumer = _s(json['CENTER_Consumer']);
    centerKgs = _s(json['CENTER_KGS']);
    centerGas = _s(json['CENTER_GAS']);
    comBefore = _s(json['COM_BEFORE']);
    comNo = _s(json['COM_NO']);
    comName = _s(json['COM_NAME']);
    comTel = _s(json['COM_TEL']);
    comHp = _s(json['COM_HP']);
    comCeoName = _s(json['COM_CEO_NAME']);
    comSignYN = _s(json['COM_SIGN_YN']);
    cuGongNo = _s(json['CU_GONGNO']);
    custComNo = _s(json['CUST_COM_NO']);
    custComName = _s(json['CUST_COM_NAME']);
    cuAddr1 = _s(json['CU_ADDR1']);
    cuAddr2 = _s(json['CU_ADDR2']);
    custTel = _s(json['CUST_TEL']);
    cuGongName = _s(json['CU_GONGNAME']);
    custSign = _s(json['CUST_SIGN']);
    contFileUrl = _s(json['CONT_FILE_URL']);
    anzCuConfirmTel = _s(json['ANZ_CU_Confirm_TEL']);
    anzCuSmsYN = _s(json['ANZ_CU_SMS_YN']);
    regDt = _s(json['REG_DT']);
    regUserId = _s(json['REG_USER_ID']);
    regSwCode = _s(json['REG_SW_CODE']);
    regSwName = _s(json['REG_SW_NAME']);
    userNo = _s(json['USERNO']);
    gpsX = _s(json['GPS_X']);
    gpsY = _s(json['GPS_Y']);
    anzSign = _s(json['ANZ_Sign']);
    anzSign2 = _s(json['ANZ_Sign2']);
  }

  Map<String, dynamic> toJson() => {
    'AREA_CODE': areaCode,
    'ANZ_Cu_Code': anzCuCode,
    'ANZ_Sno': anzSno,
    'ANZ_Date': anzDate,
    'ANZ_Date_F': anzDateF,
    'ANZ_Date_T': anzDateT,
    'SALE_TYPE': saleType,
    'CONT_TYPE': contType,
    'USE_CYL': useCyl,
    'USE_CYL_MEMO': useCylMemo,
    'USE_METER': useMeter,
    'USE_METER_MEMO': useMeterMemo,
    'USE_TRANS': useTrans,
    'USE_TRANS_MEMO': useTransMemo,
    'USE_VAPOR': useVapor,
    'USE_VAPOR_MEMO': useVaporMemo,
    'USE_PIPE': usePipe,
    'USE_PIPE_MEMO': usePipeMemo,
    'USE_Facility': useFacility,
    'CENTER_SI': centerSi,
    'CENTER_Consumer': centerConsumer,
    'CENTER_KGS': centerKgs,
    'CENTER_GAS': centerGas,
    'COM_BEFORE': comBefore,
    'COM_NO': comNo,
    'COM_NAME': comName,
    'COM_TEL': comTel,
    'COM_HP': comHp,
    'COM_CEO_NAME': comCeoName,
    'COM_SIGN_YN': comSignYN,
    'CU_GONGNO': cuGongNo,
    'CUST_COM_NO': custComNo,
    'CUST_COM_NAME': custComName,
    'CU_ADDR1': cuAddr1,
    'CU_ADDR2': cuAddr2,
    'CUST_TEL': custTel,
    'CU_GONGNAME': cuGongName,
    'CUST_SIGN': custSign,
    'CONT_FILE_URL': contFileUrl,
    'ANZ_CU_Confirm_TEL': anzCuConfirmTel,
    'ANZ_CU_SMS_YN': anzCuSmsYN,
    'REG_DT': regDt,
    'REG_USER_ID': regUserId,
    'REG_SW_CODE': regSwCode,
    'REG_SW_NAME': regSwName,
    'USERNO': userNo,
    'GPS_X': gpsX,
    'GPS_Y': gpsY,
    'ANZ_Sign': anzSign,
    'ANZ_Sign2': anzSign2,
  };
}
