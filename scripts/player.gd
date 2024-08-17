class_name Player
extends Node2D

signal player_move  # param: <int> current_panel
signal player_mess_up

@export var action_time := 0.175

@onready var staircase = get_node("../Staircase")

var press_beat_idx := -1
var release_beat_idx := -1
var last_move_beat_idx := -1
var success_streak := 0
var height := 0
var double_jump := false

var cards: Array[int] = [
	# build cards
	3,  # key_1 - Panel: Normal
	3,  # key_2 - Panel: Cracked
	1,  # key_3 - Panel: Holy
	0,  # key_4 - Panel: Dark
	0,  # key_5 - Panel: Gap

	# ability cards
	0,  # key_q - "skip second" - jump 2 panels ahead
	0,  # key_w - "panel cleanse" - convert currently stepped panel to a holy panel
	0,  # key_e - "halt" - freeze demon chaser for 3 beats
]

var current_panel := 12  # panel ID; int of range 1 ~ 12

enum PanelStatus {Normal, Holy, Dark, Gap, Cracked, Empty} # mirror of staircase.gd


func _ready() -> void:
	print("player instanced")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press_space"):
		press_beat_idx = Global.get_current_beat(action_time)
		if press_beat_idx == -2:
			double_jump = true
		elif press_beat_idx == -1:
			# failed beat, will not move this turn
			double_jump = false
			player_mess_up.emit()
		else:
			move_player(1)

	# if Input.is_action_just_released("press_space"):
	# 	release_beat_idx = Global.get_current_beat(action_time)

	# 	if press_beat_idx != -1 and release_beat_idx != -1 and last_move_beat_idx != release_beat_idx:
	# 		last_move_beat_idx = release_beat_idx
	# 		var jump_length = clamp(release_beat_idx - press_beat_idx, 1, 3)
	# 		success_streak += 1
	# 		move_player(jump_length)

		# press_beat_idx = -1


func move_player(jump_length: int):
	print(press_beat_idx, " ",  release_beat_idx, " ", jump_length)
	self.rotation_degrees += 30 * jump_length
	height += jump_length
	current_panel += jump_length
	if current_panel > 12:
		current_panel -= 12

	# print("current_panel", current_panel)
	player_move.emit(current_panel)
	check_panel_event()


func check_panel_event():
	var current_panel_idx = current_panel - 1
	# var current_panel_status = staircase.panel_statuses[current_panel_idx]
	# print("current panel; idx: ", current_panel_idx, ", status: ", current_panel_status)
	# if current_panel_status == PanelStatus.Normal:
		# print("is panel normal")
