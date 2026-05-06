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
  String _statusMessage = 'Finalizing your booking...';

  @override
  void initState() {
    super.initState();
    _processOrder();
  }

  Future<void> _processOrder() async {
    try {
      // Practice #6: Different fare types (LCC vs Non-LCC)
      if (!widget.isLcc) {
        setState(() => _statusMessage = 'Issuing Ticket...');
        // Practice #1: Order Ticket for Non-LCC
        await _apiService.orderTicket(widget.ptrUniqueID);
      }

      setState(() => _statusMessage = 'Fetching Trip Details...');
      // Practice #11: Post-Booking Validation (Call Trip Details)
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

  void _showRefundDialog() async {
    // Practice #12: Always call Quote APIs before execution
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Request Refund Quote?'),
        content: const Text('This will check the cancellation charges before executing the refund.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('BACK')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _handleRefundFlow();
            },
            child: const Text('GET QUOTE'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefundFlow() async {
    setState(() => _isLoading = true);
    try {
      final quote = await _apiService.getRefundQuote(widget.ptrUniqueID);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Refund Quote Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow('Refundable Amount:', quote['refundableAmount']?.toString() ?? '0.00'),
              _buildRow('Cancellation Fees:', quote['charges']?.toString() ?? '0.00'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await _executeRefund(quote['quoteId']);
              },
              child: const Text('CONFIRM REFUND'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _executeRefund(String quoteId) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.executeRefund(widget.ptrUniqueID, quoteId);
      // Practice #12: Use PTR Status to track final status
      final updatedDetails = await _apiService.getTripDetails(widget.ptrUniqueID);
      if (!mounted) return;
      setState(() {
        _tripDetails = updatedDetails;
        _isLoading = false;
        _statusMessage = 'Refund Processed';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refund Execution Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        automaticallyImplyLeading: false, // Prevent going back to booking form
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              )
            : _buildDetails(),
      ),
    );
  }

  Widget _buildDetails() {
    if (_tripDetails == null) {
      return Text('Failed to load trip details. Status: $_statusMessage');
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildRow('PNR:', _tripDetails!['pnr'] ?? 'N/A'),
                  _buildRow('Ticket No:', _tripDetails!['ticketNumber'] ?? 'N/A'),
                  _buildRow('Status:', _tripDetails!['status'] ?? 'Confirmed'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _showRefundDialog,
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text('Cancel / Refund Booking', style: TextStyle(color: Colors.red)),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('BACK TO HOME'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
