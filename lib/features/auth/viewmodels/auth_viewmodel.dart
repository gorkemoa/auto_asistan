import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../services/auth_repository.dart';
import '../models/user_model.dart';

/// Auth ViewModel — giriş, kayıt ve oturum yönetimi
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;

  /// Giriş yap
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.signIn(email: email, password: password);
      _user = await _repo.getCurrentProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('SignIn ViewModel Hatası', e, stackTrace);
      _error = _mapError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Kayıt ol
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      _user = await _repo.getCurrentProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('SignUp ViewModel Hatası', e, stackTrace);
      _error = _mapError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Oturumu kapat
  Future<void> signOut() async {
    try {
      await _repo.signOut();
    } catch (e, stackTrace) {
      AppLogger.error('SignOut ViewModel Hatası', e, stackTrace);
    }
    _user = null;
    notifyListeners();
  }

  /// Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('ResetPassword ViewModel Hatası', e, stackTrace);
      _error = _mapError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Profil yükle
  Future<void> loadProfile() async {
    try {
      _user = await _repo.getCurrentProfile();
      notifyListeners();
    } catch (_) {}
  }

  /// Hatayı okunabilir metne çevir
  String _mapError(dynamic e) {
    // Supabase AuthApiException özel kontrolü
    if (e is AuthApiException) {
      if (e.code == 'over_email_send_rate_limit' ||
          e.statusCode?.toString() == '429') {
        return 'E-posta gönderim limiti aşıldı.\n\n'
            '💡 Geliştirici Notu: Supabase Dashboard > Authentication > Providers > Email kısmından "Confirm email" ayarını KAPATARAK bu limiti aşabilirsiniz.';
      }
      if (e.code == 'user_already_exists' ||
          e.message.contains('already registered')) {
        return 'Bu e-posta adresi zaten kayıtlı.';
      }
      if (e.code == 'invalid_credentials' ||
          e.message.contains('invalid login credentials')) {
        return 'E-posta veya şifre hatalı.';
      }
      return e.message;
    }

    final msg = e.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('socket')) {
      return 'İnternet bağlantınızı kontrol edin.';
    }
    return 'Hata: ${e.toString()}';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
