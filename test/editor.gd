extends Spatial

onready var player: Node = $editorPlayer
#onready var grass: AutoGridMap = $level/gridmaps/grass
#onready var castle: AutoGridMap = $level/gridmaps/castle



signal layer_added(name)

var current_cell = null
var is_editing = false
var selected = null
var show_other_maps = true

const MAX_CURSOR_SIZE = 20
var cursor_height = 1
var cursor_width = 1

var maps = []
var selected_index = 0
var level_name = ""

var point_meshlib = preload("res://tileset/point_meshlib.tres")
var grass_meshlib = preload("res://tileset/grass.tres")
var castle_meshlib = preload("res://tileset/dungeon.tres")
const AutoGridMap = preload("res://Auto_GridMap.gd")

var base_level = preload("res://test/base_level.tscn")
var gridmap_cursor = preload("res://test/cursor.tscn")

onready var editorLabel: Label = find_node("editorModeLabel")
onready var levelLabel: Label = find_node("nameLabel")

var level: Node = null

func set_level_label():
	levelLabel.text = "editing: %s" % level_name

func new_level(name):
	print(name)
	level_name = name
	set_level_label()
	var instance = base_level.instance()
	add_child(instance)
	level = instance
	# TODO set skybox default

func load_level(name):
	print("loading")
	# TODO should reset state if we allow moving between levels
	level_name = name
	var packed_scene = load("res://levels/%s.tscn" % name)
	var instance = packed_scene.instance()
	instance.connect("ready", self, "_on_level_loaded")
	self.add_child(instance)
	level = instance
	set_level_label()
#	yield(instance, "ready")
#	self.maps = $level/gridmaps.get_children()
#	selected = maps[0]
#	print("level loaded")
#	find_node("level_name_popup").hide()
	
func _on_level_loaded():
	self.maps = $level/gridmaps.get_children()
	if len(maps):
		for map in maps:
			var result = map.get_used_cells()
			var subcells = map.sub_gridmap.get_used_cells()
			print("main cells ", len(result), "sub cells: ", len(subcells))
		selected = maps[0]
		_set_label()
		emit_signal("layer_added", maps[0].name)
	print("level loaded")
	find_node("level_name_popup").hide()
#func _ready():
#	var obj = Bullet.new()
func add_layer(name):
	
	var newMap = AutoGridMap.new()
	newMap.mesh_library = point_meshlib
	newMap.mesh_library_3d = grass_meshlib
	newMap.name = name
	var cursor = gridmap_cursor.instance()
	$level/gridmaps.add_child(newMap)
	# may have to yield for a signal from newMap before adding children
	newMap.add_child(cursor)
	cursor.set_owner($level)
	newMap.set_owner($level)
	
	maps.append(newMap)
	if not selected:
		selected = newMap
		_set_label()
	emit_signal("layer_added", name)
	# TODO add to tree

func save():
	if not level_name:
		print("can't save") #TODO show error
		return
	var scene = PackedScene.new()
	if len(maps):
		for map in maps:
			map.sub_gridmap.set_owner($level)
	# Only `node` and `rigid` are now packed.
	var result = scene.pack(self.get_node("level"))
#	var result = self.get_node("level")
	if result == OK:
		print("level name ", level_name)
		var error = ResourceSaver.save("res://levels/%s.tscn" % level_name, scene)  # Or "user://..."
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
#	ResourceFormatSaver.recognize()
	# then close or alternatively go back to menu

func _cycle_map():
	if len(maps) == 0:
		return
	var next_index = (selected_index + 1) % len(maps)
	selected_index = next_index
	selected = maps[selected_index]
	print("selected: %s" % selected.name)
	
func _set_label():
	editorLabel.text = "layer: %s" % selected.name
	
func _enable_editing():
	if not selected:
		return
	editorLabel.visible = true
	selected.find_node("cursor").visible = true
	_update_cursor()

func _disable_editing():
	if not selected:
		return
	editorLabel.visible = false
	selected.find_node("cursor").visible = false


func _hide_maps():
	for map in maps:
		if map != selected:
			map.sub_gridmap.visible = !map.sub_gridmap.visible
		else:
			map.sub_gridmap.visible = true

func _show_maps():
	for map in maps:
		if map != selected:
			map.sub_gridmap.visible = !map.sub_gridmap.visible

func _refresh_map_visibility():
	if show_other_maps:
		_hide_maps()
	else:
		_show_maps()

func _toggle_hide_maps():
	show_other_maps = !show_other_maps
	_refresh_map_visibility()

func _ready():
	pass
#	selected = grass

	# TODO remove these after removing the premade maps
#	maps.append(grass)
#	maps.append(castle)
#	_set_label()
		# do editing stuff

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_edit"):
		is_editing = not is_editing
		if is_editing:
			_enable_editing()
		else:
			_disable_editing()
		print("is editing ", is_editing)
	
	if not is_editing:
		return

	if event.is_action_pressed("toggle_visibility"):
		_toggle_hide_maps()
		
	if event.is_action_pressed("interact"):
		_disable_editing()
		print("call cycle map")
		_cycle_map()
		_set_label()
		current_cell = null
		_enable_editing()
		
		
	if event.is_action_pressed("increase_cursor_height"):
		if cursor_height < MAX_CURSOR_SIZE:
