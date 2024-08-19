extends Node


signal signal_global_puzzle_change
signal signal_global_state_change


var bpm: int = 100:
	set(val):
		bpm = val
		beat_wait_time = 60.0 / val
var beat_wait_time: float = 60.0 / bpm
var timer := Timer.new()
var beat_idx = 1

var in_freeze := false

enum State {Exiting, InLevel, InBetween, Tutorial}
var state: State = State.InBetween:
	# make sure state is set at the last line!
	set(new_state):
		state = new_state
		if state == State.Exiting:
			pass
		elif state == State.InBetween:
			pass
		elif state == State.Tutorial:
			self.in_freeze = true
			pass
		else: # state == State.InLevel
			pass
		signal_global_state_change.emit()

# var player_level := 1001
var current_level_idx = 0   # 0~8
var current_puzzle_idx = 0  # 0~2
var level_goals = [
	["---h--------", "-------h----", "-----h-----h"],
	["---h------h-", "-h----h-----", "h---h----h--"],
	["---d--------", "d------d----", "h-----d-----"], # tutor dark panel
	["d-d---h-h---", "dh--dh--dh--", "dhdhdhdhdhdh"],
	["------------", "------------", "------------"],
	["------------", "------------", "------------"],
	["------------", "------------", "------------"],
	["------------", "------------", "------------"],
	["------------", "------------", "------------"],
]

var scenarios: Array[State] = [
	State.Tutorial,
	State.InBetween,
	State.Tutorial,
	State.Tutorial,
	State.Exiting,
	State.InBetween,
	State.Tutorial,
	State.InLevel, # level 1, ... and so on
	State.Exiting,
	State.Tutorial,
	State.InBetween,
	State.InLevel,
	State.Exiting,
	State.Tutorial,
	State.InBetween,
]
var scenario_idx := 0
var tutorial_idx := 0
var timer_started := false

var unlock_demon := false
var unlock_clock_hand2 := false
var unlock_panel_dark := false
var unlock_panel_earth := false

@onready var world: World = get_node("/root/World")
@onready var player: Player = get_node("/root/World/Rotator/Player")
@onready var clock: Clock = get_node("/root/World/Rotator/Clock")
@onready var staircase: Staircase = get_node("/root/World/Rotator/Staircase")
@onready var music = get_node("/root/World/Music")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timer)
	timer.wait_time = beat_wait_time
	timer.timeout.connect(_make_beat)
	music.signal_audio_beat.connect(_on_first_metronome_beat)
	player.signal_player_move.connect(_on_player_move)
	self.set_state_to_next_scenario()


func _on_first_metronome_beat():
	if not timer_started:
		timer.start()
		timer_started = true


func _on_player_move(_move_sign, _new_panel_id):
	if player.current_panel_idx == staircase.top_panel_idx:
		print("player on top panel")
		if self.state == State.Exiting or self.state == State.InBetween:
			self.set_state_to_next_scenario()


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


func set_state_to_next_scenario():
	if self.scenario_idx == len(self.scenarios):
		# TODO: trigger end game
		pass
	else:
		self.state = self.scenarios[self.scenario_idx]
		self.scenario_idx += 1


func increment_current_level_puzzle() -> void:
	self.current_puzzle_idx += 1
	if self.current_puzzle_idx == 3:
		self.current_level_idx += 1
		self.current_puzzle_idx = 0
		# puzzle complete, go to next state
		self.set_state_to_next_scenario()
	self.signal_global_puzzle_change.emit()


func _make_beat():
	# print("GLOBAL: beat ", beat_idx )
	beat_idx += 1
