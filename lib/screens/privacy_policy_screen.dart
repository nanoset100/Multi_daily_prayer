import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('매일 기도 루틴 — 개인정보 처리방침'),
            _Body('최종 업데이트: 2024년 12월'),
            SizedBox(height: 16),

            _Heading('1. 수집하는 정보'),
            _Body('• 기도 기록: 사용자가 입력한 기도 내용 및 날짜\n'
                '• 앱 사용 통계: 기도 횟수, 접속 패턴 (개인 식별 불가)\n'
                '• 알림 설정: 기도 알림 시간'),

            _Heading('2. 수집하지 않는 정보'),
            _Body('이름, 이메일, 전화번호 등 개인 식별 정보, 위치 정보, '
                '연락처, 기기의 다른 앱 정보는 수집하지 않습니다.'),

            _Heading('3. 정보 이용 목적'),
            _Body('기도 기록 저장 및 관리, 기도 알림 제공, 앱 기능 개선에만 사용합니다.'),

            _Heading('4. 정보 저장 및 보안'),
            _Body('모든 데이터는 Supabase의 안전한 클라우드 서버에 암호화되어 저장됩니다. '
                '데이터 전송 시 HTTPS를 사용합니다.'),

            _Heading('5. 정보 공유'),
            _Body('사용자의 개인정보를 제3자와 공유하지 않습니다. '
                '광고 목적으로 정보를 사용하지 않습니다.'),

            _Heading('6. AI 기능 안내'),
            _Body('기도문 생성 기능은 OpenAI의 AI 기술을 사용합니다. '
                'AI가 생성한 기도문임을 명시합니다. '
                'AI 생성에 사용된 입력 텍스트는 서버에 저장되지 않습니다.'),

            _Heading('7. 아동 개인정보 보호'),
            _Body('13세 미만 아동의 개인정보를 의도적으로 수집하지 않습니다.'),

            _Heading('8. 사용자 권리'),
            _Body('• 저장된 데이터를 언제든지 확인, 수정, 삭제할 수 있습니다.\n'
                '• 앱 사용을 언제든지 중단할 수 있습니다.'),

            _Heading('9. 정책 변경'),
            _Body('개인정보 처리방침이 변경되는 경우 앱 내에서 공지합니다.'),

            _Heading('10. 문의'),
            _Body('개인정보 처리방침 관련 문의는 앱스토어 문의 기능을 이용해 주세요.'),

            SizedBox(height: 32),
            Divider(),
            SizedBox(height: 16),

            _SectionTitle('Privacy Policy (English)'),
            _Body('Last Updated: December 2024'),
            SizedBox(height: 16),

            _Heading('1. Information We Collect'),
            _Body('• Prayer records entered by users\n'
                '• App usage statistics (non-identifiable)\n'
                '• Notification settings'),

            _Heading('2. Information We Do NOT Collect'),
            _Body('We do not collect names, emails, phone numbers, location data, '
                'contacts, or information from other apps.'),

            _Heading('3. AI Feature'),
            _Body('Prayer generation uses OpenAI technology. '
                'All AI-generated content is clearly disclosed. '
                'Input text is not stored on our servers.'),

            _Heading('4. Data Security'),
            _Body('All data is encrypted and stored on Supabase secure cloud servers '
                'using HTTPS.'),

            _Heading('5. Children\'s Privacy'),
            _Body('We do not collect personal information from children under 13.'),

            _Heading('6. Contact'),
            _Body('For questions, please contact us through the app store support page.'),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
    );
  }
}
