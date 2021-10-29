extends HBoxContainer

var food_bar = []

onready var onigiri = get_node("Onigiri")
onready var hotdog = get_node("Hotdog")
onready var dango = get_node("Dango")
onready var cola = get_node("Cola")

enum {ONIGIRI, HOTDOG, DANGO, COLA}

signal obtain_mission(mission_array)


# Called when the node enters the scene tree for the first time.
func _ready():
	food_bar = [onigiri, hotdog, dango, cola]
	var mission_array = []
	
	if onigiri.visible:
		mission_array.append(ONIGIRI)
	if hotdog.visible:
		mission_array.append(HOTDOG)
	if dango.visible:
		mission_array.append(DANGO)
	if cola.visible:
		mission_array.append(COLA)
		
	emit_signal("obtain_mission", mission_array)


func _on_Player_item_added(item_id):
	food_bar[item_id].modulate = Color(1,1,1,1)
	pass # Replace with function body.
