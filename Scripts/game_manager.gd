extends Node2D

var grid_size :int = 120
var num_rows = 8
var num_columns = 8
@export var dummy_scene:PackedScene
@export var grid_scene:PackedScene
@export var grid_position_offset:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var grid_instance = grid_scene.instantiate()
	grid_instance.position = grid_position_offset
	add_child(grid_instance)
	for i in range(num_rows):
		var instance = dummy_scene.instantiate()
		instance.position = Vector2(0,i*grid_size)
		grid_instance.add_child(instance)
		
	for j in range(num_columns):
		var instance = dummy_scene.instantiate()
		instance.position = Vector2(j*grid_size,0)
		grid_instance.add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
