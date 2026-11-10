# Outline Presentasi Minggu 2 — Relational Data Chronicles

Slide total: 8 slide + 1 slide Q&A (opsional).
Durasi demo: 3 menit (Start → Level Select → L1 → L2 → L3 → End Session).
Rekaman layar: `docs/progress/week2/` (7 PNG). GIF 30 detik bila ffmpeg tersedia Minggu 3.

---

## Slide 1 — Konteks & Tim
- Judul proyek: **Relational Data Chronicles: The Lost Schema**
- Mata kuliah: **Basis Data** (Pengenalan Model Data Relasional)
- Tim Kelompok 9:
  - **Project + Level Manager:** Mohammad Hafidz Suhaiby
  - **Artist:** Muhammad Naufal Zhafran
  - **Programmer:** Mohammad Ikhsan Ridho
- **Status jujur:** Minggu 1 kosong — pengejaran di Minggu 2 (1 minggu kerja = 14 jam aktif).
- Engine: **Godot 4.7.2 (GDScript, Compatibility renderer)**. Target: **HTML5 (Web)**.

---

## Slide 2 — Desain Inti (Core Loop & Pemetaan Materi)
| Skill | Tombol | Konsep Basis Data | Mekanik |
|---|---|---|---|
| **Data Scan** | 1 | Atribut, domain, record | Gelombang radius → kolom/nilai tabel terlihat (alias `scannable`) |
| **Unique Strike** | 3 | Primary Key (unik, tidak NULL) | Terjang → pecah kristal hanya bila kolom unik; duplikat/NULL ditolak |
| **Relation Bridge** | 5 | Foreign Key, referential integrity | Klik FK Anchor → PK Anchor; valid = jembatan; invalid = Orphan Glitch |

*Skill Schema Vision & Query Pulse → Minggu 3 (P1).*

---

## Slide 3 — 3 Level & Progres
| Level | Region | Konsep | Guardian | Skill Diperoleh |
|---|---|---|---|---|
| **L1** | Record Ruins (teal/abu) | Relation, tuple, attribute, domain | Duplicate Golem (20 HP) | Data Scan |
| **L2** | Key Citadel (amber/perunggu) | Superkey, candidate key, PK, NULL, composite key | Composite Warden (25 HP) | Unique Strike |
| **L3** | Foreign Spire (ungu-magenta) | FK, referential integrity, orphan record | Null Sovereign (40 HP, 2 fase) | Relation Bridge |

Masing-masing: 4–5 room, ≥40 Data Fragment, 1 Memory Crystal, 2 Ancient Record, 1 Schema Key.

---

## Slide 4 — Progres Nyata (MIN-W2: P0 selesai)

| ID | Fitur | Status | Bukti |
|---|---|---|---|
| W2-01 | Repo + Autoload + InputMap + Settings | ✅ Done | `git log`, `autoload/*.gd` |
| W2-02 | Aset terpilih tampil di game | ✅ Done | `docs/progress/week2/*.png` |
| W2-03 | Player nyata (animasi + collision) | ✅ Done | `scenes/player/player.tscn` |
| W2-04 | TileSet solid + physics layer | ✅ Done | `assets/tilesets/l1.tres` + check_nodes |
| W2-05 | HUD live (Health, Energy, XP, Rank) | ✅ Done | `scripts/ui/hud.gd` + EventBus |
| W2-06 | 6 collectible berfungsi | ✅ Done | `scenes/items/*.tscn` |
| W2-07 | **Level 1 playable** (R1-1..R1-4) | ✅ Done | `data/levels/L1.json` + `pk_barrier` L1_P01 |
| W2-08 | **Level 2 playable** (R2-1..R2-4) | ✅ Done | L2_P01, P02 (NULL), P03 (composite) |
| W2-09 | **Level 3 playable** (R3-1..R3-5) | ✅ Done | `relation_bridge`, Orphan Glitch, Null Sovereign |
| W2-10 | Start / Level Select / End Session | ✅ Done | 7 screenshot |
| W2-11 | Audio: 3 musik + 12 SFX | ✅ Done | `assets/audio/` |
| W2-12 | **Lint 0 ERROR + Web export** | ✅ Done | `check_nodes.py`, `build/web/` (HTTP 200) |
| W2-13 | Trello + GitHub + laporan | ✅ Done | `reports/trello_updates/`, `git tag v0.2-week2` |
| W2-14–17 | P1 (Market, Save, Difficulty, Cache) | ⏳ Partial / Not Done | Direncanakan Minggu 3–4 |

