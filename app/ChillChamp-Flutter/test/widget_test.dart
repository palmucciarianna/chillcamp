import 'package:flutter_test/flutter_test.dart';
import 'package:chillchamp/main.dart';

void main() {
  testWidgets('shows ChillChamp welcome screen', (tester) async {
    await tester.pumpWidget(const ChillChampApp());
    expect(find.text('ChillChamp'), findsOneWidget);
    expect(find.text('Esplora la demo'), findsOneWidget);
  });
}
