import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'qr_code_page.dart';

class RewardsPage extends StatefulWidget {
  final Map<String, dynamic> customer;

  const RewardsPage({super.key, required this.customer});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  List<Map<String, dynamic>> rewards = [];
  List<Map<String, dynamic>> redeemedRewards = [];

  @override
  void initState() {
    super.initState();
    fetchRewards(); // ดึงข้อมูลรางวัล
    fetchRedeemedRewards(); // ดึงข้อมูลรางวัลที่แลกแล้ว
    fetchCustomerData(); // ดึงข้อมูลลูกค้า (คะแนน)
  }

  Future<void> fetchRewards() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/rewards'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            rewards = data.map((reward) {
              // เพิ่ม redeemQuantity เริ่มต้นเป็น 1
              reward['redeemQuantity'] = 1;
              return reward as Map<String, dynamic>;
            }).toList();
          });
        }
      } else {
        if (mounted) {
          showErrorSnackBar('Unable to fetch rewards');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('Error occurred: $e');
      }
    }
  }

  Future<void> fetchRedeemedRewards() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/redeemed/${widget.customer['customer_id']}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          // Sort redeemed rewards from latest to oldest
          data.sort((a, b) => DateTime.parse(b['redemption_date'])
              .compareTo(DateTime.parse(a['redemption_date'])));

          setState(() {
            redeemedRewards =
                data.map((reward) => reward as Map<String, dynamic>).toList();
          });
        }
      } else {
        if (mounted) {
          showErrorSnackBar('Unable to fetch redeemed rewards');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('Error occurred: $e');
      }
    }
  }

  Future<void> fetchCustomerData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/customer/${widget.customer['customer_id']}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            widget.customer['points_balance'] =
                data['customer']['points_balance']; // Update total points
          });
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('Error occurred: $e');
      }
    }
  }

  Future<void> redeemReward(
      int rewardId, int pointsUsed, int redeemQuantity) async {
    // รหัสนี้จะต้องใช้ redeemQuantity ด้วย
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/redeem'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'customer_id': widget.customer['customer_id'],
          'reward_id': rewardId,
          'points_used': pointsUsed,
          'quantity': redeemQuantity, // ส่งจำนวนที่ต้องการแลกไปด้วย
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reward redeemed successfully')),
          );

          // Fetch fresh data to refresh the UI
          await fetchCustomerData(); // Refresh customer data
          await fetchRewards(); // Refresh rewards after redemption
          await fetchRedeemedRewards(); // Refresh redeemed rewards after redemption
        }
      } else {
        if (mounted) {
          showErrorSnackBar('Error redeeming reward');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('Error occurred: $e');
      }
    }
  }

  void showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showRewardDetails(Map<String, dynamic> reward, int redeemQuantity) {
    final int totalPoints = widget.customer['points_balance'];
    final int pointsRequired = reward['points_required'] *
        redeemQuantity; // คำนวณแต้มที่ใช้ตามจำนวนรางวัล

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'รายละเอียดรางวัล: ${reward['reward_name']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.green, // เปลี่ยนสีของหัวข้อ
            ),
          ),
          content: SingleChildScrollView(
            // เพิ่มการเลื่อนเพื่อให้ดูข้อมูลทั้งหมดได้
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward['description'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'คะแนนรวมของคุณ: $totalPoints',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'คะแนนที่ต้องการ: $pointsRequired',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'จำนวนที่ต้องการแลก: $redeemQuantity ชิ้น', // แสดงจำนวนรางวัลที่ต้องการแลก
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                reward['image'] != null
                    ? Image.network(
                        'http://10.0.2.2:3000/uploads/${reward['image']}',
                        height: 150,
                        fit: BoxFit.cover, // ทำให้ภาพดูดีในกรอบ
                      )
                    : const Text('ไม่มีภาพ'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดหน้าต่าง
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                // เรียกใช้ฟังก์ชันแลกของรางวัลพร้อมส่งจำนวนที่ต้องการแลกไปด้วย
                redeemReward(reward['reward_id'], pointsRequired,
                    redeemQuantity); // ส่ง redeemQuantity ไปด้วย
                if (mounted) {
                  Navigator.of(context).pop(); // ปิดหน้าต่าง
                }
              },
              child: const Text('แลก'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // เปลี่ยนสีของข้อความ
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRedeemedRewards() async {
    await fetchRedeemedRewards();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Redeemed Rewards',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.green,
            ),
          ),
          content: redeemedRewards.isEmpty
              ? const Text(
                  'No rewards redeemed yet',
                  style: TextStyle(fontSize: 18),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    itemCount: redeemedRewards.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final redeemedReward = redeemedRewards[index];
                      final DateTime redemptionDate =
                          DateTime.parse(redeemedReward['redemption_date']).add(
                              const Duration(hours: 7)); // Adjust for timezone
                      final String formattedDate =
                          DateFormat('dd/MM/yyyy HH:mm').format(redemptionDate);

                      String statusThai;
                      Color statusColor;
                      if (redeemedReward['status'] == 'completed') {
                        statusThai = 'Completed';
                        statusColor = Colors.green;
                      } else if (redeemedReward['status'] == 'pending') {
                        statusThai = 'Pending';
                        statusColor = Colors.orange;
                      } else {
                        statusThai = redeemedReward['status'];
                        statusColor = Colors.red;
                      }

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        child: ListTile(
                          leading: const Icon(
                            Icons.card_giftcard,
                            color: Colors.orange,
                            size: 40,
                          ),
                          title: Text(
                            redeemedReward['reward_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${redeemedReward['redemption_id']}',
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(redeemedReward['description']),
                                const SizedBox(height: 4),
                                Text(
                                  'Time: $formattedDate',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Quantity redeemed: ${redeemedReward['quantity'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // ปุ่มดู QR Code
                                TextButton(
                                  onPressed: () {
                                    // ไปยังหน้า QR Code โดยใช้ redemption_id
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => QrCodePage(
                                          qrData: redeemedReward[
                                                  'redemption_id']
                                              .toString(), // ส่ง redemption_id ไปยัง QR code
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Show QR Code'),
                                ),
                              ],
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: statusColor,
                                size: 25,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                statusThai,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPoints = widget.customer['points_balance'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('แลกของรางวัล',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
            },
          ),
        ],
      ),
      body: rewards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView.builder(
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final int availableQuantity = reward['quantity'];
                    int redeemQuantity = reward['redeemQuantity'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4, // เพิ่มความลึกให้กับการ์ด
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // มุมที่มน
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward['reward_name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green, // เปลี่ยนสีของชื่อรางวัล
                              ),
                            ),
                            const SizedBox(height: 8),
                            reward['image'] != null
                                ? Image.network(
                                    'http://10.0.2.2:3000/uploads/${reward['image']}',
                                    height: 150,
                                    fit: BoxFit.cover, // ปรับขนาดให้พอดีกับกรอบ
                                  )
                                : const Text('No image available'),
                            const SizedBox(height: 8),
                            Text(
                              reward['description'],
                              style: const TextStyle(
                                  color: Colors
                                      .black54), // เปลี่ยนสีข้อความให้ดูเรียบขึ้น
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'จำนวนใช้แต้ม: ${reward['points_required']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'จำนวนของรางวัล: $availableQuantity',
                              style: const TextStyle(color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (redeemQuantity > 1) {
                                      setState(() {
                                        rewards[index]['redeemQuantity']--;
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  redeemQuantity.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    if (redeemQuantity < availableQuantity) {
                                      setState(() {
                                        rewards[index]['redeemQuantity']++;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showRewardDetails(reward, redeemQuantity);
                              },
                              child: const Text('รายละเอียด / แลก'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green, // สีตัวอักษร
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.star, color: Colors.white),
                      onPressed: _showRedeemedRewards,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Card(
                    color: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        'คะแนนของคุณ: $totalPoints',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
