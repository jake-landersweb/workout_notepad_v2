## Model

users:
    - id: STRING
    - email: STRING !!KEY
    - firstName: STRING
    - lastName: STRING
    - phone: STRING
    - sync: BOOL
    - password: BYTE
    - salt: BYTE
    - created: DATE
    - updated: DATE

categories:
    - id: STRING
    - title: STRING

sets:
    - id: STRING
    - user_id: STRING
    - categories: CSV
    - title: STRING
    - description: STRING
    - created: DATE
    - updated: DATE?
    - type: INT (0 = weighted, 1 = bw, 2 = timed)
    - sets: INT
    - reps: INT
    - time: INT
    - time_post: STRING

set_sets:
    - id: STRING
    - parent_id: STRING
    - child_id: STRING
    - order: INT

workouts:
    - id: STRING
    - user_id: STRING
    - categories: CSV
    - title: STRING
    - description: STRING
    - created: DATE
    - updated: DATE?

workout_sets:
    - workout_id: STRING
    - set_id: STRING
    - order: INT

set_log:
    - id: STRING
    - user_id: STRING
    - set_id: STRING
    - type: INT
    - sets: INT
    - reps: INT
    - time: INT
    - time_post: STRING
    - weight: INT
    - weight_post: STRING
    - note: STRING
    - created: DATE

## Dynamic Queries

### All Sets For a Workout

```sql
SELECT * FROM sets s WHERE s.user_id = $USERID
JOIN workout_set ws ON s.id = ws.set_id
JOIN workouts w ON ws.workout_id = w.id
ORDER BY ws.order;
```

### Get Set Children

```sql
SELECT * from set_sets ss WHERE ss.parent_id = $ID
RIGHT JOIN sets s ON s.id == ss.child_id
ORDER BY ss.order;
```

### Get Sets With Category

```sql
SELECT * FROM sets s WHERE s.user_id = $USERID AND s.categories LIKE '%$CAT%';
```

### Get Workouts With Category

```sql
SELECT * FROM workouts w WHERE w.user_id = $USERID AND w.categories LIKE '%$CAT%';
```