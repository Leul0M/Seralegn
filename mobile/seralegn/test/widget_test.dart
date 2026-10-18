// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:seralegn/fayda/fayda_decoder.dart';

void main() {
  test('decodes phone number from a Fayda QR payload', () {
    const payload =
        'John Doe:DLT:V:4:G:M:A:1234567890:D:2002/11/04:P:0912345678:SIGN:abc';

    final result = decodePayload(payload);

    expect(result, isA<FaydaResultOk>());
    final data = (result as FaydaResultOk).data;
    expect(data.fullName, 'John Doe');
    expect(data.gender, 'M');
    expect(data.phoneNumber, '0912345678');
  });
}
