import 'package:flutter/foundation.dart';

class NetConfig {
  //static const String baseUrl = 'http://192.168.0.72:14003/gas/api/';
  static const String _remoteUrl = 'http://gas.joaoffice.com:14013/gas/api/';
  //static const String _remoteUrl = 'http://192.168.0.72:14013/gas/api/';

  //static const String _remoteUrl = 'http://gas.joaoffice.com:14001/gas/api/';
  /// 웹에서는 프록시 서버(localhost:8888)를 통해 CORS 우회
  /// dart run tool/proxy_server.dart 로 프록시 실행 후 사용
  static const String _proxyUrl = 'http://localhost:8888/gas/api/';

  /// USE_PROXY=true 로 실행하면 프록시 사용
  static const bool _useProxy = bool.fromEnvironment('USE_PROXY', defaultValue: false);

  static String get baseUrl {
    if (kIsWeb && _useProxy) return _proxyUrl;
    return _remoteUrl;
  }

  /// API 서버 루트 URL (업로드 등 /gas/api/ 밖의 엔드포인트용)
  static String get serverRootUrl {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  static const int timeoutConnect = 40000;
  static const int timeoutWrite = 30000;
  static const int timeoutRead = 30000;
  static const int timeoutLong = 120000;
}
