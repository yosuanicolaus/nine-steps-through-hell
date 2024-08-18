class_name Player
extends Node2D

# signal player_move  # param: <int> current_panel_id
signal player_mess_up
signal player_play_card  # param: <int> card_idx (0 ~ 7)

@export var action_time := 0.175

var press_beat_idx := -1
var release_beat_idx := -1
var last_move_beat_idx := -1
var success_streak := 0
var height := 0
var double_jump := false

var canon_rotation_degree = 0
var is_moving := false
var is_moving_begin := deg_to_rad(0)
var is_moving_end := deg_to_rad(0)
var is_moving_elapsed := 0.0
var is_moving_speed := 7
var is_moving_treshold := 0.06

var cards: Array[int] = [
	# build cards
	1113,  # key_1 - Panel: Normal
	1113,  # key_2 - Panel: Cracked
	1111,  # key_3 - Panel: Holy
	1110,  # key_4 - Panel: Dark
	1110,  # key_5 - Panel: Gap

	# ability cards
	110,  # key_q - "skip second" - jump 2 panels ahead
	110,  # key_w - "panel cleanse" - convert currently stepped panel to a holy panel
	110,  # key_e - "halt" - freeze demon chaser for 3 beats
]

var current_panel_id := 1  # panel ID; int of range 1 ~ 12

enum PanelStatus {Normal, Holy, Dark, Gap, Cracked, Empty} # mirror of staircase.gd


func _ready() -> void:
	print("player instanced")


func _process(delta: float) -> void:
	if self.is_moving:
		self.rotation = lerp_angle(self.is_moving_begin, self.is_moving_end, self.is_moving_elapsed)
		self.is_moving_elapsed += delta * self.is_moving_speed
		if abs(self.rotation - self.is_moving_end) <= self.is_moving_treshold:
			self.is_moving = false

	# elif because when moving, player shouldn't move somewhere else
	elif Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right'):
		press_beat_idx = Global.get_current_beat(action_time)
		if press_beat_idx == -2:
			double_jump = true
		elif press_beat_idx == -1:
			# failed beat, will not move this turn
			double_jump = false
			player_mess_up.emit()
		elif last_move_beat_idx != press_beat_idx:
			last_move_beat_idx = press_beat_idx
			var move_sign = 1 if Input.is_action_just_pressed('ui_right') else -1
			move_player(move_sign)
			success_streak += 1

	var card_key_ids := [ "card_1", "card_2", "card_3", "card_4", "card_5", "card_q", "card_w", "card_e"]
	for i in range(8):
		if Input.is_action_just_pressed(card_key_ids[i]) and self.cards[i] > 0:
			self.cards[i] -= 1
			player_play_card.emit(i)


func move_player(move_sign=1, going_up=false):
	# sign can be 1 or -1. 1 means right, -1 means left
	# print(press_beat_idx, " ",  release_beat_idx, " ", jump_length)
	# self.rotation_degrees += 30 * jump_length
	self.canon_rotation_degree += 30 * move_sign
	self.is_moving = true
	self.is_moving_begin = self.rotation
	self.is_moving_end = deg_to_rad(canon_rotation_degree)
	self.is_moving_elapsed = 0

	if going_up:
		self.height += 1

	# self.current_panel_id += move_sign
	# current_panel_id %= 12
	# print("current_panel_id", current_panel_id)
	# player_move.emit(current_panel_id)
	# check_panel_event()


func check_panel_event():
	var current_panel_idx = current_panel_id - 1
	# var current_panel_status = staircase.panel_statuses[current_panel_idx]
	# print("current panel; idx: ", current_panel_idx, ", status: ", current_panel_status)
	# if current_panel_status == PanelStatus.Normal:
		# print("is panel normal")
