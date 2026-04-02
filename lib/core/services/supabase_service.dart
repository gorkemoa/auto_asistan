import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase servis singleton
/// Uygulama genelinde tek bir Supabase client kullanılır
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Supabase başlatma — main.dart'ta çağrılır
  static Future<void> initialize() async {
    await Supabase.initialize(
      // TODO: Supabase proje URL'sini buraya ekleyin
      url: 'https://ogskmmxtbwmyxxedacdh.supabase.co',
      // TODO: Supabase anon key'ini buraya ekleyin
      anonKey: 'sb_publishable_Du-Pj5uj5gAtnSOZVERVPg_ilM7QCFp',
      debug: true,
    );
  }

  /// Mevcut kullanıcı
  static User? get currentUser => client.auth.currentUser;

  /// Oturum durumunu dinle
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// Oturum açık mı?
  static bool get isLoggedIn => currentUser != null;
}
