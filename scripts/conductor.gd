extends AudioStreamPlayer

signal signal_audio_beat

@export var song_bpm: float = 100.0

# https://www.reddit.com/r/godot/comments/15jqlqh/how_do_i_make_a_metronome_that_activates_triggers/
# Tracking the signal_audio_beat and song position
var song_position: float = 0.0
var last_reported_beat := 0
var song_position_in_beats := 0
var seconds_per_beat := 60.0 / song_bpm

var beats_before_start = 0

func _ready() -> void:
	seconds_per_beat = 60.0 / song_bpm

# We're stick to game frames no matter how we're trying to bound to audio time. So let's
# use this loop to determine the audio time and work with it
func _process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / seconds_per_beat)) + beats_before_start
		_report_beat()


func _report_beat() -> void:
	if last_reported_beat < song_position_in_beats:
		# print("signal_audio_beat ", song_position_in_beats)
		# emit_signal("signal_audio_beat", song_position_in_beats)
		signal_audio_beat.emit(song_position_in_beats)
		last_reported_beat = song_position_in_beats
