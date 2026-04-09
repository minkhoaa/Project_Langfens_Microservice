#!/usr/bin/env python3
"""
Test Key Rotation Mechanism
Simulates rate limit on first key to verify rotation to second key.

Run: python scripts/test_key_rotation.py
"""

import os
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.services.openai_like_service import OpenAILikeService, key_manager
import asyncio


def test_key_rotation_simulation():
    """Test that key rotation works when one key is exhausted."""
    print("=" * 60)
    print("KEY ROTATION TEST")
    print("=" * 60)
    
    # Set up 2 test keys
    os.environ["GROQ_API_KEYS"] = "gsk_key1_valid,gsk_key2_valid"
    os.environ["CEREBRAS_API_KEY"] = "csk_test_key"
    
    # Create service
    service = OpenAILikeService()
    
    print("\n📊 Initial Key Status:")
    status = key_manager.get_status()
    for provider, info in status.items():
        print(f"   {provider}: {info['available']}/{info['total']} available")
    
    # Simulate exhausting first key
    print("\n🚫 Simulating: Marking first Groq key as exhausted...")
    key_manager.mark_exhausted("groq", 0, "simulated rate limit")
    
    print("\n📊 After exhausting first key:")
    status = key_manager.get_status()
    for provider, info in status.items():
        print(f"   {provider}: {info['available']}/{info['total']} available")
        for k in info["keys"]:
            state = "🚫 EXHAUSTED" if k["exhausted"] else "✅ available"
            print(f"      Key #{k['index']+1}: {k['preview']} - {state}")
    
    # Get next key - should return key #2
    print("\n🔄 Getting next available key...")
    key_info = key_manager.get_next_key("groq")
    if key_info:
        api_key, key_index = key_info
        print(f"   ✅ Returned: Key #{key_index + 1} ({api_key[:10]}...)")
        if key_index == 1:
            print("   ✅ CORRECT: Got key #2 (first exhausted)")
        else:
            print(f"   ⚠️ UNEXPECTED: Got key #{key_index + 1}")
    else:
        print("   ❌ No keys available!")
    
    # Test reset after cooldown
    print("\n🔄 Simulating: 1 hour cooldown + reset...")
    # Manually set exhausted_at to 1 hour ago
    import time
    with key_manager._lock:
        for ki in key_manager._keys.get("groq", []):
            ki["exhausted"] = False
            ki["exhausted_at"] = time.time() - 3700  # 1 hour + 100 sec ago
    
    status = key_manager.get_status()
    print(f"   After cooldown: {status['groq']['available']}/{status['groq']['total']} available")
    
    key_info = key_manager.get_next_key("groq")
    if key_info:
        api_key, key_index = key_info
        print(f"   ✅ After reset, got Key #{key_index + 1}")
    
    print("\n" + "=" * 60)
    print("✅ Key rotation test completed!")


async def test_full_flow_with_rotation():
    """Test full generate flow with multiple keys."""
    print("\n" + "=" * 60)
    print("FULL FLOW TEST WITH KEY ROTATION")
    print("=" * 60)

    if not os.getenv("GROQ_API_KEYS"):
        print("❌ GROQ_API_KEYS not set in environment")
        return

    service = OpenAILikeService()
    
    prompt = "Say 'Hello from Groq!' in exactly those words. Return ONLY text, no JSON."
    
    print("\n🤖 Calling generate...")
    result = await service.generate(
        prompt_template=prompt,
        variables={},
        model_size="small",  # Use small model for speed
        max_tokens=50,
    )
    
    print(f"\n✅ Result: {result}")
    print(f"   Provider used: {result.get('provider', 'unknown')}")


if __name__ == "__main__":
    test_key_rotation_simulation()
    asyncio.run(test_full_flow_with_rotation())
