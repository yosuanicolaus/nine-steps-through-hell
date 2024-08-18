extends Node2D

@onready var rotator = $Rotator
@onready var player: Player = $Rotator/Player
@onready var clock: Clock = $Rotator/Clock
@onready var staircase: Staircase = $Rotator/Staircase
@onready var label: Label = $Label

enum StaircaseState {Exiting, InLevel, InBetween}  # copy from Staircase
var is_in_level := false
var player_level := 1001
var level_levels: Array[int] = [1002, 1037, 1073] # stage levels

@export var rotate_speed = 0.4
var last_trigger = -1

var current_level_idx = 0
var current_puzzle_idx = 0  # 0~2
var level_goals = [
	["---h--h-----", "--h---------", "---h-hhh----"],
	["---h--h----h", "---h--h-----", "---h--h-----"],
	["---h---d----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("world instanced")
	player.player_half_beat.connect(_on_player_half_beat)
	player.player_move.connect(_on_player_move)
	player.player_play_card.connect(_on_player_play_card)
	Global.timer.timeout.connect(_on_global_beat)
	_update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if staircase.state == StaircaseState.InLevel:
		rotator.rotation_degrees += rotate_speed * delta


func _on_player_half_beat():
	clock.next_rotate_backward = true


func _on_player_move(move_sign: int, _current_panel_id: int):
	if staircase.state == StaircaseState.InBetween:
		player_level += move_sign

	if player_level in self.level_levels and self.last_trigger != player_level:
		# make sure only triggers once by setting & checking last_trigger
		staircase.trigger_enter_level()
		clock.modify_clock_lights_from_goal(level_goals[current_level_idx][current_puzzle_idx])
		self.last_trigger = player_level

	_update_label()


func _on_player_play_card(card_key_id: int):
	if staircase.state != StaircaseState.InLevel:
		return  # player can only play card in level

	if card_key_id <= 4:
		# build panel cards (key 1~5)
		# staircase.build_panel(card_key_id)
		staircase.build_panel_on_clock_hand(clock, card_key_id)

		if staircase.is_puzzle_complete(level_goals[current_level_idx][current_puzzle_idx]):
			self.current_puzzle_idx += 1
			if current_puzzle_idx < 3:
				clock.modify_clock_lights_from_goal(level_goals[current_level_idx][current_puzzle_idx])
			else:  # puzzle complete; Exiting level
				current_puzzle_idx = 0
				current_level_idx += 1
				clock.modify_clock_lights_from_goal("------------")  # clear clock lights
				staircase.trigger_exiting_level(player.current_panel_id)
	else:
		# ability cards ... (?)
		pass

	_update_label()


func _on_global_beat():
	pass


func _update_label() -> void:
	label.text = '\n'.join([
		"STATE: %s" % str(staircase.state),
		"player_level: %s" % str(player_level),
		"clock1_panel_id: %s" % str(clock.clock1_panel_id),
		"clock2_panel_id: %s" % str(clock.clock2_panel_id),
	])
