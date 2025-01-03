import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';


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