#			player.camera.transform.origin.y += selected.sub_gridmap.cell_size.y
#			player.camera.transform.origin.z += selected.sub_gridmap.cell_size.y * 1.5
			cursor_height += 1
			print("updating cursor height")
			_update_cursor(true)
	if event.is_action_pressed("decrease_cursor_height"):
		if cursor_height > 1:
#			player.camera.transform.origin.y -= selected.sub_gridmap.cell_size.y
#			player.camera.transform.origin.z -= selected.sub_gridmap.cell_size.y * 1.5
			cursor_height -= 1
			_update_cursor(true)
	if event.is_action_pressed("increase_cursor_width"):
		if cursor_width < MAX_CURSOR_SIZE:
#			player.camera.transform.origin.x -= selected.sub_gridmap.cell_size.x
			cursor_width += 1
			_update_cursor(true)
	if event.is_action_pressed("decrease_cursor_width"):
		if cursor_width > 1:
#			player.camera.transform.origin.x += selected.sub_gridmap.cell_size.x
			cursor_width -= 1
			_update_cursor(true)

#	if event.is_action_pressed("fire"):
#		_change_cell(0)
#		update_cell(current_cell.x, current_cell.y, current_cell.z)```~~~~~~~~~

#	if event.is_action_pressed("remove"):
#		_change_cell(-1)

func _change_cell(val):
#	print("cursor_width")
#	print(cursor_width)
#	print("cursor height")
#	print(cursor_height)
#	var tile = selected.get_cell_item(current_cell.x, current_cell.y, current_cell.z)
	for y in range(0, cursor_height):
		for x in range(0, cursor_width):
			var tile = selected.get_cell_item(current_cell.x + x, current_cell.y + y, current_cell.z)
			if tile != val:
				selected.set_cell_item(current_cell.x + x, current_cell.y + y, current_cell.z, val)
				


func _update_cursor(force_refresh=false):
	if not selected:
		return
	var point = player.editor_target.global_transform.origin
#		var point = player.camera.aim_ray.get_collision_point()

	var cell = selected.world_to_map(selected.to_local(point))
	var item = selected.get_main_cell_item(cell.x, cell.y, cell.z)
	var cursor = selected.find_node("cursor")

	if cell != current_cell or force_refresh:
		var cell_size = selected.sub_gridmap.cell_size 
#		var offset = Vector3((cursor_width * cell_size.x) / 2 - cell_size.x, (cursor_height * cell_size.y) / 2 - cell_size.z * .5, 0)
#		var offset = Vector3((cursor_width * cell_size.x) / 2 - cell_size.x, (cursor_height * cell_size.y) / 2 - cell_size.z, 0)
		var offset = Vector3(cell_size.x * (cursor_width - 1), cell_size.y * (cursor_height - 1), 0)
		var cursor_pos = selected.map_to_world(cell.x, cell.y, cell.z)
		cursor.global_transform.origin = cursor_pos + offset
		var extra_cursor = Vector3(cursor_width, cursor_height, 1) * 1.5
		cursor.mesh.size = selected.sub_gridmap.cell_size * extra_cursor
		current_cell = cell

var speed : float

func _update_cam_angle():
	if not selected:
		return
	var cam = player.camera
	var cursor = selected.find_node("cursor")
	
	

#	var to: Vector3 = cursor.global_transform.origin - cam.global_transform.origin
#	var new_transform = Transform(Basis(to, Vector3(0, 1, 0)), cam.global_transform.origin)
#	new_transform.looking_at(cursor.global_transform.origin - cam.global_transform.origin, Vector3(0, 1, 0))
	var new_transform = cam.global_transform.looking_at(cursor.global_transform.origin, Vector3(0, 1, 0))
#	print(cam.global_transform)
	var interpolated = cam.global_transform.interpolate_with(new_transform, .5)
#	cam.set_global_transform(interpolated)
#	player.cameraTween.interpolate_property(cam, "global_transform/basis", cam.global_transform, interpolated, .2)
#	player.cameraTween.start()
#	print(cam.global_transform)
#	cam.look_at(cursor.global_transform.origin, Vector3(0, 1, 0))

func _process(delta):
	if is_editing:
		_update_cam_angle()
#	if is_editing:
#		var cam = player.camera
#		var cursor = selected.get_child(1)
#		cam.look_at(cursor.global_transform.origin, Vector3(0, 1, 0))
		
		
	# trying to point camera towards cursor
#	if is_editing:
#		var cam = player.camera
#		var cursor = selected.get_child(1)
#		cam.look_at(cursor.global_transform.origin, Vector3(0, 1, 0))
#		cam.global_transform.origin = lerp(cam.global_transform.origin, cursor.global_transform.origin, delta*20)
#		var current_rotation = Quat(cam.global_transform.basis)
#		var next_rotation = current_rotation.slerp(Quat(cursor.global_transform.basis), delta*20)
#		cam.global_transform.basis = Basis(next_rotation)
#		cam.global_transform.basis = cam.global_transform.basis + cursor.global_transform.basis
	
	if is_editing:
		if Input.is_action_pressed("fire"):
			_change_cell(0)
		if Input.is_action_pressed("remove"):
			_change_cell(-1)
		_update_cursor()

