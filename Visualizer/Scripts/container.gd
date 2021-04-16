extends Node2D


const ELEMENT_SIZE = 20

var custom_name: String = ""
var shape: StyleBoxFlat

onready var Main: Node
onready var Problem: Node


func deselect_elements():
	
	for I in get_elements_selected():
		I.set_selected(false)


func draw_self() -> void:
	draw_style_box(shape, Rect2(Vector2(0, 0), $Mask.rect_size))


func get_center(offset = Vector2.ZERO) -> Vector2:
	return $Mask.rect_position + $Mask.rect_size / 2 + offset


func get_elements() -> Array:
	return $Elements.get_children()


func get_name() -> String:
	return custom_name


func get_elements_selected() -> Array:
	
	var elements_selected = []
	for I in get_elements():
		if I.is_selected:
			elements_selected.append(I)
	return elements_selected


func get_size() -> int:
	return len(get_elements())
