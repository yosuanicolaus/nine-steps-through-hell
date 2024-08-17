extends Node2D

var can_move := false
var has_moved := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func move_player():
	self.rotation_degrees += 30
