import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/widgets/keyboard_aware_bottom_sheet.dart';

void main() {
  testWidgets('keeps tall content scrollable above the mobile keyboard', (
    tester,
  ) async {
    const screenSize = Size(360, 640);
    const keyboardHeight = 300.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            viewInsets: EdgeInsets.only(bottom: keyboardHeight),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: KeyboardAwareBottomSheet(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(),
                    SizedBox(height: 500),
                    Text('Acción final'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final verticalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    final scrollable = tester.state<ScrollableState>(verticalScrollable);
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Acción final'));
    await tester.pumpAndSettle();

    final keyboardTop = screenSize.height - keyboardHeight;
    expect(
      tester.getBottomRight(find.text('Acción final')).dy,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the primary action fixed above the mobile keyboard', (
    tester,
  ) async {
    const screenSize = Size(360, 640);
    const keyboardHeight = 300.0;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: screenSize,
            viewInsets: EdgeInsets.only(bottom: keyboardHeight),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: KeyboardAwareBottomSheet(
                footer: const SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('Confirmar cita'),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [TextField(), SizedBox(height: 500)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = find.text('Confirmar cita');
    expect(button, findsOneWidget);
    expect(
      tester.getBottomRight(button).dy,
      lessThanOrEqualTo(screenSize.height - keyboardHeight),
    );
    expect(tester.takeException(), isNull);
  });
}
