extends Enemy
class_name Casual_Enemy


func _ready() -> void:
	default_transform = global_transform
	healthbar.init_health(health)
	prio = null
	weapons_in_tree = get_tree().get_nodes_in_group("weapon")
	for each_weapon in weapons_in_tree:
		if each_weapon.owner == self:
			currentweapon = each_weapon

func _process(delta: float) -> void:
	_handle_var(delta)

func _handle_var(delta):
	print(abs(velocity.x + velocity.z))
	#Is moving?
	if abs(velocity.x + velocity.z) > 0.25:
		is_moving = true
	else:
		is_moving = false

	#Curiosity mechanic
	if curious >= 0.0 and curious_stage < 2:
		curious -= delta / 2
	if curious <= 0.0:
		unalert()

	#Think timer/adrenaline mechanic
	if think_timer < 1.0 / adrenaline:
			think_timer += delta
	if think_timer >= 1.0 / adrenaline:
		think()
		think_timer = 0.0

func _physics_process(delta: float) -> void:
	animationTree.set("parameters/stater/conditions/walk", !staggered and is_moving == true and attacking == false and is_blocking == false and is_running == false)
	animationTree.set("parameters/stater/conditions/idle", !staggered and is_moving == false and attacking == false and is_blocking == false and is_running == false)
	if prio:
		$Raycast.look_at(prio.global_position)
	var current_position = global_position
	var next_position = nav.get_next_path_position()
	var new_velocity = (next_position - current_position).normalized() * speed
	nav.velocity = new_velocity
	move_and_slide()
	if is_on_floor() == false:
		velocity.y -= 1
	if velocity.length() > 0.1:
		var look_direction = velocity.normalized()
		var current_rotation = basis.get_rotation_quaternion()
		var target_rotation = Quaternion.from_euler(Vector3(0, atan2(-look_direction.x, -look_direction.z), 0))
		var new_rotation = current_rotation.slerp(target_rotation, 1.0 * delta)
		basis = Basis(new_rotation)
	if curious_stage == 2:
		$RayCast.look_at(prio.global_position)
	velocity = velocity.move_toward(nav.velocity, 0.1)
func _on_alertness_sphere_area_entered(area: Area3D) -> void:
	if area.is_in_group("alerter"):
		alert(1 / pow(global_position.distance_to(area.global_position), 1.0/6.0), area.owner)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	print("yeeha")
	nav.velocity = nav.velocity.move_toward(safe_velocity, 0.1)

func damage_by(damaged):
	health -= damaged
	healthbar.health = health 

func guard_break():
	pass
