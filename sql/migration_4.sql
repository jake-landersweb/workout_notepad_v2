CREATE TABLE IF NOT EXISTS workout_template (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workoutId TEXT NOT NULL,
    title TEXT NOT NULL DEFAULT '',
    description TEXT,
    keywords TEXT,
    metadata JSON,
    level TEXT,
    estTime TEXT,
    backgroundColor TEXT,
    imageId TEXT,
    sha256 TEXT,

    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    UNIQUE (workoutId)
);
--
CREATE TABLE IF NOT EXISTS workout_template_exercise (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workoutTemplateId INTEGER NOT NULL,
    exerciseId TEXT NOT NULL,

    exerciseOrder INTEGER NOT NULL,
    supersetId TEXT NOT NULL,
    supersetOrder INTEGER NOT NULL,
    sets INTEGER NOT NULL,
    reps INTEGER NOT NULL,
    time INTEGER NOT NULL,

    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (workoutTemplateId) REFERENCES workout_template (id) ON DELETE CASCADE,
    FOREIGN KEY (exerciseId) REFERENCES exercise (exerciseId) ON DELETE CASCADE
);
