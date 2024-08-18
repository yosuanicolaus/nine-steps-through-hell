extends Node2D

@onready var rotator = $Rotator
@onready var player: Player = $Rotator/Player
@onready var clock: Clock = $Rotator/Clock
@onready var staircase: Staircase = $Rotator/Staircase
@onready var label: Label = $Label

var rotate_speed := 0.4
var last_trigger = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.signal_player_move.connect(_on_player_move)
	player.signal_player_play_card.connect(_on_player_play_card)
	Global.timer.timeout.connect(_on_global_beat)
	_update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.state == Global.State.InLevel:
		rotator.rotation_degrees += rotate_speed * delta


func _on_player_move(_move_sign: int, _current_panel_idx: int):
	_update_label()


func _on_player_play_card(_card_key_id: int):
	_update_label()


func _on_global_beat():
	_update_label()


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
		"stair top panel idx: %s" % str(staircase.top_panel_idx),
	])
