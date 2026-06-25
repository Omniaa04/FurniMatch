import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:furnimatch/features/profile/presentation/pages/edit_profile_page.dart';

void main() {
  testWidgets(
    'Edit Profile screen displays required widgets',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfilePage(
            userId: 1,
            currentName: 'Shahd',
          ),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );
}