extends Node

onready var player: Player = $"../Player"
onready var grass: AutoGridMap = $"../GridMap_grass"
onready var castle: AutoGridMap = $"../GridMap_castle"

var current_cell = null
var is_editing = false
var selected = null

func _ready():
	selected = grass
		# do editing stuff
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_edit"):
		is_editing = not is_editing
		var cursor = selected.get_child(1)
		if is_editing:
			cursor.visible = true
		else:
			cursor.visible = false
		if is_editing:
			if selected == grass:
				selected = castle
			else:
				selected = grass
			
		print("is editing ", is_editing)
		
	if event.is_action_pressed("fire") and is_editing:
		var tile = selected.get_cell_item(current_cell.x, current_cell.y, current_cell.z)
		var new_cell = 0
		if tile == 0:
			new_cell = -1
		selected.set_cell_item(current_cell.x, current_cell.y, current_cell.z, new_cell)
		
#		update_cell(current_cell.x, current_cell.y, current_cell.z)```~~~~~~~~~
		


func _process(delta):
	if is_editing:
		var point = player.camera.editor_target.global_transform.origin
#		var point = player.camera.aim_ray.get_collision_point()
		var cell = selected.world_to_map(grass.to_local(point))
		var item = selected.get_main_cell_item(cell.x, cell.y, cell.z)
		var cursor = selected.get_child(1)

		if cell != current_cell:
			var cursor_pos = selected.map_to_world(cell.x, cell.y, cell.z)
			cursor.global_transform.origin = cursor_pos

			cursor.mesh.size = selected.sub_gridmap.cell_size * 1
			current_cell = cell
			return
#			print("item is ", item)
			
#			grass.set_cell_item(cell.x, cell.y, cell.z, 0)
#			grass.update_cell(cell.x, cell.y, cell.z)
#			if current_cell:
#				grass.update_cell(current_cell.x, current_cell.y, current_cell.z)
#			current_cell = cell
#			grass.clear()
			
#		var tile = grass.get_cell_item(cell.x, cell.y, cell.z)
