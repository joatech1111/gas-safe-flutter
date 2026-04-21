// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// 웹 환경에서 브라우저 userAgent 반환
String getUserAgent() => html.window.navigator.userAgent;
