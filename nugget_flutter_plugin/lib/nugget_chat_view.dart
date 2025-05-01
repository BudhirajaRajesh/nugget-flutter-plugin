import 'dart:io';

// import 'package:flutter/foundation.dart'; // Removed unused import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Flutter widget that displays the native Nugget SDK chat view.
///
/// This widget uses Platform Views (UiKitView on iOS) to embed the native UI.
/// Ensure the Nugget SDK has been initialized via `NuggetFlutterPlugin().initialize()`
/// before attempting to display this widget.
class NuggetChatView extends StatefulWidget {
  /// Creates a widget that displays the native Nugget chat view.
  const NuggetChatView({super.key});

  @override
  State<NuggetChatView> createState() => _NuggetChatViewState();
}

class _NuggetChatViewState extends State<NuggetChatView> {
  // Unique identifier for the platform view type. Must match the string
  // registered in the native iOS code (AppDelegate.swift or similar).
  final String viewType = 'com.yourcompany.nugget/chat_view'; // Use a unique name

  // Pass creation parameters if needed by the native view factory.
  // For now, assume none are needed, but this map can be populated.
  final Map<String, dynamic> creationParams = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    // Platform Views are only available on specific platforms.
    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr, // Adjust as needed
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(), // Standard codec
        // Optional: Gesture recognizers can be configured here if needed
        // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        //   Factory<OneSequenceGestureRecognizer>(
        //     () => EagerGestureRecognizer(),
        //   ),
        // },
      );
    } else if (Platform.isAndroid) {
       // Optionally implement AndroidView or return a placeholder
       return const Center(
         child: Text('NuggetChatView: Android not yet implemented.'),
       );
    } else {
       return Center(
         child: Text('NuggetChatView: Unsupported platform (${Platform.operatingSystem})'),
       );
    }
  }
} 