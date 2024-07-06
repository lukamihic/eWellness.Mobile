class Services {
  final String title;
  final double price;
  final int duration;
  final int id;

  Services(
      {required this.title,
      required this.price,
      required this.duration,
      required this.id});

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
        title: json['name'],
        price: json['price'],
        duration: json['duration'],
        id: json['id']);
  }
}
