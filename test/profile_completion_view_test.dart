import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:inventif/views/auth/profile_completion_view.dart';
import 'package:inventif/models/user_model.dart';
import 'package:flutter/services.dart';

void main() {
  testWidgets('Identifier field accepts only digits', (WidgetTester tester) async {
    final user = UserModel(
      uid: 'uid',
      fullName: 'Test User',
      identifier: '',
      email: 'test@example.com',
      ktm: '12345',
      role: 'user',
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(
      home: ProfileCompletionView(userData: user),
    ));

    // Find Identifier TextField by hint text
    final identifierFinder = find.byWidgetPredicate((widget) {
      return widget is TextField && widget.decoration?.hintText == 'NIM/NIP';
    });
    expect(identifierFinder, findsOneWidget);

    // Verify that the Identifier TextField has numeric input restrictions
    final textFieldWidget = tester.widget<TextField>(identifierFinder);
    expect(textFieldWidget.keyboardType, TextInputType.number);
    expect(textFieldWidget.inputFormatters, contains(FilteringTextInputFormatter.digitsOnly));
    // Optionally, enter digits only and ensure no errors
    await tester.enterText(identifierFinder, '12345');
    await tester.pump();
    expect(textFieldWidget.controller?.text, '12345');
  });
}
