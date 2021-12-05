extends Node2D

onready var puzzle = preload("res://Scenes/Puzzle.tscn")
var puzzle_exists = false

# Resource Variables
var pollution = 500
var solar = 0
var trees = 0
var water = 0
var bees = 0
var amount = 10
var bomb_amount = 50


func _ready():
	$GUI.update_gui(pollution, solar, trees, water, bees)


func _process(delta):
	update_environment()


func update_environment():
	# Grow solarpunk landscape
	if pollution <= 300:
		$Environment/Smog1.emitting = false
		$Environment/Smog2.emitting = false
		$Environment/Background_Dead.visible = false
		$Environment/Ground_Dead.visible = false
		$Environment/Foreground_Dead.visible = false
		$Environment/Background.visible = true
		$Environment/Ground.visible = true
		$Environment/Foreground.visible = true
	if trees > 300 && pollution <= 200:
		$Environment/Trees.visible = true
		$Environment/Factory_Dead.visible = false
	if water > 200:
		$Environment/Road_Dead.visible = false
		$Environment/Mountains_Dead.visible = false
		$Environment/Road.visible = true
		$Environment/Mountains.visible = true
	if bees > 200:
		$Environment/Apartment_Dead.visible = false
		$Environment/Apartment.visible = true
	if solar > 200 && water >= 300: 
		$Environment/City_Dead.visible = false
		$Environment/City.visible = true
	# Revert to desolation
	if pollution > 400:
		$Environment/Smog1.emitting = true
		$Environment/Smog2.emitting = true
		$Environment/Background_Dead.visible = true
		$Environment/Ground_Dead.visible = true
		$Environment/Foreground_Dead.visible = true
		$Environment/Background.visible = false
		$Environment/Ground.visible = false
		$Environment/Foreground.visible = false
	if trees < 100 && pollution > 300:
		$Environment/Trees.visible = false
		$Environment/Factory_Dead.visible = true
	if water < 100:
		$Environment/Road_Dead.visible = true
		$Environment/Mountains_Dead.visible = true
		$Environment/Road.visible = false
		$Environment/Mountains.visible = false
	if bees < 100:
		$Environment/Apartment_Dead.visible = true
		$Environment/Apartment.visible = false
	if solar < 100 && water < 200: 
		$Environment/City_Dead.visible = true
		$Environment/City.visible = false


func update_resources(type):
	if type == "skull" && pollution - amount >= 0:
		pollution -= amount
	if type == "sun":
		solar += amount
	if type == "tree":
		trees += amount
	if type == "water":
		water += amount
	if type == "bee":
		bees += amount
	$GUI.update_gui(pollution, solar, trees, water, bees)


func bomb_score(success, type):
	if success:
		if type == "skull":
			pollution -= bomb_amount
		if type == "sun":
			solar += bomb_amount
		if type == "tree":
			trees += bomb_amount
		if type == "water":
			water += bomb_amount
		if type == "bee":
			bees += bomb_amount
	else:
		if type == "skull":
			pollution += bomb_amount
		if type == "sun":
			solar -= bomb_amount
		if type == "tree":
			trees -= bomb_amount
		if type == "water":
			water -= bomb_amount
		if type == "bee":
			bees -= bomb_amount
	$GUI.update_gui(pollution, solar, trees, water, bees)


func open_puzzle():
	if !puzzle_exists:
		var new_puzzle = puzzle.instance()
		add_child(new_puzzle)
		puzzle_exists = true
		$BombWindow.visible = true
		$BombWindow.set_new_bomb()
	else:
		if $BombWindow.state == $BombWindow.inactive:
			get_node("Puzzle").queue_free()
			puzzle_exists = false
			$BombWindow.visible = false
			$BombWindow.deactivate()
		else:
			$Warning.visible = true


func _on_pollution_timer_timeout():
	pollution += amount
	$GUI.update_gui(pollution, solar, trees, water, bees)


func _on_resource_timer_timeout():
	if solar - amount > 0:
		solar -= amount
	if trees - amount > 0:
		trees -= amount
	if water - amount > 0:
		water -= amount
	if bees - amount > 0:
		bees  -= amount
	$GUI.update_gui(pollution, solar, trees, water, bees)


func _on_puzzle_button_pressed():
	open_puzzle()


# Mouse-hover upgrade text
func _on_ApartmentZone_mouse_entered():
	if !puzzle_exists:
		$ApartmentZone/Panel.visible = true
		$ApartmentZone/RichTextLabel.visible = true


func _on_ApartmentZone_mouse_exited():
	$ApartmentZone/Panel.visible = false
	$ApartmentZone/RichTextLabel.visible = false


func _on_FactoryZone_mouse_entered():
	if !puzzle_exists:
		$FactoryZone/Panel.visible = true
		$FactoryZone/RichTextLabel.visible = true


func _on_FactoryZone_mouse_exited():
	$FactoryZone/Panel.visible = false
	$FactoryZone/RichTextLabel.visible = false


func _on_CityZone_mouse_entered():
	if !puzzle_exists:
		$CityZone/Panel.visible = true
		$CityZone/RichTextLabel.visible = true


func _on_CityZone_mouse_exited():
	$CityZone/Panel.visible = false
	$CityZone/RichTextLabel.visible = false


func _on_WarningOkay_pressed():
	pollution += 20
	solar -= 20
	trees -= 20
	water -= 20
	bees -= 20
	$GUI.update_gui(pollution, solar, trees, water, bees)
	get_node("Puzzle").queue_free()
	puzzle_exists = false
	$BombWindow.visible = false
	$BombWindow.deactivate()
	$Warning.visible = false


func _on_WarningCancel_pressed():
	$Warning.visible = false
