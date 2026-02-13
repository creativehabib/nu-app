import 'package:flutter/material.dart';
import '../services/railway_service.dart';
import '../models/train_trip.dart';

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  final RailwayService _service = RailwayService();
  bool _isLoading = false;
  List<TrainTrip> _trips = [];

  // ডিফল্ট ভ্যালু (এগুলো পরে ডাইনামিক করতে পারেন)
  String fromCity = "Dhaka";
  String toCity = "Cox's Bazar";
  String doj = "23-Feb-2026";

  void _getTrainData() async {
    setState(() => _isLoading = true);
    final results = await _service.searchTrips(fromCity, toCity, doj, "S_CHAIR");
    setState(() {
      _trips = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ট্রেনের সময় ও সিট'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _getTrainData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("সার্চ করুন (Dhaka - Cox's Bazar)"),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.train, color: Colors.indigo),
                    title: Text(trip.trainName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("ছাড়ার সময়: ${trip.departureTime}\nভাড়া: ${trip.fare} টাকা"),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "সিট: ${trip.availableSeats}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}