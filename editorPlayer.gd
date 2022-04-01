extends KinematicBody


onready var editor_target = $editor_target
onready var camera = $Spatial
onready var cameraTween = $Spatial/Tween

export var mouseSense := 0.005
export var speed := 30.0
var is_y_inverted = false

const ANGLE_X_MIN := -PI / 4
const ANGLE_X_MAX := PI / 3

export var sensitivity_gamepad := Vector2(2.5, 2.5)


#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseMotion:
##		$MeshInstance.rotate_x( event.relative.y * mouseSense )
#		rotate_y( -event.relative.x * mouseSense )
#		print(event.relative)

static func get_look_direction() -> Vector2:
	return Vector2(Input.get_action_strength("look_right") - Input.get_action_strength("look_left"), Input.get_action_strength("look_up") - Input.get_action_strength("look_down")).normalized()
	
func update_rotation(offset: Vector2) -> void:
	rotation.y -= offset.x
	rotation.x += offset.y * -1.0 if is_y_inverted else offset.y
	rotation.x = clamp(rotation.x, ANGLE_X_MIN, ANGLE_X_MAX)
	rotation.z = 0
	
func _process(delta):
	var look_direction := get_look_direction()
	if look_direction.length() > 0:
		update_rotation(look_direction * sensitivity_gamepad * delta)

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
	
	dir = dir.normalized() * speed
	
	move_and_slide(dir, Vector3.UP)
