extends Node2D

@onready var background: Sprite2D = $Background
@onready var rotator = $Rotator
@onready var player: Player = $Rotator/Player
@onready var demon: Demon = $Rotator/Demon
@onready var clock: Clock = $Rotator/Clock
@onready var staircase: Staircase = $Rotator/Staircase
@onready var label: Label = $Label

var rotate_speed := 0.4
var last_trigger = -1

# var background_in_transition := false
var background_start_scale := 1.3
var background_end_scale := 1.0
var background_scale_speed := 0.6
var background_fade_speed := 0.15


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background.set_modulate(Color(1, 1, 1, 0))

	player.signal_player_move.connect(_on_player_move)
	player.signal_player_play_card.connect(_on_player_play_card)
	Global.timer.timeout.connect(_on_global_beat)
	Global.signal_global_state_change.connect(_on_global_state_change)
	_update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.state == Global.State.InLevel:
		rotator.rotation_degrees += rotate_speed * delta
		background.scale = lerp(
			Vector2(background_start_scale, background_start_scale),
			Vector2(background_end_scale, background_end_scale),
			background_scale_speed * delta,
		)
		background.set_modulate(lerp(background.get_modulate(), Color(1, 1, 1, 1), background_fade_speed * delta))
		background.rotation_degrees -= rotate_speed * delta


func _on_player_move(_move_sign: int, _current_panel_idx: int):
	_update_label()


func _on_player_play_card(_card_key_id: int):
	_update_label()


func _on_global_beat():
	_update_label()


func _on_global_state_change():
	if Global.state == Global.State.InLevel:
		background.scale = Vector2(background_start_scale, background_start_scale)
		background.set_modulate(Color(1, 1, 1, 0))


func _update_label() -> void:
	label.text = '\n'.join([
		"STATE: %s" % str(Global.state),
		"Beat: %s" % str(Global.beat_idx),
		"current_level_idx: %s" % str(Global.current_level_idx),
		"current_puzzle_idx: %s" % str(Global.current_puzzle_idx),
		"In Freeze: %s" % str(Global.in_freeze),
		"clock1_panel_idx: %s" % str(clock.clock1_panel_idx),
		"clock2_panel_idx: %s" % str(clock.clock2_panel_idx),
		"player current panel idx: %s" % str(player.current_panel_idx),
		"player rotation deg: %s" % str(player.rotation_degrees),
		"demon current panel idx: %s" % str(demon.current_panel_idx),
		"demon rotation deg: %s" % str(demon.rotation_degrees),
		"stair top panel idx: %s" % str(staircase.top_panel_idx),
	])
