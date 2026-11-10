# HERMES_GDD.md — GDD Pedoman Agent: Relational Data Chronicles: The Lost Schema

**Untuk:** Agent Hermes (pengembang Godot) | **Tim:** Kelompok [isi] | **Mata kuliah:** Basis Data, materi *Pengenalan Model Data Relasional*
**Status dokumen:** v1.0, disusun 10 November 2026 (Minggu 2 dari 4, **belum ada progres**)
**Turunan dari:** GDD v0.1 yang diserahkan ke dosen (Bagian 1 dan 2.1-2.4). Dokumen ini lebih operasional: ia memuat angka, struktur node, data puzzle, dan tugas harian.

> Cara membaca: Bagian 2 adalah **kontrak kerja Minggu 2**. Bagian 3-5 adalah spesifikasi yang harus kamu implementasikan. Bagian 6 adalah panduan aset. Bagian 7 adalah prosedur Trello/GitHub/laporan. Bagian 9 adalah QA dan jalur cadangan.

---

## 1. Ringkasan Proyek dan Keputusan Teknis

### 1.1 Pitch
Data Realm adalah dunia digital yang dibangun dari tabel dan relasi. **Null Corruption** mengubah nilai menjadi NULL dan memutus relasi. Pemain (**Data Explorer**, ditemani drone **Cursor**) menjelajah tiga wilayah, memperoleh skill yang masing-masing mewakili satu konsep basis data, membuka area baru, dan mengalahkan **Null Sovereign**.

**Aturan desain inti:** materi basis data adalah *mekanik*, bukan kuis. Memukul kolom yang benar-benar unik (primary key), menyambung nilai foreign key ke parent yang ada (referential integrity), menembakkan nilai yang lolos constraint. Pilihan ganda A/B/C/D **tidak** dipakai.

### 1.2 Tiga region (level)
| Level | Region | Konsep materi | Skill yang diperoleh | Penjaga |
|---|---|---|---|---|
| L1 | **Record Ruins** | Relation/tabel, tuple, attribute, domain | Data Scan | Duplicate Golem |
| L2 | **Key Citadel** | Superkey, candidate key, primary key, NULL, composite key | Unique Strike | Composite Warden |
| L3 | **Foreign Spire** | Foreign key, referential integrity, orphan record | Relation Bridge | Null Sovereign (boss akhir) |

*Skill Schema Vision dan Query Pulse ditunda ke Minggu 3 (P1).*

