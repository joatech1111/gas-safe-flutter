import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/auth_login.dart';
import '../models/combo_data.dart';
import '../models/meters_customer_result_data.dart';
import '../models/meters_check_status_result_data.dart';
import '../models/safety_customer_result_data.dart';
import '../models/safety_history_result_data.dart';
import '../models/safety_check_contract_result_data.dart';
import '../models/safety_equip_result_data.dart';
import '../models/safety_tank_result_data.dart';
import '../models/safety_saving_result_data.dart';
import '../models/safety_status_result_data.dart';
import '../utils/keys.dart';
import '../utils/prefs_util.dart';
import 'net_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  late Dio _dioLong;

  ApiService._internal() {
    _dio = _createDio(NetConfig.timeoutRead);
    _dioLong = _createDio(NetConfig.timeoutLong);
  }

  Dio _createDio(int timeout) {
    final dio = Dio(BaseOptions(
      baseUrl: NetConfig.baseUrl,
      connectTimeout: Duration(milliseconds: NetConfig.timeoutConnect),
      sendTimeout: Duration(milliseconds: timeout),
      receiveTimeout: Duration(milliseconds: timeout),
      contentType: 'application/json',
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final loginJson = PrefsUtil.getString(Keys.prefLoginUser);
        if (loginJson != null) {
          try {
            final authLogin = AuthLogin.fromJson(json.decode(loginJson));
            if (authLogin.sToken != null) {
              options.queryParameters[Keys.sessionId] = authLogin.sToken;
            }
          } catch (_) {}
        }
        handler.next(options);
      },
    ));

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }

  Future<Map<String, dynamic>> _request(
    Future<Response> Function() requestFunc, {
    bool useLongTimeout = false,
  }) async {
    try {
      final response = await requestFunc();
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) return json.decode(data);
      return {'resultCode': 9999, 'result': 'Unknown response format'};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        try {
          if (e.response!.data is Map) return e.response!.data;
          return json.decode(e.response!.data.toString());
        } catch (_) {}
      }
      return {'resultCode': 9999, 'result': e.message ?? '네트워크 연결에 실패했습니다.'};
    } catch (e) {
      return {'resultCode': 9999, 'result': e.toString()};
    }
  }

  // Auth
  Future<Map<String, dynamic>> authLogin(Map<String, dynamic> req) =>
      _request(() => _dio.post('auth/login', data: req));

  Future<Map<String, dynamic>> authLogout() =>
      _request(() => _dio.get('auth/logout'));

  Future<Map<String, dynamic>> authSignUp(Map<String, dynamic> req) =>
      _request(() => _dio.post('auth/signup', data: req));

  // Config
  Future<Map<String, dynamic>> configArea() =>
      _request(() => _dio.get('config/area'));

  Future<Map<String, dynamic>> configAll(String areaCode) =>
      _request(() => _dio.get('config/all/${areaCode.trim()}'));

  Future<Map<String, dynamic>> configGubun(String gubun, String areaCode) =>
      _request(() => _dio.get('config/${gubun.trim()}/${areaCode.trim()}'));

  Future<Map<String, dynamic>> configInfoUpdate(Map<String, dynamic> req) =>
      _request(() => _dio.put('config', data: req));

  // Customer
  Future<Map<String, dynamic>> customerSearchCondition(String areaCode) =>
      _request(() => _dio.get('customers/search/conditions/${areaCode.trim()}'));

  Future<Map<String, dynamic>> customerInfoUpdate(Map<String, dynamic> req) =>
      _request(() => _dio.put('customers', data: req));

  // Meters
  Future<Map<String, dynamic>> metersCustomerSearchCondition(String areaCode) =>
      _request(() => _dio.get('meters/customers/search/conditions/${areaCode.trim()}'));

  Future<Map<String, dynamic>> metersCustomerSearchKeyword(Map<String, dynamic> req) {
    final gumType = req['GUM_TYPE'] ?? Keys.metersCycleAll;
    switch (gumType) {
      case Keys.metersCycleRound:
        final ymSno = (req['GUM_YMSNO'] ?? '').toString().trim();
        return _request(() => _dio.post('meters/customers/search/keyword/sno/$ymSno', data: req));
      case Keys.metersCycleMonth:
        final term = (req['GUM_TURM'] ?? '').toString().trim();
        return _request(() => _dio.post('meters/customers/search/keyword/term/$term', data: req));
      default:
        return _request(() => _dio.post('meters/customers/search/keyword', data: req));
    }
  }

  Future<Map<String, dynamic>> metersCustomerSearchLocation(Map<String, dynamic> req) =>
      _request(() => _dio.post('meters/customers/search/location', data: req));

  Future<Map<String, dynamic>> metersCheckInfoInsert(Map<String, dynamic> req) =>
      _request(() => _dio.post('meters/customers', data: req));

  Future<Map<String, dynamic>> metersCheckInfoUpdate(Map<String, dynamic> req) =>
      _request(() => _dio.put('meters/customers', data: req));

  Future<Map<String, dynamic>> metersCheckInfoDelete(Map<String, dynamic> req) =>
      _request(() => _dio.delete('meters/customers', data: req));

  Future<Map<String, dynamic>> metersInfoUpdate(Map<String, dynamic> req) =>
      _request(() => _dio.put('meters/info', data: req));

  Future<Map<String, dynamic>> metersCheckStatusSearchKeyword(Map<String, dynamic> req) =>
      _request(() => _dio.post('meters/checkstatus/search/keyword', data: req));

  Future<Map<String, dynamic>> metersCheckStatusSearchLocation(Map<String, dynamic> req) =>
      _request(() => _dio.post('meters/checkstatus/search/location', data: req));

  // Safety
  Future<Map<String, dynamic>> safetyCustomerSearchCondition(String areaCode) =>
      _request(() => _dio.get('safetycheck/customers/search/conditions/${areaCode.trim()}'));

  Future<Map<String, dynamic>> safetyCustomerSearchKeyword(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/customers/search/keyword', data: req));

  Future<Map<String, dynamic>> safetyCustomerSearchLocation(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/customers/search/location', data: req));

  Future<Map<String, dynamic>> safetyHistory(String areaCode, String cuCode, String shDate) =>
      _request(() => _dio.get('safetycheck/history/${areaCode.trim()}/${cuCode.trim()}/${shDate.trim()}'));

  Future<Map<String, dynamic>> safetyCheckContract(String areaCode, String cuCode, String sno) =>
      _request(() => _dio.get('safetycheck/cont/${areaCode.trim()}/${cuCode.trim()}/${sno.trim()}'));

  Future<Map<String, dynamic>> safetyCheckContractLast(String areaCode, String cuCode) =>
      _request(() => _dio.get('safetycheck/cont/${areaCode.trim()}/${cuCode.trim()}'));

  Future<Map<String, dynamic>> safetyCheckContractInsert(Map<String, dynamic> req, {bool useLong = false}) =>
      _request(() => (useLong ? _dioLong : _dio).post('safetycheck/cont', data: req));

  Future<Map<String, dynamic>> safetyCheckContractUpdate(Map<String, dynamic> req, {bool useLong = false}) =>
      _request(() => (useLong ? _dioLong : _dio).put('safetycheck/cont', data: req));

  Future<Map<String, dynamic>> safetyCheckContractDelete(Map<String, dynamic> req) =>
      _request(() => _dio.delete('safetycheck/cont', data: req));

  Future<Map<String, dynamic>> safetyEquip(String areaCode, String cuCode, String sno) =>
      _request(() => _dio.get('safetycheck/equips3/${areaCode.trim()}/${cuCode.trim()}/${sno.trim()}'));

  Future<Map<String, dynamic>> safetyEquipLast(String areaCode, String cuCode) =>
      _request(() => _dio.get('safetycheck/equips3/${areaCode.trim()}/${cuCode.trim()}'));

  Future<Map<String, dynamic>> safetyEquipInsert(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/equips', data: req));

  Future<Map<String, dynamic>> safetyEquipUpdate(Map<String, dynamic> req) =>
      _request(() => _dio.put('safetycheck/equips', data: req));

  Future<Map<String, dynamic>> safetyEquipDelete(Map<String, dynamic> req) =>
      _request(() => _dio.delete('safetycheck/equips', data: req));

  Future<Map<String, dynamic>> safetyEquipInsertNew(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/NewequipsAdd', data: req));

  Future<Map<String, dynamic>> safetyEquipUpdateNew(Map<String, dynamic> req) =>
      _request(() => _dio.put('safetycheck/NewequipsAdd', data: req));

  Future<Map<String, dynamic>> safetyEquipDeleteNew(Map<String, dynamic> req) =>
      _request(() => _dio.delete('safetycheck/NewequipsAdd', data: req));

  Future<Map<String, dynamic>> safetyTank(String areaCode, String cuCode, String sno) =>
      _request(() => _dio.get('safetycheck/tanks/${areaCode.trim()}/${cuCode.trim()}/${sno.trim()}'));

  Future<Map<String, dynamic>> safetyTankLast(String areaCode, String cuCode) =>
      _request(() => _dio.get('safetycheck/tanks/${areaCode.trim()}/${cuCode.trim()}'));

  Future<Map<String, dynamic>> safetyTankInsert(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/tanks', data: req));

  Future<Map<String, dynamic>> safetyTankUpdate(Map<String, dynamic> req) =>
      _request(() => _dio.put('safetycheck/tanks', data: req));

  Future<Map<String, dynamic>> safetyTankDelete(Map<String, dynamic> req) =>
      _request(() => _dio.delete('safetycheck/tanks', data: req));

  Future<Map<String, dynamic>> safetySaving(String areaCode, String cuCode, String sno) =>
      _request(() => _dio.get('safetycheck/saving/${areaCode.trim()}/${cuCode.trim()}/${sno.trim()}'));

  Future<Map<String, dynamic>> safetySavingLast(String areaCode, String cuCode) =>
      _request(() => _dio.get('safetycheck/saving/${areaCode.trim()}/${cuCode.trim()}'));

  Future<Map<String, dynamic>> safetySavingInsert(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/saving', data: req));

  Future<Map<String, dynamic>> safetySavingUpdate(Map<String, dynamic> req) =>
      _request(() => _dio.put('safetycheck/saving', data: req));

  Future<Map<String, dynamic>> safetySavingDelete(Map<String, dynamic> req) =>
      _request(() => _dio.delete('safetycheck/saving', data: req));

  Future<Map<String, dynamic>> safetySms(String areaCode, String smsDiv) =>
      _request(() => _dio.get('safetycheck/sms/${areaCode.trim()}/$smsDiv'));

  Future<Map<String, dynamic>> safetyStatusSearchKeyword(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/status/search/keyword', data: req));

  Future<Map<String, dynamic>> safetyStatusSearchLocation(Map<String, dynamic> req) =>
      _request(() => _dio.post('safetycheck/status/search/location', data: req));
}
