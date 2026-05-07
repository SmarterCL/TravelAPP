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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Datos del Pasajero', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(),
              const SizedBox(height: 30),
              const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTextField(_firstNameController, 'Nombres (como en el pasaporte)'),
              const SizedBox(height: 15),
              _buildTextField(_lastNameController, 'Apellidos (como en el pasaporte)'),
              const SizedBox(height: 40),
              _buildInfoNote(),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : _handleBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isBooking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('CONFIRMAR RESERVA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Estás reservando un vuelo de ${widget.flight.origin} a ${widget.flight.destination} con ${widget.flight.airline}',
              style: const TextStyle(fontSize: 13, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
      child: const Text(
        'Asegúrate de que los nombres coincidan exactamente con tu identificación oficial para evitar problemas al abordar.',
        style: TextStyle(fontSize: 12, color: Colors.orange),
      ),
    );
  }

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBooking = true);
    try {
      final bookingData = {
        'flightId': widget.flight.flightId,
        'uniqueID': _transactionUniqueId,
        'passengers': [
          {
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'type': 'Adult',
          }
        ],
      };

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
        SnackBar(content: Text('Error en la reserva: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }
}
