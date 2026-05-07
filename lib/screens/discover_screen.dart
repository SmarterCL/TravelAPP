import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/destination.dart';
import 'destination_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<String> _categories = ['Todo', 'Playa', 'Montaña', 'Ciudad', 'Aventura'];
  int _activeCategory = 0;

  static final List<Destination> popularDestinations = [
    Destination(
      name: 'París',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
      location: 'Francia',
      description: 'La Ciudad de la Luz te espera con su icónica Torre Eiffel, museos de clase mundial y calles llenas de romance y cultura.',
      startingPrice: 450,
    ),
    Destination(
      name: 'Maldivas',
      imageUrl: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800',
      location: 'Maldivas',
      description: 'Un paraíso tropical con playas de arena blanca, aguas cristalinas y resorts de lujo sobre el agua.',
      startingPrice: 1200,
    ),
    Destination(
      name: 'Tokio',
      imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
      location: 'Japón',
      description: 'Una mezcla perfecta de tradición y tecnología. Templos antiguos conviven con rascacielos futuristas.',
      startingPrice: 890,
    ),
    Destination(
      name: 'Santorini',
      imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
      location: 'Grecia',
      description: 'Famosa por sus edificios blancos con cúpulas azules y atardeceres espectaculares sobre el mar Egeo.',
      startingPrice: 650,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategories(),
              _buildSectionTitle('Destinos Destacados'),
              _buildHorizontalDestinations(),
              _buildSectionTitle('Recomendados para ti'),
              _buildVerticalDestinations(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, Viajero 👋', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const SizedBox(height: 5),
              const Text('Explora el Mundo', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Color(0xFF1A237E)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: '¿A dónde quieres ir?',
            prefixIcon: Icon(Icons.search, color: Color(0xFF1A237E)),
            suffixIcon: Icon(Icons.tune, color: Color(0xFF1A237E)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isActive = _activeCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1A237E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[600],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E3E5C))),
          TextButton(onPressed: () {}, child: const Text('Ver todo', style: TextStyle(color: Color(0xFF1A237E)))),
        ],
      ),
    );
  }

  Widget _buildHorizontalDestinations() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: popularDestinations.length,
        itemBuilder: (context, index) {
          final dest = popularDestinations[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DestinationDetailScreen(destination: dest))),
            child: Container(
              width: 200,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(dest.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dest.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                            Text(dest.location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalDestinations() {
    return Column(
      children: popularDestinations.map((dest) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(imageUrl: dest.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dest.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(dest.location, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Column(
              children: [
                Text('\$${dest.startingPrice}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                const Text('/pers', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }
}
