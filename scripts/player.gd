extends Node2D

@export var action_time := 0.2

var press_beat_idx := -1
var release_beat_idx := -1
var success_streak := 0


func _ready() -> void:
	print("player instanced")
	print(Global.bpm)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press_space"):
		press_beat_idx = Global.get_current_beat(action_time)

	elif Input.is_action_just_released("press_space"):
		release_beat_idx = Global.get_current_beat(action_time)

		if press_beat_idx != -1 and release_beat_idx != -1:
			var jump_length = clamp(release_beat_idx - press_beat_idx, 1, 3)
			try_move_player(jump_length)
		press_beat_idx = -1


func try_move_player(jump_length: int):
	print(press_beat_idx, " ",  release_beat_idx, " ", jump_length)
	self.rotation_degrees += 30 * jump_length
