extends Area2D
## Anchor - PK Anchor dan FK Anchor untuk Relation Bridge (GDD 3.3, 4.4).

@export_enum("pk", "fk") var anchor_type := "pk"
@export var anchor_value := "1"
@export var anchor_label := "id_dosen"
@export var accepts_values: Array = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _selected := false
var _linked := false

func _ready() -> void:
	add_to_group("relation_anchor")
	add_to_group("pk_anchor" if anchor_type == "pk" else "fk_anchor")
	add_to_group("scannable")
	sprite.texture = load("res://assets/sprites/ui/anchor_%s.png" % ("pk" if anchor_type == "pk" else "fk"))
	match anchor_type:
		"pk":
			EventBus.message.emit("")
			label.text = "%s\n%s" % [anchor_label, anchor_value]
		_:
			label.text = "%s\n%s" % [anchor_label, anchor_value]

func value_text() -> String:
	return anchor_value

func set_selected(v: bool) -> void:
	_selected = v
	sprite.modulate = Color(1.4, 1.4, 0.7) if v else Color(1, 1, 1)

func is_selectable() -> bool:
	return not _linked

func accepts(value: String) -> bool:
	if anchor_type != "pk":
		return false
	if accepts_values.is_empty():
		return value == anchor_value
	return accepts_values.has(value)

func on_linked() -> void:
	_linked = true
	sprite.modulate = Color(1.0, 1.6, 1.2)
	label.modulate = Color(1, 1, 1)

func reveal(_seconds: float) -> void:
	label.visible = true
	var t := create_tween()
	t.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(_seconds)