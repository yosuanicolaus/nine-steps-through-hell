extends Node2D

@onready var rotator = $Rotator
@onready var player: Node2D = $Rotator/Player
@onready var clock = $Rotator/Clock
@onready var label = $Label
@onready var staircase = $Rotator/Staircase

var is_in_level := false
var player_level := 1001
var level_levels: Array[int] = [1002, 1037, 1073] # stage levels

@export var rotate_speed = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("world instanced")
	player.player_mess_up.connect(_on_player_mess_up)
	player.player_move.connect(_on_player_move)
	player.player_play_card.connect(_on_player_play_card)
	Global.timer.timeout.connect(_on_beat)
	_update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_in_level:
		rotator.rotation_degrees += rotate_speed * delta


func _on_player_mess_up():
	clock.next_rotate_backward = true


func _on_player_move(move_sign: int, _current_panel_id: int):
	if not self.is_in_level:
		player_level += move_sign

	if player_level in self.level_levels:
		# trigger level
		self.is_in_level = true
		staircase.trigger_in_level()

	_update_label()


func _on_player_play_card(card_key_id: int):
	if card_key_id <= 4:
		staircase.build_panel(card_key_id)
		_update_label()


func _on_beat():
	pass


func _update_label() -> void:
	label.text = '\n'.join([
		"Player info",
		"level: %s" % str(player_level),
		"Card info",
		"card 1: %s" % player.cards[0],
		"card 2: %s" % player.cards[1],
		"card 3: %s" % player.cards[2],
		"card 4: %s" % player.cards[3],
		"card 5: %s" % player.cards[4],
		"card q: %s" % player.cards[5],
		"card w: %s" % player.cards[6],
		"card e: %s" % player.cards[7],
	])
