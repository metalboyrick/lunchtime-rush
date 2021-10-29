extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# game time in seconds
export var GAME_TIME = 10

onready var game_timer = get_node("GameTimer")
onready var timer_text = get_node("HUD/TimerSection/TimeLabel")
onready var pause_screen = get_node("HUD/PauseScreen")
onready var win_screen = get_node("HUD/WinScreen")
onready var lose_screen = get_node("HUD/LoseScreen")
onready var radar = get_node("HUD/Radar")
onready var timer_section = get_node("HUD/TimerSection")
onready var food_bar = get_node("HUD/FoodBar")
onready var goal = get_node("Goal")
onready var music = get_node("BgMusic")
onready var flag_anim = get_node("FinishFlag/AnimationPlayer")

var is_item_complete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	flag_anim.play("New Anim")
	game_timer.wait_time = GAME_TIME
	timer_text.text = String(GAME_TIME).pad_decimals(2)
	music.play()
	game_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer_text.text = String(game_timer.time_left).pad_decimals(2)
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			music.stop()
			get_tree().paused = true
			pause_screen.show()
			
		if event.scancode == KEY_TAB:
			if event.pressed:
				radar.visible = true
				timer_section.visible = false
				food_bar.visible = false
				
			if not event.pressed:
				radar.visible = false
				timer_section.visible = true
				food_bar.visible = true

func _on_GameTimer_timeout():
	get_tree().paused = true
	lose_screen.show()


func _on_ContinueButton_pressed():
	music.play()
	get_tree().paused = false
	pause_screen.hide()


func _on_QuitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/main.tscn")

func _on_Player_all_items_obtained():
	print("got all items")
	is_item_complete = true


func _on_Goal_body_entered(body):
	if body.name == "Player" and is_item_complete:
		win_screen.show()


func _on_NextButton_pressed():
	get_tree().change_scene("res://scenes/main.tscn")


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
