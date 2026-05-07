class Hotel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final double pricePerNight;
  final List<String> amenities;
  final String description;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.pricePerNight,
    required this.amenities,
    required this.description,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Hotel',
      location: json['location']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? 'https://via.placeholder.com/400x200?text=No+Image',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      amenities: List<String>.from(json['amenities'] ?? []),
      description: json['description']?.toString() ?? '',
    );
  }
}
