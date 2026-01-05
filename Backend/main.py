from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from model_loader import ModelLoader
import uvicorn
import os

app = FastAPI(title="Fake News Prediction API")

# Add CORS Middleware to allow requests from Flutter/Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Initialize ModelLoader
model_loader = ModelLoader()

class NewsRequest(BaseModel):
    text: str

class PredictionResponse(BaseModel):
    label: str
    confidence: float

@app.get("/")
def home():
    return {"message": "API is running. Use POST /predict to classify news."}

@app.post("/predict", response_model=PredictionResponse)
def predict_news(request: NewsRequest):
    try:
        # The model loads lazily on the first request
        result = model_loader.predict(request.text)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    # Run on port 8001 to avoid conflicts
    uvicorn.run(app, host="0.0.0.0", port=8001)
