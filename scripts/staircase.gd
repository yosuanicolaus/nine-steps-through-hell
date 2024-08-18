class_name Staircase
extends Node2D


# modulate values for Color(r, g, b) from darkest to lightest
var dark_to_light_values: Array[float] = [0.16, 0.27, 0.37, 0.46, 0.55, 0.64, 0.73, 0.82, 0.91, 1.0, 1.0, 1.0]

@onready var panel_sprites: Array[Sprite2D] = [ # player start at Panel1
	$Panel1/Sprite, $Panel2/Sprite, $Panel3/Sprite, $Panel4/Sprite, $Panel5/Sprite, $Panel6/Sprite,
	$Panel7/Sprite, $Panel8/Sprite, $Panel9/Sprite, $Panel10/Sprite, $Panel11/Sprite, $Panel12/Sprite,
]

enum PanelStatus {Normal, Holy, Dark, Gap, Cracked, Empty, Fade}

enum StaircaseState {Exiting, InLevel, InBetween}

var state: StaircaseState = StaircaseState.InBetween

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
	PanelStatus.Normal, PanelStatus.Normal, PanelStatus.Normal, PanelStatus.Normal,
	PanelStatus.Normal, PanelStatus.Normal, PanelStatus.Empty, PanelStatus.Empty,
	PanelStatus.Empty, PanelStatus.Empty, PanelStatus.Empty, PanelStatus.Empty,
]

var top_panel_id := 6 # top panel ID (not idx!) <int>1~12


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_panel_sprite_texture()
	_update_panel_sprite_modulate()


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
	if not self.state == StaircaseState.InLevel:
		return false

	for i in 12:
		var goal_status = {
			"-": PanelStatus.Normal,
			"h": PanelStatus.Holy,
			"d": PanelStatus.Dark,
		}[level_goal[i]]
		print("i: ", i, ", goal_status: ", goal_status, ", panelstatus: ", panel_statuses[i])
		if goal_status != panel_statuses[i]:
			return false
	return true  # level complete if InLevel, and all panel status is same as goal status


func build_panel_on_clock_hand(clock: Clock, card_idx: int) -> void:
	panel_statuses[clock.clock1_panel_id - 1] = _get_panel_status_from_card_idx(card_idx)
	panel_statuses[clock.clock2_panel_id - 1] = _get_panel_status_from_card_idx(card_idx)
	_update_panel_sprite_texture()


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
	_update_panel_sprite_texture()
	_update_panel_sprite_modulate()


func trigger_enter_level() -> void:
	self.state = StaircaseState.InLevel
	for i in 12:
		panel_sprites[i].get_child(0).energy = 1
		panel_sprites[i].modulate = Color(1, 1, 1, 1)
		panel_statuses[i] = PanelStatus.Normal
	_update_panel_sprite_texture()


func trigger_exiting_level(player_panel_id: int) -> void:
	self.state = StaircaseState.Exiting
	for i in 12:
		panel_statuses[i] = PanelStatus.Fade

	# make the opposite of player's current panel the exit of "Exiting" floor
	var opposite_panel_idx = player_panel_id + 5  # + 6 (id) - 1 (for idx)
	if opposite_panel_idx >= 12:
		opposite_panel_idx -= 12
	panel_statuses[opposite_panel_idx] = PanelStatus.Normal
	panel_sprites[opposite_panel_idx].get_child(0).energy = 3
	_update_panel_sprite_texture()


func trigger_global_freeze() -> void:
	Global.in_freeze = true
	for i in 12:
		panel_sprites[i].modulate = Color(10, 10, 10, 1)
	await get_tree().create_timer(1.0).timeout
	for i in 12:
		panel_sprites[i].modulate = Color(1, 1, 1, 1)
	Global.in_freeze = false


func _update_panel_sprite_modulate() -> void:
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


func _update_panel_sprite_texture() -> void:
	for i in 12:
		if i + 1 == top_panel_id:
			panel_sprites[i].texture = panel_sprite_top_map[panel_statuses[i]]
		else:
			panel_sprites[i].texture = panel_sprite_map[panel_statuses[i]]
