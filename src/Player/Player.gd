tool
class_name Player
extends KinematicBody
# Helper class for the Player scene's scripts to be able to have access to the
# camera and its orientation.

onready var camera: CameraRig = $CameraRig
onready var skin: Mannequiny = $Mannequiny
onready var state_machine: StateMachine = $StateMachine

var is_editing = false

func _get_configuration_warning() -> String:
	return "Missing camera node" if not camera else ""


func _input(event: InputEvent) -> void:

	if event.is_action_pressed("toggle_edit"):
		is_editing = not is_editing
		var cursor = camera.editor_target.get_child(0)
		if is_editing:
			cursor.visible = true
		else:
			cursor.visible = false
			
		print("is editing ", is_editing)
