import 'dart:math';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'data/content_repository.dart';
import 'data/local_database.dart';
import 'data/user_store.dart';
import 'domain/catalog.dart';
import 'domain/quiz.dart';
import 'domain/user_data.dart';
import 'platform/answer_feedback.dart';

const yellow = Color(0xFFF5C928),
    ink = Color(0xFF181818),
    paper = Color(0xFFFFFDF5);
const green = Color(0xFF247A43), red = Color(0xFFB73535);
typedef CatalogLoader = Future<Catalog> Function();

class QuizApp extends StatelessWidget {
  const QuizApp({
    super.key,
    this.loadCatalog,
    this.store,
    this.feedback,
    this.initialPath,
  });
  final CatalogLoader? loadCatalog;
  final UserStore? store;
  final AnswerFeedback? feedback;
  final String? initialPath;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Дія Ми',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: yellow),
      scaffoldBackgroundColor: paper,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: ink,
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyLarge: TextStyle(fontSize: 18, color: ink),
      ),
    ),
    home: QuizHome(
      loadCatalog: loadCatalog,
      store: store,
      feedback: feedback,
      initialPath: initialPath,
    ),
  );
}

enum _Page { welcome, categories, rounds, quiz, result, invalid }

class _InitialDestination {
  const _InitialDestination(
    this.page, {
    this.category,
    this.round,
    this.openSettings = false,
    this.invalidPath,
  });

  final _Page page;
  final String? category;
  final int? round;
  final bool openSettings;
  final String? invalidPath;
}

class QuizHome extends StatefulWidget {
  const QuizHome({
    super.key,
    this.loadCatalog,
    this.store,
    this.feedback,
    this.initialPath,
  });
  final CatalogLoader? loadCatalog;
  final UserStore? store;
  final AnswerFeedback? feedback;
  final String? initialPath;
  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  Catalog? _catalog;
  bool _loading = true, _failed = false;
  _Page _page = _Page.welcome;
  String? _category;
  QuizAttempt? _attempt;
  late final UserStore _store;
  late final AnswerFeedback _feedback;
  late final bool _ownsStore;
  AppSettings _settingsState = const AppSettings.defaults();
  SessionProgress _progress = SessionProgress();
  String _phrase = '';
  String? _invalidPath;
  bool _progressSaveFailed = false;
  @override
  void initState() {
    super.initState();
    _ownsStore = widget.store == null;
    _store = widget.store ?? DriftUserStore(AppDatabase.defaults());
    _feedback = widget.feedback ?? const FlutterAnswerFeedback();
    _load();
  }

