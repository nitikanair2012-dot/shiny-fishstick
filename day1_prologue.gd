extends Node2D

# Day 1 prologue script for a retro 2D narrative game.
# Attach this script to the root node of the Day 1 scene.

# Basic game state variables
var current_day: int = 1
var player_can_move: bool = false

# Dialogue state
var _dialogue_index: int = 0
var _dialogue_lines: Array = []

# Placeholder textures / scenes for pixel sprites.
# Replace these paths with your actual sprite resources.
const NENE_SPRITE: Texture = preload("res://assets/sprites/nene_pixel.png")
const AOI_SPRITE: Texture = preload("res://assets/sprites/aoi_pixel.png")
const PLAYER_SPRITE: Texture = preload("res://assets/sprites/nene_player.png")

# Node references
onready var day_card: CanvasItem = $DayCard
onready var classroom_background: CanvasItem = $ClassroomBackground
onready var character_container: Node2D = $Characters
onready var player_node: Node2D = $Player
onready var dialogue_panel: CanvasItem = $UI/DialoguePanel
onready var dialogue_label: Label = $UI/DialoguePanel/DialogueLabel
onready var speaker_label: Label = $UI/DialoguePanel/SpeakerLabel

func _ready() -> void:
    # Initialize the scene state for the prologue.
    current_day = 1
    player_can_move = false
    _dialogue_index = 0
    dialogue_panel.visible = false
    classroom_background.modulate.a = 0.0
    day_card.visible = true
    day_card.modulate = Color(0, 0, 0, 1)

    _configure_dialogue()
    _spawn_scene_characters()
    _start_day_card_sequence()

func _configure_dialogue() -> void:
    # Dialogue for the morning classroom cutscene.
    _dialogue_lines = [
        {"speaker": "Aoi", "text": "Nene, did you hear? They say Hanako-san of the Toilet grants wishes in the 3rd-floor girls' bathroom."},
        {"speaker": "Nene", "text": "The rumor is so creepy... but also... if it is true, I should try it."},
        {"speaker": "Aoi", "text": "Be careful. The school spirits are not like ordinary ghosts."},
        {"speaker": "Nene", "text": "I won't back down. I'm going to head there after class."}
    ]

func _spawn_scene_characters() -> void:
    # Spawn Nene and Aoi as small pixel sprites in the classroom scene.
    character_container.clear()

    var nene_sprite = Sprite2D.new()
    nene_sprite.texture = NENE_SPRITE
    nene_sprite.position = Vector2(220, 320)
    nene_sprite.scale = Vector2(0.75, 0.75)
    nene_sprite.name = "Nene"
    character_container.add_child(nene_sprite)

    var aoi_sprite = Sprite2D.new()
    aoi_sprite.texture = AOI_SPRITE
    aoi_sprite.position = Vector2(360, 320)
    aoi_sprite.scale = Vector2(0.75, 0.75)
    aoi_sprite.name = "Aoi"
    character_container.add_child(aoi_sprite)

    # The player node uses Nene's player-facing sprite, locked initially.
    if player_node.has_node("Sprite2D"):
        player_node.get_node("Sprite2D").texture = PLAYER_SPRITE
    player_node.position = Vector2(180, 400)
    player_node.visible = true

func _start_day_card_sequence() -> void:
    # Show the day card for 3 seconds, then fade it out and fade in the classroom.
    day_card.visible = true
    player_can_move = false
    yield(get_tree().create_timer(3.0), "timeout")
    yield(_fade_canvas_item(day_card, 1.0, 0.0, 0.5), "finished")
    day_card.visible = false
    yield(_fade_canvas_item(classroom_background, 0.0, 1.0, 0.8), "finished")
    _start_morning_dialogue()

func _fade_canvas_item(item: CanvasItem, from_alpha: float, to_alpha: float, duration: float) -> Tween:
    var tween = create_tween()
    item.modulate.a = from_alpha
    tween.tween_property(item, "modulate:a", to_alpha, duration)
    return tween

func _start_morning_dialogue() -> void:
    dialogue_panel.visible = true
    _show_next_dialogue_line()

func _show_next_dialogue_line() -> void:
    if _dialogue_index >= _dialogue_lines.size():
        _end_dialogue_sequence()
        return

    var line = _dialogue_lines[_dialogue_index]
    speaker_label.text = line.get("speaker", "")
    dialogue_label.text = line.get("text", "")
    _dialogue_index += 1

func _end_dialogue_sequence() -> void:
    dialogue_panel.visible = false
    player_can_move = true
    # Player can now control Nene and walk to the hallway / bathroom.

func _input(event: InputEvent) -> void:
    if not player_can_move:
        return

    if event is InputEventKey and event.pressed:
        var move_vector = Vector2.ZERO
        if Input.is_action_pressed("ui_right"):
            move_vector.x += 1
        if Input.is_action_pressed("ui_left"):
            move_vector.x -= 1
        if Input.is_action_pressed("ui_down"):
            move_vector.y += 1
        if Input.is_action_pressed("ui_up"):
            move_vector.y -= 1

        if move_vector != Vector2.ZERO:
            move_vector = move_vector.normalized() * 120 * get_process_delta_time()
            player_node.position += move_vector

func _unhandled_input(event: InputEvent) -> void:
    if dialogue_panel.visible and event is InputEventKey and event.pressed and event.scancode == Key.ENTER:
        _show_next_dialogue_line()
