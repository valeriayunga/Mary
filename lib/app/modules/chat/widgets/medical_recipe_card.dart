import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class MedicalRecipeCard extends StatelessWidget {
  final Map<String, dynamic>? medicalRecipe;

  const MedicalRecipeCard({super.key, required this.medicalRecipe});

  @override
  Widget build(BuildContext context) {
    if (medicalRecipe == null) return Container();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Futura Consulta",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () {
                    // Aquí puedes agregar funcionalidad adicional
                  },
                  color: Colors.blue,
                ),
              ],
            ),
            const Divider(),
            if (medicalRecipe!.containsKey("appoimnet") &&
                medicalRecipe!["appoimnet"] != null &&
                medicalRecipe!["appoimnet"] is Map)
              _buildAppointmentDetails(
                  medicalRecipe!["appoimnet"] as Map<String, dynamic>),
            const SizedBox(height: 16),
            _buildAgendarButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails(Map<String, dynamic> appoiment) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  "Detalles de la proxima Consulta",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.person,
              'Doctor:',
              appoiment['doctor'] ?? "",
              Colors.indigo,
            ),
            if (appoiment['fecha'] != null)
              _buildDetailRow(
                Icons.calendar_today,
                'Fecha:',
                appoiment['fecha'] ?? "",
                Colors.green,
              ),
            if (appoiment['lugar'] != null)
              _buildDetailRow(
                Icons.location_on,
                'Lugar:',
                appoiment['lugar'] ?? "",
                Colors.orange,
              ),
            if (appoiment['hora'] != null)
              _buildDetailRow(
                Icons.schedule,
                'Hora:',
                appoiment['hora'] ?? "",
                Colors.purple,
              ),
            if (appoiment['informacion_adicional'] != null)
              _buildDetailRow(
                Icons.info,
                'Notas:',
                appoiment['informacion_adicional'] ?? "",
                Colors.teal,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendarButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        onPressed: () =>
            Get.find<ChatController>().sendMessage('Agendar una cita médica'),
        icon: const Icon(Icons.calendar_month_outlined),
        label: const Text('Agendar Cita'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
