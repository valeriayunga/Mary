import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReprogramAppointmentDialog extends StatefulWidget {
  final int appointmentId;
  final Function(DateTime, TimeOfDay) onReprogram;

  const ReprogramAppointmentDialog(
      {super.key, required this.appointmentId, required this.onReprogram});

  @override
  _ReprogramAppointmentDialogState createState() =>
      _ReprogramAppointmentDialogState();
}

class _ReprogramAppointmentDialogState
    extends State<ReprogramAppointmentDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reprogramar Cita'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              _selectedDate == null
                  ? 'Seleccionar Fecha'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          ListTile(
            title: Text(
              _selectedTime == null
                  ? 'Seleccionar Hora'
                  : _selectedTime!.format(context),
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedDate == null || _selectedTime == null
              ? null
              : () {
                  widget.onReprogram(_selectedDate!, _selectedTime!);
                  Get.back();
                },
          child: const Text('Reprogramar'),
        ),
      ],
    );
  }
}
