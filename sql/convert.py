import json
import uuid

with open("./old-data.json", "r") as f:
    odata = json.loads(f.read())
    f.close()

ndata = {}

for k, v in odata.items():
    print(k)
    print(len(v))
    ndata[k] = []
    if (
        k != "workout_exercise"
        and k != "exercise_set"
        and k != "exercise_log"
        and k != "workout_snapshot"
        and k != "exercise_detail"
    ):
        ndata[k] = v

ndata["workout_exercise"] = []

for we in odata["workout_exercise"]:
    superset_id = uuid.uuid4().hex
    obj = {
        "workoutExerciseId": we["workoutExerciseId"],
        "workoutId": we["workoutId"],
        "exerciseId": we["exerciseId"],
        "supersetId": superset_id,
        "supersetOrder": 0,
        "exerciseOrder": we["exerciseOrder"],
        "sets": we["sets"],
        "reps": we["reps"],
        "time": we["time"],
        "created": we["created"],
        "updated": we["updated"],
    }
    children = []

    for es in odata["exercise_set"]:
        if es["workoutExerciseId"] == we["workoutExerciseId"]:
            children.append(es)

    ndata["workout_exercise"].append(obj)
    for i in range(len(children)):
        ndata["workout_exercise"].append(
            {
                "workoutExerciseId": children[i]["exerciseSetId"],
                "workoutId": we["workoutId"],
                "exerciseId": children[i]["childId"],
                "supersetId": superset_id,
                "exerciseOrder": we["exerciseOrder"],
                "supersetId": superset_id,
                "supersetOrder": i + 1,
                "sets": children[i]["sets"],
                "reps": children[i]["reps"],
                "time": children[i]["time"],
                "created": children[i]["created"],
                "updated": children[i]["updated"],
            }
        )


ndata["exercise_log"] = []
for l in odata["exercise_log"]:
    ndata["exercise_log"].append(
        {
            "exerciseLogId": l["exerciseLogId"],
            "exerciseId": l["exerciseId"],
            "supersetId": uuid.uuid4().hex,
            "workoutExerciseId": "",
            "exerciseOrder": 0,
            "supersetOrder": 0,
            "workoutLogId": l["workoutLogId"],
            "title": l["title"],
            "category": l["category"],
            "type": l["type"],
            "sets": l["sets"],
            "created": l["created"],
            "updated": l["updated"],
        }
    )

with open("./new-data.json", "w") as f:
    f.write(json.dumps(ndata))
    f.close()
