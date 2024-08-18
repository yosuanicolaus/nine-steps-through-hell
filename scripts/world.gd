extends Node2D

@onready var rotator = $Rotator
@onready var player: Player = $Rotator/Player
@onready var clock: Clock = $Rotator/Clock
@onready var staircase: Staircase = $Rotator/Staircase
@onready var label: Label = $Label

@export var rotate_speed = 0.4
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


func _on_player_move(_move_sign: int, _current_panel_id: int):
	# if Global.state == Global.State.InBetween and player.current_panel_id == staircase.exit_panel_id:
	# 	staircase.trigger_next_in_between_level()

	# if player_level in self.level_levels and self.last_trigger != player_level:
	# 	# make sure only triggers once by setting & checking last_trigger
	# 	staircase.trigger_enter_level()
	# 	clock.modify_clock_lights_from_goal(level_goals[current_level_idx][current_puzzle_idx])
	# 	self.last_trigger = player_level

	_update_label()


func _on_player_play_card(card_key_id: int):
	if Global.state != Global.State.InLevel:
		return  # player can only play card in level

	if card_key_id <= 4:
		# build panel cards (key 1~5)
		staircase.build_panel_from_clock_hand(card_key_id)

		# if staircase.is_puzzle_complete(level_goals[current_level_idx][current_puzzle_idx]):
		# 	self.current_puzzle_idx += 1
		# 	if current_puzzle_idx < 3:
		# 		clock.modify_clock_lights_from_goal(level_goals[current_level_idx][current_puzzle_idx])
		# 	else:  # puzzle complete; Exiting level
		# 		current_puzzle_idx = 0
		# 		current_level_idx += 1
		# 		clock.modify_clock_lights_from_goal("------------")  # clear clock lights
		# 		staircase.trigger_exiting_level(player.current_panel_id)
	_update_label()


func _on_global_beat():
	_update_label()


func _update_label() -> void:
	label.text = '\n'.join([
		"STATE: %s" % str(Global.state),
		"Beat: %s" % str(Global.beat_idx),
		"In Freeze: %s" % str(Global.in_freeze),
		"clock1_panel_id: %s" % str(clock.clock1_panel_id),
		"clock2_panel_id: %s" % str(clock.clock2_panel_id),
	])
