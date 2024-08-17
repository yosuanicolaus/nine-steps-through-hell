extends Node2D

@onready var beat_timer: Timer = $BeatTimer
@onready var open_timer: Timer = $OpenTimer
@onready var close_timer: Timer = $CloseTimer
@onready var player: Node2D = $Player

@export var bpm := 100
@export var action_time := 0.2

var i = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var beat_wait_time := 60.0 / bpm
	open_timer.wait_time = beat_wait_time
	beat_timer.wait_time = beat_wait_time
	close_timer.wait_time = beat_wait_time

	open_timer.timeout.connect(_open_beat)
	beat_timer.timeout.connect(_make_beat)
	close_timer.timeout.connect(_close_beat)

	# starts in the 4th beat
	# var start_time = 4 * beat_wait_time
	# print(start_time)
	open_timer.start()
	beat_timer.start()
	close_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _open_beat():
	print("open beat")

func _close_beat():
	print("close beat")

func _make_beat():
	print("beat ", i)
	i += 1
	# player.move_player()
