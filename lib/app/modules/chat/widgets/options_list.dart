import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class OptionsList extends StatefulWidget {
  final List<Map<String, dynamic>>? options;
  OptionsList({super.key, required this.options});

  @override
  _OptionsListState createState() => _OptionsListState();
}

class _OptionsListState extends State<OptionsList> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    return Obx(
          () => controller.showOptions.value
          ? _buildOptions(context)
          : Container(),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final controller = Get.find<ChatController>();
    if (widget.options == null || widget.options!.isEmpty) return Container();

    final lastMessage = controller.messages.last;

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
    } else if (lastMessage.historialOptions.isNotEmpty) {
      return _buildOptionsContainer(
        context: context,
        title: 'Opciones de Historial',
        icon: Icons.assignment,
        color: Colors.orange,
        options: lastMessage.historialOptions,
        optionBuilder: _buildHistorialOptionCard,
      );
    }  else if (lastMessage.recommendationOptions.isNotEmpty) {
      return _buildOptionsContainer(
        context: context,
        title: 'Recomendaciones',
        icon: Icons.lightbulb_outline,
        color: Colors.teal,
        options: lastMessage.recommendationOptions.map((option) => {'text': option}).toList(),
        optionBuilder: _buildRecommendationOptionCard,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                    ]
                ),
                IconButton(onPressed: _toggleExpanded,
                  icon: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
          if(_isExpanded) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  optionBuilder(context, options[index]),
            ),
          ]
        ],
      ),
    );
  }
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
  Widget _buildGenericOptionCard(
      BuildContext context, Map<String, dynamic> option) {
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
      case 'Descargar historial':
        return Icons.download;
      case 'Obtener resumen':
        return Icons.summarize;
      case 'Hacer una pregunta':
        return Icons.question_answer;
      case 'Laboratorios':
        return Icons.science;
      default:
        return Icons.arrow_forward_ios;
    }
  }
  Widget _buildRecommendationOptionCard(
      BuildContext context, Map<String, dynamic> recommendationOption) {
    return _buildOptionButton(
      recommendationOption['text'],
      icon: Icons.help_outline,
    );
  }

  Widget _buildMedicalOptionCard(
      BuildContext context, Map<String, dynamic> medicalOption) {
    return _buildOptionButton(
      '${medicalOption['name']} - ${medicalOption['address']}',
      icon: Icons.local_hospital,
      id: medicalOption['id'].toString(),
    );
  }

  Widget _buildHistorialOptionCard(
      BuildContext context, Map<String, dynamic> historialOption) {
    return _buildOptionButton(
      historialOption['text'],
      icon: _getHistorialOptionIcon(historialOption['text']),
    );
  }

  IconData _getHistorialOptionIcon(String optionText) {
    switch (optionText) {
      case 'Descargar historial':
        return Icons.download;
      case 'Obtener resumen':
        return Icons.summarize;
      case 'Hacer una pregunta':
        return Icons.question_mark;
      default:
        return Icons.arrow_forward_ios;
    }
  }

  Widget _buildSpecialtyOptionCard(
      BuildContext context, Map<String, dynamic> specialtyOption) {
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
          onTap: () => Get.find<ChatController>().sendMessage(id ?? text),
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
    final String fullName =
    "${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}".trim();

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
            Get.find<ChatController>().sendMessage(fullName);
            if (Get.find<ChatController>().isLoading.value) {
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
                    Obx(() => Get.find<ChatController>().isLoading.value
                        ? const CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue),
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
        Get.find<ChatController>().sendDateTime(selectedDateTime);
      }
    }
  }
}