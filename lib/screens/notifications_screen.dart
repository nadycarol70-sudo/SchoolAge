import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'search_criteria_screen.dart';
import 'thematic_map_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _currentIndex = 1; // Notifications is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 24),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // Balance the back button
                ],
              ),
            ),

            // Notification List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 20),
                  // Notification Card 1 - Application Status
                  _buildNotificationCard(
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.withOpacity(0.1),
                    title: 'Application Status Updated',
                    description: 'Your application to City International School has been processed.',
                    actionButton: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A), // Green button
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Processing Complete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notification Card 2 - Acceptance
                  _buildNotificationCard(
                    icon: Icons.check_circle,
                    iconColor: Colors.orange,
                    iconBgColor: Colors.orange.withOpacity(0.1),
                    title: 'Congratulations!',
                    description: 'Your child has been accepted at City International School!',
                    customContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 32),
                        const Text(
                          'Interview Scheduled:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Thursday, October 15th at 10:00 AM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD6EBE8),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThematicMapScreen()),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SearchCriteriaScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(CupertinoIcons.bell_fill),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_app),
            label: 'Add',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    Widget? actionButton,
    Widget? customContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B3346),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 16),
            actionButton,
          ],
          if (customContent != null) customContent,
        ],
      ),
    );
  }
}


