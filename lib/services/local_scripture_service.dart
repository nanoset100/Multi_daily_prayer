import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocalScriptureService {
  /// assets/daily_scriptures_ko.json 파일에서 모든 항목을 로드합니다.
  static Future<List<Map<String, dynamic>>> loadScriptures() async {
    final jsonStr = await rootBundle.loadString(
      'assets/daily_scriptures_ko.json',
    );
    final List<dynamic> list = json.decode(jsonStr);
    return list.cast<Map<String, dynamic>>();
  }
}
