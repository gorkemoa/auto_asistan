import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_service.dart';
import 'core/services/storage_service.dart';
import 'app.dart';

/// AutoAssist — Dijital Araç Asistanı
/// Ana giriş noktası
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Durum çubuğu stili
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Yalnızca dikey mod
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Servisleri başlat
  await dotenv.load(fileName: ".env");
  await StorageService.initialize();
  await SupabaseService.initialize();

  runApp(const App());
}
