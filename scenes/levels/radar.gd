extends Control


# Declare member variables here. Examples:
var center

onready var player = get_parent().get_parent().get_node("YSort/Player")
onready var radar_center = get_node("RadarCenter")

onready var onigiri_radar = get_node("OnigiriRadar")
onready var onigiri_stall = get_parent().get_parent().get_node("OnigiriStall")

onready var hotdog_radar = get_node("HotdogRadar")
onready var hotdog_stall = get_parent().get_parent().get_node("HotdogStall")

onready var cola_radar = get_node("ColaRadar")
onready var cola_stall = get_parent().get_parent().get_node("ColaStall")

onready var dango_radar = get_node("DangoRadar")
onready var dango_stall = get_parent().get_parent().get_node("DangoStall")

onready var goal_radar = get_node("GoalRadar")
onready var goal_zone= get_parent().get_parent().get_node("Goal")

# Called when the node enters the scene tree for the first time.
func _ready():
	center = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2) 
	pass # Replace with function body.

func move_radar(food_radar, stall):
	var player_pos = player.global_position
	var stall_pos = stall.global_position
	var directional_vector = (stall_pos - player_pos).normalized()
	
	var angle  = directional_vector.angle_to(Vector2.DOWN) 
	print(angle)
	food_radar.rect_global_position = radar_center.global_position + directional_vector * 100
	food_radar.get_node("Arrow").rotation = -1 * angle
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_radar(onigiri_radar, onigiri_stall)
	move_radar(dango_radar, dango_stall)
	move_radar(cola_radar, cola_stall)
	move_radar(hotdog_radar, hotdog_stall)
	move_radar(goal_radar, goal_zone)



func _on_ColaStall_stall_exit_range(id):
	cola_radar.visible = true


func _on_ColaStall_stall_in_range(id):
	cola_radar.visible = false


func _on_DangoStall_stall_exit_range(id):
	dango_radar.visible = true


func _on_DangoStall_stall_in_range(id):
	dango_radar.visible = false


func _on_HotdogStall_stall_exit_range(id):
	hotdog_radar.visible = true


func _on_HotdogStall_stall_in_range(id):
	hotdog_radar.visible = false


func _on_OnigiriStall_stall_exit_range(id):
	onigiri_radar.visible = true


func _on_OnigiriStall_stall_in_range(id):
	onigiri_radar.visible = false


func _on_VisibilityNotifier2D_viewport_entered(viewport):
	goal_radar.visible = false


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	goal_radar.visible = true
