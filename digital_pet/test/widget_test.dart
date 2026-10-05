import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_pet/main.dart';

void main() {
  testWidgets('Digital Pet loads correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DigitalPetApp());

    expect(find.text('Digital Pet'), findsOneWidget);
    expect(find.text('My Pet'), findsOneWidget);
    expect(find.text('Happiness: 50 / 100'), findsOneWidget);
    expect(find.text('Hunger: 50 / 100'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Pause Session'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}
