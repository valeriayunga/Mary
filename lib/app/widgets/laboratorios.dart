import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class LabResultsView extends StatefulWidget {
  const LabResultsView({Key? key}) : super(key: key);

  @override
  _LabResultsViewState createState() => _LabResultsViewState();
}

class _LabResultsViewState extends State<LabResultsView> {
  List<dynamic> _labResults = [];
  bool _isLoading = true;
  final List<String> _laboratories = ['Laboratorio Central', 'Clínica San Pablo', 'MediHelp Lab'];
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchLabResults();
  }

  Future<void> _fetchLabResults() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Usar la dirección IP local del emulador Android para acceder al backend en el host.
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/lab/get/tests'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['appoiments'] != null) {
          _labResults = data['appoiments'];
        } else {
          _labResults = [];
        }
      } else {
        // Manejar el error de la API
        print("Error al obtener resultados de laboratorio: ${response.statusCode}");
        Get.snackbar("Error", "No se pudieron cargar los resultados de laboratorio",
            backgroundColor: Colors.red[300], colorText: Colors.white);
      }
    } catch (e) {
      // Manejar errores de conexión
      print("Error de conexión: $e");
      Get.snackbar("Error", "Error de conexión con el servidor",
          backgroundColor: Colors.red[300], colorText: Colors.white);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndOpenFile(String fileUrl) async {
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    try {
      final response = await _dio.get(
          'http://10.0.2.2:8000/lab/files/$fileUrl',
          options: Options(responseType: ResponseType.bytes));

      if (response.statusCode == 200 && response.data != null) {
        final bytes = response.data;
        final fileName = fileUrl.split('/').last;
        OpenFile.open(
          bytes.toString(),
          type: 'application/pdf', // o el tipo que sea
        );
        Get.snackbar('Apertura Exitosa', 'El archivo se abrio correctamente.',backgroundColor: Colors.green[300], colorText: Colors.white );
      } else {
        Get.snackbar("Error", "Error al descargar el archivo",backgroundColor: Colors.red[300], colorText: Colors.white);
      }
    } on DioException catch (e) {
      print("Error de descarga: $e");
      Get.snackbar("Error", "Error al descargar el archivo",backgroundColor: Colors.red[300], colorText: Colors.white);
    }catch(e){
      print("Error desconocido: $e");
      Get.snackbar("Error", "Error desconocido",backgroundColor: Colors.red[300], colorText: Colors.white);
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
            if (_labResults.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                    child: Text(
                      'No hay resultados de laboratorio.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )),
              )
            else
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
      children: _labResults.map((result) => Column(
        children: [
          _buildLabResultCard(
            title: result['test_type'],
            date: result['date'],
            laboratory: _laboratories[result['id'] % _laboratories.length],
            pdfPath: result['file_path'],
          ),
          const SizedBox(height: 12),
        ],
      ),
      ).toList(),
    );
  }

  Widget _buildLabResultCard({
    required String title,
    required String date,
    required String laboratory,
    required String pdfPath,
  }) {
    String formattedDate = date.split('-').reversed.join('-');
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
                            formattedDate,
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
                          // Get.to(() =>  MyPdfViewer(pdfPath: pdfPath)); //ya no lo mandaremos a ver
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
                        onPressed: () async {
                          _downloadAndOpenFile(pdfPath);
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