import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diia_my/app.dart';
import 'package:diia_my/data/memory_user_store.dart';
import 'package:diia_my/domain/catalog.dart';
import 'package:diia_my/domain/user_data.dart';
import 'package:diia_my/platform/answer_feedback.dart';

import 'domain/quiz_test.dart' show question;

class RecordingFeedback implements AnswerFeedback {
  bool? correct;
  AppSettings? settings;

  @override
  Future<void> onAnswer({
    required bool correct,
    required AppSettings settings,
  }) async {
    this.correct = correct;
    this.settings = settings;
  }
}

class FailingSaveStore extends MemoryUserStore {
  @override
  Future<void> saveCompletedAttempt(SavedRoundProgress progress) async {
    throw Exception('disk full');
  }
}

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
        store: MemoryUserStore(),
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
        store: MemoryUserStore(),
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
          store: MemoryUserStore(),
          loadCatalog: () async =>
              Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android back asks before abandoning an unfinished round', (
    tester,
  ) async {
    await tester.pumpWidget(
      QuizApp(
        store: MemoryUserStore(),
        loadCatalog: () async =>
            Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
      ),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Розпочнімо');
    await tapText(tester, 'Діти 5–12 років');
    await tapText(tester, 'Раунд 1');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Вийти з раунду?'), findsOneWidget);
    expect(find.text('Залишитися'), findsOneWidget);
    expect(find.text('Вийти'), findsOneWidget);
    await tapText(tester, 'Залишитися');
    expect(find.text('Запитання 1 із 1'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tapText(tester, 'Вийти');
    expect(find.text('Раунд 1'), findsOneWidget);
  });

  testWidgets('mobile quiz supports long text at 200 percent scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final longText = List.filled(
      10,
      'Чи потрібно поважати потреби іншої людини та запитувати, як їй допомогти?',
    ).join(' ');
    final longExplanation = List.filled(
      8,
      'Спочатку варто вислухати людину й не вирішувати замість неї.',
    ).join(' ');

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: QuizApp(
          store: MemoryUserStore(),
          loadCatalog: () async => Catalog(
            [question('q1', 1, text: longText, explanation: longExplanation)],
            version: 'v1',
            mode: 'draft',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Розпочнімо');
    await tapText(tester, 'Діти 5–12 років');
    await tapText(tester, 'Раунд 1');

    expect(find.text('Повага'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Ні')).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Так')).height,
      greaterThanOrEqualTo(48),
    );
    await tapText(tester, 'Ні');
    expect(find.text(longExplanation), findsOneWidget);
    await tester.ensureVisible(find.text('Завершити раунд'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile settings open as a safe full-screen page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      QuizApp(
        store: MemoryUserStore(),
        loadCatalog: () async =>
            Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Налаштування'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mobile-settings-page')), findsOneWidget);
    expect(
      find.text('Налаштування зберігаються на цьому пристрої.'),
      findsOneWidget,
    );
  });

  testWidgets('completed progress is restored after rebuilding the app', (
    tester,
  ) async {
    final store = MemoryUserStore();
    final catalog = Catalog([question('q1', 1)], version: 'v1', mode: 'draft');

    await tester.pumpWidget(
      QuizApp(store: store, loadCatalog: () async => catalog),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Розпочнімо');
    await tapText(tester, 'Діти 5–12 років');
    await tapText(tester, 'Раунд 1');
    await tapText(tester, 'Так');
    await tapText(tester, 'Завершити раунд');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      QuizApp(store: store, loadCatalog: () async => catalog),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Розпочнімо');
    await tapText(tester, 'Діти 5–12 років');

    expect(find.textContaining('1 із 1 · найкраще 1'), findsOneWidget);
    expect(find.textContaining('Без помилок'), findsOneWidget);
  });

  testWidgets(
    'answer feedback receives persisted sound and vibration settings',
    (tester) async {
      final feedback = RecordingFeedback();
      final store = MemoryUserStore(
        settings: const AppSettings(
          explanations: true,
          sound: true,
          vibration: true,
          shuffle: false,
        ),
      );
      await tester.pumpWidget(
        QuizApp(
          store: store,
          feedback: feedback,
          loadCatalog: () async =>
              Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
        ),
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'Розпочнімо');
      await tapText(tester, 'Діти 5–12 років');
      await tapText(tester, 'Раунд 1');
      await tapText(tester, 'Ні');

      expect(feedback.correct, isFalse);
      expect(feedback.settings?.sound, isTrue);
      expect(feedback.settings?.vibration, isTrue);
    },
  );

  testWidgets('deep link opens a round and an invalid link explains recovery', (
    tester,
  ) async {
    final catalog = Catalog([question('q1', 1)], version: 'v1', mode: 'draft');
    await tester.pumpWidget(
      QuizApp(
        store: MemoryUserStore(),
        initialPath: '/rounds/children-1',
        loadCatalog: () async => catalog,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Запитання 1 із 1'), findsOneWidget);

    await tester.pumpWidget(
      QuizApp(
        key: const ValueKey('invalid-route'),
        store: MemoryUserStore(),
        initialPath: '/rounds/unknown-9',
        loadCatalog: () async => catalog,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Посилання недійсне'), findsOneWidget);
    expect(find.text('До категорій'), findsOneWidget);
  });

  testWidgets(
    'quiz exposes progress, question and feedback to screen readers',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        QuizApp(
          store: MemoryUserStore(),
          loadCatalog: () async =>
              Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
        ),
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'Розпочнімо');
      await tapText(tester, 'Діти 5–12 років');
      await tapText(tester, 'Раунд 1');

      final progress = tester.getSemantics(
        find.bySemanticsLabel('Прогрес раунду'),
      );
      expect(progress.value, '100%');
      expect(
        tester.getSemantics(find.text('Запитання q1')).flagsCollection.isHeader,
        isTrue,
      );
      await tapText(tester, 'Так');
      expect(
        tester
            .getSemantics(find.text('Правильно!'))
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      semantics.dispose();
    },
  );

  testWidgets('primary flow can start with keyboard only', (tester) async {
    await tester.pumpWidget(
      QuizApp(
        store: MemoryUserStore(),
        loadCatalog: () async =>
            Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
      ),
    );
    await tester.pumpAndSettle();
    bool hasFocus() =>
        Focus.of(tester.element(find.text('Розпочнімо'))).hasFocus;
    for (var i = 0; i < 5 && !hasFocus(); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(hasFocus(), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Для кого ця гра?'), findsOneWidget);
  });

  testWidgets('failed progress write is explained without a false success', (
    tester,
  ) async {
    await tester.pumpWidget(
      QuizApp(
        store: FailingSaveStore(),
        loadCatalog: () async =>
            Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
      ),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Розпочнімо');
    await tapText(tester, 'Діти 5–12 років');
    await tapText(tester, 'Раунд 1');
    await tapText(tester, 'Так');
    await tapText(tester, 'Завершити раунд');
    expect(
      find.text('Прогрес залишився лише до закриття застосунку.'),
      findsOneWidget,
    );
    expect(find.text('Прогрес збережено на цьому пристрої.'), findsNothing);
  });

  test('design colors meet WCAG AA contrast for normal text', () {
    double contrast(Color first, Color second) {
      final firstLuminance = first.computeLuminance();
      final secondLuminance = second.computeLuminance();
      final high = firstLuminance > secondLuminance
          ? firstLuminance
          : secondLuminance;
      final low = firstLuminance > secondLuminance
          ? secondLuminance
          : firstLuminance;
      return (high + 0.05) / (low + 0.05);
    }

    expect(contrast(ink, yellow), greaterThanOrEqualTo(4.5));
    expect(contrast(ink, paper), greaterThanOrEqualTo(4.5));
    expect(contrast(Colors.white, green), greaterThanOrEqualTo(4.5));
    expect(contrast(Colors.white, red), greaterThanOrEqualTo(4.5));
  });

  testWidgets('target phone, tablet and desktop sizes do not overflow', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in const [
      Size(390, 844),
      Size(768, 1024),
      Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        QuizApp(
          key: ValueKey(size),
          store: MemoryUserStore(),
          loadCatalog: () async =>
              Catalog([question('q1', 1)], version: 'v1', mode: 'draft'),
        ),
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'Розпочнімо');
      expect(tester.takeException(), isNull, reason: 'viewport $size');
    }
  });
}
