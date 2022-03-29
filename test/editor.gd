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
		
func _process(delta):
	if player.is_editing:
		var point = player.camera.editor_target.global_transform.origin
#		var point = player.camera.aim_ray.get_collision_point()
		var cell = grass.world_to_map(grass.to_local(point))
		var item = grass.get_main_cell_item(cell.x, cell.y, cell.z)

		if cell != current_cell:
			print("item is ", item)
			grass.set_cell_item(cell.x, cell.y, cell.z, 0)
			grass.update_cell(cell.x, cell.y, cell.z)
#			if current_cell:
#				grass.update_cell(current_cell.x, current_cell.y, current_cell.z)
			current_cell = cell
#			grass.clear()
			
#		var tile = grass.get_cell_item(cell.x, cell.y, cell.z)
