@tool

class_name CustomModifier
extends SkeletonModifier3D
var opose
@export var Skewer: Node3D
@export var bone: String
@export var setzero: bool
@export var setreal: bool

func _process(delta: float) -> void:
	if setzero == true:
		#print(Skewer.transform)
		Skewer.transform.origin = opose.origin
	if setreal == true:
		#print(Skewer.transform)
		Skewer.transform = opose
func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for safety.
	
	var bone_idx: int = skeleton.find_bone(bone)
	var original_pose: Transform3D = skeleton.get_bone_global_pose(bone_idx)
	var global_pose: Transform3D = skeleton.transform * original_pose
	opose = original_pose
	
	skeleton.set_bone_global_pose(bone_idx, Skewer.transform)