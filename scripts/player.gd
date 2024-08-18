class_name Player
extends Node2D

signal signal_player_move  # param: <int> move_sign, <int> current_panel_idx
signal signal_player_control
signal signal_player_play_card  # param: <int> card_idx (0 ~ 7)

var action_time := 0.145
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

var current_panel_idx := 0  # panel ID; int of range 1 ~ 12
var is_in_freeze := false

enum PanelStatus {Normal, Holy, Dark, Earth, Empty, Fade} # mirror of staircase.gd
@onready var staircase: Staircase = get_node("../Staircase")
@onready var animated_sprite = $AnimatedSprite2D


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finish)


func _on_animation_finish():
	animated_sprite.play('idle')


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right'):
		press_beat_idx = Global.get_current_beat(action_time)
		# TODO DEBUG MODE: RESTORE LATER
		if true:
		# if press_beat_idx != -1 and last_move_beat_idx != press_beat_idx:
		# 	last_move_beat_idx = press_beat_idx

			var move_sign = 1 if Input.is_action_just_pressed('ui_right') else -1
			move_player(move_sign)
			success_streak += 1

	if Input.is_action_pressed('press_space'):  # hold space to control the long clock hand
		signal_player_control.emit()

	var card_key_ids := [ "card_1", "card_2", "card_3", "card_4", "card_5", "card_q", "card_w", "card_e"]
	for i in range(8):
		if Input.is_action_pressed(card_key_ids[i]):
			signal_player_play_card.emit(i)


func move_player(move_sign: int) -> void:
	# sign can be 1 or -1. 1 means right, -1 means left
	assert(move_sign == 1 or move_sign == -1, "move_sign must be either 1 or -1")
	if Global.in_freeze:
		return

	var goal_panel_idx = current_panel_idx + 1 if move_sign == 1 else current_panel_idx - 1
	goal_panel_idx %= 12
	if staircase.panel_statuses[goal_panel_idx] == PanelStatus.Empty:
		print("can't move to empty panel")
		return  # can't move to empty panel

	self.rotation_degrees += 30 * move_sign
	self.current_panel_idx += move_sign
	self.current_panel_idx %= 12
	if self.current_panel_idx == -1:  # unknown bug: why does % not work?
		current_panel_idx = 11
	animated_sprite.flip_h = move_sign == -1
	animated_sprite.play("move")
	signal_player_move.emit(move_sign, current_panel_idx)
