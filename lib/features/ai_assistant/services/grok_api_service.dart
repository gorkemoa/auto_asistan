import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/utils/logger.dart';

/// Grok API Servisi — AI mekanik asistanı
class GrokApiService {
  static final _apiKey = dotenv.get('XAI_API_KEY');
  static const _baseUrl = 'https://api.x.ai/v1/chat/completions';

  static const _systemPrompt = '''
Sen AutoAssist, deneyimli bir oto mekanik yapay zekasısın. Güncel yıl 2026. Kullanıcının araç sorunlarına ve bakımına yardımcı olacaksın.
Ayrıca sana kullanıcının araçları, geçmiş giderleri ve yaklaşan hatırlatmalarıyla ilgili veriler (CONTEXT) verilecek.

Görevin:
1. Kullanıcının verdiği arıza profilini dinle.
2. EĞER BİLGİ YETERSİZSE, hemen teşhiste bulunmak yerine kullanıcıya detay sor (Örn: "Ses metalik mi vurma sesi mi?", "Hangi hızlarda oluyor?").
3. Bilgiler yeterliyse olası sorunu belirle ve ciddiyet derecesini değerlendir.
4. Yapılması gerekenleri KISA, ÖZ ve NET bir dille listele. Asla uzun paragraflar yazma.
5. Sağlanan CONTEXT verilerini (Örn: bakım tarihi gelmiş mi, o araç için bilinen kronik sorun var mı) analizine dahil et.

ÖNEMLİ KURALLAR:
- ASLA çok uzun yazma, 1-2 cümlelik kısa cevaplar ver veya kısa maddeler kullan.
- Bilgi eksikse teşhis üretme, soru sor. ("diagnosis" JSON bloğunu göndermeyebilirsin veya boş bırakabilirsin).
- Kesin teşhismiş gibi davranma.
- Her mesajında Türkçe konuş ve anlaşılır ol.
- Güncel yılı 2026 olarak kabul et. En son otomotiv teknolojilerine görebilgi ver.
- Yanıtlarını DAİMA şu JSON formatında ver:
{
  "message": "Kullanıcıya vereceğin kısa metin",
  "diagnosis": {
    "possible_issue": "Olası sorun adı (Emin değilsen null bırak)",
    "severity": "low/medium/high/critical (Emin değilsen null bırak)",
    "description": "Risk ve durumun kısa açıklaması",
    "can_drive": true/false (Emin değilsen null bırak),
    "recommendations": ["Net öneri 1", "Net öneri 2"]
  }
}
''';

  /// AI'a soru sor
  Future<Map<String, dynamic>> askQuestion(
    String question, {
    List<Map<String, dynamic>> previousMessages = const [],
    String? userContext,
    String? base64Image,
  }) async {
    try {
      final List<Map<String, dynamic>> messages = [
        {'role': 'system', 'content': _systemPrompt},
        if (userContext != null)
          {
            'role': 'system',
            'content': 'KULLANICI VERİLERİ (CONTEXT):\\n$userContext',
          },
        ...previousMessages,
      ];

      if (base64Image != null) {
        messages.add({
          'role': 'user',
          'content': [
            {'type': 'text', 'text': question},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
          ],
        });
      } else {
        messages.add({'role': 'user', 'content': question});
      }

      final body = {
        'model': 'grok-4-1-fast-reasoning',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1024,
      };

      AppLogger.apiRequest('POST', _baseUrl, body);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(body),
      );

      AppLogger.apiResponse(
        'POST',
        _baseUrl,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // JSON formatında parse et
        try {
          final parsed = jsonDecode(content);
          return parsed;
        } catch (e) {
          AppLogger.warning('Gelen yanıt JSON formatında değil: $content');
          // JSON değilse düz metin olarak dön
          return {'message': content};
        }
      } else {
        AppLogger.error('API Hatası', response.body);
        throw Exception('API hatası: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('AI Chat Hatası', e, stackTrace);
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
