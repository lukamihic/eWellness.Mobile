class Offer {
  final String title;
  final String description;

  Offer({required this.title, required this.description});

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      title: json['name'],
      description: json['description'],
    );
  }
}
