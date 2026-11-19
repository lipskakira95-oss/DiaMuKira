import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:diia_my/app.dart';
import 'package:diia_my/data/local_database.dart';
import 'package:diia_my/data/user_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> tapVisible(WidgetTester tester, String text) async {
    final finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('bundled Android quiz works offline and keeps progress', (
    tester,
  ) async {
    final firstStore = DriftUserStore(AppDatabase.defaults());
    await tester.pumpWidget(QuizApp(store: firstStore));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Розпочнімо'), findsOneWidget);

    await tapVisible(tester, 'Розпочнімо');
    await tapVisible(tester, 'Діти 5–12 років');
    await tapVisible(tester, 'Раунд 1');
    for (var answered = 0; answered < 7; answered++) {
      await tapVisible(tester, 'Так');
      await tapVisible(tester, answered == 6 ? 'Завершити раунд' : 'Далі');
    }
    expect(find.text('Раунд завершено'), findsOneWidget);
    expect(find.text('Прогрес збережено на цьому пристрої.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await firstStore.close();
    final reopenedStore = DriftUserStore(AppDatabase.defaults());
    addTearDown(reopenedStore.close);
    await tester.pumpWidget(QuizApp(store: reopenedStore));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await tapVisible(tester, 'Розпочнімо');
    await tapVisible(tester, 'Діти 5–12 років');
    expect(find.textContaining('найкраще'), findsWidgets);
  });
}
