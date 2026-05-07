import 'package:flutter/foundation.dart';

class AirportService {
  static final AirportService _instance = AirportService._internal();
  factory AirportService() => _instance;

  // Practice #10: Optimized Cache
  static final Map<String, String> _airportCache = {
    'LHR': 'London Heathrow',
    'JFK': 'New York JFK',
    'CDG': 'Paris Charles de Gaulle',
    'DXB': 'Dubai International',
    'SIN': 'Singapore Changi',
  };

  AirportService._internal();

  // Optimized: Returns immediate value if cached, otherwise returns code and triggers fetch
  String getAirportSync(String code) {
    return _airportCache[code] ?? code;
  }

  Future<void> prefetchAirports(List<String> codes) async {
    final missingCodes = codes.where((c) => !_airportCache.containsKey(c)).toList();
    if (missingCodes.isEmpty) return;

    // Simulate batch API call
    await Future.delayed(const Duration(milliseconds: 100));
    for (var code in missingCodes) {
      _airportCache[code] = 'Airport $code'; // Placeholder for real API data
    }
  }

  Future<String> getAirportName(String code) async {
    if (_airportCache.containsKey(code)) {
      return _airportCache[code]!;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    _airportCache[code] = 'Airport $code';
    return _airportCache[code]!;
  }
}
