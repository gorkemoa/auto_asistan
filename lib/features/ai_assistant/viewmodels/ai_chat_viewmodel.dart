import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../garage/services/vehicle_repository.dart';
import '../../expenses/services/expense_repository.dart';
import '../../reminders/services/reminder_repository.dart';
import '../models/chat_message_model.dart';
import '../services/grok_api_service.dart';
import '../services/ai_chat_repository.dart';

/// AI Chat ViewModel
class AiChatViewModel extends ChangeNotifier {
  final GrokApiService _apiService = GrokApiService();
  final VehicleRepository _vehicleRepo = VehicleRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final ReminderRepository _reminderRepo = ReminderRepository();
  final AiChatRepository _chatRepo = AiChatRepository();
  final _uuid = const Uuid();

  List<ChatSessionModel> _sessions = [];
  String? _currentSessionId;
  
  bool _isTyping = false;
  bool _isLoadingSessions = true;

  List<ChatSessionModel> get sessions => _sessions;
  ChatSessionModel? get currentSession {
    if (_currentSessionId == null) return null;
    try {
      return _sessions.firstWhere((s) => s.id == _currentSessionId);
    } catch (_) {
      return null;
    }
  }

  List<ChatMessageModel> get messages => currentSession?.messages ?? [];
  bool get isTyping => _isTyping;
  bool get isLoadingSessions => _isLoadingSessions;

  AiChatViewModel() {
    Future.microtask(() => _initSessions());
  }

