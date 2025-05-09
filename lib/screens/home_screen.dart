import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_service.dart';
import '../services/local_scripture_service.dart';
import 'my_prayers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _prayerController = TextEditingController();
  String? _selectedEmotion;
  bool _isGenerating = false;
  Future<SharedPreferences>? _prefsFuture;
  final List<String> _prayers = [];

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

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _prayerController.dispose();
    super.dispose();
  }

  Future<void> _savePrayer(SharedPreferences prefs) async {
    try {
      if (_prayerController.text.isEmpty) {
        _showMessage('기도 내용을 입력해주세요');
        return;
      }

      if (_selectedEmotion == null) {
        _showMessage('감정을 선택해주세요');
        return;
      }

      final prayerEntry = {
        'text': _prayerController.text,
        'emotion': _selectedEmotion,
        'date': DateTime.now().toString().split(' ')[0],
      };

      final String prayerJson = jsonEncode(prayerEntry);

      final List<String>? existingPrayers = prefs.getStringList(
        'saved_prayers',
      );

      if (existingPrayers != null) {
        existingPrayers.add(prayerJson);
        await prefs.setStringList('saved_prayers', existingPrayers);
      } else {
        await prefs.setStringList('saved_prayers', [prayerJson]);
      }

      _showMessage('기도가 저장되었습니다');

      _prayerController.clear();
      setState(() {
        _selectedEmotion = null;
      });
    } catch (e) {
      _showMessage('저장 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _generateAIPrayer() async {
    if (_prayerController.text.isEmpty) {
      _showMessage('기도 내용을 입력해주세요');
      return;
    }

    if (_selectedEmotion == null) {
      _showMessage('감정을 선택해주세요');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final generatedPrayer = await OpenAIService.generatePrayer(
        _prayerController.text,
        _selectedEmotion!,
      );

      if (!mounted) return;

      // Store the original input in case user wants to revert
      final originalInput = _prayerController.text;

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder:
            (context) => AlertDialog(
              title: const Text('AI가 생성한 기도문'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '원래 입력:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(originalInput),
                    const SizedBox(height: 16),
                    const Text(
                      'AI 생성 기도문:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(generatedPrayer),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _prayerController.text =
                        originalInput; // Restore original input
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    _prayerController.text = generatedPrayer;
                    Navigator.of(context).pop();
                    _showMessage('AI 기도문이 적용되었습니다');
                  },
                  child: const Text('사용하기'),
                ),
              ],
            ),
      );
    } catch (e, stacktrace) {
      if (!mounted) return;

      print('Prayer generation error: $e');
      print('Stacktrace: $stacktrace');

      _showMessage('기도문 생성 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (ScaffoldMessenger.maybeOf(context) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } else {
      print("ScaffoldMessenger not available: $message");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB2EBF2),
        elevation: 0,
        centerTitle: true,
        title: const Text('매일 기도 루틴', style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: LocalScriptureService.loadScriptures(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('데이터 로딩 오류: ${snapshot.error}'));
          }

          // 데이터가 성공적으로 로드됨
          final scriptures = snapshot.data!;

          // 오늘의 말씀을 가져옴 (간단하게 첫 번째 항목 사용)
          final todayItem =
              scriptures.isNotEmpty ? scriptures[0] : <String, dynamic>{};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                          '📌 ${todayItem['theme_ko'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          todayItem['verse_ko'] ?? '',
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
                        const Text(
                          '🙏 예시 기도문',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          todayItem['prayer_ko'] ?? '여기에 예시 기도문이 표시됩니다.',
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
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: '감정 선택',
                    hintText: '지금의 감정 상태를 선택해주세요',
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
                      _emotions.map((String emotion) {
                        return DropdownMenuItem<String>(
                          value: emotion,
                          child: Text(emotion),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEmotion = newValue;
                    });
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    '내 감정을 선택한 후 상황에 맞게 적어보세요',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                // 기도문 입력창
                TextField(
                  controller: _prayerController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: '당신의 기도를 여기에 적어주세요...',
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
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.black,
                        ),
                        label: Text(
                          _isGenerating ? '생성 중...' : 'AI 도움받기',
                          style: const TextStyle(color: Colors.black),
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
                                  if (_prayerController.text.isEmpty) {
                                    _showMessage('기도 내용을 입력해주세요');
                                    return;
                                  }
                                  if (_selectedEmotion == null) {
                                    _showMessage('감정을 선택해주세요');
                                    return;
                                  }
                                  setState(() {
                                    _isGenerating = true;
                                  });
                                  try {
                                    final generatedPrayer =
                                        await OpenAIService.generatePrayer(
                                          _prayerController.text,
                                          _selectedEmotion!,
                                        );
                                    if (!mounted) return;
                                    final originalInput =
                                        _prayerController.text;
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text('AI가 생성한 기도문'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '원래 입력:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(originalInput),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'AI 생성 기도문:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(generatedPrayer),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _prayerController.text =
                                                      generatedPrayer;
                                                  Navigator.of(context).pop();
                                                  _showMessage(
                                                    'AI 기도문이 적용되었습니다',
                                                  );
                                                },
                                                child: const Text('사용하기'),
                                              ),
                                            ],
                                          ),
                                    );
                                  } catch (e) {
                                    _showMessage('기도문 생성 오류: $e');
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
                            icon: const Icon(Icons.save, color: Colors.black),
                            label: const Text(
                              '저장하기',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                                'date': DateTime.now().toString().split(' ')[0],
                              };
                              final String prayerJson = jsonEncode(prayerEntry);
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
                            label: const Text(
                              '내 기도문 보기',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyPrayersScreen(),
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
          );
        },
      ),
    );
  }

  Widget _buildPrayerForm(SharedPreferences prefs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _prayers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_prayers[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _prayerController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '당신의 기도를 여기에 적어주세요...',
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
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async => await _savePrayer(prefs),
            child: const Text('기도문 저장하기'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedEmotion,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: '감정 선택',
              hintText: '지금의 감정 상태를 선택해주세요',
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
                _emotions.map((String emotion) {
                  return DropdownMenuItem<String>(
                    value: emotion,
                    child: Text(emotion),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedEmotion = newValue;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed:
                _isGenerating
                    ? null
                    : () async {
                      if (_prayerController.text.isEmpty) {
                        _showMessage('기도 내용을 입력해주세요');
                        return;
                      }
                      if (_selectedEmotion == null) {
                        _showMessage('감정을 선택해주세요');
                        return;
                      }
                      setState(() {
                        _isGenerating = true;
                      });
                      try {
                        final generatedPrayer =
                            await OpenAIService.generatePrayer(
                              _prayerController.text,
                              _selectedEmotion!,
                            );
                        if (!mounted) return;
                        final originalInput = _prayerController.text;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('AI가 생성한 기도문'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '원래 입력:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(originalInput),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'AI 생성 기도문:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(generatedPrayer),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _prayerController.text = generatedPrayer;
                                      Navigator.of(context).pop();
                                      _showMessage('AI 기도문이 적용되었습니다');
                                    },
                                    child: const Text('사용하기'),
                                  ),
                                ],
                              ),
                        );
                      } catch (e) {
                        _showMessage('기도문 생성 오류: $e');
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isGenerating = false;
                          });
                        }
                      }
                    },
            icon:
                _isGenerating
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? '생성 중...' : '✨🙏 AI 도움받기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _savePrayer(prefs),
            icon: const Icon(Icons.save),
            label: const Text('💾 저장하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
