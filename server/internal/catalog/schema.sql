CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL
);
CREATE TABLE rounds (
    category_id TEXT NOT NULL REFERENCES categories(id),
    number INTEGER NOT NULL CHECK(number BETWEEN 1 AND 4),
    title TEXT NOT NULL,
    PRIMARY KEY(category_id, number)
);
CREATE TABLE questions (
    id TEXT PRIMARY KEY,
    category_id TEXT NOT NULL,
    round_number INTEGER NOT NULL,
    position INTEGER NOT NULL CHECK(position > 0),
    text TEXT NOT NULL CHECK(length(trim(text)) > 0),
    correct_answer INTEGER NOT NULL CHECK(correct_answer IN (0,1)),
    explanation TEXT NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('draft','approved')),
    source TEXT NOT NULL,
    content_version TEXT NOT NULL,
    FOREIGN KEY(category_id, round_number) REFERENCES rounds(category_id, number),
    UNIQUE(category_id, round_number, position)
);
CREATE TABLE content_meta (
    id INTEGER PRIMARY KEY CHECK(id=1),
    version TEXT NOT NULL,
    mode TEXT NOT NULL CHECK(mode IN ('draft','production'))
);
PRAGMA user_version=1;
