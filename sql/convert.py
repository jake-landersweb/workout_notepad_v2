import json
import uuid

filedata = ""
with open("./init.json", "r") as f:
    filedata = f.read()
    f.close()

data = json.loads(filedata)

# convert exercise logs to exercise logs and metadata
newLogs = []
metadata = []
for i in data["exerciseLogs"]:
    newLogs.append(
        {
            "created": i["created"],
            "exerciseId": i["exerciseId"],
            "exerciseLogId": i["exerciseLogId"],
            "note": i["note"],
            "parentId": i["parentId"],
            "sets": i["sets"],
            "title": i["title"],
            "type": i["type"],
            "updated": i["updated"],
            "workoutLogId": i["workoutLogId"],
            "created": i["created"],
            "updated": i["updated"],
        }
    )
    # create metadata objects
    reps = i["reps"].split(",")
    time = i["time"].split(",")
    weight = i["weight"].split(",")
    for j in range(len(reps)):
        metadata.append(
            {
                "exerciseLogMetaId": uuid.uuid4().hex,
                "exerciseLogId": i["exerciseLogId"],
                "exerciseId": i["exerciseId"],
                "reps": int(reps[j]),
                "time": int(time[j]),
                "weight": int(weight[j]),
                "weightPost": i["weightPost"],
                "created": i["created"],
            }
        )

del data["exerciseLogs"]
del data["exerciseLogTags"]
data["exerciseLogs"] = newLogs
data["exerciseLogsMeta"] = metadata

serialized = json.dumps(data)

with open("./init-test.json", "w") as f:
    f.write(serialized)
    f.close()
