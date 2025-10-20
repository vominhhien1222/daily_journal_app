import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt ⚙️'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🌙 Dark mode
          SwitchListTile(
            value: settings.darkMode,
            onChanged: (_) => settings.toggleDarkMode(),
            title: const Text('Chế độ tối'),
            subtitle: const Text(
              'Chuyển giao diện sang nền nâu trầm vintage 🌙',
            ),
          ),
          const Divider(height: 24),

          // 🔔 Daily reminder
          SwitchListTile(
            value: settings.reminderEnabled,
            onChanged: (val) => settings.toggleReminder(val),
            title: const Text('Nhắc tôi viết nhật ký mỗi ngày'),
            subtitle: const Text('Gửi lời nhắc nhẹ nhàng vào giờ bạn chọn 🕯️'),
          ),
          if (settings.reminderEnabled)
            ListTile(
              title: const Text('Giờ nhắc nhở'),
              subtitle: Text(settings.reminderTimeLabel),
              trailing: const Icon(
                Icons.access_time_rounded,
                color: Colors.brown,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: settings.reminderTime,
                );
                if (picked != null) {
                  settings.updateReminderTime(picked);
                }
              },
            ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Phiên bản 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
