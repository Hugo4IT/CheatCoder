class_name CheatCodeListener
extends Node

signal cheat_activated
signal cheat_progress

## Allow pressing the wrong button
export (bool) var allow_mistakes: bool = false
## If the cheat code progress should automatically be reset
export (bool) var has_timeout: bool = true
## Automatically reset cheat code progress after `timeout_delay` seconds
export (float) var timeout_delay: float = 2.0
## Stop listening for input
export (bool) var disabled: bool = false setget set_disabled
## Will the signal be called every time the cheat code is activated, or only once?
export (bool) var repeat: bool = false
## Delay before player can use another cheatcode
export (float) var repeat_cooldown: float = 5.0
## Use the `CheatCode` resource
export (Resource) var code

var code_progress: int = 0
var first_time: bool = false
var timeout_timer: Timer
var cooldown_timer: Timer

func _ready() -> void:
	assert(code is CheatCode, "%s/code MUST be of type `CheatCode`" % get_path())

	timeout_timer = Timer.new()
	add_child(timeout_timer)

	timeout_timer.start(timeout_delay)
	timeout_timer.connect("timeout", self, "_timeout_timer_timeout")

	cooldown_timer = Timer.new()
	add_child(cooldown_timer)

	cooldown_timer.connect("timeout", cooldown_timer, "stop")

func _timeout_timer_timeout() -> void:
	if has_timeout:
		code_progress = 0
		emit_signal("cheat_progress", 0)
	
	timeout_timer.start(timeout_delay)

func _input(event: InputEvent) -> void:
	if disabled:
		return

	if not cooldown_timer.is_stopped():
		return

	if event is InputEventKey:
		if event.pressed and not event.echo \
				and not event.control and not event.shift \
				and not event.meta and not event.alt:
			var next_key = code.entries[code_progress] if \
					code.entries[code_progress] != 0 else KEY_UP
			if next_key == event.scancode:
				code_progress += 1
				timeout_timer.start(timeout_delay)
				
				if code_progress == len(code.entries):
					if repeat or not first_time:
						emit_signal("cheat_activated")
					first_time = true
					code_progress = 0

					cooldown_timer.start(repeat_cooldown)
				else:
					emit_signal("cheat_progress", code_progress)
			elif not allow_mistakes:
				code_progress = 0
				emit_signal("cheat_progress", code_progress)

func set_disabled(new_value: bool) -> void:
	disabled = new_value
	code_progress = 0

	if disabled:
		timeout_timer.stop()
	else:
		timeout_timer.start(timeout_delay)
