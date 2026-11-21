import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';

void main() => runApp(QuizApp(initialPath: kIsWeb ? Uri.base.path : '/'));
