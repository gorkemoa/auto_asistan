/// Form doğrulama kuralları
class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi boş bırakılamaz';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş bırakılamaz';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opsiyonel
    final regex = RegExp(r'^[0-9]{10,11}$');
    if (!regex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }

  static String? number(String? value, [String fieldName = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz';
    }
    if (double.tryParse(value) == null) {
      return 'Geçerli bir sayı giriniz';
    }
    return null;
  }

  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Yıl boş bırakılamaz';
    }
    final y = int.tryParse(value);
    if (y == null || y < 1900 || y > DateTime.now().year + 1) {
      return 'Geçerli bir yıl giriniz';
    }
    return null;
  }

  static String? plate(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opsiyonel
    // Türk plaka formatı kontrolü (basit)
    if (value.trim().length < 5) {
      return 'Geçerli bir plaka giriniz';
    }
    return null;
  }
}
