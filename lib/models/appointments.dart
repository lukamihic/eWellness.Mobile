class Appointment {
  final String startTime;
  final String endTime;
  final double? price;
  final int clientId;
  final int id;

  Appointment({
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.clientId,
    required this.id,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'] ?? 0,
      clientId: json['clientId'],
      id: json['id'],
    );
  }
}
