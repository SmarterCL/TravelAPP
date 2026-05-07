import 'package:flutter/material.dart';
import '../models/flight_search_result.dart';
import '../services/airport_service.dart';
import '../utils/formatters.dart';
import 'flight_details_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<FlightSearchResult> flights;
  final Map<String, dynamic> searchCriteria;

  const ResultsScreen({super.key, required this.flights, required this.searchCriteria});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _airportService = AirportService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Optimization: Prefetch all airport names in one go to avoid FutureBuilder in the list
    final allCodes = widget.flights.expand((f) => [f.origin, f.destination]).toSet().toList();
    await _airportService.prefetchAirports(allCodes);
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Flight')),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : widget.flights.isEmpty
              ? const Center(child: Text('No flights found.'))
              : ListView.builder(
                  // Optimization: use fixedExtent if possible, or at least ensure efficient builds
                  itemCount: widget.flights.length,
                  itemBuilder: (context, index) {
                    final flight = widget.flights[index];
                    return FlightCard(flight: flight);
                  },
                ),
    );
  }
}

class FlightCard extends StatelessWidget {
  final FlightSearchResult flight;
  const FlightCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    final airportService = AirportService();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlightDetailsScreen(flight: flight),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.flight, color: Color(0xFF1A237E)),
                  const SizedBox(width: 8),
                  Text(
                    '${flight.airline} (${flight.airlineCode})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (flight.isLcc)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: const Text('LCC', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildCityCol(
                      flight.origin,
                      airportService.getAirportSync(flight.origin),
                      flight.departureTime,
                      true
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                  Expanded(
                    child: _buildCityCol(
                      flight.destination,
                      airportService.getAirportSync(flight.destination),
                      flight.arrivalTime,
                      false
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Price', style: TextStyle(color: Colors.grey)),
                  Text(
                    Formatters.formatCurrency(flight.price, flight.currency),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1A237E)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCol(String code, String name, DateTime time, bool isOrigin) {
    return Column(
      crossAxisAlignment: isOrigin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          code,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(Formatters.formatDisplayTime(time), style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
