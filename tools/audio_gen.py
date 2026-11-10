#!/usr/bin/env python3
"""
audio_gen.py - musik chiptune + SFX sintetis (dibuat sendiri, bebas lisensi).

    python3 tools/audio_gen.py

Output: assets/audio/music/*.wav, assets/audio/sfx/*.wav (22050 Hz mono 16-bit).
Musik di-loop oleh AudioManager (AudioStreamWAV.loop_mode di-set di runtime).
"""
import math
import os
import random
import struct
import wave

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SR = 22050
rnd = random.Random(7)


def write_wav(path, samples):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    peak = max(1e-6, max(abs(s) for s in samples))
    norm = 0.85 / peak if peak > 1.0 else 1.0
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s * norm)) * 32767)) for s in samples
        ))


def square(freq, dur, vol=0.3, duty=0.5, decay=6.0, detune=0.0):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        ph = (freq * t) % 1.0
        v = 1.0 if ph < duty else -1.0
        if detune:
            ph2 = (freq * (1 + detune) * t) % 1.0
            v = (v + (1.0 if ph2 < duty else -1.0)) * 0.5
        out.append(v * vol * math.exp(-decay * t))
    return out


def noise(dur, vol=0.25, decay=25.0, hp=0.0):
    n = int(SR * dur)
    out, prev = [], 0.0
    for i in range(n):
        t = i / SR
        v = rnd.uniform(-1, 1)
        prev = prev * hp + v * (1 - hp)
        out.append(prev * vol * math.exp(-decay * t))
    return out


def silence(dur):
    return [0.0] * int(SR * dur)


def mix(*tracks):
    n = max(len(t) for t in tracks)
    out = [0.0] * n
    for t in tracks:
        for i, s in enumerate(t):
            out[i] += s
    return out


def seq(notes, dur, **kw):
    """notes: list freq (0 = istirahat); masing-masing berbunyi `dur` detik."""
    out = []
    for f in notes:
        out += silence(dur) if f == 0 else square(f, dur, **kw)
    return out


NOTE = {n: 440.0 * 2 ** ((i - 9) / 12) for i, n in enumerate(
    ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])}


def f(name, octave):
    return NOTE[name] * 2 ** (octave - 4)


# ---------------------------------------------------------------- musik
def music_menu():
    """Loop tenang 8 birama, 90 BPM."""
    beat = 60 / 90 / 2  # 1/8
    prog = [("A", 2), ("F", 2), ("C", 3), ("G", 2)]
    bass = []
    for root, oc in prog:
        bass += [f(root, oc - 1)] * 6 + [0, 0]
    pad = []
    for root, oc in prog:
        pad += [f(root, oc)] * 2 + [f(root, oc) * 1.26] * 2 + [f(root, oc) * 1.5] * 2 + [0, 0]
    melody = [f("E", 5), 0, f("A", 5), 0, f("C", 6), 0, f("A", 5), 0,
              f("F", 5), 0, f("C", 6), 0, f("A", 5), 0, 0, 0,
              f("G", 5), 0, f("C", 6), 0, f("E", 6), 0, f("C", 6), 0,
              f("D", 5), 0, f("G", 5), 0, f("B", 5), 0, 0, 0]
    b = seq(bass, beat, vol=0.20, duty=0.5, decay=1.5)
    p = seq(pad, beat, vol=0.10, duty=0.25, decay=1.2)
    m = seq(melody, beat, vol=0.14, duty=0.125, decay=2.5)
    hat = (noise(beat, 0.05, 40, 0.5) * 2) * 32
    return mix(b, p, m, hat)


def music_level():
    """Loop 8 birama, 132 BPM, bass 1/8 + arpeggio + hi-hat."""
    beat = 60 / 132 / 2
    roots = ["D", "D", "A#", "A#", "F", "F", "C", "A"]
    bass, arp, drums = [], [], []
    for root in roots:
        for k in range(8):
            bass.append(f(root, 2) if k % 4 != 3 else 0)
        for step in (0, 1, 2, 1, 0, 1, 2, 1):
            arp.append(f(root, 4) * (1.0, 1.19, 1.5)[step])
        for k in range(8):
            drums.append(k % 2 == 0)
    b = seq(bass, beat, vol=0.22, duty=0.5, decay=2.0)
    a = seq(arp, beat, vol=0.10, duty=0.125, decay=4.0)
    hat = []
    for k in range(len(drums)):
        hat += noise(beat, 0.09 if k % 2 == 0 else 0.05, 30, 0.4) if drums[k] else silence(beat)
    kick = []
    for k in range(len(drums)):
        kick += square(60, beat, 0.28, 0.5, 12) if k % 4 == 0 else silence(beat)
    return mix(b, a, hat, kick)


