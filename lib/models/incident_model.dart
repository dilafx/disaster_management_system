class IncidentModel {
  final String id;
  final String title; 
  final String description; 
  final String userId; 
  final double latitude;
  final double longitude;
  final String status; 
  final DateTime timestamp;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.timestamp,
  });

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Firestore
  factory IncidentModel.fromMap(Map<String, dynamic> map, String docId) {
    return IncidentModel(
      id: docId,
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}