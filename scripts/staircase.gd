class_name Staircase
extends Node2D


# modulate values for Color(r, g, b) from darkest to lightest
var modulate_values: Array[float] = [0.16, 0.27, 0.37, 0.46, 0.55, 0.64, 0.73, 0.82, 0.91, 1.0, 1.0, 1.0]

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
	PanelStatus.Empty: preload('res://art/staircase_tile_empty.png'),
}

@onready var panel_sprite_top_map := {
	PanelStatus.Normal: preload('res://art/staircase_tile_normal_top.png'),
	PanelStatus.Holy: preload('res://art/staircase_tile_cracked_top.png'),
	PanelStatus.Dark: preload('res://art/staircase_tile_dark_top.png'),
	PanelStatus.Gap: preload('res://art/staircase_tile_gap_top.png'),
	PanelStatus.Cracked: preload('res://art/staircase_tile_holy_top.png'),
	PanelStatus.Empty: preload('res://art/staircase_tile_empty.png'),
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

var top_panel_idx := 6


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_panel_sprite_texture()
	update_panel_sprite_modulate()


func update_panel_sprite_modulate() -> void:
	var to_fill_idx = top_panel_idx
	if to_fill_idx == 12:
		to_fill_idx = 0

	for dark_idx in 12:
		var mod_val := modulate_values[dark_idx]
		panel_sprites[to_fill_idx].modulate = Color(mod_val, mod_val, mod_val, 1)
		to_fill_idx += 1
		if to_fill_idx == 12:
			to_fill_idx = 0


func update_panel_sprite_texture() -> void:
	for i in 12:
		if i + 1 == top_panel_idx:
			panel_sprites[i].texture = panel_sprite_top_map[panel_statuses[i]]
		else:
			panel_sprites[i].texture = panel_sprite_map[panel_statuses[i]]
