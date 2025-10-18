import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_journal_app/app.dart'; // ✅ app chính của bạn

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 🔹 Build app chính và render frame đầu tiên
    await tester.pumpWidget(const App());

    // 🔹 Kiểm tra xem có tiêu đề chính (App title hoặc widget nào đó) không
    expect(find.text('Daily Journal & Mood'), findsOneWidget);
  });
}
