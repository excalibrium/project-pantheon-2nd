@tool
extends AnimationTree

func _process(delta: float) -> void:
	set_active(true)
#func _process(delta):
		#if name == "FistsAnimTree" and owner.LeftHandItem == "Fists":
			#self.set_active(true)
		#else:
			#self.set_active(false)
		#if name == "AnimationTree" and owner.LeftHandItem != "Fists":
			#self.set_active(true)
		#else:
			#self.set_active(false)