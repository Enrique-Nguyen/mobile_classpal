import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Màu nền xám nhạt
        primaryColor: const Color(0xFF2E3A8C), // Màu xanh đậm chủ đạo
        fontFamily: 'Roboto', // Hoặc Poppins nếu bạn import Google Fonts
      ),
      home: const EventsScreen(),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final int registeredCount;
  final int maxCount;
  final bool isJoinable; // Để chỉnh style nút Join (đậm/nhạt)

  const EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.registeredCount,
    required this.maxCount,
    this.isJoinable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 8),
          // 2. Description
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          // 3. Info Row (Date & Location)
          Row(
            children: [
              _buildIconText(Icons.calendar_today_outlined, "$date\n$time"),
              const SizedBox(width: 24),
              _buildIconText(Icons.location_on_outlined, location),
            ],
          ),
          const SizedBox(height: 20),
          // 4. Join Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isJoinable ? const Color(0xFF2E3A8C) : const Color(0xFFEFF2F7),
                elevation: isJoinable ? 2 : 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   if(isJoinable) const Icon(Icons.check, color: Colors.white, size: 20),
                   if(isJoinable) const SizedBox(width: 8),
                   Text(
                    "JOIN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isJoinable ? Colors.white : const Color(0xFFA0AEC0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 5. Registration Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Registered", style: TextStyle(color: Color(0xFF5E6C84))),
                Text(
                  "$registeredCount/$maxCount",
                  style: const TextStyle(
                    color: Color(0xFF00C853), // Màu xanh lá
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper widget cho icon + text
  Widget _buildIconText(IconData icon, String text) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E3A8C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF5E6C84), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildHeaderButton(Icons.grid_view), // Menu Button
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text("Events & attendance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("CS101 · Product Ops", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildHeaderButton(Icons.notifications_none),
                  const SizedBox(width: 8),
                  _buildHeaderButton(Icons.emoji_events_outlined),
                ],
              ),
            ),
            
            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search events...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // --- List of Events ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  EventCard(
                    title: "Văn nghệ 20/11",
                    description: "Tham dự đi để lấy điểm rèn luyện!",
                    date: "Dec 1, 2024",
                    time: "18:00 - 22:00",
                    location: "Hội trường T45",
                    registeredCount: 18,
                    maxCount: 30,
                    isJoinable: true,
                  ),
                  EventCard(
                    title: "Trường học không ma tóe",
                    description: "Sự kiện của VTV",
                    date: "Nov 30, 2024",
                    time: "14:00 - 17:00",
                    location: "Tập trung tại cổng trường",
                    registeredCount: 22,
                    maxCount: 30,
                    isJoinable: false, // Giả lập trạng thái nút nhạt màu
                  ),
                   EventCard(
                    title: "Talkshow về AI trong thời đại số",
                    description: "Diễn giả nổi tiếng của Meta về trường để xàm lờ",
                    date: "Dec 5, 2024",
                    time: "15:00 - 17:00",
                    location: "Hội trường T35",
                    registeredCount: 15,
                    maxCount: 30,
                    isJoinable: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // --- Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Đang chọn Events
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Duties"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Assets"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Funds"),
           BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, size: 20, color: Colors.black87),
    );
  }
}