import os
import google.generativeai as genai
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS

# --- Configuration ---
GOOGLE_API_KEY = os.getenv('GOOGLE_API_KEY')
UNSPLASH_ACCESS_KEY = os.getenv('UNSPLASH_ACCESS_KEY')
genai.configure(api_key=GOOGLE_API_KEY)

app = Flask(__name__)
CORS(app)

# --- IMAGE GENERATION ENDPOINT ---
@app.route('/generate-image', methods=['POST'])
def generate_image():
    data = request.get_json()
    if not data or 'prompt' not in data:
        return jsonify({'error': 'Missing prompt'}), 400

    prompt = data['prompt']
    print(f"Received image prompt: {prompt}")

    try:
        model = genai.GenerativeModel('models/gemini-1.5-flash-latest')
        ai_prompt = f"Based on the user's prompt, extract 3-5 visual keywords for an image search. Keywords should be simple, comma-separated. USER PROMPT: {prompt} KEYWORDS:"
        response = model.generate_content(ai_prompt)
        search_query = response.text.strip().replace("\n", "")
        print(f"AI Keywords for Image Search: {search_query}")

        unsplash_url = f"https://api.unsplash.com/search/photos?query={search_query}&per_page=1&orientation=portrait"
        headers = {"Authorization": f"Client-ID {UNSPLASH_ACCESS_KEY}"}
        
        unsplash_response = requests.get(unsplash_url, headers=headers)
        unsplash_data = unsplash_response.json()
        image_url = unsplash_data['results'][0]['urls']['regular']
        print(f"Found Unsplash Image: {image_url}")
        
        return jsonify({ 'image_url': image_url })
    except Exception as e:
        print(f"An error occurred in image generation: {e}")
        return jsonify({'image_url': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb'}), 500

# --- CHAT ENDPOINT ---
@app.route('/chat', methods=['POST'])
def handle_chat():
    data = request.get_json()
    if not data or 'prompt' not in data:
        return jsonify({'error': 'Missing prompt'}), 400

    prompt = data['prompt']
    print(f"Received chat prompt: {prompt}")

    try:
        model = genai.GenerativeModel('models/gemini-1.5-flash-latest')
        chat_prompt = f"You are Aura, a calm, empathetic AI companion. Keep responses brief (1-3 sentences) and encouraging. USER: {prompt} AURA:"
        response = model.generate_content(chat_prompt)
        ai_response = response.text.strip()
        print(f"AI Chat Response: {ai_response}")
        
        return jsonify({'response': ai_response})
    except Exception as e:
        print(f"An error occurred in chat: {e}")
        return jsonify({'error': 'Failed to get AI response'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)