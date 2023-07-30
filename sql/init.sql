CREATE TABLE category(
    categoryId TEXT PRIMARY KEY,
    title TEXT,
    icon TEXT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);
--
CREATE TRIGGER category_update AFTER UPDATE ON category
BEGIN
    UPDATE category SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise(
    exerciseId TEXT PRIMARY KEY,
    category TEXT DEFAULT "" NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL DEFAULT "",
    type INTEGER DEFAULT 0 NOT NULL,
    sets INTEGER NOT NULL,
    reps INTEGER DEFAULT 0 NOT NULL,
    time INTEGER DEFAULT 0 NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);
--
CREATE INDEX exercise_category ON exercise(category);
--
CREATE TRIGGER exercise_update AFTER UPDATE ON exercise
BEGIN
    UPDATE exercise SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise_detail(
    exerciseId TEXT PRIMARY KEY,
    objectId TEXT NOT NULL,
    description TEXT NOT NULL,
    difficultyLevel TEXT NOT NULL,
    equipmentNeeded TEXT NOT NULL,
    restTime INTEGER DEFAULT 60 NOT NULL,
    cues TEXT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (exerciseId) REFERENCES exercise(exerciseId) ON DELETE CASCADE
);
--
CREATE TRIGGER exercise_detail_update AFTER UPDATE ON exercise_detail
BEGIN
    UPDATE exercise_detail SET updated = CURRENT_TIMESTAMP;
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
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL DEFAULT "",
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
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
CREATE TABLE workout_log(
    workoutLogId TEXT PRIMARY KEY,
    workoutId TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    duration INTEGER DEFAULT 0 NOT NULL, /* duration in seconds */
    note TEXT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (workoutId) REFERENCES workout(workoutId) ON DELETE SET NULL
);
--
CREATE INDEX workout_log_workoutid ON workout_log(workoutId);
--
CREATE TRIGGER workout_log_update AFTER UPDATE ON workout_log
BEGIN
    UPDATE workout_log SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise_log(
    exerciseLogId TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT "",
    exerciseId TEXT NOT NULL,
    parentId TEXT,
    workoutLogId TEXT,
    type INTEGER DEFAULT 0 NOT NULL,
    sets INTEGER NOT NULL,
    note TEXT,
    isSuperSet BOOLEAN NOT NULL DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (exerciseId) REFERENCES exercise(exerciseId) ON DELETE CASCADE,
    FOREIGN KEY (workoutLogId) REFERENCES workout_log(workoutLogId)
);
--
CREATE INDEX exercise_log_exerciseid ON exercise_log(exerciseId);
--
CREATE INDEX exercise_log_workoutlogid ON exercise_log(workoutLogId);
--
CREATE TRIGGER exercise_log_update AFTER UPDATE ON exercise_log
BEGIN
    UPDATE exercise_log SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise_log_meta(
    exerciseLogMetaId TEXT PRIMARY KEY,
    exerciseLogId TEXT NOT NULL,
    exerciseId TEXT NOT NULL,
    reps INTEGER NOT NULL,
    time INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    weightPost TEXT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (exerciseLogId) REFERENCES exercise_log(exerciseLogId) ON DELETE CASCADE,
    FOREIGN KEY (exerciseId) REFERENCES exercise(exerciseId) ON DELETE CASCADE
);
--
CREATE INDEX exericse_log_meta_exerciselogid ON exercise_log_meta(exerciseLogId);
--
CREATE INDEX exericse_log_meta_exerciseid ON exercise_log_meta(exerciseId);
--
CREATE TABLE tag(
    tagId TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    isDefault BOOLEAN DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);
--
CREATE INDEX tag_tagid ON tag(tagId);
--
CREATE TRIGGER tag_update AFTER UPDATE ON tag
BEGIN
    UPDATE tag SET updated = CURRENT_TIMESTAMP;
END;
--
CREATE TABLE exercise_log_meta_tag(
    exerciseLogMetaTagId TEXT PRIMARY KEY,
    exerciseLogMetaId TEXT NOT NULL,
    exerciseLogId TEXT NOT NULL,
    tagId TEXT NOT NULL,
    sortPos INTEGER NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (exerciseLogMetaId) REFERENCES exercise_log_meta(exerciseLogMetaId),
    FOREIGN KEY (exerciseLogId) REFERENCES exercise_log(exerciseLogId),
    FOREIGN KEY (tagId) REFERENCES tag(tagId)
);
--
CREATE INDEX exercise_log_meta_tag_tagid ON exercise_log_meta_tag(tagId);
--
CREATE TABLE workout_snapshot(
    workoutSnapshotId TEXT PRIMARY KEY,
    workoutId TEXT NOT NULL,
    jsonData TEXT NOT NULL,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    createdEpoch INTEGER NOT NULL,

    FOREIGN KEY (workoutId) REFERENCES workout(workoutId) ON DELETE CASCADE
);
--
CREATE INDEX workout_snapshot_workoutid ON workout_snapshot(workoutId);
--
CREATE TABLE device(
    deviceId TEXT PRIMARY KEY,
    deviceMake TEXT,
    deviceModel TEXT,
    deviveOs TEXT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    lastUsed DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);
/*
CREATE TABLE sync_log(
    syncId TEXT PRIMARY KEY,
    deviceId TEXT NOT NULL,
    syncStart DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    syncEnd DATETIME,
    syncStatus TEXT CHECK(syncStatus IN ('PENDING', 'SUCCESS', 'ERROR')) DEFAULT 'PENDING',
    errorDetails TEXT,
    numberOfTables INTEGER,
    numberOfRecords INTEGER,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (deviceId) REFERENCES device(deviceId)
);
CREATE TABLE deletion_log(
    deletionLogId TEXT PRIMARY KEY,
    tableName TEXT NOT NULL,
    recordId TEXT NOT NULL,
    deletedAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE INDEX deletion_log_deletedat ON deletion_log(deletedAt);
*/