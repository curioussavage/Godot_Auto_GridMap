extends Popup

onready var editor = get_node("/root/Editor")
onready var accept_btn = find_node("accept_btn")
onready var name_text = find_node("level_name")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	accept_btn.connect("pressed", self, "on_accept")
	yield(get_tree().create_timer(1), "timeout")
	if not editor.level_name:
		popup_centered()

func on_accept():
	if not name_text.text:
		return
	# TODO validate name is not taken
	editor.new_level(name_text.text)
	hide()
