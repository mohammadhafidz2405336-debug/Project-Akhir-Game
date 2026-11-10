# Keputusan Teknis (DECISIONS.md)

Catatan keputusan yang menyimpang dari atau belum dijawab GDD. Format: tanggal — keputusan — alasan.

1. **2026-11-10 — Aset dibuat prosedural, bukan pack itch.io.** GDD 6.2 menyebut kandidat CC0 (0x72, Vaca Roxa, Orius, Kenney).
   Keputusan: seluruh sprite/tileset/audio dibuat sendiri via `tools/artgen.py` + `tools/audio_gen.py`.
   Alasan: konsistensi palet antar-3-region terjaga, lisensi bebas risiko, dan item spesifik (kristal PK Barrier,
   anchor FK/PK, pedestal) tidak tersedia di pack gratis. Kandidat tetap dicatat di `ASSETS.md` bagian 3.

2. **2026-11-10 — Geometri level disimpan di `data/levels/<id>.json` (peta ASCII) dan dicat oleh `level_base.gd`.**
   Alasan: satu tempat untuk mengubah layout, mudah diverifikasi, dan tiga scene level cukup menetapkan `level_id`
   sehingga isi scene tetap kecil dan lolos linter.

3. **2026-11-10 — Scene dihasilkan oleh `tools/scenegen.py`, bukan ditulis tangan satu per satu.**
   Alasan: menjamin setiap `Sprite2D` punya `texture`, setiap body/area punya `CollisionShape2D` ber-shape, dan
   setiap `TileMapLayer` punya `tile_set` (GDD 5.4). Regenerasi = `python tools/scenegen.py`.

4. **2026-11-10 — Satu skrip `enemy_base.gd` + tabel `const VARIANTS` untuk 5 varian musuh**, bukan 5 skrip duplikat.
   Alasan: perilaku berbeda hanya pada frame, HP, damage, kecepatan, dan jenis behavior; menghindari duplikasi 300+ baris.

5. **2026-11-10 — `preload` scene musuh diganti `load()` dengan tipe eksplisit.**
   Alasan: preload siklik (scene musuh memakai skrip yang mem-preload scene musuh) membuat `load()` skrip gagal dan
   `can_instantiate()` bernilai false. `load()` menunda resolusi sampai runtime.

6. **2026-11-10 — Platform hantu (tile atlas 5:1) tidak memakai collision tile.**
   Alasan: collision fisika pada tile akan menabrak pemain dari samping; tabrakan diserahkan ke skrip `GhostPlatform`
   (aktif hanya saat terlihat/ter-scan), sesuai desain "jalan yang muncul setelah Data Scan".

7. **2026-11-10 — Autotest dijalankan lewat flag CLI `-- --autotest` yang di-hook dari `main_menu.gd`**, bukan scene terpisah.
   Alasan: menguji jalur nyata (Start → level) tanpa menambah scene debug yang harus lolos linter.

8. **2026-11-10 — Nilai anchor Relation Bridge memakai nilai kolom, bukan nama baris.**
   Contoh: FK Anchor `MK03 → id_dosen = 7` disimpan sebagai `anchor_value = "7"` dengan label `MK03.id_dosen`.
   Alasan: validasi harus membandingkan nilai FK dengan nilai PK (`VARCHAR` di DBMS), bukan nama entitas.
   Kesalahan awal (memakai `"MK01"`) membuat link valid ditolak; ditemukan oleh autotest kasus 5.

9. **2026-11-10 — `build/web/` masuk `.gitignore`; bukti export disimpan sebagai log + tangkapan layar.**
   Alasan: 39 MB per commit tidak perlu; build dapat direproduksi dengan satu perintah di README.
   (GDD 5.1 meminta minimal aset sumber dan `.import` di-commit — keduanya di-commit.)

## 11. Kamera menempel player (10 Nov 2026)

Kamera memakai `position_smoothing` saja, **tanpa** `drag_*_margin`. Drag margin
membuat kamera diam sampai player mendekati tepi layar, dan pemain membacanya
sebagai "ada jeda" saat berjalan ke satu arah. Level 1-3 masih muat dalam satu
layar per room, jadi dead-zone tidak diperlukan.
