#!/usr/bin/env python3
"""
artgen.py - generator aset piksel "Relational Data Chronicles: The Lost Schema".

Semua gambar di proyek ini dibuat sendiri oleh skrip ini (tidak ada aset pihak
ketiga yang dipakai), sehingga bebas lisensi (CC0 / public domain). Jalankan:

    python3 tools/artgen.py

Output (relatif ke root proyek):
    assets/tilesets/l1.png l2.png l3.png          atlas 16x16 (8x4 sel)
    assets/tilesets/l1.tres l2.tres l3.tres       TileSet + physics layer
    assets/sprites/player_sheet.png               + player_frames.tres
    assets/sprites/enemies/*.png                  + frames .tres
    assets/sprites/items/*.png
    assets/sprites/ui/*.png
    assets/backgrounds/l1.png l2.png l3.png
Skrip ini idempoten: aman dijalankan berulang.
"""
import os
import random
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rnd = random.Random(1234)  # deterministik: aset sama tiap kali di-generate

# ---------------------------------------------------------------- palet region
REGIONS = {
    "l1": dict(  # Record Ruins - teal / abu digital
        dark=(18, 32, 38), mid=(36, 62, 68), light=(78, 148, 138),
        accent=(122, 232, 212), accent2=(236, 255, 251), glow=(24, 90, 84),
    ),
    "l2": dict(  # Key Citadel - perunggu / amber
        dark=(42, 28, 16), mid=(80, 54, 28), light=(172, 122, 58),
        accent=(255, 204, 102), accent2=(255, 244, 208), glow=(120, 78, 24),
    ),
    "l3": dict(  # Foreign Spire - ungu / magenta
        dark=(26, 18, 46), mid=(58, 42, 88), light=(126, 76, 198),
        accent=(224, 92, 255), accent2=(255, 226, 255), glow=(84, 40, 140),
    ),
}

# ------------------------------------------------------------------- utilitas
def img(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def dither(d, x, y, w, h, col, chance=0.10, step=1):
    for yy in range(y, y + h, step):
        for xx in range(x, x + w, step):
            if rnd.random() < chance:
                d.point((xx, yy), fill=col)


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c) + (255,)


# ----------------------------------------------------------------- tileset
# atlas 8 kolom x 4 baris = 128x64 px, sel 16x16.
COLS, ROWS, T = 8, 4, 16


def tile_solid(pal, u, d_, l, r, secret=False):
    """Satu sel blok solid 16x16; u/d/l/r = ada tetangga solid di sisi itu."""
    im = img(T, T)
    dr = ImageDraw.Draw(im)
    dr.rectangle([0, 0, 15, 15], fill=shade(pal["mid"], 1.0))
    dither(dr, 0, 0, 16, 16, shade(pal["dark"], 1.0), 0.16)
    # bata halus
    for by in (4, 9, 14):
        dr.line([0, by, 15, by], fill=shade(pal["mid"], 0.82))
    dr.line([7, 0, 7, 4], fill=shade(pal["mid"], 0.82))
    dr.line([3, 5, 3, 9], fill=shade(pal["mid"], 0.82))
    dr.line([11, 10, 11, 14], fill=shade(pal["mid"], 0.82))
    if not u:  # permukaan atas: garis energi
        dr.rectangle([0, 0, 15, 2], fill=shade(pal["light"], 1.0))
        dr.line([0, 0, 15, 0], fill=shade(pal["accent"], 1.0))
    if not d_:
        dr.rectangle([0, 13, 15, 15], fill=shade(pal["dark"], 0.95))
    if not l:
        dr.line([0, 0, 0, 15], fill=shade(pal["light"], 0.85))
    if not r:
        dr.line([15, 0, 15, 15], fill=shade(pal["dark"], 0.8))
    if u and l and r and d_:
        dr.point((5, 6), fill=shade(pal["accent"], 1.0))
        dr.point((10, 11), fill=shade(pal["accent"], 0.8))
    if secret:  # dinding rahasia: pucat, terlihat seperti blok biasa
        for i in range(3):
            dr.point((4 + i * 4, 8), fill=shade(pal["accent"], 0.55))
    return im


