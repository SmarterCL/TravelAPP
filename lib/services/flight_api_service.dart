import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_mcp/flutter_mcp.dart';
import '../models/flight_search_result.dart';

class FlightApiService {
  static final FlightApiService _instance = FlightApiService._internal();
  factory FlightApiService() => _instance;

  late Dio _dio;
  final _uuid = const Uuid();

  FlightApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.travelopro.com/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Practice #8: Log request and response metadata for debugging (avoiding sensitive payloads in production)
    if (kDebugMode) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('RESPONSE[${response.statusCode}]');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('ERROR[${e.response?.statusCode}] => MESSAGE: ${e.message}');
          return handler.next(e);
        },
      ));
    }

    // Practice #4: Manage Timeouts & Retries with exponential backoff
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      logPrint: kDebugMode ? debugPrint : null,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ],
    ));

    // Practice #9: Auth Interceptor using MCP secure storage
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final apiKey = await FlutterMCP.instance.secureRead('travelopro_api_key');
        if (apiKey != null) {
          options.headers['Authorization'] = 'Bearer $apiKey';
        }
        return handler.next(options);
      },
    ));
  }

  // 1. Search API
  Future<List<FlightSearchResult>> searchFlights(Map<String, dynamic> searchCriteria) async {
    try {
      final response = await _dio.post('/flight/search', data: searchCriteria);
      
      // Return list of flights
      return (response.data['flights'] as List)
          .map((f) => FlightSearchResult.fromJson(f))
          .toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 2. Validate Fare API (Practice #1, #2)
  Future<bool> validateFare(String flightId, double expectedPrice) async {
    try {
      final response = await _dio.post('/flight/validate', data: {
        'flightId': flightId,
        'price': expectedPrice,
      });
      
      final bool isValid = response.data['isValid'] ?? false;
      final double newPrice = (response.data['currentPrice'] ?? expectedPrice).toDouble();

      if (!isValid || newPrice != expectedPrice) {
        debugPrint('Price changed! Old: $expectedPrice, New: $newPrice');
        return false; // Suggest restarting flow or updating price
      }
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // 3. Fare Rule API
  Future<dynamic> getFareRules(String flightId) async {
    final response = await _dio.get('/flight/farerules/$flightId');
    return response.data;
  }

  // 4. Book API (Practice #3: Idempotency)
  Future<String> bookFlight(Map<String, dynamic> bookingData) async {
    try {
      // Practice #3: Ensure uniqueID is present (passed from UI)
      if (!bookingData.containsKey('uniqueID')) {
        bookingData['uniqueID'] = _uuid.v4();
      }

      final response = await _dio.post('/flight/book', data: bookingData);
      
      if (response.data['status'] == 'Success') {
        return response.data['ptrUniqueID']; // Practice #5: Use PTR for tracking
      } else {
        throw Exception('Booking failed: ${response.data['message']}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 5. Order Ticket API [Non LCC]
  Future<Map<String, dynamic>> orderTicket(String ptrUniqueID) async {
    try {
      final response = await _dio.post('/flight/orderTicket', data: {
        'ptrUniqueID': ptrUniqueID,
      });
      return response.data;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 6. Trip Details API (Practice #11: Post-Booking Validation)
  Future<Map<String, dynamic>> getTripDetails(String ptrUniqueID) async {
    final response = await _dio.get('/flight/tripDetails/$ptrUniqueID');
    return response.data;
  }

  // 7. Refund/Void Quote API (Practice #12)
  Future<Map<String, dynamic>> getRefundQuote(String ptrUniqueID) async {
    try {
      final response = await _dio.post('/flight/refundQuote', data: {
        'ptrUniqueID': ptrUniqueID,
      });
      return response.data; // Should return charges and refundable amount
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 8. Execute Refund/Void API (Practice #12)
  Future<Map<String, dynamic>> executeRefund(String ptrUniqueID, String quoteId) async {
    try {
      final response = await _dio.post('/flight/executeRefund', data: {
        'ptrUniqueID': ptrUniqueID,
        'quoteId': quoteId,
      });
      return response.data;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dynamic e) {
    if (kDebugMode) {
      if (e is DioException) {
        debugPrint('API Error: ${e.response?.data ?? e.message}');
      } else {
        debugPrint('Unexpected Error: $e');
      }
    }
  }
}
