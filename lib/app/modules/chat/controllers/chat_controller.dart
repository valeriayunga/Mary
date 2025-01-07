import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>> options;
  final List<Map<String, dynamic>> medicalOptions;
  final List<Map<String, dynamic>> specialtyOptions;
  final List<Map<String, dynamic>> doctorOptions;
  final List<Map<String, dynamic>> historialOptions;
  final Map<String, dynamic>? citaDetails;
  final Map<String, dynamic>? confirmationDetails;
  final List<String> recommendationOptions;


  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.options = const [],
    this.medicalOptions = const [],
    this.specialtyOptions = const [],
    this.doctorOptions = const [],
    this.historialOptions = const [],
    this.citaDetails,
    this.confirmationDetails,
    this.recommendationOptions = const [],
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/ws/chat'));
  final isListening = false.obs;
  final showOptions = true.obs; // Nueva propiedad para la visibilidad

  @override
  void onInit() {
    super.onInit();
    channel.stream.listen(
          (message) {
        try {
          final parsedMessage = json.decode(message);
          isLoading.value = false;
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
            medicalOptions: !doctorsList.isNotEmpty
                ? (parsedMessage['medical_options']?.cast<Map<String, dynamic>>() ?? [])
                : [],
            specialtyOptions: parsedMessage['specialty_options']?.cast<Map<String, dynamic>>() ?? [],
            doctorOptions: doctorsList,
            historialOptions:
            parsedMessage['historial_options']?.cast<Map<String, dynamic>>() ?? [],
            citaDetails: parsedMessage['cita_details'],
            confirmationDetails: parsedMessage['confirmation_details'],
            recommendationOptions:
            parsedMessage['recommendation_options']?.cast<String>() ?? [],
          );
          messages.add(chatMessage);
        } catch (e) {
          print("Error al parsear mensaje: $e");
          isLoading.value = false;
        }
      },
      onError: (error) {
        print("Error en el websocket: $error");
        isLoading.value = false;
      },
      onDone: () {
        print("Conexión Cerrada");
        isLoading.value = false;
      },
    );
  }

  void sendMessage(String text) {
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    isLoading.value = true;
    channel.sink.add(text);
  }

  void sendDateTime(DateTime dateTime) {
    final formattedDateTime = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    sendMessage(formattedDateTime);
  }

  @override
  void onClose() {
    channel.sink.close();
    super.onClose();
  }

  void sendTranscribedText(String text) {
    if (text.isNotEmpty) {
      sendMessage(text);
    }
  }
  List<Map<String, dynamic>>? getLastMessageOptions() {
    if (messages.isEmpty) return null;
    final lastMessage = messages.last;
    if (lastMessage.doctorOptions.isNotEmpty) {
      return lastMessage.doctorOptions;
    }
    if (lastMessage.medicalOptions.isNotEmpty) {
      return lastMessage.medicalOptions;
    }
    if (lastMessage.specialtyOptions.isNotEmpty) {
      return lastMessage.specialtyOptions;
    }
    if (lastMessage.historialOptions.isNotEmpty) {
      return lastMessage.historialOptions;
    }
    if (lastMessage.recommendationOptions.isNotEmpty) {
      return lastMessage.recommendationOptions
          .map((option) => {'text': option})
          .toList();
    }
    if (lastMessage.options.isNotEmpty) {
      return lastMessage.options;
    }
    return null;
  }
  void toggleOptionsVisibility() {
    showOptions.value = !showOptions.value;
  }
}