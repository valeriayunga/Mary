import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mary/app/modules/chat/controllers/chat_controller.dart';
import 'package:mary/app/modules/chat/widgets/option_doctor_card.dart';
import 'package:mary/app/modules/chat/widgets/specialist_card.dart';
import 'medical_option_card.dart';
import 'options_container.dart';
import 'option_card.dart';

class OptionsList extends StatefulWidget {
  final List<Map<String, dynamic>>? options;
  const OptionsList({super.key, required this.options});

  @override
  // ignore: library_private_types_in_public_api
  _OptionsListState createState() => _OptionsListState();
}

class _OptionsListState extends State<OptionsList> {
  bool _isExpanded = true;
  late ChatController controller;
  @override
  void initState() {
    controller = Get.find<ChatController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.showOptions.value ? _buildOptions(context) : Container(),
    );
  }

  Widget _buildOptions(BuildContext context) {
    if (widget.options == null || widget.options!.isEmpty) return Container();
    final lastMessage = controller.messages.last;
    Widget getOptionWidget() {
      if (lastMessage.doctorOptions.isNotEmpty) {
        return OptionsContainer(
            onToggleExpanded: _toggleExpanded,
            isExpanded: _isExpanded,
            context: context,
            title: 'Doctores Disponibles',
            icon: Icons.person,
            color: Colors.indigo,
            options: lastMessage.doctorOptions,
            optionBuilder: _buildDoctorCard);
      } else if (lastMessage.medicalOptions.isNotEmpty) {
        return OptionsContainer(
          onToggleExpanded: _toggleExpanded,
          isExpanded: _isExpanded,
          context: context,
          title: 'Centros Médicos',
          icon: Icons.local_hospital,
          color: Colors.blue,
          options: lastMessage.medicalOptions,
          optionBuilder: _buildMedicalOptionCard,
        );
      } else if (lastMessage.specialtyOptions.isNotEmpty) {
        return OptionsContainer(
            onToggleExpanded: _toggleExpanded,
            isExpanded: _isExpanded,
            context: context,
            title: 'Especialidades',
            icon: Icons.medical_services,
            color: Colors.green,
            options: lastMessage.specialtyOptions,
            optionBuilder: _buildSpecialtyOptionCard);
      } else if (lastMessage.historialOptions.isNotEmpty) {
        return OptionsContainer(
            onToggleExpanded: _toggleExpanded,
            isExpanded: _isExpanded,
            context: context,
            title: 'Opciones de Historial',
            icon: Icons.assignment,
            color: Colors.orange,
            options: lastMessage.historialOptions,
            optionBuilder: _buildHistorialOptionCard);
      } else if (lastMessage.recommendationOptions.isNotEmpty) {
        return OptionsContainer(
            onToggleExpanded: _toggleExpanded,
            isExpanded: _isExpanded,
            context: context,
            title: 'Recomendaciones',
            icon: Icons.lightbulb_outline,
            color: Colors.teal,
            options: lastMessage.recommendationOptions
                .map((option) => {'text': option})
                .toList(),
            optionBuilder: _buildRecommendationOptionCard);
      } else if (lastMessage.options.isNotEmpty) {
        return OptionsContainer(
          onToggleExpanded: _toggleExpanded,
          isExpanded: _isExpanded,
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

    return SingleChildScrollView(child: getOptionWidget());
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget _buildGenericOptionCard(
      BuildContext context, Map<String, dynamic> option) {
    return OptionCard(
        text: option['text'], icon: _getGenericOptionIcon(option['text']));
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
    return OptionCard(
        text: recommendationOption['text'], icon: Icons.help_outline);
  }

  Widget _buildMedicalOptionCard(
      BuildContext context, Map<String, dynamic> medicalOption) {
    return MedicalOptionCard(
      medicalOption: medicalOption,
    );
  }

  Widget _buildHistorialOptionCard(
      BuildContext context, Map<String, dynamic> historialOption) {
    return OptionCard(
        text: historialOption['text'],
        icon: _getHistorialOptionIcon(historialOption['text']));
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
    return SpecialtyCard(specialtyOption: specialtyOption);
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    return DoctorCard(doctor: doctor);
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
