import 'package:flutter/material.dart';
import '../models/flight_search_result.dart';
import '../services/airport_service.dart';
import '../utils/formatters.dart';
import 'flight_details_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<FlightSearchResult> flights;
  final Map<String, dynamic> searchCriteria;
  final _airportService = AirportService();

  ResultsScreen({super.key, required this.flights, required this.searchCriteria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Flight')),
      body: flights.isEmpty
          ? const Center(child: Text('No flights found.'))
          : ListView.builder(
              itemCount: flights.length,
              itemBuilder: (context, index) {
                final flight = flights[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
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
                              const Icon(Icons.flight, color: Colors.blue),
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
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
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
                                child: _buildCityCol(flight.origin, flight.departureTime, true),
                              ),
                              const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                              Expanded(
                                child: _buildCityCol(flight.destination, flight.arrivalTime, false),
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCityCol(String code, DateTime time, bool isOrigin) {
    return FutureBuilder<String>(
      future: _airportService.getAirportName(code),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: isOrigin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              code,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              snapshot.data ?? '...',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(Formatters.formatDisplayTime(time), style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        );
      },
    );
  }
}
