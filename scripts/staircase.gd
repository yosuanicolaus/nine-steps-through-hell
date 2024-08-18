class_name Staircase
extends Node2D


# modulate values for Color(r, g, b) from darkest to lightest
var dark_to_light_values: Array[float] = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.88, 0.94, 0.97, 1.0, 1.0, 1.0]

@onready var panel_sprites: Array[Sprite2D] = [ # player start at Panel1
	$Panel1/Sprite, $Panel2/Sprite, $Panel3/Sprite, $Panel4/Sprite, $Panel5/Sprite, $Panel6/Sprite,
	$Panel7/Sprite, $Panel8/Sprite, $Panel9/Sprite, $Panel10/Sprite, $Panel11/Sprite, $Panel12/Sprite,
]
@onready var player: Player = get_node("../Player")
@onready var clock: Clock = get_node("../Clock")

enum PanelStatus {Normal, Holy, Dark, Gap, Cracked, Empty, Fade}

@onready var panel_sprite_map := {
	PanelStatus.Normal: preload('res://art/staircase_tile_normal.png'),
	PanelStatus.Holy: preload('res://art/staircase_tile_holy.png'),
	PanelStatus.Dark: preload('res://art/staircase_tile_dark.png'),
	PanelStatus.Gap: preload('res://art/staircase_tile_gap.png'),
	PanelStatus.Cracked: preload('res://art/staircase_tile_cracked.png'),
	PanelStatus.Empty: preload('res://art/staircase_tile_empty.png'),
	PanelStatus.Fade: preload('res://art/staircase_tile_fade.png'),
}

@onready var panel_sprite_top_map := {
	PanelStatus.Normal: preload('res://art/staircase_tile_normal_top.png'),
	PanelStatus.Holy: preload('res://art/staircase_tile_holy_top.png'),
	PanelStatus.Dark: preload('res://art/staircase_tile_dark_top.png'),
	PanelStatus.Gap: preload('res://art/staircase_tile_gap_top.png'),
	PanelStatus.Cracked: preload('res://art/staircase_tile_cracked_top.png'),
	PanelStatus.Empty: preload('res://art/staircase_tile_empty.png'),
	PanelStatus.Fade: preload('res://art/staircase_tile_fade.png'),
}

var panel_statuses: Array[PanelStatus] = [
	PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade,
	PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Fade,
	PanelStatus.Fade, PanelStatus.Fade, PanelStatus.Normal, PanelStatus.Empty,
]

var top_panel_id := 11 # top panel ID (not idx!) <int>1~12
var in_between_idx = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.signal_global_state_change.connect(_on_global_state_change)
	player.signal_player_move.connect(_on_player_move)
	player.signal_player_play_card.connect(_on_player_play_card)
	_update_panel_textures()
	_update_panel_lights_dark_to_light()


func _on_global_state_change() -> void:
	if Global.state == Global.State.Exiting:
		pass
	elif Global.state == Global.State.InBetween:
		var empty_panel_idx = self.top_panel_id - 1 + 11
		empty_panel_idx %= 12
		self.top_panel_id -= 2
		if self.top_panel_id < 1:
			self.top_panel_id += 12
		self.top_panel_id = self.top_panel_id

		self.panel_statuses[empty_panel_idx] = PanelStatus.Empty
		self._update_panel_textures()
		self._update_panel_lights_dark_to_light()
	else: # InLevel
		for i in 12:
			panel_sprites[i].get_child(0).energy = 1
			panel_sprites[i].modulate = Color(1, 1, 1, 1)
			panel_statuses[i] = PanelStatus.Normal
		_update_panel_textures()


func _on_player_move(_move_sign: int, _current_panel_id: int):
	if player.current_panel_id == self.top_panel_id:
		if Global.state == Global.State.Exiting:
			Global.state = Global.State.InBetween
		elif Global.state == Global.State.InBetween:
			Global.state = Global.State.InLevel


