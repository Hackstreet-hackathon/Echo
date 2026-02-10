import os
import time
import json
import speech_recognition as sr
import pyttsx3
from openai import OpenAI
from datetime import datetime
from supabase import create_client, Client
from dotenv import load_dotenv

# Load env variables
load_dotenv('../.env')

# Supabase Setup
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY")

# OpenRouter / OpenAI Setup
# Using the key provided by the user in the prompt
OPENAI_API_KEY = "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"
OPENAI_BASE_URL = "https://openrouter.ai/api/v1"

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env")
    exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

client = OpenAI(
    api_key=OPENAI_API_KEY,
    base_url=OPENAI_BASE_URL
)

engine = pyttsx3.init()
r = sr.Recognizer()

# Enhanced configuration for noisy environments
r.energy_threshold = 4000
r.dynamic_energy_threshold = True
r.pause_threshold = 1.0
r.phrase_threshold = 0.5

def speak(text):
    print(f"🗣️ System: {text}")
    engine.say(text)
    engine.runAndWait()

def calibrate_noise_level(duration=3):
    print("🔊 Calibrating microphone for ambient noise...")
    with sr.Microphone() as source:
        r.adjust_for_ambient_noise(source, duration=duration)
    print(f"✅ Calibration complete. Energy threshold: {r.energy_threshold}")

def adaptive_listen(timeout=10, phrase_time_limit=15):
    with sr.Microphone() as source:
        print("🎤 Listening for announcement...")
        r.adjust_for_ambient_noise(source, duration=1)
        try:
            audio = r.listen(source, timeout=timeout, phrase_time_limit=phrase_time_limit)
            return audio
        except sr.WaitTimeoutError:
            return None

def extract_structured_data(text):
    """
    Uses LLM to extract structured train data from spoken text.
    """
    print("🧠 Extracting data with AI...")
    prompt = f"""
    Extract the following details from this railway announcement: "{text}"
    
    Return ONLY a JSON object with these keys:
    - name: Train name (e.g. "Chennai Express") or "Unknown" if not mentioned
    - train_number: Train number (e.g. "12601") or null
    - platform: Platform number (integer) or null
    - status: 'On Time', 'Delayed', 'Arrived', 'Departing', or 'Cancelled'
    - type: 'arrival', 'departure', or 'general'
    
    If specific details are missing, guess reasonable defaults based on context or use null.
    Example: "Train 123 is arriving on platform 1" -> {{"name": "Unknown", "train_number": "123", "platform": 1, "status": "On Time", "type": "arrival"}}
    """
    
    try:
        completion = client.chat.completions.create(
            model="openai/gpt-3.5-turbo", # Or any cheap model on OpenRouter
            messages=[
                {"role": "system", "content": "You are a data extraction assistant. Output valid JSON only."},
                {"role": "user", "content": prompt}
            ]
        )
        content = completion.choices[0].message.content
        # robust json parsing
        start = content.find('{')
        end = content.rfind('}') + 1
        return json.loads(content[start:end])
    except Exception as e:
        print(f"❌ AI Extraction Error: {e}")
        return None

def process_audio(audio):
    try:
        text = r.recognize_google(audio)
        print(f"📝 Transcribed: {text}")
        return text
    except sr.UnknownValueError:
        print("❌ Could not understand speech")
        return None
    except sr.RequestError as e:
        print(f"⚠️ Service error: {e}")
        return None

def main():
    print("🚂 ECHO Station Master Simulator Started")
    calibrate_noise_level()
    speak("Station Master System Online")
    
    while True:
        audio = adaptive_listen()
        if audio is None:
            continue
            
        text = process_audio(audio)
        if not text:
            continue
            
        if "exit" in text.lower() or "shutdown" in text.lower():
            speak("Shutting down")
            break
            
        # Extract Data
        data = extract_structured_data(text)
        if data:
            print(f"📊 Structured Data: {json.dumps(data, indent=2)}")
            
            # Construct full payload
            payload = {
                "name": data.get("name") or "Express",
                "train_number": data.get("train_number"),
                "platform": data.get("platform"),
                "status": data.get("status") or "On Time",
                "type": data.get("type") or "general",
                "speech_recognized": text,
                "isPWD": False, # Could be extracted too
                "time": datetime.utcnow().isoformat(),
                "ticket": None
            }
            
            # Push to Supabase
            try:
                print("🚀 Uploading to Supabase...")
                supabase.table("announcements").insert(payload).execute()
                print("✅ Announcement Live!")
                speak("Announcement broadcasted")
            except Exception as e:
                print(f"❌ Database Error: {e}")
        
if __name__ == "__main__":
    main()
