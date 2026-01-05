from fastapi import FastAPI
from pydantic import BaseModel
import tensorflow as tf
import numpy as np
import pickle
from tensorflow.keras.preprocessing.sequence import pad_sequences
from fastapi.middleware.cors import CORSMiddleware
import os

# --- LOAD MODEL (Robust Loading) ---
model_path = "fake_news_model.h5"
if not os.path.exists(model_path):
    print(f"Warning: {model_path} not found. Ensure it is in the same directory.")
    # Create a dummy model or handle error if needed
else:
    try:
        model = tf.keras.models.load_model(model_path)
    except Exception as e:
        print(f"Error loading model: {e}")

# --- LOAD TOKENIZER ---
tokenizer_path = "tokenizer.pickle"
if os.path.exists(tokenizer_path):
    with open(tokenizer_path, "rb") as f:
        tokenizer = pickle.load(f)
else:
    print(f"Warning: {tokenizer_path} not found.")

MAX_LENGTH = 200

# --- APP SETUP ---
app = FastAPI(title="Fake News Detection API")

# --- CORS FIX FOR WEB ---
# This allows requests from ANY domain (including localhost:60652)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

class NewsRequest(BaseModel):
    text: str

@app.post("/predict")
def predict_news(req: NewsRequest):
    # If model/tokenizer isn't loaded, return dummy response for testing connection
    if 'tokenizer' not in globals() or 'model' not in globals():
        return {
            "label": 1, 
            "confidence": 0.99, 
            "note": "Model not loaded, returning dummy Fake result"
        }

    seq = tokenizer.texts_to_sequences([req.text])
    pad = pad_sequences(seq, maxlen=MAX_LENGTH, padding='post', truncating='post')
    pred = model.predict(pad, verbose=0)
    label_index = int(np.argmax(pred, axis=1)[0])
    label_str = "FAKE" if label_index == 1 else "REAL"
    confidence = float(np.max(pred))
    
    return {"label": label_str, "confidence": confidence}

if __name__ == "__main__":
    import uvicorn
    # Initializing with access to all network interfaces
    uvicorn.run(app, host="0.0.0.0", port=8001)
