import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'success_screen.dart';
import 'search_criteria_screen.dart';

class ThematicMapScreen extends StatefulWidget {
  const ThematicMapScreen({super.key});

  @override
  State<ThematicMapScreen> createState() => _ThematicMapScreenState();
}

class _ThematicMapScreenState extends State<ThematicMapScreen> {
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _schools = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    try {
      // Load the index of governorate files
      final String indexContent = await rootBundle.loadString('assets/data/schools/index.json');
      final List<dynamic> fileList = json.decode(indexContent);
      
      List<Map<String, dynamic>> allSchools = [];
      
      for (String fileName in fileList) {
        final String schoolContent = await rootBundle.loadString('assets/data/schools/$fileName');
        final List<dynamic> schoolData = json.decode(schoolContent);
        allSchools.addAll(List<Map<String, dynamic>>.from(schoolData));
      }

      setState(() {
        _schools = allSchools;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading school data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NotificationsScreen()),
      );
    } else if (index == 2) {
      // Map - Already here
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SearchCriteriaScreen()),
      );
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _resetRotation() {
    _mapController.rotate(0);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'american':
        return Colors.redAccent;
      case 'ig':
      case 'british':
        return Colors.blueAccent;
      case 'international':
        return Colors.purpleAccent;
      case 'national':
        return const Color(0xFF14B886); // Emerald green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Schools Map', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(30.0444, 31.2357), // Center on Cairo
              initialZoom: 10.0, // Zoom in closer to Cairo
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(21.5, 24.0),
                  const LatLng(32.0, 37.0),
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.schoolage',
              ),
              MarkerLayer(
                markers: _schools.map((school) {
                  final color = _getCategoryColor(school['category'] ?? '');
                  return Marker(
                    point: LatLng(school['lat'], school['lng']),
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(school['name']),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category: ${school['category']}'),
                                Text('Governorate: ${school['governorate']}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              )
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.school,
                        color: color,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Scalebar(
                alignment: Alignment.bottomLeft,
                textStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // North Arrow
          Positioned(
            top: 16,
            right: 16,
            child: StreamBuilder<MapEvent>(
              stream: _mapController.mapEventStream,
              builder: (context, snapshot) {
                final rotation = _mapController.camera.rotation;
                return GestureDetector(
                  onTap: _resetRotation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: rotation * (3.14159 / 180),
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xFF14B886),
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Zoom Controls
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              children: [
                _buildControlButton(
                  icon: Icons.add,
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 12),
                _buildControlButton(
                  icon: Icons.remove,
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),
          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('American', Colors.redAccent),
                  _buildLegendItem('IG/British', Colors.blueAccent),
                  _buildLegendItem('International', Colors.purpleAccent),
                  _buildLegendItem('National', const Color(0xFF14B886)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFD6EBE8),
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 3,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_outlined),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 24,
        ),
      ),
    );
  }
}

