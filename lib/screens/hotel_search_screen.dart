import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/hotel_service.dart';
import '../models/hotel.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final _hotelService = HotelService();
  final _searchController = TextEditingController();
  List<Hotel> _hotels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    if (mounted) setState(() => _isLoading = true);
    final results = await _hotelService.searchHotels(_searchController.text);
    if (mounted) {
      setState(() {
        _hotels = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            _buildSearchSection(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hotels.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 100),
                          itemCount: _hotels.length,
                          itemBuilder: (context, index) => _PremiumHotelCard(hotel: _hotels[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hospedaje', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text('Encuentra tu Hotel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 25,
            child: Icon(Icons.hotel, color: const Color(0xFF1A237E).withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (_) => _performSearch(),
          decoration: const InputDecoration(
            hintText: 'Ciudad, nombre del hotel...',
            prefixIcon: Icon(Icons.search, color: Color(0xFF1A237E)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.hotel_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 10),
        const Text('No encontramos hoteles disponibles', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _PremiumHotelCard extends StatelessWidget {
  final Hotel hotel;
  const _PremiumHotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: hotel.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, color: Colors.red, size: 20),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${hotel.rating}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(hotel.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    Text('\$${hotel.pricePerNight}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.blue),
                        Text(' ${hotel.location}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Text('por noche', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  children: hotel.amenities.take(3).map((a) => _AmenityTag(text: a)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityTag extends StatelessWidget {
  final String text;
  const _AmenityTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF1A237E), fontWeight: FontWeight.w600)),
    );
  }
}
