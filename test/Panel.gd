extends PanelContainer

onready var save_btn = find_node("save_btn")
onready var exit_btn = find_node("exit_btn")

onready var add_layer_btn = find_node("layers_btn")
onready var add_layer_input = find_node("layer_name_input")
onready var layers_list = find_node("layers_list")
onready var sky_btn = find_node("sky_btn")
onready var editor = get_node("/root/Editor")

# Called when the node enters the scene tree for the first time.
func _ready():
	sky_btn.connect("item_selected", self, "on_sky_selected")
	save_btn.connect("pressed", self, "on_save_pressed")
	exit_btn.connect("pressed", self, "on_exit_pressed")
	add_layer_btn.connect("pressed", self, "on_add_layer_pressed")
	editor.connect("layer_added", self, "on_layer_added")
	
	
func on_sky_selected(idx):
	var container = editor.get_node("skyContainer")
	var current = container.get_child(0)
	current.queue_free()
	yield(current, "tree_exited")
	var scene = load("res://addons/AllSkyFree/AllSkyFree_%s.tscn" % sky_btn.text)
	var instance = scene.instance()
	container.add_child(instance)

func on_save_pressed():
	editor.save()
	print("save")
	
func on_exit_pressed():
	print("exit")

func on_add_layer_pressed():
	name = add_layer_input.text
	if name:
		editor.add_layer(name)
	add_layer_input.text = ""
#	print("clicked")
	
func on_layer_added(layer_name):
	print("layer added")
	layers_list.clear()
	for layer in editor.layers:
		layers_list.add_item(layer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
