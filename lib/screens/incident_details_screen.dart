import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- 1. Import this
import '../models/incident_model.dart';
import '../services/database_service.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final IncidentModel incident;

  const IncidentDetailsScreen({super.key, required this.incident});

  // --- 2. Function to Open External Map ---
  Future<void> _openMap() async {
    // This URL format works for both Android and iOS to open the default maps app
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${incident.latitude},${incident.longitude}");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: Could not launch
      debugPrint("Could not open maps.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incident Details"),
        backgroundColor: _getStatusColor(incident.status),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 3. UPDATED: Clickable Map Header ---
            InkWell(
              onTap: _openMap, 
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: const DecorationImage(
                    
                    image: AssetImage('assets/map_placeholder.png'), 
                    fit: BoxFit.cover,
                    opacity: 0.2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 60, color: Colors.red[900]),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [const BoxShadow(blurRadius: 5, color: Colors.black26)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("OPEN IN GOOGLE MAPS", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Icon(Icons.open_in_new, size: 16, color: Colors.red[900]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Reported: ${incident.timestamp.toString().substring(0, 16)}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Divider(height: 30),

                  const Text("Situation Report:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    incident.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      const Text("Current Status: ", style: TextStyle(fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(incident.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getStatusColor(incident.status)),
                        ),
                        child: Text(
                          incident.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(incident.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  dbService.updateStatus(incident.id, 'verified');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked as Verified")));
                },
                child: const Text("VERIFY"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  dbService.updateStatus(incident.id, 'resolved');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked as Resolved")));
                },
                child: const Text("RESOLVE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'resolved') return Colors.green;
    if (status == 'verified') return Colors.blue;
    return Colors.red;
  }
}