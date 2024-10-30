import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardPage extends StatelessWidget {
  final Map<String, dynamic> customer;

  const CardPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'บัตรสะสมแต้ม (สมาชิกสหกรณ์การเกษตร)',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.green,
      ),
      body: Container(
        // ใช้ Container สำหรับพื้นหลัง
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/pumpwallpaper.png"), // ระบุที่ตั้งของรูปภาพพื้นหลัง
            fit: BoxFit.cover, // ปรับให้ภาพพื้นหลังครอบคลุมเต็มหน้าจอ
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.9, // ปรับให้เหมาะสมกับขนาดหน้าจอ
                    height: 300, // เพิ่มความสูงการ์ด
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/member_card.png'), // ใส่ภาพพื้นหลังใหม่
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            'ID: ${customer['customer_id'] ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: QrImageView(
                            data: customer['phone_number']?.toString() ?? "N/A",
                            version: QrVersions.auto,
                            size: 150.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Phone: ${customer['phone_number'] ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.all(16.0), // เพิ่ม padding รอบๆ ข้อความ
                  decoration: BoxDecoration(
                    color: Colors.green[100], // สีพื้นหลัง
                    border: Border.all(
                        color: Colors.green, width: 2), // กรอบสีเขียว
                    borderRadius: BorderRadius.circular(10), // มุมกรอบที่มน
                  ),
                  child: const Text(
                    '* แสดงบัตรสมาชิกนี้ต่อพนักงานเมื่อทำรายการเติมน้ำมัน เพื่อรับแต้มสะสม *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
