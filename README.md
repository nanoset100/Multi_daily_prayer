# 매일 기도 루틴 🙏 (Daily Prayer Routine)

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue.svg)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)](https://flutter.dev/)

## 📱 앱 소개 (App Overview)
매일 기도 루틴은 사용자가 일상에서 기도 습관을 형성하고 유지할 수 있도록 도와주는 크로스플랫폼 모바일 앱입니다. Flutter로 개발되어 Android와 iOS에서 모두 사용할 수 있습니다.

**Daily Prayer Routine** is a cross-platform mobile app built with Flutter that helps users establish and maintain daily prayer habits on both Android and iOS devices.

## ✨ 주요 기능 (Key Features)

### 📅 기도 관리 (Prayer Management)
- **스마트 알림**: 사용자 맞춤 시간에 기도 알림 전송
- **기도 기록**: 일별 기도 내용 및 완료 상태 추적
- **기도 통계**: 시각적 차트로 기도 습관 분석
- **개인 기도문**: 사용자만의 기도문 작성 및 관리

### 🤖 AI 기능 (AI Features)
- **AI 기도문 보완**: OpenAI 기술을 활용한 기도문 개선 제안
- **성경 구절 연계**: 관련 성경 구절 자동 제안
- **개인화된 추천**: 사용자 패턴 기반 맞춤형 제안

### 📊 통계 및 분석 (Statistics & Analytics)
- **기도 달성률**: 월별/주별 기도 완료율 시각화
- **연속 기도 기록**: 연속으로 기도한 날 수 추적
- **진도 추적**: 개인 영적 성장 여정 기록

### 🔄 동기화 (Synchronization)
- **클라우드 백업**: Supabase 기반 안전한 데이터 동기화
- **다기기 연동**: 여러 기기에서 동일한 데이터 접근

## 🛠️ 기술 스택 (Tech Stack)

### Frontend
- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Provider/Riverpod
- **UI Components**: Material Design 3

### Backend & Services
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **AI Service**: OpenAI API
- **Push Notifications**: Firebase Cloud Messaging
- **Local Storage**: SharedPreferences, SQLite

### Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **Structure**: Feature-based modular architecture
- **Dependencies**: Dependency injection with GetIt

## 📁 프로젝트 구조 (Project Structure)

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── prayer_card.dart
│   └── stats_model.dart
├── screens/                  # UI 화면
│   ├── home_screen.dart
│   ├── my_prayers_screen.dart
│   └── my_stats_screen.dart
├── services/                 # 비즈니스 로직
│   ├── notification_service.dart
│   ├── openai_service.dart
│   ├── local_scripture_service.dart
│   └── prayer_service.dart
└── widgets/                  # 재사용 위젯
```

## 🚀 시작하기 (Getting Started)

### 전제 조건 (Prerequisites)
- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상
- Android Studio / VS Code
- Android/iOS 개발 환경 설정

### 설치 방법 (Installation)

1. **저장소 클론**
```bash
git clone https://github.com/yourusername/Multi_daily_prayer.git
cd Multi_daily_prayer
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경 설정**
- `lib/services/` 폴더에 API 키 설정
- Supabase 프로젝트 설정
- OpenAI API 키 구성

4. **앱 실행**
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### 빌드 방법 (Build Instructions)

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔧 설정 (Configuration)

### API 키 설정
1. `lib/services/openai_service.dart`에서 OpenAI API 키 설정
2. `lib/services/supabase_service.dart`에서 Supabase URL 및 키 설정

### 알림 설정
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

## 🔒 개인정보 보호 (Privacy & Security)

### 데이터 보안
- **암호화**: 모든 민감한 데이터는 AES-256으로 암호화
- **전송 보안**: HTTPS/TLS 1.3 프로토콜 사용
- **로컬 저장**: 기기 내 보안 저장소 활용

### 개인정보 처리
- **최소 수집**: 기능 제공에 필요한 최소한의 정보만 수집
- **사용자 제어**: 언제든지 데이터 삭제 가능
- **투명성**: AI 처리 과정 완전 공개

## 📋 권한 설명 (Permissions)

### Android
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### iOS
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>기도 시간 알림을 위해 필요합니다</string>
```

## 🧪 테스트 (Testing)

```bash
# 단위 테스트
flutter test

# 통합 테스트
flutter test integration_test/

# 위젯 테스트
flutter test test/widget_test.dart
```

## 📱 지원 플랫폼 (Supported Platforms)

- ✅ Android 6.0+ (API 23+)
- ✅ iOS 12.0+
- 🔄 Web (개발 중)
- 🔄 macOS (개발 중)

## 🤝 기여하기 (Contributing)

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스 (License)

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 문의 및 지원 (Contact & Support)

- **이슈 신고**: [GitHub Issues](https://github.com/yourusername/Multi_daily_prayer/issues)
- **기능 요청**: [GitHub Discussions](https://github.com/yourusername/Multi_daily_prayer/discussions)
- **보안 문제**: security@example.com

## 🙏 감사의 말 (Acknowledgments)

- [Flutter](https://flutter.dev/) - UI 프레임워크
- [Supabase](https://supabase.io/) - 백엔드 서비스
- [OpenAI](https://openai.com/) - AI 기능 제공
- 모든 기여자들과 사용자들께 감사드립니다

---

## For App Store Review

### App Category
**Lifestyle - Religion & Spirituality**

### Key Features for Review
- Daily prayer scheduling and notifications
- Personal prayer journal with AI enhancement
- Progress tracking and statistics
- Secure cloud synchronization
- Cross-platform compatibility

### AI Transparency Statement
This app uses OpenAI's technology to enhance prayer content. All AI-generated suggestions are clearly marked and require user approval. The AI feature is optional and can be disabled at any time.

### Privacy Compliance
- GDPR compliant
- CCPA compliant  
- No tracking without user consent
- Full data portability
- Right to deletion honored
