class EventModel {
  final int? id;
  final String title;
  final String description;
  final String monthYear;
  final String status;
  final String location;
  final String imageUrl;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.monthYear,
    required this.status,
    required this.location,
    required this.imageUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      monthYear: json['month_year'],
      status: json['status'],
      location: json['location'] ?? '-',
      imageUrl: json['image_url'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "month_year": monthYear,
      "status": status,
      "location": location,
      "image_url": imageUrl,
    };
  }
}