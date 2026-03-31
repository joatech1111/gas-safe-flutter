import 'dart:convert';
import '../models/auth_login.dart';
import '../models/combo_data.dart';
import '../utils/keys.dart';
import '../utils/prefs_util.dart';

class AppState {
  static AuthLogin? loginUser;

  static List<ComboData> comboSw = [];
  static List<ComboData> comboSort = [];
  static List<ComboData> comboMan = [];
  static List<ComboData> comboSafe = [];
  static List<ComboData> comboJy = [];
  static List<ComboData> comboApt = [];
  static List<ComboData> comboGumm = [];
  static List<ComboData> comboGum = [];
  static List<ComboData> comboMeter = [];
  static List<ComboData> comboMLR = [];
  static List<ComboData> comboMTY = [];

  static void setLoginUser(AuthLogin user) {
    loginUser = user;
    PrefsUtil.setString(Keys.prefLoginUser, json.encode(user.toJson()));
  }

  static AuthLogin? getLoginUser() {
    if (loginUser != null) return loginUser;
    loginUser = PrefsUtil.fromJson(Keys.prefLoginUser, (j) => AuthLogin.fromJson(j));
    return loginUser;
  }

  static void clearLoginUser() {
    loginUser = null;
    PrefsUtil.remove(Keys.prefLoginUser);
  }

  static String get areaCode => loginUser?.baAreaCode?.trim() ?? '';
  static String get swCode => loginUser?.baSwCode?.trim() ?? '';
  static String get gubunCode => loginUser?.baGubunCode?.trim() ?? '';
  static String get jyCode => loginUser?.baJyCode?.trim() ?? '';
  static String get orderBy => loginUser?.baOrderBy?.trim() ?? '';
  static String get safeSwCode => loginUser?.safeSwCode?.trim() ?? '';
  static String get safeSwName => loginUser?.safeSwName?.trim() ?? '';
  static String get loginUserId => loginUser?.loginUser?.trim() ?? '';

  static void parseConfigAll(Map<String, dynamic>? resultData) {
    if (resultData == null) return;
    comboSw = _parseComboList(resultData['SW']);
    comboSort = _parseComboList(resultData['SORT']);
    comboMan = _parseComboList(resultData['MAN']);
    comboSafe = _parseComboList(resultData['SAFE']);
    comboJy = _parseComboList(resultData['JY']);
  }

  static void parseMetersCondition(Map<String, dynamic>? resultData) {
    if (resultData == null) return;
    comboGumm = _parseComboList(resultData['GUMM']);
    comboApt = _parseComboList(resultData['APT']);
    comboSw = _parseComboList(resultData['SW']);
    comboMan = _parseComboList(resultData['MAN']);
    comboJy = _parseComboList(resultData['JY']);
    comboSort = _parseComboList(resultData['SORT']);
    comboGum = _parseComboList(resultData['GUM']);
    comboMeter = _parseComboList(resultData['METER']);
    comboMLR = _parseComboList(resultData['M-LR'] ?? resultData['MLR']);
    comboMTY = _parseComboList(resultData['M-TY'] ?? resultData['MTY']);
  }

  static void parseSafetyCondition(Map<String, dynamic>? resultData) {
    if (resultData == null) return;
    comboApt = _parseComboList(resultData['APT']);
    comboSw = _parseComboList(resultData['SW']);
    comboMan = _parseComboList(resultData['MAN']);
    comboJy = _parseComboList(resultData['JY']);
  }

  static List<ComboData> _parseComboList(dynamic list) {
    if (list == null) return [];
    if (list is! List) return [];
    return list.map((e) => ComboData.fromJson(e as Map<String, dynamic>).toTrim()).toList();
  }
}
