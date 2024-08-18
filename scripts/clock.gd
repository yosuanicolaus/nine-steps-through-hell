extends Sprite2D


var next_rotate_backward := false

@onready var clock_hand1 := $ClockHand  # long, controllable
@onready var clock_hand2 := $ClockHand2 # short, slower, uncontrollable

var clock1_panel_id := 1:
	set(val):
		if val > 12:
			clock1_panel_id -= 12
var clock2_panel_id := 7:
	set(val):
		if val > 12:
			clock2_panel_id -= 12
var clock2_cycle := true


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
		clock_hand1.rotation_degrees -= 30
		clock1_panel_id += 1
	else:
		clock_hand1.rotation_degrees += 30

	if clock2_cycle:
		clock2_cycle = false
		clock_hand2.rotation_degrees += 30
		clock2_panel_id += 1
		# if clock2_panel_id == 12:
			# clock2_panel
	else:
		clock2_cycle = true
