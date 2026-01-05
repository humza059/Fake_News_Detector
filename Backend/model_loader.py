import tensorflow as tf
from tensorflow.keras.preprocessing.sequence import pad_sequences
import pickle
import numpy as np
import os

class ModelLoader:
    def __init__(self, model_path='fake_news_model.h5', tokenizer_path='tokenizer.pickle'):
        self.model_path = model_path
        self.tokenizer_path = tokenizer_path
        self.model = None
        self.tokenizer = None
        self.max_length = 54
        self.padding_type = 'post'
        self.trunc_type = 'post'

    def load_model(self):
        """Loads the Keras model and pickle tokenizer."""
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(f"Model file not found: {self.model_path}")
        
        if not os.path.exists(self.tokenizer_path):
            raise FileNotFoundError(f"Tokenizer file not found: {self.tokenizer_path}")

        try:
            print("Loading Code Model & Tokenizer...")
            self.model = tf.keras.models.load_model(self.model_path)
            with open(self.tokenizer_path, 'rb') as handle:
                self.tokenizer = pickle.load(handle)
            print("Model loaded successfully.")
        except Exception as e:
            print(f"Error loading files: {e}")
            raise e

    def predict(self, text):
        """Predicts label and confidence for the given text."""
        if self.model is None or self.tokenizer is None:
            self.load_model()
        
        # Preprocess
        sequences = self.tokenizer.texts_to_sequences([text])
        padded = pad_sequences(sequences, maxlen=self.max_length, padding=self.padding_type, truncating=self.trunc_type)
        
        # Predict
        prediction = self.model.predict(padded, verbose=0)
        prob = float(prediction[0][0])
        
        # logic: 0=FAKE, 1=REAL (Standard binary classification)
        label = "REAL" if prob >= 0.5 else "FAKE"
        
        return {
            "label": label, 
            "confidence": prob
        }
