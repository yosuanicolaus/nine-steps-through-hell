extends Node


signal signal_global_state_change


enum State {Exiting, InLevel, InBetween}
var bpm: int = 100:
	set(val):
		bpm = val
		beat_wait_time = 60.0 / val
var beat_wait_time: float = 60.0 / bpm
var timer := Timer.new()
var beat_idx = 1

var in_freeze := false

var state: State = State.InBetween:
	# make sure state is set at the last line!
	set(new_state):
		state = new_state
		if state == State.Exiting:
			current_level_idx += 1
			current_puzzle_idx = 0
		elif state == State.InBetween:
			pass
		else: # state == State.InLevel
			pass
		signal_global_state_change.emit()

# var player_level := 1001
var current_level_idx = 0   # 0~8
var current_puzzle_idx = 0  # 0~2
var level_goals = [  # demon starts at level 1, puzzle 2 (0_1)
	["---h--------", "--h----h----", "-----d------"],
	["---h--h----h", "---h--d-----", "---h--h--d--"],
	["---h---d----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
	["---h--h-----", "---h--h-----", "---h--h-----"],
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	# -1 (failed action beat)
	if timer.time_left <= action_time:
		return beat_idx
	elif beat_wait_time - timer.time_left <= action_time:
		return beat_idx - 1

	return -1


func get_current_level_goal() -> String:
	return self.level_goals[self.current_level_idx][self.current_puzzle_idx]


func increment_current_level_puzzle() -> void:
	self.current_puzzle_idx += 1
	if self.current_puzzle_idx == 3:
		self.current_level_idx += 1
		self.current_puzzle_idx = 0


func _make_beat():
	# print("GLOBAL: beat ", beat_idx )
	beat_idx += 1
