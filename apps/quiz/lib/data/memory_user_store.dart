import '../domain/user_data.dart';

class MemoryUserStore implements UserStore {
  MemoryUserStore({
    AppSettings settings = const AppSettings.defaults(),
    CachedContent? content,
    Iterable<SavedRoundProgress> progress = const [],
  }) {
    _settings = settings;
    _content = content;
    _progress.addEntries(progress.map((item) => MapEntry(item.key, item)));
  }

  late AppSettings _settings;
  CachedContent? _content;
  final Map<String, SavedRoundProgress> _progress = {};

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<List<SavedRoundProgress>> loadProgress(String contentVersion) async =>
      _progress.values
          .where((item) => item.contentVersion == contentVersion)
          .toList(growable: false);

  @override
  Future<void> saveCompletedAttempt(SavedRoundProgress progress) async {
    final previous = _progress[progress.key];
    _progress[progress.key] = SavedRoundProgress(
      contentVersion: progress.contentVersion,
      categoryId: progress.categoryId,
      roundNumber: progress.roundNumber,
      lastScore: progress.lastScore,
      bestScore: previous == null
          ? progress.bestScore
          : (previous.bestScore > progress.bestScore
                ? previous.bestScore
                : progress.bestScore),
      total: progress.total,
    );
  }

  @override
  Future<CachedContent?> loadContent() async => _content;

  @override
  Future<void> saveContent(CachedContent content) async {
    _content = content;
  }

  @override
  Future<void> close() async {}
}
