import 'dart:async';

import 'package:flutter/material.dart';
// Import the main plugin file, which now exports the handler
import 'package:nugget_flutter_plugin/nugget_flutter_plugin.dart';

void main() {
  // Ensure bindings are initialized before calling plugin code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the handler for native -> Dart calls
  NuggetPluginNativeCallbackHandler.initializeHandler();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = NuggetFlutterPlugin();
  final _apiKeyController = TextEditingController(text: "YOUR_API_KEY"); // TODO: Replace with your key
  final _deeplinkController = TextEditingController(text: "optional_deeplink_path");

  bool _isInitialized = false;
  String _status = 'SDK Not Initialized';
  final List<String> _callbackMessages = [];
  StreamSubscription? _ticketSuccessSubscription;
  StreamSubscription? _ticketFailureSubscription;
  // TODO: Add subscriptions for auth and other streams if needed

  @override
  void initState() {
    super.initState();
    _listenToCallbacks();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _deeplinkController.dispose();
    _ticketSuccessSubscription?.cancel();
    _ticketFailureSubscription?.cancel();
    // TODO: Cancel other subscriptions
    super.dispose();
  }

  void _listenToCallbacks() {
    _ticketSuccessSubscription = _plugin.onTicketCreationSucceeded.listen((id) {
      if (mounted) {
        setState(() {
          _callbackMessages.add('Ticket Success: ID=$id');
        });
      }
    });

    _ticketFailureSubscription = _plugin.onTicketCreationFailed.listen((error) {
      if (mounted) {
        setState(() {
          _callbackMessages.add('Ticket Failed: ${error ?? "Unknown error"}');
        });
      }
    });

    // TODO: Listen to auth streams (onTokenUpdated, onPermissionStatusUpdated)
    // You'll likely need to implement the actual auth logic in the 
    // NuggetPluginNativeCallbackHandler when those methods are invoked
  }

  Future<void> _initializeSdk() async {
    if (_apiKeyController.text.isEmpty || _apiKeyController.text == "YOUR_API_KEY") {
        setState(() {
          _status = 'Please enter a valid API Key';
        });
        return;
    }
    setState(() {
      _status = 'Initializing...';
      _callbackMessages.clear(); // Clear previous messages
    });
    try {
      // Example Theme/Font data (replace with actual data if needed)
      final theme = NuggetThemeData(
        tintColorHex: "#FF0000", // Example: Red tint
        interfaceStyle: NuggetInterfaceStyle.light,
      );
      // final font = NuggetFontData(...); // Define if needed

      await _plugin.initialize(
        apiKey: _apiKeyController.text,
        theme: theme,
        // font: font,
      );
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _status = 'SDK Initialized Successfully';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _status = 'SDK Initialization Failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nugget Plugin Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your Nugget API Key',
                ),
                enabled: !_isInitialized, // Disable after init
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isInitialized ? null : _initializeSdk,
                child: const Text('Initialize SDK'),
              ),
              const SizedBox(height: 10),
              Text('Status: $_status'),
              const SizedBox(height: 10),
              const Text('Callbacks:'),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey[200],
                  child: ListView.builder(
                     itemCount: _callbackMessages.length,
                     itemBuilder: (context, index) => Text(_callbackMessages[index]),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Native Chat View:'),
              // Conditionally display the Native View
              if (_isInitialized)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)
                    ),
                    // Example with deeplink
                    // child: NuggetChatView(initialDeeplink: "some/path/here"),
                    // Example without deeplink
                    child: const NuggetChatView(), 
                  ),
                )
              else
                const Expanded(
                  flex: 2,
                  child: Center(child: Text('Initialize SDK to show Chat View')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
