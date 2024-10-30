import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transactions_page.dart';
import 'card_page.dart';
import 'rewards_page.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> customer;

  const HomePage({super.key, required this.customer});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
    _fetchNews();
  }

  Future<void> _fetchCustomerData() async {
    final url =
        'http://10.0.2.2:3000/customers/${widget.customer['customer_id']}';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final updatedCustomer = json.decode(response.body);
        setState(() {
          widget.customer['points_balance'] =
              updatedCustomer['customer']['points_balance'];
        });
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  List<dynamic> newsList = [];

  Future<void> _fetchNews() async {
    final url = 'http://10.0.2.2:3000/news'; // URL ของ API

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          newsList = json.decode(response.body);
        });
      } else {
        print('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _fetchCustomerData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getPage(int index) {
      switch (index) {
        case 1:
          return TransactionsPage(customerId: widget.customer['customer_id']);
        case 2:
          return CardPage(customer: widget.customer);
        case 3:
          return RewardsPage(customer: widget.customer);
        case 4:
          return AdditionalPage(customer: widget.customer);
        default:
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/pumpwallpaper.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black38,
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อสมาชิก
                      Text(
                        '${widget.customer['first_name']} ${widget.customer['last_name']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),

                      // เลขสมาชิกสหกรณ์
                      Text(
                        'เลขสมาชิกสหกรณ์ : ${widget.customer['customer_id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),

                      // เบอร์โทรศัพท์
                      Text(
                        'เบอร์ : ${widget.customer['phone_number']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[700]!, Colors.green[800]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stars,
                              color: Colors.yellowAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'แต้มสะสม: ${widget.customer['points_balance']} แต้ม',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 220, // เปลี่ยนตำแหน่งกรอบข่าวให้ติดกับการ์ด
                left: 20,
                right: 20,
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // ปรับความโปร่งใส
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final newsItem = newsList[index];
                      return Padding(
                        padding:
                            const EdgeInsets.all(10.0), // เพิ่ม padding รอบๆ
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'http://10.0.2.2:3000/uploadnews/${newsItem['image_url']}',
                                width: double.infinity, // ให้ภาพขยายเต็มพื้นที่
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              newsItem['description'] ?? 'ไม่มีคำอธิบาย',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(
                                height: 20,
                                thickness: 1,
                                color: Colors.grey), // เพิ่มเส้นแบ่งระหว่างข่าว
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
      }
    }

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text('สวัสดี ${widget.customer['first_name']}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchCustomerData,
                ),
              ],
              backgroundColor: Colors.green,
            )
          : null,
      body: getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'รายการ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'บัตร',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.redeem),
            label: 'แลกรางวัล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'เพิ่มเติม',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 42, 216, 181),
        unselectedItemColor: const Color.fromARGB(255, 253, 253, 253),
        backgroundColor: const Color.fromARGB(255, 54, 124, 56),
        onTap: _onItemTapped,
      ),
    );
  }
}
