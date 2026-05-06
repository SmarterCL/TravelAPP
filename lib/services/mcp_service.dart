import 'package:flutter_mcp/flutter_mcp.dart';
import 'flight_api_service.dart';

class McpService {
  final FlightApiService _flightService = FlightApiService();

  Future<void> setupTravelAssistant() async {
    // Practice #9: Security - Store API key securely
    await FlutterMCP.instance.secureStore('travelopro_api_key', 'YOUR_SECRET_API_KEY');

    // Register a Tool in MCP so the AI can search for flights
    await FlutterMCP.instance.createServer(
      name: 'TravelServer',
      version: '1.0.0',
      capabilities: ServerCapabilities(
        tools: ToolsCapability(),
      ),
      config: MCPServerConfig(
        name: 'TravelServer',
        version: '1.0.0',
        transportType: 'stdio', // Internal communication
      ),
    );

    // Note: In a real app, you would define the 'search_flights' tool 
    // and map it to _flightService.searchFlights
  }

  Future<String> askAssistant(String query) async {
    // Example of using MCP to chat with an AI provider
    // This requires an LLM client to be configured in main.dart
    try {
      final response = await FlutterMCP.instance.chat('default_llm', query);
      return response.text;
    } catch (e) {
      return 'Assistant error: $e';
    }
  }
}
