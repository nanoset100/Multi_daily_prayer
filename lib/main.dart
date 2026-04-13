import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // 알림 서비스 초기화 (채널 등록만 - 권한 요청은 앱 렌더링 후)
  NotificationService.initialize();

  // 통계 초기화 - 비동기로 처리 (앱 시작 블로킹 방지)
  StatsService.updateStatsOnAppOpen().catchError((_) {});

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
