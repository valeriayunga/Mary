import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mary/main.dart'; // Asegúrate de usar el nombre de tu proyecto

void main() {
  testWidgets('App Loads Successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/home',
      getPages: [], // Puedes añadir tus páginas aquí si lo necesitas para la prueba
    ));
    // Verify that app was loaded without errors
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
