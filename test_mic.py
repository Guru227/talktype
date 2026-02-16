#!/usr/bin/env python3
"""Test microphone capture"""
import sounddevice as sd
import numpy as np
import time

SAMPLE_RATE = 16000
DURATION = 3  # seconds

print("Available audio devices:")
print(sd.query_devices())
print()

print(f"Default input device: {sd.query_devices(kind='input')}")
print()

print(f"Recording for {DURATION} seconds...")
print("Speak NOW!")

audio = sd.rec(int(DURATION * SAMPLE_RATE),
               samplerate=SAMPLE_RATE,
               channels=1,
               dtype='float32')
sd.wait()

print("\nRecording complete!")
print(f"Audio shape: {audio.shape}")
print(f"Audio dtype: {audio.dtype}")
print(f"Max amplitude: {np.max(np.abs(audio)):.4f}")
print(f"Mean amplitude: {np.mean(np.abs(audio)):.4f}")
print(f"RMS energy: {np.sqrt(np.mean(audio ** 2)):.4f}")

if np.max(np.abs(audio)) < 0.001:
    print("\n❌ WARNING: Very low audio levels - microphone may not be working!")
elif np.max(np.abs(audio)) < 0.01:
    print("\n⚠️  WARNING: Low audio levels - speak louder or check microphone!")
else:
    print("\n✅ Audio captured successfully!")
