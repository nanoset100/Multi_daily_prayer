import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/stats_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const fallbackUrl = 'https://sevdrykubdoynryfahjm.supabase.co';
  const fallbackKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNldmRyeWt1YmRveW5yeWZhaGptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczODg0ODEsImV4cCI6MjA2Mjk2NDQ4MX0.ZkTQEVQrx6AlnKLQ0SVptP0nC8fPceWttiSeDzBp2NU';

  String supabaseUrl = fallbackUrl;
  String supabaseAnonKey = fallbackKey;

  try {
    await dotenv.load(fileName: ".env");
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? fallbackUrl;
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? fallbackKey;
  } catch (_) {}

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (_) {}

  // 알림 서비스 초기화 (채널 등록)
  NotificationService.initialize();

  // 통계 초기화 - 비동기로 처리 (앱 시작 블로킹 방지)
  StatsService.updateStatsOnAppOpen().catchError((_) {});

  // 알림 권한 요청 및 매일 오전 9시 기도 알림 스케줄링
  try {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    await NotificationService.scheduleDailyPrayerNotification();
  } catch (_) {}

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
