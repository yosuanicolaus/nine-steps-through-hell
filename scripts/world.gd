extends Node2D

@onready var player: Node2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("world instanced")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

