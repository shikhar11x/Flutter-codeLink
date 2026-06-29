import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';

class SocketService {
  SocketService._();

  static IO.Socket? _socket;

  static IO.Socket get socket {
    _socket ??= IO.io(
      AppConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    return _socket!;
  }

  static void connect() {
    if (!socket.connected) socket.connect();
  }

  static void disconnect() {
    socket.disconnect();
  }

  static void joinPad(String slug, String userName, String color) {
    socket.emit('join_pad', {
      'slug': slug,
      'userName': userName,
      'color': color,
    });
  }

  static void sendCodeChange(String slug, String content) {
    socket.emit('code_change', {'slug': slug, 'content': content});
  }

  static void sendCursorMove(String slug, int line, int column) {
    socket.emit('cursor_move', {'slug': slug, 'line': line, 'column': column});
  }

  static void sendLanguageChange(String slug, String language) {
    socket.emit('language_change', {'slug': slug, 'language': language});
  }

  static void onCodeUpdate(Function(String) callback) {
    socket.on('code_update', (data) => callback(data['content']));
  }

  static void onUsersUpdate(Function(List) callback) {
    socket.on('users_update', (data) => callback(data));
  }

  static void onPadInit(Function(Map) callback) {
    socket.on('pad_init', (data) => callback(data));
  }

  static void onLanguageUpdate(Function(String) callback) {
    socket.on('language_update', (data) => callback(data['language']));
  }

  static void offAll() {
    socket.off('code_update');
    socket.off('users_update');
    socket.off('pad_init');
    socket.off('language_update');
  }
}