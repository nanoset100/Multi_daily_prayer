import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class OpenAIService {
  static Future<String> generatePrayer(
    String userInput,
    String emotion,
    String languageCode,
    String bibleVerse,
  ) async {
    try {
      debugPrint(
        'Generating prayer for emotion: $emotion, input: $userInput, lang: $languageCode, verse: $bibleVerse',
      );

      // Load API key from environment variables
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('Error: OpenAI API key is not set');
        throw Exception('OpenAI API key is not configured');
      }

      debugPrint('Making API request to OpenAI...');
      // Prepare the request
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': _getLocalizedPrompt(
                languageCode,
                userInput,
                bibleVerse,
                emotion,
              ),
            },
            {'role': 'user', 'content': userInput},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      debugPrint('Received response with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decode response body using UTF-8
        final decodedBody = utf8.decode(response.bodyBytes);
        debugPrint('OpenAI Response Decoded Body: $decodedBody');

        final data = jsonDecode(decodedBody) as Map<String, dynamic>;

        // Defensive null checks
        if (data['choices'] == null || data['choices'].isEmpty) {
          debugPrint('Error: No choices returned by OpenAI');
          debugPrint('Response data: $data');
          throw Exception('No choices returned by OpenAI');
        }

        final message = data['choices'][0]?['message'];
        if (message == null || message is! Map) {
          debugPrint(
            'Error: No valid message object found in the first choice',
          );
          debugPrint('First choice data: ${data['choices'][0]}');
          throw Exception('No valid message object in the first choice');
        }

        final content = message['content'];
        if (content == null || content is! String) {
          debugPrint('Error: No valid message content returned by OpenAI');
          debugPrint('Message data: $message');
          throw Exception('No valid message content returned');
        }

        final generatedText = content;
        debugPrint('Successfully generated prayer text (UTF-8 decoded)');
        return generatedText;
      } else {
        debugPrint('API Error: ${response.statusCode}\nBody: ${response.body}');
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error generating prayer: $e');
      debugPrint('Stack trace: $stackTrace');
      // Re-throw the exception to be caught in the UI layer
      rethrow;
    }
  }

  static String _getLocalizedPrompt(
    String languageCode,
    String userInput,
    String bibleVerse,
    String emotion,
  ) {
    switch (languageCode) {
      case 'en':
        return '''
You are an AI assistant writing Christian prayers.

Write a heartfelt prayer of around 150 characters including elements of repentance, supplication, and gratitude, following these instructions:

- Reflect today's Bible verse: "$bibleVerse"
- Incorporate the user's written prayer input: "$userInput"
- Use a compassionate tone that empathizes with the user's emotional state: "$emotion"
- Start the prayer with "Dear Heavenly Father," or "Lord," and end with "In Jesus' name, Amen."
- The prayer should sound like the warm words of a pastor, not like AI-generated text.
''';
      case 'ja':
        return '''
あなたはクリスチャンの祈りを作成するAIアシスタントです。

以下の指示に従って、悔い改め、願い、感謝の要素を含む約150文字の心のこもった祈りを作成してください。

- 今日の聖書の御言葉を反映してください: "$bibleVerse"
- ユーザーが書いた祈りの内容を反映してください: "$userInput"
- ユーザーの感情 "$emotion" に共感する口調で書いてください
- 「天のお父様、」または「主よ、」で始め、「イエス様のお名前でお祈りします。アーメン。」で締めくくってください
- AIのようではなく、牧師の温かい言葉のように聞こえるように書いてください。
''';
      case 'zh':
        return '''
你是一位为基督徒撰写祷告文的AI助手。

请根据以下指示，撰写一篇约150字，包含悔改、祈求和感恩元素的真诚祷告文。

- 融入今日的圣经经文: "$bibleVerse"
- 融入用户输入的祷告内容: "$userInput"
- 用充满同理心的语气回应用户的情绪: "$emotion"
- 以"亲爱的天父"或"主啊"开头，以"奉耶稣的名祷告，阿门。"结尾
- 不要像AI一样，而要像牧师温暖的话语一样
''';
      case 'es':
        return '''
Eres un asistente de IA que escribe oraciones cristianas.

Escribe una oración sincera de unas 150 palabras que incluya elementos de arrepentimiento, súplica y gratitud, siguiendo estas instrucciones:

- Refleja el versículo bíblico de hoy: "$bibleVerse"
- Incorpora el contenido de oración escrito por el usuario: "$userInput"
- Usa un tono compasivo que empatice con el estado emocional del usuario: "$emotion"
- Comienza con "Padre Celestial," o "Señor," y termina con "En el nombre de Jesús, Amén."
- La oración debe sonar como las palabras cálidas de un pastor, no como un texto generado por IA.
''';
      default:
        return '''
당신은 기독교인의 기도문을 작성하는 AI 도우미입니다.

아래 지시사항을 참고하여 회개, 간구, 감사의 요소를 포함한 진심 어린 기도문을 150자 내외로 작성하세요.

- 오늘의 성경 말씀을 기도에 반영하세요: "$bibleVerse"
- 사용자가 직접 작성한 기도문 내용을 반영하세요: "$userInput"
- 사용자의 마음 상태 "$emotion" 에 공감하는 어투로 기도문을 구성하세요.
- 기도문은 "하나님 아버지," 혹은 "주님,"으로 시작하고 "예수님의 이름으로 기도드립니다. 아멘."으로 마무리하세요.
- 인공지능의 말투가 아닌, 따뜻하고 목회자의 말처럼 들리게 하세요.
''';
    }
  }
}
