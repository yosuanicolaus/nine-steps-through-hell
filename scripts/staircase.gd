class_name Staircase
extends Node2D


# modulate values for Color(r, g, b) from darkest to lightest
var dark_to_light_values: Array[float] = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.88, 0.94, 0.97, 1.0, 1.0, 1.0]

@onready var panel_sprites: Array[Sprite2D] = [ # player start at Panel1
	$Panel1/Sprite, $Panel2/Sprite, $Panel3/Sprite, $Panel4/Sprite, $Panel5/Sprite, $Panel6/Sprite,
	$Panel7/Sprite, $Panel8/Sprite, $Panel9/Sprite, $Panel10/Sprite, $Panel11/Sprite, $Panel12/Sprite,
]
@onready var player: Player = get_node("../Player")
@onready var demon: Demon = get_node("../Demon")
@onready var clock: Clock = get_node("../Clock")

enum PanelStatus {Normal, Holy, Dark, Earth, Empty, Fade}

@onready var panel_sprite_map := {
	PanelStatus.Normal: preload('res://art/staircase_tile_normal.png'),
	PanelStatus.Holy: preload('res://art/staircase_tile_holy.png'),
	PanelStatus.Dark: preload('res://art/staircase_tile_dark.png'),
	PanelStatus.Earth: preload('res://art/staircase_tile_earth.png'),
	PanelStatus.Empty: preload('res://art/staircase_tile_empty.png'),
	PanelStatus.Fade: preload('res://art/staircase_tile_fade.png'),
}

var panel_statuses: Array[PanelStatus] = [
	PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade,
	PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade,
	PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Normal, PanelStatus.Empty,
]

var top_panel_idx := 10 # top panel ID->IDX <int>0~11
var in_between_idx = 0
var default_energy = 0.57


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.signal_global_state_change.connect(_on_global_state_change)
	player.signal_player_move.connect(_on_player_move)
	player.signal_player_play_card.connect(_on_player_play_card)
	for i in 12:
		self.update_panel(i, panel_statuses[i])


func _on_global_state_change() -> void:
	if Global.state == Global.State.Exiting:
		self._update_panel_status_all_fade_except_opposite()
	elif Global.state == Global.State.InBetween:
		for i in 12:
			self.update_panel(i, PanelStatus.Normal)  # clear empty panels

		var empty_panel_idx = player.current_panel_idx + 11
		empty_panel_idx %= 12
		self.top_panel_idx = player.current_panel_idx - 2
		if self.top_panel_idx < 0:
			self.top_panel_idx += 12
		self.update_panel(top_panel_idx, PanelStatus.Normal, 3)

		self.update_panel(empty_panel_idx, PanelStatus.Empty)
	elif Global.state == Global.State.Tutorial:
		pass
	else: # InLevel
		for i in 12:
			self.update_panel(i, PanelStatus.Normal)


func _on_player_move(_move_sign: int, _current_panel_idx: int):
	pass


func _on_player_play_card(card_key_idx: int):
	if Global.state == Global.State.InLevel:
		# build panel cards (key 1~4)
		self.build_panel_from_clock_hand(card_key_idx)
		if self.is_puzzle_complete(Global.get_current_level_goal()):
			Global.increment_current_level_puzzle()


func _get_panel_status_from_card_idx(card_idx: int) -> PanelStatus:
	assert(card_idx >= 0 and card_idx <= 3, "card_idx must be between 0 - 3!")
	return {
		0: PanelStatus.Normal,
		1: PanelStatus.Holy,
		2: PanelStatus.Dark,
		3: PanelStatus.Earth,
	}[card_idx]


func update_panel(panel_idx: int, panel_status: PanelStatus, energy=self.default_energy) -> void:
	self.panel_statuses[panel_idx] = panel_status
	self.panel_sprites[panel_idx].texture = self.panel_sprite_map[panel_status]
	self.panel_sprites[panel_idx].get_child(0).energy = energy
	# if panel_status == PanelStatus.Fade:
	 	# panel_sprites[panel_idx].get_child(0).energy = 0.5
	# else:
		# panel_sprites[panel_idx].get_child(0).energy = 1


func is_puzzle_complete(level_goal: String) -> bool:
	# DEBUG MODE
	# return true
	for i in 12:
		var goal_status = {
			"-": PanelStatus.Normal,
			"h": PanelStatus.Holy,
			"d": PanelStatus.Dark,
			"e": PanelStatus.Earth,
		}[level_goal[i]]
		# print("%s %s %s" % [i, goal_status, panel_statuses[i]])
		if goal_status != panel_statuses[i]:
			return false
	return true # level complete if InLevel, and all panel status is same as goal status


func build_panel_from_clock_hand(card_idx: int) -> void:
	panel_statuses[clock.clock1_panel_idx] = _get_panel_status_from_card_idx(card_idx)
	if Global.unlock_clock_hand2:
		panel_statuses[clock.clock2_panel_idx] = _get_panel_status_from_card_idx(card_idx)

	# if build holy panel on demon
	if card_idx == 1 and Global.unlock_demon and (
		demon.current_panel_idx == clock.clock1_panel_idx or
		(Global.unlock_clock_hand2 and clock.clock2_panel_idx == demon.current_panel_idx)):
		demon.demon_active = false
		demon.respawn_timer.start()

	_update_panel_textures()


func debug_build(card_idx: int):
	# FOR DEBUG
	panel_statuses[self.player.current_panel_idx] = _get_panel_status_from_card_idx(card_idx)
	_update_panel_textures()


func _get_opposite_panel_idx() -> int:
	var opposite_panel_idx = self.player.current_panel_idx + 6
	opposite_panel_idx %= 12
	return opposite_panel_idx


func _update_panel_status_all_fade_except_opposite() -> void:
	for i in 12:
		self.update_panel(i, PanelStatus.Fade)

	# make the opposite of player's current panel the exit of "Exiting" floor
	var opposite_panel_idx = self._get_opposite_panel_idx()
	self.update_panel(opposite_panel_idx, PanelStatus.Normal)
	# panel_statuses[opposite_panel_idx] = PanelStatus.Normal
	# panel_sprites[opposite_panel_idx].get_child(0).energy = 3
	self.top_panel_idx = opposite_panel_idx
	_update_panel_textures()


func trigger_global_freeze() -> void:
	Global.in_freeze = true
	for i in 12:
		panel_sprites[i].modulate = Color(10, 10, 10, 1)
	await get_tree().create_timer(1.0).timeout
	for i in 12:
		panel_sprites[i].modulate = Color(1, 1, 1, 1)
	Global.in_freeze = false


func _update_panel_lights_dark_to_light() -> void:
	pass
	# var to_fill_idx = top_panel_idx + 1
	# to_fill_idx %= 12

	# for dark_idx in 12:
	# 	var mod_val := dark_to_light_values[dark_idx]
	# 	# panel_sprites[to_fill_idx].get_child(0).energy = mod_val
	# 	panel_sprites[to_fill_idx].modulate = Color(mod_val, mod_val, mod_val, 1)
	# 	# panel_sprites[to_fill_idx].apply_scale
	# 	to_fill_idx += 1
	# 	if to_fill_idx == 12:
	# 		to_fill_idx = 0


func _update_panel_textures() -> void:
	for i in 12:
		panel_sprites[i].texture = panel_sprite_map[panel_statuses[i]]
