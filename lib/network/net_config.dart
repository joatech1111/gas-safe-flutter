class NetConfig {
  //static const String baseUrl = 'http://192.168.0.72:14003/gas/api/';
  static const String baseUrl = 'http://gas.joaoffice.com:14013/gas/api/'; //todo: 전화번호 인증 추가 서버
  //static const String baseUrl = 'http://gas.joaoffice.com:14001/gas/api/';

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
