import speech_recognition as sr
import pyttsx3
import json
import os
import time
import io
import requests
import threading

AUDIO_UPLOAD_URL = os.environ.get("AUDIO_UPLOAD_URL")
LOCATION_ID = os.environ.get("ECHO_LOCATION_ID", "station-1")

engine = pyttsx3.init()
r = sr.Recognizer()

r.energy_threshold = 4000
r.dynamic_energy_threshold = True
r.pause_threshold = 1.0
r.phrase_threshold = 0.5

json_file = "voice_inputs.json"
if os.path.exists(json_file):
    with open(json_file, "r") as f:
        all_inputs = json.load(f)
else:
    all_inputs = []

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
            audio = r.listen(
                source, 
                timeout=timeout, 
                phrase_time_limit=phrase_time_limit
            )
            return audio
        except sr.WaitTimeoutError:
            print("⏰ Listening timeout - no speech detected")
            return None

def is_likely_speech(text):
    if not text:
        return False
    
    text = text.strip()
    
    if len(text) < 3:
        return False
    
    words = text.split()
    if len(words) < 2:  
        return False
        
    return True

def process_audio_with_retry(audio, retries=2):
    text = None
    
    for attempt in range(retries + 1):
        try:
            text = r.recognize_google(audio)
            if text and is_likely_speech(text):
                return text
        except sr.UnknownValueError:
            if attempt == retries:
                print("❌ Could not understand speech clearly")
            continue
        except sr.RequestError as e:
            print(f"⚠️ Google Speech Recognition error: {e}")
            break
    
    try:
        text = r.recognize_sphinx(audio)
        if text and is_likely_speech(text):
            print("🔧 Using offline recognition (Sphinx)")
            return text
    except:
        pass  
    
    return None

def send_audio_to_backend(audio_data, ts):
    if not AUDIO_UPLOAD_URL:
        return

    try:
        wav_data = audio_data.get_wav_data()
        file_obj = io.BytesIO(wav_data)
        file_obj.name = f"announcement_{int(ts)}.wav"

        files = {
            'file': (file_obj.name, file_obj, 'audio/wav'),
        }
        data = {
            'timestamp': str(ts),
            'location_id': LOCATION_ID,
        }

        print(f"📡 Uploading audio to {AUDIO_UPLOAD_URL}...")
        resp = requests.post(AUDIO_UPLOAD_URL, files=files, data=data, timeout=10)
        resp.raise_for_status()
        print(f"✅ Audio uploaded successfully (status {resp.status_code})")

    except Exception as e:
        print(f"❌ Failed to upload audio: {e}")

def main():
    print("🎤 Announcement Recognition System Ready!")
    print("🔊 Calibrating for your environment...")
    calibrate_noise_level()

    print("\nCommands:")
    print("- Say 'exit' or 'quit' to end")
    print("- Speak clearly and loudly for announcements")
    print("- System is optimized for noisy environments\n")

    while True:
        audio = adaptive_listen(timeout=15, phrase_time_limit=20)
        
        if audio is None:
            continue
        
        capture_time = time.time()
        
        upload_thread = threading.Thread(
            target=send_audio_to_backend, 
            args=(audio, capture_time)
        )
        upload_thread.start()

        user_input = process_audio_with_retry(audio)
        
        if not user_input:
            print("💬 No clear speech detected, continuing to listen...")
            continue
            
        print(f"🗣️ Detected: {user_input}")

        if user_input.lower() in ["exit", "quit", "stop", "end"]:
            print("👋 Goodbye!")
            break
        
        all_inputs.append({
            "voice_input": user_input,
            "timestamp": capture_time
        })
        with open(json_file, "w") as f:
            json.dump(all_inputs, f, indent=4)
        
        print("💾 Input saved to JSON")
        
    calibration_data = {
        "final_energy_threshold": r.energy_threshold,
        "total_inputs_processed": len(all_inputs),
        "last_session": time.time()
    }

    with open("calibration_data.json", "w") as f:
        json.dump(calibration_data, f, indent=2)

    print("✅ Session ended successfully!")

if __name__ == "__main__":
    main()
