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
## Use the `CheatCode` resource
export (Resource) var code

var code_progress: int = 0
var first_time: bool = false
var timeout_timer: float = timeout_delay

func _ready() -> void:
	assert(code is CheatCode, "%s/code MUST be of type `CheatCode`" % get_path())

func _process(delta: float) -> void:
	if disabled: return
	
	timeout_timer -= delta
	if timeout_timer <= 0.0 and has_timeout:
		code_progress = 0
		emit_signal("cheat_progress", 0)

func _input(event: InputEvent) -> void:
	if disabled: return
	if event is InputEventKey:
		if event.pressed and not event.echo \
				and not event.control and not event.shift \
				and not event.meta and not event.alt:
			var next_key = code.entries[code_progress] if \
					code.entries[code_progress] != 0 else KEY_UP
			if next_key == event.scancode:
				code_progress += 1
				timeout_timer = timeout_delay
				
				if code_progress == len(code.entries):
					if not repeat and not first_time:
						emit_signal("cheat_activated")
					first_time = true
					code_progress = 0
				else:
					emit_signal("cheat_progress", code_progress)
			elif not allow_mistakes:
				code_progress = 0
				emit_signal("cheat_progress", code_progress)

func set_disabled(new_value: bool) -> void:
	disabled = new_value
	code_progress = 0
	timeout_timer = timeout_delay
