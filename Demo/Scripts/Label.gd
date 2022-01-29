extends RichTextLabel


func _ready() -> void:
	pass

func _cheat_code_activated() -> void:
	bbcode_text = "\n[center][rainbow][wave]%s[/wave][/rainbow][/center]\n" % [
		"You have pressed the konami code!"
	]
