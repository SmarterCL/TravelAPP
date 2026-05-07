import 'package:flutter/material.dart';
import '../services/flight_api_service.dart';

class ConfirmationScreen extends StatefulWidget {
  final String ptrUniqueID;
  final bool isLcc;

  const ConfirmationScreen({super.key, required this.ptrUniqueID, required this.isLcc});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final _apiService = FlightApiService();
  Map<String, dynamic>? _tripDetails;
  bool _isLoading = true;
  String _statusMessage = 'Finalizando tu reserva...';

  @override
  void initState() {
    super.initState();
    _processOrder();
  }

  Future<void> _processOrder() async {
    try {
      if (!widget.isLcc) {
        setState(() => _statusMessage = 'Emitiendo boleto...');
        await _apiService.orderTicket(widget.ptrUniqueID);
      }

      setState(() => _statusMessage = 'Obteniendo detalles del viaje...');
      final details = await _apiService.getTripDetails(widget.ptrUniqueID);
      
      if (!mounted) return;
      setState(() {
        _tripDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Confirmación de Reserva', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_statusMessage, style: const TextStyle(color: Colors.grey)),
                ],
              )
            : _buildDetails(),
      ),
    );
  }

  Widget _buildDetails() {
    if (_tripDetails == null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('No se pudieron cargar los detalles. Status: $_statusMessage', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('VOLVER')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 20),
          const Text('¡Reserva Confirmada!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Tu viaje ha sido procesado con éxito', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildInfoRow('PNR:', _tripDetails!['pnr'] ?? 'N/A'),
                const Divider(height: 30),
                _buildInfoRow('Nro. Boleto:', _tripDetails!['ticketNumber'] ?? 'N/A'),
                const Divider(height: 30),
                _buildInfoRow('Estado:', _tripDetails!['status'] ?? 'Confirmado'),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('VOLVER AL INICIO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E))),
      ],
    );
  }
}
