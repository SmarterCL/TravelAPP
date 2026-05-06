class FlightSearchResult {
  final String flightId;
  final String airline;
  final String airlineCode;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final String currency;
  final bool isLcc;

  FlightSearchResult({
    required this.flightId,
    required this.airline,
    required this.airlineCode,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.currency,
    required this.isLcc,
  });

  factory FlightSearchResult.fromJson(Map<String, dynamic> json) {
    return FlightSearchResult(
      flightId: json['flightId']?.toString() ?? '',
      airline: json['airline']?.toString() ?? 'Unknown Airline',
      airlineCode: json['airlineCode']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      departureTime: json['departureTime'] != null
          ? DateTime.tryParse(json['departureTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      arrivalTime: json['arrivalTime'] != null
          ? DateTime.tryParse(json['arrivalTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      isLcc: json['isLcc'] == true,
    );
  }
}
