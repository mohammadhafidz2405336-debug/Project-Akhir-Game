extends Node
## AudioManager - musik (loop) dan SFX lewat pool player (GDD 5.2, W2-11).

const MUSIC := {
	"menu": "res://assets/audio/music/menu.wav",
	"level": "res://assets/audio/music/level.wav",
	"boss": "res://assets/audio/music/boss.wav",
}
const SFX := {
	"jump": "res://assets/audio/sfx/jump.wav",
	"attack": "res://assets/audio/sfx/attack.wav",
	"hurt": "res://assets/audio/sfx/hurt.wav",
	"pickup": "res://assets/audio/sfx/pickup.wav",
	"ui_click": "res://assets/audio/sfx/ui_click.wav",
	"puzzle_correct": "res://assets/audio/sfx/puzzle_correct.wav",
	"puzzle_wrong": "res://assets/audio/sfx/puzzle_wrong.wav",
	"purchase": "res://assets/audio/sfx/purchase.wav",
	"death": "res://assets/audio/sfx/death.wav",
	"skill": "res://assets/audio/sfx/skill.wav",
	"bridge": "res://assets/audio/sfx/bridge.wav",
	"victory": "res://assets/audio/sfx/victory.wav",
}

var _music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _cache := {}
var _current := ""
var music_db := -10.0
var sfx_db := -6.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_pool.append(p)

func _stream(path: String) -> AudioStream:
	if not _cache.has(path):
		var s := load(path)
		if s is AudioStreamWAV:
			var w: AudioStreamWAV = s
			w.loop_mode = AudioStreamWAV.LOOP_FORWARD
			w.loop_begin = 0
			w.loop_end = int(w.get_length() * w.mix_rate)
		_cache[path] = s
	return _cache[path]

func play_music(name: String) -> void:
	if _current == name and _music_player.playing:
		return
	if not MUSIC.has(name):
		return
	_current = name
	_music_player.stream = _stream(MUSIC[name])
	_music_player.volume_db = music_db
	_music_player.play()

func stop_music() -> void:
	_current = ""
	_music_player.stop()

func play_sfx(name: String) -> void:
	if not SFX.has(name):
		return
	for p in _sfx_pool:
		if not p.playing:
			p.stream = _stream(SFX[name])
			p.volume_db = sfx_db
			p.play()
			return