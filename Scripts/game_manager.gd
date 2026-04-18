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
	
	
	
	#Debug for spawner_grid_to_array
	#debug_spawner_grid_to_array()
	#Debug for array_to_spawner_grid
	#debug_array_to_spawner_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawner_grid_to_array(pos:Vector2i) -> int:
	if (pos.y == 0):
		return pos.x
	elif (pos.x == num_columns-1):
		return num_columns -1 + pos.y
	elif (pos.y == num_rows-1):
		return num_rows + num_columns -2 + num_columns -1 - pos.x
	elif (pos.x == 0):
		return num_rows *2 + num_columns * 2 -4 - pos.y
	else:
		print("Spawner_grid_to_array: Invalid grid pos, returning 0")
		return 0

func array_to_spawner_grid(idx:int) -> Vector2i:
	if (idx < 0):
		print("array_to_spawner_grid: Invalid array, returning Vector2i(0,0)")
		return Vector2i(0,0)
	elif (idx <= num_columns -1 and idx >= 0):
		return Vector2i(idx,0)
	elif (idx <= num_columns -1 + num_rows -1):
		return Vector2i(num_columns-1,idx - (num_columns-1))
	elif (idx <= num_columns -1 + num_rows -1 + num_columns -1):
		return Vector2i(num_columns - 1 -(idx - (num_columns-1) - (num_rows-1)),num_rows-1)
	elif (idx <= num_columns*2 + num_rows*2 -5):
		return Vector2i(0,num_columns*2 + num_rows*2 -4 - idx) 
	else:
		print("array_to_spawner_grid: Invalid array, returning Vector2i(0,0)")
		return Vector2i(0,0)


#DEBUG FUNCTIONS
func debug_array_to_spawner_grid() ->void:
	for i in range(-1,num_columns*2 + num_rows*2 -3):
		print(array_to_spawner_grid(i))

func debug_spawner_grid_to_array() -> void:
	for i in range(num_rows):
		for j in range(num_columns):
			print(spawner_grid_to_array(Vector2i(j,i)))
