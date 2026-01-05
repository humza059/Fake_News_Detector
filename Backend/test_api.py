import requests
import time

def test_api():
    base_url = "http://127.0.0.1:8001"
    
    # Wait for server to start
    for _ in range(5):
        try:
            resp = requests.get(base_url)
            if resp.status_code == 200:
                print("Server is ready!")
                print("Root response:", resp.json())
                break
        except:
            print("Waiting for server...")
            time.sleep(2)
    else:
        print("Server failed to start or is not reachable.")
        return

    # Test prediction
    test_text = "Breaking news: Aliens have landed in New York!"
    print(f"Testing prediction with text: '{test_text}'")
    
    try:
        resp = requests.post(f"{base_url}/predict", json={"text": test_text})
        print("Prediction response:", resp.json())
    except Exception as e:
        print("Prediction request failed:", e)

if __name__ == "__main__":
    test_api()
