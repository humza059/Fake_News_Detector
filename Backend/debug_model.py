from model_loader import ModelLoader
import numpy as np

print("Initializing loader...")
loader = ModelLoader("fake_news_model.h5", "tokenizer.pickle")
loader.load_model()

# Test cases
texts = [
    "Aliens have landed in New York City and are eating pizza.",
    "The government successfully passed the new healthcare bill yesterday.",
    "Hillary Clinton emails reveal secret plot.",
    "Local cat wins mayor election in small town."
]

print("\n--- DEBUGGING ---")
print(f"Tokenizer Vocab Size: {len(loader.tokenizer.word_index)}")

for text in texts:
    print(f"\nText: {text}")
    # Check tokenization
    seq = loader.tokenizer.texts_to_sequences([text])
    print(f"Sequence: {seq}")
    
    # Check prediction
    result = loader.predict(text)
    print(f"Result: {result}")
