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
    ).timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw Exception('응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.'),
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