  @override
  void dispose() {
    if (_ownsStore) _store.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      AppSettings settings;
      try {
        settings = await _store.loadSettings();
      } on Exception {
        settings = const AppSettings.defaults();
      }
      final catalog =
          await (widget.loadCatalog?.call() ??
              ContentRepository(store: _store).load());
      List<SavedRoundProgress> savedProgress;
      try {
        savedProgress = await _store.loadProgress(catalog.version);
      } on Exception {
        savedProgress = const [];
      }
      final destination = _resolveInitialPath(
        catalog,
        widget.initialPath ?? '/',
      );
      final attempt = destination.round == null
          ? null
          : QuizAttempt(
              catalog.inRound(destination.category!, destination.round!),
              shuffle: settings.shuffle,
            );
      if (mounted) {
        setState(() {
          _catalog = catalog;
          _settingsState = settings;
          _progress = SessionProgress(savedProgress);
          _page = destination.page;
          _category = destination.category;
          _attempt = attempt;
          _invalidPath = destination.invalidPath;
          _loading = false;
        });
        if (destination.openSettings) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(_settings());
          });
        }
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  _InitialDestination _resolveInitialPath(Catalog catalog, String rawPath) {
    final segments = Uri.tryParse(rawPath)?.pathSegments ?? const <String>[];
    if (segments.isEmpty) return const _InitialDestination(_Page.welcome);
    if (segments.length == 1 && segments.first == 'categories') {
      return const _InitialDestination(_Page.categories);
    }
    if (segments.length == 1 && segments.first == 'settings') {
      return const _InitialDestination(_Page.welcome, openSettings: true);
    }
    if (segments.length == 3 &&
        segments[0] == 'categories' &&
        segments[2] == 'rounds' &&
        catalog.categories.contains(segments[1])) {
      return _InitialDestination(_Page.rounds, category: segments[1]);
    }
    if (segments.length == 2 && segments.first == 'rounds') {
      final separator = segments[1].lastIndexOf('-');
      if (separator > 0) {
        final category = segments[1].substring(0, separator);
        final round = int.tryParse(segments[1].substring(separator + 1));
        if (round != null && catalog.inRound(category, round).isNotEmpty) {
          return _InitialDestination(
            _Page.quiz,
            category: category,
            round: round,
          );
        }
      }
    }
    return _InitialDestination(_Page.invalid, invalidPath: rawPath);
  }

  String _pathFor(_Page page) => switch (page) {
    _Page.welcome => '/',
    _Page.categories => '/categories',
    _Page.rounds => '/categories/$_category/rounds',
    _Page.quiz ||
    _Page.result => '/rounds/$_category-${_attempt!.current.roundNumber}',
    _Page.invalid => _invalidPath ?? '/',
  };

  void _updateBrowserPath(String path, {bool replace = false}) {
    if (kIsWeb) {
      unawaited(
        SystemNavigator.routeInformationUpdated(
          uri: Uri.parse(path),
          replace: replace,
        ),
      );
    }
  }

  void _go(_Page page) {
    setState(() => _page = page);
    _updateBrowserPath(_pathFor(page));
  }

  Future<void> _leave(_Page destination) async {
    if (_page == _Page.quiz && !_attempt!.finished) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Вийти з раунду?'),
          content: const Text('Незавершена спроба не збережеться.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Залишитися'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Вийти'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    _go(destination);
  }

  void _start(int round) {
    setState(() {
      _attempt = QuizAttempt(
        _catalog!.inRound(_category!, round),
        shuffle: _settingsState.shuffle,
      );
      _page = _Page.quiz;
    });
    _updateBrowserPath('/rounds/$_category-$round');
  }

  void _answer(bool value) {
    late bool accepted;
    setState(() => accepted = _attempt!.submit(value));
    if (accepted) {
      unawaited(_sendFeedback(_attempt!.lastCorrect!));
    }
  }

  Future<void> _sendFeedback(bool correct) async {
    try {
      await _feedback.onAnswer(correct: correct, settings: _settingsState);
    } on Exception {
      // Unsupported sound or haptics must never interrupt a quiz attempt.
    }
  }

  Future<void> _next() async {
    SavedRoundProgress? completed;
    setState(() {
      _attempt!.next();
      if (_attempt!.finished) {
        completed = _progress.record(_attempt!);
        _progressSaveFailed = false;
        _page = _Page.result;
        const phrases = [
          'Кожна спроба допомагає вчитися.',
          'Дякуємо за уважність до інших.',
          'Нові знання починаються з цікавості.',
        ];
        _phrase = phrases[Random().nextInt(phrases.length)];
      }
    });
    if (completed != null) {
      try {
        await _store.saveCompletedAttempt(completed!);
      } on Exception {
        if (mounted) {
          setState(() => _progressSaveFailed = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не вдалося зберегти прогрес на цьому пристрої.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveSettings(AppSettings settings) async {
    setState(() => _settingsState = settings);
    try {
      await _store.saveSettings(settings);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не вдалося зберегти налаштування.')),
        );
      }
    }
  }

  Future<void> _settings() async {
    final returnPath = _pathFor(_page);
    _updateBrowserPath('/settings');
    final panel = _SettingsPanel(
      initialSettings: _settingsState,
      onChanged: _saveSettings,
    );
    if (MediaQuery.sizeOf(context).width < 600) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            key: const Key('mobile-settings-page'),
            appBar: AppBar(
              backgroundColor: yellow,
              foregroundColor: ink,
              title: const Text('Налаштування'),
            ),
            body: SafeArea(child: panel),
          ),
        ),
      );
      _updateBrowserPath(returnPath, replace: true);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(child: panel),
    );
    _updateBrowserPath(returnPath, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final canBack = _page != _Page.welcome;
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final title = mobile && _category != null && _page != _Page.categories
        ? (_page == _Page.quiz || _page == _Page.result
              ? _attempt?.current.roundTitle ?? 'Дія Ми'
              : _catalog!.inCategory(_category!).first.categoryName)
        : 'Дія Ми';
    return PopScope(
      canPop: !canBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && canBack) {
          _leave(
            _page == _Page.quiz || _page == _Page.result
                ? _Page.rounds
                : _Page.welcome,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: yellow,
          foregroundColor: ink,
          leading: canBack
              ? IconButton(
                  tooltip: 'Назад',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _leave(
                    _page == _Page.quiz || _page == _Page.result
                        ? _Page.rounds
                        : _Page.welcome,
                  ),
                )
              : null,
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: 'Налаштування',
              onPressed: _settings,
              icon: const Icon(Icons.tune),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _failed
              ? _error()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1000;
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(wide ? 40 : 20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_catalog!.mode == 'draft')
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0C2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Чернетки навчальних матеріалів · потребують редакторської перевірки',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (_catalog!.origin == 'bundled')
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    'Використовуємо матеріали зі збірки.',
                                  ),
                                ),
                              if (wide && _page == _Page.quiz)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 260, child: _roundPanel()),
                                    const SizedBox(width: 32),
                                    Expanded(child: _content()),
                                  ],
                                )
                              else
                                _content(),
                              const SizedBox(height: 32),
                              const Text(
                                'Навчаємося поважати відмінності — крок за кроком.',
                                style: TextStyle(color: Color(0xFF595959)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _error() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: const Text(
              'Не вдалося завантажити матеріали',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _load, child: const Text('Спробувати знову')),
        ],
      ),
    ),
  );
  Widget _content() {
    switch (_page) {
      case _Page.welcome:
        return _welcome();
      case _Page.categories:
        return _categories();
      case _Page.rounds:
        return _rounds();
      case _Page.quiz:
        return _quiz();
      case _Page.result:
        return _result();
      case _Page.invalid:
        return _invalidRoute();
    }
  }

  Widget _welcome() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.diversity_3, size: 56, color: ink),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            'Різні люди.\nСпільний світ.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Короткі запитання про повагу, доступність і взаємодію. Обери свою категорію та навчайся у зручному темпі.',
          style: TextStyle(fontSize: 20, height: 1.5),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _badge('5 категорій'),
            _badge('18 раундів'),
            _badge('Без поспіху'),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => _go(_Page.categories),
          child: const Text('Розпочнімо'),
        ),
      ],
    ),
  );
  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3BD),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text),
  );
  Widget _categories() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          'Для кого ця гра?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      const SizedBox(height: 12),
      const Text('Обери категорію. Її можна змінити у будь-який момент.'),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1000
              ? 3
              : width >= 600
              ? 2
              : 1;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _catalog!.categories.map((id) {
              final questions = _catalog!.inCategory(id);
              return SizedBox(
                width: (width - 16 * (columns - 1)) / columns,
                child: _tile(
                  questions.first.categoryName,
                  '${questions.map((q) => q.roundNumber).toSet().length} раунди · ${questions.length} запитань',
                  Icons.groups,
                  () {
                    setState(() {
                      _category = id;
                      _page = _Page.rounds;
                    });
                    _updateBrowserPath('/categories/$id/rounds');
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
  Widget _rounds() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          _catalog!.inCategory(_category!).first.categoryName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      const SizedBox(height: 12),
      const Text('Обери раунд. Повторювати можна скільки завгодно.'),
      const SizedBox(height: 24),
      _roundPanel(),
    ],
  );
  Widget _roundPanel() {
    final rounds = _catalog!
        .inCategory(_category!)
        .map((q) => q.roundNumber)
        .toSet()
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rounds.map((round) {
        final questions = _catalog!.inRound(_category!, round);
        final progress = _progress.forRound(questions.first);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _tile(
            'Раунд $round',
            '${questions.first.roundTitle}\n${progress == null ? '${questions.length} запитань' : '${progress.last} із ${progress.total} · найкраще ${progress.best}'}${progress?.perfect == true ? ' · Без помилок' : ''}',
            progress?.perfect == true
                ? Icons.check_circle
                : Icons.play_circle_outline,
            () => _page == _Page.quiz ? _leave(_Page.rounds) : _start(round),
          ),
        );
      }).toList(),
    );
  }

  Widget _quiz() {
    final attempt = _attempt!;
    final q = attempt.current;
    final answered = attempt.lastCorrect != null;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Раунд ${q.roundNumber} · ${q.roundTitle}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text('Запитання ${attempt.number} із ${attempt.total}'),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: attempt.number / attempt.total,
            semanticsLabel: 'Прогрес раунду',
            semanticsValue:
                '${(attempt.number * 100 / attempt.total).round()}%',
            color: ink,
            backgroundColor: const Color(0xFFFFF3BD),
          ),
          const SizedBox(height: 32),
          Semantics(
            header: true,
            child: Text(
              q.text,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical =
                  MediaQuery.textScalerOf(context).scale(1) > 1.5 ||
                  constraints.maxWidth < 240;
              Widget button(String text, bool answer, Color color) =>
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 60),
                    ),
                    onPressed: answered ? null : () => _answer(answer),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
              return vertical
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        button('Ні', false, red),
                        const SizedBox(height: 12),
                        button('Так', true, green),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: button('Ні', false, red)),
                        const SizedBox(width: 16),
                        Expanded(child: button('Так', true, green)),
                      ],
                    );
            },
          ),
          if (answered) ...[
            const SizedBox(height: 24),
            Semantics(
              liveRegion: true,
              child: Text(
                attempt.lastCorrect! ? 'Правильно!' : 'Спробуймо розібратися',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (!attempt.lastCorrect! && _settingsState.explanations)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  q.explanation,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _next,
              child: Text(
                attempt.number == attempt.total ? 'Завершити раунд' : 'Далі',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _result() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _attempt!.score == _attempt!.total
              ? Icons.check_circle
              : Icons.auto_awesome,
          size: 56,
          color: green,
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            'Раунд завершено',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_attempt!.score} із ${_attempt!.total}',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        Text(_phrase, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => _start(_attempt!.current.roundNumber),
              child: const Text('Повторити'),
            ),
            OutlinedButton(
              onPressed: () => _go(_Page.rounds),
              child: const Text('До раундів'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _progressSaveFailed
              ? 'Прогрес залишився лише до закриття застосунку.'
              : 'Прогрес збережено на цьому пристрої.',
        ),
      ],
    ),
  );
  Widget _invalidRoute() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Посилання недійсне',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Категорію або раунд не знайдено. Оберіть доступну категорію.',
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => _go(_Page.categories),
          child: const Text('До категорій'),
        ),
      ],
    ),
  );
  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: ink, width: 1.3),
    ),
    child: child,
  );
  Widget _tile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFFE2DEC9)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: ink),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    ),
  );
}

class _SettingsPanel extends StatefulWidget {
  const _SettingsPanel({
    required this.initialSettings,
    required this.onChanged,
  });

  final AppSettings initialSettings;
  final Future<void> Function(AppSettings settings) onChanged;

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _change(AppSettings settings) {
    setState(() => _settings = settings);
    unawaited(widget.onChanged(settings));
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Налаштування',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Пояснювати помилки'),
          value: _settings.explanations,
          onChanged: (value) =>
              _change(_settings.copyWith(explanations: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Перемішувати запитання'),
          subtitle: const Text('Застосовується до нової спроби.'),
          value: _settings.shuffle,
          onChanged: (value) => _change(_settings.copyWith(shuffle: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Звукові ефекти'),
          subtitle: const Text('Використовуються там, де підтримуються.'),
          value: _settings.sound,
          onChanged: (value) => _change(_settings.copyWith(sound: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Вібрація при помилці'),
          subtitle: const Text('Залежить від можливостей пристрою.'),
          value: _settings.vibration,
          onChanged: (value) => _change(_settings.copyWith(vibration: value)),
        ),
        const SizedBox(height: 12),
        const Text('Налаштування зберігаються на цьому пристрої.'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Готово'),
        ),
      ],
    ),
  );
}
