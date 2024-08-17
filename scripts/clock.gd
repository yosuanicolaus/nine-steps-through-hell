extends Sprite2D


var next_rotate_backward := false
@onready var clock_hand := $ClockHand


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.timer.timeout.connect(_rotate_hand)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
	# pass

func _rotate_hand() -> void:
	if next_rotate_backward:
		next_rotate_backward = false
		clock_hand.rotation_degrees -= 30
	else:
		clock_hand.rotation_degrees += 30
