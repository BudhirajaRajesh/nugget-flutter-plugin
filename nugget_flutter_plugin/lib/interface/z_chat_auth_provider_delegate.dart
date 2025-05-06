import 'z_chat_auth_user_info.dart';

abstract class ZChatAuthProviderDelegate {
    Future<ZChatAuthUserInfo?> requireAuthInfo();
    Future<ZChatAuthUserInfo?> refreshAuthInfo();
}