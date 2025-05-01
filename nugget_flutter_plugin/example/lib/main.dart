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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: const Text('Plugin example app body'),
        ),
      ),
    );
  }
}
