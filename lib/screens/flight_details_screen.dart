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
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles del Vuelo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: _isValidating 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Validando tarifa y obteniendo reglas...', textAlign: TextAlign.center),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatusHeader(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFlightInfoCard(),
                        const SizedBox(height: 30),
                        const Text('Reglas de Tarifa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _fareRules?.toString() ?? 'Cargando reglas...',
                            style: TextStyle(color: Colors.grey[700], height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildPriceFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Colors.green[50],
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text('Tarifa verificada y disponible', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFlightInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue),
                const SizedBox(width: 8),
                Text(widget.flight.airline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                Text(widget.flight.airlineCode, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLocationDetail(widget.flight.origin, widget.flight.departureTime, 'Salida'),
                const Icon(Icons.arrow_forward, color: Colors.blue, size: 30),
                _buildLocationDetail(widget.flight.destination, widget.flight.arrivalTime, 'Llegada'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail(String city, DateTime time, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(Formatters.formatDisplayTime(time), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(Formatters.formatDisplayDate(time), style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPriceFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total a pagar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              Formatters.formatCurrency(widget.flight.price, widget.flight.currency),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isValidating ? null : _validateAndProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('CONFIRMAR Y CONTINUAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _validateAndProceed() async {
    setState(() => _isValidating = true);
    
    try {
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
        title: const Text('Precio Actualizado'),
        content: const Text('La tarifa para este vuelo ha cambiado o ya no está disponible. Por favor, realiza una nueva búsqueda.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('REINICIAR BÚSQUEDA'),
          ),
        ],
      ),
    );
  }
}
