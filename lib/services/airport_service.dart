import 'package:dio/dio.dart';

class AirportService {
  static final AirportService _instance = AirportService._internal();
  factory AirportService() => _instance;

  final Dio _dio = Dio();
  
  // Practice #10: Cache static data to avoid unnecessary repeated API calls
  static final Map<String, String> _airportCache = {};

  AirportService._internal();

  Future<String> getAirportName(String code) async {
    if (_airportCache.containsKey(code)) {
      return _airportCache[code]!;
    }

    try {
      // In a real app, this would call a static data API
      // final response = await _dio.get('https://api.travelopro.com/v1/static/airports/$code');
      // final name = response.data['name'];
      
      // Mocking for now
      final name = code == 'LHR' ? 'London Heathrow' : 'New York JFK';
      _airportCache[code] = name;
      return name;
    } catch (e) {
      return code;
    }
  }
}
