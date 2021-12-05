extends Node2D

export (int) var bomb_timer = 3
var type = ["skull", "sun", "tree", "water", "bee"]
var sprite

var current_turn
var current_type
enum {active, inactive}
var state


func _ready():
	randomize()
	sprite = $AnimatedSprite
	state = inactive


func check_for_new_bomb():
	if state == inactive:
		# Pick a number between 0 and 2
		var rand_num = randi() % 3
		if rand_num == 0:
			set_new_bomb()


func set_new_bomb():
	var rand_num = floor(rand_range(0, type.size()))
	current_type = type[rand_num]
	sprite.frame = rand_num
	current_turn = bomb_timer
	$TurnCount.set_text(str(current_turn))
	$TurnCount.visible = true
	$Success.visible = false
	$Failure.visible = false
	state = active
	$AudioNotify.play()


func deactivate():
	state = inactive
	current_turn = 0


func update():
	$TurnCount.set_text(str(current_turn))


func handle_turn():
	if state == inactive:
		check_for_new_bomb()
	elif state == active:
		if current_turn == 3:
			current_turn -= 1
		elif current_turn == 2:
			current_turn -= 1
		elif current_turn == 1:
			current_turn -= 1
			boom()
		update()
	


func check_match(match_type):
	if state == active:
		if match_type == current_type:
			$TurnCount.visible = false
			$Success.visible = true
			$AudioSuccess.play()
			get_parent().bomb_score(true, current_type)
			state = inactive

func boom():
	$TurnCount.visible = false
	$Failure.visible = true
	get_parent().bomb_score(false, current_type)
	$AudioFailure.play()
	state = inactive
