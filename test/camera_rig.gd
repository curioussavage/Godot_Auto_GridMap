extends Spatial

var gimbal_target: Node

onready var editor_target = $editor_target 

export var mouseSense := 0.005
export var speed := 20.0
export var rotate_speed := PI / 2
var is_y_inverted = false

const ANGLE_X_MIN := -PI / 4
const ANGLE_X_MAX := PI / 3

export var sensitivity_gamepad := Vector2(2.5, 2.5)

static func get_look_direction() -> Vector2:
	return Vector2(Input.get_action_strength("look_right") - Input.get_action_strength("look_left"), Input.get_action_strength("look_up") - Input.get_action_strength("look_down")).normalized()
	
func update_rotation(node, offset: Vector2, delta) -> void:
#	node.rotation.y -= offset.x
#	node.rotation.x += offset.y * -1.0 if is_y_inverted else offset.y
#	node.rotation.x = clamp(node.rotation.x, ANGLE_X_MIN, ANGLE_X_MAX)
#	node.rotation.z = 0
	rotate_object_local(Vector3.UP, offset.y * speed * delta)

func _process(delta):
#	http://kidscancode.org/godot_recipes/3d/camera_gimbal/
	var y_rotation = 0
	if Input.is_action_pressed("look_right"):
		y_rotation += 1
	if Input.is_action_pressed("look_left"):
		y_rotation += -1
	var x_rotation = 0
	if Input.is_action_pressed("look_up"):
		x_rotation += -1
	if Input.is_action_pressed("look_down"):
		x_rotation += 1
#	var look_direction := get_look_direction()
#	if look_direction.length() > 0:
	rotate_object_local(Vector3.RIGHT, y_rotation * rotate_speed * delta)
	get_child(0).rotate_object_local(Vector3.UP, x_rotation * rotate_speed * delta)
	get_child(0).rotation.x = clamp($xGimbal.rotation.x, -1.4, -0.01)
#		update_rotation(self, Vector2(0, look_direction.y) * sensitivity_gamepad * delta)
#		update_rotation(get_child(0), Vector2(look_direction.x, 0) * sensitivity_gamepad * delta)
		
#	if gimbal_target:
#		self.global_transform.origin = (
#			self.gimbal_target.global_transform.origin
#		)
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var dir := Vector3.ZERO
#	$MeshInstance.rotation_degrees.x = clamp($MeshInstance.rotation_degrees.x, -80,80 )

#	print($MeshInstance.transform.basisy)
	if Input.is_action_pressed("move_front"):
		dir += -global_transform.basis[2]
#		dir.y -= $MeshInstance.transform.basis.y.z
	if Input.is_action_pressed("move_back"):
		dir += global_transform.basis[2]
#		dir.y += $MeshInstance.transform.basis.y.z
	if Input.is_action_pressed("move_left"):
		dir -= global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += global_transform.basis.x
		
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		if Input.is_action_pressed("move_up"):
			dir += global_transform.basis.y

		if Input.is_action_pressed("move_down"):
			dir -= global_transform.basis.y
	else:
		dir.y = 0
	
	dir = dir.normalized() * speed * delta
	
	translate(dir)
#	move_and_slide(dir, Vector3.UP)
