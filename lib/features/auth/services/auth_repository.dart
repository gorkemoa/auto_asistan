import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/user_model.dart';

/// Auth repository — Supabase Auth işlemleri
class AuthRepository {
  final _client = SupabaseService.client;

  /// E-posta ile giriş
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    AppLogger.supabaseOp('SIGN_IN', 'auth', {'email': email});
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      AppLogger.info('Giriş başarılı: ${response.user?.email}');
      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Giriş Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// E-posta ile kayıt
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    AppLogger.supabaseOp('SIGN_UP_START', 'auth', {'email': email});
    try {
      AppLogger.info('Supabase Auth.signUp çağrılıyor...');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      AppLogger.info('Auth.signUp başarılı. User: ${response.user?.id}');

      // Kullanıcı profili oluştur
      if (response.user != null) {
        AppLogger.supabaseOp('INSERT_PROFILE_START', 'users', {'id': response.user!.id, 'full_name': fullName});
        try {
          await _client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'phone': phone,
          });
          AppLogger.info('Profil başarıyla oluşturuldu.');
        } catch (dbErr, dbStack) {
          AppLogger.error('Profil oluşturma (DB) Hatası: Veritabanında "users" tablosu oluşturulmamış olabilir veya RLS politikası eksik olabilir.', dbErr, dbStack);
          rethrow;
        }
      } else {
        AppLogger.warning('Auth.signUp sonrası user nesnesi null döndü (Email onayı bekliyor olabilir mi?)');
      }

      AppLogger.info('Tüm kayıt süreci başarılı.');
      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Genel Kayıt Hatası (Repository)', e, stackTrace);
      rethrow;
    }
  }

  /// Oturumu kapat
  Future<void> signOut() async {
    AppLogger.supabaseOp('SIGN_OUT', 'auth');
    try {
      await _client.auth.signOut();
    } catch (e, stackTrace) {
      AppLogger.error('Çıkış Hatası', e, stackTrace);
    }
  }

  /// Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    AppLogger.supabaseOp('RESET_PASSWORD', 'auth', {'email': email});
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e, stackTrace) {
      AppLogger.error('Şifre Sıfırlama Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Mevcut kullanıcı profilini getir
  Future<UserModel?> getCurrentProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    AppLogger.supabaseOp('SELECT', 'users', {'id': user.id});
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        AppLogger.warning('Profil bulunamadı: ${user.id}');
        return null;
      }
      return UserModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('Profil Getirme Hatası', e, stackTrace);
      return null;
    }
  }

  /// Profili güncelle
  Future<void> updateProfile(UserModel profile) async {
    AppLogger.supabaseOp('UPDATE', 'users', {'id': profile.id});
    try {
      await _client.from('users').update(profile.toJson()).eq('id', profile.id);
      AppLogger.info('Profil güncellendi');
    } catch (e, stackTrace) {
      AppLogger.error('Profil Güncelleme Hatası', e, stackTrace);
      rethrow;
    }
  }
}
