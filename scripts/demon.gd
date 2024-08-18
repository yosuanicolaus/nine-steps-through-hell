extends Node2D


var cycle := 0
# var max_cycle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.timer.timeout.connect(_on_global_beat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_global_beat():
	# move demon
	if cycle == 0:
		self.rotation_degrees += 30
		cycle += 1
	else:
		cycle = 0
