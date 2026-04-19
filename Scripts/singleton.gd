extends Node

var grid_instance
var grid_size :int = 120
var num_rows = 8
var num_columns = 8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func crash_occurred(pos:Vector2) -> void:
	grid_position_to_index(pos)
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

func grid_index_to_position(pos:Vector2i) -> Vector2:	return Vector2(pos.x * grid_size,pos.y * grid_size)

func grid_position_to_index(pos:Vector2)-> Vector2i: return Vector2i(int(pos.x) / grid_size,int(pos.y) / grid_size)

func grid_position_to_array(pos:Vector2i) -> int:
	return pos.y*num_columns + pos.x

func array_to_grid_position(idx:int) -> Vector2i:
	return Vector2i(idx%num_columns,idx/num_columns)
