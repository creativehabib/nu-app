class TrainTrip {
  final String trainName;
  final String departureTime;
  final String arrivalTime;
  final int availableSeats;
  final double fare;
  final String trainNo;

  TrainTrip({
    required this.trainName,
    required this.departureTime,
    required this.arrivalTime,
    required this.availableSeats,
    required this.fare,
    required this.trainNo,
  });

  factory TrainTrip.fromJson(Map<String, dynamic> json) {
    return TrainTrip(
      trainName: json['train_name'] ?? 'N/A',
      departureTime: json['departure_time'] ?? 'N/A',
      arrivalTime: json['arrival_time'] ?? 'N/A',
      availableSeats: json['available_seats'] ?? 0,
      fare: double.parse((json['fare'] ?? 0).toString()),
      trainNo: json['train_no'] ?? '',
    );
  }
}