extends Control

onready var main = get_parent()

func update_gui(pollution, solar, trees, water, bees):
	$HBoxContainer/Pollution/PollutionNumber.text = str(pollution)
	$HBoxContainer/Solar/SolarNumber.text = str(solar)
	$HBoxContainer/Trees/TreeNumber.text = str(trees)
	$HBoxContainer/Water/WaterNumber.text = str(water)
	$HBoxContainer/Bees/BeesNumber.text = str(bees)

func _on_puzzle_button_pressed():
	main.open_puzzle()
