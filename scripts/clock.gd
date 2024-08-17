extends Sprite2D


@onready var clock_hand := $ClockHand


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.timer.timeout.connect(_rotate_hand)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
	# pass

func _rotate_hand() -> void:
	clock_hand.rotation_degrees += 30
