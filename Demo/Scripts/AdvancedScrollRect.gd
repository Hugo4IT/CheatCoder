extends Container

export (int) var scrolled_children: int = 0 setget set_scrolled_children

onready var scroll_y: float = 0.0

var tween: Tween

var _minimum_width = 0

func _ready() -> void:
	tween = Tween.new()
	get_parent().call_deferred("add_child", tween)
	call_deferred("set_scrolled_children", 0)

func _get_minimum_size() -> Vector2:
	return Vector2(_minimum_width, 0.0)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_minimum_width = 0
			var current_y: float = rect_global_position.y + rect_size.y / 2.0 - scroll_y
			
			for child in get_children():
				if child is Control:
					child.rect_global_position.y = current_y
					
					var half_size = rect_size.y / 2.0
					var center = half_size - get_child(0).rect_size.y / 2.0
					var distance = pow(1.0 - abs((current_y - center) / half_size), 2.0)
					child.modulate.a = distance
					child.rect_pivot_offset.y = child.rect_size.y * (1.0 - current_y / rect_size.y)
					child.rect_scale = Vector2(
							pow(distance, 2.0) * 0.5 + 0.5, pow(distance, 2.0) * 0.5 + 0.5)
					
					current_y += child.rect_size.y
					_minimum_width = max(_minimum_width, child.rect_size.x)

func set_scrolled_children(new_value: int) -> void:
	if new_value > get_child_count(): return
	
	var temp_scroll_y = get_child(0).rect_size.y / 2.0
	for i in range(new_value):
		temp_scroll_y += get_child(i).rect_size.y
	
	tween.interpolate_method(self, "set_scroll_y", scroll_y, temp_scroll_y,
			0.3, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()
	
	scrolled_children = new_value

func set_scroll_y(new_value: float) -> void:
	scroll_y = new_value
	queue_sort()
