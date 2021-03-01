extends Node2D

const ELEMENT = preload("res://Scenes/Element.tscn")
const ELEMENT_COLORS = [
	Color(1, 0.406122, 0.406122), 
	Color(0.406122, 0.540673, 1), 
	Color(0.406122, 1, 0.554592), 
	Color(0.967522, 1, 0.406122),
	Color(0.675223, 0.406122, 1), 
	Color(1, 0.684503, 0.406122), 
	Color(1, 0.406122, 0.781936), 
	Color(0.406122, 0.958243, 1), 
	Color(0.558594, 0.218878, 0.218878), 
	Color(0.237456, 0.218878, 0.558594)]

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
			add_element()
		
		"Group":
			for i in $Elements.get_children():
				if i.selected == true:
					pass
			#add selected
	
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
	var elements = $Elements.get_children()
	for i in range(len(elements)):
		if distinct:
			elements[i].set_color(ELEMENT_COLORS[i])
			#	Color(0.33 * (i%3), 0.33 * ((i/3)%3), 0.33 * ((i/9)%3))
		else:
			elements[i].set_color(Color.white)


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
