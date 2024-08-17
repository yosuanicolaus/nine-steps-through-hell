extends Node2D


var modulate_values := [40, 70, 94, 117, 140, 163, 186, 209, 232, 255, 255, 255]

# listed from dark -> light
@onready var panels := [
	$Anchor7/StaircaseTile,
	$Anchor8/StaircaseTile,
	$Anchor9/StaircaseTile,
	$Anchor10/StaircaseTile,
	$Anchor11/StaircaseTile,
	$Anchor12/StaircaseTile,
	$Anchor/StaircaseTile,  # player start location
	$Anchor2/StaircaseTile,
	$Anchor3/StaircaseTile,
	$Anchor4/StaircaseTile,
	$Anchor5/StaircaseTile,
	$Anchor6/StaircaseTile,
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for idx in 12:
		var mod_val := float(modulate_values[idx]) / 255
		print(mod_val)
		panels[idx].modulate = Color(mod_val, mod_val, mod_val, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
	# pass
