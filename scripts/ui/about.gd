extends Control
## About - identitas tim, dosen, dan atribusi lisensi aset (GDD 5.3).

@onready var body: Label = $Body
@onready var back_btn: Button = $Back

func _ready() -> void:
	AudioManager.play_music("menu")
	body.text = """RELATIONAL DATA CHRONICLES: THE LOST SCHEMA
Kelompok 9 - Mata Kuliah Basis Data (Pengenalan Model Data Relasional)

Project + Level Manager : Mohammad Hafidz Suhaiby
Artist                  : Muhammad Naufal Zhafran
Programmer              : Mohammad Ikhsan Ridho

Dosen pengampu          : (isi nama dosen)
Asisten                 : (isi nama asisten)

Engine: Godot 4.7.2 stable (MIT License).
Font  : Press Start 2P (SIL Open Font License 1.1), VT323 (OFL 1.1).
Sprite, tile, UI, dan audio proyek ini dibuat sendiri lewat skrip
Python (tools/artgen.py, tools/audio_gen.py) sehingga lisensinya milik tim.
Rincian lengkap: ASSETS.md."""
	back_btn.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		RoomManager.goto_menu())
