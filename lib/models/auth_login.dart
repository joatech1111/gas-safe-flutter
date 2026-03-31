class AuthLogin {
  static String? _s(dynamic v) => v?.toString();
  String? hpSno;
  String? loginCo;
  String? loginName;
  String? loginUser;
  String? loginPass;
  String? baAreaCode;
  String? baSwCode;
  String? baGubunCode;
  String? baJyCode;
  String? baOrderBy;
  String? safeSwCode;
  String? licenseDate;
  String? loginStartDate;
  String? loginLastDate;
  String? loginEndDate;
  String? loginInfo;
  String? loginMemo;
  String? appCert;
  String? gpsSearchYn;
  String? sToken;
  String? safeSwName;

  AuthLogin();

  AuthLogin.fromJson(Map<String, dynamic> json) {
    hpSno = _s(json['HP_SNO']);
    loginCo = _s(json['Login_Co']);
    loginName = _s(json['Login_Name']);
    loginUser = _s(json['Login_User']);
    loginPass = _s(json['Login_Pass']);
    baAreaCode = _s(json['BA_Area_CODE']);
    baSwCode = _s(json['BA_SW_CODE']);
    baGubunCode = _s(json['BA_Gubun_CODE']);
    baJyCode = _s(json['BA_JY_Code']);
    baOrderBy = _s(json['BA_OrderBy']);
    safeSwCode = _s(json['Safe_SW_CODE']);
    licenseDate = _s(json['License_Date']);
    loginStartDate = _s(json['Login_StartDate']);
    loginLastDate = _s(json['Login_LastDate']);
    loginEndDate = _s(json['Login_EndDate']);
    loginInfo = _s(json['Login_info']);
    loginMemo = _s(json['Login_Memo']);
    appCert = _s(json['APP_Cert']);
    gpsSearchYn = _s(json['GPS_SEARCH_YN']);
    sToken = _s(json['sToken']);
    safeSwName = _s(json['Safe_SW_NAME']);
  }

  Map<String, dynamic> toJson() => {
    'HP_SNO': hpSno,
    'Login_Co': loginCo,
    'Login_Name': loginName,
    'Login_User': loginUser,
    'Login_Pass': loginPass,
    'BA_Area_CODE': baAreaCode,
    'BA_SW_CODE': baSwCode,
    'BA_Gubun_CODE': baGubunCode,
    'BA_JY_Code': baJyCode,
    'BA_OrderBy': baOrderBy,
    'Safe_SW_CODE': safeSwCode,
    'License_Date': licenseDate,
    'Login_StartDate': loginStartDate,
    'Login_LastDate': loginLastDate,
    'Login_EndDate': loginEndDate,
    'Login_info': loginInfo,
    'Login_Memo': loginMemo,
    'APP_Cert': appCert,
    'GPS_SEARCH_YN': gpsSearchYn,
    'sToken': sToken,
    'Safe_SW_NAME': safeSwName,
  };

  bool certAreaCode() {
    if (appCert == null || appCert!.isEmpty) return false;
    if (appCert!.length <= 5) return false;
    return appCert![0] == '0';
  }

  bool certSW() {
    if (appCert == null || appCert!.isEmpty) return false;
    if (appCert!.length <= 5) return false;
    return appCert![1] == '0';
  }

  bool certGubun() {
    if (appCert == null || appCert!.isEmpty) return false;
    if (appCert!.length <= 5) return false;
    return appCert![2] == '0';
  }

  bool certAreaType() {
    if (appCert == null || appCert!.isEmpty) return false;
    if (appCert!.length <= 5) return false;
    return appCert![3] == '0';
  }

  bool certSafeSW() {
    if (appCert == null || appCert!.isEmpty) return false;
    if (appCert!.length <= 5) return false;
    return appCert![4] == '0';
  }

  bool certMenu(List<String> requiredPermissions) {
    if (appCert == null || appCert!.isEmpty) return false;
    if (appCert!.length <= 5) return false;
    return requiredPermissions.contains(appCert![5]);
  }

  bool certCustomer(List<String> requiredPermissions) {
    if (appCert == null || appCert!.isEmpty) return false;
    if (appCert!.length <= 6) return false;
    return requiredPermissions.contains(appCert![6]);
  }
}
