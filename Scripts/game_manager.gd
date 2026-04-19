extends Node2D

@export var dummy_scene:PackedScene
@export var grid_scene:PackedScene
@export var grid_position_offset:Vector2
@export var robot_scene:PackedScene

var grid_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_instance = grid_scene.instantiate()
	grid_instance.position = grid_position_offset
	add_child(grid_instance)
	Singleton.grid_instance = grid_instance
	for i in range(Singleton.num_rows):
		var instance = dummy_scene.instantiate()
		instance.position = Vector2(0,i*Singleton.grid_size)
		grid_instance.add_child(instance)
		
	for j in range(Singleton.num_columns):
		var instance = dummy_scene.instantiate()
		instance.position = Vector2(j*Singleton.grid_size,0)
		grid_instance.add_child(instance)
	
	#Debug for spawner_grid_to_array
	#debug_spawner_grid_to_array()
	#Debug for array_to_spawner_grid
	#debug_array_to_spawner_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
var aa = 0
func _on_spawn_timer_timeout() -> void:
	var robot_instance = robot_scene.instantiate()
	robot_instance.direction = Vector2.DOWN
	robot_instance.position = Singleton.grid_index_to_position(Singleton.array_to_spawner_grid(aa))
	grid_instance.add_child(robot_instance)
	aa +=1

#DEBUG FUNCTIONS
func debug_array_to_spawner_grid() ->void:
	for i in range(-1,Singleton.num_columns*2 + Singleton.num_rows*2 -3):
		print(Singleton.array_to_spawner_grid(i))

func debug_spawner_grid_to_array() -> void:
	for i in range(Singleton.num_rows):
		for j in range(Singleton.num_columns):
			print(Singleton.spawner_grid_to_array(Vector2i(j,i)))
