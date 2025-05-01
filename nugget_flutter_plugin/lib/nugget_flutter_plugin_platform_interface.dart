import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nugget_flutter_plugin_method_channel.dart';

abstract class NuggetFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a NuggetFlutterPluginPlatform.
  NuggetFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static NuggetFlutterPluginPlatform _instance =
      MethodChannelNuggetFlutterPlugin();

  /// The default instance of [NuggetFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelNuggetFlutterPlugin].
  static NuggetFlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NuggetFlutterPluginPlatform] when
  /// they register themselves.
  static set instance(NuggetFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Opens the chat interface using a specific client token and deeplink.
  ///
  /// Returns a [Future<void>] because platform channel calls are asynchronous.
  /// This allows the caller to `await` the completion of the call and handle
  /// potential [PlatformException]s using `try-catch`.
  Future<void> openChatWithCustomDeeplink({required String clientToken, required String customDeeplink}) {
    throw UnimplementedError('openChatWithCustomDeeplink() has not been implemented');
  }

  /// Initializes the Nugget SDK with necessary configurations.
  ///
  /// Must be called once before using other SDK features.
  /// Requires an [apiKey]. Optional [theme] and [font] data can be provided
  /// for UI customization.
  Future<void> initialize({
    required String apiKey,
    NuggetThemeData? theme,
    NuggetFontData? font,
  }) {
     throw UnimplementedError('initialize() has not been implemented');
  }

  /// Stream providing the latest APNS token as a String.
  Stream<String> get onTokenUpdated {
    throw UnimplementedError('onTokenUpdated has not been implemented.');
  }

  /// Stream providing the latest push notification permission status.
  Stream<NuggetPushPermissionStatus> get onPermissionStatusUpdated {
      throw UnimplementedError('onPermissionStatusUpdated has not been implemented.');
  }

  /// Stream providing the conversation ID when a ticket is successfully created.
  Stream<String> get onTicketCreationSucceeded {
      throw UnimplementedError('onTicketCreationSucceeded has not been implemented.');
  }

  /// Stream providing an optional error message when ticket creation fails.
  Stream<String?> get onTicketCreationFailed {
      throw UnimplementedError('onTicketCreationFailed has not been implemented.');
  }
}

// --- Enums --- 

// Add an enum to represent permission status (mirroring UNAuthorizationStatus)
enum NuggetPushPermissionStatus {
  notDetermined, // Raw value 0
  denied,        // Raw value 1
  authorized,    // Raw value 2
  provisional,   // Raw value 3 (iOS 12+)
  ephemeral      // Raw value 4 (iOS 14+)
}

/// Represents the desired UI style (light/dark/system).
enum NuggetInterfaceStyle {
  /// Use the system's current light/dark mode setting.
  system,
  /// Force light mode.
  light,
  /// Force dark mode.
  dark
}

/// Represents logical font weights used by the Nugget SDK.
enum NuggetFontWeight {
  light,
  regular,
  medium,
  semiBold,
  bold,
  extraBold,
  black
}

/// Represents relative font sizes used by the Nugget SDK.
enum NuggetFontSize {
  font050,
  font100,
  font200,
  font300,
  font400,
  font500,
  font600,
  font700,
  font800,
  font900
}

// --- Helper Data Classes --- 

/// Represents theme customization data for the Nugget SDK UI.
class NuggetThemeData {
  /// Optional custom color palette hex string (e.g., "#RRGGBB").
  final String? paletteHexString;
  /// Optional custom tint color hex string (e.g., "#RRGGBB").
  final String? tintColorHex; // Renamed from primaryColorHex
  /// Desired interface style (light/dark/system). Defaults to system.
  final NuggetInterfaceStyle interfaceStyle;

  NuggetThemeData({
    this.paletteHexString,
    this.tintColorHex,
    this.interfaceStyle = NuggetInterfaceStyle.system,
  });

  /// Converts this object to a Map suitable for platform channel transmission.
  Map<String, dynamic> toJson() => {
    // Only include non-null values
    if (paletteHexString != null) 'paletteHexString': paletteHexString,
    if (tintColorHex != null) 'tintColorHex': tintColorHex,
    // Convert enum to its string name (e.g., 'system', 'light', 'dark')
    'interfaceStyle': interfaceStyle.name,
  }..removeWhere((key, value) => value == null); // Clean way to create map and remove nulls
}

/// Represents font customization data for the Nugget SDK UI.
class NuggetFontData {
  /// The primary font name (e.g., "Helvetica Neue").
  final String fontName;
  /// The font family name (might be the same as fontName or different).
  final String fontFamily;
  /// Maps logical weights to specific font name suffixes or PostScript names
  /// (e.g., { NuggetFontWeight.bold: 'Bold', NuggetFontWeight.regular: 'Regular' }).
  final Map<NuggetFontWeight, String> fontWeightMapping;
  /// Maps relative sizes to specific integer point sizes
  /// (e.g., { NuggetFontSize.font100: 12, NuggetFontSize.font400: 16 }).
  final Map<NuggetFontSize, int> fontSizeMapping;

  NuggetFontData({
    required this.fontName,
    required this.fontFamily,
    required this.fontWeightMapping,
    required this.fontSizeMapping,
  });

  /// Converts this object to a Map suitable for platform channel transmission.
  Map<String, dynamic> toJson() => {
    'fontName': fontName,
    'fontFamily': fontFamily,
    // Convert enum keys to strings for JSON compatibility
    'fontWeightMapping': fontWeightMapping.map(
        (key, value) => MapEntry(key.name, value) // key.name gives 'light', 'bold' etc.
    ),
    'fontSizeMapping': fontSizeMapping.map(
        (key, value) => MapEntry(key.name, value) // key.name gives 'font050', 'font100' etc.
    ),
  };
}
