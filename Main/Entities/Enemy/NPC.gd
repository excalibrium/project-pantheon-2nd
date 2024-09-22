extends Character
class_name Enemy

enum State { IDLE, ATTACK }
enum IdleSubstate { STANDING, ROAMING, ALERTED, SEARCHING }
enum AttackSubstate { AWAIT, FLEE, APPROACH, DEFEND, STRIKE }

const THRESHOLD_A := 1.0
const THRESHOLD_B := 3.0

@export var speed := 2.0
@export var accel := 10.0
@export var alertness := 2.0
@export var adrenaline := 1.0

var awareness_rays: Array[RayCast3D]
@export var awareness_ray: RayCast3D
@export var awareness_sphere: CollisionShape3D
@export var nav: NavigationAgent3D
@onready var healthbar := $SubViewport/HealthBar
@export var animationTree: AnimationTree

var current_state: State = State.IDLE
var current_idle_substate: IdleSubstate = IdleSubstate.STANDING
var current_attack_substate: AttackSubstate = AttackSubstate.AWAIT
var last_alerter: Node
var last_alerter_pos: Vector3
var curious_stage := 0
var curious := 0.0
var think_timer := 0.0
var default_transform: Transform3D
var current_attack_target
var last_seen
var prio
var turn_off_pain_inhibitors := false
var safeness := 0
func _ready() -> void:
	healthbar.init_health(health)
	await get_tree().physics_frame

func alert(alert_level: float, alerter: Node) -> void:
	if prio == null:
		prio = alerter
		print(" prio was null")
	#print(alerter)
	curious = min(curious + alert_level, 100.0)
	last_alerter = alerter
	if prio.curiosityFactor <= last_alerter.curiosityFactor or current_attack_substate == AttackSubstate.AWAIT:
		prio = alerter
		print(" prio is alerter")
	if curious > THRESHOLD_A and curious < THRESHOLD_B:
		curious_stage = 1
		look_at(alerter.global_position, Vector3.UP)
	elif curious > THRESHOLD_B:
		curious_stage = 2
		#print("MY CURIOSITY IS UNSATIABLE")
		nav.target_position = prio.global_position

func unalert() -> void:
	pass
	#nav.target_position = default_transform.origin

func think() -> void:
	check_awareness()
	if prio:
		print(global_position.distance_to(prio.global_position))
	print("cs: ", current_state)
	print("attackss: ", current_attack_substate)
	print("alerted and : ", nav.target_position)
	match current_state:
		State.IDLE:
			think_idle()
		State.ATTACK:
			print("EX TER MI NATEEE")
			combat_decision_making()

func think_idle() -> void:
	print("idle thought")
	print("cis: ", current_idle_substate)
	if current_idle_substate == IdleSubstate.STANDING:
		print("stand proud")
	if curious >= THRESHOLD_A and curious < THRESHOLD_B:
		curious_stage = 1
		current_idle_substate = IdleSubstate.ALERTED
	elif curious > THRESHOLD_B:
		curious_stage = 2
		current_idle_substate = IdleSubstate.SEARCHING

		if current_idle_substate == IdleSubstate.SEARCHING:
			print("where this nigga at")
	elif curious < THRESHOLD_A:
		curious_stage = 0
		if abs(velocity) != Vector3.ZERO:
			current_idle_substate = IdleSubstate.ROAMING
		else:
			nav.target_position = default_transform.origin
			IdleSubstate.STANDING

func check_awareness() -> void:
	print(prio)
	var a:float = INF
	for ray in $Raycast.raycasts:
		awareness_ray = ray
		last_seen = awareness_ray.get_collider()
		if prio == null and awareness_ray.get_collider() is Character:
			prio = awareness_ray.get_collider()
		if prio is Character and prio.curiosityFactor < a:
			a = prio.curiosityFactor
			prio = awareness_ray.get_collider()
		if prio and prio.is_in_group("Ally"):
			print("ally seen")
			safeness = 0
			current_attack_target = prio
			current_state = State.ATTACK
		if awareness_ray.get_collider() and awareness_ray.get_collider().owner == prio:
			curious = prio.curiosityFactor
			if prio.curiosityFactor >= (THRESHOLD_A + THRESHOLD_B) / 2 and awareness_ray.get_collider().owner == prio:

				if prio.is_in_group("Ally") and awareness_ray.get_collider().owner == last_alerter:
					safeness = 0

					current_attack_target = prio
					current_state = State.ATTACK
			else:
				print("ruzgar")

func combat_decision_making() -> void:
	print(current_state)
	match current_attack_substate:
		AttackSubstate.AWAIT:
			if current_attack_target.threat_level > threat_level and turn_off_pain_inhibitors == false:
				current_attack_substate = AttackSubstate.FLEE
				print("flee")
			else:
				current_attack_substate = AttackSubstate.APPROACH
		AttackSubstate.FLEE:
			flee()
			if find_nearest_ally() and find_nearest_ally().global_position.distance_to(global_position) < 2:
				if global_position.distance_to(current_attack_target.global_position) > 10:
					print("im safe")
					safeness += 1
				if global_position.distance_to(current_attack_target.global_position) < 10:
					print("must attack")
					current_attack_substate = AttackSubstate.AWAIT
					turn_off_pain_inhibitors = true
			if safeness > 5:
				print("wew time to go back to post")
				current_state = State.IDLE
				curious = 1
		AttackSubstate.APPROACH:
			if prio:
				print("APPROACH")
				nav.target_position = current_attack_target.global_position
			if global_position.distance_to(current_attack_target.global_position) > 6:
				print("far")
				current_attack_substate = AttackSubstate.APPROACH
			if global_position.distance_to(current_attack_target.global_position) < 2:
				current_attack_substate = AttackSubstate.STRIKE
				print("close")
		AttackSubstate.STRIKE:
			
			print("swing", self)
			current_attack_substate = AttackSubstate.AWAIT
		AttackSubstate.DEFEND:
			
			print("defend")
func find_nearest_ally() -> Node:
	var alpha_group = get_tree().get_nodes_in_group("enemies")
	var nearest_ally: Node = null
	var nearest_distance: float = INF

	for ally in alpha_group:
		if ally == self:
			continue  # Skip self
		var distance = global_position.distance_to(ally.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_ally = ally

	return nearest_ally

func flee():
	var nearest_ally = find_nearest_ally()
	if nearest_ally:
		if global_position.distance_to(find_nearest_ally().global_position) < 100:
			nav.target_position = find_nearest_ally().global_position
			#print("LESSEAMUP")
		if global_position.distance_to(find_nearest_ally().global_position) >= 100:
			print("ahhellnaw imma die...")
	else:
		print("noone to save me imma die... ATTACK!!!!")
		turn_off_pain_inhibitors = true
		current_attack_substate = AttackSubstate.APPROACH

func push(towards, hitter):
	if towards == "left":
		velocity += global_transform.basis * Vector3(10, 0, 0)
	if towards == "right":
		velocity += global_transform.basis * Vector3(-10, 0, 0)
	if towards == "fwd":
		velocity += global_transform.basis * Vector3(0, 0, -10)
	if towards == "bwd":
		velocity += global_transform.basis * Vector3(0, 0, 10)
	if towards == "bwdplayer":
		var direction: Vector3 = global_position - hitter.global_position
		direction = direction.normalized()
		velocity += direction * 5
	return
