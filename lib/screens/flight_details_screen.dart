import 'package:flutter/material.dart';
import '../models/flight_search_result.dart';
import '../services/flight_api_service.dart';
import '../utils/formatters.dart';
import 'booking_screen.dart';

class FlightDetailsScreen extends StatefulWidget {
  final FlightSearchResult flight;

  const FlightDetailsScreen({super.key, required this.flight});

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  final _apiService = FlightApiService();
  bool _isValidating = false;
  dynamic _fareRules;

  @override
  void initState() {
    super.initState();
    _revalidateAndFetchRules();
  }

  Future<void> _revalidateAndFetchRules() async {
    setState(() => _isValidating = true);
    try {
      // Practice #1 & #2: Sequence Search -> Validate Fare -> Fare Rule
      final isValid = await _apiService.validateFare(
        widget.flight.flightId, 
        widget.flight.price
      );

      if (isValid) {
        final rules = await _apiService.getFareRules(widget.flight.flightId);
        if (mounted) {
          setState(() {
            _fareRules = rules;
            _isValidating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isValidating = false);
          _showPriceChangedDialog();
        }
      }
    } catch (e) {
      debugPrint('Sequence error: $e');
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Details')),
      body: _isValidating 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Validating fare and fetching rules...', textAlign: TextAlign.center),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFlightHeader(),
                  const Divider(),
                  _buildPriceSection(),
                  const SizedBox(height: 24),
                  const Text('Fare Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  _fareRules == null 
                      ? const Text('Loading fare rules...') 
                      : Text(_fareRules.toString()), 
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValidating ? null : _validateAndProceed,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: _isValidating 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('CONFIRM & PROCEED TO BOOKING'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFlightHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.flight.airline} - ${widget.flight.airlineCode}', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLocationCol(widget.flight.origin, widget.flight.departureTime),
            const Icon(Icons.flight_takeoff),
            _buildLocationCol(widget.flight.destination, widget.flight.arrivalTime),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationCol(String city, DateTime time) {
    return Column(
      children: [
        Text(city, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(Formatters.formatDisplayTime(time)),
        Text(Formatters.formatDisplayDate(time), style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Fare:', style: TextStyle(fontSize: 18)),
        Text(
          Formatters.formatCurrency(widget.flight.price, widget.flight.currency),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    );
  }

  Future<void> _validateAndProceed() async {
    setState(() => _isValidating = true);
    
    try {
      // Practice #2: Always revalidate before booking
      final isValid = await _apiService.validateFare(
        widget.flight.flightId, 
        widget.flight.price
      );

      if (!mounted) return;
      setState(() => _isValidating = false);

      if (isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingScreen(flight: widget.flight),
          ),
        );
      } else {
        _showPriceChangedDialog();
      }
    } catch (e) {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  void _showPriceChangedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price Changed'),
        content: const Text('The fare for this flight has changed or is no longer available. Please search again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('RESTART SEARCH'),
          ),
        ],
      ),
    );
  }
}
