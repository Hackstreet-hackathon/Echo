from flask import Flask, jsonify,request
import speech_recognition as sr
import pyttsx3
from openai import OpenAI
import json
import os
import threading
import time

# ==============================
# FLASK APP
# ==============================
app = Flask(__name__)

# ==============================
# LLM CLIENT (SECURE)
# ==============================
client = OpenAI(
    api_key=os.environ.get("OPENROUTER_API_KEY"),
    base_url="https://openrouter.ai/api/v1"
)

# ==============================
# SPEECH SETUP
# ==============================
engine = pyttsx3.init()
r = sr.Recognizer()

r.energy_threshold = 4000
r.dynamic_energy_threshold = True
r.pause_threshold = 1.0
r.phrase_threshold = 0.5

# ==============================
# DATA STORAGE
# ==============================
json_file = "voice_inputs.json"

if os.path.exists(json_file):
    with open(json_file, "r") as f:
        all_inputs = json.load(f)
else:
    all_inputs = []

# ==============================
# CONTROL FLAGS
# ==============================
listening = False
listener_thread = None

# ==============================
# FUNCTIONS
# ==============================

def calibrate_noise_level(duration=3):
    with sr.Microphone() as source:
        r.adjust_for_ambient_noise(source, duration=duration)


def adaptive_listen(timeout=15, phrase_time_limit=20):
    with sr.Microphone() as source:
        r.adjust_for_ambient_noise(source, duration=1)
        try:
            return r.listen(source, timeout=timeout, phrase_time_limit=phrase_time_limit)
        except:
            return None


def process_audio(audio):
    try:
        return r.recognize_google(audio)
    except:
        return None


def analyze_with_llm(text):
    try:
        response = client.chat.completions.create(
            model="openai/gpt-4o-mini",
            messages=[
                {"role": "system", "content": "Summarize railway announcements clearly."},
                {"role": "user", "content": text}
            ]
        )

        return response.choices[0].message.content
    except Exception as e:
        return f"LLM Error: {e}"



def voice_listener():
    global listening

    print("Voice listener started...")
    calibrate_noise_level()

    while listening:
        audio = adaptive_listen()

        if not audio:
            continue

        text = process_audio(audio)

        if not text:
            continue

        print("Detected:", text)

        # LLM Processing
        llm_output = analyze_with_llm(text)
        print("LLM Response:", llm_output)

        entry = {
            "original_text": text,
            "llm_analysis": llm_output,
            "timestamp": time.time()
        }

        all_inputs.append(entry)

        with open(json_file, "w") as f:
            json.dump(all_inputs, f, indent=4)

# ==============================
# ROUTES
# ==============================

@app.route("/")
def home():
    return "Voice AI Server Running"


@app.route("/start")
def start():
    global listening, listener_thread

    if not listening:
        listening = True
        listener_thread = threading.Thread(target=voice_listener)
        listener_thread.start()
        return jsonify({"status": "Listening started"})
    else:
        return jsonify({"status": "Already running"})


@app.route("/stop")
def stop():
    global listening
    listening = False
    return jsonify({"status": "Listening stopped"})


@app.route("/logs")
def logs():
    return jsonify(all_inputs)


@app.route("/status")
def status():
    return jsonify({
        "listening": listening,
        "total_records": len(all_inputs)
    })

import uuid

@app.route("/upload_audio", methods=["POST"])
def upload_audio():
    try:
        if "file" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        audio_file = request.files["file"]

        filename = f"temp_{uuid.uuid4().hex}.wav"
        audio_file.save(filename)

        with sr.AudioFile(filename) as source:
            audio = r.record(source)

        try:
            text = r.recognize_google(audio)
        except sr.UnknownValueError:
            os.remove(filename)
            return jsonify({"error": "Speech not clear"}), 400

        llm_output = analyze_with_llm(text)

        os.remove(filename)

        return jsonify({
            "original_text": text,
            "llm_output": llm_output
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500



# ==============================
# RUN SERVER
# ==============================

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)