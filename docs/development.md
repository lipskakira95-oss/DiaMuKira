# Початок розробки

Реалізовано перший крок: 152 авторські чернетки в CSV, імпортер SQLite і Go API. Flutter-інтерфейси й клієнтську Drift-базу ще не реалізовано. [Статус матеріалів](../content/README.md) та [архітектура бази](database.md).

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
