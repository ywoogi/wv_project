extends Node2D

const ELEMENT = preload("res://Scenes/Element.tscn")

var custom_name : String
var distinct = false
var element_offset = 0
var shape


func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	
	$Label.text = name


func _draw():
	
	draw_style_box(shape, Rect2(Vector2(0, 0), $Mask.rect_size))


func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Add": 
			
			var new_element = ELEMENT.instance()
			new_element.position = $Menu.position
			$Elements.add_child(new_element)
	
	$Menu.hide()


func _pressed_global() -> void:
	
	$Menu.position = get_local_mouse_position()
	$Menu.show()


#TODO add ability to add names to elements -> adv settings
func add_element():
	
	var new_element = ELEMENT.instance()
	new_element.position = Vector2(0, element_offset)
	element_offset += 64
	$Elements.add_child(new_element)


func get_name() -> String:
	
	return custom_name


func set_distinct(distinct : bool):
	
	self.distinct = distinct
	for I in $Elements.get_children():
		if distinct:
			I.modulate = Color(g.randomf(1), g.randomf(1), g.randomf(1), 1)
		else:
			I.modulate = Color.white


func set_name(custom_name : String = "") -> void:
	
	if custom_name == "": $Label.text = name
	else: $Label.text = name + " (" + custom_name + ")"


func set_size(size : int) -> void:
	
	for i in $Elements.get_children():
		 i.queue_free()
	element_offset = 0
	for _i in range(size):
		add_element()
	set_distinct(distinct)
