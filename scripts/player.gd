class_name Player
extends Node2D

signal player_move  # param: <int> current_panel_id
signal player_mess_up
signal player_play_card  # param: <int> card_idx (0 ~ 7)

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
	13,  # key_1 - Panel: Normal
	13,  # key_2 - Panel: Cracked
	11,  # key_3 - Panel: Holy
	10,  # key_4 - Panel: Dark
	10,  # key_5 - Panel: Gap

	# ability cards
	0,  # key_q - "skip second" - jump 2 panels ahead
	0,  # key_w - "panel cleanse" - convert currently stepped panel to a holy panel
	0,  # key_e - "halt" - freeze demon chaser for 3 beats
]

var current_panel_id := 1  # panel ID; int of range 1 ~ 12

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
		elif last_move_beat_idx != press_beat_idx:
			last_move_beat_idx = press_beat_idx
			move_player(1)
			success_streak += 1

	var card_key_ids := [ "card_1", "card_2", "card_3", "card_4", "card_5", "card_q", "card_w", "card_e"]
	for i in range(8):
		if Input.is_action_just_pressed(card_key_ids[i]) and self.cards[i] > 0:
			self.cards[i] -= 1
			player_play_card.emit(i)


func move_player(jump_length: int):
	print(press_beat_idx, " ",  release_beat_idx, " ", jump_length)
	self.rotation_degrees += 30 * jump_length
	height += jump_length
	current_panel_id += jump_length
	if current_panel_id > 12:
		current_panel_id -= 12

	# print("current_panel_id", current_panel_id)
	player_move.emit(current_panel_id)
	check_panel_event()


func check_panel_event():
	var current_panel_idx = current_panel_id - 1
	# var current_panel_status = staircase.panel_statuses[current_panel_idx]
	# print("current panel; idx: ", current_panel_idx, ", status: ", current_panel_status)
	# if current_panel_status == PanelStatus.Normal:
		# print("is panel normal")
