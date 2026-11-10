#!/usr/bin/env python3
"""scenegen.py - generator .tscn nyata (bukan kerangka kosong) untuk proyek Godot 4.

Menulis scene item, puzzle, skill, world, musuh, level, dan UI dengan node asli:
setiap Sprite2D punya texture, setiap body/area punya CollisionShape2D ber-shape,
setiap TileMapLayer punya tile_set. Jalankan: python3 tools/scenegen.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def write(rel, text):
    path = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("write", rel)


def scene(uid, ext, subs, nodes):
    """ext: [(type, path, id)], subs: [(type, id, props)], nodes: [(name,type,parent,props,groups)]"""
    steps = 1 + len(ext) + len(subs)
    out = ['[gd_scene load_steps=%d format=3 uid="uid://%s"]' % (steps, uid), ""]
    for t, p, i in ext:
        out.append('[ext_resource type="%s" path="%s" id="%s"]' % (t, p, i))
    if ext:
        out.append("")
    for t, i, props in subs:
        out.append('[sub_resource type="%s" id="%s"]' % (t, i))
        out += props
        out.append("")
    for name, t, parent, props, groups in nodes:
        if t is None:
            head = '[node name="%s"' % name
        else:
            head = '[node name="%s" type="%s"' % (name, t)
        if parent:
            head += ' parent="%s"' % parent
        if groups:
            head += " groups=[%s]" % ", ".join('"%s"' % g for g in groups)
        inst = [x for x in props if x.startswith("instance = ")]
        props = [x for x in props if not x.startswith("instance = ")]
        if inst:
            head += " " + inst[0]
        head += "]"
        out.append(head)
        out += props
        out.append("")
    return "\n".join(out)


S = "res://scripts/"
TXT = "res://assets/sprites/"

# ---------------------------------------------------------------- item pickup
write("scenes/items/pickup.tscn", scene(
    "c01pickup5dscn0",
    [("Script", S + "items/pickup.gd", "1_s"),
     ("Texture2D", TXT + "items/fragment.png", "2_tex")],
    [("CircleShape2D", "c_pick", ["radius = 7.0"])],
    [
        ("Pickup", "Area2D", None, ["collision_layer = 0", "collision_mask = 2",
                                    'script = ExtResource("1_s")'], None),
        ("Sprite2D", "Sprite2D", ".", ['texture = ExtResource("2_tex")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['shape = SubResource("c_pick")'], None),
    ]))

# ---------------------------------------------------------------- anchor PK/FK
write("scenes/puzzle/anchor.tscn", scene(
    "c02anchor9dscn0",
    [("Script", S + "puzzle/anchor.gd", "1_s"),
     ("Texture2D", TXT + "ui/anchor_pk.png", "2_pk"),
     ("Texture2D", TXT + "ui/anchor_fk.png", "3_fk")],
    [("RectangleShape2D", "r_anchor", ["size = Vector2(16, 20)"])],
    [
        ("Anchor", "Area2D", None,
         ["collision_layer = 4", "collision_mask = 0",
          'script = ExtResource("1_s")'], ["relation_anchor"]),
        ("Sprite2D", "Sprite2D", ".", ['texture = ExtResource("2_pk")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['shape = SubResource("r_anchor")'], None),
        ("Label", "Label", ".",
         ['offset_left = -26.0', 'offset_top = -32.0', 'offset_right = 26.0',
          'offset_bottom = -16.0', 'theme_override_font_sizes/font_size = 7',
          'text = "id_dosen = 1"', 'horizontal_alignment = 1'], None),
    ]))

# ---------------------------------------------------------------- PK barrier
write("scenes/puzzle/pk_barrier.tscn", scene(
    "c03pkbarrierdscn",
    [("Script", S + "puzzle/pk_barrier.gd", "1_s"),
     ("Texture2D", TXT + "ui/crystal_icon.png", "2_tex")],
    [("RectangleShape2D", "r_bar", ["size = Vector2(48, 80)"])],
    [
        ("PKBarrier", "StaticBody2D", None,
         ["collision_layer = 1", "collision_mask = 0",
          'script = ExtResource("1_s")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(24, -40)', 'shape = SubResource("r_bar")'], None),
        ("Sprite2D", "Sprite2D", ".",
         ['texture = ExtResource("2_tex")', 'position = Vector2(24, -40)',
          'modulate = Color(0.6, 0.85, 1, 0.35)'], None),
        ("Crystals", "Node2D", ".", [], None),
        ("CrystalGlow", "Sprite2D", "Crystals",
         ['texture = ExtResource("2_tex")', 'modulate = Color(0.6, 0.9, 1, 0.3)',
          'position = Vector2(24, -40)'], None),
        ("Hint", "Label", ".", ['offset_left = -30.0', 'offset_top = -104.0',
                                'offset_right = 90.0', 'offset_bottom = -88.0',
                                'theme_override_font_sizes/font_size = 8',
                                'text = "PRIMARY KEY?"'], None),
    ]))

# --------------------------------------------------------------- terminal
write("scenes/puzzle/puzzle_terminal.tscn", scene(
    "c04terminaldscn0",
    [("Script", S + "puzzle/puzzle_terminal.gd", "1_s"),
     ("Texture2D", TXT + "ui/terminal.png", "2_tex")],
    [("RectangleShape2D", "r_term", ["size = Vector2(28, 30)"])],
    [
        ("PuzzleTerminal", "Area2D", None,
         ["collision_layer = 32", "collision_mask = 0",
          'script = ExtResource("1_s")'], ["interactable"]),
        ("Sprite2D", "Sprite2D", ".", ['texture = ExtResource("2_tex")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(0, -15)', 'shape = SubResource("r_term")'], None),
        ("Label", "Label", ".",
         ['offset_left = -18.0', 'offset_top = -40.0', 'offset_right = 22.0',
          'offset_bottom = -26.0', 'theme_override_font_sizes/font_size = 8',
          'text = "[E] TERMINAL"'], None),
    ]))

# --------------------------------------------------------------- secret wall
write("scenes/puzzle/secret_wall.tscn", scene(
    "c05secretwalldscn",
    [("Script", S + "puzzle/secret_wall.gd", "1_s"),
     ("Texture2D", "res://assets/tilesets/l1.png", "2_tex")],
    [("RectangleShape2D", "r_wall", ["size = Vector2(32, 48)"])],
    [
        ("SecretWall", "StaticBody2D", None,
         ["collision_layer = 1", "collision_mask = 0",
          'script = ExtResource("1_s")'], ["scannable"]),
        ("Sprite2D", "Sprite2D", ".",
         ['texture = ExtResource("2_tex")', 'position = Vector2(16, -24)',
          'region_enabled = true', 'region_rect = Rect2(48, 16, 16, 16)'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(16, -24)', 'shape = SubResource("r_wall")'], None),
    ]))

# --------------------------------------------------------------- pedestal
write("scenes/puzzle/skill_pedestal.tscn", scene(
    "c06pedestaldscn0",
    [("Script", S + "puzzle/skill_pedestal.gd", "1_s"),
     ("Texture2D", TXT + "ui/pedestal.png", "2_tex")],
    [("RectangleShape2D", "r_ped", ["size = Vector2(24, 24)"])],
    [
        ("SkillPedestal", "Area2D", None,
         ["collision_layer = 32", "collision_mask = 0",
          'script = ExtResource("1_s")'], ["interactable"]),
        ("Sprite2D", "Sprite2D", ".", ['texture = ExtResource("2_tex")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(0, -12)', 'shape = SubResource("r_ped")'], None),
        ("Label", "Label", ".",
         ['offset_left = -30.0', 'offset_top = -34.0', 'offset_right = 34.0',
          'offset_bottom = -20.0', 'theme_override_font_sizes/font_size = 7',
          'text = "[E] SKILL"'], None),
    ]))

# --------------------------------------------------------------- sync point
write("scenes/puzzle/sync_point.tscn", scene(
    "c07syncpointdscn",
    [("Script", S + "puzzle/sync_point.gd", "1_s"),
     ("Texture2D", TXT + "ui/sync_point.png", "2_tex")],
    [("RectangleShape2D", "r_sync", ["size = Vector2(18, 24)"])],
    [
        ("SyncPoint", "Area2D", None,
         ["collision_layer = 32", "collision_mask = 2",
          'script = ExtResource("1_s")'], ["interactable"]),
        ("Sprite2D", "Sprite2D", ".", ['texture = ExtResource("2_tex")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(0, -12)', 'shape = SubResource("r_sync")'], None),
        ("Label", "Label", ".",
         ['offset_left = -24.0', 'offset_top = -32.0', 'offset_right = 26.0',
          'offset_bottom = -20.0', 'theme_override_font_sizes/font_size = 7',
          'text = "SYNC"'], None),
    ]))

# --------------------------------------------------------------- gate
write("scenes/puzzle/gate.tscn", scene(
    "c08gatedscn0",
    [("Script", S + "puzzle/gate.gd", "1_s"),
     ("Texture2D", "res://assets/tilesets/l2.png", "2_tex")],
    [("RectangleShape2D", "r_gate", ["size = Vector2(16, 64)"])],
    [
        ("Gate", "StaticBody2D", None,
         ["collision_layer = 1", "collision_mask = 0",
          'script = ExtResource("1_s")'], None),
        ("Sprite2D", "Sprite2D", ".",
         ['texture = ExtResource("2_tex")', 'position = Vector2(8, -32)',
          'region_enabled = true', 'region_rect = Rect2(80, 0, 16, 16)'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(8, -32)', 'shape = SubResource("r_gate")'], None),
    ]))

# --------------------------------------------------------------- exit marker
write("scenes/puzzle/exit_marker.tscn", scene(
    "c09exitmarkerdscn",
    [("Script", S + "world/exit_marker.gd", "1_s"),
     ("Texture2D", TXT + "ui/key_icon.png", "2_tex")],
    [("RectangleShape2D", "r_exit", ["size = Vector2(24, 32)"])],
    [
        ("ExitMarker", "Area2D", None,
         ["collision_layer = 0", "collision_mask = 2",
          'script = ExtResource("1_s")'], None),
        ("Sprite2D", "Sprite2D", ".", ['texture = ExtResource("2_tex")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(0, -16)', 'shape = SubResource("r_exit")'], None),
        ("Label", "Label", ".",
         ['offset_left = -30.0', 'offset_top = -40.0', 'offset_right = 34.0',
          'offset_bottom = -26.0', 'theme_override_font_sizes/font_size = 7',
          'text = "EXIT"'], None),
    ]))

# --------------------------------------------------------------- skills
write("scenes/skills/bridge.tscn", scene(
    "c10bridgedscn00",
    [("Script", S + "skills/bridge.gd", "1_s"),
     ("Texture2D", TXT + "ui/anchor_fk.png", "2_tex")],
    [("RectangleShape2D", "r_bridge", ["size = Vector2(96, 8)"])],
    [
        ("Bridge", "StaticBody2D", None,
         ["collision_layer = 1", "collision_mask = 0",
          'script = ExtResource("1_s")'], ["bridge"]),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['shape = SubResource("r_bridge")', 'position = Vector2(48, 0)'], None),
        ("Line2D", "Line2D", ".",
         ['points = PackedVector2Array(0, 0, 96, 0)', 'width = 5.0',
          'default_color = Color(0.45, 0.95, 1, 1)'], None),
        ("Sprite2D", "Sprite2D", ".",
         ['texture = ExtResource("2_tex")', 'modulate = Color(1, 1, 1, 0.25)',
          'position = Vector2(48, -18)'], None),
        ("Timer", "Timer", ".", ["wait_time = 20.0", "one_shot = true"], None),
    ]))

write("scenes/skills/scan_wave.tscn", scene(
    "c11scanwavedscn0",
    [("Script", S + "skills/scan_wave.gd", "1_s")],
    [("CircleShape2D", "c_wave", ["radius = 96.0"])],
    [
        ("ScanWave", "Area2D", None,
         ["collision_layer = 0", "collision_mask = 1",
          'script = ExtResource("1_s")'], ["scan_wave"]),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['shape = SubResource("c_wave")'], None),
    ]))

write("scenes/skills/unique_strike.tscn", scene(
    "c12strikedscn00",
    [("Script", S + "skills/unique_strike.gd", "1_s"),
     ("Texture2D", TXT + "ui/skill_strike.png", "2_tex")],
    [("RectangleShape2D", "r_strike", ["size = Vector2(80, 18)"])],
    [
        ("UniqueStrike", "Area2D", None,
         ["collision_layer = 8", "collision_mask = 4",
          'script = ExtResource("1_s")'], ["unique_strike"]),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(40, -10)', 'shape = SubResource("r_strike")'], None),
        ("Sprite2D", "Sprite2D", ".",
         ['texture = ExtResource("2_tex")', 'position = Vector2(40, -10)',
          'modulate = Color(0.7, 0.95, 1, 0.7)'], None),
    ]))

# --------------------------------------------------------------- spike
write("scenes/world/spike.tscn", scene(
    "c13spikedscn000",
    [("Script", S + "world/spike.gd", "1_s"),
     ("Texture2D", "res://assets/tilesets/l1.png", "2_tex")],
    [("RectangleShape2D", "r_spike", ["size = Vector2(16, 6)"])],
    [
        ("Spike", "Area2D", None,
         ["collision_layer = 128", "collision_mask = 2",
          'script = ExtResource("1_s")'], ["hazard"]),
        ("Sprite2D", "Sprite2D", ".",
         ['texture = ExtResource("2_tex")', 'region_enabled = true',
          'region_rect = Rect2(0, 0, 16, 16)'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(0, -3)', 'shape = SubResource("r_spike")'], None),
    ]))

# --------------------------------------------------------------- enemies
write("scenes/enemies/null_orb.tscn", scene(
    "c14nullorbdscn00",
    [("Script", S + "enemies/null_orb.gd", "1_s"),
     ("Texture2D", TXT + "ui/null_orb.png", "2_tex")],
    [("CircleShape2D", "c_orb", ["radius = 5.0"])],
    [
        ("NullOrb", "Area2D", None,
         ["collision_layer = 16", "collision_mask = 3",
          'script = ExtResource("1_s")'], ["boss_orb"]),
        ("Sprite2D", "Sprite2D", ".", ['texture = ExtResource("2_tex")'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['shape = SubResource("c_orb")'], None),
    ]))

write("scenes/enemies/composite_warden.tscn", scene(
    "c15wardendscn000",
    [("Script", S + "enemies/enemy_base.gd", "1_s"),
     ("SpriteFrames", "res://assets/sprites/enemies/composite_warden_frames.tres", "2_f")],
    [("RectangleShape2D", "r_body", ["size = Vector2(20, 26)"]),
     ("RectangleShape2D", "r_hurt", ["size = Vector2(26, 30)"]),
     ("RectangleShape2D", "r_hit", ["size = Vector2(26, 26)"]),
     ("StyleBoxFlat", "s_hp", ["bg_color = Color(1, 0.75, 0.2, 1)"])],
    [
        ("CompositeWarden", "CharacterBody2D", None,
         ["collision_layer = 4", "collision_mask = 1",
          'script = ExtResource("1_s")', 'kind = "composite_warden"',
          'behavior = "patrol"', "max_hp = 25", "is_guardian = true",
          "speed = 18.0", 'drop_key = "L2_KEY"'], ["enemy", "guardian", "warden"]),
        ("AnimatedSprite2D", "AnimatedSprite2D", ".",
         ['offset = Vector2(0, -16)', 'sprite_frames = ExtResource("2_f")',
          'animation = &"idle"', 'autoplay = "idle"'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(0, -13)', 'shape = SubResource("r_body")'], None),
        ("Hurtbox", "Area2D", ".",
         ["collision_layer = 8", "collision_mask = 8"], None),
        ("CollisionShape2D", "CollisionShape2D", "Hurtbox",
         ['position = Vector2(0, -15)', 'shape = SubResource("r_hurt")'], None),
        ("Hitbox", "Area2D", ".",
         ["collision_layer = 16", "collision_mask = 2"], None),
        ("CollisionShape2D", "CollisionShape2D", "Hitbox",
         ['position = Vector2(0, -14)', 'shape = SubResource("r_hit")'], None),
        ("WallRay", "RayCast2D", ".",
         ['position = Vector2(0, -10)', 'target_position = Vector2(22, 0)'], None),
        ("LedgeRay", "RayCast2D", ".",
         ['position = Vector2(0, -2)', 'target_position = Vector2(0, 20)'], None),
        ("HpBar", "ProgressBar", ".",
         ['offset_left = -24.0', 'offset_top = -46.0', 'offset_right = 24.0',
          'offset_bottom = -40.0', "max_value = 25.0", "value = 25.0",
          "show_percentage = false",
          'theme_override_styles/background = SubResource("s_hp")'], None),
    ]))

write("scenes/enemies/null_sovereign.tscn", scene(
    "c16sovereigndscn0",
    [("Script", S + "enemies/null_sovereign.gd", "1_s"),
     ("SpriteFrames", "res://assets/sprites/enemies/null_sovereign_frames.tres", "2_f"),
     ("Texture2D", TXT + "ui/null_orb.png", "3_shield")],
    [("RectangleShape2D", "r_body", ["size = Vector2(24, 34)"]),
     ("CircleShape2D", "c_hurt", ["radius = 22.0"]),
     ("StyleBoxFlat", "s_hp", ["bg_color = Color(0.8, 0.35, 1, 1)"])],
    [
        ("NullSovereign", "CharacterBody2D", None,
         ["collision_layer = 4", "collision_mask = 1",
          'script = ExtResource("1_s")'], ["enemy", "boss"]),
        ("AnimatedSprite2D", "AnimatedSprite2D", ".",
         ['offset = Vector2(0, -20)', 'sprite_frames = ExtResource("2_f")',
          'animation = &"idle"', 'autoplay = "idle"'], None),
        ("CollisionShape2D", "CollisionShape2D", ".",
         ['position = Vector2(0, -17)', 'shape = SubResource("r_body")'], None),
        ("Hurtbox", "Area2D", ".",
         ["collision_layer = 8", "collision_mask = 8"], None),
        ("CollisionShape2D", "CollisionShape2D", "Hurtbox",
         ['position = Vector2(0, -20)', 'shape = SubResource("c_hurt")'], None),
        ("ShieldFx", "Sprite2D", ".",
         ['texture = ExtResource("3_shield")', 'modulate = Color(0.6, 0.9, 1, 0.4)',
          'scale = Vector2(4, 4)', 'position = Vector2(0, -20)'], None),
        ("HpBar", "ProgressBar", ".",
         ['offset_left = -32.0', 'offset_top = -56.0', 'offset_right = 32.0',
          'offset_bottom = -50.0', "max_value = 40.0", "value = 40.0",
          "show_percentage = false",
          'theme_override_styles/background = SubResource("s_hp")'], None),
    ]))

# --------------------------------------------------------------- levels
LEVELS = [
    ("level1_record_ruins", "c20level1dscn000", "L1", "l1", "Record Ruins // teal"),
    ("level2_key_citadel", "c21level2dscn000", "L2", "l2", "Key Citadel // amber"),
    ("level3_foreign_spire", "c22level3dscn000", "L3", "l3", "Foreign Spire // magenta"),
]
for fname, uid, lid, tex, title in LEVELS:
    write("scenes/levels/%s.tscn" % fname, scene(
        uid,
        [("Script", S + "levels/level_base.gd", "1_s"),
         ("TileSet", "res://assets/tilesets/%s.tres" % tex, "2_tiles"),
         ("Texture2D", "res://assets/backgrounds/%s.png" % tex, "3_bg"),
         ("PackedScene", "res://scenes/player/player.tscn", "4_player"),
         ("PackedScene", "res://scenes/ui/hud.tscn", "5_hud"),
         ("PackedScene", "res://scenes/ui/pause_menu.tscn", "6_pause")],
        [],
        [
            ("Level", "Node2D", None,
             ['script = ExtResource("1_s")', 'level_id = "%s"' % lid], None),
            ("Background", "Sprite2D", ".",
             ['texture = ExtResource("3_bg")', 'centered = false',
              'z_index = -10', 'texture_filter = 1'], None),
            ("Solid", "TileMapLayer", ".",
             ['tile_set = ExtResource("2_tiles")'], None),
            ("Decor", "TileMapLayer", ".",
             ['tile_set = ExtResource("2_tiles")', "z_index = -1"], None),
            ("Rooms", "Node2D", ".", [], None),
            ("RoomProbe", "Marker2D", "Rooms", ["position = Vector2(8, 8)"], None),
            ("Entities", "Node2D", ".", [], None),
            ("EntityProbe", "Marker2D", "Entities", ["position = Vector2(8, 8)"], None),
            ("Player", None, ".",
             ['instance = ExtResource("4_player")'], None),
            ("HUD", None, ".",
             ['instance = ExtResource("5_hud")'], None),
            ("PauseMenu", None, ".",
             ['instance = ExtResource("6_pause")'], None),
            ("Info", "Label", ".",
             ['offset_left = 10.0', 'offset_top = 500.0', 'offset_right = 460.0',
              'offset_bottom = 530.0', 'theme_override_font_sizes/font_size = 8',
              'theme_override_colors/font_color = Color(0.5, 0.9, 0.85, 1)',
              'text = "%s"' % title], None),
        ]))

# --------------------------------------------------------------- UI: pause
write("scenes/ui/pause_menu.tscn", scene(
    "c30pausemenudscn0",
    [("Script", S + "ui/pause_menu.gd", "1_s")],
    [],
    [
        ("PauseMenu", "CanvasLayer", None,
         ['script = ExtResource("1_s")', "process_mode = 3", "layer = 20"], None),
        ("Panel", "ColorRect", ".",
         ["anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
          "color = Color(0.04, 0.05, 0.09, 0.85)"], None),
        ("Box", "VBoxContainer", "Panel",
         ["anchors_preset = 8", "anchor_left = 0.5", "anchor_top = 0.5",
          "anchor_right = 0.5", "anchor_bottom = 0.5",
          "offset_left = -90.0", "offset_top = -70.0",
          "offset_right = 90.0", "offset_bottom = 70.0",
          "theme_override_constants/separation = 12"], None),
        ("Title", "Label", "Panel/Box",
         ["theme_override_font_sizes/font_size = 12", 'text = "PAUSED"',
          "horizontal_alignment = 1"], None),
        ("Resume", "Button", "Panel/Box", ['text = "LANJUT (Esc)"'], None),
        ("Menu", "Button", "Panel/Box", ['text = "KEMBALI KE MENU"'], None),
    ]))

# --------------------------------------------------------------- UI: main menu
write("scenes/ui/main_menu.tscn", scene(
    "c31mainmenudscn00",
    [("Script", S + "ui/main_menu.gd", "1_s"),
     ("Theme", "res://assets/fonts/theme_pixel.tres", "2_theme")],
    [],
    [
        ("MainMenu", "Control", None,
         ['script = ExtResource("1_s")',
          "anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
          'theme = ExtResource("2_theme")'], None),
        ("Bg", "ColorRect", ".",
         ["anchor_right = 1.0", "anchor_bottom = 1.0",
          "color = Color(0.05, 0.07, 0.12, 1)"], None),
        ("Title", "Label", ".",
         ["anchor_left = 0.5", "anchor_right = 0.5", "offset_left = -420.0",
          "offset_top = 70.0", "offset_right = 420.0", "offset_bottom = 110.0",
          "theme_override_font_sizes/font_size = 20",
          'text = "RELATIONAL DATA CHRONICLES"', "horizontal_alignment = 1"], None),
        ("Sub", "Label", ".",
         ["anchor_left = 0.5", "anchor_right = 0.5", "offset_left = -420.0",
          "offset_top = 115.0", "offset_right = 420.0", "offset_bottom = 135.0",
          "theme_override_font_sizes/font_size = 10",
          'text = "THE LOST SCHEMA // Kelompok 9 // Basis Data"',
          "horizontal_alignment = 1"], None),
        ("Box", "VBoxContainer", ".",
         ["anchor_left = 0.5", "anchor_top = 0.5", "anchor_right = 0.5",
          "anchor_bottom = 0.5", "offset_left = -120.0", "offset_top = -90.0",
          "offset_right = 120.0", "offset_bottom = 130.0",
          "theme_override_constants/separation = 10"], None),
        ("Play", "Button", "Box", ['text = "MULAI BARU"'], None),
        ("Continue", "Button", "Box", ['text = "LANJUTKAN"'], None),
        ("LevelSelect", "Button", "Box", ['text = "PILIH LEVEL"'], None),
        ("About", "Button", "Box", ['text = "TENTANG"'], None),
        ("Quit", "Button", "Box", ['text = "KELUAR"'], None),
        ("Foot", "Label", ".",
         ["anchor_top = 1.0", "anchor_bottom = 1.0", "offset_left = 20.0",
          "offset_top = -34.0", "offset_right = 940.0", "offset_bottom = -10.0",
          "theme_override_font_sizes/font_size = 8",
          'text = "Aset: lihat About & ASSETS.md // Godot 4.7.2 MIT"',
          "horizontal_alignment = 1"], None),
    ]))

# --------------------------------------------------------------- UI: level select
write("scenes/ui/level_select.tscn", scene(
    "c32levelselectdscn",
    [("Script", S + "ui/level_select.gd", "1_s"),
     ("Theme", "res://assets/fonts/theme_pixel.tres", "2_theme")],
    [],
    [
        ("LevelSelect", "Control", None,
         ['script = ExtResource("1_s")',
          "anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
          'theme = ExtResource("2_theme")'], None),
        ("Bg", "ColorRect", ".",
         ["anchor_right = 1.0", "anchor_bottom = 1.0",
          "color = Color(0.05, 0.07, 0.12, 1)"], None),
        ("Title", "Label", ".",
         ["offset_left = 40.0", "offset_top = 30.0", "offset_right = 920.0",
          "offset_bottom = 60.0", "theme_override_font_sizes/font_size = 14",
          'text = "PILIH REGION"', "horizontal_alignment = 1"], None),
        ("Box", "VBoxContainer", ".",
         ["offset_left = 200.0", "offset_top = 120.0", "offset_right = 760.0",
          "offset_bottom = 380.0", "theme_override_constants/separation = 14"], None),
        ("L1", "Button", "Box", ['text = "L1 RECORD RUINS"'], None),
        ("L2", "Button", "Box", ['text = "L2 KEY CITADEL"'], None),
        ("L3", "Button", "Box", ['text = "L3 FOREIGN SPIRE"'], None),
        ("Market", "Button", "Box", ['text = "DATA MARKET"'], None),
        ("Back", "Button", "Box", ['text = "KEMBALI"'], None),
        ("Status", "Label", ".",
         ["offset_left = 40.0", "offset_top = 470.0", "offset_right = 920.0",
          "offset_bottom = 520.0", "theme_override_font_sizes/font_size = 8",
          'text = "Fragments 0 // Logic Lv 1 // Solved 0/9"',
          "horizontal_alignment = 1"], None),
    ]))

# --------------------------------------------------------------- UI: end session
write("scenes/ui/end_session.tscn", scene(
    "c33endsessiondscn",
    [("Script", S + "ui/end_session.gd", "1_s"),
     ("Theme", "res://assets/fonts/theme_pixel.tres", "2_theme")],
    [],
    [
        ("EndSession", "Control", None,
         ['script = ExtResource("1_s")',
          "anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
          'theme = ExtResource("2_theme")'], None),
        ("Bg", "ColorRect", ".",
         ["anchor_right = 1.0", "anchor_bottom = 1.0",
          "color = Color(0.04, 0.05, 0.09, 1)"], None),
        ("Title", "Label", ".",
         ["offset_left = 40.0", "offset_top = 90.0", "offset_right = 920.0",
          "offset_bottom = 140.0", "theme_override_font_sizes/font_size = 20",
          'text = "SESSION END"', "horizontal_alignment = 1"], None),
        ("Stats", "Label", ".",
         ["offset_left = 60.0", "offset_top = 170.0", "offset_right = 900.0",
          "offset_bottom = 340.0", "theme_override_font_sizes/font_size = 9",
          'text = "-"', "horizontal_alignment = 1", "autowrap_mode = 3"], None),
        ("Box", "HBoxContainer", ".",
         ["anchor_left = 0.5", "anchor_right = 0.5", "offset_left = -220.0",
          "offset_top = 380.0", "offset_right = 220.0", "offset_bottom = 420.0",
          "theme_override_constants/separation = 16"], None),
        ("Retry", "Button", "Box", ['text = "COBA LAGI"'], None),
        ("Menu", "Button", "Box", ['text = "MENU UTAMA"'], None),
    ]))

# --------------------------------------------------------------- UI: about
write("scenes/ui/about.tscn", scene(
    "c34aboutdscn0000",
    [("Script", S + "ui/about.gd", "1_s"),
     ("Theme", "res://assets/fonts/theme_pixel.tres", "2_theme")],
    [],
    [
        ("About", "Control", None,
         ['script = ExtResource("1_s")',
          "anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
          'theme = ExtResource("2_theme")'], None),
        ("Bg", "ColorRect", ".",
         ["anchor_right = 1.0", "anchor_bottom = 1.0",
          "color = Color(0.05, 0.07, 0.12, 1)"], None),
        ("Body", "Label", ".",
         ["offset_left = 50.0", "offset_top = 40.0", "offset_right = 910.0",
          "offset_bottom = 440.0", "theme_override_font_sizes/font_size = 8",
          'text = "-"', "autowrap_mode = 3"], None),
        ("Back", "Button", ".",
         ["anchor_left = 0.5", "anchor_right = 0.5", "offset_left = -90.0",
          "offset_top = 460.0", "offset_right = 90.0", "offset_bottom = 500.0",
          'text = "KEMBALI"'], None),
    ]))

# --------------------------------------------------------------- UI: market
write("scenes/ui/market_ui.tscn", scene(
    "c35marketuidscn0",
    [("Script", S + "ui/market_ui.gd", "1_s"),
     ("Theme", "res://assets/fonts/theme_pixel.tres", "2_theme")],
    [],
    [
        ("MarketUI", "CanvasLayer", None,
         ['script = ExtResource("1_s")', "process_mode = 3", "layer = 25"], None),
        ("Panel", "ColorRect", ".",
         ["anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
          "color = Color(0.03, 0.04, 0.07, 0.94)"], None),
        ("Title", "Label", "Panel",
         ["offset_left = 40.0", "offset_top = 24.0", "offset_right = 920.0",
          "offset_bottom = 50.0", "theme_override_font_sizes/font_size = 12",
          'text = "DATA MARKET // Broker Byte"',
          "horizontal_alignment = 1"], None),
        ("List", "VBoxContainer", "Panel",
         ["offset_left = 90.0", "offset_top = 62.0", "offset_right = 870.0",
          "offset_bottom = 430.0", "theme_override_constants/separation = 6"], None),
        ("Feedback", "Label", "Panel",
         ["offset_left = 90.0", "offset_top = 436.0", "offset_right = 870.0",
          "offset_bottom = 462.0", "theme_override_font_sizes/font_size = 8",
          'text = ""', "horizontal_alignment = 1"], None),
        ("Close", "Button", "Panel",
         ["offset_left = 400.0", "offset_top = 470.0", "offset_right = 560.0",
          "offset_bottom = 506.0", 'text = "TUTUP (Esc)"'], None),
    ]))

print("done")
