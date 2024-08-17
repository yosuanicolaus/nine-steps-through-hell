class_name Player
extends Node2D

signal player_move  # param: <int> current_panel

@export var action_time := 0.175

var press_beat_idx := -1
var release_beat_idx := -1
var last_move_beat_idx := -1
var success_streak := 0
var height := 0

var cards: Array[int] = [
	0,  # "skip second" - jump 2 panels ahead
	0,  # "panel cleanse" - convert currently stepped panel to a holy panel
	0,  # "halt" - freeze demon chaser for 3 beats
]

var current_panel := 12  # panel ID; int of range 1 ~ 12
enum PanelStatus {Normal, Holy, Dark, Gap, Cracked} # mirror of staircase.gd

# @onready var staircase: Staircase = get_node("../Staircase")


func _ready() -> void:
	print("player instanced")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press_space"):
		press_beat_idx = Global.get_current_beat(action_time)

	elif Input.is_action_just_released("press_space"):
		release_beat_idx = Global.get_current_beat(action_time)

		if press_beat_idx != -1 and release_beat_idx != -1 and last_move_beat_idx != release_beat_idx:
			last_move_beat_idx = release_beat_idx
			var jump_length = clamp(release_beat_idx - press_beat_idx, 1, 3)
			success_streak += 1
			move_player(jump_length)

		press_beat_idx = -1


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
