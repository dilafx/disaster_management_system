import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/incident_model.dart';
import 'login_screen.dart';
import 'report_screen.dart';

class VictimHomeScreen extends StatelessWidget {
  const VictimHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Relief'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. The "Call to Action" Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.red[50],
            child: Column(
              children: [
                const Text("Are you in danger?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  icon: const Icon(Icons.add_alert, color: Colors.white),
                  label: const Text("REQUEST HELP NOW", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(alignment: Alignment.centerLeft, child: Text("My Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),

          // 2. The List of My Requests
          Expanded(
            child: StreamBuilder<List<IncidentModel>>(
              stream: dbService.getIncidents(), // In a real app, you'd filter by user ID here or in Firestore
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                // Filter locally for now (Simple method)
                final myIncidents = snapshot.data!.where((i) => i.userId == user?.uid).toList();

                if (myIncidents.isEmpty) {
                  return const Center(child: Text("No active requests. Stay safe!"));
                }

                return ListView.builder(
                  itemCount: myIncidents.length,
                  itemBuilder: (context, index) {
                    final incident = myIncidents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: _getStatusIcon(incident.status),
                        title: Text(incident.title),
                        subtitle: Text("Status: ${incident.status.toUpperCase()}"),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    if (status == 'resolved') return const Icon(Icons.check_circle, color: Colors.green);
    if (status == 'verified') return const Icon(Icons.verified, color: Colors.blue);
    return const Icon(Icons.access_time_filled, color: Colors.orange);
  }
}