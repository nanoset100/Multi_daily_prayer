import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/openai_service.dart';
import '../services/stats_service.dart';
import '../services/notification_service.dart';
import 'my_prayers_screen.dart';
import 'my_stats_screen.dart';
import '../models/prayer_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _prayerController = TextEditingController();
  String? _selectedEmotion;
  bool _isGenerating = false;

  // [다국어 드롭다운] 언어 상태 변수 추가
  String selectedLanguage = 'ko';

  // [Supabase PrayerCard 상태 변수 추가]
  List<PrayerCard> _cards = [];
  int _currentCardIndex = 0;
  bool _isLoading = true;
  String? _loadError;

  final List<String> _emotions = [
    '기쁨',
    '슬픔',
    '불안',
    '감사',
    '분노',
    '기대',
    '외로움',
    '회개',
    '사명',

    '위로',
  ];

  Map<String, dynamic>? _labels;

  @override
  void initState() {
    super.initState();
    _fetchPrayerCards();
    _initLanguage();
    _updateStats(); // Initialize stats tracking
    _requestNotificationPermission(); // 앱 렌더링 후 알림 권한 요청
  }

  @override
  void dispose() {
    _prayerController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrayerCards() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      // 오늘 날짜를 MM-dd 형식으로 변환
      final today = DateFormat('MM-dd').format(DateTime.now());

      // 오늘 날짜에 해당하는 기도문 조회
      final response =
          await Supabase.instance.client
              .from('daily_prayers')
              .select('*')
              .eq('date', today)
              .single();

      final PrayerCard todayCard = PrayerCard.fromJson(response);

      setState(() {
        _cards = [todayCard];
        _currentCardIndex = 0;
        _isLoading = false;
      });

    } catch (e) {

      setState(() {
        _isLoading = false;
      });

      // 해당 날짜의 기도문이 없는 경우 또는 기타 오류 처리
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('0 rows') || errorMessage.contains('pgrst116')) {
        setState(() {
          _loadError = '오늘의 기도문이 아직 준비되지 않았습니다.\n내일 다시 확인해주세요.';
        });
      } else {
        // 오프라인 모드로 기본 데이터 제공
        _loadOfflineData();
      }
    }
  }

  Future<void> _loadLabelsByLocale({String? forceLang}) async {
    final jsonStr = await rootBundle.loadString(
      'assets/daily_prayer_ui_labels.json',
    );
    final Map<String, dynamic> allLabels = json.decode(jsonStr);
    String langCode =
        forceLang ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
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
  }

  Future<void> _updateStats() async {
    await StatsService.updateStatsOnAppOpen();
  }

  // 알림 권한 요청 (앱 렌더링 후 실행 - App Store 리젝 방지)
  Future<void> _requestNotificationPermission() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      await NotificationService.scheduleDailyPrayerNotification();
    } catch (_) {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB2EBF2),
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchPrayerCards,
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 시도'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : _cards.isEmpty
              ? Center(child: Text(_labels?['no_verse'] ?? '말씀 데이터가 없습니다.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // [상단 타이틀+언어 드롭다운 Row 추가]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _labels?['app_title'] ?? '매일 기도 루틴',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedLanguage,
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
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 오늘의 말씀 섹션
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📌 ${_cards[_currentCardIndex].getTheme(selectedLanguage) ?? ''}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _cards[_currentCardIndex].getVerse(
                                    selectedLanguage,
                                  ) ??
                                  '',
                              style: const TextStyle(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 예시 기도문 섹션
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _labels?['example_prayer'] ?? '🙏 예시 기도문',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _cards[_currentCardIndex].getPrayer(
                                    selectedLanguage,
                                  ) ??
                                  (_labels?['example_prayer_placeholder'] ??
                                      '여기에 예시 기도문이 표시됩니다.'),
                              style: const TextStyle(height: 1.4),
                            ),
                            const SizedBox(height: 20), // 크기 증가
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 감정 드롭다운
                    DropdownButtonFormField<String>(
                      value: _selectedEmotion,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: _labels?['emotion_selection'] ?? '감정 선택',
                        hintText:
                            _labels?['select_emotion_prompt'] ??
                            '지금의 감정 상태를 선택해 주세요',
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      items:
                          (_labels?['emotions'] as List<dynamic>? ?? _emotions)
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e.toString(),
                                  child: Text(
                                    e.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEmotion = newValue;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        _labels?['select_emotion_prompt'] ??
                            '내 감정을 선택한 후 상황에 맞게 적어보세요',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 기도문 입력창
                    TextField(
                      controller: _prayerController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            _labels?['input_prayer_placeholder'] ??
                            '당신의 기도를 여기에 적어주세요...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 버튼 영역 UI 개선
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: ElevatedButton.icon(
                            icon:
                                _isGenerating
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.auto_awesome),
                            label: Text(
                              _isGenerating
                                  ? (_labels?['ai_help_button'] ?? '생성 중...')
                                  : '🙏 ${_labels?['ai_help_button'] ?? '기도문 보충하기'}',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB2EBF2),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                            ),
                            onPressed:
                                _isGenerating
                                    ? null
                                    : () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      
                                      if (_prayerController.text.isEmpty) {
                                        _showMessage(
                                          _labels?['input_prayer_placeholder'] ??
                                              '기도 내용을 입력해주세요',
                                        );
                                        return;
                                      }
                                      if (_selectedEmotion == null) {
                                        _showMessage(
                                          _labels?['select_emotion_prompt'] ??
                                              '감정을 선택해주세요',
                                        );
                                        return;
                                      }
                                      setState(() {
                                        _isGenerating = true;
                                      });
                                      try {
                                        // BuildContext를 async 호출 전에 저장
                                        final originalInput =
                                            _prayerController.text;

                                        final generatedPrayer =
                                            await OpenAIService.generatePrayer(
                                              originalInput,
                                              _selectedEmotion!,
                                              selectedLanguage,
                                              _cards.isNotEmpty
                                                  ? (_cards[_currentCardIndex]
                                                          .getVerse(
                                                            selectedLanguage,
                                                          ) ??
                                                      '')
                                                  : '',
                                            );
                                        if (!mounted) return;

                                        // State의 context를 사용하여 showDialog 호출
                                        final currentContext = context;
                                        if (!mounted ||
                                            !currentContext.mounted) {
                                          return;
                                        }

                                        showDialog(
                                          context: currentContext,
                                          barrierDismissible: false,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'AI가 생성한 기도문',
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        '원래 입력:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(originalInput),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      const Text(
                                                        'AI 생성 기도문:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(generatedPrayer),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      // AI 고지 문구 추가
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .blue
                                                                    .shade200,
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          '🧠 이 기능은 OpenAI 인공지능을 활용하여 사용자의 기도문을 기반으로 보완된 기도문을 제안합니다.',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      // 신고 기능 안내 및 버튼
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .orange
                                                                  .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .orange
                                                                    .shade200,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              '❗ 불건전하거나 부적절한 기도문이 생성되었나요? 신고를 통해 개발자에게 알려주세요.',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .orange,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              child: ElevatedButton.icon(
                                                                onPressed: () async {
                                                                  await sendReportToDeveloper(
                                                                    generatedPrayer,
                                                                  );
                                                                },
                                                                icon: const Icon(
                                                                  Icons
                                                                      .report_problem,
                                                                  size: 16,
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                                label: const Text(
                                                                  '🚨 신고하기',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  elevation: 0,
                                                                  side: BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .red
                                                                            .shade300,
                                                                  ),
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  Center(
                                                    child: Builder(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => TextButton(
                                                            onPressed: () {
                                                              _prayerController
                                                                      .text =
                                                                  generatedPrayer;
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                              if (mounted) {
                                                                _showMessage(
                                                                  _labels?['ai_help_button'] ??
                                                                      'AI 기도문이 적용되었습니다',
                                                                );
                                                              }
                                                            },
                                                            style: TextButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFFB2EBF2,
                                                                  ),
                                                              foregroundColor:
                                                                  Colors.black,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        32,
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              '기도문 보충하기',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      } catch (e) {
                                        _showMessage(
                                          _labels?['ai_help_button'] ??
                                              '기도문 생성 오류: $e',
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isGenerating = false;
                                          });
                                        }
                                      }
                                    },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.save,
                                  color: Colors.black,
                                ),
                                label: Text(
                                  _labels?['save_button'] ?? '저장하기',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_prayerController.text.isEmpty) {
                                    _showMessage('기도 내용을 입력해주세요');
                                    return;
                                  }
                                  if (_selectedEmotion == null) {
                                    _showMessage('감정을 선택해주세요');
                                    return;
                                  }
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final prayerEntry = {
                                    'text': _prayerController.text,
                                    'emotion': _selectedEmotion,
                                    'date':
                                        DateTime.now().toString().split(' ')[0],
                                  };
                                  final String prayerJson = jsonEncode(
                                    prayerEntry,
                                  );
                                  final List<String>? existingPrayers = prefs
                                      .getStringList('saved_prayers');
                                  if (existingPrayers != null) {
                                    existingPrayers.add(prayerJson);
                                    await prefs.setStringList(
                                      'saved_prayers',
                                      existingPrayers,
                                    );
                                  } else {
                                    await prefs.setStringList('saved_prayers', [
                                      prayerJson,
                                    ]);
                                  }
                                  _showMessage('기도가 저장되었습니다');
                                  _prayerController.clear();
                                  setState(() {
                                    _selectedEmotion = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.menu_book,
                                  color: Colors.black,
                                ),
                                label:
                                    selectedLanguage == 'en'
                                        ? Center(
                                          child: Text(
                                            _labels?['my_prayers_button'] ??
                                                'View My Prayers',
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                        : Text(
                                          _labels?['my_prayers_button'] ??
                                              '내 기도문 보기',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              MyPrayersScreen(labels: _labels),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.bar_chart,
                                  color: Colors.black,
                                ),
                                label: Text(
                                  _labels?['my_stats_button'] ?? '나의 기록',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const MyStatsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  // 오프라인 모드용 기본 데이터 로딩
  void _loadOfflineData() {
    final today = DateFormat('MM-dd').format(DateTime.now());
    final defaultCard = PrayerCard(
      id: 1,
      date: today,
      themeKo: '하나님의 사랑',
      themeEn: 'God\'s Love',
      themeJa: '神の愛',
      themeZh: '神的爱',
      themeEs: 'Amor de Dios',
      verseKo:
          '하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라 (요한복음 3:16)',
      verseEn:
          'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. (John 3:16)',
      verseJa:
          '神は、実に、そのひとり子をお与えになったほどに世を愛された。それは御子を信じる者が、一人として滅びることなく、永遠のいのちを持つためである。(ヨハネ 3:16)',
      verseZh: '神爱世人，甚至将他的独生子赐给他们，叫一切信他的，不至灭亡，反得永生。(约翰福音 3:16)',
      verseEs:
          'Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna. (Juan 3:16)',
      prayerKo:
          '사랑의 하나님, 저희를 향한 무한한 사랑에 감사드립니다. 오늘도 주님의 사랑 안에서 살아가게 하시고, 다른 이들에게도 그 사랑을 나누는 삶이 되게 하소서. 예수님의 이름으로 기도합니다. 아멘.',
      prayerEn:
          'God of love, thank you for your infinite love for us. Help us to live in your love today and to share that love with others. In Jesus\' name we pray. Amen.',
      prayerJa:
          '愛の神様、私たちへの無限の愛に感謝いたします。今日も主の愛の中で生きることができ、他の人々にもその愛を分かち合う人生となりますように。イエス様の御名によって祈ります。アーメン。',
      prayerZh: '慈爱的神，感谢您对我们无限的爱。求您帮助我们今天活在您的爱中，并与他人分享这份爱。奉耶稣的名祷告。阿们。',
      prayerEs:
          'Dios de amor, gracias por tu amor infinito hacia nosotros. Ayúdanos a vivir en tu amor hoy y a compartir ese amor con otros. En el nombre de Jesús oramos. Amén.',
    );

    setState(() {
      _cards = [defaultCard];
      _currentCardIndex = 0;
      _isLoading = false;
      _loadError = null;
    });
  }

  // 신고 기능 추가
  Future<void> sendReportToDeveloper(String generatedPrayer) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('reports').insert({
        'type': '기도문 신고',
        'content': generatedPrayer,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _showMessage('신고가 접수되었습니다. 감사합니다.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('신고 중 오류가 발생했습니다.');
      }
    }
  }

  void _showMessage(String message) {
    if (mounted && ScaffoldMessenger.maybeOf(context) != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
