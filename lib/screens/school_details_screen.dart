import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import 'application_screen.dart';
import 'thematic_map_screen.dart';

class SchoolDetailsScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;
  final Map<String, dynamic>? schoolData;

  const SchoolDetailsScreen({
    super.key,
    this.schoolId = '',
    this.schoolName = '',
    this.schoolData,
  });

  @override
  State<SchoolDetailsScreen> createState() => _SchoolDetailsScreenState();
}

class _SchoolDetailsScreenState extends State<SchoolDetailsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Header Image
                  Stack(
                    children: [
                      widget.schoolData?['image_url'] != null || widget.schoolData?['image'] != null
                        ? Image.asset(
                            widget.schoolData?['image_url'] ?? widget.schoolData?['image'] ?? 'assets/images/schools/generic.png',
                            fit: BoxFit.cover,
                            height: 250,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/schools/generic.png',
                              fit: BoxFit.cover,
                              height: 250,
                              width: double.infinity,
                            ),
                          )
                        : Image.asset(
                            'assets/images/screen2.png',
                            fit: BoxFit.cover,
                            height: 250,
                            width: double.infinity,
                          ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Content Sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          icon: Icons.school_outlined,
                          title: 'About ${widget.schoolName}:',
                          content: widget.schoolData?['description'] ??
                              '${widget.schoolName} aims to provide a balanced educational environment that focuses on academic excellence.',
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          icon: Icons.monetization_on_outlined,
                          title: 'Fees:',
                          content: widget.schoolData?['fees'] ?? 'Contact school for fees',
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          icon: Icons.phone_outlined,
                          title: 'Contact Phone:',
                          content: widget.schoolData?['phone'] ?? 'Contact school for details',
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          icon: Icons.language_outlined,
                          title: 'Website:',
                          content: widget.schoolData?['website'] ?? 'Visit official website',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Apply Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationScreen(
                          schoolId: widget.schoolId,
                          schoolName: widget.schoolName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2E2E), // Dark capsule
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFD3E7DE), // Light greenish teal background
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              );
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ThematicMapScreen()),
              );
            } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SearchCriteriaScreen()),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black87,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_none_outlined),
                ],
              ),
              activeIcon: Stack(
                children: [
                  const Icon(Icons.notifications),
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
              activeIcon: Icon(CupertinoIcons.plus_app_fill),
              label: 'Add',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

