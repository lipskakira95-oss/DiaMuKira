class AppSettings {
  const AppSettings({
    required this.explanations,
    required this.sound,
    required this.vibration,
    required this.shuffle,
  });

  const AppSettings.defaults()
    : explanations = true,
      sound = false,
      vibration = false,
      shuffle = false;

  final bool explanations;
  final bool sound;
  final bool vibration;
  final bool shuffle;

  AppSettings copyWith({
    bool? explanations,
    bool? sound,
    bool? vibration,
    bool? shuffle,
  }) => AppSettings(
    explanations: explanations ?? this.explanations,
    sound: sound ?? this.sound,
    vibration: vibration ?? this.vibration,
    shuffle: shuffle ?? this.shuffle,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.explanations == explanations &&
      other.sound == sound &&
      other.vibration == vibration &&
      other.shuffle == shuffle;

  @override
  int get hashCode => Object.hash(explanations, sound, vibration, shuffle);
}

class SavedRoundProgress {
  const SavedRoundProgress({
    required this.contentVersion,
    required this.categoryId,
    required this.roundNumber,
    required this.lastScore,
    required this.bestScore,
    required this.total,
  });

  final String contentVersion;
  final String categoryId;
  final int roundNumber;
  final int lastScore;
  final int bestScore;
  final int total;

  String get key => '$contentVersion/$categoryId/$roundNumber';
  bool get perfect => bestScore == total;

  @override
  bool operator ==(Object other) =>
      other is SavedRoundProgress &&
      other.contentVersion == contentVersion &&
      other.categoryId == categoryId &&
      other.roundNumber == roundNumber &&
      other.lastScore == lastScore &&
      other.bestScore == bestScore &&
      other.total == total;

  @override
  int get hashCode => Object.hash(
    contentVersion,
    categoryId,
    roundNumber,
    lastScore,
    bestScore,
    total,
  );
}

class CachedContent {
  const CachedContent({
    required this.version,
    required this.mode,
    required this.json,
  });

  final String version;
  final String mode;
  final String json;

  @override
  bool operator ==(Object other) =>
      other is CachedContent &&
      other.version == version &&
      other.mode == mode &&
      other.json == json;

  @override
  int get hashCode => Object.hash(version, mode, json);
}

abstract interface class UserStore {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<List<SavedRoundProgress>> loadProgress(String contentVersion);
  Future<void> saveCompletedAttempt(SavedRoundProgress progress);
  Future<CachedContent?> loadContent();
  Future<void> saveContent(CachedContent content);
  Future<void> close();
}
