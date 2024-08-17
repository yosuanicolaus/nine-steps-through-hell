extends Node


var bpm: int = 100:
	set(val):
		beat_wait_time = 60.0 / val
var beat_wait_time: float = 60.0 / bpm
var timer := Timer.new()
var beat_idx = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("global _ready")
	add_child(timer)
	timer.wait_time = beat_wait_time
	timer.timeout.connect(_make_beat)
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func get_current_beat(action_time: float) -> int:
	# returns either:
	# beat_idx if action_time is in beat
	# -2 if action_time is near the middle of the beat
	# -1 (failed action beat)
	if timer.time_left <= action_time:
		return beat_idx
	elif beat_wait_time - timer.time_left <= action_time:
		return beat_idx - 1
	return -1


func _make_beat():
	# print("GLOBAL: beat ", beat_idx )
	beat_idx += 1
