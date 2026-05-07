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
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildForm(),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reserva tu', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
          const Text('Próximo Vuelo', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _buildLocationInput(
            controller: _originController,
            label: 'Desde',
            hint: 'Código IATA (ej. MAD)',
            icon: Icons.flight_takeoff,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _buildLocationInput(
            controller: _destinationController,
            label: 'Hacia',
            hint: 'Código IATA (ej. MEX)',
            icon: Icons.flight_land,
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF1A237E)),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fecha de Salida', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(Formatters.formatDisplayDate(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('BUSCAR VUELOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput({required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: InputBorder.none,
              labelStyle: const TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Búsquedas Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildHistoryItem('MAD', 'CDG', '22 May'),
          _buildHistoryItem('LHR', 'JFK', '15 Jun'),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String from, String to, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(from, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              Text(to, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _handleSearch() async {
    setState(() => _isLoading = true);
    try {
      if (_originController.text.isEmpty || _destinationController.text.isEmpty) {
        throw Exception('Por favor, ingresa origen y destino');
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
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
