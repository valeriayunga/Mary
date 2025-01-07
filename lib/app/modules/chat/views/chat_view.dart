import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import '../widgets/appointment_details_card.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/options_list.dart';


class ChatView extends GetView<ChatController> {
  ChatView({super.key});

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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Obx(
                            () => ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final message = controller.messages[index];
                            if (message.citaDetails != null &&
                                message.confirmationDetails != null) {
                              return Column(
                                  children: [
                                    ChatMessageWidget(message: message),
                                    AppointmentDetailsCard(citaDetails: message.citaDetails!, confirmationDetails: message.confirmationDetails!),
                                  ]
                              );
                            }
                            return ChatMessageWidget(message: message);


                          },
                        ),
                      ),
                    ),
                    Obx(() => OptionsList(options: controller.getLastMessageOptions())),

                  ],
                )
            ),
          ),

          ChatInput(),
        ],
      ),
    );
  }
}