import 'package:flutter/services.dart';

import '../domain/user_data.dart';

abstract interface class AnswerFeedback {
  Future<void> onAnswer({required bool correct, required AppSettings settings});
}

class FlutterAnswerFeedback implements AnswerFeedback {
  const FlutterAnswerFeedback();

  @override
  Future<void> onAnswer({
    required bool correct,
    required AppSettings settings,
  }) async {
    if (settings.sound) {
      await SystemSound.play(
        correct ? SystemSoundType.click : SystemSoundType.alert,
      );
    }
    if (!correct && settings.vibration) {
      await HapticFeedback.mediumImpact();
    }
  }
}
