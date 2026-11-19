# Android-застосунок

## Підтримувані версії та склад

| Параметр | Значення |
| --- | --- |
| Application ID | `ua.diiamy.diia_my` |
| Назва | `Дія Ми` |
| Мінімальний Android | API 24 (Android 7.0) |
| Target / compile SDK | API 36 |
| Локальна база | Drift поверх SQLite |
| Архітектури debug APK | `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| API | `--dart-define=API_BASE_URL=https://example.org`; без API використовується набір зі збірки |

Звичайний Android manifest забороняє незашифрований HTTP. Debug manifest дозволяє його для локального емулятора, де Go API на комп'ютері доступний як `http://10.0.2.2:8080`. Production API має використовувати HTTPS.

## Проєктні інструменти

На перевіреній Windows-машині Flutter зберігається в `.local/tools/flutter`, Android SDK — у `.local/tools/android-sdk`, Gradle — у `.local/cache/gradle`. Для native SQLite потрібні NDK r28c (`28.2.13676358`) і CMake 3.22.1. Локальні SDK та результати складання ігноруються Git.

Після `flutter pub get` debug APK складається з кореня репозиторію:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-android.ps1 -Mode debug
```

Для доступного HTTPS API:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-android.ps1 -Mode release -ApiBaseUrl https://example.org
```

Release-варіант зараз підписується тестовим debug-ключем Flutter і не придатний для Google Play. На етапі випуску потрібні окремий upload key, GitHub Secret та Android App Bundle.

## Перевірки

Widget-тести перевіряють компонування 360×800 із масштабом тексту 200%, довгі тексти, повноекранні налаштування та системне повернення з підтвердженням виходу. Інтеграційний smoke проходить сім запитань із набору в APK, повторно відкриває SQLite та перевіряє збережений прогрес:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/smoke-android.ps1
```

Команда потребує запущеного Android-емулятора або телефона з увімкненим USB debugging. Вібрацію, реальний звук і TalkBack остаточно перевіряють на фізичному пристрої.