---

## Slide 5 — Demo Alur (3 menit)
1. **Start Screen** → Play → Level 1 (Data Scan, PK Barrier, Guardian, Schema Key)
2. **Level Select** (L2 terbuka) → Level 2 (Unique Strike, 3 PK Barrier, Guardian)
3. **Level Select** (L3 terbuka) → Level 3 (Relation Bridge, Orphan Glitch, Boss Null Sovereign)
4. **End Session (Menang)** → statistik (waktu, Fragments, Logic Level, Knowledge Rank)

*Tangkapan layar pendukung: `01_menu.png` → `07_end_session.png`.*

---

## Slide 6 — Aset & Lisensi
- **100% aset buatan tim** (prosedural via `tools/artgen.py`, `tools/audio_gen.py`):
  - 8 animasi pemain (idle, run, jump, fall, attack, hurt, death, cast)
  - 5 varian musuh (blob, slime, orphan, golem, warden) + boss Null Sovereign
  - 6 collectible, 18 ikon UI, 3 tileset region + background
  - 3 musik loop + 12 SFX (sintesis gelombang)
- **Pihak ketiga:**
  - Font *Press Start 2P* & *VT323* — SIL OFL 1.1
  - Godot Engine 4.7.2 — MIT
- **Keputusan:** tidak memakai pack itch.io (CC0) karena risiko gaya bentrok & lisensi tak pasti.
- Tercatat lengkap di `ASSETS.md` & `docs/assets/asset_selection.md`.

---

## Slide 7 — Pemenuhan Spesifikasi Proyek (minimal)
| Syarat Proyek | Pemenuhan |
|---|---|
| Genre 2D (bukan novel/runner) | ✅ Metroidvania/puzzle platformer |
| Output Web (HTML5) | ✅ `build/web/index.html` (Export Compatibility) |
| Kontrol keyboard + mouse | ✅ A/D/Space/E + klik (attack) |
| ≥3 atribut | ✅ 5 (Health, Energy, XP/Level, Fragments, Rank) |
| ≥3 collectible | ✅ 6 (Fragment, Crystal, Key, Record, Cell, Core) |
| Ekonomi (Market + bonus Level) | ✅ MarketManager ada; bonus level 4/7 (+10 Energy) |
| Audio | ✅ 3 musik + 12 SFX |
| Aset berlisensi | ✅ Buatan tim + OFL font + MIT engine |
| ≥3 level berkisah + materi DB | ✅ 3 level → PK, FK, orphan, NULL, composite |
| Layar: Start/Level Select/Session/End/About | ✅ Semua berfungsi + screenshot |

---

## Slide 8 — Metrik & Risiko Minggu 3–4
**Metrik Minggu 2:**
- 31 scene `.tscn` | 40 script `.gd` | 2.520 baris kode
- 0 ERROR `check_nodes.py` | Autotest 19/19 pass
- Build Web 39 MB | 7 bukti visual

**Risiko & Mitigasi:**
| Risiko | Mitigasi |
|---|---|
| Waktu ketat (Minggu 1 kosong) | Fokus P0 dulu; P1 pangkas ke Minggu 3–4 |
| Backtracking / Hub belum ada | `ExitMarker.target_room` sudah siap; Minggu 3 hubungkan ke Hub |
| Alpha Test bug UX | Functional Test lengkap Minggu 3; kuesioner singkat |
| Export Web fitur tidak didukung | Renderer Compatibility, tanpa thread, shader ringan |

**Rencana Minggu 3 (P1):**
Schema Vision, Query Pulse, Hub + backtracking, Market lengkap, Save/Load, Corrupted Cache, Difficulty modes, 18 Ancient Record, Functional Test lengkap, **Alpha Test**.

---

*Disusun oleh Hermes Agent (Hermes) — Kelompok 9 — 10 November 2026*