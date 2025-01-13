import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../widgets/reprogram_appointment_dialog.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({Key? key}) : super(key: key);

  @override
  _AppointmentsViewState createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  List<dynamic> _upcomingAppointments = [];
  List<dynamic> _pastAppointments = [];
  bool _isLoading = true;
  final List<String> _locations = [
    'Clínica San Pablo',
    'Hospital Central',
    'MediHelp'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/citas/dia/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _processAppointments(data['appoiments']);
      } else {
        // Manejar el error de la API
        print("Error al obtener citas: ${response.statusCode}");
        Get.snackbar("Error", "No se pudieron cargar las citas",
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

  void _processAppointments(List<dynamic> appointments) {
    DateTime now = DateTime.now();
    _upcomingAppointments = [];
    _pastAppointments = [];

    for (var appointment in appointments) {
      DateTime appointmentDate = DateTime.parse(appointment['date']);
      // Usamos DateTime.parse para convertir la fecha y hora en objetos DateTime

      if (appointmentDate.isAfter(now.subtract(const Duration(days: 1)))) {
        _upcomingAppointments.add(appointment);
      } else {
        _pastAppointments.add(appointment);
      }
    }
    setState(() {}); // Actualizar la UI después de separar citas
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
          'Mis Citas Médicas',
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
                  _buildUpcomingAppointments(),
                  const SizedBox(height: 32),
                  _buildPastAppointments(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFFa076ec),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: FontAwesomeIcons.calendarAlt,
          title: 'Próximas Citas',
          color: const Color(0xFFa076ec),
        ),
        const SizedBox(height: 16),
        if (_upcomingAppointments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
                child: Text(
              'No hay citas próximas.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            )),
          )
        else
          ..._upcomingAppointments.map((appointment) => Column(
                children: [
                  _buildAppointmentCard(
                    appointmentId: appointment['id'],
                    doctorName:
                        '${appointment['doctor']['first_name']} ${appointment['doctor']['last_name']}',
                    specialty: appointment['doctor']['specialty'],
                    date: appointment['date'],
                    time: appointment['time'],
                    location: _locations[appointment['id'] % _locations.length],
                    status: appointment['status'],
                    statusColor: appointment['status'] == 'PENDING'
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(height: 12),
                ],
              )),
      ],
    );
  }

  Widget _buildPastAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: FontAwesomeIcons.history,
          title: 'Historial de Citas',
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        if (_pastAppointments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'No hay citas en el historial.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ..._pastAppointments.map((appointment) => Column(children: [
                _buildAppointmentCard(
                  appointmentId: appointment['id'],
                  doctorName:
                      '${appointment['doctor']['first_name']} ${appointment['doctor']['last_name']}',
                  specialty: appointment['doctor']['specialty'],
                  date: appointment['date'],
                  time: appointment['time'],
                  location: _locations[appointment['id'] % _locations.length],
                  status: appointment['status'],
                  statusColor: Colors.blue,
                  isPast: true,
                ),
                const SizedBox(height: 12),
              ])),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required int appointmentId,
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required String location,
    required String status,
    required Color statusColor,
    bool isPast = false,
  }) {
    String formattedTime = time.substring(0, 5);
    String formattedDate = date.split('-').reversed.join('-');
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFa076ec).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.userMd,
                  color: Color(0xFFa076ec),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoItem(
                icon: FontAwesomeIcons.calendar,
                text: formattedDate,
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: FontAwesomeIcons.clock,
                text: formattedTime,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: FontAwesomeIcons.hospital,
            text: location,
          ),
          if (!isPast) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showReprogramDialog(appointmentId);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFa076ec)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Reprogramar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFa076ec),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ver Detalles'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _reprogramAppointment(
      int appointmentId, DateTime date, TimeOfDay time) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final formattedTime = time.format(context);
    try {
      final response = await http.put(
          Uri.parse('http://10.0.2.2:8000/api/citas/$appointmentId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'date': formattedDate,
            'time': formattedTime,
          }));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showSnackBar('Cita reprogramada correctamente', Colors.green);
        print(data);
      } else {
        print("error al reprogramar la cita: ${response.statusCode}");
        _showSnackBar("Error al reprogramar la cita", Colors.red.shade300);
      }
    } catch (e) {
      print("Error al conectar con el servidor: $e");
      _showSnackBar("Error al conectar con el servidor", Colors.red.shade300);
    }
  }

  void _showSnackBar(String message, Color color) {
    Get.snackbar(
      "Mensaje",
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showReprogramDialog(int appointmentId) {
    showDialog(
      context: context,
      builder: (context) => ReprogramAppointmentDialog(
        appointmentId: appointmentId,
        onReprogram: (date, time) {
          _reprogramAppointment(appointmentId, date, time);
        },
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
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
