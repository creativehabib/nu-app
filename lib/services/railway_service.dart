import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/train_trip.dart';

class RailwayService {
  Future<List<TrainTrip>> searchTrips(String from, String to, String date, String seatClass) async {
    final url = Uri.parse(
        "https://railspaapi.shohoz.com/v1.0/web/bookings/search-trips-v2?from_city=$from&to_city=$to&date_of_journey=$date&seat_class=$seatClass");

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List tripsJson = data['data']['trips'] ?? [];
        return tripsJson.map((json) => TrainTrip.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching train data: $e");
    }
    return [];
  }
}