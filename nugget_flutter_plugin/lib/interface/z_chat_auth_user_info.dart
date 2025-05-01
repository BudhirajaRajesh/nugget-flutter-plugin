import 'z_chat_auth_info.dart';
import 'z_chat_user_info.dart';

abstract class ZChatAuthUserInfo implements ZChatAuthInfo, ZChatUserInfo {
    Map<String, dynamic> toJson();
}

// Concrete implementation of the combined auth/user info interface
class ZChatAuthUserInfoImpl implements ZChatAuthUserInfo {
    
    // Define the fields required by the implemented interfaces
    @override
    final int clientID;
    @override
    final String accessToken;
    @override
    final String userID;
    @override
    final String userName;
    @override
    final String photoURL;
    @override
    final String displayName; // Added missing field from ZChatUserInfo

    ZChatAuthUserInfoImpl({
        required this.clientID,
        required this.accessToken,
        required this.userID,
        required this.userName,
        required this.photoURL,
        required this.displayName, // Added missing parameter
    });
    
    // Factory constructor to parse from a Map (e.g., from platform channel)
    // Added type checks for safety
    factory ZChatAuthUserInfoImpl.fromJson(Map<String, dynamic> json) {
        return ZChatAuthUserInfoImpl(
            clientID: json['clientID'] as int? ?? 0, // Example: provide default or throw
            accessToken: json['accessToken'] as String? ?? '',
            userID: json['userID'] as String? ?? '',
            userName: json['userName'] as String? ?? '',
            photoURL: json['photoURL'] as String? ?? '',
            displayName: json['displayName'] as String? ?? '', // Added parsing
        );
    }

    // Implementation for toJson required by the abstract class
    @override
    Map<String, dynamic> toJson() {
        return {
            'clientID': clientID,
            'accessToken': accessToken,
            'userID': userID,
            'userName': userName,
            'photoURL': photoURL,
            'displayName': displayName,
        };
    }

    // Getters are implicitly provided by final fields, no need for separate implementations
    // like `@override int get clientID => _clientID;` etc.
}
