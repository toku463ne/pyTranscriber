from flask import Flask, request, render_template, redirect, url_for
import os
import whisper
from werkzeug.utils import secure_filename

UPLOAD_FOLDER = 'uploads'
TRANSCRIPT_FOLDER = 'transcripts'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(TRANSCRIPT_FOLDER, exist_ok=True)

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

model = whisper.load_model("tiny")  # 軽量な tiny モデル

@app.route("/", methods=["GET", "POST"])
def index():
    transcript = None

    if request.method == "POST":
        file = request.files.get("file")
        if file and file.filename.endswith((".mp3", ".wav")):
            filename = secure_filename(file.filename)
            filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)
            file.save(filepath)

            result = model.transcribe(filepath, language="ja", task="transcribe")
            transcript_text = result["text"]

            output_path = os.path.join(TRANSCRIPT_FOLDER, filename + ".txt")
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(transcript_text)

            return render_template("index.html", transcript=transcript_text)

    return render_template("index.html", transcript=transcript)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
