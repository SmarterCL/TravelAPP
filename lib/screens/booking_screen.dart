import 'package:flutter/material.dart';
import '../models/flight_search_result.dart';
import '../services/flight_api_service.dart';
import 'confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final FlightSearchResult flight;

  const BookingScreen({super.key, required this.flight});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _apiService = FlightApiService();
  bool _isBooking = false;
  
  // Practice #3: Unique ID per transaction attempt to ensure idempotency
  late final String _transactionUniqueId;

  @override
  void initState() {
    super.initState();
    _transactionUniqueId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Practice #7: Ensure passenger names match government ID
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name (as per Passport)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name (as per Passport)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : _handleBooking,
                  child: _isBooking 
                      ? const CircularProgressIndicator() 
                      : const Text('CONFIRM BOOKING'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBooking = true);
    try {
      final bookingData = {
        'flightId': widget.flight.flightId,
        'uniqueID': _transactionUniqueId, // Practice #3
        'passengers': [

          {
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'type': 'Adult',
          }
        ],
      };

      // Practice #3: Idempotency handled in service via uniqueID
      // Practice #5: ptrUniqueID returned from service
      final ptrUniqueID = await _apiService.bookFlight(bookingData);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            ptrUniqueID: ptrUniqueID,
            isLcc: widget.flight.isLcc,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }
}
