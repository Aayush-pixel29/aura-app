import os
import base64
import json
import logging
import requests
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)
CORS(app) # Enable CORS for Flutter Web local requests

# Ollama local address (Default for Docker Desktop)
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")

# Fallback models list in order of preference
PREFERRED_MODELS = ["llama3", "llama3.2", "mistral", "gemma2", "gemma", "phi3"]
SELECTED_MODEL = None

# Lazy load computer vision models to avoid startup overhead or crashing if libraries are missing
emotion_detector = None

def get_detector():
    global emotion_detector
    if emotion_detector is not None:
        return emotion_detector
    try:
        import cv2
        from fer import FER
        # Initialize FER with MTCNN=False for faster lightweight CPU detection
        emotion_detector = FER(mtcnn=False)
        logging.info("Facial Expression Recognition (FER) model loaded successfully!")
        return emotion_detector
    except Exception as e:
        logging.warning(f"Could not load FER model: {e}. Falling back to mock emotion detection.")
        return None

def find_available_model():
    global SELECTED_MODEL
    if SELECTED_MODEL is not None:
        return SELECTED_MODEL
    
    try:
        response = requests.get(f"{OLLAMA_URL}/api/tags")
        if response.statusCode == 200:
            models_data = response.json().get("models", [])
            installed_models = [m.get("name").split(":")[0] for m in models_data]
            logging.info(f"Installed Ollama models: {installed_models}")
            
            for model in PREFERRED_MODELS:
                if model in installed_models:
                    SELECTED_MODEL = model
                    logging.info(f"Selected Ollama model: '{SELECTED_MODEL}'")
                    return SELECTED_MODEL
            
            if installed_models:
                SELECTED_MODEL = installed_models[0]
                logging.info(f"Fallback to first available Ollama model: '{SELECTED_MODEL}'")
                return SELECTED_MODEL
    except Exception as e:
        logging.error(f"Failed to fetch models from Ollama: {e}")
    
    # Ultimate default
    SELECTED_MODEL = "llama3"
    logging.info(f"Defaulting to '{SELECTED_MODEL}' (Ollama connection might be offline)")
    return SELECTED_MODEL

@app.route("/api/tags", methods=["GET"])
def get_tags():
    """Proxy route to get Ollama tags."""
    try:
        response = requests.get(f"{OLLAMA_URL}/api/tags")
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({"error": f"Failed to connect to local Ollama: {str(e)}"}), 500

@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json() or {}
    prompt = data.get("prompt", "").strip()
    if not prompt:
        return jsonify({"error": "Missing prompt"}), 400

    model = find_available_model()
    
    system_context = (
        "You are Aura, a compassionate and empathetic AI companion designed for youth mental wellness. "
        "Your role: Listen actively, validate emotions, provide calm, supportive, non-judgmental responses. "
        "Keep responses warm, friendly, and concise (2-4 sentences). Do not give medical advice. "
        "Respond as a caring friend."
    )

    full_prompt = f"{system_context}\n\nUser: {prompt}\nAura:"

    try:
        response = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": model,
                "prompt": full_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "num_predict": 150
                }
            }
        )
        if response.status_code == 200:
            ai_response = response.json().get("response", "").strip()
            return jsonify({"response": ai_response})
        else:
            return jsonify({"error": f"Ollama returned error: {response.text}"}), response.status_code
    except Exception as e:
        logging.error(f"Error calling Ollama: {e}")
        return jsonify({"error": f"Failed to connect to local Ollama: {str(e)}"}), 500

@app.route("/reflection", methods=["POST"])
def reflection():
    data = request.get_json() or {}
    mood = data.get("mood", "").strip()
    if not mood:
        return jsonify({"error": "Missing mood"}), 400

    model = find_available_model()
    prompt = (
        f"A user checked in feeling: '{mood}'. "
        "Write a single warm, poetic, and highly validating sentence (under 20 words) "
        "acknowledging this feeling like a gentle, reassuring hug. Speak directly to them."
    )

    try:
        response = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": model,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.8,
                    "num_predict": 60
                }
            }
        )
        if response.status_code == 200:
            reflection_text = response.json().get("response", "").strip()
            # Clean quotes if any
            reflection_text = reflection_text.strip('"').strip("'")
            return jsonify({"response": reflection_text})
        else:
            return jsonify({"error": "Ollama error"}), response.status_code
    except Exception as e:
        return jsonify({"response": f"Every feeling you have is valid and real. I am here with you. 💜"}), 200

@app.route("/generate-image", methods=["POST"])
def generate_image():
    data = request.get_json() or {}
    prompt = data.get("prompt", "").strip()
    if not prompt:
        return jsonify({"error": "Missing prompt"}), 400

    model = find_available_model()
    keyword_prompt = (
        f"Based on the user's emotional description: '{prompt}', "
        "extract exactly 2 simple visual keywords suitable for finding a calming, artistic background image. "
        "Return only the keywords separated by a comma. Do not explain."
    )

    try:
        response = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": model,
                "prompt": keyword_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.5,
                    "num_predict": 10
                }
            }
        )
        if response.status_code == 200:
            keywords = response.json().get("response", "").strip()
            search_query = keywords.replace("\n", "").replace(" ", "").replace(".", "")
            image_url = f"https://loremflickr.com/800/600/{search_query}"
            return jsonify({"image_url": image_url})
    except Exception as e:
        logging.error(f"Image prompt error: {e}")
        
    return jsonify({"image_url": "https://loremflickr.com/800/600/peaceful,nature"})

@app.route("/analyze-frame", methods=["POST"])
def analyze_frame():
    """Receives a base64 webcam frame, runs facial emotion detection, and returns the top emotion."""
    data = request.get_json() or {}
    image_data = data.get("image", "")
    
    if not image_data:
        return jsonify({"error": "No image data received"}), 400
        
    try:
        # Decode base64 image
        if "," in image_data:
            image_data = image_data.split(",")[1]
            
        decoded_bytes = base64.b64decode(image_data)
        
        # Initialize OpenCV & FER lazily
        detector = get_detector()
        if detector is None:
            # Mock fallback if libraries aren't installed/working
            import random
            mock_emotions = ["Happy", "Neutral", "Sad", "Surprised"]
            return jsonify({
                "emotion": random.choice(mock_emotions),
                "confidence": 0.85,
                "message": "Mock detection active (install fer & tensorflow for real CV)"
            })

        import cv2
        # Convert bytes to numpy array
        nparr = np.frombuffer(decoded_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            return jsonify({"error": "Failed to decode image"}), 400
            
        # Detect emotions
        emotions = detector.detect_emotions(img)
        
        if not emotions:
            return jsonify({"emotion": "Neutral", "confidence": 1.0, "message": "No face detected"})
            
        # Get the first detected face's emotions
        first_face_emotions = emotions[0]["emotions"]
        # Find the emotion with the highest score
        top_emotion = max(first_face_emotions, key=first_face_emotions.get)
        confidence = first_face_emotions[top_emotion]
        
        # Capitalize emotion label
        emotion_label = top_emotion.capitalize()
        
        logging.info(f"Detected Emotion: {emotion_label} (Confidence: {confidence:.2f})")
        return jsonify({
            "emotion": emotion_label,
            "confidence": confidence,
            "all_emotions": first_face_emotions
        })
        
    except Exception as e:
        logging.error(f"Error in analyze-frame: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    logging.info("Starting local Aura Backend Server on http://localhost:5000")
    # Run locally
    app.run(host="0.0.0.0", port=5000, debug=True)