def tile_platform(pal, part):
    im = img(T, T)
    dr = ImageDraw.Draw(im)
    left, right = part == "l", part == "r"
    x0, x1 = (2 if left else 0), (13 if right else 15)
    dr.rectangle([x0, 3, x1, 5], fill=shade(pal["light"], 1.0))
    dr.line([x0, 3, x1, 3], fill=shade(pal["accent"], 1.0))
    dr.rectangle([x0, 6, x1, 7], fill=shade(pal["mid"], 1.0))
    dr.line([x0, 8, x1, 8], fill=shade(pal["dark"], 1.0))
    # penyangga
    dr.line([x0 + 3, 9, x0 + 3, 11], fill=shade(pal["mid"], 0.9))
    dr.line([x1 - 3, 9, x1 - 3, 11], fill=shade(pal["mid"], 0.9))
    return im


def tile_ghost(pal):
    im = img(T, T)
    dr = ImageDraw.Draw(im)
    for x in range(0, 16, 4):
        dr.line([x, 4, x + 2, 4], fill=shade(pal["accent"], 0.55))
        dr.line([x, 5, x + 2, 5], fill=shade(pal["accent"], 0.35))
    dr.line([0, 9, 15, 9], fill=shade(pal["accent"], 0.22))
    return im


def tile_bg(pal, variant):
    im = img(T, T)
    dr = ImageDraw.Draw(im)
    dr.rectangle([0, 0, 15, 15], fill=shade(pal["dark"], 0.72))
    if variant == 0:
        dr.line([0, 0, 0, 15], fill=shade(pal["dark"], 0.5))
        dr.line([0, 0, 15, 0], fill=shade(pal["dark"], 0.5))
    else:
        dr.polygon([(8, 3), (12, 8), (8, 13), (4, 8)], outline=shade(pal["glow"], 1.0))
        dr.point((8, 8), fill=shade(pal["glow"], 1.0))
    return im


def tile_decor(pal, kind):
    im = img(T, T)
    dr = ImageDraw.Draw(im)
    if kind == "circuit":
        dr.line([1, 12, 6, 12, 6, 4, 13, 4], fill=shade(pal["accent"], 0.75), width=1)
        dr.point((6, 12), fill=shade(pal["accent2"], 1.0))
        dr.point((13, 4), fill=shade(pal["accent2"], 1.0))
        dr.rectangle([9, 9, 12, 12], outline=shade(pal["light"], 0.9))
    elif kind == "pipe":
        dr.rectangle([5, 0, 10, 15], fill=shade(pal["mid"], 0.9), outline=shade(pal["dark"], 1.0))
        dr.line([7, 0, 7, 15], fill=shade(pal["light"], 0.8))
    else:  # vent
        dr.rectangle([2, 4, 13, 11], fill=shade(pal["dark"], 1.0), outline=shade(pal["light"], 0.8))
        for y in (6, 8, 10):
            dr.line([4, y, 11, y], fill=shade(pal["mid"], 1.0))
    return im


def build_tileset(key, pal):
    atlas = img(COLS * T, ROWS * T)
    solid = {}  # (col,row) -> punya physics
    def put(c, r, im, physics=False):
        atlas.paste(im, (c * T, r * T))
        solid[(c, r)] = physics

    combos = {(0, 0): (0, 1, 1), (0, 1): (0, 1, 1), (0, 2): (0, 1, 1)}  # placeholder
    # 3x3 blok: baris = u? (0 atas, 1 tengah, 2 bawah), kolom = l/r
    for r in range(3):
        for c in range(3):
            u = (r != 0)
            d_ = (r != 2)
            l = (c != 0)
            rr = (c != 2)
            put(c, r, tile_solid(pal, u, d_, l, rr), True)
    put(3, 0, tile_solid(pal, False, False, False, False), True)      # blok tunggal
    put(3, 1, tile_solid(pal, True, True, True, True), True)          # blok dalam
    put(4, 0, tile_platform(pal, "l"), True)
    put(5, 0, tile_platform(pal, "m"), True)
    put(6, 0, tile_platform(pal, "r"), True)
    put(4, 1, tile_solid(pal, True, True, True, True, secret=True), True)  # dinding rahasia
    put(5, 1, tile_ghost(pal), False)                                 # platform hantu (collision via GhostPlatform)
    put(6, 1, tile_bg(pal, 0), False)
    put(7, 1, tile_bg(pal, 1), False)
    put(0, 3, tile_decor(pal, "circuit"), False)
    put(1, 3, tile_decor(pal, "pipe"), False)
    put(2, 3, tile_decor(pal, "vent"), False)
    put(3, 3, tile_decor(pal, "circuit"), False)
    out = os.path.join(ROOT, "assets", "tilesets", f"{key}.png")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    atlas.save(out)
    write_tileset_tres(key, solid)
    return out


