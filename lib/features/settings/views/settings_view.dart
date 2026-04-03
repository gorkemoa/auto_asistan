import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _authVM = AuthViewModel();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _authVM.loadProfile();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Oturumunuzu kapatmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authVM.signOut();
      // Uygulama rotasına göre ana sayfaya yönlendirilebilir. 
      // Burada logout sonrası AuthViewModel dinleyicileri tetiklenecektir.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _authVM,
          builder: (context, _) {
            final userEmail = _authVM.user?.email ?? 'Oturum açılmadı';
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppDimensions.pagePaddingH, 16, AppDimensions.pagePaddingH, 8),
                  child: Row(
                    children: [
                      Text('Ayarlar', style: AppTypography.h2),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SettingsList(
                    lightTheme: const SettingsThemeData(
                      settingsListBackground: AppColors.surfaceLight,
                      settingsSectionBackground: AppColors.surfaceCard,
                      titleTextColor: AppColors.primaryNavy,
                      leadingIconsColor: AppColors.accentBlue,
                      dividerColor: AppColors.surfaceDivider,
                    ),
                    sections: [
                      SettingsSection(
                        title: const Text('Genel'),
                        tiles: <SettingsTile>[
                          SettingsTile.navigation(
                            leading: const iconoir.User(width: 24, height: 24, color: AppColors.textPrimary),
                            title: const Text('Hesap Bilgileri'),
                            value: Text(userEmail),
                          ),
                          SettingsTile.switchTile(
                            onToggle: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                            initialValue: _notificationsEnabled,
                            leading: const iconoir.Bell(width: 24, height: 24, color: AppColors.textPrimary),
                            title: const Text('Bildirimler'),
                          ),
                          SettingsTile.switchTile(
                            onToggle: (value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                            },
                            initialValue: _darkModeEnabled,
                            leading: const iconoir.HalfMoon(width: 24, height: 24, color: AppColors.textPrimary),
                            title: const Text('Karanlık Mod'),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text('Uygulama'),
                        tiles: <SettingsTile>[
                          SettingsTile.navigation(
                            leading: const iconoir.InfoCircle(width: 24, height: 24, color: AppColors.textPrimary),
                            title: const Text('Hakkında'),
                            value: const Text('v1.0.0'),
                          ),
                          SettingsTile.navigation(
                            leading: const iconoir.Shield(width: 24, height: 24, color: AppColors.textPrimary),
                            title: const Text('Gizlilik Sözleşmesi'),
                            onPressed: (context) {
                              launchUrl(Uri.parse('https://autoassist.ai/privacy'));
                            },
                          ),
                          SettingsTile.navigation(
                            leading: const iconoir.LogOut(width: 24, height: 24, color: AppColors.danger),
                            title: const Text('Çıkış Yap', style: TextStyle(color: AppColors.danger)),
                            onPressed: (context) => _handleLogout(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
