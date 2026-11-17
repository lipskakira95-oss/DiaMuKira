import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diia_my/app.dart';
import 'package:diia_my/domain/catalog.dart';

import 'domain/quiz_test.dart' show question;

void main() {
  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('start, category, round, answer, result and retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      QuizApp(
        loadCatalog: () async =>
            Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Чернетки'), findsWidgets);
    await tapText(tester, 'Розпочнімо');
    await tapText(tester, 'Діти 5–12 років');
    await tapText(tester, 'Раунд 1');
    await tapText(tester, 'Так');
    expect(find.text('Правильно!'), findsOneWidget);
    await tapText(tester, 'Завершити раунд');
    expect(find.text('1 із 1'), findsOneWidget);
    await tapText(tester, 'Повторити');
    expect(find.text('Запитання 1 із 1'), findsOneWidget);
  });
  testWidgets('loading failure offers retry', (tester) async {
    await tester.pumpWidget(
      QuizApp(
        loadCatalog: () async => throw const FormatException('bad content'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Не вдалося завантажити матеріали'), findsOneWidget);
    expect(find.text('Спробувати знову'), findsOneWidget);
  });
  testWidgets('small screen with large text does not overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: QuizHome(
          loadCatalog: () async =>
              Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
