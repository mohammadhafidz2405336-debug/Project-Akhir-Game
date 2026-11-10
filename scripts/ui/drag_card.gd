extends Button
class_name DragValueCard

## Kartu nilai yang bisa diseret ke DropSlot.

var payload: Dictionary = {}

func _ready() -> void:
	flat = true
	custom_minimum_size = Vector2(120, 40)
	add_theme_font_size_override("font_size", 11)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.13, 0.16, 0.20)
	sb.border_width_bottom = 2
	sb.border_color = Color(0.35, 0.45, 0.55)
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	for s in ["normal", "hover", "pressed"]:
		add_theme_stylebox_override(s, sb)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := Label.new()
	preview.text = text
	preview.add_theme_font_size_override("font_size", 12)
	set_drag_preview(preview)
	return payload