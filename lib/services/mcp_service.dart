import 'package:flutter/foundation.dart';
import 'package:flutter_mcp/flutter_mcp.dart';
import 'flight_api_service.dart';

class McpService {
  final FlightApiService _flightService = FlightApiService();

  Future<void> setupTravelAssistant() async {
    try {
      // Practice #9: Security - Store API key securely
      // Check if already stored to avoid overwriting real keys with dummy one
      final existingKey = await FlutterMCP.instance.secureRead('travelopro_api_key');
      if (existingKey == null || existingKey.isEmpty) {
        await FlutterMCP.instance.secureStore('travelopro_api_key', 'YOUR_SECRET_API_KEY');
      }

      // Register a Tool in MCP so the AI can search for flights
      // Adding error handling here to avoid crashing if server creation fails
      await FlutterMCP.instance.createServer(
        name: 'TravelServer',
        version: '1.0.0',
        capabilities: ServerCapabilities(
          tools: ToolsCapability(),
        ),
        config: MCPServerConfig(
          name: 'TravelServer',
          version: '1.0.0',
        ),
      ).catchError((e) => debugPrint('MCP Server creation error: $e'));

    } catch (e) {
      debugPrint('setupTravelAssistant error: $e');
    }
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