def write_tileset_tres(key, solid):
    """TileSet .tres: atlas + physics_layer_0 (collision_layer 1 = world)."""
    lines = [
        '[gd_resource type="TileSet" load_steps=3 format=3]',
        "",
        f'[ext_resource type="Texture2D" path="res://assets/tilesets/{key}.png" id="1_atlas"]',
        "",
        '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_atlas"]',
        'texture = ExtResource("1_atlas")',
        'texture_region_size = Vector2i(16, 16)',
    ]
    for (c, r), phys in sorted(solid.items()):
        lines.append(f"{c}:{r}/0 = 0")
    for (c, r), phys in sorted(solid.items()):
        if phys:
            lines.append(
                f"{c}:{r}/0/physics_layer_0/polygon_0/points = "
                "PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)"
            )
    lines += [
        "",
        "[resource]",
        "tile_size = Vector2i(16, 16)",
        "physics_layer_0/collision_layer = 1",
        "physics_layer_0/collision_mask = 0",
        'sources/0 = SubResource("TileSetAtlasSource_atlas")',
        "",
    ]
    with open(os.path.join(ROOT, "assets", "tilesets", f"{key}.tres"), "w") as f:
        f.write("\n".join(lines))


# ------------------------------------------------------------------- karakter
PLAYER_FRAME = (20, 24)


