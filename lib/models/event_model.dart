class EventModel {
  final int? id;
  final String? name;
  final String? date;
  final String? formattedDate;
  final String? location;
  final String? imageUrl;
  final String? status;
  final String? createdAt;

  EventModel({
    this.id,
    this.name,
    this.date,
    this.formattedDate,
    this.location,
    this.imageUrl,
    this.status,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      date: json['date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      location: json['location']?.toString(),
      imageUrl: json['image_url']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'formatted_date': formattedDate,
      'location': location,
      'image_url': imageUrl,
      'status': status,
      'created_at': createdAt,
    };
  }
}
