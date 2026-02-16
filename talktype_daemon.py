#!/usr/bin/env python3
"""
TalkType daemon for Wayland/GNOME
Responds to SIGUSR1 signals to toggle recording
"""
import signal
import sys
import time
import threading
from pathlib import Path

# Import talktype components
import numpy as np
from scipy.io import wavfile
import sounddevice as sd
import pyperclip
import subprocess
import platform

# Configuration
SAMPLE_RATE = 16000
LANGUAGE = "en"
MODEL = "tiny"
SYSTEM = platform.system()
PID_FILE = Path.home() / ".cache" / "talktype_daemon.pid"

# State
class State:
    IDLE = 0
    RECORDING = 1
    TRANSCRIBING = 2

state = State.IDLE
state_lock = threading.Lock()
audio_chunks = []
stream = None
whisper_model = None

def beep(freq, duration, volume=0.12):
    """Play beep"""
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    wave = (volume * np.sin(2 * np.pi * freq * t)).astype(np.float32)
    try:
        sd.play(wave, SAMPLE_RATE)
    except:
        pass

def audio_callback(indata, frames, time_info, status):
    """Accumulate audio chunks"""
    audio_chunks.append(indata.copy())

def start_recording():
    """Start recording"""
    global stream, audio_chunks
    audio_chunks = []
    stream = sd.InputStream(
        samplerate=SAMPLE_RATE,
        channels=1,
        dtype='float32',
        callback=audio_callback
    )
    stream.start()
    beep(880, 0.08)
    print("🎤 RECORDING...")

def stop_recording():
    """Stop recording and return audio"""
    global stream
    if stream:
        stream.stop()
        stream.close()
        stream = None
    beep(440, 0.12)
    print("⏳ Transcribing...")

    if not audio_chunks:
        return np.array([], dtype=np.float32)
    return np.concatenate(audio_chunks).flatten()

def has_speech(audio, threshold=0.005):
    """Check if audio contains speech"""
    energy = np.sqrt(np.mean(audio ** 2))
    print(f"Audio energy: {energy:.4f} (threshold: {threshold})")
    return energy > threshold

def transcribe(audio):
    """Transcribe audio"""
    if len(audio) < SAMPLE_RATE * 0.5 or not has_speech(audio):
        return ""

    audio_for_whisper = audio.astype(np.float32)
    segments, _ = whisper_model.transcribe(audio_for_whisper, language=LANGUAGE)
    return " ".join(seg.text for seg in segments).strip()

def paste_text(text):
    """Copy text to clipboard for pasting"""
    # Copy to clipboard
    pyperclip.copy(text)
    # Beep to indicate it's ready to paste
    beep(660, 0.08)
    print(f"📋 Copied to clipboard! Press Ctrl+Shift+V (terminal) or Ctrl+V (other apps) to paste")

def transcribe_and_paste(audio):
    """Background transcription and paste"""
    global state
    try:
        text = transcribe(audio)
        if text:
            paste_text(" " + text)
            beep(660, 0.08)
            print(f"✅ {text}")
        else:
            beep(220, 0.2)
            print("❌ No speech detected")
    except Exception as e:
        beep(220, 0.2)
        print(f"❌ Error: {e}")
    finally:
        with state_lock:
            state = State.IDLE
        print("● Ready")

def toggle_recording(signum, frame):
    """Toggle recording on SIGUSR1"""
    global state

    with state_lock:
        if state == State.IDLE:
            state = State.RECORDING
            start_recording()
        elif state == State.RECORDING:
            state = State.TRANSCRIBING
            audio = stop_recording()
            threading.Thread(
                target=transcribe_and_paste,
                args=(audio,),
                daemon=True
            ).start()
        # TRANSCRIBING: ignore

def cleanup(signum, frame):
    """Cleanup on exit"""
    print("\nShutting down...")
    if PID_FILE.exists():
        PID_FILE.unlink()
    sys.exit(0)

def main():
    global whisper_model

    # Write PID file
    PID_FILE.parent.mkdir(exist_ok=True)
    PID_FILE.write_text(str(os.getpid()))

    print("TalkType Daemon for Wayland/GNOME")
    print("=" * 40)

    # Load Whisper model
    from faster_whisper import WhisperModel
    print(f"Loading Whisper model '{MODEL}'...")
    whisper_model = WhisperModel(MODEL, device="auto", compute_type="auto")
    print("Model loaded.")

    # Set up signal handlers
    signal.signal(signal.SIGUSR1, toggle_recording)
    signal.signal(signal.SIGINT, cleanup)
    signal.signal(signal.SIGTERM, cleanup)

    print("\n● Ready")
    print("Waiting for toggle signals...")
    print("Set up GNOME keyboard shortcut to run:")
    print(f"  python {Path(__file__).parent / 'talktype_toggle.py'}")
    print("\nPress Ctrl+C to exit\n")

    # Keep running
    while True:
        time.sleep(1)

if __name__ == "__main__":
    import os
    main()
