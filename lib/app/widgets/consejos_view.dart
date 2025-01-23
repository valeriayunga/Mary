import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'consejo_detalle_view.dart';

class ConsejosView extends StatefulWidget {
  final int categoriaId;
  final String categoriaName;

  const ConsejosView(
      {super.key, required this.categoriaId, required this.categoriaName});

  @override
  ConsejosViewState createState() => ConsejosViewState();
}

class ConsejosViewState extends State<ConsejosView> {
  List<dynamic> _consejos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConsejos();
  }

  Future<void> _fetchConsejos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('http://172.17.180.111:8000/consejos/consejos/'));
      if (response.statusCode == 200) {
        final stringResponse = const Utf8Decoder().convert(response.bodyBytes);
        final data = json.decode(stringResponse);
        _processConsejos(data);
      } else {
        Get.snackbar("Error", "No se pudieron cargar los consejos",
            backgroundColor: Colors.red[300], colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Error de conexión con el servidor",
          backgroundColor: Colors.red[300], colorText: Colors.white);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processConsejos(List<dynamic> consejos) {
    _consejos = consejos
        .where((consejo) => consejo['categoria']['id'] == widget.categoriaId)
        .toList();
    setState(() {});
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
  }

  Color _getCategoryColor() {
    switch (widget.categoriaId) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.amber;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.categoriaId) {
      case 1:
        return FontAwesomeIcons.utensils;
      case 2:
        return FontAwesomeIcons.chartLine;
      case 3:
        return FontAwesomeIcons.pills;
      default:
        return FontAwesomeIcons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoriaName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          color: categoryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Consejos sobre ${widget.categoriaName}',
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._consejos.map((consejo) => _buildConsejoCard(
                        consejo,
                        categoryColor,
                      )),
                ],
              ),
            ),
    );
  }

  Widget _buildConsejoCard(dynamic consejo, Color categoryColor) {
    return GestureDetector(
      onTap: () {
        Get.to(() =>
            ConsejoDetalleView(consejo: consejo, categoryColor: categoryColor));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.lightbulb,
                          color: categoryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          consejo['titulo'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _parseHtmlString(consejo['resumen']),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
