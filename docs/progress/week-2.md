# Laporan Progres Minggu 2 — Relational Data Chronicles

Tanggal: **10 November 2026** (Minggu 2 hari 1 — pengejaran total).

## Ringkasan eksekutif
Minggu 1 kosong. Seluruh target P0 Minggu 2 (W2-01..W2-13) diselesaikan dalam satu sesi kerja intensif.
Game dapat dimainkan dari **Start Screen → Level Select → Level 1 → Level 2 → Level 3 → End Session (Menang/Kalah)**.
Export Web tersedia, linter 0 ERROR, autotest 19/19 pass, tangkapan layar 7 bukti visual.

## Harian (hanya hari ini)

| Waktu | Aktivitas | Hasil |
|---|---|---|
| 08:00–08:15 | Env check | Godot 4.7.2, Python 3, export templates Web di `/workspace/_tools/tpl`, Git OK |
| 08:15–09:30 | Fondasi (Fase 0-2) | `scenegen.py` memperbaiki root script pada UI; `artgen.py` regenerasi aset (tileset 16×16 + animasi); `audio_gen.py` 3 musik + 12 SFX; `check_nodes.py` lolos |
| 09:30–10:30 | Level 1 (Record Ruins) | `level_base.gd` cat ASCII dari `data/levels/L1.json`; `pk_barrier.gd` validasi kolom unik; `skill_pedestal.gd` Data Scan; `duplicate_golem` guardian drop key |
| 10:30–11:15 | Level 2 (Key Citadel) | 3 PK Barrier (L2_P01, P02, P03); `Unique Strike` skill; `composite_warden` guardian |
| 11:15–12:00 | Level 3 (Foreign Spire) | Relation Bridge (FK→PK), Orphan Glitch, `Null Sovereign` boss 2 fase |
| 12:00–12:45 | UI sistem | MainMenu, LevelSelect, EndSession, HUD, PauseMenu, About, MarketUI — semua lewat `scenegen.py` |
| 12:45–13:30 | Autotest & verifikasi | `scripts/_dev/autotest.gd` 19 test case pass; export Web build; serve + curl HTTP 200 |
| 13:30–14:15 | Dokumentasi & Git | README, ASSETS.md, asset_selection.md, DECISIONS.md, functional_test.md, OPEN_QUESTIONS.md; `git init` + commit + tag `v0.2-week2` |

## Bukti teknis

| Item | Hasil | Lokasi |
|---|---|---|
| Linter `check_nodes.py` | 0 ERROR, 0 WARNING (31 scene, 212 node, 40 script) | `python tools/check_nodes.py` |
| Headless level 1–3 | Tanpa SCRIPT ERROR | `/tmp/l1.log`–`l3.log` |
| Autotest | 19 PASS / 0 FAIL | `scripts/_dev/autotest.gd` |
| Export Web | `build/web/index.html` + assets, server HTTP 200 | `/tmp/exp3.log` + curl |
| Screenshot 7 bukti | Menu, L1 start, L1 ruins, L2, L3, Level Select, End Session | `docs/progress/week2/*.png` |
| Git commit | 1 commit (b222513) + tag `v0.2-week2` | `git log --oneline` |
| Aset | 84 file (sprite, tileset, bg, audio) tercatat di ASSETS.md | `assets/` |

## Metrik kode
- **Scene .tscn:** 31
- **Script .gd:** 40 (2.520 baris kode non-komentar)
- **Node total:** 212
- **Node ber-script:** 32
- **Puzzle JSON:** 5 (L1_P01, L2_P01..P03, L3_P01)

## Risiko & mitigasi (untuk Minggu 3–4)

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Waktu ketat | Fitur P1 (Market lengkap, Save, Difficulty, Cache) tidak selesai | Fokus P0 dulu; P1 dipangkas ke Minggu 3-4 |
| Backtracking antar-region | Minggu 2 memakai 3 level terpisah (Level Select), Hub belum ada | RoomManager sudah pakai `ExitMarker.target_room`; Minggu 3 cukup hubungkan |
| Alpha Test pemain lain | Bug UX/puzzle tidak terduga | Siapkan kuesioner singkat + logs; jadwalkan Minggu 3 akhir |
| Trailer + poster + HKI | Luaran wajib Minggu 4 | Mulai rekam layar demo 30 detik per Minggu 3; poster A4 template |

## Rencana Minggu 3 (mengacu GDD 2.1)
- Skill Schema Vision & Query Pulse (P1)
- Hub dunia & backtracking (pindah dari Level Select ke peta terhubung)
- Data Market lengkap (validasi tier + konfirmasi ≥200 FG)
- Save/Load penuh (GameState serialisasi JSON)
- Corrupted Cache & Difficulty mode
- 18 Ancient Record & glosarium
- Functional Test lengkap (mengisi `docs/testing/functional_test.md` selesai)
- Mulai Alpha Test (pemain lain)

---

*Laporan ini dibuat otomatis oleh Hermes Agent sebagai bagian pengiriman harian.*