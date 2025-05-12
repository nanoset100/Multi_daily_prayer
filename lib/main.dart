import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void showTestNotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'basic_channel',
      title: '🛎️ 테스트 알림',
      body: '이것은 awesome_notifications로 보낸 첫 알림입니다!',
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // JSON 파일 로드 테스트
  final jsonStr = await rootBundle.loadString(
    'assets/daily_prayer_ui_labels.json',
  );
  final Map<String, dynamic> labels = json.decode(jsonStr);
  print(
    '✅ daily_prayer_ui_labels.json loaded: '
    'keys = \\${labels.keys.toList()}',
  );
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 알림 서비스 초기화
  NotificationService.initialize();

  // Awesome Notifications 초기화
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: '기본 채널',
      channelDescription: '기본 알림 채널',
      defaultColor: const Color(0xFF9D50DD),
      importance: NotificationImportance.High,
      channelShowBadge: true,
    ),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '매일 기도 루틴',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
    );
  }
}
