import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import 'thematic_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600], size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Filter Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton(Icons.favorite_border, 'Favorites'),
                      const SizedBox(width: 10),
                      _buildFilterButton(Icons.history, 'History'),
                      const SizedBox(width: 10),
                      _buildFilterButton(Icons.person_outline, 'Following'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Map Card
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(30.0444, 31.2357), // Cairo
                          initialZoom: 13.0,
                          interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.none, // Static map for home screen feel
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.schoolage',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: const [
                                  LatLng(30.0440, 31.2350),
                                  LatLng(30.0500, 31.2360),
                                  LatLng(30.0600, 31.2330),
                                  LatLng(30.0700, 31.2380),
                                ],
                                color: Colors.blue.shade700,
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              const Marker(
                                point: LatLng(30.0440, 31.2350),
                                width: 30,
                                height: 30,
                                child: Icon(Icons.location_on, color: Colors.green, size: 30),
                              ),
                              const Marker(
                                point: LatLng(30.0700, 31.2380),
                                width: 30,
                                height: 30,
                                child: Icon(Icons.home, color: Colors.blue, size: 30),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Text overlay like in design
                      const Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                "Geziret al",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                "Zamalek",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 80,
                        right: 50,
                        child: Text(
                          "Cairo",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Feed Item - City International School
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'city international school',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '3 min ago',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/city internation national.jpeg',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Post description',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      '109 likes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.chat_bubble_outline, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      '80 comments',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Spacing for bottom nav
              ],
            ),
          ),
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
            // Home toggle: if already home, try to go back
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationsScreen()),
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
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(CupertinoIcons.bell),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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

  Widget _buildFilterButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

