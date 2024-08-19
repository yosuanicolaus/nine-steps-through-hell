class_name Demon
extends Node2D


@onready var animated_sprite = $AnimatedSprite2D
@onready var respawn_timer: Timer = $RespawnTimer
@onready var player: Player = get_node("../Player")
@onready var staircase: Staircase = get_node("../Staircase")

var cycle : Array[bool] = [false, false, true]
var cycle_idx: int = 0
var current_panel_idx := 7  # panel IDX; int of range 0-11

@onready var demon_active: bool = false:
	set(val):
		demon_active = val
		if val == true:
			# reposition to opposite of player
			self.cycle_idx = 0
			self.current_panel_idx = (player.current_panel_idx + 6) % 12
			self.rotation_degrees = player.rotation_degrees + 180
		self.visible = val


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finish)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	Global.timer.timeout.connect(_on_global_beat)
	Global.signal_global_state_change.connect(_on_global_state_change)


func _on_animation_finish():
	animated_sprite.play('idle')


func _on_respawn_timer_timeout():
	if Global.state == Global.State.InLevel:
		self.demon_active = true


func _on_global_state_change():
	if Global.state == Global.State.InLevel and Global.unlock_demon:
		self.respawn_timer.stop()
		self.demon_active = true
	else:
		self.demon_active = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.demon_active and self.current_panel_idx == player.current_panel_idx:
		# demon just hit the player, oh no!
		self.demon_active = false
		self.respawn_timer.start()
		for i in 12:
			staircase.update_panel(i, staircase.PanelStatus.Dark)


func _get_move_sign() -> int:
	for i in range(6):
		var next_panel_idx := self.current_panel_idx + i + 1
		next_panel_idx %= 12
		if next_panel_idx == player.current_panel_idx:
			return 1

	return -1


func _on_global_beat():
	# move demon
	if not demon_active or Global.in_freeze or Global.state != Global.State.InLevel:
		return

	if self.cycle[cycle_idx]:
		var move_sign := self._get_move_sign()
		self.animated_sprite.flip_h = move_sign == -1
		self.animated_sprite.play("move")
		self.rotation_degrees += 30 * move_sign

		self.current_panel_idx += move_sign
		self.current_panel_idx %= 12
		if self.current_panel_idx < 0:
			self.current_panel_idx += 12

	cycle_idx += 1
	cycle_idx %= len(cycle)
