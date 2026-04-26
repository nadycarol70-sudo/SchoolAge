import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<String> _regions = [
    'alexandria', 'asyut', 'beheira', 'beni_suef', 'cairo', 'dakahlia',
    'faiyum', 'gharbia', 'giza', 'minya', 'monufia', 'qalyubia',
    'qena', 'sharqia', 'sohag'
  ];

  /// Reads local JSON files and uploads/updates them in Firestore.
  static Future<void> seedDataIfNeeded() async {
    try {
      print('Starting data migration/update to Firestore...');

      for (String region in _regions) {
        try {
          final String response = await rootBundle.loadString('assets/data/schools/$region.json');
          final List<dynamic> data = json.decode(response);

          WriteBatch batch = _db.batch();
          for (var item in data) {
            final Map<String, dynamic> school = item as Map<String, dynamic>;
            final String schoolName = school['name'] ?? 'unknown';
            // Create a deterministic ID from the name
            final String docId = schoolName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
            
            DocumentReference docRef = _db.collection('schools').doc(docId);
            batch.set(docRef, {
              ...school,
              'updatedAt': FieldValue.serverTimestamp(),
              'rating': school['rating'] ?? 4.5,
              'fees': school['fees'] ?? '$region Fees (Contact School)',
              'image_url': school['image_url'] ?? school['image'] ?? 'assets/images/schools/generic.png',
              'description': school['description'] ?? 'A leading educational institution in $region providing quality education and holistic development.',
              'phone': school['phone'] ?? '+20 (Contact School)',
              'website': school['website'] ?? 'www.school-website.edu.eg',
            }, SetOptions(merge: true));
          }
          await batch.commit();
          print('Successfully updated $region.json');
        } catch (e) {
          print('Error migrating $region: $e');
        }
      }

      print('Data migration complete!');
    } catch (e) {
      print('Seeding error: $e');
      throw Exception('Seeding error: $e');
    }
  }
}
