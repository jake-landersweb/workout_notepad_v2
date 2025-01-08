from flask import Flask, request, jsonify
import os

app = Flask(__name__)

# Directory to save files
UPLOAD_DIR = "screenshots"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@app.route("/", methods=["POST"])
def upload_file():
    try:
        data = request.json
        filename = data.get("filename")
        file_bytes = data.get("bytes")

        if not filename or not file_bytes:
            return jsonify({"error": "Filename or bytes missing"}), 400

        file_path = os.path.join(UPLOAD_DIR, filename)
        with open(file_path, "wb") as f:
            f.write(bytearray(file_bytes))

        return jsonify({"message": f"File saved as {file_path}"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=34893)