func _on_player_play_card(card_key_id: int):
	if Global.state == Global.State.InLevel and card_key_id <= 4:
		# build panel cards (key 1~5)
		self.build_panel_from_clock_hand(card_key_id)

		print(Global.get_current_level_goal())
		print(self.is_puzzle_complete(Global.get_current_level_goal()))
		if self.is_puzzle_complete(Global.get_current_level_goal()):
			# Global.increment_current_level_puzzle()
			Global.current_puzzle_idx += 1
			if Global.current_puzzle_idx < 3:
				# load next level
				clock.modify_clock_lights_from_goal(Global.get_current_level_goal())
			else:
				# puzzle complete; enter exiting state
				clock.modify_clock_lights_from_goal("------------") # clear clock lights
				self._update_panel_status_all_fade_except_opposite()
				Global.state = Global.State.Exiting


func _get_panel_status_from_card_idx(card_idx: int) -> PanelStatus:
	assert(card_idx >= 0 and card_idx <= 4, "card_idx must be between 0 - 4!")
	return {
		0: PanelStatus.Normal,
		1: PanelStatus.Holy,
		2: PanelStatus.Dark,
		3: PanelStatus.Gap,
		4: PanelStatus.Cracked,
	}[card_idx]


func is_puzzle_complete(level_goal: String) -> bool:
	for i in 12:
		var goal_status = {
			"-": PanelStatus.Normal,
			"h": PanelStatus.Holy,
			"d": PanelStatus.Dark,
		}[level_goal[i]]
		print("%s %s %s" % [i, goal_status, panel_statuses[i]])
		if goal_status != panel_statuses[i]:
			return false
	return true # level complete if InLevel, and all panel status is same as goal status


func build_panel_from_clock_hand(card_idx: int) -> void:
	panel_statuses[clock.clock1_panel_id - 1] = _get_panel_status_from_card_idx(card_idx)
	panel_statuses[clock.clock2_panel_id - 1] = _get_panel_status_from_card_idx(card_idx)
	_update_panel_textures()


func build_panel_on_top(card_idx: int) -> void:
	assert(card_idx >= 0 and card_idx <= 4, "card_idx must be between 0 - 4!")
	var to_build_idx = top_panel_id
	if to_build_idx == 12:
		to_build_idx = 0

	var new_panel_status: PanelStatus = {
		0: PanelStatus.Normal,
		1: PanelStatus.Cracked,
		2: PanelStatus.Holy,
		3: PanelStatus.Dark,
		4: PanelStatus.Gap,
	}[card_idx]
	panel_statuses[to_build_idx] = new_panel_status
	top_panel_id = to_build_idx + 1
	_update_panel_textures()
	_update_panel_lights_dark_to_light()


func _get_opposite_panel_idx() -> int:
	var opposite_panel_idx = self.player.current_panel_id + 5 # + 6 (id) - 1 (for idx)
	if opposite_panel_idx >= 12:
		opposite_panel_idx -= 12
	return opposite_panel_idx


func _update_panel_status_all_fade_except_opposite() -> void:
	for i in 12:
		panel_statuses[i] = PanelStatus.Fade

	# make the opposite of player's current panel the exit of "Exiting" floor
	var opposite_panel_idx = self._get_opposite_panel_idx()
	panel_statuses[opposite_panel_idx] = PanelStatus.Normal
	panel_sprites[opposite_panel_idx].get_child(0).energy = 3
	self.top_panel_id = opposite_panel_idx + 1
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
	var to_fill_idx = top_panel_id
	if to_fill_idx == 12:
		to_fill_idx = 0

	for dark_idx in 12:
		var mod_val := dark_to_light_values[dark_idx]
		panel_sprites[to_fill_idx].get_child(0).energy = mod_val
		panel_sprites[to_fill_idx].modulate = Color(mod_val, mod_val, mod_val, 1)
		# panel_sprites[to_fill_idx].apply_scale
		to_fill_idx += 1
		if to_fill_idx == 12:
			to_fill_idx = 0


func _update_panel_textures() -> void:
	for i in 12:
		if i + 1 == top_panel_id:
			panel_sprites[i].texture = panel_sprite_top_map[panel_statuses[i]]
		else:
			panel_sprites[i].texture = panel_sprite_map[panel_statuses[i]]
