import 'package:supabase_flutter/supabase_flutter.dart';

class OpenAIService {
  static Future<String> generatePrayer(
    String userInput,
    String emotion,
    String languageCode,
    String bibleVerse,
  ) async {
    final response = await Supabase.instance.client.functions.invoke(
      'generate-prayer',
      body: {
        'userInput': userInput,
        'emotion': emotion,
        'languageCode': languageCode,
        'bibleVerse': bibleVerse,
      },
    );

    if (response.data == null) {
      throw Exception('기도문 생성에 실패했습니다');
    }

    final error = response.data['error'] as String?;
    if (error != null) {
      throw Exception(error);
    }

    final prayer = response.data['prayer'] as String?;
    if (prayer == null || prayer.isEmpty) {
      throw Exception('기도문을 받지 못했습니다');
    }

    return prayer;
  }
}
