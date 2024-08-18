class_name Player
extends Node2D

signal player_move  # param: <int> move_sign, <int> current_panel_id
signal player_half_beat
signal player_play_card  # param: <int> card_idx (0 ~ 7)

@export var action_time := 0.175

var press_beat_idx := -1
var release_beat_idx := -1
var last_move_beat_idx := -1
var success_streak := 0
var height := 0

# build cards
# key_1 - Panel: Normal
# key_2 - Panel: Cracked
# key_3 - Panel: Holy
# key_4 - Panel: Dark
# key_5 - Panel: Gap

# ability cards
# key_q - "skip second" - jump 2 panels ahead
# key_w - "panel cleanse" - convert currently stepped panel to a holy panel
# key_e - "halt" - freeze demon chaser for 3 beats

var current_panel_id := 1  # panel ID; int of range 1 ~ 12
var is_in_freeze := false

enum PanelStatus {Normal, Holy, Dark, Gap, Cracked, Empty, Fade} # mirror of staircase.gd


func _ready() -> void:
	print("player instanced")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right'):
		press_beat_idx = Global.get_current_beat(action_time)
		if press_beat_idx == -1:
			# failed beat, will not move this turn
			player_half_beat.emit()
		elif last_move_beat_idx != press_beat_idx:
			last_move_beat_idx = press_beat_idx
			var move_sign = 1 if Input.is_action_just_pressed('ui_right') else -1
			move_player(move_sign)
			success_streak += 1

	var card_key_ids := [ "card_1", "card_2", "card_3", "card_4", "card_5", "card_q", "card_w", "card_e"]
	for i in range(8):
		if Input.is_action_just_pressed(card_key_ids[i]):
			player_play_card.emit(i)


func move_player(move_sign: int) -> void:
	# sign can be 1 or -1. 1 means right, -1 means left
	assert(move_sign == 1 or move_sign == -1, "move_sign must be either 1 or -1")
	if Global.in_freeze:
		return

	self.rotation_degrees += 30 * move_sign
	self.current_panel_id += move_sign
	current_panel_id %= 12
	player_move.emit(move_sign, current_panel_id)


# func check_panel_event():
	# var current_panel_idx = current_panel_id - 1
	# var current_panel_status = staircase.panel_statuses[current_panel_idx]
	# print("current panel; idx: ", current_panel_idx, ", status: ", current_panel_status)
	# if current_panel_status == PanelStatus.Normal:
		# print("is panel normal")
