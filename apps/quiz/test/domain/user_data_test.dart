import 'package:diia_my/domain/user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings have safe defaults and independent switches', () {
    const defaults = AppSettings.defaults();

    expect(defaults.explanations, isTrue);
    expect(defaults.sound, isFalse);
    expect(defaults.vibration, isFalse);
    expect(defaults.shuffle, isFalse);

    final changed = defaults.copyWith(sound: true, shuffle: true);
    expect(changed.explanations, isTrue);
    expect(changed.sound, isTrue);
    expect(changed.vibration, isFalse);
    expect(changed.shuffle, isTrue);
  });

  test('progress identity includes the content version', () {
    const first = SavedRoundProgress(
      contentVersion: 'v1',
      categoryId: 'children',
      roundNumber: 1,
      lastScore: 6,
      bestScore: 7,
      total: 7,
    );
    const nextVersion = SavedRoundProgress(
      contentVersion: 'v2',
      categoryId: 'children',
      roundNumber: 1,
      lastScore: 6,
      bestScore: 7,
      total: 7,
    );

    expect(first.key, isNot(nextVersion.key));
    expect(first.perfect, isTrue);
  });
}
