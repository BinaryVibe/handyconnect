class Worker {
  String name;
  String category;
  double rating;
  String description;
  String experience;
  String tools;
  String pricing;
  String image;
  List<DateTime> availableDates;

  Worker({
    required this.name,
    required this.category,
    required this.rating,
    required this.description,
    required this.experience,
    required this.tools,
    required this.pricing,
    required this.image,
    required this.availableDates,
  });
}
