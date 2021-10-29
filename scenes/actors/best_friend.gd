extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (bool) var IS_WALKING
export(int, "clockwise", "counter-clockwise") var DIRECTION = 0
export(int, "up", "right", "down", "left") var START_DIRECTION = 2
export(float) var SPEED = 1

enum {BESTFRIEND, TEACHER, STUDENT}

onready var sight = get_node("Sight")
onready var dialog = get_node("Dialog")
onready var player = get_parent().get_parent().get_node("Player")
onready var sprite = get_node("AnimatedSprite")
onready var turning_points = [get_parent().get_node("TurnPoint1"),
								get_parent().get_node("TurnPoint2"),
								get_parent().get_node("TurnPoint3"),
								get_parent().get_node("TurnPoint4")]
								
var current_direction = Vector2.ZERO
var current_direction_index
var original_position = self.global_position
var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var animation_names_walk = ["walk_up", "walk_right", "walk_down", "walk_left"]
var animation_names_idle = ["idle_up", "idle_right", "idle_down", "idle_left"]
var angles = [PI,-1 * (PI / 2),0, PI / 2]
var turn_flag = false

signal player_spotted(npc_id, instance_id)


# Called when the node enters the scene tree for the first time.
func _ready():
	current_direction = directions[START_DIRECTION]
	sight.rotation = angles[START_DIRECTION]
	current_direction_index = START_DIRECTION
	
	if IS_WALKING:
		sprite.play(animation_names_walk[START_DIRECTION])
	else:
		sprite.play(animation_names_idle[START_DIRECTION])
		
	player.connect("player_frozen", self, "player_frozen")
	player.connect("freeze_finished", self, "exit_freeze")
	for turning_point in turning_points:
		turning_point.connect("body_entered", self, "_on_body_entered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for node in get_tree().get_nodes_in_group("player_feet"):
		if sight.overlaps_area(node):
			emit_signal("player_spotted", BESTFRIEND, get_instance_id())
			
	if IS_WALKING:
		move_and_collide(current_direction.normalized() * SPEED)
			

func turn():
	var next_direction = 0
	if DIRECTION == 0:
		next_direction  = (current_direction_index + 1) % 4
		sight.rotate(PI / 2)
	elif DIRECTION == 1:
		next_direction = current_direction_index - 1
		if next_direction < 0:
			next_direction = 3
		sight.rotate(-1 * PI / 2)
		
	current_direction = directions[next_direction]
	sprite.play(animation_names_walk[next_direction])
	current_direction_index = next_direction

func player_frozen(id):
	if id == get_instance_id():
		dialog.visible = true	
		var player_pos = player.global_position
		var npc_pos = self.global_position
		var player_pos_relative = (player_pos - npc_pos).normalized()
		var player_direction = Vector2(int(round(player_pos_relative.x)), int(round(player_pos_relative.y)))
		
		if player_direction.x != 0 and player_direction.y != 0:
			player_direction = Vector2(0, player_direction.y)
		
		var player_direction_index = directions.find(player_direction)
		
		# stop and idle the sprite
		current_direction = Vector2.ZERO
		sprite.play(animation_names_idle[ player_direction_index])
	
		
func exit_freeze():
	current_direction = directions[current_direction_index]
	if IS_WALKING:
		sprite.play(animation_names_walk[current_direction_index])
	else:
		sprite.play(animation_names_idle[current_direction_index])
	
	dialog.visible = false
			
func _on_body_entered(body):
	if body == self:
		turn()
