from firebase_functions import https_fn
from firebase_admin import initialize_app
import google.generativeai as genai
import json

import os

initialize_app()

# Read the API key from environment variables (Set this up in Firebase Secrets)
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
genai.configure(api_key=GEMINI_API_KEY)

@https_fn.on_request(cors=https_fn.Options(cors_origins="*", cors_methods=["get", "post"]))
def chat(req: https_fn.Request) -> https_fn.Response:
    if req.method != "POST":
        return https_fn.Response("Method Not Allowed", status=405)
    
    try:
        data = req.get_json()
        if not data or 'prompt' not in data:
            return https_fn.Response(json.dumps({'error': 'Missing prompt'}), status=400, mimetype="application/json")
        
        prompt = data['prompt']
        model = genai.GenerativeModel('models/gemini-1.5-flash-latest')
        chat_prompt = f"You are Aura, a calm, empathetic AI companion. Keep responses brief (1-3 sentences) and encouraging. USER: {prompt} AURA:"
        
        response = model.generate_content(chat_prompt)
        ai_response = response.text.strip()
        
        return https_fn.Response(json.dumps({'response': ai_response}), status=200, mimetype="application/json")
    except Exception as e:
        print(f"Error in chat function: {e}")
        return https_fn.Response(json.dumps({'error': str(e)}), status=500, mimetype="application/json")

@https_fn.on_request(cors=https_fn.Options(cors_origins="*", cors_methods=["get", "post"]))
def generate_image(req: https_fn.Request) -> https_fn.Response:
    if req.method != "POST":
        return https_fn.Response("Method Not Allowed", status=405)
    
    try:
        data = req.get_json()
        if not data or 'prompt' not in data:
            return https_fn.Response(json.dumps({'error': 'Missing prompt'}), status=400, mimetype="application/json")
        
        prompt = data['prompt']
        model = genai.GenerativeModel('models/gemini-1.5-flash-latest')
        ai_prompt = f"Based on the user's prompt, extract 1-2 visual keywords for an image search. Keywords should be simple, separated by commas. USER PROMPT: {prompt} KEYWORDS:"
        
        response = model.generate_content(ai_prompt)
        search_query = response.text.strip().replace("\n", "").replace(" ", "").replace(",", "")
        
        # Using a free placeholder service based on the AI's keyword extraction
        image_url = f"https://loremflickr.com/800/600/{search_query}"
        
        return https_fn.Response(json.dumps({'image_url': image_url}), status=200, mimetype="application/json")
    except Exception as e:
        print(f"Error in image generation function: {e}")
        return https_fn.Response(json.dumps({'error': str(e)}), status=500, mimetype="application/json")
