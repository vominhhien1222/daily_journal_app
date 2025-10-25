import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Đăng ký tài khoản mới
  Future<User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Lỗi đăng ký: ${e.code}");
      rethrow;
    }
  }

  /// 🔹 Đăng nhập
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Lỗi đăng nhập: ${e.code}");
      rethrow;
    }
  }

  /// 🔹 Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// 🔹 Kiểm tra user hiện tại
  User? get currentUser => _auth.currentUser;

  /// 🔹 Lắng nghe thay đổi đăng nhập (realtime)
  Stream<User?> get userChanges => _auth.userChanges();
}
