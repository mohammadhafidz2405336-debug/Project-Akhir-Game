#!/usr/bin/env python3
"""
levelgen.py - penulis data level (data/levels/*.json) + validator kelayakan.

Peta disimpan sebagai array string ASCII, satu karakter = satu tile 16 px:
    '#' blok solid   '=' platform tipis   'G' platform hantu (scannable)
    '.' kosong       '^' duri (spike)

Entitas diletakkan dalam tile: x = kolom, y = baris permukaan tempat ia berdiri.

Validator menolak level yang tidak bisa dimainkan:
  - entitas darat yang tidak berdiri di atas tile solid
  - jurang lebih lebar dari 5 tile (jangkauan lompat ~5 tile)
  - platform yang tidak terjangkau (naik > 2 tile dari pijakan sebelumnya)

    python3 tools/levelgen.py
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAX_GAP = 5
MAX_STEP_UP = 2


class Level:
    def __init__(self, lid, name, w, h, ground_row, bg):
        self.id, self.name, self.w, self.h = lid, name, w, h
        self.ground = ground_row
        self.bg = bg
        self.g = [["." for _ in range(w)] for _ in range(h)]
        self.entities = []
        self.rooms = []
        self.hints = []
        self.fill(0, ground_row, w - 1, h - 1, "#")

    def fill(self, x0, y0, x1, y1, ch):
        for y in range(max(0, y0), min(self.h, y1 + 1)):
            for x in range(max(0, x0), min(self.w, x1 + 1)):
                self.g[y][x] = ch

    def pit(self, x0, x1):
        """Jurang: hapus lantai. Lebar harus <= MAX_GAP."""
        assert x1 - x0 + 1 <= MAX_GAP, f"{self.id}: jurang {x1 - x0 + 1} tile terlalu lebar"
        self.fill(x0, self.ground, x1, self.h - 1, ".")

    def plat(self, x0, x1, row, ch="="):
        self.fill(x0, row, x1, row, ch)

    def room(self, rid, x0, x1, name, hint=""):
        self.rooms.append({"id": rid, "x0": x0, "x1": x1, "nama": name, "hint": hint})

    def add(self, typ, x, y, **kw):
        e = {"type": typ, "x": x, "y": y}
        e.update(kw)
        self.entities.append(e)

    # ---- prefab entitas ----
    def fragments(self, x0, x1, y, step=4, amount=5):
        x = x0
        while x <= x1:
            self.add("pickup", x, y, kind="fragment", amount=amount, dy=-1)
            x += step

    def blobs(self, xs, y):
        for x in xs:
            self.add("enemy", x, y, kind="glitch_blob")

    def slimes(self, xs, y, split=True):
        for x in xs:
            self.add("enemy", x, y, kind="duplicate_slime", split=split)

    def hint(self, x, y, text, w=64):
        self.hints.append({"x": x, "y": y, "text": text, "w": w})

    def validate(self):
        solids = ("#", "=", "G")
        for e in self.entities:
            ex, ey = e["x"], e["y"]
            assert 0 <= ex < self.w, f"{self.id}: entitas di luar peta x={ex}"
            ground_ok = 0 <= ey < self.h and self.g[ey][ex] in solids
            floating = e["type"] in ("pickup", "hint_area", "fk_anchor", "pk_anchor")
            assert ground_ok or floating or e.get("dy", 0) < 0, \
                f"{self.id}: {e['type']} di x={ex},y={ey} tidak berdiri di atas tile solid"
        # lebar jurang
        run = 0
        for x in range(self.w):
            if self.g[self.ground][x] == ".":
                run += 1
                assert run <= MAX_GAP, f"{self.id}: jurang {run} tile di x={x}"
            else:
                run = 0
        # keterjangkauan platform: setiap baris platform <= 2 tile di atas pijakan
        rows = sorted({y for y in range(self.h) for x in range(self.w) if self.g[y][x] in solids})
        prev = None
        for y in rows:
            if prev is not None and prev - y > MAX_STEP_UP and y != 0:
                # baris lebih tinggi (y kecil) harus punya pijakan <= 2 tile di bawahnya
                reachable = any(
                    self.g[y + d][x] in solids
                    for d in range(1, MAX_STEP_UP + 1)
                    for x in range(self.w)
                    if self.g[y][x] in solids
                )
                assert reachable, f"{self.id}: baris {y} tidak terjangkau (naik > {MAX_STEP_UP} tile)"
            prev = y
        assert len(self.rooms) >= 3, f"{self.id}: butuh minimal 3 room"
        return self

    def to_dict(self):
        rows = ["".join(r) for r in self.g]
        return {
            "id": self.id, "nama": self.name, "width": self.w, "height": self.h,
            "ground_row": self.ground, "background": self.bg,
            "spawn": {"x": 3, "y": self.ground},
            "map": rows, "rooms": self.rooms, "entities": self.entities, "hints": self.hints,
        }


# ------------------------------------------------------------------ LEVEL 1
def level1():
    L = Level("L1", "Record Ruins", 152, 20, 15, "res://assets/backgrounds/l1.png")
    L.room("R1-1", 0, 39, "Gerbang Reruntuhan",
           "A/D bergerak, Space lompat, J serang, E berinteraksi. Cursor mengikutimu.")
    L.room("R1-2", 40, 75, "Scanner Chamber", "Ambil Data Scan di pedestal (tekan E), lalu tekan 1.")
    L.room("R1-3", 76, 119, "Corrupted Table Terminal",
           "Terminal tabel: cocokkan nilai ke kolom yang domainnya benar.")
    L.room("R1-4", 120, 151, "Duplicate Golem", "Kalahkan Duplicate Golem untuk Schema Key.")

    L.pit(11, 13)                      # jurang kecil di R1-1
    L.fragments(5, 10, L.ground)
    L.fragments(15, 34, L.ground, step=3)
    L.blobs([18, 27], L.ground)
    L.add("sync_point", 34, L.ground)
    L.hint(6, L.ground - 3, "Cursor: 'Data Realm runtuh. Null Corruption mengubah nilai jadi NULL.'")

    # R1-2 : pedestal + platform hantu menuju Ancient Record
    L.add("pedestal", 46, L.ground, skill="scan")
    L.plat(52, 54, L.ground - 2, "G")
    L.plat(57, 59, L.ground - 4, "G")
    L.plat(62, 71, L.ground - 4, "=")
    L.add("pickup", 66, L.ground - 4, kind="ancient_record", cid="L1_AR_01", dy=-1)
    L.fragments(44, 50, L.ground)

    # R1-3 : terminal + dinding rahasia
    L.add("terminal", 84, L.ground, puzzle="L1_P01")
    L.fill(96, L.ground - 3, 97, L.ground - 1, "#")
    L.add("secret_wall", 96, L.ground, w=2, h=3)
    L.fill(98, L.ground - 5, 104, L.ground - 5, "#")   # atap ruang rahasia
    L.add("pickup", 100, L.ground, kind="memory_crystal", cid="L1_MC_01", dy=-1)
    L.add("pickup", 103, L.ground, kind="ancient_record", cid="L1_AR_02", dy=-1)
    L.add("gate", 108, L.ground, puzzle="L1_P01")
    L.blobs([90, 106], L.ground)
    L.fragments(80, 94, L.ground, step=3)

    # R1-4 : arena golem
    L.add("gate", 122, L.ground, puzzle="__arena__", closes=True)
    L.add("enemy", 138, L.ground, kind="duplicate_golem", guardian=True, key="L1_KEY")
    L.add("exit_marker", 149, L.ground, target="level_select")
    L.hint(126, L.ground - 3, "Arena tertutup! Kalahkan Duplicate Golem (HP 20).")
    L.fragments(124, 130, L.ground)
    return L.validate()


# ------------------------------------------------------------------ LEVEL 2
def level2():
    L = Level("L2", "Key Citadel", 156, 22, 17, "res://assets/backgrounds/l2.png")
    L.room("R2-1", 0, 41, "Gerbang Benteng", "Pedestal Unique Strike ada di depan; tekan E lalu 3.")
    L.room("R2-2", 42, 77, "PK Barrier I", "Hanya kolom yang benar-benar unik yang memecahkan kristal.")
    L.room("R2-3", 78, 119, "PK Barrier II (NULL)", "Periksa NULL: primary key tidak boleh NULL.")
    L.room("R2-4", 120, 155, "Composite Warden", "Pukul kristal NIM lalu KodeMK dalam 2 detik.")

    L.pit(16, 19)
    L.add("sync_point", 8, L.ground)
    L.slimes([24, 30, 36], L.ground)
    L.add("pedestal", 34, L.ground, skill="strike")
    L.fragments(10, 40, L.ground, step=4)
    L.hint(4, L.ground - 3, "Duplicate Slime terbelah dua saat mati. Hati-hati.")

    # R2-2 : PK Barrier I (kolom NIM)
    L.add("pk_barrier", 62, L.ground, puzzle="L2_P01", w=3, h=5)
    L.add("pickup", 70, L.ground, kind="ancient_record", cid="L2_AR_01", dy=-1)
    L.fragments(66, 74, L.ground)
    L.plat(50, 54, L.ground - 2, "=")

    # R2-3 : PK Barrier II (NULL)
    L.pit(88, 91)
    L.add("pk_barrier", 98, L.ground, puzzle="L2_P02", w=3, h=5)
    L.add("secret_wall", 110, L.ground, w=2, h=3)
    L.fill(112, L.ground - 5, 118, L.ground - 5, "#")
    L.add("pickup", 114, L.ground, kind="memory_crystal", cid="L2_MC_01", dy=-1)
    L.add("pickup", 117, L.ground, kind="ancient_record", cid="L2_AR_02", dy=-1)
    L.fragments(80, 95, L.ground, step=3)

    # R2-4 : composite + Warden
    L.add("gate", 121, L.ground, puzzle="__arena__", closes=True)
    L.add("pk_barrier", 132, L.ground, puzzle="L2_P03", w=3, h=5, composite=True)
    L.add("enemy", 142, L.ground, kind="composite_warden", guardian=True, key="L2_KEY", warden=True)
    L.add("exit_marker", 153, L.ground, target="level_select")
    L.fragments(124, 130, L.ground)
    L.hint(125, L.ground - 3, "Kristal NIM dan KodeMK harus dipukul berurutan (2 detik).")
    return L.validate()


# ------------------------------------------------------------------ LEVEL 3
def level3():
    L = Level("L3", "Foreign Spire", 156, 30, 25, "res://assets/backgrounds/l3.png")
    L.room("R3-1", 0, 37, "Dasar Menara", "Ambil Relation Bridge; buat link FK -> PK untuk menyeberang.")
    L.room("R3-2", 38, 79, "Dua Jembatan", "Maksimal 2 jembatan aktif, masing-masing 20 detik.")
    L.room("R3-3", 80, 119, "Orphan Trap", "FK 7 tidak punya induk. Perbaiki nilainya di terminal.")
    L.room("R3-4", 120, 137, "Menara Vertikal", "Naik lewat platform; awas Orphan Glitch.")
    L.room("R3-5", 138, 155, "Null Sovereign", "Buat link valid untuk memecahkan perisai boss.")

    L.add("sync_point", 6, L.ground)
    L.add("pedestal", 20, L.ground, skill="bridge")
    L.fragments(8, 36, L.ground, step=4)
    # R3-1: tabel Dosen (PK) & MataKuliah (FK) mengapit jurang
    L.pit(26, 30)
    L.add("pk_anchor", 24, L.ground - 3, value="1", label="id_dosen", dy=-3)
    L.add("pk_anchor", 24, L.ground - 6, value="2", label="id_dosen", dy=-6)
    L.add("pk_anchor", 24, L.ground - 9, value="3", label="id_dosen", dy=-9)
    L.add("fk_anchor", 33, L.ground - 3, value="2", label="MK01.id_dosen", dy=-3)
    L.hint(12, L.ground - 3, "Tekan 5 di dekat FK Anchor, lalu 5 lagi di PK Anchor tujuan.")

    # R3-2: dua jurang
    L.pit(46, 50)
    L.pit(60, 64)
    L.add("pk_anchor", 44, L.ground - 2, value="2", label="id_dosen", dy=-2)
    L.add("fk_anchor", 52, L.ground - 2, value="2", label="MK01.id_dosen", dy=-2)
    L.add("pk_anchor", 58, L.ground - 2, value="1", label="id_dosen", dy=-2)
    L.add("fk_anchor", 66, L.ground - 2, value="1", label="MK02.id_dosen", dy=-2)
    L.add("pickup", 72, L.ground, kind="memory_crystal", cid="L3_MC_01", dy=-1)
    L.fragments(54, 72, L.ground, step=4)

    # R3-3: orphan trap + terminal perbaikan
    L.pit(90, 94)
    L.add("pk_anchor", 84, L.ground - 2, value="1", label="id_dosen", dy=-2)
    L.add("pk_anchor", 84, L.ground - 5, value="2", label="id_dosen", dy=-5)
    L.add("pk_anchor", 84, L.ground - 8, value="3", label="id_dosen", dy=-8)
    L.add("fk_anchor", 96, L.ground - 2, value="7", label="MK03.id_dosen", accepts=[], dy=-2)
    L.add("fk_fix_terminal", 100, L.ground, puzzle="L3_P01")
    L.add("pickup", 108, L.ground, kind="ancient_record", cid="L3_AR_01", dy=-1)
    L.add("pickup", 112, L.ground, kind="ancient_record", cid="L3_AR_02", dy=-1)
    L.fragments(98, 116, L.ground, step=4)

    # R3-4: menara vertikal
    L.fill(120, L.ground - 2, 120, L.ground - 1, "#")
    for i, row in enumerate([L.ground - 3, L.ground - 5, L.ground - 7, L.ground - 9]):
        L.plat(122 + (i % 2) * 3, 126 + (i % 2) * 3, row, "=")
    L.add("enemy", 126, L.ground - 9, kind="orphan_glitch", dy=-9)
    L.add("enemy", 124, L.ground, kind="orphan_glitch")
    L.fragments(122, 130, L.ground - 9, step=3)

    # R3-5: arena boss
    L.add("gate", 138, L.ground, puzzle="__arena__", closes=True)
    L.add("pk_anchor", 143, L.ground - 4, value="1", label="id_dosen", dy=-4)
    L.add("pk_anchor", 143, L.ground - 7, value="2", label="id_dosen", dy=-7)
    L.add("fk_anchor", 151, L.ground - 4, value="2", label="MK01.id_dosen", dy=-4)
    L.add("fk_anchor", 151, L.ground - 7, value="1", label="MK02.id_dosen", dy=-7)
    L.add("boss", 147, L.ground - 6, kind="null_sovereign", dy=-6)
    L.hint(139, L.ground - 3, "Perisai Null Sovereign hanya pecah oleh Relation Bridge yang valid.")
    return L.validate()


def main():
    out = os.path.join(ROOT, "data", "levels")
    os.makedirs(out, exist_ok=True)
    for lv in (level1(), level2(), level3()):
        d = lv.to_dict()
        frags = sum(e.get("amount", 1) for e in d["entities"]
                    if e["type"] == "pickup" and e.get("kind") == "fragment")
        assert frags >= 40, f"{lv.id}: fragment hanya {frags}, minimal 40"
        with open(os.path.join(out, f"{lv.id}.json"), "w") as f:
            json.dump(d, f, indent=1)
        print(f"{lv.id} {lv.name}: {lv.w}x{lv.h} tile, {len(d['entities'])} entitas, "
              f"{len(d['rooms'])} room, {frags} fragment")


if __name__ == "__main__":
    main()
