extends Node2D

# State Machine
enum {wait, move}
var state

# Grid Size
export (int) var height = 8
export (int) var width = 9
export (int) var x_start = -64
export (int) var y_start = 48
export (int) var offset = 16
export (int) var y_offset = 2

var possible_pieces = [
	preload("res://Scenes/BeePiece.tscn"),
	preload("res://Scenes/SkullPiece.tscn"),
	preload("res://Scenes/SunPiece.tscn"),
	preload("res://Scenes/TreePiece.tscn"),
	preload("res://Scenes/WaterPiece.tscn"),
	preload("res://Scenes/TimePiece.tscn")
]

# Current pieces
var all_pieces = []

# Swapback pieces
var piece_one = null
var piece_two = null
var last_place = Vector2.ZERO
var last_direction = Vector2.ZERO
var move_checked = false

# Touch variable
var first_touch = Vector2.ZERO
var final_touch = Vector2.ZERO
var controlling = false

# Reference Nodes
var main
var bomb

func _ready():
	state = move
	randomize()
	all_pieces = create_2D_array()
	spawn_pieces()
	main = get_parent().get_parent()
	bomb = main.get_node("BombWindow")


func _process(delta):
	if state == move:
		touch_input()


func create_2D_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func spawn_pieces():
	for i in width:
		for j in height:
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			var loops = 0;
			while(match_at(i, j, piece.type) && loops < 100):
				rand = floor(rand_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(i, j)
			all_pieces[i][j] = piece


func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)


func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)


func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false


func match_at(column, row, type):
	if column > 1:
		if all_pieces[column - 1][row] != null && all_pieces[column - 2][row] != null:
			if all_pieces[column - 1][row].type == type && all_pieces[column -2][row].type == type:
				return true
	if row > 1:
		if all_pieces[column][row - 1] != null && all_pieces[column][row - 2] != null:
			if all_pieces[column][row - 1].type == type && all_pieces[column][row - 2].type == type:
				return true


func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var second_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && second_piece != null:
		store_info(first_piece, second_piece, Vector2(column, row), direction)
		state = wait
		all_pieces[column][row] = second_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		second_piece.move(grid_to_pixel(column, row))
		if !move_checked:
			find_matches()


func store_info(first_piece, second_piece, place, direction):
	piece_one = first_piece
	piece_two = second_piece
	last_place = place
	last_direction = direction


func swap_back():
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = move
	move_checked = false


func touch_difference(first_grid, second_grid):
	var difference = second_grid - first_grid
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(first_grid.x, first_grid.y, Vector2(1,0))
		elif difference.x < 0:
			swap_pieces(first_grid.x, first_grid.y, Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(first_grid.x, first_grid.y, Vector2(0,1))
		elif difference.y < 0:
			swap_pieces(first_grid.x, first_grid.y, Vector2(0,-1))


func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)) && controlling:
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			touch_difference(first_touch, final_touch)
		controlling = false


func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_type = all_pieces[i][j].type
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if  all_pieces[i - 1][j].type == current_type && all_pieces[i + 1][j].type == current_type:
							all_pieces[i - 1][j].matched = true
							all_pieces[i - 1][j].die()
							all_pieces[i][j].matched = true
							all_pieces[i][j].die()
							all_pieces[i + 1][j].matched = true
							all_pieces[i + 1][j].die()
							bomb.check_match(current_type)
							
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].type == current_type && all_pieces[i][j + 1].type == current_type:
							all_pieces[i][j - 1].matched = true
							all_pieces[i][j - 1].die()
							all_pieces[i][j].matched = true
							all_pieces[i][j].die()
							all_pieces[i][j + 1].matched = true
							all_pieces[i][j + 1].die()
							bomb.check_match(current_type)
	get_parent().get_node("destroy_timer").start()


func destroy_matched():
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					was_matched = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					get_parent().get_node("PopSound").play()
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()


func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_timer").start()


func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = floor(rand_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instance()
				var loops = 0;
				while(match_at(i, j, piece.type) && loops < 100):
					rand = floor(rand_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instance()
				add_child(piece)
				piece.position = grid_to_pixel(i, j - y_offset)
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
	after_refill()


func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].type):
					find_matches()
					get_parent().get_node("destroy_timer").start()
					return
	state = move
	move_checked = false
	bomb.handle_turn()
	

func _on_destroy_timer_timeout():
	destroy_matched()


func _on_collapse_timer_timeout():
	collapse_columns()


func _on_refill_timer_timeout():
	refill_columns()


func _on_QuitButton_pressed():
	# Should be main
	get_parent().get_parent().puzzle_exists = false
	get_parent().queue_free()
