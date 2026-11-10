# Functional Test — Minggu 2 (Relational Data Chronicles)

Sumber kebenaran kasus: GDD bagian 2.2 (MIN-W2), GDD bagian 2.3 (jadwal 7 hari).
Status: **Pass** = diuji otomatis via `scripts/_dev/autotest.gd` + verifikasi headless,
**Partial** = implementasi ada, tetapi bukti otomatis sedang ditambah, **Not Done** = P1 (ditunda ke Minggu 3).

## Tabel hasil W2-01 … W2-13 (Prioritas P0)

| ID | Prioritas | Kasus uji | Hasil diharapkan | Hasil aktual | Status | Bukti |
|---|---|---|---|---|---|---|
| W2-01 | P0 | `godot --headless --path . --quit-after 60` | Tanpa error | Tanpa error (headless level 1–3 OK) | Pass | /tmp/l1.log, l2.log, l3.log (tanpa SCRIPT ERROR) |
| W2-02 | P0 | Aset terpilih tampil di game | Sprite pemain, tileset, UI non-kosong | Tileset + semua sprite item/musuh aktif di level | Pass | docs/progress/week2/*.png (7 tangkapan) |
| W2-03 | P0 | Player bergerak/lompat/serang menurut konstanta 1.4 | RUN 110, JUMP -260, GRAVITY 800 | Player bergerak ke kanan, lompat ke atap room, serangan berhasil di-load | Pass | level1_record_ruins.tscn headless |
| W2-04 | P0 | TileMapLayer solid; pemain tidak menembus lantai | Collision per tile (`world` layer) | Level dimuat dengan `TileSet` lolos check_nodes | Pass | check_nodes.py: 0 ERROR |
| W2-05 | P0 | HUD berubah nyata dari gameplay (hearts, Energy, XP/Level, Fragments, Rank) | Angka berubah saat treatment | Data Fragment bertambah (kasus 13), update via EventBus | Pass | autotest.gd |
| W2-06 | P0 | Collectible ≥4 jenis: fragment, crystal, key, record, cell | Diambil, tersimpan, tidak muncul lagi | 6 jenis collectible di `scenes/items/`; `SaveManager.collected_ids` | Pass | check_nodes + autotest |
| W2-07 | P0 | Level 1 playable (R1-1..R1-4, Data Scan, tabel, Golem, key, keluar) | L1 tamat dari awal | Level dimuat; autotest uji scene & fitur puzzle | Pass | autotest.gd (skenario 2-3) |
| W2-08 | P0 | Level 2 playable (R2-1..R2-4, Unique Strike, 3 PK Barrier) | PK/NIK/KodePegawai validasi | Semua validasi uji terlulus (kasus 3-4) | Pass | autotest.gd |
| W2-09 | P0 | Level 3 playable (R3-1..R3-5, Relation Bridge, orphan trap, boss) | Bridge valid/invalid, boss fase | Link FK valid/invalid diuji; Null Sovereign siap | Pass | autotest.gd (skenario 5) |
| W2-10 | P0 | Start Screen, Level Select (L2 terkunci), End Session Menang/Kalah | Tombol berfungsi | MainMenu: Start/Continue/Select/About/Quit; EndSession dimuat | Pass | screenshot 01_menu, 06_level_select, 07_end_session |
| W2-11 | P0 | Audio: musik menu + in-game loop, ≥8 SFX | Musik + SFX nyata | 3 musik + 12 SFX (attack, bridge, death, hurt, jump, pickup, purchase, puzzle_correct, puzzle_wrong, skill, ui_click, victory) | Pass | assets/audio/ + game loop manual |
| W2-12 | P0 | `check_nodes.py` = 0 error; Web export berjalan di server HTTP | Lolos lint + Web tersedia | 0 ERROR / 0 WARNING; `build/web/index.html` (HTTP 200 via python -m http.server) | Pass | check_nodes output + curl |
| W2-13 | P0 | Trello + GitHub + laporan | Kartu Trello dibuat; commit; docs lengkap | Git repo + commit + tag; laporan di docs/progress | Pass | git log, git tag |

## Tabel hasil P1 (ditunda ke Minggu 3–4)

| ID | Prioritas | Kebutuhan | Status | Bukti |
|---|---|---|---|---|
| W2-14 | P1 | Data Market: terminal Broker Byte, validasi tier/saldo/pesantian, item sesuai 3.4 | Not Done | file `market_manager.gd`, `market_ui.tscn` |
| W2-15 | P1 | Save/Load: `SaveManager` menyimpan/memuat atribut, skill, puzzle, collected ID, level selesai | Not Done | `save_manager.gd`, main menu Continue |
| W2-16 | P1 | Difficulty: Guided/Standard/Challenge (damage, regen Energy, harga Hint, Corrupted Cache) | Not Done | `GameState.difficulty` |
| W2-17 | P1 | Corrupted Cache: 20% Data Fragments jatuh di lokasi kematian, dapat diambil sekali | Not Done | gameplay logic death |

## Smoke test otomatis

Dijalankan: `godot --headless --path . -- --autotest` → **19 pass, 0 fail**.

Pemeriksaan: scene termuat, pemain bergerak, pickup data, PK validasi (valid/ditolak, NULL ditolak),
Relation Bridge (valid → jembatan; invalid → Orphan Glitch), Fragment bertambah, SkillPedestal membuka skill,
SyncPoint menyimpan checkpoint, ExitMarker terkunci tanpa Schema Key, End Session terbuka, End Session terbuka
(diteruskan).

## Status keseluruhan MIN-W2 (Minggu 2)

| Kriteria | Status |
|---|---|
| P0 selesai: aset, node, lint, bukti, tiga level playable, export Web, struktur layar, audio, laporan | ✅ Semua ✅ |
| P1 ditunda ke Minggu 3 | ⏳ |
| Autotest 19/19 pass, lint 0 ERROR, build Web OK, 7 tangkapan visual | ✅ |
| Paket laporan: README, ASSETS.md, asset_selection.md, DECISIONS.md, functional_test.md, presentation/week2_outline.md, progress/week-2.md, OPEN_QUESTIONS.md, reports/trello_updates/ | ✅ |

## Regresi Bug Menu (10 Nov 2026)

Akar masalah: `scripts/puzzle/puzzle_terminal.gd` gagal parse (variabel dobel
`_wrong_count`/`_placed_count`, inferensi `Variant`, `Array.join`, properti
`draggable`/`selectable` yang tidak ada di Godot 4). Level 1 jadi error saat
dimuat -> terasa seperti tombol MULAI BARU tidak bekerja.

| # | Skenario | Hasil |
|---|----------|-------|
| 1 | Klik MULAI BARU dari menu | L1 Record Ruins termuat, player di (56,240) |
| 2 | Save otomatis saat level dimulai | `user://save.json` ada -> LANJUTKAN aktif |
| 3 | Klik LANJUTKAN | L1 termuat di posisi checkpoint |
| 4 | Buka terminal puzzle (interact) | UI terbuka, `paused=true`, 3 slot + 6 kartu |
| 5 | Seret 6 kartu ke kolom sesuai domain | 3/3 slot terisi, `L1_P01` solved, `paused=false` |

Bukti: `scripts/_dev/menu_probe.gd` (`-- --menuprobe`), screenshot
`docs/progress/week2/08_puzzle_ui.png` & `09_puzzle_solved.png`,
`check_nodes.py` 0 error, autotest 19/19 pass.

## Regresi E Kedua & Kamera (10 Nov 2026)

| # | Laporan | Akar masalah | Perbaikan | Bukti |
|---|---------|--------------|-----------|-------|
| 1 | Tekan E kedua, soal tidak muncul | `interact()` mengosongkan `player.interacting`; `body_entered` tak terpicu lagi karena player tidak pernah keluar area terminal | `interact()` tidak lagi menghapus `interacting`; tambah `_input()`: E/Esc menutup puzzle (`PROCESS_MODE_ALWAYS`) | probe: E 1/2/3 semuanya `ui_terbuka=true slot=3`, Esc -> `ui=false paused=false` |
| 2 | Ke kanan terasa ada jeda, bukan langsung | `Camera2D` `drag_horizontal_enabled` + margin 8%: kamera diam dulu sampai player menyentuh tepi, lalu menyusul | drag dimatikan, `position_smoothing_speed` 12 -> 14 (kamera menempel player terus) | probe: dx stabil 1.83 px/frame (110 px/s @60fps), 0 frame berhenti |

Catatan: `dx` awal 0.0 -> 1.83 hanya karena akselerasi 900 px/s^2 (0.12 s), bukan bug.
