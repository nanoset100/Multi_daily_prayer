import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static void initialize() {
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'prayer_channel',
        channelName: '기도 알림',
        channelDescription: '매일 기도 시간을 알려주는 알림입니다.',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ], debug: true);
  }

  static void showNotification({required String title, required String body}) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: title,
        body: body,
      ),
    );
  }

  static Future<void> scheduleDailyPrayerNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'prayer_channel',
        title: '🙏 기도의 시간입니다',
        body: '오늘도 하나님과 함께 기도로 하루를 시작해요!',
      ),
      schedule: NotificationCalendar(
        hour: 9,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }
}
