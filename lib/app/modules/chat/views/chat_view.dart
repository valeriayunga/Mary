import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class ChatView extends GetView<ChatController> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Variables para la animación del micrófono
  final RxDouble _micScale = 1.0.obs;
  Timer? _animationTimer;
  String _tempWords = ''; // Variable temporal para acumular palabras

  ChatView({super.key});

  void _handleSubmitted(String text) {
    controller.sendMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  void _startListening() async {
    if (!controller.isListening.value) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Estado: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        controller.isListening.value = true;
        _startMicAnimation();
        _tempWords = ''; // Limpiar las palabras temporales al iniciar la grabación
        _speech.listen(
          onResult: (result) {
            _tempWords = result.recognizedWords;
            _textController.text = _tempWords;
            print('Resultado: ${result.recognizedWords}, Final: ${result.finalResult}');
          },
        );
      } else {
        print("El reconocimiento de voz no está disponible.");
      }
    } else {
      controller.isListening.value = false;
      _stopListening();
    }
  }

  void _stopListening() async {
    _stopMicAnimation();
    await _speech.stop();
    if (_tempWords.isNotEmpty) {
      controller.sendTranscribedText(_tempWords);
    }
  }

  void _startMicAnimation() {
    _micScale.value = 1.0;
    _animationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (controller.isListening.value) {
        _micScale.value = (_micScale.value == 1.0) ? 1.2 : 1.0;
      } else {
        _stopMicAnimation();
      }
    });
  }

  void _stopMicAnimation() {
    _micScale.value = 1.0;
    _animationTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Laboratorios'),
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessage(message);
                },
              )),
            ),
            Obx(() => _buildOptionsSection(context)),
            _buildInputSection(),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => controller.isListening.value
              ? _buildRecordingIndicator()
              : Container()),
          Row(
            children: [
              Obx(() => IconButton(
                icon: Icon(controller.isListening.value ? Icons.mic_off : Icons.mic),
                onPressed: _startListening,
                color: controller.isListening.value ? Colors.red : Colors.blue,
              )),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                    textInputAction: TextInputAction.send,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
                () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(_micScale.value),
              child: const Icon(
                Icons.mic,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Grabando...',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Column(
      crossAxisAlignment:
      message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!message.isUser) _buildAssistantHeader(message),
        Container(
          margin: EdgeInsets.only(
            left: message.isUser ? 64 : 0,
            right: message.isUser ? 0 : 64,
            bottom: 16,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssistantHeader(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Mary ${DateFormat('hh:mm a').format(message.timestamp)}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    final lastMessage =
    controller.messages.isNotEmpty ? controller.messages.last : null;
    if (lastMessage == null) return Container();

    if (lastMessage.doctorOptions.isNotEmpty) {
      return _buildOptionsContainer(
        context: context,
        title: 'Doctores Disponibles',
        icon: Icons.person,
        color: Colors.indigo,
        options: lastMessage.doctorOptions,
        optionBuilder: _buildDoctorCard,
      );
    } else if (lastMessage.medicalOptions.isNotEmpty) {
      return _buildOptionsContainer(
        context: context,
        title: 'Centros Médicos',
        icon: Icons.local_hospital,
        color: Colors.blue,
        options: lastMessage.medicalOptions,
        optionBuilder: _buildMedicalOptionCard,
      );
    } else if (lastMessage.specialtyOptions.isNotEmpty) {
      return _buildOptionsContainer(
        context: context,
        title: 'Especialidades',
        icon: Icons.medical_services,
        color: Colors.green,
        options: lastMessage.specialtyOptions,
        optionBuilder: _buildSpecialtyOptionCard,
      );
    } else if (lastMessage.options.isNotEmpty) {
      return _buildOptionsContainer(
        context: context,
        title: 'Opciones',
        icon: Icons.list_alt,
        color: Colors.purple,
        options: lastMessage.options,
        optionBuilder: _buildGenericOptionCard,
      );
    }
    return Container();
  }

  Widget _buildOptionsContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> options,
    required Widget Function(BuildContext, Map<String, dynamic>) optionBuilder,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => optionBuilder(context, options[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericOptionCard(BuildContext context, Map<String, dynamic> option) {
    return _buildOptionButton(
      option['text'],
      icon: _getGenericOptionIcon(option['text']),
    );
  }

  IconData _getGenericOptionIcon(String optionText) {
    switch (optionText) {
      case 'Agendar una cita médica':
        return Icons.calendar_today;
      case 'Consultar mi historial médico':
        return Icons.history;
      case 'Recetas Médicas':
        return Icons.receipt_long;
      case 'Laboratorios':
        return Icons.science;
      default:
        return Icons.arrow_forward_ios;
    }
  }

  Widget _buildMedicalOptionCard(BuildContext context, Map<String, dynamic> medicalOption) {
    return _buildOptionButton(
      '${medicalOption['name']} - ${medicalOption['address']}',
      icon: Icons.local_hospital,
      id: medicalOption['id'].toString(),
    );
  }

  Widget _buildSpecialtyOptionCard(BuildContext context, Map<String, dynamic> specialtyOption) {
    return _buildOptionButton(
      specialtyOption['specialty'],
      icon: Icons.medical_services,
    );
  }

  Widget _buildOptionButton(String text, {IconData? icon, String? id}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[300]!, Colors.purple[400]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.sendMessage(id ?? text),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    final String fullName = "${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}".trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            controller.sendMessage(fullName);
            if (controller.isLoading.value) {
              await _selectDateTime(context);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Obx(() => controller.isLoading.value
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    )
                        : Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.blue,
                        size: 18,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                if (doctor['specialty'] != null)
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Colors.blue.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        doctor['specialty'],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (doctor['phone'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.blue.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        doctor['phone'],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        controller.sendDateTime(selectedDateTime);
      }
    }
  }
}