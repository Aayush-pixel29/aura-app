# 🌿 Aura — AI Mental Wellness Companion

Aura is a state-of-the-art mental wellness application designed to support individuals struggling with stress, anxiety, social withdrawal, and overthinking. Developed as an interactive, highly empathetic exhibition demo, Aura uses **Local LLMs (Ollama)** and **Computer Vision Face Detection** to analyze user emotions live and provide a personalized, supportive space for self-expression.

🌐 **Live Demo Frontend:** [https://aura-app-fe69f.web.app](https://aura-app-fe69f.web.app)

---

## ✨ Key Features

*   **📸 Live AI Face Scan (Computer Vision):** Toggle the camera panel to let Aura analyze your facial expression in real time. It uses a local convolutional neural network (CNN) to detect emotions (Happy, Neutral, Sad, Surprise, etc.) and automatically checks you in.
*   **💬 Empathy-Driven Chat (Local LLM):** Engage in supportive, non-judgmental dialogue with Aura. Powered by your local Ollama LLM, Aura acts as a comforting companion, offering active listening and validating your feelings.
*   **🎨 Paint a Feeling:** Describe what's on your mind, and Aura will extract visual keywords to automatically generate a beautiful, calming, custom background artwork that captures your mood.
*   **📔 My Journal:** Revisit your past conversations, emotional checks, and painted artwork in one place, allowing you to reflect on your wellness journey over time.

---

## 🛠️ Tech Stack

### **Frontend**
*   **Framework:** Flutter (Web & Mobile compilation)
*   **UI/UX:** Modern dark-theme glassmorphic design system
*   **Animations:** Rich micro-interactions built with `flutter_animate`
*   **Media Capture:** HTML5 Webcam Streaming Canvas API (for Flutter Web)

### **Backend**
*   **Server:** Python Flask with CORS enabled for secure localhost communication
*   **AI Engine:** Docker Desktop running local **Ollama** (supports `llama3`, `mistral`, or `phi3`)
*   **Computer Vision:** `OpenCV` + `FER` (Facial Expression Recognition framework using TensorFlow)

---

## 🏗️ Architecture

```
  [ Webcam Feed ]
         │
         ▼
 ┌───────────────┐
 │  Flutter Web  │ ◄─────── (Firebase Hosting)
 └───────┬───────┘
         │
         │ (Base64 Video Frames via HTTP POST)
         ▼
 ┌───────────────┐
 │ Python Server │ ◄─────── (Localhost:5000)
 └───────┬───────┘
         ├──────────────────────────────┐
         ▼                              ▼
 ┌───────────────┐              ┌───────────────┐
 │  OpenCV / FER │              │ Docker Ollama │
 └───────────────┘              └───────────────┘
(Facial Emotion Model)         (Local Llama3 LLM)
```

---

## 🚀 Local Setup & Running Guide

To run this high-fidelity local demo, you need to spin up the backend services on your laptop so the web app can communicate with them.

### **1. Run Ollama (Docker)**
Make sure your Docker Container running Ollama is active on port `11434`. Pull a model if you haven't already:
```bash
docker exec -it <ollama-container-name> ollama run llama3
```

### **2. Setup and Start Python Backend**
Navigate to the `backend` directory, create a virtual environment, and launch the server:
```bash
# Navigate to backend
cd backend

# Create & activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows use: .\venv\Scripts\activate

# Install required dependencies
pip install -r requirements.txt

# Start Flask Server
python server.py
```
The server will boot up on `http://localhost:5000`.

### **3. Run or Access the Frontend**
Open the live hosted web app at **[aura-app-fe69f.web.app](https://aura-app-fe69f.web.app)** (or run `flutter run -d chrome` from the `aura_app` root folder). 

Enable **AI Mood Scan** inside the mood check-in page and enjoy your local, private, offline-capable AI companion!
