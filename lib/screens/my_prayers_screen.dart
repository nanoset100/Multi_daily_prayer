import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPrayersScreen extends StatefulWidget {
  const MyPrayersScreen({super.key});

  @override
  State<MyPrayersScreen> createState() => _MyPrayersScreenState();
}

class _MyPrayersScreenState extends State<MyPrayersScreen> {
  List<Map<String, dynamic>> _prayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  Future<void> _loadPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('saved_prayers');
    if (saved != null) {
      setState(() {
        _prayers =
            saved.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

        // Sort prayers by date in descending order (newest first)
        _prayers.sort((a, b) {
          final da = DateTime.parse(a['date'] ?? '');
          final db = DateTime.parse(b['date'] ?? '');
          return db.compareTo(da); // Descending order
        });

        _isLoading = false;
      });
    } else {
      setState(() {
        _prayers = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 기도문 모아보기')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _prayers.isEmpty
              ? const Center(child: Text('저장된 기도문이 없습니다.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _prayers.length,
                itemBuilder: (context, index) {
                  final prayer = _prayers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '[${prayer['emotion'] ?? ''}]',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                prayer['date'] ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(prayer['text'] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
