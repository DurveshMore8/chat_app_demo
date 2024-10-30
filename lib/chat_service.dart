import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  void connect(email) {
    socket = IO.io('http://192.168.45.79:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'email': email},
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to server');
    });

    socket.onDisconnect((_) => print('Disconnected'));
  }

  void sendMessage(Map<String, dynamic> data) {
    socket.emit('send_message', data);
  }

  void listenForMessages(Function onMessageReceived) {
    socket.on('receive_message', (data) {
      onMessageReceived(data);
    });
  }
}
