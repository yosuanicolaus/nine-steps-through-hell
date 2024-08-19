class_name Clock
extends Sprite2D


var next_rotate_backward := false

@onready var clock1_hand := $ClockHand # long, controllable
@onready var clock2_hand := $ClockHand2 # short, slower, uncontrollable

@onready var light_nodes: Array[PointLight2D] = [
	$Light1, $Light2, $Light3, $Light4, $Light5, $Light6,
	$Light7, $Light8, $Light9, $Light10, $Light11, $Light12,
]

@onready var player: Player = get_node("../Player")

enum LightStatus {Off, Holy, Dark, Earth}

var light_statuses: Array[LightStatus] = [
	LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off,
	LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off, LightStatus.Off,
]

var clock1_panel_idx := 0:
	set(val):
		clock1_panel_idx = val
		clock1_panel_idx %= 12
var clock2_panel_idx := 6:
	set(val):
		clock2_panel_idx = val
		clock2_panel_idx %= 12
var clock2_cycle := true
var light_energy := 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clock2_hand.visible = false
	player.signal_player_control.connect(_on_player_half_beat)
	player.signal_player_move.connect(_on_player_move)
	player.signal_player_play_card.connect(_on_player_play_card)
	Global.timer.timeout.connect(_on_global_beat)
	Global.signal_global_state_change.connect(_on_global_state_change)
	Global.signal_global_puzzle_change.connect(_on_global_puzzle_change)


func _on_player_half_beat():
	self.next_rotate_backward = true


func _on_player_move(_move_sign: int, _current_panel_idx: int):
	pass


func _on_player_play_card(_card_key_idx: int):
	pass


func _on_global_puzzle_change():
	if Global.state == Global.State.InLevel:
		self.modify_clock_lights_from_string(Global.get_current_level_goal())
	else:
		self._set_clock_lights_off()


func _on_global_state_change() -> void:
	if Global.state == Global.State.Exiting:
		self._set_clock_lights_off()
	elif Global.state == Global.State.InBetween:
		self._set_clock_lights_off()
	elif Global.state == Global.State.Tutorial:
		pass
	else: # InLevel
		self.modify_clock_lights_from_string(Global.get_current_level_goal())


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
	# pass


func _set_light_status(idx: int, light_status: LightStatus) -> void:
	print("setlightstatus ", idx, " , ", light_status)
	self.light_statuses[idx] = light_status
	if light_status == LightStatus.Off:
		self.light_nodes[idx].energy = 0
	elif light_status == LightStatus.Holy:
		self.light_nodes[idx].energy = self.light_energy
		self.light_nodes[idx].color = Color(1, 1, 0, 1)
	elif light_status == LightStatus.Dark:
		self.light_nodes[idx].energy = self.light_energy
		self.light_nodes[idx].color = Color(1, 0, 1, 1)
	elif light_status == LightStatus.Earth:
		self.light_nodes[idx].energy = self.light_energy
		self.light_nodes[idx].color = Color(0, 1, 0, 1)


func modify_clock_lights_from_string(level_goal: String) -> void:
	# level_goal is a string of length 12 consisting of either "-", "h", "d", "e"
	for i in 12:
		if level_goal[i] == "-":
			self._set_light_status(i, LightStatus.Off)
		elif level_goal[i] == "h": # holy -> yellow
			self._set_light_status(i, LightStatus.Holy)
		elif level_goal[i] == "d": # dark -> purple
			self._set_light_status(i, LightStatus.Dark)


func _set_clock_lights_off() -> void:
	self.modify_clock_lights_from_string("------------")


func _on_global_beat() -> void:
	if Global.in_freeze: return
	if next_rotate_backward:
		next_rotate_backward = false
		clock1_hand.rotation_degrees -= 30
		clock1_panel_idx -= 1
	else:
		clock1_hand.rotation_degrees += 30
		clock1_panel_idx += 1

	if clock2_cycle:
		clock2_cycle = false
		clock2_hand.rotation_degrees += 30
		clock2_panel_idx += 1
	else:
		clock2_cycle = true
