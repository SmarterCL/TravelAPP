import '../models/hotel.dart';

class HotelService {
  static final HotelService _instance = HotelService._internal();
  factory HotelService() => _instance;
  HotelService._internal();

  Future<List<Hotel>> searchHotels(String query) async {
    // Mocking hotel data for reinforcement
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      Hotel(
        id: 'h1',
        name: 'Grand Smarter Plaza',
        location: 'London, UK',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        rating: 4.8,
        pricePerNight: 250.0,
        amenities: ['WiFi', 'Pool', 'Spa', 'Gym'],
        description: 'Experience luxury in the heart of London with panoramic city views.',
      ),
      Hotel(
        id: 'h2',
        name: 'Eco Lodge & Suites',
        location: 'New York, USA',
        imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        rating: 4.5,
        pricePerNight: 180.0,
        amenities: ['Eco-friendly', 'Breakfast', 'WiFi'],
        description: 'A sustainable stay option with modern amenities in Manhattan.',
      ),
      Hotel(
        id: 'h3',
        name: 'Ocean View Resort',
        location: 'Miami, USA',
        imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
        rating: 4.9,
        pricePerNight: 320.0,
        amenities: ['Beach Access', 'Pool', 'Bar'],
        description: 'Stunning beach views with private access to the Atlantic coast.',
      ),
    ];
  }
}
