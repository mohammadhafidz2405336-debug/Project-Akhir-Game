# Pemilihan Aset (Fase 1, W2-02)

Tanggal: 10 November 2026. Kriteria penilaian mengikuti GDD 6.1 (skala 1-5).

## 1. Shortlist kandidat

| # | Kandidat | Kategori | Lisensi | Tema | Konsistensi | Kelengkapan | Impor | Total |
|---|---|---|---|---|---|---|---|---|
| A | 0x72 — 16x16 Robot Tileset | Tileset | CC0 | 4 | 3 | 3 | 5 | 15 |
| B | Vaca Roxa — Generic Dungeon Pack | Tileset + karakter | CC0 | 3 | 4 | 4 | 4 | 15 |
| C | JIK-A-4 — Orius | Karakter + musuh | CC0 | 4 | 3 | 5 | 3 | 15 |
| D | Kenney — Pixel Platformer + UI | UI/ikon/props | CC0 | 3 | 3 | 5 | 5 | 16 |
| E | V3X3D — Retro Lines | Tileset + karakter | CC0 | 3 | 4 | 3 | 4 | 14 |
| **F** | **Aset prosedural buatan tim** (`tools/artgen.py`) | Tileset + karakter + UI + audio | Milik tim | **5** | **5** | **5** | **5** | **20** |

## 2. Keputusan

**Dipilih F: aset prosedural buatan tim**, bukan kandidat itch.io.

Alasan (tertulis sesuai GDD 6.4 langkah 3):
1. **Konsistensi palet terjamin.** Satu palet per region dihasilkan dari satu sumber konstanta warna,
   sehingga L1 teal-abu, L2 amber-perunggu, dan L3 ungu-magenta pasti serasi — risiko utama GDD 10
   ("gaya aset bentrok") hilang total.
2. **Lisensi bebas risiko.** Tidak ada aset pihak ketiga, jadi tidak ada halaman CC0 yang perlu
   diverifikasi ulang atau atribusi yang bisa terlewat.
3. **Kelengkapan animasi sesuai GDD 5.3.** Pemain punya 8 animasi (idle, run, jump, fall, attack,
   hurt, death, cast) dengan ukuran frame 24×24 dan hitbox kaki yang pas dengan konstanta 1.4.
4. **Impor bersih.** PNG atlas 16×16 dan `.tres` (TileSet, SpriteFrames) dibuat terprogram, tidak ada
   spritesheet berantakan atau format berbayar.
5. **Semua kebutuhan khusus terpenuhi**: anchor FK/PK, kristal kolom PK Barrier, pedestal skill,
   terminal, sync point, null orb boss — item-item ini jarang tersedia di pack gratis mana pun.

Kandidat A-E tetap dicatat (lihat `ASSETS.md` bagian 3) sebagai bukti proses seleksi, bukan dipakai.

## 3. Bukti visual

Tiga region dengan palet berbeda, dari game berjalan (960×540, zoom kamera 2×):

| Level | Tangkapan layar | Palet |
|---|---|---|
| L1 Record Ruins | `docs/progress/week2/02_level1_start.png`, `03_level1_ruins.png` | teal `#1D3237` / aksen `#7AE8D4` |
| L2 Key Citadel | `docs/progress/week2/04_level2_citadel.png` | perunggu-amber `#26180E` / aksen emas |
| L3 Foreign Spire | `docs/progress/week2/05_level3_spire.png` | ungu `#120C21` / aksen magenta |

## 4. Atribusi yang dipasang

Aset sendiri tidak perlu atribusi; yang wajib dicantumkan hanya:
- Font **Press Start 2P** & **VT323** — SIL OFL 1.1 (dicantumkan di layar About + `ASSETS.md`).
- **Godot Engine 4.7.2** — MIT (dicantumkan di layar About).