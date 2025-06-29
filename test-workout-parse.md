## Exploration of parsing workouts with AI

I found a random workout in my notes from a while ago that I jotted down:

```txt
Leg day

10 min warmup
Back squat
- 145x8
- 225x8
- 275x8x2
- 315x3
- 335x3

Deadlift
- 145x8
- 225x8
- 315x6x2
- 365x5
- 405x1

Sitting calves
- 3x15

Quad ladder
- 10 up 10 down

Hamstring curl
- 3x15

Plate press calves
- 2x10 outer
- 2x10 mid
- 2x10 inner

Hack squat
- 4x10
```

Lets feed it into AI and see if I can a decent output:

---

I have a workout I wrote down in my notes, and I want to convert it into a structured format.

Respond to this request in JSON

```
{raw}
```

---

Using o4-mini, I got:

```json
{
    "workoutName": "Leg day",
    "exercises": [
        {
            "name": "Warmup",
            "type": "time",
            "duration": {
                "value": 10,
                "unit": "minutes"
            }
        },
        {
            "name": "Back squat",
            "sets": [
                {
                    "weight_lbs": 145,
                    "reps": 8,
                    "sets": 1
                },
                {
                    "weight_lbs": 225,
                    "reps": 8,
                    "sets": 1
                },
                {
                    "weight_lbs": 275,
                    "reps": 8,
                    "sets": 2
                },
                {
                    "weight_lbs": 315,
                    "reps": 3,
                    "sets": 1
                },
                {
                    "weight_lbs": 335,
                    "reps": 3,
                    "sets": 1
                }
            ]
        },
        {
            "name": "Deadlift",
            "sets": [
                {
                    "weight_lbs": 145,
                    "reps": 8,
                    "sets": 1
                },
                {
                    "weight_lbs": 225,
                    "reps": 8,
                    "sets": 1
                },
                {
                    "weight_lbs": 315,
                    "reps": 6,
                    "sets": 2
                },
                {
                    "weight_lbs": 365,
                    "reps": 5,
                    "sets": 1
                },
                {
                    "weight_lbs": 405,
                    "reps": 1,
                    "sets": 1
                }
            ]
        },
        {
            "name": "Sitting calves",
            "sets": [
                {
                    "reps": 15,
                    "sets": 3
                }
            ]
        },
        {
            "name": "Quad ladder",
            "pattern": [
                {
                    "direction": "up",
                    "reps": 10
                },
                {
                    "direction": "down",
                    "reps": 10
                }
            ]
        },
        {
            "name": "Hamstring curl",
            "sets": [
                {
                    "reps": 15,
                    "sets": 3
                }
            ]
        },
        {
            "name": "Plate press calves",
            "variations": [
                {
                    "position": "outer",
                    "sets": 2,
                    "reps": 10
                },
                {
                    "position": "mid",
                    "sets": 2,
                    "reps": 10
                },
                {
                    "position": "inner",
                    "sets": 2,
                    "reps": 10
                }
            ]
        },
        {
            "name": "Hack squat",
            "sets": [
                {
                    "reps": 10,
                    "sets": 4
                }
            ]
        }
    ]
}
```

Now lets feed in some more information about the app's data custom data format:

---

I want to convert a plain text workout into fitting into an existing schema I have already created. I do not want to modify the schema, I would rather fit the workout into this schema.

In addition, there are some interesting ways in which this schema interacts with each other, but we can cover this later. Here is the schema:


First we have the workout table. This is just metadata about a workout:

```sql
CREATE TABLE IF NOT EXISTS workout_template (
    id INTEGER PRIMARY KEY,
    workoutId TEXT NOT NULL,
    title TEXT NOT NULL DEFAULT '',
    description TEXT,
    keywords TEXT,
    metadata JSON,
    level TEXT,
    estTime TEXT,
    backgroundColor TEXT,
    imageId TEXT,
    sha256 TEXT NOT NULL,

    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    UNIQUE (workoutId)
);
```

