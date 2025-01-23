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
  final List<Map<String, dynamic>>? medicamentos;
  final Map<String, dynamic>? medicalRecipes;
  final List<Map<String, dynamic>>? prescriptionMedications;

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
    this.medicamentos = const [],
    this.medicalRecipes,
    this.prescriptionMedications = const [],
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final channel =
      WebSocketChannel.connect(Uri.parse('ws://172.17.180.111:8000/ws/chat'));
  final isListening = false.obs;
  final showOptions = true.obs;

  @override
  void onInit() {
    super.onInit();
    channel.stream.listen(
      (message) {
        print("Mensaje del websocket: $message");
        try {
          final parsedMessage = json.decode(message);
          if (parsedMessage['type'] == 'image') {
            final imageResponse = parsedMessage['message'];
            messages.add(ChatMessage(
              text: imageResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          } else {
            List<Map<String, dynamic>> doctorsList = [];
            if (parsedMessage['medical_options'] != null &&
                parsedMessage['medical_options'].isNotEmpty &&
                parsedMessage['medical_options'][0].containsKey('first_name')) {
              doctorsList = List<Map<String, dynamic>>.from(
                  parsedMessage['medical_options']);
            }

            final chatMessage = ChatMessage(
              text: parsedMessage['message'],
              isUser: false,
              timestamp: DateTime.now(),
              options:
                  parsedMessage['options']?.cast<Map<String, dynamic>>() ?? [],
              medicalOptions: !doctorsList.isNotEmpty
                  ? (parsedMessage['medical_options']
                          ?.cast<Map<String, dynamic>>() ??
                      [])
                  : [],
              specialtyOptions: parsedMessage['specialty_options']
                      ?.cast<Map<String, dynamic>>() ??
                  [],
              doctorOptions: doctorsList,
              historialOptions: parsedMessage['historial_options']
                      ?.cast<Map<String, dynamic>>() ??
                  [],
              citaDetails: parsedMessage['cita_details'],
              confirmationDetails: parsedMessage['confirmation_details'],
              recommendationOptions:
                  parsedMessage['recommendation_options']?.cast<String>() ?? [],
              prescriptionMedications:
                  parsedMessage.containsKey('prescription_medications') &&
                          parsedMessage['prescription_medications'] != null
                      ? parsedMessage['prescription_medications']
                          ?.cast<Map<String, dynamic>>()
                      : [],
              medicalRecipes:
                  parsedMessage['medical_recipes'] is Map<String, dynamic>
                      ? parsedMessage['medical_recipes']
                      : null,
            );

            // Depuración: Verifica los medicamentos recibidos
            print("=== Mensaje parseado ===");
            print("Texto: ${chatMessage.text}");
            print("MedicalRecipes: ${chatMessage.medicalRecipes}");
            print(
                "PrescriptionMedications: ${chatMessage.prescriptionMedications}");
            print("=========================");

            messages.add(chatMessage);
          }
          isLoading.value = false;
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

  void sendImage(String message) {
    isLoading.value = true;
    channel.sink.add(message);
  }

  void sendMessage(String text) {
    final message = json.encode({'text': text});
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    isLoading.value = true;
    channel.sink.add(message);
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
