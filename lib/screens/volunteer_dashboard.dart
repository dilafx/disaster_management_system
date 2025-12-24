import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/incident_model.dart';
import 'login_screen.dart';
import 'incident_details_screen.dart'; // <--- 1. IMPORT ADDED HERE

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Missions'),
        backgroundColor: Colors.blue[800],
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
      body: StreamBuilder<List<IncidentModel>>(
        stream: dbService.getIncidents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final allIncidents = snapshot.data ?? [];
          
          // Filter: Volunteers usually only see "Verified" or "Pending" requests
          final activeIncidents = allIncidents.where((i) => i.status != 'resolved').toList();

          if (activeIncidents.isEmpty) {
            return const Center(child: Text("No active missions available. Good job!"));
          }

          return ListView.builder(
            itemCount: activeIncidents.length,
            itemBuilder: (context, index) {
              final incident = activeIncidents[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      // --- 2. ON TAP ADDED HERE ---
                      // This opens the details screen when you click the row
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => IncidentDetailsScreen(incident: incident)
                          )
                        );
                      },
                      // ----------------------------
                      
                      leading: Icon(Icons.health_and_safety, size: 40, color: Colors.blue[800]),
                      title: Text(incident.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(incident.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Chip(
                        label: Text(incident.status.toUpperCase()),
                        backgroundColor: _getStatusColor(incident.status),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                    
                    // The "Action" Bar
                    OverflowBar(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.directions_run),
                          label: const Text("I'M GOING"),
                          onPressed: () {
                            dbService.updateStatus(incident.id, 'verified');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mission Accepted! Stay Safe.")),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text("RESOLVED", style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            dbService.updateStatus(incident.id, 'resolved');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'verified') return Colors.blue;
    if (status == 'pending') return Colors.orange;
    return Colors.grey;
  }
}