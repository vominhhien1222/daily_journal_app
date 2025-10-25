import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const _pinKey = 'user_pin';
  static final _storage = const FlutterSecureStorage();

  /// Lưu mã PIN (đã mã hóa)
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// Lấy mã PIN
  static Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Kiểm tra PIN nhập vào
  static Future<bool> verifyPin(String inputPin) async {
    final savedPin = await getPin();
    return savedPin == inputPin;
  }

  /// Xóa PIN (khi người dùng muốn đổi)
  static Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }
}
