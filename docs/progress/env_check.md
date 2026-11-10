# Env Check — Fase 0 (10 November 2026)

Diperiksa dari terminal agent (Docker/WSL2, workspace `/workspace`).

| Item | Perintah | Hasil | Status |
|---|---|---|---|
| Godot | `/workspace/_tools/godot --version` | `4.7.2.stable.official.ed1daf0bf` | OK |
| Python | `python3 --version` | `3.13.16` | OK |
| Git | `git --version` | `2.47.3` | OK (repo di-init sesi ini) |
| Export template Web | `ls ~/.local/share/godot/export_templates/4.7.2.stable/` | `web_nothreads_release.zip`, `version.txt` | OK |
| Display untuk screenshot | `which xvfb-run` | `/usr/bin/xvfb-run` | OK — dipakai untuk `--shots` |
| PIL (buat aset) | `python3 -c "import PIL"` | tersedia | OK |
| ffmpeg (GIF) | `ffmpeg -version` | **tidak terpasang** | Tidak dipakai; bukti berupa PNG |
| `gh` CLI | `gh auth status` | **tidak terpasang** | Repo Git lokal saja; push dilakukan manusia |
| Trello API | `$TRELLO_KEY`, `$TRELLO_TOKEN` | **kosong** | Kartu via `reports/trello_updates/*.md` (siap tempel) |

## Konsekuensi (jalur cadangan GDD 9.3)

1. **Tidak ada display fisik** → screenshot diambil via `xvfb-run godot --path . -- --shots`
   (skrip `scripts/_dev/shots.gd`, 7 PNG tersimpan di `docs/progress/week2/`). Terbukti berjalan.
2. **Tidak ada kredensial Trello** → semua kartu + komentar bukti ditulis ke
   `reports/trello_updates/2026-11-10.md`; manusia menempelkannya ke papan.
3. **Tidak ada `gh`** → commit dilakukan lokal (b222513, tag `v0.2-week2`); push ke GitHub dilakukan
   manusia setelah repo private dibuat dan anggota diundang.
4. **Tidak ada ffmpeg** → bukti visual PNG, bukan GIF. GIF gerak dapat ditambahkan Minggu 3 bila
   perlu (butuh ffmpeg/imagemagick).

## Catatan ruang disk

`/root` adalah tmpfs 1 GB dan sempat **penuh** saat menyalin export template (salinan parsial
0-byte menyebabkan export gagal). Solusi: hapus direktori template lalu salin hanya
`web_nothreads_release.zip` (10 MB). Build Web (39 MB) disimpan di `/workspace` (tmpfs 10 GB).
