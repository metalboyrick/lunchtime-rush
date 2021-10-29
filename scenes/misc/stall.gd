extends Node

class_name Stall

# Declare member variables here. Examples:
var stall_name

enum {ONIGIRI, HOTDOG, DANGO, COLA}

signal enter_stall(id)
signal exit_stall()
signal stall_in_range(id)
signal stall_exit_range(id)

onready var stand_zone = get_node("StandZone")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for node in get_tree().get_nodes_in_group("player_feet"):
		if stand_zone.overlaps_area(node):
			emit_signal("enter_stall", stall_name)
			
func _on_StandZone_body_exited(body):
	emit_signal("exit_stall")
	
func _on_VisibilityNotifier2D_screen_entered():
	emit_signal("stall_in_range", get_instance_id())

func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("stall_exit_range", get_instance_id())


