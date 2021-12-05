extends Node2D

export (String) var type

var movement_tween
var matched = false
var main


# Called when the node enters the scene tree for the first time.
func _ready():
	movement_tween = $Tween
	main = get_tree().get_root().get_node("Main")


func move(target):
	movement_tween.interpolate_property(self, "position", position, target, 
									.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	movement_tween.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func die():
	var sprite = get_node("Sprite")
	sprite.modulate = Color(2.5, 2.5, 2.5, 0.5)
	main.update_resources(type)


