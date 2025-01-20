// En `chat_input.dart`
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../controllers/chat_controller.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ImagePicker _picker = ImagePicker();

  // Variables para la animación del micrófono
  final RxDouble _micScale = 1.0.obs;
  Timer? _animationTimer;
  String _tempWords = ''; // Variable temporal para acumular palabras

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    Get.find<ChatController>().sendMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  void _startListening() async {
    final controller = Get.find<ChatController>();
    if (!controller.isListening.value) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Estado: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        controller.isListening.value = true;
        _startMicAnimation();
        _tempWords =
            ''; // Limpiar las palabras temporales al iniciar la grabación
        _speech.listen(
          onResult: (result) {
            _tempWords = result.recognizedWords;
            _textController.text = _tempWords;
            print(
                'Resultado: ${result.recognizedWords}, Final: ${result.finalResult}');
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
      Get.find<ChatController>().sendTranscribedText(_tempWords);
    }
  }

  void _startMicAnimation() {
    _micScale.value = 1.0;
    _animationTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (Get.find<ChatController>().isListening.value) {
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

  Future<Map<String, dynamic>?> _uploadImage(File image) async {
    final url = Uri.parse('http://192.168.1.13:8000/img');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(
            'image', image.path.split('.').last) // Obtener el tipo de la imagen
        ));
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print("Respuesta de la subida: $jsonResponse");
        return jsonResponse;
      } else {
        print('Error al subir la imagen: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  Future<void> _sendImageDataToBackend(
      String imageUrl, String contentType) async {
    final message = json.encode({
      'type': 'image',
      'image_url': imageUrl,
      'content_type': contentType,
    });
    print('Mensaje de imagen: $message');
    Get.find<ChatController>().sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
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
          Obx(() => Get.find<ChatController>().isListening.value
              ? _buildRecordingIndicator()
              : Container()),
          Row(
            children: [
              Obx(() => IconButton(
                    icon: Icon(Get.find<ChatController>().isListening.value
                        ? Icons.mic_off
                        : Icons.mic),
                    onPressed: _startListening,
                    color: Get.find<ChatController>().isListening.value
                        ? Colors.red
                        : const Color(0xFFa076ec),
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
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () async {
                  final XFile? image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final response = await _uploadImage(File(image.path));
                    print('Respuesta de la subida: $response');
                    if (response != null) {
                      await _sendImageDataToBackend(
                          response['image_url'],
                          MediaType('image', image.path.split('.').last)
                              .toString());
                    }
                  }
                },
                color: const Color(0xFFa076ec),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFa076ec),
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
}