Then, each workout has a list of exercises attached to it:

```sql
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
```

If a workout is a super-set, then we want to use a supersetId to link them together, along with the supersetOrder.

But to actually log a workout, we store this information into another table.

For workouts, we store some metadata about this exercise like letting the user set a custom title, the duration, etc.

```sql
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
```

Then, for each exercise, we have the following:

An exercise log record:

```sql
CREATE TABLE exercise_log(
    exerciseLogId TEXT PRIMARY KEY,
    exerciseId TEXT NOT NULL,
    workoutExerciseId TEXT,
    exerciseOrder INTEGER DEFAULT 0,
    supersetId TEXT,
    supersetOrder INTEGER DEFAULT 0,
    workoutLogId TEXT,
    
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT "",
    type INTEGER DEFAULT 0 NOT NULL,
    sets INTEGER NOT NULL,
    note TEXT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (exerciseId) REFERENCES exercise(exerciseId) ON DELETE CASCADE,
    FOREIGN KEY (workoutLogId) REFERENCES workout_log(workoutLogId)
);
```

And a list of metadata records that represent each instance of an exercise being performed. Such that if we have 4 sets of 12 for an exercise, there will be 4 metadata records.

```sql
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
```

Lastly, it should be noted that the `reps`, `time`, and `weight` for the `exercise` record is simply the suggestion. The actual performed amount will be on the `exercise_log_meta`.

With this information, I want you to convert a text-based workout for me into this structure. I want you to respond in a JSON schema with the table names representing the root keys, and lists of JSON objects representing the items that will be inserted into the database.

Here is the raw text workout:

```txt
Leg day

10 min warmup
Back squat
- 145x8
- 225x8
- 275x8x2
- 315x3
- 335x3

Deadlift
- 145x8
- 225x8
- 315x6x2
- 365x5
- 405x1

Sitting calves
- 3x15

Quad ladder
- 10 up 10 down

Hamstring curl
- 3x15

Plate press calves
- 2x10 outer
- 2x10 mid
- 2x10 inner

Hack squat
- 4x10
```

---

o4-mini gave me the following output:

```json
{
  "workout_template": [
    {
      "id": 1,
      "workoutId": "leg_day",
      "title": "Leg day",
      "description": "",
      "keywords": null,
      "metadata": null,
      "level": null,
      "estTime": null,
      "backgroundColor": null,
      "imageId": null,
      "sha256": ""
    }
  ],
  "workout_template_exercise": [
    {
      "workoutTemplateId": 1,
      "exerciseId": "warmup",
      "exerciseOrder": 1,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 1,
      "reps": 0,
      "time": 600
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "back_squat",
      "exerciseOrder": 2,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 6,
      "reps": 8,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "deadlift",
      "exerciseOrder": 3,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 6,
      "reps": 8,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "sitting_calves",
      "exerciseOrder": 4,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 3,
      "reps": 15,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "quad_ladder",
      "exerciseOrder": 5,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 1,
      "reps": 20,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "hamstring_curl",
      "exerciseOrder": 6,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 3,
      "reps": 15,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "plate_press_calves_outer",
      "exerciseOrder": 7,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 2,
      "reps": 10,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "plate_press_calves_mid",
      "exerciseOrder": 8,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 2,
      "reps": 10,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "plate_press_calves_inner",
      "exerciseOrder": 9,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 2,
      "reps": 10,
      "time": 0
    },
    {
      "workoutTemplateId": 1,
      "exerciseId": "hack_squat",
      "exerciseOrder": 10,
      "supersetId": "",
      "supersetOrder": 0,
      "sets": 4,
      "reps": 10,
      "time": 0
    }
  ]
}
```

This did not work. I am sure with more prompt tuning this can work, but because the initial output was so far off we need to simplify this approach.

Creating a simple schema that we can create relationships with will be better. Using typescript will be good for the model, as it was trained heavily on this language and is very similar to the JSON output I want out.

