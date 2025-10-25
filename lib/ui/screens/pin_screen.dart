import 'package:flutter/material.dart';
import '../../core/security_service.dart';
import 'package:local_auth/local_auth.dart';

class PinScreen extends StatefulWidget {
  final VoidCallback onAuthenticated; // Hàm callback khi xác thực xong
  const PinScreen({super.key, required this.onAuthenticated});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isSettingPin = false;
  bool _isLoading = true;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkIfPinSet();
  }

  Future<void> _checkIfPinSet() async {
    final pin = await SecurityService.getPin();
    setState(() {
      _isSettingPin = pin == null;
      _isLoading = false;
    });
  }

  Future<void> _handleAuth() async {
    final savedPin = await SecurityService.getPin();
    final input = _pinController.text.trim();

    if (_isSettingPin) {
      await SecurityService.savePin(input);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã đặt mã PIN thành công!')),
      );
      setState(() => _isSettingPin = false);
      _pinController.clear();
    } else if (savedPin == input) {
      widget.onAuthenticated();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Mã PIN sai, thử lại!')));
    }
  }

  Future<void> _tryBiometricAuth() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      if (!canCheck) return;

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Xác thực để mở khóa ứng dụng',
      );

      if (didAuthenticate) {
        widget.onAuthenticated();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi xác thực: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSettingPin ? "Đặt mã PIN bảo vệ" : "Nhập mã PIN để mở khóa",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nhập mã PIN',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleAuth,
                child: Text(_isSettingPin ? 'Lưu mã PIN' : 'Xác nhận'),
              ),
              const SizedBox(height: 10),
              if (!_isSettingPin)
                OutlinedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("Dùng vân tay"),
                  onPressed: _tryBiometricAuth,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
