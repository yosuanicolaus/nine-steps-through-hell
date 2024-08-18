class_name Staircase
extends Node2D


# modulate values for Color(r, g, b) from darkest to lightest
var dark_to_light_values: Array[float] = [0.16, 0.27, 0.37, 0.46, 0.55, 0.64, 0.73, 0.82, 0.91, 1.0, 1.0, 1.0]

@onready var panel_sprites: Array[Sprite2D] = [
	$Panel1/Sprite, # player start location
	$Panel2/Sprite,
	$Panel3/Sprite,
	$Panel4/Sprite,
	$Panel5/Sprite,
	$Panel6/Sprite,
	$Panel7/Sprite,
	$Panel8/Sprite,
	$Panel9/Sprite,
	$Panel10/Sprite,
	$Panel11/Sprite,
	$Panel12/Sprite,
]

enum PanelStatus {Normal, Holy, Dark, Gap, Cracked, Empty}

@onready var panel_sprite_map := {
	PanelStatus.Normal: preload('res://art/staircase_tile_normal.png'),
	PanelStatus.Holy: preload('res://art/staircase_tile_cracked.png'),
	PanelStatus.Dark: preload('res://art/staircase_tile_dark.png'),
	PanelStatus.Gap: preload('res://art/staircase_tile_gap.png'),
	PanelStatus.Cracked: preload('res://art/staircase_tile_holy.png'),
	PanelStatus.Empty: preload('res://art/empty_sprite.png'),
}

@onready var panel_sprite_top_map := {
	PanelStatus.Normal: preload('res://art/staircase_tile_normal_top.png'),
	PanelStatus.Holy: preload('res://art/staircase_tile_cracked_top.png'),
	PanelStatus.Dark: preload('res://art/staircase_tile_dark_top.png'),
	PanelStatus.Gap: preload('res://art/staircase_tile_gap_top.png'),
	PanelStatus.Cracked: preload('res://art/staircase_tile_holy_top.png'),
	PanelStatus.Empty: preload('res://art/empty_sprite.png'),
}

var panel_statuses: Array[PanelStatus] = [
	PanelStatus.Normal,
	PanelStatus.Normal,
	PanelStatus.Normal,
	PanelStatus.Normal,
	PanelStatus.Normal,
	PanelStatus.Normal,
	PanelStatus.Empty,
	PanelStatus.Empty,
	PanelStatus.Empty,
	PanelStatus.Empty,
	PanelStatus.Empty,
	PanelStatus.Empty,
]

var top_panel_id := 6 # top panel ID (not idx!) <int>1~12


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_panel_sprite_texture()
	_update_panel_sprite_modulate()


func update_from_player_action(player: Player) -> void:
	# based on player's current panel, update top_panel
	print("update_from_player_action ", player)


func build_panel(card_idx: int) -> void:
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


func trigger_in_level() -> void:
	for i in 12:
		panel_sprites[i].get_child(0).energy = 1
		panel_sprites[i].modulate = Color(1, 1, 1, 1)
		panel_statuses[i] = PanelStatus.Normal
	_update_panel_sprite_texture()


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
