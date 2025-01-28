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

const kPrimaryColor = Color(0xFFa076ec);

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
  final RxDouble _micScale = 1.0.obs;
  Timer? _animationTimer;
  String _tempWords = '';

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => Get.find<ChatController>().isListening.value
              ? _buildRecordingIndicator()
              : const SizedBox.shrink()),
          Row(
            children: [
              _buildVoiceButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onSubmitted: _handleSubmitted,
                          textInputAction: TextInputAction.send,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      _buildImageButton(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Get.find<ChatController>().isListening.value
              ? Colors.red.withOpacity(0.1)
              : kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: IconButton(
          icon: Icon(
            Get.find<ChatController>().isListening.value
                ? Icons.mic_off
                : Icons.mic,
            color: Get.find<ChatController>().isListening.value
                ? Colors.red
                : kPrimaryColor,
            size: 24,
          ),
          onPressed: _startListening,
        ),
      ),
    );
  }

  Widget _buildImageButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: Icon(
          Icons.image,
          color: kPrimaryColor,
          size: 22,
        ),
        onPressed: () async {
          final XFile? image =
              await _picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            final response = await _uploadImage(File(image.path));
            if (response != null) {
              await _sendImageDataToBackend(
                response['image_url'],
                MediaType('image', image.path.split('.').last).toString(),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white, size: 22),
        onPressed: () => _handleSubmitted(_textController.text),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            'Grabando...',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // Los métodos restantes permanecen igual
  void _handleSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      Get.find<ChatController>().sendMessage(text);
      _textController.clear();
      _focusNode.requestFocus();
    }
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
        _tempWords = '';
        _speech.listen(
          onResult: (result) {
            _tempWords = result.recognizedWords;
            _textController.text = _tempWords;
          },
        );
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
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', image.path.split('.').last),
    ));
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      }
      return null;
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
    Get.find<ChatController>().sendMessage(message);
  }
}
