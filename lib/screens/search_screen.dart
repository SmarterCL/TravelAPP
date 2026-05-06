import 'package:flutter/material.dart';
import '../services/flight_api_service.dart';
import '../utils/formatters.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _originController = TextEditingController(text: 'LHR');
  final _destinationController = TextEditingController(text: 'JFK');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  final _apiService = FlightApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Flights')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _originController,
              decoration: const InputDecoration(labelText: 'From (IATA)'),
            ),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'To (IATA)'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Departure Date'),
              subtitle: Text(Formatters.formatDisplayDate(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSearch,
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('SEARCH FLIGHTS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSearch() async {
    setState(() => _isLoading = true);
    try {
      // Practice #7: Validate mandatory fields
      if (_originController.text.isEmpty || _destinationController.text.isEmpty) {
        throw Exception('Please fill in origin and destination');
      }

      final criteria = {
        'origin': _originController.text.toUpperCase(),
        'destination': _destinationController.text.toUpperCase(),
        'departureDate': Formatters.formatDateApi(_selectedDate),
        'passengers': {'adults': 1, 'children': 0, 'infants': 0},
      };

      final results = await _apiService.searchFlights(criteria);
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(flights: results, searchCriteria: criteria),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
