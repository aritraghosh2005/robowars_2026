import json
from pydub import AudioSegment
import sys

def main():
    try:
        audio = AudioSegment.from_mp3("assets/audio/skynut.mp3")
        chunk_ms = 50
        levels = []
        
        for i in range(0, len(audio), chunk_ms):
            chunk = audio[i:i+chunk_ms]
            levels.append(chunk.rms)
            
        max_rms = max(levels) if levels else 1
        # Boost quiet parts a bit but cap at 1.0
        normalized = [min(1.0, float(l) / max_rms * 1.2) for l in levels]
        
        with open("assets/audio/skynut_levels.json", "w") as f:
            json.dump({"chunk_ms": chunk_ms, "levels": normalized}, f)
        print("Done!")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
