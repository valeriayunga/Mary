import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mary/app/widgets/documento.dart';

class LabResultsView extends GetView {
  const LabResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Mis Resultados',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: FontAwesomeIcons.flask,
              title: 'Exámenes de Laboratorio',
              color: const Color(0xFFa076ec),
            ),
            const SizedBox(height: 16),
            _buildLabResultsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí puedes implementar la navegación al chat de preguntas
          Get.toNamed('/lab-questions');
        },
        backgroundColor: const Color(0xFFa076ec),
        icon: const Icon(FontAwesomeIcons.questionCircle),
        label: const Text('Preguntas sobre tus resultados'),
      ),
    );
  }

  Widget _buildLabResultsList() {
    return Column(
      children: [
        _buildLabResultCard(
          title: 'Análisis de Sangre',
          date: '15 de Septiembre, 2024',
          laboratory: 'Laboratorio Central',
          pdfPath: 'assets/pdfs/blood_test.pdf',
        ),
        const SizedBox(height: 12),
        _buildLabResultCard(
          title: 'Prueba de Glucosa',
          date: '10 de Septiembre, 2024',
          laboratory: 'Clínica San Pablo',
          pdfPath: 'assets/pdfs/glucose_test.pdf',
        ),
        const SizedBox(height: 12),
        _buildLabResultCard(
          title: 'Perfil Lipídico',
          date: '5 de Septiembre, 2024',
          laboratory: 'Laboratorio Central',
          pdfPath: 'assets/pdfs/lipid_profile.pdf',
        ),
      ],
    );
  }

  Widget _buildLabResultCard({
    required String title,
    required String date,
    required String laboratory,
    required String pdfPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFa076ec).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.fileMedicalAlt,
                        color: Color(0xFFa076ec),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            laboratory,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.to(() => const MyPdfViewer());
                        },
                        icon: const Icon(FontAwesomeIcons.filePdf),
                        label: const Text('Ver PDF'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFa076ec)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Implementar la descarga del PDF
                        },
                        icon: const Icon(FontAwesomeIcons.download),
                        label: const Text('Descargar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: const Color(0xFFa076ec),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
