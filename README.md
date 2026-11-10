# Relational Data Chronicles: The Lost Schema

Game edukasi 2D action-puzzle platformer untuk mata kuliah **Basis Data** (materi Pengenalan Model Data Relasional).
Dibuat dengan **Godot 4.7.2-stable** (GDScript, renderer Compatibility), diekspor ke **HTML5/Web**.

**Kelompok 9**

| Peran | Nama |
|---|---|
| Project + Level Manager | Mohammad Hafidz Suhaiby |
| Artist | Muhammad Naufal Zhafran |
| Programmer | Mohammad Ikhsan Ridho |

## Versi dan cara menjalankan

- Godot **4.7.2.stable.official** (`ed1daf0bf`). Jangan mencampur versi lain.
- Buka folder ini sebagai project (`project.godot`), atau dari terminal:

```bash
godot --headless --path . --import                 # impor aset
godot --path .                                     # mainkan (main scene: MainMenu)
python tools/check_nodes.py                        # linter anti node kosong (wajib 0 ERROR)
godot --headless --path . -- --autotest            # smoke test otomatis (19 pemeriksaan)
godot --headless --path . --export-release "Web" build/web/index.html
python -m http.server 8000 --directory build/web   # uji di http://localhost:8000
```

Tangkapan layar bukti: `docs/progress/week2/`. Laporan harian: `docs/progress/week-2.md`.

## Kontrol

| Aksi | Tombol |
|---|---|
| Gerak | A/D atau ←/→ |
| Lompat | Space / W / ↑ |
| Data Slash (serangan) | J atau klik kiri |
| Interaksi (terminal, pedestal, sync point) | E |
| Skill 1 Data Scan / 3 Unique Strike / 5 Relation Bridge | 1 / 3 / 5 |
| Jeda | Esc / P |

## Struktur

```
docs/HERMES_GDD.md      spesifikasi lengkap (sumber kebenaran desain)
autoload/               EventBus, GameState, SaveManager, AudioManager, SkillManager, MarketManager, RoomManager
data/levels/            peta ASCII tiap level (dicat level_base.gd)
data/puzzles/           data puzzle PK/FK (L1_P01, L2_P01-P03, L3_P01)
scenes/ scripts/        player, enemies, puzzle, skills, ui, levels, world
tools/                  check_nodes.py (linter), artgen.py, audio_gen.py, levelgen.py, scenegen.py (generator scene)
assets/                 sprites, tilesets, backgrounds, audio, fonts — semua tercatat di ASSETS.md
```

## Aset

Seluruh sprite, tileset, musik, dan SFX dibuat sendiri lewat skrip Python (Pillow + sintesis gelombang)
di `tools/artgen.py` dan `tools/audio_gen.py` — lisensi milik tim, tidak ada aset pihak ketiga.
Font *Press Start 2P* memakai lisensi SIL OFL 1.1. Rincian: `ASSETS.md`.
