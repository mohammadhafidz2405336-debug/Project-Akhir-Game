extends Button
class_name DropSlot

## Slot tujuan drop. `column` = nama kolom yang diwakili slot ini.

signal value_dropped(payload: Dictionary)

var column: String = ""
var filled: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(200, 44)
	add_theme_font_size_override("font_size", 11)
	text = "(seret nilai ke sini)"
	_apply_style(Color(0.10, 0.12, 0.15))

func _apply_style(bg: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(2)
	sb.border_color = Color(0.3, 0.4, 0.5)
	sb.corner_radius_top_left = 5
	sb.corner_radius_top_right = 5
	sb.corner_radius_bottom_left = 5
	sb.corner_radius_bottom_right = 5
	for s in ["normal", "hover", "pressed"]:
		add_theme_stylebox_override(s, sb)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return not filled and data is Dictionary and data.get("type") == "value"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data):
		value_dropped.emit(data)

func mark_filled(value_text: String, ok: bool) -> void:
	filled = true
	text = value_text
	_apply_style(Color(0.16, 0.34, 0.22) if ok else Color(0.38, 0.16, 0.16))