### 1.3 Keputusan teknis (kunci, jangan diubah tanpa mencatat di `docs/DECISIONS.md`)
| Item | Keputusan |
|---|---|
| Engine | Godot 4.x stable. Versi terbaru di godotengine.org per Agustus 2026 adalah 4.7.2; 4.6.x juga stabil. **Pakai versi yang sudah terpasang di mesin tim dan kunci di README** (jangan campur versi). Perlu minimal 4.3 untuk `TileMapLayer` dan ekspor Web single-thread. |
| Bahasa | GDScript (C# tidak dapat diekspor ke Web di Godot 4) |
| Renderer | Compatibility (`gl_compatibility`) |
| Viewport | 960 × 540, stretch `canvas_items`, aspect `keep` |
| Aset 16×16 | Kebanyakan aset gratis berukuran 16×16. **Pakai tile 16 px dan `Camera2D.zoom = Vector2(2, 2)`** sehingga tampil seperti 32 px di layar. (GDD v0.1 menyebut tile 32 px; perubahan ini disengaja dan tidak mengubah desain.) Jika aset terpilih 32×32, pakai zoom 1. |
| Texture filter | Nearest (`textures/canvas_textures/default_texture_filter = 0`), `snap_2d_transforms_to_pixel = true` |
| Physics tick | 60 Hz |
| Input | Keyboard + mouse |
| Save | JSON di `user://save.json` |

### 1.4 Ringkasan konstanta gerak (nilai awal, satuan piksel dunia, tile 16 px)
`RUN_SPEED = 110`, `GRAVITY = 800`, `JUMP_VELOCITY = -260` (tinggi lompat sekitar 2,6 tile), `JUMP_CUT = 0.5` (lepas tombol melompat: kecepatan naik dibagi dua), `COYOTE_TIME = 0.10`, `JUMP_BUFFER = 0.10`, `MAX_FALL_SPEED = 380`, `HURT_IFRAMES = 1.2`, `KNOCKBACK = Vector2(120, -140)`.

---

## 2. Jadwal 4 Minggu dan Kontrak Minggu 2

### 2.1 Peta empat minggu
| Minggu | Status | Fokus | Hasil yang diperiksa |
|---|---|---|---|
| 1 | Lewat, **kosong** (catat jujur di laporan) | Seharusnya: konsep dan fondasi | — |
| **2 (sekarang)** | **Kritis** | **Vertical slice: Start → Level Select → L1 → L2 → L3 → End Session, aset nyata, node nyata** | Demo playable + bukti Trello/GitHub |
| 3 | Rencana | Skill sisa (Schema Vision, Query Pulse), hubungkan dunia lewat Hub dan backtracking, perluas room, boss matang, 18 Ancient Record, Market lengkap, Save Code, **Instrumen Uji + Functional Test**, mulai Alpha Test | Build web di hosting lab, hasil Functional Test |
| 4 | Rencana | **Feature freeze hari ke-3**, perbaikan bug dari Alpha Test, balancing, audio final, deploy, **GDD final, poster A4, video trailer ~5 menit, draft HKI**, laporan akhir | Luaran wajib proyek akhir |

### 2.2 Minimum Minggu 2 (Definition of Done, "MIN-W2")
Setiap butir harus punya **bukti** (lihat 7.4). P0 wajib selesai. P1 dikerjakan bila P0 tuntas.

| ID | Prioritas | Deliverable | Kriteria diterima |
|---|---|---|---|
| W2-01 | P0 | Repositori GitHub + struktur proyek + Autoload + InputMap + Project Settings | `godot --headless --path . --quit-after 60` tanpa error; README memuat versi Godot; struktur sesuai 5.1 |
| W2-02 | P0 | Pemilihan dan integrasi aset (peta + karakter) | `docs/assets/asset_selection.md` berisi ≥3 kandidat per kategori + keputusan; `ASSETS.md` terisi; aset terpilih **tampil di game** |
| W2-03 | P0 | Player nyata | Scene Player sesuai 5.3: sprite beranimasi (idle, run, jump, fall, attack, hurt, death), collision, Camera2D, bergerak sesuai 1.4; hurtbox dan hitbox berfungsi |
| W2-04 | P0 | TileSet dan template level | TileSet dari tileset terpilih dengan physics layer; satu `TileMapLayer` solid berfungsi; Player tidak menembus lantai/dinding |
| W2-05 | P0 | Atribut + HUD | Health, Energy, Logic XP/Level, Data Fragments tampil dan **berubah nyata** dari gameplay; Knowledge Rank dihitung dari bintang puzzle |
| W2-06 | P0 | Collectible (≥4 jenis berfungsi) | Data Fragment, Memory Crystal, Energy Cell, Ancient Record berfungsi (diambil, tersimpan, tidak muncul lagi setelah diambil); Schema Key dari Guardian |
| W2-07 | P0 | **Level 1 playable** (Record Ruins) | R1-1 sampai R1-4 sesuai 4.2, termasuk Data Scan dan terminal tabel, Guardian, Schema Key, keluar ke Level Select |
| W2-08 | P0 | **Level 2 playable** (Key Citadel) | R2-1 sampai R2-4 sesuai 4.3, termasuk Unique Strike dan 3 PK Barrier |
| W2-09 | P0 | **Level 3 playable** (Foreign Spire) | R3-1 sampai R3-5 sesuai 4.4, termasuk Relation Bridge, orphan trap, boss Null Sovereign (HP dan 2 pola serangan), layar Menang |
| W2-10 | P0 | Struktur layar | Start Screen, Level Select (L2 terkunci sampai L1 selesai, dst.), End Session (Menang/Kalah) dengan tombol berfungsi, About (nama + foto placeholder) |
| W2-11 | P0 | Audio minimal | 1 musik menu, 1 musik in-game (loop), ≥8 SFX nyata (lompat, serang, terkena, ambil, klik UI, puzzle benar, puzzle salah, beli/tolak); semua tercatat di `ASSETS.md` |
| W2-12 | P0 | Linter + export Web | `python tools/check_nodes.py` = 0 error; `build/web/index.html` berjalan lewat `python -m http.server` di Chrome |
| W2-13 | P0 | Trello + GitHub + paket laporan | Papan Trello berisi semua kartu W2 dengan status benar; PR/commit tertaut; `docs/progress/week-2.md` dan `docs/presentation/week2_outline.md` terisi |
| W2-14 | P1 | Data Market | Terminal di Level Select/Hub; item sesuai 3.4 (Health/Energy/Damage tier, Logic Recovery, Integrity Patch, Puzzle Hint) dengan validasi dan pesan gagal |
| W2-15 | P1 | Save/Load | `SaveManager` menyimpan dan memuat status (atribut, skill, puzzle, collected ID, level selesai) |
| W2-16 | P1 | Difficulty Guided/Standard/Challenge | Sesuai 3.6 |
| W2-17 | P1 | Corrupted Cache (penalti kematian) | Sesuai 3.1 |

> **Catatan jujur mengenai kompromi Minggu 2:** pada GDD v0.1 dunia adalah satu peta terhubung lewat Hub dan skill-gating antarregion. Untuk mengejar waktu, Minggu 2 memakai **tiga level yang dimuat dari Level Select**. Namun **RoomManager harus sudah memakai penanda pintu keluar** (`ExitMarker` dengan `target_room`) agar Minggu 3 cukup menghubungkan scene ke Hub tanpa menulis ulang.

### 2.3 Rencana 7 hari untuk Minggu 2
| Hari | Fokus | Hasil harian yang harus dibuktikan |
|---|---|---|
| H1 (hari ini) | Fase 0 + W2-01 + W2-02 (shortlist aset, scene uji) | Env check, repo tersusun, `asset_selection.md` draf, kartu Trello dibuat |
| H2 | W2-02 (final) + W2-03 + W2-04 | Player bergerak di tilemap dengan aset terpilih (GIF) |
| H3 | W2-05 + W2-06 + musuh dasar + W2-10 (menu, level select) | HUD bekerja; collectible; Start Screen memuat Level 1 |
| H4 | W2-07 (Level 1) | L1 tamat dari awal sampai Schema Key |
| H5 | W2-08 (Level 2) | L2 tamat; Unique Strike dan 3 PK Barrier |
| H6 | W2-09 (Level 3 + boss) + W2-11 (audio) | L3 tamat sampai layar Menang |
| H7 | W2-12 + W2-13 (+ P1 bila sempat) | Export Web, lint bersih, tag `v0.2-week2`, paket laporan |

Jika terlambat satu hari, **pangkas dahulu** hal-hal ini (urut): P1, jumlah musuh per room, dekorasi/parallax, animasi cadangan. **Jangan pernah** memangkas: aset nyata, node nyata, lint, bukti, dan tiga level playable.

### 2.4 Kartu Trello yang harus dibuat (copy ke papan)
Daftar: `Backlog` | `Minggu 2 - To Do` | `In Progress` | `Testing` | `Done` | `Blocked`.
Label: `P0` (merah), `P1` (kuning), `Aset`, `Level`, `Sistem`, `UI`, `Audio`, `Dokumen`.
Nama kartu: `[W2][P0] W2-03 Player nyata`. Setiap kartu memiliki checklist kriteria dari tabel 2.2 dan lampiran bukti. Buat satu kartu per ID W2-01 sampai W2-17, ditambah kartu "Rencana Minggu 3" dan "Rencana Minggu 4" di `Backlog`.

---

## 3. Data Tuning (sumber kebenaran angka)

### 3.1 Atribut pemain
| Atribut | Awal | Maks | Aturan |
|---|---|---|---|
| Health (hati) | 5 | 8 | Terkena musuh/hazard -1 (boss -2); i-frame 1,2 detik + knockback; jatuh ke void -1 dan kembali ke platform aman terakhir. Habis: layar End Session (Kalah) → ulang dari Sync Point terakhir dengan Health dan Energy penuh, musuh room direset. **Corrupted Cache** (P1): 20% Data Fragments jatuh di lokasi kematian, dapat diambil sekali. |
| Energy | 50 | 110 (130 dengan perk) | Regenerasi +3/detik, mulai 1,5 detik setelah terakhir memakai skill. Energy Cell +15. Energy 0: skill terkunci, serangan dasar tetap jalan. |
| Logic XP | 0 | 2700 (Level 10) | Tidak pernah berkurang. Ambang level: 0, 100, 250, 450, 700, 1000, 1350, 1750, 2200, 2700. Naik level: bonus Data Fragments = 10 × level baru. Perk: Level 4 dan 7 = +10 maks Energy. |
| Data Fragments | 0 | 999 | Mata uang Market. |
| Knowledge Rank | Novice | Grandmaster | Mastery % = bintang terbaik semua puzzle ÷ (jumlah puzzle × 3). Novice 0-24, Apprentice 25-49, Analyst 50-74, Architect 75-89, Grandmaster 90-100. |

**Bintang puzzle:** 3★ = tanpa jawaban salah dan tanpa Hint; 2★ = ≤2 salah atau 1 Hint; 1★ = selain itu. Hanya bintang terbaik per puzzle yang dihitung.
**XP puzzle (pertama kali):** 40 / 80 / 120 (mudah/sedang/sulit) × (3★: 1,5; 2★: 1,0; 1★: 0,75). Mengulang puzzle tidak memberi XP. Musuh: 3 XP hanya saat pertama kali dikalahkan per ID musuh. Ancient Record: 25 XP. Guardian: 150. Null Sovereign: 300.
**Kesalahan puzzle tidak mengurangi Health.** Hanya bintang turun dan muncul pesan edukatif bergaya DBMS.

### 3.2 Collectible
| Item | Visual (pakai sprite dari aset terpilih atau gambar sederhana yang konsisten) | Fungsi | Sifat |
|---|---|---|---|
| Data Fragment | Heksagon cyan; varian 1 / 5 / 25 | Mata uang | Consumable, otomatis diambil |
| Memory Crystal | Kristal ungu | Bahan upgrade tier 2-3 | Disimpan (maks 99), tidak dapat dijual |
| Logic Core | Inti heksagon emas | Bahan Skill Module/Enhancer (P1/Minggu 3) | Disimpan (maks 10) |
| Schema Key | Kunci dengan bentuk gigi berbeda per region | Membuka Schema Gate/keluar level | Permanen, key item |
| Ancient Record | Tablet/gulungan | Entri glosarium di Journal, +25 XP sekali | Permanen |
| Energy Cell | Baterai hijau | +15 Energy instan | Consumable (peluang drop 25%) |

Setiap collectible permanen punya ID unik (contoh: `L1_AR_01`, `L2_MC_02`) dan dicatat di `GameState.collected_ids`. **Jumlah minimal Minggu 2 per level:** ≥40 Data Fragment, 1 Memory Crystal (tersembunyi), 2 Ancient Record, 1 Schema Key (dari Guardian), Energy Cell dari musuh. Logic Core: 1 per level dari Guardian (L1, L2) dan 1 dari boss L3 (sebagai hadiah, belum terpakai di Minggu 2).

**Isi Ancient Record** (tulis 2-4 kalimat akurat dalam bahasa Indonesia sederhana, simpan di `data/glossary.json`):
- L1: relation (tabel), tuple (baris/record), attribute (kolom), domain, relation schema vs relation instance.
- L2: superkey, candidate key, primary key (unik dan tidak NULL), composite key, alasan NULL tidak boleh di primary key (entity integrity).
- L3: foreign key, referential integrity, orphan record, parent-child, nilai FK boleh NULL bila kolom mengizinkan.

### 3.3 Skill (P0 Minggu 2: tiga skill)
| Skill | Tombol | Energy | Cooldown | Efek | Hubungan materi |
|---|---|---|---|---|---|
| Data Scan | 1 | 10 | 1 s | Gelombang radius 96 px (0,4 detik). Objek grup `scannable` terlihat 8 detik. | Atribut dan record |
| Unique Strike | 3 | 20 | 2 s | Terjang 80 px ke arah hadap; memicu `PKBarrier`; musuh terkena 2 × damage dasar. | Primary key |
| Relation Bridge | 5 | 25 per link | 0,5 s | Klik FK Anchor lalu PK Anchor (jarak ≤128 px); bila valid terbentuk jembatan 20 detik; bila tidak, Orphan Glitch muncul. Maks 2 link aktif. | Foreign key |

*Ditunda ke Minggu 3 (P1):* Schema Vision (tombol 2, 4 Energy/detik), Query Pulse (tombol 4, 15 Energy). **Pasang ikon slot kosong** di HUD agar tata letak tidak berubah. Skill terkunci sampai diambil di pedestal level terkait (`SkillPedestal`).

Serangan dasar **Data Slash** (tombol J / klik kiri): damage dasar 2, cooldown 0,35 s, hitbox sementara di depan pemain.

### 3.4 Data Market (P1 Minggu 2)
Pedagang NPC **Broker Byte**; antarmuka CanvasLayer dengan `process_mode = ALWAYS` dan `get_tree().paused = true` saat terbuka. Validasi urut: tier maksimum → persyaratan (Logic Level) → batas bawa → saldo. Eksekusi atomik: kurangi biaya, terapkan efek, simpan, umpan balik. Kegagalan: tombol nonaktif + alasan + SFX tolak, tanpa pemotongan saldo. Pembelian ≥200 FG meminta konfirmasi.

| Item | Biaya | Efek | Syarat |
|---|---|---|---|
| Health Upgrade T1 / T2 / T3 | 100 FG / 200 FG + 1 MC / 350 FG + 2 MC | +1 hati maks dan pulih penuh | Logic Level 2 / 4 / 6, tier berurutan |
| Energy Upgrade T1 / T2 / T3 | 80 / 160 + 1 MC / 280 + 2 MC | +20 maks Energy | Level 2 / 4 / 6 |
| Damage Upgrade T1 / T2 / T3 | 120 / 240 + 1 MC / 400 + 2 MC | +1 damage Data Slash dan Unique Strike | Level 3 / 5 / 7 |
| Logic Recovery | 40 FG | +50 Energy (batas bawa 5) | — |
| Integrity Patch | 60 FG | +2 hati (batas bawa 3) | — |
| Puzzle Hint | 30 FG | 1 token Hint (batas 5); membatasi puzzle itu maks 2★ | — |

*MC = Memory Crystal, FG = Data Fragments.* Database Scanner, Index Dash, dan Skill Enhancer → Minggu 3. Harga disimpan di Resource `.tres`/JSON, **bukan** di-hardcode di logika.

### 3.5 Musuh
| Musuh | Level | HP | Damage | Perilaku (implementasi) |
|---|---|---|---|---|
| Glitch Blob | L1 | 3 | 1 | Patrol kiri-kanan, balik arah di tepi/dinding (RayCast2D); drop FG 2-4, peluang Energy Cell 25% |
| Duplicate Slime | L2 | 4 | 1 | Patrol + lompat kecil tiap 2 detik; terbelah menjadi 2 Slime mini (HP 1) saat mati (tanpa XP/drop dari mini) |
| Orphan Glitch | L3 | 2 | 1 | Muncul dari link FK tidak valid; mengejar pemain perlahan (kecepatan 50); hilang bila jembatan valid dibuat atau setelah 15 detik |
| Duplicate Golem (Guardian L1) | L1 | 20 | 1 | Menerjang bolak-balik; tiap 25% HP hilang memanggil 1 Glitch Blob; drop Schema Key + Logic Core |
| Composite Warden (Guardian L2) | L2 | 25 | 1 | Pola 1: gelombang tanah; pola 2: pukulan atas; terluka hanya saat sedang "stun" (setelah pemain memecahkan PK Barrier majemuk di arena); drop Schema Key + Logic Core |
| Null Sovereign (Boss) | L3 | 40 | 1 (proyektil), 2 (sentuhan) | Fase 1 (>50% HP): melontarkan kipas 3 proyektil "NULL orb" tiap 2,5 detik, melayang bolak-balik. Fase 2: memunculkan Orphan Glitch tiap 6 detik; perisai boss pecah hanya jika pemain membuat link Relation Bridge valid antara dua anchor di arena (perisai menyala lagi setelah 8 detik). Kalah → layar Menang. |

Semua musuh: `CharacterBody2D` dengan `Hurtbox`, `Hitbox`, `AnimatedSprite2D` nyata, dan HP bar sederhana untuk Guardian/boss.

### 3.6 Kesulitan (P1)
| Parameter | Guided | Standard | Challenge |
|---|---|---|---|
| Damage musuh | separuh (min 1) | normal | ×1,5 (dibulatkan ke atas) |
| Regen Energy | ×1,5 | ×1 | ×0,75 |
| Harga Hint | Hint pertama tiap puzzle gratis | 30 FG | 45 FG |
| Corrupted Cache | 0% | 20% | 30% |

---

## 4. Spesifikasi Level (Minggu 2)

Ukuran room dalam **tile** (16 px). Setiap room punya `RoomBounds` (batas kamera), `PlayerSpawn`/`ExitMarker` (`Marker2D`), dan `SyncPoint` bila dinyatakan. Rancang platform sehingga semua lompatan masuk akal dengan konstanta 1.4 (lompat horizontal maks sekitar 5 tile, vertikal sekitar 2,5 tile).

### 4.1 Format data puzzle (JSON, `data/puzzles/<id>.json`)
```json
{
  "id": "L2_P01",
  "type": "pk_barrier",
  "difficulty": "easy",
  "table": "Mahasiswa",
  "rows": [
    {"NIM": "2201001", "Nama": "Sari",  "Kota": "Malang"},
    {"NIM": "2201002", "Nama": "Budi",  "Kota": "Malang"},
    {"NIM": "2201003", "Nama": "Budi",  "Kota": "Batu"}
  ],
  "columns": ["NIM", "Nama", "Kota"],
  "valid_keys": [["NIM"]],
  "explanations": {
    "Nama": "Duplicate key value: 'Budi' muncul lebih dari sekali, sehingga Nama tidak dapat mengidentifikasi baris secara unik.",
    "Kota": "Duplicate key value: 'Malang' muncul lebih dari sekali.",
    "NIM": "Benar: NIM unik dan tidak NULL, sehingga dapat menjadi primary key."
  }
}
```
Validasi **dihitung oleh kode** dari `rows` (unik dan bukan NULL), `valid_keys` dipakai hanya sebagai kunci jawaban yang diperiksa silang saat debug. Ini mencegah data puzzle yang salah.

### 4.2 Level 1: Record Ruins (tema: reruntuhan teal/abu, hijau-kebiruan)
Tujuan belajar: relation, tuple, attribute, domain. Skill: **Data Scan**.

| Room | Ukuran | Isi | Rincian |
|---|---|---|---|
| R1-1 Gerbang Reruntuhan | 40 × 18 | Tutorial gerak | Awal: `PlayerSpawn`. Jurang kecil (lompat), 2 Glitch Blob, 12 Data Fragment, 1 `SyncPoint`. Cursor memberi teks tutorial lewat `CursorHint` (Area2D pemicu + panel teks): gerak, lompat, serang. |
| R1-2 Scanner Chamber | 36 × 20 | Data Scan | `SkillPedestal` (Data Scan). Setelah diambil, Cursor menjelaskan tombol 1. Platform hantu (`scannable`) membentuk jalan ke ledge atas yang berisi **Ancient Record L1_AR_01**. Label setelah scan: `kolom: nilai`. |
| R1-3 Corrupted Table Terminal | 44 × 20 | Puzzle terminal tabel | `PuzzleTerminal` tipe `column_match` (drag and drop): tabel **Mahasiswa(NIM, Nama, Prodi)** dengan slot kolom `[NIM][Nama][Prodi]` dan 6 kartu: `2201001`, `2201002`, `Sari`, `Budi`, `Informatika`, `Sistem Informasi`. Kartu benar menempel dan menyala hijau; salah memantul + pesan ("Nilai ini bukan bagian dari domain kolom Nama"). Selesai: pintu terbuka. Ruang rahasia (tembok `scannable`) berisi **Memory Crystal L1_MC_01** dan **Ancient Record L1_AR_02**. 14 Data Fragment, 2 Glitch Blob. |
| R1-4 Duplicate Golem | 30 × 18 | Guardian + keluar | Arena tertutup saat Golem aktif. Setelah kalah: drop Schema Key (Entity Key) + Logic Core; pintu keluar → `ExitMarker` ke Level Select; `LevelComplete` menandai L1 selesai dan membuka L2. |

Estimasi XP L1: puzzle 80 (sedang) × pengali, Ancient Record 2 × 25, Golem 150, musuh ≈ 15.

### 4.3 Level 2: Key Citadel (tema: benteng perunggu-amber)
Tujuan belajar: superkey, candidate key, primary key, NULL, composite key. Skill: **Unique Strike**.

| Room | Ukuran | Isi | Rincian |
|---|---|---|---|
| R2-1 Gerbang Benteng | 40 × 20 | Pedestal Unique Strike | 3 Duplicate Slime, 15 FG, `SyncPoint`. Pedestal skill dijaga 2 Slime; setelah diambil, Cursor menjelaskan tombol 3 dan memberi tahu bahwa dinding kristal hanya pecah oleh kolom yang tepat. |
| R2-2 PK Barrier I | 36 × 18 | Puzzle PK dasar | `PKBarrier` dengan data `L2_P01` (Mahasiswa; pada 4.1). Hanya kristal **NIM** pecah; Nama dan Kota memantulkan terjangan + pesan duplikasi. Di balik barrier: **Ancient Record L2_AR_01**, 14 FG. |
| R2-3 PK Barrier II (NULL) | 40 × 22 | Puzzle PK dengan NULL | Data `L2_P02`: **Pegawai(KodePegawai, NIK, Email)**; KodePegawai: `P01,P02,P03,P04` (unik, tidak NULL); NIK: `3507..01, 3507..02, NULL, 3507..04` (unik tetapi mengandung NULL → ditolak, pesan: "Primary key tidak boleh NULL (entity integrity)"); Email: `a@x.id, b@x.id, a@x.id, c@x.id` (duplikat). Hanya **KodePegawai** benar. Ruang rahasia `scannable`: **Memory Crystal L2_MC_01**, **Ancient Record L2_AR_02**. Perhatikan: pemain dapat memakai Data Scan di sini juga (menunjukkan kegunaan lintas level). |
| R2-4 Composite Warden | 34 × 20 | Puzzle PK majemuk + Guardian | Data `L2_P03`: **Nilai(NIM, KodeMK, Nilai)** dengan baris `(2201001, MK01), (2201001, MK02), (2201002, MK01), (2201002, MK02)`. NIM saja dan KodeMK saja tidak unik; **kombinasi** NIM + KodeMK unik. Barrier majemuk: pemain harus memukul kristal NIM lalu KodeMK dalam 2 detik. Berhasil: Warden **stun** 6 detik (rentan). Gagal: Warden menyerang. Kalahkan Warden (HP 25) → drop Schema Key (Candidate Key) + Logic Core → pintu keluar, L2 selesai, L3 terbuka. |

### 4.4 Level 3: Foreign Spire (tema: menara sci-fi ungu-magenta)
Tujuan belajar: foreign key, referential integrity, orphan record. Skill: **Relation Bridge**.

| Room | Ukuran | Isi | Rincian |
|---|---|---|---|
| R3-1 Dasar Menara | 38 × 20 | Pedestal Relation Bridge + tutorial | Pedestal skill. Tutorial anchors: **tabel Dosen** (PK Anchor: `id_dosen` = 1, 2, 3) dan **tabel MataKuliah** (FK Anchor: `MK01 → id_dosen = 2`). Jurang 8 tile hanya bisa dilewati dengan membuat link valid. |
| R3-2 Dua Jembatan | 42 × 22 | Link valid ganda | Dua jurang berurutan, FK Anchor `MK01 → 2` dan `MK02 → 1`; maks 2 link aktif. Pemain harus menyeberang sebelum jembatan hilang (20 s). 16 FG, Memory Crystal `L3_MC_01` di ledge jauh. |
| R3-3 Orphan Trap | 40 × 24 | Orphan record | FK Anchor `MK03 → id_dosen = 7`; PK Anchor hanya 1,2,3. Link ke nilai 7 gagal: pesan "Foreign key constraint fails: parent row not found", muncul Orphan Glitch. **Perbaikan:** terminal `fk_fix` menampilkan nilai `id_dosen` yang boleh dipilih (1, 2, 3) dan **NULL** (kolom mengizinkan NULL): pemain mengganti nilai FK menjadi valid, lalu link berhasil. Satu Ancient Record `L3_AR_01` (foreign key) dan `L3_AR_02` (referential integrity). |
| R3-4 Menara Vertikal | 24 × 40 | Platform vertikal | Kombinasi jembatan (1 link) dan platform biasa; 2 Orphan Glitch; `SyncPoint` di dasar. |
| R3-5 Null Sovereign | 36 × 22 | Boss | Arena tertutup; 2 pasang anchor tetap di sisi kiri dan kanan untuk memecahkan perisai (lihat 3.5). Kalah → `EndSession` Menang dengan statistik (waktu, Fragments, Logic Level, Knowledge Rank, Ancient Record terkumpul). |

---

## 5. Struktur Proyek dan Spesifikasi Node

### 5.1 Struktur folder
```
res://
├─ project.godot
├─ README.md  ASSETS.md  tools/check_nodes.py  .gitignore  .gitattributes
├─ docs/  (HERMES_GDD.md, DECISIONS.md, OPEN_QUESTIONS.md, assets/, progress/, presentation/, testing/)
├─ reports/trello_updates/
├─ assets/
│  ├─ inbox/                 # unduhan mentah (jangan dipakai langsung)
│  ├─ sprites/ (player, enemies, items, ui)
│  ├─ tilesets/
│  ├─ backgrounds/
│  ├─ audio/ (music, sfx)
│  └─ fonts/
├─ autoload/ (event_bus.gd, game_state.gd, save_manager.gd, audio_manager.gd, skill_manager.gd, market_manager.gd, room_manager.gd)
├─ data/ (puzzles/*.json, glossary.json, market_items.json, tuning.json)
├─ scenes/
│  ├─ player/ enemies/ items/ puzzle/ skills/ ui/ levels/ world/
└─ scripts/ (mengikuti struktur scenes/)
```
`.gitignore` minimal: `.godot/`, `build/`, `*.translation`, `export_credentials.cfg`. **Commit** folder `assets/` final dan file `.import` bila tim memutuskan demikian (tulis di DECISIONS.md); minimal commit aset sumber agar repositori lengkap.

### 5.2 Project Settings dan InputMap
Atur: `display/window/size/viewport_width=960`, `viewport_height=540`, `stretch/mode="canvas_items"`, `stretch/aspect="keep"`, `rendering/renderer/rendering_method="gl_compatibility"`, `textures/canvas_textures/default_texture_filter=0`, `2d/snap/snap_2d_transforms_to_pixel=true`, `physics/common/physics_ticks_per_second=60`. Layer fisika (beri nama): 1 `world`, 2 `player`, 3 `enemy`, 4 `player_hitbox`, 5 `enemy_hitbox`, 6 `interactable`, 7 `pickup`, 8 `hazard`.

InputMap: `move_left` (A, ←), `move_right` (D, →), `jump` (Space, W, ↑), `attack` (J, klik kiri), `interact` (E), `skill_1`...`skill_5` (1-5), `journal` (Tab, I), `pause` (Esc, P).

Autoload: `EventBus`, `GameState`, `SaveManager`, `AudioManager`, `SkillManager`, `MarketManager`, `RoomManager` (diaktifkan sesuai urutan itu).

**Signal minimal di `EventBus`:** `health_changed(old, new)`, `energy_changed(old, new)`, `fragments_changed(old, new)`, `logic_xp_changed(xp, level)`, `logic_level_up(level)`, `rank_changed(rank)`, `skill_unlocked(id)`, `puzzle_solved(id, stars)`, `collectible_taken(id, type)`, `room_entered(id)`, `level_completed(level_id)`, `player_died()`, `boss_defeated(id)`, `market_purchase(item_id, tier)`.

### 5.3 Pohon node wajib (Node Asli)
Format: `Nama (Tipe)` + properti penting. **Semua properti yang ditulis wajib terisi sungguhan.**

**Player (`scenes/player/player.tscn`)**
```
Player (CharacterBody2D)            script: player.gd   groups: player   collision_layer=2, mask=1|3|8
├─ AnimatedSprite2D                 sprite_frames: idle, run, jump, fall, attack, hurt, death, (cast)  dari aset terpilih
├─ CollisionShape2D                 shape: RectangleShape2D/CapsuleShape2D sesuai ukuran kaki-badan sprite
├─ Camera2D                         zoom=(2,2), position_smoothing_enabled=true, smoothing speed≈6, drag margins kecil, limit_* diatur RoomBounds
├─ Hurtbox (Area2D)                 mask=enemy_hitbox|hazard   └─ CollisionShape2D (shape)
├─ AttackPivot (Node2D)             flip sesuai arah hadap
│  └─ Hitbox (Area2D)               layer=player_hitbox, monitoring dinyalakan hanya saat serangan  └─ CollisionShape2D (shape)
├─ InteractArea (Area2D)            mask=interactable   └─ CollisionShape2D (shape)
├─ CoyoteTimer (Timer, 0.1)  JumpBufferTimer (Timer, 0.1)  IFrameTimer (Timer, 1.2)  AttackCooldown (Timer, 0.35)
├─ AudioStreamPlayer2D x N atau pakai AudioManager (stream terisi)
└─ SkillCaster (Node)               script: skill_caster.gd  (membaca input skill, memanggil SkillManager)
```
**Glitch Blob / musuh umum (`scenes/enemies/enemy_base.tscn`, varian mewarisi)**
```
Enemy (CharacterBody2D)  script  groups: enemy
├─ AnimatedSprite2D (sprite_frames asli)   ├─ CollisionShape2D (shape)
├─ Hurtbox (Area2D)+CollisionShape2D       ├─ Hitbox (Area2D, layer enemy_hitbox)+CollisionShape2D
├─ WallRay (RayCast2D, enabled)            ├─ LedgeRay (RayCast2D, enabled)
└─ DropSpawner (Node) script: spawn Data Fragment / Energy Cell (mengambil scene Pickup)
```
**Pickup (`scenes/items/pickup.tscn`)**
```
Pickup (Area2D) script: pickup.gd  mask=player   export: data (CollectibleData/JSON id), collectible_id
├─ Sprite2D atau AnimatedSprite2D (texture nyata)   ├─ CollisionShape2D (CircleShape2D)
└─ AnimationPlayer (bobbing naik-turun, loop)   (SFX diputar lewat AudioManager)
```
**PKBarrier (`scenes/puzzle/pk_barrier.tscn`)**
```
PKBarrier (StaticBody2D) script: pk_barrier.gd   export: puzzle_id
├─ CollisionShape2D (shape menutup jalan)
├─ Crystals (Node2D) → tiap kolom: CrystalColumn (Area2D+Sprite2D+CollisionShape2D+Label nama kolom)
├─ DataPanel (Control/GridContainer) menampilkan baris contoh dari JSON
└─ AnimationPlayer (animasi pecah, deflect)
```
Method kontrak: `on_strike(hit_column_name)`; memanggil validator unik, mengirim `puzzle_solved`, memutar animasi, menampilkan penjelasan di `HintLabel`/panel Cursor.

**FKAnchor / PKAnchor (`scenes/puzzle/`)**: `Area2D` + `Sprite2D` + `CollisionShape2D` + `Label` (menampilkan nilai) di grup `relation_anchor`. **Bridge** (`scenes/skills/bridge.tscn`): `StaticBody2D` + `CollisionShape2D` (shape persegi panjang panjang jembatan) + `Line2D` visual + `Timer` (20 s) + animasi muncul/hilang.

**PuzzleTerminal (`scenes/puzzle/puzzle_terminal.tscn`)**: `Area2D` pemicu (tekan E) + `Sprite2D` + `CollisionShape2D` + `CanvasLayer` panel UI berisi `Control` slot dan kartu yang dapat diseret (`Control` dengan `_get_drag_data`/`_can_drop_data`/`_drop_data`, atau `gui_input`), tombol Hint, tombol Tutup, dan label umpan balik.

**SkillPedestal**: `Area2D` + `Sprite2D`/`AnimatedSprite2D` + `CollisionShape2D` + script yang memanggil `SkillManager.unlock(id)` sekali dan menampilkan pop-up pengantar.

**SyncPoint**: `Area2D` + `AnimatedSprite2D` + `CollisionShape2D` + `PointLight2D` opsional; menyimpan game (`SaveManager`), memulihkan Health/Energy, mencatat `last_sync_point`.

**Level template (`scenes/levels/level_template.tscn`, dipakai semua level)**
```
Level (Node2D) script: level_base.gd   export: level_id
├─ Background (ParallaxBackground/ParallaxLayer atau TextureRect) dengan texture nyata
├─ TileMapLayer "Solid"   tile_set = res://assets/tilesets/<tileset>.tres  (physics layer 1, collision tiap tile)
├─ TileMapLayer "Decor"   (tanpa collision)
├─ Rooms (Node2D) → Room (Node2D) per room: RoomBounds (Area2D+CollisionShape2D) + Marker2D spawn/exit + isi
├─ Entities (Node2D) → musuh, pickup, puzzle, pedestal (instance scene nyata)
├─ Player (instance player.tscn)
├─ HUD (instance hud.tscn)
└─ LevelAudio (Node) memutar musik level lewat AudioManager
```
**HUD (`scenes/ui/hud.tscn`)**: `CanvasLayer` → `HBoxContainer` ikon hati (`TextureRect` per hati), `TextureProgressBar` Energy (texture nyata atau `StyleBoxFlat`), label Logic Level + bar XP, ikon dan angka Data Fragments, 5 slot skill (ikon, kunci, cooldown overlay), label peringkat; semua terhubung ke `EventBus`, tanpa polling.
**UI layar:** `main_menu.tscn`, `level_select.tscn` (peta dengan 3 tombol region, status terkunci/terbuka), `end_session.tscn` (varian Menang/Kalah), `about.tscn` (nama + foto pengembang + dosen, atribusi aset dan lisensi Godot MIT), `pause_menu.tscn`, `market_ui.tscn`. Semua memakai `Control` dengan anchor/container yang benar, tema (`Theme`) dengan font pixel dari `assets/fonts/`.

### 5.4 Aturan "Node Asli" (diperiksa `tools/check_nodes.py`)
1. `Sprite2D` wajib `texture`; `AnimatedSprite2D` wajib `sprite_frames` (berisi frame dari aset nyata).
2. `CollisionShape2D` wajib `shape`; body dan area wajib punya child collision.
3. `TileMapLayer` wajib `tile_set`; TileSet harus berasal dari tileset sungguhan dan punya physics layer.
4. `AudioStreamPlayer` wajib `stream`.
5. Tidak ada node `Node`/`Node2D`/`Control` kosong tanpa script dan tanpa child (kecuali `Marker2D`).
6. Tidak ada script berisi stub (`pass`/hanya `extends`). Setiap script punya logika nyata dan dapat dijalankan.
7. Referensi `res://` harus valid (tidak ada resource hilang).
8. **Cara membuat scene:** boleh lewat editor Godot, tulis `.tscn` teks dengan hati-hati, atau skrip `@tool`/`--script` yang membangun node lalu `PackedScene.pack()` dan `ResourceSaver.save()`. Setelah membuat, **buka dan jalankan** scene itu; `.tscn` yang tidak pernah dijalankan dianggap belum Done.

---

## 6. Aset: Peta dan Karakter yang Sesuai GDD

### 6.1 Kriteria seleksi (nilai 1-5, simpan di `docs/assets/asset_selection.md`)
| Kriteria | Ketentuan |
|---|---|
| Lisensi | CC0 atau lisensi yang jelas dan sesuai; CC-BY boleh dengan atribusi. **Tolak** NC/ND, tanpa lisensi, atau tidak terverifikasi. |
| Kecocokan tema | Data Realm: reruntuhan digital (L1), benteng amber (L2), menara sci-fi ungu (L3). Boleh satu pack serbaguna dengan **tint palet berbeda** per region. |
| Konsistensi | Ukuran tile sama (16×16 atau 32×32), gaya garis dan palet serasi antara tileset, karakter, musuh, dan item. Hindari mencampur dua gaya berbeda tanpa penyelarasan. |
| Kelengkapan karakter | Idle, run, jump/fall, attack, hurt, death (cast opsional). |
| Kelengkapan tileset | Tanah/lantai, dinding, platform tipis, tepi, sudut, latar belakang atau parallax, props (pintu, tiang, peti, duri). |
| Daya tarik | Terbaca jelas pada zoom 2×, kontras dengan latar, kesan "digital". |
| Kemudahan impor | Spritesheet PNG teratur, tanpa format berbayar (.psd/.aseprite hanya bila bisa diekspor). |

### 6.2 Kandidat awal (sudah ditinjau per 10 November 2026; **verifikasi ulang lisensi dan isi paket di halaman sumber sebelum dipakai**)
| Kandidat | Isi | Lisensi yang tertera | Cocok untuk |
|---|---|---|---|
| **0x72: 16x16 Robot Tileset** (0x72.itch.io/16x16-robot-tileset) | Tileset sci-fi/robot 16×16 | CC0 (menurut katalog aset gratis; konfirmasi di halaman) | **L3 Foreign Spire**, Hub, nuansa digital |
| **0x72: MicroFantasy / 2-Bit Metroidvania Tileset** (0x72.itch.io) | Tileset fantasi 16×16 dan tileset 2-bit kecil | CC0 | L1/L2 cadangan atau gaya minimalis |
| **Vaca Roxa (bakudas): Generic Dungeon Pack** (bakudas.itch.io/generic-dungeon-pack) | Tileset dungeon 16×16 + karakter dengan animasi lari, lompat, bertahan, mati, serang | CC0 (tertera di halaman) | **L1 Record Ruins, L2 Citadel**, pemain cadangan |
| **JIK-A-4: Orius** (jik-a-4.itch.io/orius) | Pack platformer/metroidvania: karakter, senjata, musuh, jebakan, tile beranimasi (16×16/32×32) | CC0 (halaman Orius tercantum CC0; halaman "Orius asset pack" terpisah, **cek keduanya**) | Pemain + musuh |
| **V3X3D: Retro Lines** (v3x3d.itch.io/retro-lines) | Tileset 16×16 + karakter beranimasi | CC0 (judul halaman) | Pemain/tile alternatif |
| **Cole Sweet: Metroidvania tileset** (cole-sweet.itch.io/metroidvania-tileset) | Tileset sci-fi 16-bit | **CC-BY 4.0** (wajib atribusi) | L3 bila CC0 kurang |
| **Senari Rey: Pixel Art Platformer Tileset** | Tileset + sprite pemain + 4 musuh (bayar sesukamu) | **Tidak tertera di hasil tinjauan, verifikasi** | Cadangan |
| **Kenney** (kenney.nl, termasuk Pixel Platformer dan paket UI) | Aset platformer, UI, ikon | Umumnya **CC0** (verifikasi per paket) | UI, ikon, props, cadangan |
| **Brackeys' Platformer Bundle** (itch.io) | Karakter, tile, suara, musik piksel | Verifikasi di halaman | Prototipe cepat, SFX |

**Rekomendasi awal (verifikasi dengan scene uji):** pemain + musuh + L1/L2 dari **Vaca Roxa Generic Dungeon** atau **Orius** (pilih yang paling serasi), L3 dari **0x72 Robot Tileset**, disatukan dengan penyetelan palet (Python/Pillow atau `CanvasModulate` per region) bila selisih warna mengganggu. Jika dua gaya tampak bentrok, **pakai satu pack saja untuk semua level** dan bedakan region lewat tint dan props. Konsistensi lebih penting daripada keragaman.

**Aset yang dibuat sendiri/ditambahkan:** ikon HUD (hati, Energy, Fragment, ikon skill), sprite collectible (Memory Crystal, Logic Core, Schema Key, Ancient Record, Energy Cell), sprite anchor FK/PK, kristal kolom PK Barrier, SkillPedestal. Boleh digambar dengan Piskel/LibreSprite, dibuat dari bentuk sederhana berpalet sama lewat skrip Python, atau dihasilkan AI (catat tool, tanggal, prompt di `ASSETS.md`, lalu rapikan agar sesuai palet).

### 6.3 Musik, SFX, dan font
| Kebutuhan | Opsi | Catatan |
|---|---|---|
| SFX | **Kenney** (Interface Sounds, Impact Sounds, Digital Audio, umumnya CC0), **jsfxr/Bfxr** (buat sendiri, bebas), Freesound (filter CC0), OpenGameArt | Verifikasi lisensi per file. Simpan sebagai WAV mono pendek. |
| Musik | OpenGameArt (filter CC0), **Kevin MacLeod / Incompetech** (CC-BY, wajib atribusi), buat sendiri (LMMS, BeepBox) | OGG, loop, ≤2 MB per trek. Perlu: menu, level 1-3 (boleh satu trek bergantian), boss, jingle menang/kalah. |
| Font | Google Fonts berlisensi OFL: *Press Start 2P*, *VT323*, *Silkscreen* | Simpan file lisensi OFL bersama font. |

### 6.4 Proses pengerjaan aset (wajib urut)
1. Unduh ke `assets/inbox/` (jangan ubah). Jika halaman butuh klik manual atau login, beri manusia tautan + nama file, lanjutkan dengan placeholder.
2. Buat scene uji `scenes/_dev/asset_preview.tscn` (node asli: TileMapLayer + AnimatedSprite2D) untuk setiap kandidat, ambil screenshot, tempel di `asset_selection.md`.
3. Pilih, alasan tertulis, lalu pindahkan ke `assets/sprites|tilesets|audio|fonts`, atur Import (Nearest filter untuk pixel art), potong atlas, buat `SpriteFrames` dan `TileSet`.
4. Catat di `ASSETS.md` **sebelum** commit. Tambahkan atribusi ke layar About.

Template `ASSETS.md`:
```
| File | Jenis | Sumber/URL | Pembuat | Lisensi | Tanggal ambil | Dimodifikasi? | Atribusi wajib? |
```

---

## 7. Prosedur: GitHub, Trello, Laporan Presentasi

### 7.1 GitHub
- Repositori **private**, undang semua anggota, dosen, dan asisten. Cabang `main` stabil; kerja di `week2/<fitur>` (mis. `week2/player`).
- Commit kecil, pesan: `feat: player movement`, `fix: ...`, `asset: tambah tileset 0x72 (CC0)`, `docs: ...`, `chore: ...`.
- Pull Request ke `main` dengan templat: *Apa yang berubah, Cara menguji, Bukti (screenshot/GIF), Hasil check_nodes, Kartu Trello*.
- Tag `v0.2-week2` di akhir Minggu 2, rilis berisi build web (zip) dan catatan versi.
- Isi `docs/testing/functional_test.md` (mulai Minggu 2 dengan *smoke test*, dilengkapi Minggu 3-4): tabel kasus uji (ID, langkah, hasil diharapkan, hasil aktual, status), mencakup gerak, skill, puzzle, Market, save, kalah/menang. Alpha Test (pemain lain) disiapkan di `docs/testing/alpha_test.md`: kuesioner singkat + catatan bug.

### 7.2 Trello (REST API bila ada kredensial)
```bash
# buat kartu
curl -s -X POST "https://api.trello.com/1/cards" \
  -d "idList=$LIST_ID" -d "name=[W2][P0] W2-03 Player nyata" -d "desc=Kriteria: ..." \
  -d "key=$TRELLO_KEY" -d "token=$TRELLO_TOKEN"
# komentar bukti
curl -s -X POST "https://api.trello.com/1/cards/$CARD_ID/actions/comments" \
  --data-urlencode "text=Selesai. Commit: <url>. Bukti: docs/progress/week2/player.gif" \
  -d "key=$TRELLO_KEY" -d "token=$TRELLO_TOKEN"
# pindah kartu
curl -s -X PUT "https://api.trello.com/1/cards/$CARD_ID" -d "idList=$DONE_LIST_ID" \
  -d "key=$TRELLO_KEY" -d "token=$TRELLO_TOKEN"
```
Aturan: pindah ke `In Progress` saat mulai, `Testing` saat selesai tetapi belum diuji, `Done` hanya dengan bukti, `Blocked` dengan komentar alasan dan apa yang dibutuhkan. Jangan menyimpan key/token di repositori. Jika tidak ada akses: tulis `reports/trello_updates/<tanggal>.md` berisi daftar kartu + komentar siap salin dan minta manusia menempelkannya.

### 7.3 Pembaruan harian (wajib)
Sebelum menutup sesi: (1) lint, (2) export Web percobaan, (3) commit dan push, (4) kartu Trello diperbarui, (5) `docs/progress/week-2.md` ditambah entri hari itu, (6) laporan sesi dikirim (format di `HERMES_PROMPT.md`).

### 7.4 Bukti yang diterima
Screenshot/GIF dari game berjalan (simpan di `docs/progress/week2/`), keluaran lint, log `godot --headless ...`, tautan commit/PR, dan (bila memungkinkan) build web yang dapat dibuka. Jika tidak bisa menjalankan game, bukti = keluaran perintah + pernyataan jujur bahwa uji visual belum dilakukan, dan manusia diminta memverifikasi.

### 7.5 Paket laporan presentasi Minggu 2 (`docs/presentation/week2_outline.md`)
Susun draf slide (judul + isi) dan skrip demo 3 menit:
1. **Konteks:** proyek, materi (model relasional), tim, status jujur (Minggu 1 kosong, pengejaran di Minggu 2).
2. **Desain singkat:** core loop, 3 level, 3 skill, pemetaan skill → konsep basis data.
3. **Progres nyata:** tabel W2-01 sampai W2-17 dengan status Done/Partial/Not Done + bukti.
4. **Demo:** Start → Level Select → L1 (Data Scan, terminal tabel) → L2 (PK Barrier) → L3 (Relation Bridge, boss) → Menang.
5. **Aset dan lisensi:** pilihan aset, alasan, atribusi.
6. **Pemenuhan spesifikasi proyek:** atribut ≥3, collectible ≥3, ekonomi, audio, 3 level, struktur layar, output web.
7. **Metrik:** jumlah scene, node, script, baris kode (dari lint), commit, kartu Done.
8. **Risiko dan rencana Minggu 3-4:** dari bagian 2.1 dan 10.
Tambahkan rekaman layar 30-60 detik jika tersedia.

---

## 8. Referensi Game (apa yang diambil, bukan disalin)

| Game | Yang dijadikan acuan |
|---|---|
| **Super Metroid / Metroid Dread** | Struktur Metroidvania klasik: skill sebagai kunci rute, peta dan stasiun peta (→ Database Scanner), backtracking setelah skill baru. |
| **Hollow Knight** | Dunia terhubung berbentuk hub, bangku istirahat (→ Sync Point), kehilangan mata uang saat mati yang dapat diambil kembali (→ Corrupted Cache), bahasa visual peta. |
| **Axiom Verge** | Sci-fi piksel dengan mekanik *glitch* sebagai kemampuan (selaras Null Corruption), progresi alat-alat aneh. |
| **Ori and the Blind Forest** | Ritme pemberian skill dan rasa gerak yang halus; referensi umpan balik (partikel, suara) saat skill dipakai. |
| **Celeste** | Platforming adil: coyote time, jump buffer, lompat variabel; mode bantuan (→ Guided). |
| **Animal Well** | Puzzle lingkungan tanpa teks berlebihan, rahasia yang mendorong rasa ingin tahu. |
| **Baba Is You** | Aturan sebagai objek yang dimanipulasi, analog constraint sebagai aturan data yang bisa diuji. |
| **Human Resource Machine / 7 Billion Humans** | Mengajarkan konsep komputasi lewat mekanik, bukan kuis; pola umpan balik kesalahan yang mendidik. |
| **SQL Murder Mystery (Knight Lab), SQL Island** | Contoh pembelajaran basis data berbasis cerita; pola narasi untuk dialog Cursor. |
| **Godot docs dan godot-demo-projects (MIT)** | Implementasi referensi: `CharacterBody2D` platformer, `TileMapLayer`, ekspor Web, demo platformer 2D yang boleh dijadikan kerangka awal (spesifikasi proyek mengizinkan memakai template). |

---

## 9. QA, Ekspor Web, dan Jalur Cadangan

### 9.1 Perintah penting
```bash
godot --version
godot --headless --path . --import                      # impor aset baru
godot --headless --path . --check-only --script res://scripts/xxx.gd
godot --headless --path . --quit-after 120              # jalankan main scene 120 frame (deteksi error)
python tools/check_nodes.py                             # linter anti node kosong
godot --headless --path . --export-release "Web" build/web/index.html
python -m http.server 8000 --directory build/web        # uji di http://localhost:8000
```
Preset ekspor bernama **"Web"** (HTML5, tanpa dukungan thread) harus ada di `export_presets.cfg`; export templates harus terpasang. Game Web tidak dapat dibuka lewat `file://`, selalu uji lewat server HTTP. Tes manual di Chrome/Edge/Firefox.

### 9.2 Smoke test sebelum menutup hari
Mulai dari Start Screen: Play berfungsi; Player bergerak, lompat, serang; HUD berubah; collectible diambil; skill hari itu berfungsi; kematian dan respawn; keluar ke Level Select; tidak ada error merah di konsol.

### 9.3 Jalur cadangan
| Masalah | Tindakan |
|---|---|
| Godot tidak ada di mesin agent | Minta manusia memasang Godot (versi sama) atau menjalankan perintah verifikasi dan membagikan keluarannya. Hindari klaim "berhasil" tanpa verifikasi. |
| Tidak ada display untuk screenshot | Gunakan `xvfb-run` bila tersedia, atau skrip yang menyimpan `get_viewport().get_texture().get_image().save_png()`; bila tidak mungkin, minta manusia mengirim screenshot. |
| Tidak bisa mengunduh aset | Berikan daftar tautan, nama file, folder tujuan (`assets/inbox/`); sementara buat placeholder dari gambar sungguhan agar tidak ada node kosong. |
| Lisensi aset tidak jelas | Jangan dipakai. Pilih kandidat lain atau buat sendiri. |
| Export Web gagal | Periksa templates, nama preset, dan error shader/fitur; pastikan renderer Compatibility dan tanpa thread; laporkan log lengkap di `OPEN_QUESTIONS.md`. |
| Tidak ada kredensial Trello/GitHub | Hasilkan teks siap tempel di `reports/` dan beri tahu manusia. |
| Waktu habis | Pangkas sesuai 2.3; kerjakan **tiga level playable** lebih dulu. |

---

## 10. Risiko dan Mitigasi
| Risiko | Dampak | Mitigasi |
|---|---|---|
| Waktu sangat ketat (Minggu 1 kosong) | Tiga level tidak selesai | Fokus P0; room dibuat kecil; pangkas P1 dan dekorasi; kerja harian dengan bukti |
| Gaya aset bentrok | Tampilan tidak menarik | Satu pack utama + tint region; scene uji sebelum memutuskan |
| Node kosong atau stub | Gagal syarat dosen | Linter wajib, review PR, aturan 5.4 |
| Puzzle membingungkan | Pemain tersesat | Cursor memberi petunjuk bertahap; pesan error edukatif; Hint |
| Bug ekspor Web | Tidak bisa dipresentasikan | Export percobaan **setiap hari**; hindari fitur yang tidak didukung Web |
| Konten basis data keliru | Merusak tujuan edukasi | Verifikasi data puzzle lewat kode (4.1); catat pertanyaan di `OPEN_QUESTIONS.md`; minta tim meninjau teks Ancient Record |
| Ruang lingkup membengkak | Tidak selesai | Hanya fitur di GDD; keputusan dicatat di `DECISIONS.md` |

---

## 11. Catatan Hubungan dengan Spesifikasi Proyek Akhir
Dokumen ini menutup syarat: genre diperbolehkan (bukan novel/endless runner), 2D, output Web, kontrol keyboard dan mouse, ≥3 atribut (5), ≥3 collectible (6), ekonomi (Market + bonus Logic Level), audio, aset berlisensi, ≥3 level berkisah terkait materi, dan struktur Start/Level Select/Game Session/End Session/About. Luaran wajib akhir (build web, repositori GitHub lengkap, GDD final, poster A4, trailer ~5 menit, HKI) dijadwalkan di Minggu 4.
