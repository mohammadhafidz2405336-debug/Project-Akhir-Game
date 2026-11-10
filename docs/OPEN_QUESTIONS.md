# Open Questions (Minggu 2)

## 1. Kredensial pihak ketiga (Trello / GitHub)
- **Trello:** Tidak ada $TRELLO_KEY / $TRELLO_TOKEN (sudah diverifikasi di env_check).
- **GitHub:** CLI `gh` tidak terpasang.
**Solusi:** Gunakan dump kartu siap tempel `reports/trello_updates/*.md`.

## 2. Build web — memastikan pengiriman akhir
- Export sudah berjalan (`godot --export-release "Web"` -> HTTP 200).
- Build ukurannya 39 MB (termasuk .wasm). Bisa dipertimbangkan pemotongan asset (misal, hilangkan audio yang tidak kritis) — tetapi opsi ini memerlukan keputusan.

## 3. Pipeline CI/CD otomatis
- Saat ini tidak ada GitHub Actions. Ini tidak wajib untuk minggu ini.
**Tetap:** manual push setelah minggu 2 selesai.

## 4. Autotest coverage
- Autotest `scripts/_dev/autotest.gd` saat ini berjalan 19 pass (termasuk check_nodes).
- Di minggu 3 perlu tambahkan cek untuk `MarketManager`, `SaveManager`, `Corrupted Cache`, dan `Anomaly` untuk mode Difficulty.

## 5. Alpha Test pemain lain
- Tidak ada daftar pemain. Rencana: buat daftar via Google Form / Discord; tunjukkan hasil functional test selesai.

## 6. Tagihan dokumen presentasi akhir
- `docs/presentation/week2_outline.md` belum dibuat. Perlu membuat outline 8 slide (judul, GDD, level design, gameplay, UI, audio, web export, roadmap).

## 7. Route pengeluaran waktu (deadlines)
- Minggu 3 direncanakan untuk fitur P1 (Market, Save, Difficulty, Corrupted Cache).
- Minggu 4: presentasi, submit final, packaging tiket untuk kelompok lain.

## 8. Node kosong / skrip stub di repositori
- `tools/t.gd`, `tools/t2.gd`, `tools/t3.gd`, `tools/probe.gd` adalah skrip debugging sementara. Bisa dihapus akhir minggu ini (Fase 0).

## 9. Integritas aset: memastikan semua aset berlisensi (pihak ketiga boleh, CC0, mandiri)
- Dilihat di `ASSETS.md`. Seluruh aset buatan sendiri; font PressStart2P dan VT323 adalah
   Google Fonts berlisensi OFL; engine Godot MIT.

## 10. Memastikan semua kartu Trello memiliki bukti
- Laporan saat ini hanya mencakup kartu `W2-01...W2-13`; kartu berikutnya (P1) tidak selesai.
- Simpan bukti di `reports/trello_updates/`.

---

*Catatan: Pertanyaan ini dibersihkan dengan benar; akan diperiksa lagi di hari-hari berikutnya.*
