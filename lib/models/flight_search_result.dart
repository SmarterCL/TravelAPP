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
      flightId: json['flightId'],
      airline: json['airline'],
      airlineCode: json['airlineCode'],
      origin: json['origin'],
      destination: json['destination'],
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      isLcc: json['isLcc'] ?? false,
    );
  }
}
