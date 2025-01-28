import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mary/app/modules/chat/widgets/loading_indicator.dart';
import 'package:mary/app/modules/chat/widgets/medication_card.dart';
import '../controllers/chat_controller.dart';
import '../widgets/appointment_details_card.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/medication_list_card.dart';
import '../widgets/medical_recipe_card.dart';
import '../widgets/options_list.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildWelcomeCard(),
            Flexible(
              child: Obx(
                () => Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          List<Widget> messageWidgets = [
                            ChatMessageWidget(message: message)
                          ];

                          if (message.citaDetails != null &&
                              message.confirmationDetails != null) {
                            messageWidgets.add(
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: AppointmentDetailsCard(
                                  citaDetails: message.citaDetails!,
                                  confirmationDetails:
                                      message.confirmationDetails!,
                                ),
                              ),
                            );
                          }

                          if (message.medicalRecipes != null) {
                            messageWidgets.add(
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: MedicalRecipeCard(
                                  medicalRecipe: message.medicalRecipes!,
                                ),
                              ),
                            );
                          }

                          if (message.prescriptionMedications != null &&
                              message.prescriptionMedications!.isNotEmpty) {
                            messageWidgets.add(
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: MedicationListCard(
                                  medications: message.prescriptionMedications!,
                                ),
                              ),
                            );
                          }

                          if (message.medicamentos != null &&
                              message.medicamentos!.isNotEmpty) {
                            messageWidgets.add(
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: MedicationCard(
                                  medicamentos: message.medicamentos!,
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(children: messageWidgets),
                          );
                        },
                      ),
                    ),
                    if (controller.isLoading.value)
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ChatLoadingIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Obx(() =>
                      OptionsList(options: controller.getLastMessageOptions())),
                  const ChatInput(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFa076ec),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Mary tu asistente Médico',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFa076ec),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.tips_and_updates,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'La mejor medicina es un sonrias',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
