import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'data/content_repository.dart';
import 'domain/catalog.dart';
import 'domain/quiz.dart';

const yellow = Color(0xFFF5C928),
    ink = Color(0xFF181818),
    paper = Color(0xFFFFFDF5);
const green = Color(0xFF247A43), red = Color(0xFFB73535);
typedef CatalogLoader = Future<Catalog> Function();

class QuizApp extends StatelessWidget {
  const QuizApp({super.key, this.loadCatalog});
  final CatalogLoader? loadCatalog;
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
    home: QuizHome(loadCatalog: loadCatalog ?? ContentRepository().load),
  );
}

enum _Page { welcome, categories, rounds, quiz, result }

class QuizHome extends StatefulWidget {
  const QuizHome({super.key, required this.loadCatalog});
  final CatalogLoader loadCatalog;
  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  Catalog? _catalog;
  bool _loading = true, _failed = false, _shuffle = false, _explanations = true;
  _Page _page = _Page.welcome;
  String? _category;
  QuizAttempt? _attempt;
  final _progress = SessionProgress();
  String _phrase = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final catalog = await widget.loadCatalog();
      if (mounted) {
        setState(() {
          _catalog = catalog;
          _loading = false;
        });
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

  void _go(_Page page) => setState(() => _page = page);
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

  void _start(int round) => setState(() {
    _attempt = QuizAttempt(
      _catalog!.inRound(_category!, round),
      shuffle: _shuffle,
    );
    _page = _Page.quiz;
  });
  void _answer(bool value) => setState(() => _attempt!.submit(value));
  void _next() => setState(() {
    _attempt!.next();
    if (_attempt!.finished) {
      _progress.record(_attempt!);
      _page = _Page.result;
      const phrases = [
        'Кожна спроба допомагає вчитися.',
        'Дякуємо за уважність до інших.',
        'Нові знання починаються з цікавості.',
      ];
      _phrase = phrases[Random().nextInt(phrases.length)];
    }
  });
  Future<void> _settings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, refresh) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Налаштування',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Пояснювати помилки'),
                    value: _explanations,
                    onChanged: (value) {
                      setState(() => _explanations = value);
                      refresh(() {});
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Перемішувати запитання'),
                    subtitle: const Text('Застосовується до нової спроби.'),
                    value: _shuffle,
                    onChanged: (value) {
                      setState(() => _shuffle = value);
                      refresh(() {});
                    },
                  ),
                  const SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Звукові ефекти'),
                    subtitle: Text('Ще недоступні в цій версії.'),
                    value: false,
                    onChanged: null,
                  ),
                  const SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Вібрація при помилці'),
                    subtitle: Text('Ще недоступна в цій версії.'),
                    value: false,
                    onChanged: null,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Налаштування та прогрес діють до закриття застосунку.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Готово'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canBack = _page != _Page.welcome;
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
          title: const Text(
            'Дія Ми',
            style: TextStyle(fontWeight: FontWeight.w800),
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
          const Text(
            'Не вдалося завантажити матеріали',
            textAlign: TextAlign.center,
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
    }
  }

  Widget _welcome() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.diversity_3, size: 56, color: ink),
        const SizedBox(height: 24),
        Text(
          'Різні люди.\nСпільний світ.',
          style: Theme.of(context).textTheme.headlineLarge,
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
      Text(
        'Для кого ця гра?',
        style: Theme.of(context).textTheme.headlineLarge,
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
      Text(
        _catalog!.inCategory(_category!).first.categoryName,
        style: Theme.of(context).textTheme.headlineSmall,
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
            color: ink,
            backgroundColor: const Color(0xFFFFF3BD),
          ),
          const SizedBox(height: 32),
          Text(
            q.text,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(height: 1.4),
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
            if (!attempt.lastCorrect! && _explanations)
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
        Text(
          'Раунд завершено',
          style: Theme.of(context).textTheme.headlineSmall,
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
        const Text('Прогрес цієї сесії збережено до закриття застосунку.'),
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
