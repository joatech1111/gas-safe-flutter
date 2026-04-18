/// 웹 개발용 CORS 프록시 서버
/// 사용법: dart run tool/proxy_server.dart
///
/// Flutter 웹 앱의 API 요청을 실제 서버로 중계합니다.
/// 기본 포트: 8888
import 'dart:convert';
import 'dart:io';

const _targetHost = 'gas.joaoffice.com';
const _targetPort = 14013;
const _proxyPort = 8888;

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _proxyPort);
  print('🚀 CORS 프록시 서버 시작: http://localhost:$_proxyPort');
  print('   → 대상 서버: http://$_targetHost:$_targetPort');
  print('   Flutter 웹 실행: flutter run -d chrome --dart-define=USE_PROXY=true');
  print('');

  await for (final request in server) {
    _handleRequest(request);
  }
}

Future<void> _handleRequest(HttpRequest request) async {
  final uri = request.uri;

  // CORS preflight (OPTIONS)
  if (request.method == 'OPTIONS') {
    _addCorsHeaders(request.response);
    request.response.statusCode = 204;
    await request.response.close();
    return;
  }

  try {
    // 대상 서버로 요청 전달
    final client = HttpClient();
    final proxyRequest = await client.open(
      request.method,
      _targetHost,
      _targetPort,
      uri.toString(),
    );

    // 원본 헤더 복사
    request.headers.forEach((name, values) {
      if (name.toLowerCase() == 'host') return;
      for (final v in values) {
        proxyRequest.headers.add(name, v);
      }
    });
    proxyRequest.headers.set('host', '$_targetHost:$_targetPort');

    // 요청 바디 전달
    final bodyBytes = await request.fold<List<int>>(
      [],
      (prev, chunk) => prev..addAll(chunk),
    );
    if (bodyBytes.isNotEmpty) {
      proxyRequest.add(bodyBytes);
    }

    final proxyResponse = await proxyRequest.close();

    // 응답 헤더 복사 + CORS 헤더 추가
    _addCorsHeaders(request.response);
    request.response.statusCode = proxyResponse.statusCode;
    proxyResponse.headers.forEach((name, values) {
      if (name.toLowerCase() == 'transfer-encoding') return;
      if (name.toLowerCase().startsWith('access-control')) return;
      for (final v in values) {
        request.response.headers.add(name, v);
      }
    });

    // 응답 바디 전달
    await proxyResponse.pipe(request.response);
    client.close(force: false);

    print('✅ ${request.method} ${uri.path} → ${proxyResponse.statusCode}');
  } catch (e) {
    print('❌ ${request.method} ${uri.path} → ERROR: $e');
    request.response.statusCode = 502;
    _addCorsHeaders(request.response);
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'resultCode': 9999,
      'result': '프록시 서버 연결 실패: $e',
    }));
    await request.response.close();
  }
}

void _addCorsHeaders(HttpResponse response) {
  response.headers.add('Access-Control-Allow-Origin', '*');
  response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization, sessionid');
  response.headers.add('Access-Control-Max-Age', '86400');
}
