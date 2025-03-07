class Appointment {
  final String startTime;
  final String endTime;
  final String? serviceName;
  final double? price;
  final int clientId;
  final int id;

  Appointment({
    required this.startTime,
    required this.endTime,
    required this.serviceName,
    required this.price,
    required this.clientId,
    required this.id,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      startTime: json['startTime'],
      endTime: json['endTime'],
      serviceName: json['service']['name'] ?? json['id'],
      price: json['price'] ?? json['totalPrice'] ?? 0,
      clientId: json['clientId'],
      id: json['id'],
    );
  }
}
