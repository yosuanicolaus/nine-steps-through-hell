class_name World
extends Node2D

@onready var background: Sprite2D = $Background
@onready var rotator = $Rotator
@onready var player: Player = $Rotator/Player
@onready var demon: Demon = $Rotator/Demon
@onready var clock: Clock = $Rotator/Clock
@onready var staircase: Staircase = $Rotator/Staircase
@onready var label: Label = $Label
@onready var tutorial_sprite: Sprite2D = $Tutorial
@onready var tutorial_label: Label = $Tutorial/Label
@onready var title: Label = $Title

var background_idx := 0
const BG_ART = [
	preload('res://art/BG_1_Limbo.png'),
	preload('res://art/BG_2_Lust.png'),
	preload('res://art/BG_3_Gluttony.png'),
	preload('res://art/BG_4_Greed.png'),
	preload('res://art/BG_5_Anger.png'),
	preload('res://art/BG_5_Anger.png'),
	preload('res://art/BG_5_Anger.png'),
	preload('res://art/BG_5_Anger.png'),
	preload('res://art/BG_5_Anger.png'),
]
const TITLE_TEXTS = [
	"Circle I : Limbo",
	"Circle II : Lust",
	"Circle III : Gluttony",
	"Circle IV : Greed",
	"Circle V : Anger",
	"Circle VI : Heresy",
	"Circle VII : Limbo",
	"Circle VIII : Limbo",
	"Circle IX : Limbo",
]

var title_fade_speed := 0.7
var rotate_speed := 0.4
var last_trigger = -1

var background_start_scale := 1.3
var background_end_scale := 1.0
var background_scale_speed := 0.3
var background_fade_speed := 0.15

var tutorial_idx := 0
var tutorial_fade_speed := 1.2
var tutorial_texts: Array[String] = [
	"""Synchronize thy steps with the cursed clock. Use the left and right arrows, but only on the beat of the clock to move forward. Misstep, and thou shalt be frozen in place.""",
	"""At the heart of thy journey lies the demon’s clock. Hold spacebar to reverse its hand, altering time’s flow.""",
	"""When the clock’s hand points to a panel, press "1" to build a normal panel, or press "2" to erect a holy panel.""",
	"""The level now unfolds. The clock shall reveal a light indicator: no light demands a normal panel, while a yellow light calls for a holy panel. Ensure all panels match the light’s command to pass the level.""",
	"""Summon the darkness by pressing "3" to place a dark panel where the clock hand points. This cursed power can bring either fortune or doom.""",
	"""A demon now awakens, hunting thee down. Should it reach thee, all panels will turn dark. Yet, in this curse lies opportunity—use it if dark panels serve thy cause. Banish the demon by placing a holy panel where it stands, but know it will return, relentless, 'till the level ends.""",
	"""A second clock hand now appears, beyond thy control, moving with every second beat. All panels built henceforth shall appear where both hands point. Master this chaos, and thou mayest rise to power.""",
	"""Press "4" to summon earth panels where both clock hands point. These solid foundations shall aid thee in thy treacherous ascent.""",
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background.set_modulate(Color(1, 1, 1, 0))
	title.set_modulate(Color(1,1,1,0))

	player.signal_player_move.connect(_on_player_move)
	player.signal_player_play_card.connect(_on_player_play_card)
	Global.timer.timeout.connect(_on_global_beat)
	Global.signal_global_state_change.connect(_on_global_state_change)

	tutorial_sprite.modulate = Color(1, 1, 1, 0)
	_on_global_state_change()  # manual trigger because Global was spawned first
	_update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.state == Global.State.InLevel:
		rotator.rotation_degrees += rotate_speed * delta
		background.scale = lerp(
			background.scale,
			Vector2(background_end_scale, background_end_scale),
			background_scale_speed * delta,
		)
		background.set_modulate(lerp(background.get_modulate(), Color(1, 1, 1, 1), background_fade_speed * delta))
		background.rotation_degrees -= rotate_speed * delta
		title.set_modulate(lerp(title.get_modulate(), Color(1, 1, 1, 1), title_fade_speed * delta))
	else:
		# background.set_modulate(lerp(background.get_modulate(), Color(1, 1, 1, 0), background_fade_speed * delta))
		background.modulate = Color(1, 1, 1, 0)
		title.set_modulate(lerp(title.get_modulate(), Color(1, 1, 1, 0), title_fade_speed * delta))

	if Global.state == Global.State.Tutorial:
		tutorial_sprite.modulate = Color(1, 1, 1, 0.85)
	else:
		tutorial_sprite.modulate = Color(1, 1, 1, 0)

	if Input.is_action_just_pressed('press_enter'):
		unfreeze_world()


func _on_player_move(_move_sign: int, _current_panel_idx: int):
	_update_label()


func _on_player_play_card(_card_key_id: int):
	_update_label()


func unfreeze_world():
	if Global.in_freeze:
		Global.in_freeze = false
		Global.set_state_to_next_scenario() # exit tutorial


func _on_global_beat():
	_update_label()


func _on_global_state_change():
	print("ogsc")
	print(Global.state)
	if Global.state == Global.State.InLevel:
		title.text = TITLE_TEXTS[self.background_idx]
		background.texture = BG_ART[self.background_idx]
		background.scale = Vector2(background_start_scale, background_start_scale)
		background.set_modulate(Color(1, 1, 1, 0))
		self.background_idx += 1
	elif Global.state == Global.State.Tutorial:
		self.play_tutorial()


func play_tutorial():
	Global.in_freeze = true
	self.tutorial_label.text = self.tutorial_texts[self.tutorial_idx]
	var ti := self.tutorial_idx
	if ti == 4:
		Global.unlock_panel_dark = true
	elif ti == 5:
		Global.unlock_demon = true
	elif ti == 6:
		clock.clock2_hand.visible = true
		Global.unlock_clock_hand2 = true
	elif ti == 7:
		Global.unlock_panel_earth = true

	self.tutorial_idx += 1


func _update_label() -> void:
	label.text = '\n'.join([
		"STATE: %s" % str(Global.state),
		"Beat: %s" % str(Global.beat_idx),
		"current_level_idx: %s" % str(Global.current_level_idx),
		"current_puzzle_idx: %s" % str(Global.current_puzzle_idx),
		"In Freeze: %s" % str(Global.in_freeze),
		"clock1_panel_idx: %s" % str(clock.clock1_panel_idx),
		"clock2_panel_idx: %s" % str(clock.clock2_panel_idx),
		"player current panel idx: %s" % str(player.current_panel_idx),
		"player rotation deg: %s" % str(player.rotation_degrees),
		"demon current panel idx: %s" % str(demon.current_panel_idx),
		"demon rotation deg: %s" % str(demon.rotation_degrees),
		"stair top panel idx: %s" % str(staircase.top_panel_idx),
	])
