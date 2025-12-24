import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/incident_model.dart';
import '../services/database_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;
  String _selectedType = 'Flood'; // Default

  // List of disasters
  final List<String> _disasterTypes = ['Flood', 'Fire', 'Earthquake', 'Landslide', 'Medical Emergency', 'Other'];

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Get Current Location (GPS)
        // NOTE: In a real app, you must handle permission requests here. 
        // We assume permissions are granted for this snippet.
        Position position = await Geolocator.getCurrentPosition(
            // ignore: deprecated_member_use
            desiredAccuracy: LocationAccuracy.high);

        // 2. Get User Info
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // 3. Create Incident Object
        IncidentModel incident = IncidentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "$_selectedType Alert",
          description: _descController.text.trim(),
          userId: user.uid,
          latitude: position.latitude,
          longitude: position.longitude,
          status: 'pending',
          timestamp: DateTime.now(),
        );

        // 4. Save to Database
        await DatabaseService().createIncident(incident);

        if (!mounted) return;
        Navigator.pop(context); // Go back to Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Help Request Sent!"), backgroundColor: Colors.green),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Help")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.emergency_share, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "What is happening?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 1. Disaster Type Dropdown
              DropdownButtonFormField(
                initialValue: _selectedType,
                items: _disasterTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _selectedType = val.toString()),
                decoration: const InputDecoration(
                  labelText: "Type of Emergency",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
              ),
              const SizedBox(height: 15),

              // 2. Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description (Optional)",
                  hintText: "E.g., trapped on roof, 3 people...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 30),

              // 3. Big Red Button
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: _isLoading 
                      ? const SizedBox() 
                      : const Icon(Icons.send, color: Colors.white),
                  label: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SEND HELP REQUEST", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text("Your GPS location will be sent automatically.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}