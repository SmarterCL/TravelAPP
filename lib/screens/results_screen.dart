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
    final allCodes = widget.flights.expand((f) => [f.origin, f.destination]).toSet().toList();
    await _airportService.prefetchAirports(allCodes);
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vuelos Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '${widget.searchCriteria['origin']} ➔ ${widget.searchCriteria['destination']}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : widget.flights.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: widget.flights.length,
                  itemBuilder: (context, index) {
                    final flight = widget.flights[index];
                    return FlightCard(flight: flight);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No se encontraron vuelos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Intenta con otras fechas o destinos', style: TextStyle(color: Colors.grey)),
        ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlightDetailsScreen(flight: flight),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.flight, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.airline,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Vuelo: ${flight.airlineCode}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (flight.isLcc)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: const Text('Bajo Costo', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeCol(flight.origin, airportService.getAirportSync(flight.origin), flight.departureTime, true),
                  Column(
                    children: [
                      const Text('8h 30m', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      const Icon(Icons.flight_takeoff, size: 14, color: Colors.blue),
                    ],
                  ),
                  _buildTimeCol(flight.destination, airportService.getAirportSync(flight.destination), flight.arrivalTime, false),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Precio Total', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    Formatters.formatCurrency(flight.price, flight.currency),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1A237E)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCol(String code, String name, DateTime time, bool isStart) {
    return Column(
      crossAxisAlignment: isStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          Formatters.formatDisplayTime(time),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          code,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
        ),
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            textAlign: isStart ? TextAlign.start : TextAlign.end,
          ),
        ),
      ],
    );
  }
}
