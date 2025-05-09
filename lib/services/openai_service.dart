import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static Future<String> generatePrayer(String userInput, String emotion) async {
    try {
      print('Generating prayer for emotion: $emotion, input: $userInput');

      // Load API key from environment variables
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        print('Error: OpenAI API key is not set');
        throw Exception('OpenAI API key is not configured');
      }

      print('Making API request to OpenAI...');
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
              'content': '''
당신은 기독교인의 기도문을 작성하는 AI 도우미입니다.

아래 정보를 참고하여 회개, 간구, 감사의 요소를 포함한 진심 어린 기도문을 150자 내외로 작성하세요.

- 오늘의 성경 말씀을 기도에 반영하세요.
- 사용자가 직접 작성한 기도문 내용을 반영하세요.
- 사용자의 마음 상태(예: 불안, 외로움, 감사 등)에 공감하는 어투로 기도문을 구성하세요.
- 기도문은 "하나님 아버지," 혹은 "주님,"으로 시작하고 "예수님의 이름으로 기도드립니다. 아멘."으로 마무리하세요.
- 인공지능의 말투가 아닌, 따뜻하고 목회자의 말처럼 들리게 하세요.
''',
            },
            {
              'role': 'user',
              'content': '감정: $emotion\n내용: $userInput\n위의 내용을 바탕으로 기도를 도와주세요.',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      print('Received response with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decode response body using UTF-8
        final decodedBody = utf8.decode(response.bodyBytes);
        print('OpenAI Response Decoded Body: $decodedBody');

        final data = jsonDecode(decodedBody) as Map<String, dynamic>;

        // Defensive null checks
        if (data['choices'] == null || data['choices'].isEmpty) {
          print('Error: No choices returned by OpenAI');
          print('Response data: $data');
          throw Exception('No choices returned by OpenAI');
        }

        final message = data['choices'][0]?['message'];
        if (message == null || message is! Map) {
          print('Error: No valid message object found in the first choice');
          print('First choice data: ${data['choices'][0]}');
          throw Exception('No valid message object in the first choice');
        }

        final content = message['content'];
        if (content == null || content is! String) {
          print('Error: No valid message content returned by OpenAI');
          print('Message data: $message');
          throw Exception('No valid message content returned');
        }

        final generatedText = content;
        print('Successfully generated prayer text (UTF-8 decoded)');
        return generatedText;
      } else {
        print('API Error: ${response.statusCode}\nBody: ${response.body}');
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('Error generating prayer: $e');
      print('Stack trace: $stackTrace');
      // Re-throw the exception to be caught in the UI layer
      rethrow;
    }
  }
}
