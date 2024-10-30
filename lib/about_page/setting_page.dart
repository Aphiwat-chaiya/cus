//Settings Page
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

// Define the State for the SettingsPage
class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _pointsEarnedEnabled = true;
  bool _pointsUsedEnabled = true;
  bool _newProductNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _pointsEarnedEnabled = prefs.getBool('pointsEarnedEnabled') ?? true;
      _pointsUsedEnabled = prefs.getBool('pointsUsedEnabled') ?? true;
      _newProductNotificationEnabled =
          prefs.getBool('newProductNotificationEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
    prefs.setBool('pointsEarnedEnabled', _pointsEarnedEnabled);
    prefs.setBool('pointsUsedEnabled', _pointsUsedEnabled);
    prefs.setBool(
        'newProductNotificationEnabled', _newProductNotificationEnabled);

    // Show confirmation after saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกการแจ้งเตือนสำเร็จ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('แจ้งเตือน'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('ได้รับแต้ม'),
            value: _pointsEarnedEnabled,
            onChanged: (bool value) {
              setState(() {
                _pointsEarnedEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('ใช้แต้ม'),
            value: _pointsUsedEnabled,
            onChanged: (bool value) {
              setState(() {
                _pointsUsedEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('สินค้าใหม่มาแล้ว'),
            value: _newProductNotificationEnabled,
            onChanged: (bool value) {
              setState(() {
                _newProductNotificationEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          ElevatedButton(
            onPressed: _saveSettings, // Save all settings at once
            child: const Text('บันทึกการตั้งค่า'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}