extends Node2D

@onready var player: Node2D = $Player
@onready var clock = $Clock
@onready var label = $Label
@onready var staircase = $Staircase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("world instanced")
	player.player_mess_up.connect(_on_player_mess_up)
	player.player_move.connect(_on_player_move)
	player.player_play_card.connect(_on_player_play_card)
	Global.timer.timeout.connect(_on_beat)
	_update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_mess_up():
	clock.next_rotate_backward = true


func _on_player_move():
	pass


func _on_player_play_card(card_idx: int):
	staircase.build_panel(card_idx)
	_update_label()


func _on_beat():
	pass


func _update_label() -> void:
	label.text = '\n'.join([
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
