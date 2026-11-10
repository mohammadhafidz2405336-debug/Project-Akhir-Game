# ASSETS.md — Catatan Aset (Kelompok 9)

Aturan: setiap aset yang masuk repositori wajib tercatat di sini. Lisensi harus jelas dan dapat diverifikasi.
Aset NonCommercial/NoDerivatives/hasil ripping **tidak dipakai**.

## 1. Aset buatan sendiri (mayoritas proyek)

Seluruh sprite, tileset, dan latar dibuat secara prosedural oleh tim memakai skrip Python (Pillow)
di `tools/artgen.py` (di-generate 10 November 2026). Sumber: milik tim, lisensi = hak tim sendiri.
Tidak ada aset pihak ketiga yang diunduh, sehingga tidak ada risiko lisensi.

| File | Jenis | Sumber | Pembuat | Lisensi | Tanggal | Modifikasi | Atribusi |
|---|---|---|---|---|---|---|---|
| `assets/sprites/player_sheet.png` (120×192, 5 kolom × 8 baris, frame 24×24) | Spritesheet pemain: idle, run, jump, fall, attack, hurt, death, cast | `tools/artgen.py` | Tim (Artist: M. Naufal Zhafran) | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/player_frames.tres` | SpriteFrames pemain (8 animasi) | diturunkan dari player_sheet.png | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/enemies/glitch_blob.png` + `_frames.tres` | Musuh L1 (idle/run/hurt) | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/enemies/duplicate_slime.png` + `_frames.tres` | Musuh L2, animasi split | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/enemies/orphan_glitch.png` + `_frames.tres` | Orphan record (L3) | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/enemies/duplicate_golem.png` + `_frames.tres` | Guardian L1 (20 HP) | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/enemies/composite_warden.png` + `_frames.tres` | Guardian L2 (25 HP) | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/enemies/null_sovereign.png` + `_frames.tres` | Boss L3 (40 HP) | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/items/{fragment,memory_crystal,logic_core,schema_key,ancient_record,energy_cell}.png` | 6 sprite collectible | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/sprites/ui/*.png` (18 file: heart_full, heart_empty, energy_icon, fragment_icon, skill_scan, skill_strike, skill_bridge, skill_empty, anchor_fk, anchor_pk, crystal_column, crystal_icon, pedestal, terminal, sync_point, key_icon, null_orb, icon) | Ikon HUD, anchor FK/PK, kristal PK Barrier, pedestal, terminal, sync point | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/tilesets/{l1,l2,l3}.png` (128×64 atlas 16×16) + `.tres` | TileSet per region, 1 physics layer (`world`) | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/backgrounds/{l1,l2,l3}.png` (480×270) | Parallax background per region | `tools/artgen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/audio/music/{menu,level,boss}.wav` | 3 trek musik loop (sintesis aditif sederhana) | `tools/audio_gen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |
| `assets/audio/sfx/*.wav` (12 file: attack, bridge, death, hurt, jump, pickup, purchase, puzzle_correct, puzzle_wrong, skill, ui_click, victory) | ≥8 SFX wajib W2-11 | `tools/audio_gen.py` | Tim | Milik tim | 2026-11-10 | — | Tidak |

## 2. Aset pihak ketiga

| File | Jenis | Sumber/URL | Pembuat | Lisensi | Tanggal ambil | Modifikasi | Atribusi wajib? |
|---|---|---|---|---|---|---|---|
| `assets/fonts/PressStart2P-Regular.ttf` | Font pixel untuk seluruh UI | https://fonts.google.com/specimen/Press+Start+2P | CodeMan38 (Google Fonts) | SIL Open Font License 1.1 (`assets/fonts/OFL.txt`) | 2026-11-10 | Tidak | Ya — dicantumkan di layar About & README |
| `assets/fonts/VT323-Regular.ttf` | Font alternatif teks panjang | https://fonts.google.com/specimen/VT323 | Peter Hull (Google Fonts) | SIL OFL 1.1 (`assets/fonts/OFL-VT323.txt`) | 2026-11-10 | Tidak | Ya — dicantumkan di layar About |

**Engine:** Godot Engine 4.7.2 — lisensi MIT, atribusi di layar About.

## 3. Kandidat aset eksternal yang ditinjau tetapi **tidak** dipakai

Ditinjau pada Fase 1 (GDD 6.2). Tidak diunduh/dipakai karena seluruh kebutuhan visual sudah
dipenuhi aset buatan sendiri yang konsisten palet — menghindari risiko gaya bentrok dan
ketidakpastian lisensi halaman itch.io. Dicatat untuk transparansi proses seleksi.

| Kandidat | Lisensi tertera | Alasan tidak dipakai |
|---|---|---|
| 0x72 — 16x16 Robot Tileset | CC0 | Gaya sci-fi robot tidak serasi dengan 3 region buatan sendiri |
| Vaca Roxa — Generic Dungeon Pack | CC0 | Palet dungeon gelap bentrok dengan tema teal/amber/ungu |
| JIK-A-4 — Orius | CC0 | Ukuran/massa karakter tidak cocok dengan konstanta gerak GDD 1.4 |
| Kenney — Pixel Platformer / UI | CC0 | Ikon UI sudah dibuat sendiri agar palet seragam |
| V3X3D — Retro Lines | CC0 | Tile 16×16 bagus, tetapi tidak ada set 3 region |

Keputusan ini dicatat juga di `docs/assets/asset_selection.md` dan `docs/DECISIONS.md`.
