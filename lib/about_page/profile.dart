import 'package:flutter/material.dart';


// Profile Page
class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> customer;

  const ProfilePage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลส่วนตัว')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อมูลส่วนตัวของ ${customer['first_name']} ${customer['last_name']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'หมายเลขโทรศัพท์: ${customer['phone_number']}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'แต้มสะสม: ${customer['points_balance']}',
              style: const TextStyle(fontSize: 18),
            ),
            
          ],
        ),
      ),
    );
  }
}


