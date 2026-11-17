# Початок розробки

Реалізовано SQLite-каталог, Go API та перший Flutter-клієнт для проходження раундів. Платформні проєкти Android/iOS створено, але їхні нативні збірки ще не перевірено. Клієнтська Drift-база, постійний прогрес, звук і вібрація — наступні кроки. [Статус матеріалів](../content/README.md) та [архітектура бази](database.md).

## Flutter та веб

Використовується Flutter 3.50.0 / Dart 3.14.0. SDK скопійовано в `.local/tools/flutter`; проєктні Pub/Gradle/Go-кеші налаштовуються wrapper-скриптами. Для першого налаштування на іншому Windows-комп’ютері:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap-flutter.ps1 -SourceSdk C:/path/to/flutter
```

`SourceSdk` — фактична папка вже встановленого SDK; приклад потрібно замінити. На CI SDK клонується з офіційного Flutter tag 3.50.0 прямо в проєкт. Далі з кореня:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-content.ps1
```

Із `apps/quiz` завантажити пакети через `../../scripts/flutter.ps1 pub get` у новому PowerShell-процесі з process-only Bypass або запускати wrapper як у наступному прикладі:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ../../scripts/flutter.ps1 pub get
powershell -NoProfile -ExecutionPolicy Bypass -File ../../scripts/flutter.ps1 analyze --no-pub
```

Із кореня виконати:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-flutter.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-web.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/serve-web.ps1
```

Потім відкрити `http://127.0.0.1:8080/`. Go одночасно видає API і зібрану вебверсію; окремого вебсервера не потрібно. Для Flutter dev-сервера на `http://localhost:5173` запустити API з `-dev-origin http://localhost:5173` і Flutter з `--dart-define=API_BASE_URL=http://127.0.0.1:8080`. Для мобільних пристроїв вказати доступний HTTPS API через цей самий параметр; без доступного API завантажується набір зі збірки.

Є сценарій початку, вибору категорії/раунду, відповідей, пояснення, результату, повтору та підтвердження виходу. Порядок можна перемішати. Галочка показує найкращий безпомилковий результат цієї сесії; постійне збереження ще не реалізовано. Глибоке посилання обслуговується вебсервером, але відновлення конкретного екрана через URL у Flutter ще попереду. Офлайн-проходження з bundled-набором не означає повного офлайн-першого завантаження вебсайту.

Для браузерного smoke потрібен установлений Chrome; Go-залежності тесту й профіль браузера залишаються в проєкті:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/browser-dependencies.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/smoke-browser.ps1
```

Chrome-шлях і URL можна перевизначити параметрами `-Chrome` та `-Url`. Android/iPhone потребують окремих SDK, пристроїв і подальших нативних перевірок; Windows не підтверджує готовність iOS.

## Go API та SQLite

Потрібен Go 1.27 або новіший; зараз використано Go 1.27.4. У PowerShell із кореня репозиторію:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/smoke-api.ps1
```

`-ExecutionPolicy Bypass` застосовується лише до цього процесу PowerShell; глобальну політику система не змінює. Wrapper налаштовує локальні кеші до Go-команд. При першому запуску потрібен доступ до мережі для завантаження залежностей із зафіксованими версіями.

Після збірки створити локальну базу та запустити API:

```powershell
.local/build/contentimport.exe -csv content/questions.uk.csv -db .local/data/quiz.sqlite
.local/build/api.exe -db .local/data/quiz.sqlite -addr 127.0.0.1:8080 -allow-draft
```

Адреси: `GET /health`, `GET /api/v1/content/version`, `GET /api/v1/content`. Сервер за замовчуванням слухає лише loopback. `-allow-draft` потрібен для поточного неперевіреного набору. Production-імпорт `contentimport.exe ... -production` відхиляє його; production-сервер без `-allow-draft` теж не стартує з draft-каталогом. Не перейменовувати чернетки в approved лише заради проходження перевірки.

Тести включають читання CSV, BOM, некоректні відповіді, дублікати, розподіл раундів, збереження після закриття, production guard та HTTP-коди. Smoke створює справжню SQLite-БД, запускає зібраний сервер на тимчасовому локальному порту, перевіряє 152 записи й завершує лише створений ним процес.

Для 3-хвилинного журналу під час активного сеансу оновлювати `.local/progress/state.json` і запускати:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/progress.ps1
```

Формат стану: `{"stage":"02","status":"Опис поточної дії","stop":false}`. Для завершення встановити `stop: true`. Скрипт записує час, стан і фактичний розмір проєктного кешу; не вигадує токени й RAM. Він друкує в термінал і локальний журнал, а не самостійно створює повідомлення в чаті після завершення сеансу.
