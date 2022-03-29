extends Node

onready var player: Player = $"../Player"
onready var grass: AutoGridMap = $"../GridMap_grass"
onready var castle: AutoGridMap = $"../GridMap_castle"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var current_cell = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
#		print(tile)
		
		# do editing stuff
		
func _input(event):
	if event.is_action_pressed("fire") and player.is_editing:
		grass.set_cell_item(current_cell.x, current_cell.y, current_cell.z, 0)
		grass.update_cell(current_cell.x, current_cell.y, current_cell.z)
		
		
func _process(delta):
	if player.is_editing:
		var point = player.camera.editor_target.global_transform.origin
#		var point = player.camera.aim_ray.get_collision_point()
		var cell = grass.world_to_map(grass.to_local(point))
		var item = grass.get_main_cell_item(cell.x, cell.y, cell.z)

		var cursor = player.camera.editor_target.get_child(0)

		if cell != current_cell:
			var cursor_pos = grass.map_to_world(cell.x, cell.y, cell.z)
			cursor.global_transform.origin = cursor_pos
			cursor.mesh.size = grass.cell_size
			current_cell = cell
			return
#			print("item is ", item)
			
			grass.set_cell_item(cell.x, cell.y, cell.z, 0)
			grass.update_cell(cell.x, cell.y, cell.z)
#			if current_cell:
#				grass.update_cell(current_cell.x, current_cell.y, current_cell.z)
			current_cell = cell
#			grass.clear()
			
#		var tile = grass.get_cell_item(cell.x, cell.y, cell.z)
