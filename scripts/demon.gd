extends Node2D


var cycle := 0
@onready var animated_sprite = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finish)
	Global.timer.timeout.connect(_on_global_beat)


func _on_animation_finish():
	animated_sprite.play('idle')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_global_beat():
	# move demon
	if cycle == 0:
		# todo calculate the relative position with player, and choose to move left/right
		var move_sign := 1
		self.animated_sprite.flip_h = move_sign == -1
		self.animated_sprite.play("move")
		self.rotation_degrees += 30 * move_sign
		cycle += 1
	else:
		cycle = 0
