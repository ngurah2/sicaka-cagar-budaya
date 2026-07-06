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
      // Penambahan .toString() memastikan data selalu terbaca sebagai String 
      // dan menghindari Type Error saat data dari Vercel tidak sesuai tipe
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      monthYear: (json['month_year'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      location: (json['location'] ?? '-').toString(),
      imageUrl: (json['image_url'] ?? '-').toString(),
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