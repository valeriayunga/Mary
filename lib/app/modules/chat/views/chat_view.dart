import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mary/app/modules/chat/widgets/loading_indicator.dart';
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
            Flexible(
              child: Obx(
                () => Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        List<Widget> messageWidgets = [
                          ChatMessageWidget(message: message)
                        ];

                        // 1. Detalles de la cita
                        if (message.citaDetails != null &&
                            message.confirmationDetails != null) {
                          messageWidgets.add(
                            AppointmentDetailsCard(
                              citaDetails: message.citaDetails!,
                              confirmationDetails: message.confirmationDetails!,
                            ),
                          );
                        }

                        // 2. Receta médica (medical_recipes)
                        if (message.medicalRecipes != null) {
                          messageWidgets.add(
                            MedicalRecipeCard(
                              medicalRecipe: message.medicalRecipes!,
                            ),
                          );
                        }

                        // 3. Medicamentos (prescription_medications)
                        if (message.prescriptionMedications != null &&
                            message.prescriptionMedications!.isNotEmpty) {
                          messageWidgets.add(
                            MedicationListCard(
                              medications: message.prescriptionMedications!,
                            ),
                          );
                        }

                        return Column(children: messageWidgets);
                      },
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
            Obx(() => OptionsList(options: controller.getLastMessageOptions())),
            const ChatInput(),
          ],
        ),
      ),
    );
  }
}
