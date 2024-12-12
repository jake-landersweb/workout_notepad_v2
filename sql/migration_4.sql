CREATE TABLE IF NOT EXISTS workout_template(
    id INT NOT NULL AUTO_INCREMENT,
    workout_id VARCHAR(36) NOT NULL,
    title VARCHAR(256) NOT NULL DEFAULT '',
    description TEXT,
    keywords TEXT,
    metadata JSON,
    level VARCHAR(32),
    est_time VARCHAR(20),
    background_color VARCHAR(7),
    image_id VARCHAR(36),
    sha_256 VARCHAR(64),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    PRIMARY KEY (id),
    UNIQUE INDEX (workout_id);
);
--
CREATE TABLE IF NOT EXISTS workout_template_exercise(
    id INT NOT NULL AUTO_INCREMENT,
    workout_template_id INT NOT NULL,
    exercise_id VARCHAR(36) NOT NULL,
    
    exercise_order INT NOT NULL,
    superset_id VARCHAR(36) NOT NULL,
    superset_order INT NOT NULL,
    sets INT NOT NULL,
    reps INT NOT NULL,
    time INT NOT NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    FOREIGN KEY (workout_template_id) REFERENCES workout_template (id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercise (id) ON DELETE CASCADE
) ENGINE=InnoDB;
--
ALTER TABLE workout
ADD COLUMN workout_template_id INT REFERENCES workout_template (id) ON DELETE SET NULL;
--
