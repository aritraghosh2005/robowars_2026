import subprocess
import json
import struct
import numpy as np

def main():
    cmd = [
        "ffmpeg", "-i", "assets/audio/skynut.mp3",
        "-f", "s16le", "-acodec", "pcm_s16le", "-ar", "8000", "-ac", "1", "pipe:1"
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    pcm_data, _ = proc.communicate()
    
    chunk_samples = 400
    levels_2d = []
    
    for i in range(0, len(pcm_data), chunk_samples * 2):
        chunk = pcm_data[i:i + chunk_samples * 2]
        if len(chunk) % 2 != 0:
            chunk = chunk[:-1]
        if not chunk:
            break
        
        samples = struct.unpack(f"<{len(chunk)//2}h", chunk)
        sig = np.array(samples, dtype=float)
        
        # Apply window to reduce spectral leakage
        window = np.hanning(len(sig))
        sig = sig * window
        
        # Compute FFT
        fft_out = np.abs(np.fft.rfft(sig))
        
        if len(fft_out) < 201:
            fft_out = np.pad(fft_out, (0, 201 - len(fft_out)))
            
        # Group 200 bins into 32 bands
        band_values = []
        for b in range(32):
            start = 1 + int(b * 6.25)
            end = 1 + int((b + 1) * 6.25)
            if start == end:
                end += 1
            # Take max amplitude in the frequency band
            val = np.max(fft_out[start:end])
            band_values.append(float(val))
            
        levels_2d.append(band_values)
        
    # Normalize the 2D array globally
    max_val = max(max(bands) for bands in levels_2d) if levels_2d else 1
    
    normalized_2d = []
    for bands in levels_2d:
        # Compress dynamics so mid/quiet frequencies are still visible
        norm_bands = [min(1.0, (val / max_val) ** 0.6 * 1.5) for val in bands]
        normalized_2d.append(norm_bands)
    
    with open("assets/audio/skynut_levels.json", "w") as f:
        json.dump({"chunk_ms": 50, "levels": normalized_2d}, f)
    
    print("Done generating 2D FFT levels")

if __name__ == "__main__":
    main()