---

I want to convert a text-based workout into a structured workout format. Here is the format that I want you to follow:

```typescript
type Workout = {
    // a human-readable title for the workout
    title: string

    // duration in seconds
    duration?: int

    // a list of exercises performed in this workout
    // 2D array allows for super-sets
    // I.E a single exercise will be the only record in the second array
    // A super-set will have multiple items in the second array
    exercises: Exercise[][]
}

enum ExerciseType {
    weighted = 0, // using weights
    bodyweight, // only using the body weight
    count_up, // a timer that counts up
    count_down, // a timer that counts down

}

type Exercise = {
    // a human readable title for the exercise
    title: string
    
    // type of this exercise to properly render the UI
    type: ExerciseType

    // the total number of sets performed
    sets: number

    // list of rep values performed in this exercise
    reps: number[]

    // list of weight values performed in this exercise
    weight: number[]

    // list of time values performed in this exercise (in seconds)
    time: number[]
}

type AIModelResponse = {
    workout: Workout
}
```

Here is the text workout:

```text
Leg day

10 min warmup
Back squat
- 145x8
- 225x8
- 275x8x2
- 315x3
- 335x3

Deadlift
- 145x8
- 225x8
- 315x6x2
- 365x5
- 405x1

Sitting calves
- 3x15

Quad ladder
- 10 up 10 down

Hamstring curl
- 3x15

Plate press calves
- 2x10 outer
- 2x10 mid
- 2x10 inner

Hack squat
- 4x10
```

Please respond as a JSON object following the schema of the `AIModelResponse` type.

---

and the response (o4-mini)

```json
{
  "workout": {
    "title": "Leg day",
    "duration": 3600,
    "exercises": [
      [
        {
          "title": "Warmup",
          "type": 3,
          "sets": 1,
          "reps": [],
          "weight": [],
          "time": [600]
        }
      ],
      [
        {
          "title": "Back squat",
          "type": 0,
          "sets": 6,
          "reps": [8, 8, 8, 8, 3, 3],
          "weight": [145, 225, 275, 275, 315, 335],
          "time": []
        }
      ],
      [
        {
          "title": "Deadlift",
          "type": 0,
          "sets": 6,
          "reps": [8, 8, 6, 6, 5, 1],
          "weight": [145, 225, 315, 315, 365, 405],
          "time": []
        }
      ],
      [
        {
          "title": "Sitting calves",
          "type": 1,
          "sets": 3,
          "reps": [15, 15, 15],
          "weight": [0, 0, 0],
          "time": []
        }
      ],
      [
        {
          "title": "Quad ladder",
          "type": 2,
          "sets": 1,
          "reps": [10, 10],
          "weight": [0, 0],
          "time": []
        }
      ],
      [
        {
          "title": "Hamstring curl",
          "type": 1,
          "sets": 3,
          "reps": [15, 15, 15],
          "weight": [0, 0, 0],
          "time": []
        }
      ],
      [
        {
          "title": "Plate press calves (outer)",
          "type": 1,
          "sets": 2,
          "reps": [10, 10],
          "weight": [0, 0],
          "time": []
        }
      ],
      [
        {
          "title": "Plate press calves (mid)",
          "type": 1,
          "sets": 2,
          "reps": [10, 10],
          "weight": [0, 0],
          "time": []
        }
      ],
      [
        {
          "title": "Plate press calves (inner)",
          "type": 1,
          "sets": 2,
          "reps": [10, 10],
          "weight": [0, 0],
          "time": []
        }
      ],
      [
        {
          "title": "Hack squat",
          "type": 0,
          "sets": 4,
          "reps": [10, 10, 10, 10],
          "weight": [0, 0, 0, 0],
          "time": []
        }
      ]
    ]
  }
}
```

With this, we can properly parse all of the required information into the table structure defined above. And, even with a simple and unoptimized prompt, we got a correct output. This gives us flexibility in other areas such as text format and model choice.