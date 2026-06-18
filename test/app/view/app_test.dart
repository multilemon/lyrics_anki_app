import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyrics_anki_app/app/app.dart';
import 'package:lyrics_anki_app/features/home/presentation/pages/home_page.dart';
import 'package:lyrics_anki_app/features/srs/data/repositories/hive_srs_repository.dart';
import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';
import 'package:lyrics_anki_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late SrsRepository srsRepository;

  setUp(() {
    srsRepository = MockSrsRepository();
    when(() => srsRepository.getStats()).thenReturn({
      'total': 0,
      'due': 0,
      'new': 0,
      'suspended': 0,
      'songs': 0,
      'jlpt': <String, int>{},
    });
    when(() => srsRepository.watchCards()).thenAnswer(
      (_) => const Stream<List<SrsCard>>.empty(),
    );
    when(() => srsRepository.getDueCards()).thenReturn([]);
  });

  group('App', () {
    testWidgets('renders HomePage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            srsRepositoryProvider.overrideWithValue(srsRepository),
          ],
          child: const App(),
        ),
      );
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