def player_frame(pose, t):
    """pose: idle|run|jump|fall|attack|hurt|death|cast ; t = indeks frame."""
    w, h = PLAYER_FRAME
    im = img(w, h)
    dr = ImageDraw.Draw(im)
    suit = (188, 214, 222, 255)
    suit_dark = (96, 124, 140, 255)
    visor = (122, 232, 212, 255)
    boot = (58, 78, 92, 255)
    blade = (236, 255, 251, 255)

    bob = 0
    if pose == "idle":
        bob = (0, 1)[t % 2]
    elif pose == "run":
        bob = (0, 0, -1, 0, 0, -1)[t % 6]
    elif pose == "death":
        bob = t * 2

    cx = 10
    if pose == "death":
        # rebah: badan mendatar
        y = 14 + min(t, 3)
        dr.rectangle([cx - 7, y, cx + 6, y + 5], fill=suit)
        dr.rectangle([cx - 9, y + 1, cx - 6, y + 4], fill=suit_dark)
        dr.point((cx - 7, y + 2), fill=visor)
        return im

    top = 4 + bob
    # kepala + helm
    dr.rectangle([cx - 4, top, cx + 3, top + 6], fill=suit)
    dr.rectangle([cx - 4, top, cx + 3, top + 1], fill=suit_dark)
    dr.rectangle([cx - 3, top + 2, cx + 2, top + 3], fill=visor)
    # badan
    dr.rectangle([cx - 4, top + 7, cx + 3, top + 14], fill=suit)
    dr.line([cx - 4, top + 7, cx + 3, top + 7], fill=suit_dark)
    dr.point((cx, top + 11), fill=visor)
    # lengan
    if pose == "attack":
        reach = (5, 7, 9)[t % 3]
        dr.rectangle([cx + 3, top + 8, cx + 4 + reach // 3, top + 10], fill=suit)
        dr.polygon([(cx + 5, top + 8), (cx + 5 + reach, top + 9), (cx + 5, top + 11)], fill=blade)
    elif pose == "cast":
        dr.rectangle([cx + 3, top + 8, cx + 5, top + 10], fill=suit)
        r = 2 + t
        dr.ellipse([cx + 4 - r, top + 3 - r, cx + 4 + r, top + 3 + r], outline=visor)
    else:
        dr.rectangle([cx + 3, top + 8, cx + 4, top + 13], fill=suit_dark)
        dr.rectangle([cx - 5, top + 8, cx - 4, top + 13], fill=suit_dark)
    # kaki
    if pose == "run":
        swing = (-2, -1, 1, 2, 1, -1)[t % 6]
        dr.rectangle([cx - 4, top + 15, cx - 2, top + 20 + min(0, swing)], fill=boot)
        dr.rectangle([cx + 1 + max(0, swing), top + 15, cx + 3, top + 20], fill=boot)
    elif pose in ("jump",):
        dr.rectangle([cx - 4, top + 15, cx - 2, top + 18], fill=boot)
        dr.rectangle([cx + 1, top + 15, cx + 3, top + 19], fill=boot)
    elif pose == "fall":
        dr.rectangle([cx - 5, top + 15, cx - 3, top + 20], fill=boot)
        dr.rectangle([cx + 2, top + 15, cx + 4, top + 20], fill=boot)
    elif pose == "hurt":
        dr.rectangle([cx - 5, top + 15, cx - 2, top + 20], fill=boot)
        dr.rectangle([cx + 1, top + 15, cx + 4, top + 19], fill=boot)
        dr.line([cx - 6, top + 2, cx + 5, top + 9], fill=(255, 96, 96, 200))
    else:
        dr.rectangle([cx - 4, top + 15, cx - 2, top + 20], fill=boot)
        dr.rectangle([cx + 1, top + 15, cx + 3, top + 20], fill=boot)
    # bayangan kecil di bawah
    dr.line([cx - 4, h - 1, cx + 3, h - 1], fill=(0, 0, 0, 90))
    return im


PLAYER_ANIMS = [  # (nama, pose, jumlah frame, fps, loop)
    ("idle", "idle", 2, 4.0, True),
    ("run", "run", 6, 12.0, True),
    ("jump", "jump", 1, 1.0, False),
    ("fall", "fall", 1, 1.0, False),
    ("attack", "attack", 3, 14.0, False),
    ("hurt", "hurt", 1, 1.0, False),
    ("death", "death", 4, 6.0, False),
    ("cast", "cast", 2, 8.0, False),
]


def build_player():
    cols = 6
    rows = len(PLAYER_ANIMS)
    sheet = img(cols * PLAYER_FRAME[0], rows * PLAYER_FRAME[1])
    spec = []
    for r, (name, pose, n, fps, loop) in enumerate(PLAYER_ANIMS):
        for i in range(n):
            sheet.paste(player_frame(pose, i), (i * PLAYER_FRAME[0], r * PLAYER_FRAME[1]))
        spec.append((name, r, n, fps, loop))
    p = os.path.join(ROOT, "assets", "sprites", "player_sheet.png")
    os.makedirs(os.path.dirname(p), exist_ok=True)
    sheet.save(p)
    write_frames_tres("player_frames", "res://assets/sprites/player_sheet.png",
                      PLAYER_FRAME, spec)


def write_frames_tres(name, texture, frame_size, spec):
    """SpriteFrames .tres dari spritesheet baris-per-animasi."""
    fw, fh = frame_size
    subs, anims = [], []
    for i, (anim, row, n, fps, loop) in enumerate(spec):
        frames = []
        for f in range(n):
            sid = f"AtlasTexture_{anim}_{f}"
            subs.append(
                f'[sub_resource type="AtlasTexture" id="{sid}"]\n'
                f'atlas = ExtResource("1_tex")\n'
                f"region = Rect2({f * fw}, {row * fh}, {fw}, {fh})\n"
            )
            frames.append('{"duration": 1.0, "texture": SubResource("%s")}' % sid)
        anims.append(
            '{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %.1f\n}'
            % (", ".join(frames), "true" if loop else "false", anim, fps)
        )
    txt = [
        f'[gd_resource type="SpriteFrames" load_steps={len(subs) + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{texture}" id="1_tex"]',
        "",
    ]
    txt += subs
    txt += ["[resource]", "animations = [" + ",\n".join(anims) + "]", ""]
    out = os.path.join(ROOT, "assets", "sprites", f"{name}.tres")
    with open(out, "w") as f:
        f.write("\n".join(txt))


# -------------------------------------------------------------------- musuh
def enemy_sheet(name, frames, size, draw):
    sheet = img(size[0] * len(frames), size[1])
    for i in range(len(frames)):
        sheet.paste(draw(i), (i * size[0], 0))
    p = os.path.join(ROOT, "assets", "sprites", "enemies", f"{name}.png")
    os.makedirs(os.path.dirname(p), exist_ok=True)
    sheet.save(p)
    write_frames_tres(f"enemies/{name}_frames", f"res://assets/sprites/enemies/{name}.png",
                      size, [("idle", 0, len(frames), 6.0, True)])


def draw_blob(i):
    im = img(16, 16)
    dr = ImageDraw.Draw(im)
    squash = (0, 1)[i]
    col = (86, 200, 152, 255)
    dr.ellipse([2, 4 + squash, 13, 14], fill=col)
    dr.ellipse([3, 5 + squash, 8, 10], fill=(140, 246, 200, 150))
    dr.point((6, 8 + squash), fill=(10, 30, 26, 255))
    dr.point((10, 8 + squash), fill=(10, 30, 26, 255))
    for gx in (3, 9, 12):
        dr.point((gx, 12 - squash), fill=(255, 90, 200, 120))
    return im


def draw_slime(i):
    im = img(16, 16)
    dr = ImageDraw.Draw(im)
    squash = (0, 1)[i]
    dr.rectangle([3, 6 + squash, 12, 14], fill=(206, 148, 78, 255))
    dr.ellipse([2, 4 + squash, 13, 10], fill=(232, 176, 96, 255))
    dr.rectangle([5, 5 + squash, 7, 8], fill=(40, 26, 12, 255))
    dr.rectangle([9, 5 + squash, 11, 8], fill=(40, 26, 12, 255))
    dr.line([3, 12, 12, 12], fill=(140, 96, 44, 255))
    return im


def draw_orphan(i):
    im = img(16, 16)
    dr = ImageDraw.Draw(im)
    o = (0, 1)[i]
    dr.polygon([(4, 6 + o), (12, 4 + o), (13, 12), (5, 14), (3, 10)], fill=(176, 74, 210, 210))
    dr.point((6, 8 + o), fill=(255, 240, 255, 255))
    dr.point((10, 8 + o), fill=(255, 240, 255, 255))
    for k in range(3):
        dr.point((2 + k * 5, 1 + (k % 2)), fill=(224, 92, 255, 200))
    return im


def draw_golem(i):
    im = img(32, 32)
    dr = ImageDraw.Draw(im)
    o = (0, 1)[i]
    body = (108, 96, 82, 255)
    dr.rectangle([6, 8 + o, 25, 27], fill=body)
    dr.rectangle([4, 10 + o, 7, 22], fill=(84, 74, 62, 255))
    dr.rectangle([24, 10 + o, 27, 22], fill=(84, 74, 62, 255))
    dr.rectangle([10, 3 + o, 21, 10], fill=(126, 112, 96, 255))
    dr.rectangle([12, 5 + o, 19, 7], fill=(255, 204, 102, 255))
    dr.rectangle([10, 20, 15, 30], fill=(84, 74, 62, 255))
    dr.rectangle([18, 20, 23, 30], fill=(84, 74, 62, 255))
    for x, y in ((9, 14), (16, 17), (22, 12), (13, 24)):
        dr.point((x, y + o), fill=(255, 204, 102, 180))
    return im


def draw_warden(i):
    im = img(32, 32)
    dr = ImageDraw.Draw(im)
    o = (0, 1)[i]
    dr.polygon([(16, 1 + o), (28, 8 + o), (26, 26), (6, 26), (4, 8 + o)], fill=(74, 62, 46, 255))
    dr.polygon([(16, 5 + o), (24, 10 + o), (23, 22), (9, 22), (8, 10 + o)], fill=(150, 116, 64, 255))
    dr.rectangle([12, 10 + o, 20, 13], fill=(255, 204, 102, 255))
    dr.line([16, 14 + o, 16, 21], fill=(255, 244, 208, 160))
    dr.rectangle([2, 12 + o, 6, 26], fill=(58, 48, 36, 255))
    dr.rectangle([26, 12 + o, 30, 26], fill=(58, 48, 36, 255))
    return im


def draw_sovereign(i):
    im = img(48, 48)
    dr = ImageDraw.Draw(im)
    o = (0, 2)[i]
    dr.polygon([(24, 2 + o), (40, 12 + o), (38, 40), (10, 40), (8, 12 + o)], fill=(30, 22, 48, 255))
    dr.polygon([(24, 6 + o), (35, 14 + o), (33, 36), (15, 36), (13, 14 + o)], fill=(66, 40, 104, 255))
    dr.rectangle([17, 16 + o, 31, 21], fill=(224, 92, 255, 255))
    dr.rectangle([20, 17 + o, 22, 19], fill=(255, 255, 255, 255))
    # mahkota
    for k in range(5):
        dr.polygon([(14 + k * 5, 6 + o), (16 + k * 5, 1 + o), (18 + k * 5, 6 + o)],
                   fill=(255, 226, 255, 255))
    dr.line([12, 30, 36, 30], fill=(224, 92, 255, 140))
    for k in range(4):
        dr.point((16 + k * 6, 34), fill=(255, 226, 255, 150))
    return im


# -------------------------------------------------------------------- item
def draw_item(name, size, box, col, extra=None):
    im = img(*size)
    dr = ImageDraw.Draw(im)
    dr.rectangle(box, fill=col)
    if extra:
        extra(dr)
    p = os.path.join(ROOT, "assets", "sprites", "items", f"{name}.png")
    os.makedirs(os.path.dirname(p), exist_ok=True)
    im.save(p)


def build_items():
    frag = img(10, 10)
    d = ImageDraw.Draw(frag)
    d.polygon([(5, 1), (9, 3), (9, 7), (5, 9), (1, 7), (1, 3)], fill=(122, 232, 212, 255),
              outline=(236, 255, 251, 255))
    d.point((4, 4), fill=(18, 60, 56, 255))
    os.makedirs(os.path.join(ROOT, "assets/sprites/items"), exist_ok=True)
    frag.save(os.path.join(ROOT, "assets/sprites/items/fragment.png"))

    def crystal(dr):
        dr.line([6, 1, 6, 12], fill=(226, 200, 255, 200))
        dr.point((4, 5), fill=(255, 255, 255, 220))
    draw_item("memory_crystal", (12, 14), [2, 2, 9, 12], (150, 110, 220, 255), crystal)

    def core(dr):
        dr.polygon([(6, 2), (10, 6), (6, 11), (2, 6)], fill=(255, 214, 120, 255))
        dr.point((6, 6), fill=(80, 54, 12, 255))
    draw_item("logic_core", (12, 14), [2, 2, 9, 12], (150, 108, 28, 255), core)

    def key(dr):
        dr.rectangle([2, 3, 6, 6], outline=(255, 244, 208, 255))
        dr.line([6, 5, 11, 5], fill=(255, 204, 102, 255), width=2)
        dr.line([9, 5, 9, 8], fill=(255, 204, 102, 255), width=2)
    draw_item("schema_key", (14, 12), [1, 1, 1, 1], (120, 90, 30, 200), key)

    def record(dr):
        for y in (4, 6, 8):
            dr.line([3, y, 8, y], fill=(210, 230, 226, 200))
    draw_item("ancient_record", (12, 14), [2, 2, 8, 10], (72, 108, 104, 255), record)

    def cell(dr):
        dr.line([5, 1, 3, 6], fill=(220, 255, 220, 255))
        dr.line([3, 6, 6, 6], fill=(220, 255, 220, 255))
        dr.line([6, 6, 4, 11], fill=(220, 255, 220, 255))
        dr.rectangle([0, 0, 7, 12], outline=(120, 220, 140, 255))
    draw_item("energy_cell", (8, 13), [0, 0, 0, 0], (40, 90, 50, 255), cell)


# ---------------------------------------------------------------------- UI
def build_ui():
    out = os.path.join(ROOT, "assets", "sprites", "ui")
    os.makedirs(out, exist_ok=True)

    heart = img(9, 8)
    d = ImageDraw.Draw(heart)
    d.polygon([(4, 1), (7, 2), (8, 4), (4, 7), (0, 4), (1, 2)], fill=(230, 76, 96, 255))
    d.point((3, 2), fill=(255, 190, 200, 255))
    heart.save(os.path.join(out, "heart_full.png"))

    heart_e = img(9, 8)
    d = ImageDraw.Draw(heart_e)
    d.polygon([(4, 1), (7, 2), (8, 4), (4, 7), (0, 4), (1, 2)], fill=(70, 44, 52, 255))
    heart_e.save(os.path.join(out, "heart_empty.png"))

    for name, col in (("fragment_icon", (122, 232, 212)), ("energy_icon", (110, 230, 140)),
                      ("crystal_icon", (170, 130, 240)), ("key_icon", (255, 204, 102))):
        im = img(10, 10)
        d = ImageDraw.Draw(im)
        d.polygon([(5, 0), (9, 3), (9, 7), (5, 9), (1, 7), (1, 3)], fill=col + (255,))
        im.save(os.path.join(out, f"{name}.png"))

    # ikon skill 16x16
    scan = img(16, 16)
    d = ImageDraw.Draw(scan)
    for r in (4, 7):
        d.arc([8 - r, 8 - r, 8 + r, 8 + r], 200, 340, fill=(122, 232, 212, 255))
    d.point((8, 8), fill=(236, 255, 251, 255))
    scan.save(os.path.join(out, "skill_scan.png"))

    strike = img(16, 16)
    d = ImageDraw.Draw(strike)
    d.polygon([(2, 8), (11, 3), (11, 6), (14, 6), (14, 10), (11, 10), (11, 13)],
              fill=(255, 204, 102, 255))
    strike.save(os.path.join(out, "skill_strike.png"))

    bridge = img(16, 16)
    d = ImageDraw.Draw(bridge)
    d.rectangle([2, 4, 5, 11], fill=(122, 232, 212, 255))
    d.rectangle([10, 4, 13, 11], fill=(255, 204, 102, 255))
    d.line([5, 7, 10, 7], fill=(236, 255, 251, 255), width=2)
    bridge.save(os.path.join(out, "skill_bridge.png"))

    empty = img(16, 16)
    d = ImageDraw.Draw(empty)
    d.rectangle([1, 1, 14, 14], outline=(120, 140, 150, 255))
    empty.save(os.path.join(out, "skill_empty.png"))

    # pedestal, terminal, sync point, anchor, column
    ped = img(16, 22)
    d = ImageDraw.Draw(ped)
    d.rectangle([3, 16, 12, 21], fill=(96, 112, 120, 255))
    d.rectangle([2, 12, 13, 16], fill=(140, 160, 170, 255))
    d.rectangle([5, 4, 10, 12], fill=(122, 232, 212, 200))
    d.line([5, 4, 10, 4], fill=(236, 255, 251, 255))
    ped.save(os.path.join(out, "pedestal.png"))

    term = img(18, 24)
    d = ImageDraw.Draw(term)
    d.rectangle([1, 4, 16, 23], fill=(44, 58, 66, 255), outline=(122, 232, 212, 255))
    d.rectangle([3, 7, 14, 13], fill=(30, 44, 50, 255))
    for y in (9, 11):
        d.line([4, y, 12, y], fill=(122, 232, 212, 200))
    d.rectangle([5, 16, 12, 18], fill=(122, 232, 212, 120))
    term.save(os.path.join(out, "terminal.png"))

    sync = img(16, 26)
    d = ImageDraw.Draw(sync)
    d.rectangle([2, 16, 13, 25], fill=(70, 86, 96, 255))
    d.polygon([(8, 0), (14, 8), (8, 16), (2, 8)], fill=(122, 232, 212, 140),
              outline=(236, 255, 251, 255))
    sync.save(os.path.join(out, "sync_point.png"))

    for name, col in (("anchor_pk", (255, 204, 102)), ("anchor_fk", (122, 232, 212))):
        im = img(14, 18)
        d = ImageDraw.Draw(im)
        d.rectangle([1, 1, 12, 16], fill=(24, 34, 40, 220), outline=col + (255,))
        d.rectangle([4, 5, 9, 12], fill=col + (90,))
        d.line([4, 8, 9, 8], fill=col + (255,))
        im.save(os.path.join(out, f"{name}.png"))

    col_im = img(16, 26)
    d = ImageDraw.Draw(col_im)
    d.rectangle([2, 4, 13, 25], fill=(30, 42, 50, 220), outline=(122, 232, 212, 255))
    d.polygon([(8, 6), (12, 12), (8, 22), (4, 12)], fill=(122, 232, 212, 170))
    col_im.save(os.path.join(out, "crystal_column.png"))

    orb = img(12, 12)
    d = ImageDraw.Draw(orb)
    d.ellipse([1, 1, 10, 10], fill=(120, 40, 150, 255), outline=(255, 226, 255, 255))
    d.point((5, 4), fill=(255, 255, 255, 255))
    orb.save(os.path.join(out, "null_orb.png"))

    icon = img(64, 64)
    d = ImageDraw.Draw(icon)
    d.rectangle([2, 2, 61, 61], fill=(22, 34, 40, 255), outline=(122, 232, 212, 255))
    d.polygon([(32, 8), (52, 24), (46, 54), (18, 54), (12, 24)], fill=(122, 232, 212, 90),
              outline=(236, 255, 251, 255))
    d.line([24, 40, 32, 26, 40, 40], fill=(255, 204, 102, 255), width=3)
    icon.save(os.path.join(out, "icon.png"))


# -------------------------------------------------------------- background
def build_background(key, pal):
    w, h = 480, 270
    im = img(w, h)
    dr = ImageDraw.Draw(im)
    for y in range(h):
        f = 1.0 - y / h * 0.55
        dr.line([0, y, w, y], fill=shade(pal["dark"], 0.55 + 0.5 * f) )
    # grid halus
    for x in range(0, w, 32):
        dr.line([x, 0, x, h], fill=shade(pal["glow"], 1.0)[:3] + (40,))
    for y in range(0, h, 32):
        dr.line([0, y, w, y], fill=shade(pal["glow"], 1.0)[:3] + (40,))
    # siluet rack / menara
    for i in range(14):
        bx = rnd.randint(-20, w)
        bw = rnd.randint(18, 46)
        bh = rnd.randint(40, 150)
        dr.rectangle([bx, h - bh, bx + bw, h], fill=shade(pal["dark"], 0.72))
        for wy in range(h - bh + 8, h - 8, 12):
            for wx in range(bx + 4, bx + bw - 4, 8):
                if rnd.random() < 0.35:
                    dr.point((wx, wy), fill=shade(pal["accent"], 0.5))
    # heksagon melayang
    for i in range(9):
        cx, cy, r = rnd.randint(0, w), rnd.randint(20, 200), rnd.randint(6, 18)
        pts = [(cx + int(r * 0.9 * a), cy + int(r * 0.9 * b))
               for a, b in ((1, 0), (0.5, 0.85), (-0.5, 0.85), (-1, 0), (-0.5, -0.85), (0.5, -0.85))]
        dr.polygon(pts, outline=shade(pal["accent"], 0.55)[:3] + (120,))
    out = os.path.join(ROOT, "assets", "backgrounds", f"{key}.png")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    im.save(out)


def main():
    for key, pal in REGIONS.items():
        build_tileset(key, pal)
        build_background(key, pal)
    build_player()
    for name, draw, size in (
        ("glitch_blob", draw_blob, (16, 16)),
        ("duplicate_slime", draw_slime, (16, 16)),
        ("orphan_glitch", draw_orphan, (16, 16)),
        ("duplicate_golem", draw_golem, (32, 32)),
        ("composite_warden", draw_warden, (32, 32)),
        ("null_sovereign", draw_sovereign, (48, 48)),
    ):
        enemy_sheet(name, [0, 1], size, draw)
    build_items()
    build_ui()
    print("artgen: selesai")


if __name__ == "__main__":
    main()
