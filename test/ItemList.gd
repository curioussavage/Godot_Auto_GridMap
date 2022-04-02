extends ItemList


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func dir_contents(path):
	var filenames = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				filenames.append(file_name)
#			else:
#				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return filenames

func load_level(idx):
	get_tree().root.get_node("Editor").load_level(get_item_text(idx))
# Called when the node enters the scene tree for the first time.

func _ready():
	connect("item_activated", self, "load_level")
	var levels = dir_contents("res://levels")
	for level in levels:
		add_item(level)