def music_boss():
    beat = 60 / 150 / 2
    roots = ["C", "C", "D#", "D#", "G", "G", "A#", "G"]
    b, lead = [], []
    for root in roots:
        b += [f(root, 1)] * 8
        lead += [f(root, 4), f(root, 4), f(root, 4) * 1.5, 0, f(root, 4) * 1.19, 0,
                 f(root, 4) * 1.5, f(root, 4) * 2]
    return mix(seq(b, beat, vol=0.24, duty=0.5, decay=1.2),
               seq(lead, beat, vol=0.10, duty=0.25, decay=3.0),
               noise(len(roots) * 8 * beat, 0.04, 0.5, 0.2))


# ------------------------------------------------------------------ sfx
def sfx_jump():
    out = []
    for i in range(int(SR * 0.16)):
        t = i / SR
        fr = 300 + 500 * t / 0.16
        out.append((1.0 if (fr * t) % 1 < 0.5 else -1.0) * 0.3 * math.exp(-9 * t))
    return out


def sfx_attack():
    return mix(square(700, 0.1, 0.25, 0.25, 20), noise(0.12, 0.2, 30, 0.1))


def sfx_hurt():
    out = []
    for i in range(int(SR * 0.25)):
        t = i / SR
        out.append(math.sin(2 * math.pi * (300 - 600 * t) * t) * 0.35 * math.exp(-6 * t))
    return mix(out, noise(0.12, 0.15, 25, 0.2))


def sfx_pickup():
    return seq([880, 1174, 1568], 0.05, vol=0.22, duty=0.5, decay=12)


def sfx_ui():
    return seq([660], 0.05, vol=0.18, duty=0.5, decay=25)


def sfx_correct():
    return seq([523, 659, 784, 1046], 0.09, vol=0.22, duty=0.5, decay=6)


def sfx_wrong():
    return mix(seq([233, 208], 0.14, vol=0.25, duty=0.5, decay=5), noise(0.1, 0.1, 30, 0.3))


def sfx_purchase():
    return seq([784, 1046, 1318], 0.07, vol=0.2, duty=0.5, decay=10)


def sfx_death():
    out = []
    for i in range(int(SR * 0.6)):
        t = i / SR
        out.append(math.sin(2 * math.pi * (400 * math.exp(-1.2 * t)) * t) * 0.3 * math.exp(-2.5 * t))
    return out


def sfx_skill():
    out = []
    for i in range(int(SR * 0.35)):
        t = i / SR
        fr = 500 + 1400 * t
        out.append((1.0 if (fr * t) % 1 < 0.3 else -1.0) * 0.2 * math.exp(-4 * t))
    return out


def sfx_bridge():
    return mix(seq([392, 523, 659, 784], 0.06, vol=0.2, duty=0.25, decay=8), noise(0.2, 0.06, 12, 0.6))


def sfx_victory():
    return seq([523, 659, 784, 1046, 784, 1046, 1318], 0.13, vol=0.22, duty=0.5, decay=4)


def main():
    mdir = os.path.join(ROOT, "assets", "audio", "music")
    sdir = os.path.join(ROOT, "assets", "audio", "sfx")
    write_wav(os.path.join(mdir, "menu.wav"), music_menu())
    write_wav(os.path.join(mdir, "level.wav"), music_level())
    write_wav(os.path.join(mdir, "boss.wav"), music_boss())
    for name, fn in (("jump", sfx_jump), ("attack", sfx_attack), ("hurt", sfx_hurt),
                     ("pickup", sfx_pickup), ("ui_click", sfx_ui), ("puzzle_correct", sfx_correct),
                     ("puzzle_wrong", sfx_wrong), ("purchase", sfx_purchase),
                     ("death", sfx_death), ("skill", sfx_skill), ("bridge", sfx_bridge),
                     ("victory", sfx_victory)):
        write_wav(os.path.join(sdir, f"{name}.wav"), fn())
    print("audio_gen: selesai")


if __name__ == "__main__":
    main()
