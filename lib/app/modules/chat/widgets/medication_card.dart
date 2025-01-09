import 'package:flutter/material.dart';

class MedicationCard extends StatelessWidget {
  final List<Map<String, dynamic>> medicamentos;

  MedicationCard({super.key, required this.medicamentos});

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
              'Medicamentos Obtenidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicamentos.length,
              separatorBuilder: (context, index) => const Divider(height: 10),
              itemBuilder: (context, index) {
                final medicamento = medicamentos[index];
                return _buildMedicationRow(medicamento);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationRow(Map<String, dynamic> medicamento) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.medication,
            color: Colors.blue.withOpacity(0.8),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              medicamento['nombre'],
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
          if (medicamento['dosis'].isNotEmpty)
            Text(
              'Dosis: ${medicamento['dosis']}',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          if (medicamento['frecuencia'].isNotEmpty)
            Text(
              'Frecuencia: ${medicamento['frecuencia']}',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}