  /// Oturumları yükle
  Future<void> _initSessions() async {
    _isLoadingSessions = true;
    notifyListeners();

    try {
      _sessions = await _chatRepo.getSessions();

      if (_sessions.isEmpty) {
        await createNewChat();
      } else {
        await selectChat(_sessions.first.id);
      }
    } catch (e) {
      AppLogger.error('Chat yükleme hatası', e);
      if (_sessions.isEmpty) await createNewChat();
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  /// Yeni sohbet başlat
  Future<void> createNewChat() async {
    // Eğer en üstteki sohbet zaten yepyeni ve kullanılmamış bir sohbetse (Yeni Sohbet)
    // tekrar tekrar yeni sohbet oluşturmasını engelle.
    if (_sessions.isNotEmpty && _sessions.first.title == 'Yeni Sohbet') {
      await selectChat(_sessions.first.id);
      return;
    }

    final newSession = ChatSessionModel(
      id: _uuid.v4(),
      title: 'Yeni Sohbet',
      createdAt: DateTime.now(),
      messages: [],
    );

    // Oturumu DB'ye kaydet
    await _chatRepo.createSession(newSession);

    // Karşılama mesajı oluştur
    final welcomeMessage = ChatMessageModel(
      id: _uuid.v4(),
      content:
          'Merhaba! 👋 Ben AutoAssist AI mekanik asistanınızım.\n\n'
          'Aracınızla ilgili sorununuzu bana anlatın veya sormak istediğiniz soruları sorun.',
      isUser: false,
      timestamp: DateTime.now(),
    );
    newSession.messages.add(welcomeMessage);

    // Mesajı DB'ye kaydet
    await _chatRepo.saveMessage(newSession.id, welcomeMessage);

    _sessions.insert(0, newSession);
    _currentSessionId = newSession.id;
    notifyListeners();
  }

  /// Başka bir sohbete geç
  Future<void> selectChat(String sessionId) async {
    if (_currentSessionId == sessionId && (currentSession?.messages.isNotEmpty ?? false)) return;
    
    _isLoadingSessions = true;
    notifyListeners();
    
    try {
      _currentSessionId = sessionId;

      // Seçilen sohbetin mesajlarını getir (Eğer daha önce getirilmediyse)
      final session = currentSession;
      if (session != null && session.messages.isEmpty) {
        final msgs = await _chatRepo.getMessages(sessionId);
        session.messages.addAll(msgs);
      }
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  /// Sohbeti sil
  Future<void> deleteChat(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    
    // DB'den sil
    await _chatRepo.deleteSession(sessionId);
    
    if (_sessions.isEmpty) {
      await createNewChat(); // Hiç kalmadıysa yeni aç
    } else if (_currentSessionId == sessionId) {
      await selectChat(_sessions.first.id); // Silinen aktifse diğerine geç
    } else {
      notifyListeners();
    }
  }

  /// Başlığı otomatik güncelle (ilk mesaja göre)
  Future<void> _updateSessionTitleIfNeeded(String firstMessage) async {
    final session = currentSession;
    if (session == null) return;
    
    if (session.title == 'Yeni Sohbet' && session.messages.length <= 2) {
      final newTitle = firstMessage.length > 25 
          ? '${firstMessage.substring(0, 25)}...' 
          : firstMessage;
      
      final index = _sessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        // Obje güncellemesi
        _sessions[index] = ChatSessionModel(
          id: session.id,
          title: newTitle,
          createdAt: session.createdAt,
          messages: session.messages,
        );
        // DB güncellemesi
        await _chatRepo.updateSessionTitle(session.id, newTitle);
      }
    }
  }

  /// Mesaj gönder
  Future<void> sendMessage(String text, {String? imagePath}) async {
    final session = currentSession;
    if (session == null || (text.trim().isEmpty && imagePath == null)) return;

    String? publicImageUrl;
    String? base64Image;

    // Eğer görsel varsa, Supabase'e yükle ve base64 al
    if (imagePath != null) {
      try {
        final file = File(imagePath);
        final bytes = await file.readAsBytes();
        base64Image = base64Encode(bytes);

        final fileName = '${_uuid.v4()}.jpg';
        final path = 'chat_images/${session.id}/$fileName';

        await SupabaseService.client.storage
            .from('chat_images')
            .upload(path, file);

        publicImageUrl = SupabaseService.client.storage
            .from('chat_images')
            .getPublicUrl(path);
      } catch (e) {
        AppLogger.error('Görsel yükleme hatası', e);
      }
    }

    // Kullanıcı mesajı ekle
    final userMessage = ChatMessageModel(
      id: _uuid.v4(),
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: publicImageUrl,
    );
    session.messages.add(userMessage);
    
    if (text.trim().isNotEmpty) {
      await _updateSessionTitleIfNeeded(text.trim());
    } else if (imagePath != null) {
      await _updateSessionTitleIfNeeded('Görsel Mesaj');
    }
    
    await _chatRepo.saveMessage(session.id, userMessage);
    
    _isTyping = true;
    notifyListeners();

    try {
      // Kullanıcı verilerini (context) topla
      final context = await _getUserContext();

      // Önceki mesajları topla (bağlamı iyi kurmak için asistan ve user geçmişi)
      final previousMessages = session.messages
          .where((m) => m.id != userMessage.id && m.id != session.messages.first.id) // İlk karşılama mesajını atla
          .take(12) // Son 6 konuşmayı hatırla
          .map(
            (m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            },
          )
          .toList();

      final response = await _apiService.askQuestion(
        text,
        previousMessages: previousMessages,
        userContext: context,
        base64Image: base64Image,
      );

      DiagnosisModel? diagnosis;
      if (response.containsKey('diagnosis') && response['diagnosis'] != null) {
        diagnosis = DiagnosisModel.fromResponse(response['diagnosis']);
      }

      final aiMessage = ChatMessageModel(
        id: _uuid.v4(),
        content: response['message'] ?? 'Bir yanıt oluşturulamadı.',
        isUser: false,
        timestamp: DateTime.now(),
        diagnosis: diagnosis,
      );

      session.messages.add(aiMessage);
      await _chatRepo.saveMessage(session.id, aiMessage);
    } catch (e) {
      final errorMessage = ChatMessageModel(
        id: _uuid.v4(),
        content:
            'Üzgünüm, bir hata oluştu veya bağlantı kurulamadı. Lütfen tekrar deneyin.\n\n',
        isUser: false,
        timestamp: DateTime.now(),
      );
      session.messages.add(errorMessage);
      await _chatRepo.saveMessage(session.id, errorMessage);
    }

    _isTyping = false;
    notifyListeners();
  }

  /// Kullanıcının tüm araç, gider ve hatırlatma bilgilerini metin olarak hazırlar
  Future<String> _getUserContext() async {
    try {
      final vehicles = await _vehicleRepo.getVehicles();
      if (vehicles.isEmpty) return 'Henüz bir araç eklenmemiş.';

      final buffer = StringBuffer();
      buffer.writeln('KULLANICI GARAJI:');

      for (var v in vehicles) {
        buffer.writeln('\\n--- ARAÇ: ${v.brand} ${v.model} (${v.year}) ---');
        buffer.writeln('- Güncel KM: ${v.currentKm}');
        buffer.writeln('- Motor: ${v.engineType}, Plaka: ${v.plate}');

        final expenses = await _expenseRepo.getExpenses(v.id);
        if (expenses.isNotEmpty) {
          buffer.writeln('  SON GİDERLER:');
          final recentExpenses = expenses.take(3);
          for (var e in recentExpenses) {
            buffer.writeln(
              '  • ${e.categoryDisplayName}: ${e.amount}₺, Tarih: ${e.date.toIso8601String().split('T').first}',
            );
          }
        }

        final reminders = await _reminderRepo.getActiveReminders(v.id);
        if (reminders.isNotEmpty) {
          buffer.writeln('  AKTİF HATIRLATMALAR:');
          for (var r in reminders) {
            final dateStr =
                r.targetDate?.toIso8601String().split('T').first ??
                'Belirtilmedi';
            buffer.writeln(
              '  • ${r.title} (${r.typeDisplayName}): Hedef Tarih: $dateStr, Hedef KM: ${r.targetKm ?? "Belirtilmedi"}',
            );
          }
        }
      }

      return buffer.toString();
    } catch (e) {
      AppLogger.error('Context oluşturma hatası', e);
      return 'Kullanıcı verileri yüklenirken bir hata oluştu.';
    }
  }

  /// Geçerli sohbeti temizle
  Future<void> clearChat() async {
    final session = currentSession;
    if (session == null) return;
    
    // Yalnızca yeni bir sohbet başlat, silme işlemini yapmıyoruz
    await deleteChat(session.id);
  }
}

