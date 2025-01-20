import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mary/app/modules/chat/controllers/chat_controller.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class DoctorCard extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorCard({super.key, required this.doctor});

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  Future<void> _selectDateTime(BuildContext context) async {
    final currentContext = context;

    DateTime? selectedDateTime = await DatePicker.showDateTimePicker(
        currentContext,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime(2101), onChanged: (date) {
      print('change $date in time zone ${date.timeZoneOffset.inHours}');
    }, onConfirm: (date) {
      Get.find<ChatController>().sendDateTime(date);
    }, locale: LocaleType.es);
  }

  @override
  Widget build(BuildContext context) {
    final String fullName =
        "${widget.doctor['first_name'] ?? ''} ${widget.doctor['last_name'] ?? ''}"
            .trim();

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
                if (widget.doctor['specialty'] != null)
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Colors.blue.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.doctor['specialty'],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (widget.doctor['phone'] != null) ...[
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
                        widget.doctor['phone'],
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
}
