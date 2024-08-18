class_name Clock
extends Sprite2D


var next_rotate_backward := false

@onready var clock1_hand := $ClockHand # long, controllable
@onready var clock2_hand := $ClockHand2 # short, slower, uncontrollable

@onready var light_nodes: Array[PointLight2D] = [
	$Light1, $Light2, $Light3, $Light4, $Light5, $Light6,
	$Light7, $Light8, $Light9, $Light10, $Light11, $Light12,
]

@onready var player: Player = $Rotator/Player

enum LightStatus {Off, Holy, Dartrigger_in_levelk}

var light_statuses: Array[LightStatus] = [
	LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off,
	LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off,
]

var clock1_panel_id := 1:
	set(val):
		clock1_panel_id = val
		if val > 12:
			clock1_panel_id -= 12
var clock2_panel_id := 7:
	set(val):
		clock2_panel_id = val
		if val > 12:
			clock2_panel_id -= 12
var clock2_cycle := true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.signal_player_control.connect(_on_player_half_beat)
	Global.timer.timeout.connect(_on_global_beat)
	Global.signal_global_state_change.connect(_on_global_state_change)


func _on_player_half_beat():
	self.next_rotate_backward = true


func _on_global_state_change() -> void:
	if Global.state == Global.State.Exiting:
		self._set_clock_lights_off()
	elif Global.state == Global.State.InBetween:
		self._set_clock_lights_off()
	else: # InLevel
		self.modify_clock_lights_from_goal(Global.get_current_level_goal())


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
	# pass


func modify_clock_lights_from_goal(level_goal: String) -> void:
	# level_goal is a string of length 12 consisting of either "-", "h", "d", ...
	for i in 12:
		var light_node := self.light_nodes[i]
		if level_goal[i] == "-":
			light_node.energy = 0
		elif level_goal[i] == "h": # holy -> yellow
			light_node.energy = 2
			light_node.color = Color(1, 1, 0, 1)
		elif level_goal[i] == "d": # dark -> purple
			light_node.energy = 2
			light_node.color = Color(1, 0, 1, 1)


func _set_clock_lights_off() -> void:
	for light_node in self.light_nodes:
		light_node.energy = 0


func _on_global_beat() -> void:
	if next_rotate_backward:
		next_rotate_backward = false
		clock1_hand.rotation_degrees -= 30
		clock1_panel_id -= 1
	else:
		clock1_hand.rotation_degrees += 30
		clock1_panel_id += 1

	if clock2_cycle:
		clock2_cycle = false
		clock2_hand.rotation_degrees += 30
		clock2_panel_id += 1
	else:
		clock2_cycle = true
