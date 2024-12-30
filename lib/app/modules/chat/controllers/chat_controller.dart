// En `chat_controller.dart`

import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>> options;
  final List<Map<String, dynamic>> medicalOptions;
  final List<Map<String, dynamic>> specialtyOptions;
  final List<Map<String, dynamic>> doctorOptions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.options = const [],
    this.medicalOptions = const [],
    this.specialtyOptions = const [],
    this.doctorOptions = const [],
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/ws/chat'));

  @override
  void onInit() {
    super.onInit();
    channel.stream.listen(
          (message) {
        try {
          final parsedMessage = json.decode(message);

          List<Map<String, dynamic>> doctorsList = [];
          if (parsedMessage['medical_options'] != null &&
              parsedMessage['medical_options'].isNotEmpty &&
              parsedMessage['medical_options'][0].containsKey('first_name')) {
            doctorsList = List<Map<String, dynamic>>.from(parsedMessage['medical_options']);
          }

          final chatMessage = ChatMessage(
            text: parsedMessage['message'],
            isUser: false,
            timestamp: DateTime.now(),
            options: parsedMessage['options']?.cast<Map<String, dynamic>>() ?? [],
            medicalOptions: !doctorsList.isNotEmpty ?
            (parsedMessage['medical_options']?.cast<Map<String, dynamic>>() ?? []) : [],
            specialtyOptions: parsedMessage['specialty_options']?.cast<Map<String, dynamic>>() ?? [],
            doctorOptions: doctorsList,
          );
          messages.add(chatMessage);
        } catch (e) {
          print("Error al parsear mensaje: $e");
        }
      },
      onError: (error) => print("Error en el websocket: $error"),
      onDone: () => print("Conexión Cerrada"),
    );
  }

  void sendMessage(String text) {
    messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now()
    ));
    channel.sink.add(text);
  }

  @override
  void onClose() {
    channel.sink.close();
    super.onClose();
  }
}