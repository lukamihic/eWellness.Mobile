class Tip {
  final String title;
  final String description;

  Tip({required this.title, required this.description});

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      title: json['name'],
      description: json['description'],
    );
  }
}
