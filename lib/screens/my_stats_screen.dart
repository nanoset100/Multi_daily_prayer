import 'package:flutter/material.dart';
import '../models/stats_model.dart';
import '../services/stats_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyStatsScreen extends StatefulWidget {
  const MyStatsScreen({super.key});

  @override
  State<MyStatsScreen> createState() => _MyStatsScreenState();
}

class _MyStatsScreenState extends State<MyStatsScreen> {
  StatsModel? _stats;
  TimeOfDay? _selectedTime;
  bool _isLoading = true;
  Map<String, dynamic>? _labels = {};
  String selectedLanguage = 'ko'; // 기본 언어를 한국어로 설정

  @override
  void initState() {
    super.initState();
    _loadStats();
    _initLanguage();
  }

  // 앱 시작 시 언어 설정 초기화
  Future<void> _initLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage');

    if (savedLanguage != null) {
      // 저장된 언어 설정이 있으면 사용
      await _loadLabelsByLocale(forceLang: savedLanguage);
    } else {
      // 없으면 기본 설정 사용
      await _loadLabelsByLocale();
    }
  }

  Future<void> _loadLabelsByLocale({String? forceLang}) async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/daily_prayer_ui_labels.json',
      );
      final Map<String, dynamic> allLabels = json.decode(jsonStr);

      // 언어 코드 결정: 강제 언어가 있거나, 시스템 언어 사용
      String langCode =
          forceLang ??
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;

      // 선택한 언어가 없으면 한국어로 기본 설정
      if (!allLabels.containsKey(langCode)) {
        langCode = 'ko';
      }

      setState(() {
        selectedLanguage = langCode;
        _labels = allLabels[langCode];
      });

      // SharedPreferences에 선택한 언어 저장 (앱 전체에서 일관성 유지)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', langCode);

      print(
        '✅ 스탯 화면 언어 설정: $langCode, labels: ${_labels?.keys.length ?? 0}개 로드됨',
      );
    } catch (e) {
      print('라벨 로딩 오류: $e');
      // 오류 발생시 기본 한국어 라벨 사용
      setState(() {
        _labels = {
          'my_stats_title': '나의 심경 기록',
          'streak_days': '연속 접속일',
          'today_access': '오늘 접속',
          'total_access': '전체 접속',
          'reminder_setting_title': '매일 확인 시간 설정',
          'reminder_description': '매일 이 시간이 되면 심경 카드를 확인하는 것을 잊지 마세요.',
          'reminder_time': '확인 시간',
          'usage_tips': '사용 팁',
          'tip_daily_streak': '매일 꾸준히 접속하면 연속 접속일이 늘어납니다.',
          'tip_reminder': '설정한 시간에 알림이 오지 않더라도 매일 앱을 열 수 있습니다.',
        };
      });
    }
  }

  Future<void> _loadStats() async {
    final stats = await StatsService.getStats();

    if (stats.reminderTime != null) {
      final timeParts = stats.reminderTime!.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });

      // Save the selected time
      final timeString = '${picked.hour}:${picked.minute}';
      await StatsService.setReminderTime(timeString);

      // Reload stats to reflect changes
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_labels?['my_stats_title'] ?? '나의 심경 기록')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // 배경색 추가
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _labels?['my_stats_title'] ?? '나의 심경 기록',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 언어 표시 및 선택 UI 개선
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                dropdownColor: Colors.black54,
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    await _loadLabelsByLocale(forceLang: newValue);
                  }
                },
                items:
                    <String>[
                      'ko',
                      'en',
                      'ja',
                      'zh',
                      'es',
                    ].map<DropdownMenuItem<String>>((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(
                          {
                            'ko': '한국어',
                            'en': 'English',
                            'ja': '日本語',
                            'zh': '中文',
                            'es': 'Español',
                          }[lang]!,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 새로운 통계 카드 - 완전히 재구성
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 제목
                      Text(
                        _labels?['my_stats_title'] ?? '나의 심경 기록',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // 통계 영역 - 고정 높이 설정 없이 내부 패딩으로 처리
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 연속 접속일
                          _buildStatTile(
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                            value: _stats?.streak.toString() ?? '0',
                            label: '', // 라벨은 아래에 별도로 표시
                          ),

                          // 오늘 접속
                          _buildStatTile(
                            icon: Icons.calendar_today,
                            color: Colors.blue,
                            value: _stats?.todayAccessCount.toString() ?? '0',
                            label: '', // 라벨은 아래에 별도로 표시
                          ),

                          // 전체 접속 (누락된 부분 추가)
                          _buildStatTile(
                            icon: Icons.bar_chart,
                            color: Colors.green,
                            value: _stats?.totalAccessCount.toString() ?? '0',
                            label: '', // 라벨은 아래에 별도로 표시
                          ),
                        ],
                      ),

                      // 라벨 영역 (값 아래에 별도로 표시)
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 연속 접속일 라벨
                          Expanded(
                            child: Text(
                              _labels?['streak_days'] ?? '연속 접속일',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // 오늘 접속 라벨
                          Expanded(
                            child: Text(
                              _labels?['today_access'] ?? '오늘 접속',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // 전체 접속 라벨 (누락된 부분 추가)
                          Expanded(
                            child: Text(
                              _labels?['total_access'] ?? '전체 접속',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reminder Setting Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labels?['reminder_setting_title'] ?? '매일 확인 시간 설정',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _labels?['reminder_description'] ??
                            '매일 이 시간이 되면 심경 카드를 확인하는 것을 잊지 마세요.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // Time Picker - 레이아웃 개선
                      Row(
                        children: [
                          // 라벨
                          Expanded(
                            child: Text(
                              _labels?['reminder_time'] ?? '확인 시간',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // 시간 표시 및 선택 버튼
                          Text(
                            _selectedTime != null
                                ? _formatTimeOfDay(_selectedTime!)
                                : '9:00 AM',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // 시간 선택 아이콘
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Usage Tips
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labels?['usage_tips'] ?? '사용 팁',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 팁 1
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _labels?['tip_daily_streak'] ??
                                    '매일 꾸준히 접속하면 연속 접속일이 늘어납니다.',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 팁 2
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _labels?['tip_reminder'] ??
                                    '설정한 시간에 알림이 오지 않더라도 매일 앱을 열 수 있습니다.',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 통계 타일 위젯 (아이콘과 값만 표시)
  Widget _buildStatTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // 12-hour format with AM/PM
    return format.format(dt);
  }
}
