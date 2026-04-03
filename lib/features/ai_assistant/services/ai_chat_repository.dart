// Removed unused import: dart:convert
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/chat_message_model.dart';

/// AI Sohbet Geçmişi Repository — Supabase CRUD
class AiChatRepository {
  final _client = SupabaseService.client;

  /// Kullanıcının tüm sohbet oturumlarını getir (Sadece başlıklar ve tarihler)
  Future<List<ChatSessionModel>> getSessions() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    AppLogger.supabaseOp('SELECT', 'ai_chat_sessions', {'user_id': userId});
    try {
      // Sadece oturum bilgilerini çeker, mesajları sonra çekeceğiz
      final data = await _client
          .from('ai_chat_sessions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data.map((json) {
        return ChatSessionModel(
          id: json['id'],
          title: json['title'],
          createdAt: DateTime.parse(json['created_at']),
          messages: [], // Mesajları henüz çekmiyoruz, hafif kalsın
        );
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error('AiChat Oturumları Getirme Hatası', e, stackTrace);
      return [];
    }
  }

  /// Belirli bir oturumun tüm mesajlarını getir
  Future<List<ChatMessageModel>> getMessages(String sessionId) async {
    AppLogger.supabaseOp('SELECT', 'ai_chat_messages', {'session_id': sessionId});
    try {
      final data = await _client
          .from('ai_chat_messages')
          .select()
          .eq('session_id', sessionId)
          .order('timestamp', ascending: true);

      return data.map((json) {
        return ChatMessageModel(
          id: json['id'],
          content: json['content'],
          isUser: json['is_user'],
          timestamp: DateTime.parse(json['timestamp']),
          imageUrl: json['image_url'],
          diagnosis: json['diagnosis'] != null
              ? DiagnosisModel.fromJson(Map<String, dynamic>.from(json['diagnosis']))
              : null,
        );
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error('AiChat Mesajları Getirme Hatası', e, stackTrace);
      return [];
    }
  }

  /// Yeni oturum oluştur
  Future<void> createSession(ChatSessionModel session) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    AppLogger.supabaseOp('INSERT', 'ai_chat_sessions', {'id': session.id});
    try {
      await _client.from('ai_chat_sessions').insert({
        'id': session.id,
        'user_id': userId,
        'title': session.title,
        'created_at': session.createdAt.toIso8601String(),
      });
    } catch (e, stackTrace) {
      AppLogger.error('AiChat Oturum Oluşturma Hatası', e, stackTrace);
    }
  }

  /// Oturum başlığını güncelle
  Future<void> updateSessionTitle(String sessionId, String title) async {
    AppLogger.supabaseOp('UPDATE', 'ai_chat_sessions', {'id': sessionId, 'title': title});
    try {
      await _client
          .from('ai_chat_sessions')
          .update({'title': title})
          .eq('id', sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('AiChat Başlık Güncelleme Hatası', e, stackTrace);
    }
  }

  /// Oturumu tamamen sil (Cascade delete ile mesajlar da silinir)
  Future<void> deleteSession(String sessionId) async {
    AppLogger.supabaseOp('DELETE', 'ai_chat_sessions', {'id': sessionId});
    try {
      await _client.from('ai_chat_sessions').delete().eq('id', sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('AiChat Oturum Silme Hatası', e, stackTrace);
    }
  }

  /// Mesaj kaydet
  Future<void> saveMessage(String sessionId, ChatMessageModel message) async {
    AppLogger.supabaseOp('INSERT', 'ai_chat_messages', {'session_id': sessionId, 'id': message.id});
    try {
      await _client.from('ai_chat_messages').insert({
        'id': message.id,
        'session_id': sessionId,
        'content': message.content,
        'is_user': message.isUser,
        'image_url': message.imageUrl,
        'diagnosis': message.diagnosis?.toJson(),
        'timestamp': message.timestamp.toIso8601String(),
      });
    } catch (e, stackTrace) {
      AppLogger.error('AiChat Mesaj Kaydetme Hatası', e, stackTrace);
    }
  }
}
