import 'package:flutter/material.dart';

class AppointmentDetailsCard extends StatelessWidget {
  final Map<String, dynamic> citaDetails;
  final Map<String, dynamic> confirmationDetails;

  const AppointmentDetailsCard(
      {super.key,
      required this.citaDetails,
      required this.confirmationDetails});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Detalles de tu cita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.person, 'Doctor:', citaDetails['doctor']),
            _buildDetailRow(Icons.medical_services, 'Especialidad:',
                citaDetails['specialty']),
            _buildDetailRow(
                Icons.local_hospital, 'Centro:', citaDetails['center']),
            _buildDetailRow(
                Icons.calendar_today, 'Fecha:', citaDetails['date']),
            _buildDetailRow(Icons.schedule, 'Hora:', citaDetails['time']),
            const SizedBox(height: 10),
            if (confirmationDetails['link_url'] != null)
              _buildCalendarLink(confirmationDetails, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue.withOpacity(0.8),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLink(
      Map<String, dynamic> confirmationDetails, BuildContext context) {
    return GestureDetector(
        onTap: () {
          _launchUrl(confirmationDetails['link_url'], context);
        },
        child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Text(
                  confirmationDetails['text'],
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  confirmationDetails['link_text'],
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                )
              ],
            )));
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri url0 = Uri.parse(url);
    // if (!await launchUrl(_url,mode: LaunchMode.externalApplication)) {
    //   ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
    //     content: Text("No se pudo abrir el enlace"),
    //   ));
    // }
  }
}
