import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:furnimatch/features/RoomMeasurement/presentation/screen/room_3d_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Room3DScreen Integration Tests', () {

   
    // Test 1
    
    testWidgets(
      'should display Room3DScreen correctly',
      (tester) async {

        await tester.pumpWidget(
          const MaterialApp(
            home: Room3DScreen(
              roomWidth: 4,
              roomLength: 5,
              roomHeight: 3,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('4.0m × 5.0m Room'), findsOneWidget);

        expect(find.byIcon(Icons.folder_open), findsOneWidget);

        expect(find.byIcon(Icons.save), findsOneWidget);

        expect(find.text('Add Furniture'), findsOneWidget);
      },
    );

  
    // Test 2
  
    testWidgets(
      'should open furniture picker when Add Furniture is pressed',
      (tester) async {

        await tester.pumpWidget(
          const MaterialApp(
            home: Room3DScreen(
              roomWidth: 4,
              roomLength: 5,
              roomHeight: 3,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Furniture'));

        await tester.pumpAndSettle();

        expect(find.text('Add Furniture'), findsWidgets);

        expect(find.text('Sofa'), findsOneWidget);

        expect(find.text('Double Bed'), findsOneWidget);

        expect(find.text('Dining Table'), findsOneWidget);
      },
    );

    
    // Test 3
    
    testWidgets(
      'should preview furniture when tapped once',
      (tester) async {

        await tester.pumpWidget(
          const MaterialApp(
            home: Room3DScreen(
              roomWidth: 4,
              roomLength: 5,
              roomHeight: 3,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Furniture'));

        await tester.pumpAndSettle();

        await tester.tap(find.text('Sofa'));

        await tester.pump();

        expect(find.text('Tap again to add →'), findsOneWidget);
      },
    );

    // Test 4

    testWidgets(
      'should add furniture after second tap',
      (tester) async {

        await tester.pumpWidget(
          const MaterialApp(
            home: Room3DScreen(
              roomWidth: 4,
              roomLength: 5,
              roomHeight: 3,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Furniture'));

        await tester.pumpAndSettle();

        await tester.tap(find.text('Sofa'));

        await tester.pump();

        await tester.tap(find.text('Tap again to add →'));

        await tester.pumpAndSettle();

        expect(find.text('Sofa'), findsOneWidget);
      },
    );

    
    // Test 5
     testWidgets(
      'should open save room screen',
      (tester) async {

        await tester.pumpWidget(
          const MaterialApp(
            home: Room3DScreen(
              roomWidth: 4,
              roomLength: 5,
              roomHeight: 3,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.save));

        await tester.pumpAndSettle();

        expect(find.byType(Room3DScreen), findsOneWidget);
    });
  });
}