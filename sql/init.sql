CREATE TABLE user(
    userId TEXT PRIMARY KEY,
    email TEXT,
    firstName TEXT,
    lastName TEXT,
    phone TEXT,
    sync INTEGER DEFAULT false,
    password BLOB,
    salt BLOB,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);
--
CREATE UNIQUE INDEX user_email on user(email);
--
CREATE TRIGGER user_update AFTER UPDATE ON user
BEGIN
    UPDATE user SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE category(
    title TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    icon TEXT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (userId) REFERENCES user(userId) ON DELETE CASCADE
);
--
CREATE TRIGGER category_update AFTER UPDATE ON category
BEGIN
    UPDATE category SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise(
    exerciseId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    category TEXT DEFAULT "" NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL DEFAULT "",
    type INTEGER DEFAULT 0 NOT NULL,
    sets INTEGER NOT NULL,
    reps INTEGER DEFAULT 0 NOT NULL,
    time INTEGER DEFAULT 0 NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (userId) REFERENCES user(userId) ON DELETE CASCADE
);
--
CREATE INDEX exercise_category ON exercise(category);
--
CREATE TRIGGER exercise_update AFTER UPDATE ON exercise
BEGIN
    UPDATE exercise SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise_set(
    exerciseSetId TEXT PRIMARY KEY,
    workoutId TEXT NOT NULL,
    workoutExerciseId TEXT NOT NULL,
    parentId TEXT NOT NULL,
    childId TEXT NOT NULL,
    exerciseOrder INTEGER NOT NULL,
    sets INTEGER NOT NULL,
    reps INTEGER DEFAULT 0 NOT NULL,
    time INTEGER DEFAULT 0 NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (workoutId) REFERENCES workout(workoutId) ON DELETE CASCADE,
    FOREIGN KEY (workoutExerciseId) REFERENCES workout_exercise(workoutExerciseId) ON DELETE CASCADE,
    FOREIGN KEY (parentId) REFERENCES exercise(exerciseId) ON DELETE CASCADE,
    FOREIGN KEY (childId) REFERENCES exercise(exerciseId) ON DELETE CASCADE
);
--
CREATE INDEX exercise_set_workout ON exercise_set(workoutId);
--
CREATE INDEX exercise_set_we ON exercise_set(workoutExerciseId);
--
CREATE INDEX exercise_set_parent ON exercise_set(parentId);
--
CREATE TRIGGER exercise_set_update AFTER UPDATE ON exercise_set
BEGIN
    UPDATE exercise_set SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE workout(
    workoutId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL DEFAULT "",
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (userId) REFERENCES user(userId) ON DELETE CASCADE
);
--
CREATE TRIGGER workout_update AFTER UPDATE ON workout
BEGIN
    UPDATE workout SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE workout_exercise(
    workoutExerciseId TEXT PRIMARY KEY,
    workoutId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    exerciseOrder INTEGER NOT NULL,
    sets INTEGER NOT NULL,
    reps INTEGER DEFAULT 0 NOT NULL,
    time INTEGER DEFAULT 0 NOT NULL,
    note TEXT,
    superSetOrdering INTEGER DEFAULT 0 NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (workoutId) REFERENCES workout(workoutId) ON DELETE CASCADE,
    FOREIGN KEY (exerciseId) REFERENCES exercise(exerciseId) ON DELETE CASCADE
);
--
CREATE INDEX workout_exercise_parent ON workout_exercise(workoutId);
--
CREATE TRIGGER workout_exercise_update AFTER UPDATE ON workout_exercise
BEGIN
    UPDATE workout_exercise SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise_log(
    exerciseLogId TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    userId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    parentId TEXT,
    workoutLogId TEXT,
    type INTEGER DEFAULT 0 NOT NULL,
    sets INTEGER NOT NULL,
    reps TEXT DEFAULT "" NOT NULL,
    time TEXT DEFAULT "" NOT NULL,
    weight TEXT DEFAULT "" NOT NULL,
    weightPost TEXT DEFAULT "lbs" NOT NULL,
    note TEXT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (userId) REFERENCES user(userId) ON DELETE CASCADE,
    FOREIGN KEY (exerciseId) REFERENCES exercise(exerciseId) ON DELETE CASCADE,
    FOREIGN KEY (workoutLogId) REFERENCES workout_log(workoutLogId)
);

--
CREATE INDEX exercise_log_exerciseid ON exercise_log(exerciseId);
--
CREATE INDEX exercise_log_userid ON exercise_log(userId);
--
CREATE INDEX exercise_log_workoutlogid ON exercise_log(workoutLogId);
--
CREATE TRIGGER exercise_log_update AFTER UPDATE ON exercise_log
BEGIN
    UPDATE exercise_log SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE workout_log(
    workoutLogId TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    workoutId TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    duration INTEGER DEFAULT 0 NOT NULL, /* duration in seconds */
    note TEXT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (userId) REFERENCES user(userId) ON DELETE CASCADE,
    FOREIGN KEY (workoutId) REFERENCES workout(workoutId) ON DELETE CASCADE
);
--
CREATE INDEX workout_log_userid ON workout_log(userId);
--
CREATE INDEX workout_log_workoutid ON workout_log(workoutId);
--
CREATE TRIGGER workout_log_update AFTER UPDATE ON workout_log
BEGIN
    UPDATE workout_log SET updated = CURRENT_TIMESTAMP;
END;