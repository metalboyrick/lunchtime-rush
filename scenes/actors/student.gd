extends KinematicBody2D

export (bool) var IS_WALKING
export(int, "clockwise", "counter-clockwise") var DIRECTION = 1
export(int, "up", "right", "down", "left") var START_DIRECTION
export(float) var SPEED = 1

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
var turn_flag = false


# Called when the node enters the scene tree for the first time.
func _ready():
	current_direction = directions[START_DIRECTION]
	current_direction_index = START_DIRECTION
	
	if IS_WALKING:
		$AnimatedSprite.play(animation_names_walk[START_DIRECTION])
	else:
		$AnimatedSprite.play(animation_names_idle[START_DIRECTION])
		for turning_point in turning_points:
			var collision_box = turning_point.get_node("CollisionShape2D")
			collision_box.disabled = true
		
	player.connect("player_frozen", self, "player_frozen")
	player.connect("freeze_finished", self, "exit_freeze")
	for turning_point in turning_points:
		turning_point.connect("body_entered", self, "_on_body_entered")
	

func _physics_process(delta):
	if IS_WALKING:
		move_and_collide(current_direction.normalized() * SPEED)
	
func turn():
	var next_direction = 0
	if DIRECTION == 0:
		next_direction  = (current_direction_index + 1) % 4
	elif DIRECTION == 1:
		next_direction = current_direction_index - 1
		if next_direction < 0:
			next_direction = 3
	
	print(current_direction_index)
	print(next_direction)
	print(directions[next_direction])
			
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
		if IS_WALKING:
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
