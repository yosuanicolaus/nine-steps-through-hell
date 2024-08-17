extends Node2D

@onready var player: Node2D = $Player
@onready var clock = $Clock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("world instanced")
	player.player_mess_up.connect(_clock_rotate_backward)
	# player.player_move.connect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _clock_rotate_backward():
	clock.next_rotate_backward = true
