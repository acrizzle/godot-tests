extends KinematicBody


const FLOOR = Vector3(0, 1, 0)
const HALF_PI = PI * .5

export var move_dead_zone = Vector2(.013, .013)
export var speed = 60

var aerial_movement = Vector3()
var gravity = Vector3()
var strafing = Vector3()
var floor_normal = Vector3(0, 1, 0)

var on_ground = false


func _physics_process(delta):
	# Read input.
	# -- Gamepad
	var walk = Vector3(
		Input.get_joy_axis(gamepad, 0), 0, Input.get_joy_axis(gamepad, 1))
	if abs(walk.x) < move_dead_zone.x: walk.x = 0
	if abs(walk.z) < move_dead_zone.y: walk.z = 0
	# -- Keyboard
	if Input.is_action_pressed('move_forward'):
		walk.z = -1
	elif Input.is_action_pressed('move_backward'):
		walk.z = 1
	if Input.is_action_pressed('move_left'):
		walk.x = -1
	elif Input.is_action_pressed('move_right'):
		walk.x = 1
	
	# Align movement with view.
	walk = $Head.transform.basis * walk * speed
	
	# Align movement with the ground.
	if not on_ground:
		var collision = move_and_collide(Vector3(0, -1, 0))
		if collision:
			print(collision.collider.name + '\n\n' +
				'POS:\n' + str(collision.position) + '\n\n' +
				'NORMAL:\n' + str(collision.normal) + '\n\n')
			floor_normal = collision.normal
			on_ground = true
	$Debug.text = \
		str(walk.slide(floor_normal)) + '\n'
	var r = move_and_slide(walk.slide(floor_normal), FLOOR)
	#var r = move_and_slide(walk.slide(floor_normal))
	#$Debug.text += str(r) + '\n'
	#move_and_collide(walk.slide(floor_normal) * delta)
	#translation += walk.slide(floor_normal) * delta
#2345678901234567890123456789012345678901234567890123456789012345678901_34567890


func _process(delta):
	_look()


export var gamepad = 0
export var look_dead_zone = Vector2(.013, .1)
export var gamepad_view_sensitivity = Vector2(.1, .08)
export var mouse_view_sensitivity = Vector2(.001, .001)
export var invert_y = false

const MAX_VERT_RANGE = (PI / 2) * .95
var _vert_look = 0


func _look():
	# Turn around.
	var look_y = Input.get_joy_axis(gamepad, 2)
	if abs(look_y) > look_dead_zone.x:
		$Head.rotate_y(-look_y * gamepad_view_sensitivity.y)
	
	# Calculate vertical aiming angle.
	_vert_look = -Input.get_joy_axis(gamepad, 3) * MAX_VERT_RANGE
	if abs(_vert_look) < look_dead_zone.y: _vert_look = 0
	
	if invert_y: _vert_look *= -1
	
	# Smoothly align camera with desired angle.
	if $Head/Camera.rotation.x != _vert_look:
		var r = _vert_look - $Head/Camera.rotation.x
		$Head/Camera.rotate_x(r * gamepad_view_sensitivity.x)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


const MAX_MOUSE_VERT = (PI / 2) * .7


func _input(event):
	if event.is_action_pressed('quit'):
		get_tree().quit()
	
	if not event is InputEventMouseMotion or \
	   Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	$Head.rotate_y(-event.relative.x * mouse_view_sensitivity.x)
	$Head/Camera.rotate_x(-event.relative.y * mouse_view_sensitivity.y)
	
	var c = $Head/Camera.rotation.x
	$Head/Camera.rotation.x = clamp(c, -MAX_MOUSE_VERT, MAX_MOUSE_VERT)