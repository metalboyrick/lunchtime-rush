extends KinematicBody2D


# Declare member variables here. Examples:
export var SPEED = 1
export var RUN_SPEED = 2
export var ANIM_SPEED_SCALE = 1

enum {IDLE, WALK, RUN, FREEZE}
enum {ONIGIRI, HOTDOG, DANGO, COLA}
enum {BESTFRIEND, TEACHER, STUDENT}


var input_vector = Vector2.ZERO
var current_direction = Vector2.DOWN			# Current direction of the character
var current_speed = SPEED
var current_state = IDLE
var current_inventory = []
var mission  = []

onready var freeze_timer = get_node("FreezeTimer")
onready var cooldown_timer= get_node("CooldownTimer")
onready var food_indicator = get_node("FoodIndicator")
onready var coin_sound = get_node("CoinSound")
onready var clash_sound = get_node("ClashSound")

signal item_added(item_id)
signal player_frozen(npc_instance_id)
signal freeze_finished
signal all_items_obtained

# Called when the node enters the scene tree for the first time.
func _ready():
	# connect all npc signals
	for npc_node in get_tree().get_nodes_in_group("npc"):
		npc_node.connect("player_spotted", self, "handle_detection")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# get unit translation for x and y
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if current_state != FREEZE:
		if input_vector == Vector2.ZERO:
			current_state = IDLE
			play_idle_animation(current_direction)
		else: 
			
			# handle sprinting
			if Input.is_action_pressed("sprint"):
				current_state = RUN
				current_speed = RUN_SPEED 
			elif input_vector != Vector2.ZERO:
				current_state = WALK
				current_speed = SPEED
			
			# handle diagonals
			if input_vector.x != 0 and input_vector.y != 0:
				current_direction = Vector2(input_vector.x, 0)
			else:
				# set animations according to direction
				current_direction = input_vector
			
			play_walk_animation(current_direction)
		
		var collision = move_and_collide(input_vector.normalized() * current_speed)
		if collision:
			if "Student" in collision.collider.name:
				handle_detection(STUDENT, collision.collider.get_instance_id())
					
func handle_detection(npc_id, npc_instance_id):
	var detection_flag = true
	if npc_id == TEACHER and current_state != RUN:
		detection_flag = false
		
	if cooldown_timer.time_left > 0:
		detection_flag = false
		
	if detection_flag:
		
		var player_pos = self.global_position
		var npc_pos = instance_from_id(npc_instance_id).global_position
		var npc_pos_relative = (npc_pos - player_pos).normalized()
		var npc_direction = Vector2(int(round(npc_pos_relative.x)), int(round(npc_pos_relative.y)))
		
		if npc_direction.x != 0 and npc_direction.y != 0:
			npc_direction = Vector2(0, npc_direction.y)
		
		current_state = FREEZE
		play_idle_animation(npc_direction)
		emit_signal("player_frozen", npc_instance_id)
		if freeze_timer.time_left == 0:
			clash_sound.play()
			freeze_timer.start()
		
func handle_stall_indication(id):
	if not id in current_inventory  and current_direction == Vector2.UP:
		food_indicator.visible = true
		if Input.is_action_just_pressed("ui_select"):
			add_item(id)
	else:
		food_indicator.visible = false
		
func play_idle_animation(direction : Vector2):
	$AnimatedSprite.speed_scale = 1
	if direction == Vector2.UP:
		$AnimatedSprite.play("idle_up")
	elif direction == Vector2.DOWN:
		$AnimatedSprite.play("idle_down")
	elif direction == Vector2.LEFT:
		$AnimatedSprite.play("idle_left")
	elif direction == Vector2.RIGHT:
		$AnimatedSprite.play("idle_right")
	
func play_walk_animation(direction : Vector2):
	if current_state == RUN:
		$AnimatedSprite.speed_scale = 2
	elif current_state == WALK:
		$AnimatedSprite.speed_scale = 1
		
	if direction == Vector2.UP:
		$AnimatedSprite.play("walk_up")
	elif direction == Vector2.DOWN:
		$AnimatedSprite.play("walk_down")
	elif direction == Vector2.LEFT:
		$AnimatedSprite.play("walk_left")
	elif direction == Vector2.RIGHT:
		$AnimatedSprite.play("walk_right")
	
	
func add_item(item_id):
	if not item_id in mission:
		print("item not required")
	else:
		current_inventory.append(item_id)
		current_inventory.sort()
		mission.sort()
		coin_sound.play()
		if (current_inventory == mission):
			emit_signal("all_items_obtained")
		emit_signal("item_added", item_id)
	

func _on_FreezeTimer_timeout():
	current_state = IDLE
	emit_signal("freeze_finished")
	if cooldown_timer.time_left == 0:
		cooldown_timer.start()


func _on_ColaStall_enter_stall(id):
	handle_stall_indication(id)

func _on_DangoStall_enter_stall(id):
	handle_stall_indication(id)

func _on_HotdogStall_enter_stall(id):
	handle_stall_indication(id)
	
func _on_OnigiriStall_enter_stall(id):
	handle_stall_indication(id)

func _on_FoodBar_obtain_mission(mission_array):
	mission = mission_array


func _on_ColaStall_exit_stall():
	food_indicator.visible = false

func _on_DangoStall_exit_stall():
	food_indicator.visible = false

func _on_HotdogStall_exit_stall():
	food_indicator.visible = false

func _on_OnigiriStall_exit_stall():
	food_indicator.visible = false
