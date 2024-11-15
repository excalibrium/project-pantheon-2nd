extends RigidBody3D

var target = null
@onready var looker = $lookat
@onready var velocity = $velocity
var timer := 0.0

func _physics_process(delta):
	var velocity = linear_velocity
	if velocity.length() > 0:
		var look_direction = velocity.normalized()
		if is_zero_approx(global_position.x - look_direction.x) == false and is_zero_approx(global_position.y - look_direction.y) == false and is_zero_approx(global_position.z - look_direction.z) == false:
			look_at(global_position - look_direction, Vector3.UP)
		if target:
			global_position = lerp(global_position, target.global_position + Vector3(0,1,0), 0.1)
