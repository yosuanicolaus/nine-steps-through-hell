extends Node2D

@export var action_time := 0.2

var last_beat_idx := -1
var success_streak := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("player instanced")
	print(Global.bpm)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press_space"):
		if Global.get_current_beat(action_time) != -1:
			try_move_player()
		print("space press ", Global.timer.time_left)
	elif Input.is_action_just_released("press_space"):
		print("space release ", Global.timer.time_left)


func try_move_player():
	print(Global.timer.time_left)
	self.rotation_degrees += 30
