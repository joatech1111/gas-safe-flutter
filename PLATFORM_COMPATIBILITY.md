# Gas Safe Flutter - 플랫폼 호환성 가이드

> 본 앱은 기존 Kotlin(Android) 전용 버전에서 Flutter 크로스 플랫폼으로 전환한 프로젝트입니다.
> Android / iOS / Web 동일 코드베이스로 빌드되며, **네이티브 의존 기능은 웹에서 동작하지 않을 수 있습니다.**

---

## 인증 체계 (기존 대비 변경사항)

### 기존 Kotlin 버전
- **UUID 기반 자동 로그인** — 기기 고유 ID로 사용자 식별

### Flutter 버전 (현재)
- **전화번호 + 비밀번호 기반 로그인**으로 전환
- DB: `GASMAX_APP.appUser.HP_SNO` (전화번호) 컬럼 기준 인증
- UUID 로그인은 완전히 제거됨

### 멀티 로그인 지원
- 하나의 기기에서 **HP_SNO에 등록된 전화번호가 여러 개인 경우 멀티 로그인 가능**
- 예: 한 사용자가 `010-1234-5678`, `010-9876-5432` 두 번호로 각각 등록된 경우, 번호별로 전환 로그인 가능
- 이는 기존 UUID 방식에서는 불가능했던 기능으로, 복수 사업장/담당 구역을 관리하는 사용자를 위해 설계됨

> **주의:** 로그인 기준이 기기(UUID)에서 사용자(전화번호)로 변경되었으므로,
> 동일 기기라도 다른 번호로 로그인하면 별도 세션으로 처리됩니다.

---

## 플랫폼별 기능 호환성 요약

| 기능 | Android | iOS | Web | 비고 |
|------|:-------:|:---:|:---:|------|
| 로그인 / 회원가입 | O | O | O | |
| 기기 정보 수집 | O | O | △ | 웹은 랜덤 ID 생성으로 대체 |
| **전화번호 자동입력** | O | X | X | Android MethodChannel 전용 |
| **GPS 위치 검색** | O | O | X | geolocator 플러그인 웹 미지원 |
| **SMS 발송** | O | O | X | url_launcher SMS scheme 웹 미지원 |
| **주소/우편번호 검색** | O | O | X | kpostal 플러그인 웹 미지원 |
| PDF 계약서 생성 | O | O | O | |
| PDF 인쇄 | O | O | O | |
| 전자서명 (Signature Pad) | O | O | O | 순수 Dart 구현 |
| 토스트 알림 | O | O | O | |
| 로컬 저장소 | O | O | O | |
| HTTP 통신 (Dio) | O | O | O | 웹은 CORS 프록시 필요 시 설정 가능 |

> **O** = 정상 동작 / **△** = 제한적 동작 / **X** = 미지원

---

## 웹에서 동작하지 않는 기능 상세

### 1. GPS 위치 기반 검색 (영향도: 높음)

**플러그인:** `geolocator` v13.0.2 (웹 미지원)

**영향 화면 (8개):**
- `metering_screen.dart` - 검침 화면
- `metering_status_screen.dart` - 검침 현황
- `safety_screen.dart` - 안전점검 화면
- `safety_status_screen.dart` - 안전점검 현황
- `safety_tank_tab.dart` - 용기 탭
- `safety_saving_tab.dart` - 절약기 탭
- `safety_equip_tab.dart` - 설비 탭
- `safety_contract_tab.dart` - 계약 탭

**동작 방식:** GPS 좌표(위도/경도)를 서버에 전송하여 현 위치 기반 고객 검색

**웹 대안:** 브라우저 Geolocation API로 대체하거나, 수동 주소 입력 방식 필요

---

### 2. 전화번호 자동 추출 (영향도: 낮음)

**구현:** Android MethodChannel (`com.joatech.gassafe/phone`)

**영향 화면:**
- `signup_screen.dart` - 회원가입 화면

**동작 방식:** SIM 카드에서 전화번호를 읽어 자동 입력
- Android: `TelephonyManager.getLine1Number()` 사용
- iOS / Web: 지원 불가 (수동 입력으로 fallback)

**필요 권한 (Android):**
- `READ_PHONE_STATE`
- `READ_PHONE_NUMBERS`

**현재 처리:** `if (kIsWeb) return;` 으로 웹에서는 건너뜀 (정상 대응 완료)

---

### 3. SMS 발송 (영향도: 중간)

**플러그인:** `url_launcher` (SMS scheme)

**영향 화면 (4개):**
- `safety_tank_tab.dart`
- `safety_saving_tab.dart`
- `safety_equip_tab.dart`
- `safety_contract_tab.dart`

**동작 방식:** `sms:` URI scheme으로 기기 문자 앱 호출

**웹 대안:** 서버 측 SMS API 연동 또는 이메일 대체

---

### 4. 주소/우편번호 검색 (영향도: 중간)

**플러그인:** `kpostal` v1.1.0 (웹 미지원)

**동작 방식:** 다음 우편번호 검색 API를 네이티브 WebView로 호출

**웹 대안:** 다음 우편번호 API를 직접 웹 페이지에서 호출하는 방식으로 전환 가능

---

## 플랫폼별 네이티브 설정

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.READ_PHONE_NUMBERS"/>
```

- `usesCleartextTraffic="true"` 설정 (HTTP 허용)
- `network_security_config.xml`로 `gas.joaoffice.com:14013` 허용

### iOS (`Info.plist`)

```
NSLocationWhenInUseUsageDescription: GPS 기반 검색을 위해 위치 권한이 필요합니다.
NSLocationAlwaysUsageDescription: (설정됨)
NSAppTransportSecurity: 임의 HTTP 로드 허용
```

### Web

- CORS 이슈로 프록시 서버 경유 가능 (`USE_PROXY` 환경변수)
- 프록시 URL: `http://localhost:8888/gas/api/`
- 테마: Android Material Design 강제 적용 (`TargetPlatform.android` 하드코딩)

---

## 기존 Kotlin 버전에서 마이그레이션 현황

| 기존 기능 (Kotlin) | Flutter 이식 | 크로스 플랫폼 | 비고 |
|-------------------|:-----------:|:----------:|------|
| 로그인/회원가입 | O | O | 전화번호+비밀번호 기반으로 전환 |
| 검침 (조회/입력/현황) | O | △ | GPS 검색은 모바일만 |
| 안전점검 (4개 탭) | O | △ | GPS/SMS는 모바일만 |
| 계약서 PDF 생성 | O | O | A4 규격, 서명 삽입 |
| 기기 정보 수집 | O | △ | 웹은 랜덤 ID |
| 주소 검색 | O | △ | kpostal 웹 미지원 |
| SMS 발송 | O | △ | 웹 미지원 |

---

## 알려진 이슈 및 개선 권장사항

### 보안
- [ ] HTTP 평문 통신 사용 중 → HTTPS 전환 권장
- [ ] `NSAllowsArbitraryLoads = true` → 프로덕션에서는 특정 도메인만 허용 권장

### UX
- [ ] 웹에서 GPS 미지원 기능 접근 시 안내 메시지 필요
- [ ] iOS 사용자에게 전화번호 수동 입력 안내 UI 필요

### 테마
- [ ] `TargetPlatform.android` 하드코딩 → 플랫폼별 적응형 테마 고려

---

*마지막 업데이트: 2026-04-20*
*기준 앱 버전: 3.0.1010*
