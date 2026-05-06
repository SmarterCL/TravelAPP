import 'package:flutter/material.dart';
import 'package:flutter_mcp/flutter_mcp.dart';
import 'screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Practice #9: Security Best Practices - Initialize MCP for secure storage and AI capabilities
    await FlutterMCP.instance.init(
      MCPConfig(
        appName: 'SmarterTravel',
        appVersion: '1.0.0',
        useBackgroundService: true,
        useNotification: true,
        autoStart: true,
        // You can configure LLM providers here if needed
        autoStartLlmClient: [],
      ),
    );
  } catch (e) {
    debugPrint('FlutterMCP initialization failed: $e');
    // Continue starting the app even if MCP fails, or show an error screen
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmarterTravel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}
