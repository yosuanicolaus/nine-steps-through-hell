extends Node2D


const WORLD = preload('res://world.tscn')

@onready var title_label : Label = $Label
@onready var story_label : Label = $StoryLabel

var begin_story := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press_enter"):
		if not begin_story:
			begin_story = true
			title_label.visible = false
			story_label.visible = true
		else:
			get_tree().change_scene_to_packed(WORLD)
