// This is a basic Flutter widget test for StreamNet TV.

import 'package:flutter_test/flutter_test.dart';

import 'package:streamnet_tv/main.dart';

void main() {
  testWidgets('StreamNet TV app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StreamNetApp());

    // Verify that the app loads
    await tester.pumpAndSettle();
  });
}
