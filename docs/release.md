# Підготовка випуску «Дія Ми»

## Поточний статус

| Поле | Значення |
| --- | --- |
| Версія застосунку | `1.0.0+1` |
| Канал | `preview` |
| Вміст | `draft-1`, 152 позиції, 18 раундів |
| Production ready | Ні |
| Причина | Немає редакторського затвердження, production API та ключів підпису. |

Метадані зберігаються в [release.json](../release/release.json). Автоматичний тест звіряє їх із Flutter-версією та вбудованим каталогом. Змінювати `production_ready` на `true` можна лише після фактичного затвердження всіх матеріалів і проходження production validation.

## Веб

| Варіант | Команда |
| --- | --- |
| Preview лише з вбудованими даними | `./scripts/package-web.ps1 -OfflineOnly` |
| API на тому самому домені | `./scripts/package-web.ps1 -SameOriginApi` |
| Окремий HTTPS API | `./scripts/package-web.ps1 -ApiBaseUrl https://quiz.example.org` |

Скрипт створює ZIP і файл SHA-256 у `.local/release`. Перевірка саме ZIP-артефакту:

```powershell
./scripts/smoke-web-package.ps1 -Package .local/release/diia-my-web-1.0.0-1-preview.zip
```

Для production сервер спочатку отримує затверджену базу, після чого запускається без `-allow-draft`:

```powershell
.local/build/contentimport.exe -csv content/questions.uk.csv -db .local/data/quiz.sqlite -production
.local/build/api.exe -db .local/data/quiz.sqlite -web apps/quiz/build/web -addr 127.0.0.1:8080
```

Зовнішній reverse proxy має додати HTTPS. Перед оновленням потрібно зупинити API, зробити резервну копію SQLite та зберегти попередній вебартефакт для відкату.

## Android

Unsigned offline preview AAB:

```powershell
./scripts/build-android.ps1 -Mode release -Target appbundle -OfflineOnly
```

Для Google Play задайте секрети лише в локальному захищеному середовищі або GitHub Secrets:

| Змінна | Значення |
| --- | --- |
| `ANDROID_KEYSTORE_PATH` | Абсолютний шлях до upload keystore. |
| `ANDROID_KEYSTORE_PASSWORD` | Пароль сховища. |
| `ANDROID_KEY_ALIAS` | Назва ключа. |
| `ANDROID_KEY_PASSWORD` | Пароль ключа. |

Потім виконайте збірку з реальною HTTPS-адресою:

```powershell
./scripts/build-android.ps1 -Mode release -Target both -ApiBaseUrl https://quiz.example.org
```

Без усіх чотирьох змінних AAB навмисно лишається непідписаним. Debug-ключ більше не використовується для release.

## iPhone

Unsigned archive для технічної перевірки створює macOS CI:

```bash
./scripts/archive-ios.sh "" true
```

Для App Store потрібні Apple Developer Team, distribution certificate, App Store provisioning profile і реальна HTTPS-адреса:

```bash
./scripts/archive-ios.sh https://quiz.example.org false
```

Unsigned `.xcarchive` не встановлюється на звичайний iPhone і не завантажується в App Store Connect. Остаточний export IPA виконується в довіреному macOS-середовищі після налаштування підпису.

## Gate публічного випуску

| Перевірка | Поточний стан |
| --- | --- |
| 152 позиції схвалені редактором | BLOCKED |
| Production import | BLOCKED поточним `draft` |
| HTTPS production API | BLOCKED: адресу не надано |
| Android upload signing | BLOCKED: ключ не надано |
| Apple signing/export | BLOCKED: профіль і сертифікат не надані |
| Фізичний Android/iPhone smoke | NOT RUN |
| Автоматичний preview CI | Має пройти для конкретного SHA |

Публікація в магазинах або на зовнішньому сервері виконується лише після закриття всіх рядків `BLOCKED` і окремого перегляду остаточних артефактів.
