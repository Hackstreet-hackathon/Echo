from flask import Flask, jsonify, request
from flask_cors import CORS
import speech_recognition as sr
from openai import OpenAI
import json
import os
import uuid
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app) # Enable CORS for Flutter web/mobile

# LLM CLIENT
client = OpenAI(
    api_key=os.environ.get("OPENROUTER_KEY"),
    base_url="https://openrouter.ai/api/v1"
)

r = sr.Recognizer()

def analyze_with_llm(text):
    try:
        response = client.chat.completions.create(
            model="openai/gpt-4o-mini",
            messages=[
                {"role": "system", "content": """You are a railway announcement analyzer. Analyze the announcement and return a JSON response with:
1. "summary": A clear, concise summary of the announcement
2. "priority": One of "high", "medium", or "low" based on urgency

Priority guidelines:
- HIGH: Safety issues, emergencies, immediate platform changes, train cancellations, severe delays, arrivals in "seconds" or "1-2 minutes", train "has reached the platform", or "immediately", urgent track updates.
- MEDIUM: Moderate delays, platform announcements, service updates, train arriving in anything between "3 minutes" and "10 minutes".
- LOW: General information, next station announcements, routine updates, train has started from its destination, anything with more than 15 minutes wait.

Return ONLY valid JSON in this format:
{"summary": "your summary here", "priority": "high/medium/low"}"""},
                {"role": "user", "content": text}
            ]
        )

        result = response.choices[0].message.content
        # Basic cleanup of markdown if LLM returns it
        if "```json" in result:
            result = result.split("```json")[1].split("```")[0].strip()
        elif "```" in result:
            result = result.split("```")[1].split("```")[0].strip()
            
        return json.loads(result)
    except Exception as e:
        print(f"LLM Error: {e}")
        return {"summary": text, "priority": "low"}

@app.route("/")
def home():
    return "ECHO Voice AI Server is Live!"

@app.route("/upload_audio", methods=["POST"])
def upload_audio():
    try:
        if "file" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        audio_file = request.files["file"]
        filename = f"temp_{uuid.uuid4().hex}.wav"
        audio_file.save(filename)

        try:
            with sr.AudioFile(filename) as source:
                audio = r.record(source)
            text = r.recognize_google(audio)
        except sr.UnknownValueError:
            return jsonify({"error": "Speech not clear enough to recognize"}), 400
        except Exception as e:
            return jsonify({"error": f"Audio processing error: {str(e)}"}), 500
        finally:
            if os.path.exists(filename):
                os.remove(filename)

        llm_output = analyze_with_llm(text)

        return jsonify({
            "original_text": text,
            "llm_output": llm_output.get("summary", text),
            "priority": llm_output.get("priority", "low")
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    # For local testing
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
