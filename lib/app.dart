import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/auth/views/onboarding_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'navigation/bottom_nav_shell.dart';

/// Ana uygulama widget'ı
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Auth durumu: 'loading', 'onboarding', 'login', 'register', 'home'
  String _screen = 'loading';

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Supabase auth kontrol
    if (SupabaseService.isLoggedIn) {
      if (!StorageService.isOnboardingComplete) {
        setState(() => _screen = 'onboarding');
      } else {
        setState(() => _screen = 'home');
      }
    } else {
      setState(() => _screen = 'login');
    }

    // Auth değişikliklerini dinle
    SupabaseService.authStateChanges.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        if (!StorageService.isOnboardingComplete) {
          setState(() => _screen = 'onboarding');
        } else {
          setState(() => _screen = 'home');
        }
      } else if (event.event == AuthChangeEvent.signedOut) {
        setState(() => _screen = 'login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Türkçe lokalizasyon
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case 'loading':
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case 'onboarding':
        return OnboardingView(
          onComplete: () => setState(() => _screen = 'home'),
        );

      case 'login':
        return LoginView(
          onRegisterTap: () => setState(() => _screen = 'register'),
          onLoginSuccess: () {
            if (!StorageService.isOnboardingComplete) {
              setState(() => _screen = 'onboarding');
            } else {
              setState(() => _screen = 'home');
            }
          },
        );

      case 'register':
        return RegisterView(
          onLoginTap: () => setState(() => _screen = 'login'),
          onRegisterSuccess: () => setState(() => _screen = 'onboarding'),
        );

      case 'home':
        return const BottomNavShell();

      default:
        return const Scaffold(body: Center(child: Text('Hata')));
    }
  }
}
