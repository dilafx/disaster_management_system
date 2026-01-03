import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Get Stream of All Incidents (Real-time updates)
  Stream<List<IncidentModel>> getIncidents() {
    return _db.collection('incidents')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => IncidentModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // 2. Create a new incident
  Future<void> createIncident(IncidentModel incident) async {
    await _db.collection('incidents').doc(incident.id).set(incident.toMap());
  }

  // 3. Update Incident Status (e.g., Admin marks as 'Resolved')
  Future<void> updateStatus(String id, String newStatus) async {
    await _db.collection('incidents').doc(id).update({'status': newStatus});
  }
}