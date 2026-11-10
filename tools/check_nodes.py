#!/usr/bin/env python3
"""
check_nodes.py - Linter "anti node kosong" untuk proyek Godot 4 (file .tscn / .gd).

Pemakaian (dari root proyek, folder yang berisi project.godot):
    python tools/check_nodes.py            # periksa seluruh proyek
    python tools/check_nodes.py scenes/    # periksa satu folder
Exit code 0 = lolos, 1 = ada ERROR. WARN tidak menggagalkan, tetapi harus dijelaskan di laporan.
"""
import os, re, sys

NEED_SHAPE_PARENTS = {"Area2D", "CharacterBody2D", "StaticBody2D", "RigidBody2D", "AnimatableBody2D"}
BARE_TYPES = {"Node", "Node2D", "Control", "CanvasLayer"}
ROOT = os.getcwd()

def parse_tscn(text):
    nodes, ext, cur = [], {}, None
    for line in text.splitlines():
        if line.startswith("[ext_resource"):
            m_id = re.search(r'id="?([^" \]]+)"?', line)
            m_path = re.search(r'path="([^"]+)"', line)
            if m_id and m_path:
                ext[m_id.group(1)] = m_path.group(1)
            cur = None
        elif line.startswith("[node"):
            attrs = dict(re.findall(r'(\w+)="([^"]*)"', line))
            cur = {"name": attrs.get("name", "?"), "type": attrs.get("type"),
                   "parent": attrs.get("parent"), "instance": "instance=" in line, "body": []}
            nodes.append(cur)
        elif line.startswith("["):
            cur = None
        elif cur is not None and line.strip():
            cur["body"].append(line)
    for n in nodes:
        if n["parent"] is None: n["path"] = "."
        elif n["parent"] == ".": n["path"] = n["name"]
        else: n["path"] = n["parent"] + "/" + n["name"]
        n["props"] = {l.split("=", 1)[0].strip(): l.split("=", 1)[1].strip() for l in n["body"] if "=" in l}
    return nodes, ext

def check_scene(path, errors, warns, stats):
    text = open(path, encoding="utf-8").read()
    nodes, ext = parse_tscn(text)
    rel = os.path.relpath(path, ROOT)
    for rid, rpath in ext.items():
        if rpath.startswith("res://") and not os.path.exists(os.path.join(ROOT, rpath[6:])):
            errors.append(f"{rel}: ext_resource hilang -> {rpath}")
    children = {}
    for n in nodes:
        children.setdefault(n["parent"] if n["parent"] is not None else "<root>", []).append(n)
    for n in nodes:
        stats["nodes"] += 1
        t, p, where = n["type"], n["props"], f"{rel} :: {n['path']} ({n['type'] or 'instance'})"
        if "script" in p: stats["scripts"] += 1
        if n["instance"] and t is None: continue
        if t == "Sprite2D" and "texture" not in p: errors.append(f"{where}: Sprite2D tanpa texture")
        if t == "AnimatedSprite2D" and "sprite_frames" not in p: errors.append(f"{where}: AnimatedSprite2D tanpa sprite_frames")
        if t == "TextureRect" and "texture" not in p: errors.append(f"{where}: TextureRect tanpa texture")
        if t == "CollisionShape2D" and "shape" not in p: errors.append(f"{where}: CollisionShape2D tanpa shape")
        if t == "CollisionPolygon2D" and "polygon" not in p: errors.append(f"{where}: CollisionPolygon2D tanpa polygon")
        if t in ("TileMapLayer", "TileMap") and "tile_set" not in p: errors.append(f"{where}: TileMap tanpa tile_set")
        if t in ("AudioStreamPlayer", "AudioStreamPlayer2D") and "stream" not in p: errors.append(f"{where}: audio player tanpa stream")
        if t == "Button" and "text" not in p and "icon" not in p: warns.append(f"{where}: Button tanpa text/icon")
        if t in NEED_SHAPE_PARENTS:
            kids = children.get(n["path"], [])
            if not any(k["type"] in ("CollisionShape2D", "CollisionPolygon2D") for k in kids):
                errors.append(f"{where}: tidak punya child CollisionShape2D/Polygon2D")
        if t in BARE_TYPES and "script" not in p and not children.get(n["path"]) and n["parent"] is not None:
            warns.append(f"{where}: node kosong (tanpa script dan tanpa child)")

def check_script(path, errors, warns, stats):
    rel = os.path.relpath(path, ROOT)
    lines = [l.strip() for l in open(path, encoding="utf-8").read().splitlines()]
    code = [l for l in lines if l and not l.startswith("#")]
    stats["gd"] += 1
    stats["gd_lines"] += len(code)
    if len(code) <= 3: errors.append(f"{rel}: script stub ({len(code)} baris kode)")
    elif code.count("pass") >= 3: warns.append(f"{rel}: banyak 'pass' ({code.count('pass')}x), pastikan bukan stub")
    if "TODO" in " ".join(lines): warns.append(f"{rel}: masih ada TODO")

def main():
    target = sys.argv[1] if len(sys.argv) > 1 else "."
    errors, warns, stats = [], [], {"nodes": 0, "scripts": 0, "scenes": 0, "gd": 0, "gd_lines": 0}
    for d, _, files in os.walk(target):
        if any(x in d for x in (".godot", ".git", "addons", "build")): continue
        for f in files:
            fp = os.path.join(d, f)
            if f.endswith(".tscn"): stats["scenes"] += 1; check_scene(fp, errors, warns, stats)
            elif f.endswith(".gd"): check_script(fp, errors, warns, stats)
    print(f"Scene: {stats['scenes']} | Node: {stats['nodes']} | Node ber-script: {stats['scripts']} | "
          f"Script .gd: {stats['gd']} ({stats['gd_lines']} baris kode)")
    for w in warns: print("WARN  ", w)
    for e in errors: print("ERROR ", e)
    print(f"Hasil: {len(errors)} error, {len(warns)} warning")
    sys.exit(1 if errors else 0)

if __name__ == "__main__":
    main()
