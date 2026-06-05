import sys
import logging
import asyncio

from fastapi.testclient import TestClient
from app.main import app

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_test():
    client = TestClient(app)
    
    print("1. Fetching scenarios...")
    resp = client.get("/api/v1/speaking/roleplay/scenarios")
    if resp.status_code != 200:
        print(f"Failed to fetch scenarios: {resp.text}")
        return
        
    data = resp.json()
    scenarios = data.get("scenarios", [])
    if not scenarios:
        print("No scenarios found!")
        return
        
    scenario = scenarios[0]
    print(f"-> Selected scenario: {scenario['title']} ({scenario['slug']})")
    
    print("\n2. Starting roleplay session...")
    user_id = "test_user_123"
    resp = client.post("/api/v1/speaking/roleplay/start", json={
        "scenario_slug": scenario["slug"],
        "user_id": user_id
    })
    
    if resp.status_code != 200:
        print(f"Failed to start session: {resp.text}")
        return
        
    session_data = resp.json()
    session_id = session_data["session_id"]
    print(f"-> Session ID: {session_id}")
    print(f"-> Agent Opening: {session_data['agent_message']['text']}")
    
    print("\n3. Evaluating speech (harvard.wav)...")
    audio_path = "/home/khoi/Projects/Project_Langfens_Microservice/data/harvard.wav"
    try:
        with open(audio_path, "rb") as f:
            resp = client.post("/api/v1/speech/evaluate", files={"audio": ("harvard.wav", f, "audio/wav")})
    except FileNotFoundError:
        print(f"File not found: {audio_path}")
        return
        
    if resp.status_code != 200:
        print(f"Speech evaluation failed: {resp.text}")
        return
        
    eval_data = resp.json()
    print(f"-> Transcript: {eval_data['transcript']}")
    print(f"-> Score: {eval_data['score']}")
    print(f"-> Errors: {eval_data['errors']}")
    
    print("\n4. Sending turn to roleplay engine...")
    resp = client.post("/api/v1/speaking/roleplay/turn-with-speech", json={
        "session_id": session_id,
        "user_id": user_id,
        "text": eval_data["transcript"],
        "score": eval_data["score"],
        "errors": eval_data["errors"]
    })
    
    if resp.status_code != 200:
        print(f"Roleplay turn failed: {resp.text}")
        return
        
    turn_data = resp.json()
    print("-> Turn successful!")
    print(f"-> Agent Reply: {turn_data['agent_message']['text']}")
    print(f"-> Feedback: {turn_data['agent_message']['feedback']}")

if __name__ == "__main__":
    run_test()
