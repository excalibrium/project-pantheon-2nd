extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_pressed("F"):
		var scene = preload("res://Main/Entities/Enemy/Casual/casual_enemy.tscn")
		var casene = scene.instantiate()
		casene.global_translate(Vector3(0, 5, 0))
		add_child(casene)
