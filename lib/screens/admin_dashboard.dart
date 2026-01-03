import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/incident_model.dart';
import 'login_screen.dart';
import 'incident_details_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Command Center'),
          backgroundColor: Colors.red[900],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [Tab(icon: Icon(Icons.list), text: "Live Feed")],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                AuthService().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<List<IncidentModel>>(
          stream: _dbService.getIncidents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final incidents = snapshot.data ?? [];

            return TabBarView(
              children: [
                // Only List View remains
                _buildListView(incidents),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<IncidentModel> incidents) {
    if (incidents.isEmpty) {
      return const Center(child: Text("All Clear! No incidents reported."));
    }

    return ListView.builder(
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 3,
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IncidentDetailsScreen(incident: incident),
                ),
              );
            },
            // --------------------------------------
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(incident.status),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
            ),
            title: Text(
              incident.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Status: ${incident.status.toUpperCase()}",
              style: TextStyle(
                color: _getStatusColor(incident.status),
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'resolved') return Colors.green;
    if (status == 'verified') return Colors.blue;
    return Colors.red;
  }
}
