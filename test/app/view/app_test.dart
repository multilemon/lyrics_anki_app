import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyrics_anki_app/app/app.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));
      expect(find.byType(MainPage), findsOneWidget);
    });
  });
}
