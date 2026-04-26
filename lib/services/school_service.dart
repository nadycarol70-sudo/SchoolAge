import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:convert';

class SchoolService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all schools stream
  Stream<List<Map<String, dynamic>>> getSchoolsStream() {
    return _db.collection('schools').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Get schools by governorate
  Future<List<Map<String, dynamic>>> getSchoolsByGovernorate(String governorate) async {
    QuerySnapshot snapshot = await _db
        .collection('schools')
        .where('governorate', isEqualTo: governorate)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  // Upload file
  Future<String> uploadFile(Uint8List fileBytes, String fileName, String folder) async {
    try {
      _storage.setMaxUploadRetryTime(const Duration(seconds: 4));
      final ref = _storage.ref().child('$folder/$fileName');
      final uploadTask = await ref.putData(fileBytes);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'retry-limit-exceeded') {
        // Fallback: If Web CORS blocks the upload, convert the image to a Base64 string 
        // and store it directly in Firestore instead of Firebase Storage.
        final base64String = base64Encode(fileBytes);
        return 'data:image/png;base64,$base64String';
      }
      throw Exception('Failed to upload file: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Submit application
  Future<void> submitApplication({
    required String userId,
    required String schoolId,
    required Map<String, dynamic> studentInfo,
  }) async {
    await _db.collection('applications').add({
      'userId': userId,
      'schoolId': schoolId,
      'studentInfo': studentInfo,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
