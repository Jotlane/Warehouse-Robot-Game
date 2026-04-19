extends Node2D

enum LaneStatus {
	LEFT,
	RIGHT,
	CLOSED,
	OPEN
}

@export var dummy_scene:PackedScene
@export var grid_scene:PackedScene
@export var grid_position_offset:Vector2
@export var robot_scene:PackedScene
var grid_obstacles:Array[int] = []
var grid_instance
var lanes:Array[LaneStatus] = []
var open_lanes:Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_instance = grid_scene.instantiate()
	grid_instance.position = grid_position_offset
	add_child(grid_instance)
	Singleton.grid_instance = grid_instance
	
	grid_obstacles.resize(Singleton.num_columns*Singleton.num_rows)
	grid_obstacles.fill(0)
	
	lanes.resize(Singleton.num_rows - 2 + Singleton.num_columns - 2)
	lanes.fill(LaneStatus.OPEN)
	for i in range(lanes.size()):
		open_lanes.append(i)
	
	Singleton.crash_occurred.connect(_crash_occurred)
	
	for i in range(Singleton.num_rows):
		var instance = dummy_scene.instantiate()
		instance.position = Vector2(0,i*Singleton.grid_size)
		grid_instance.add_child(instance)
		
	for j in range(Singleton.num_columns):
		var instance = dummy_scene.instantiate()
		instance.position = Vector2(j*Singleton.grid_size,0)
		grid_instance.add_child(instance)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(open_lanes)
	print(lanes)
	pass

func _on_spawn_timer_timeout() -> void:
	var robot_instance = robot_scene.instantiate()
	var rng = RandomNumberGenerator.new()
	var spawner_selected:int = rng.randi_range(0,Singleton.num_columns*2+Singleton.num_rows*2-5)
	robot_instance.position = Singleton.grid_index_to_position(Singleton.array_to_spawner_grid(spawner_selected))
	robot_instance.direction = Singleton.get_travel_direction(Singleton.array_to_spawner_grid(spawner_selected))
	grid_instance.add_child(robot_instance)

func _crash_occurred(pos:Vector2) -> void:
	add_obstacle(Singleton.grid_position_to_array(Singleton.grid_position_to_index(pos)))

func add_obstacle(idx:int) -> void:
	if (grid_obstacles[idx]):
		print("Already occupied with obstacle")
	else:
		grid_obstacles[idx] = 1
		var obstacle_instance = Singleton.obstacle_scene.instantiate()
		obstacle_instance.position = Singleton.grid_index_to_position(Singleton.array_to_grid_position(idx))
		grid_instance.add_child(obstacle_instance)
		var closed_lanes:Array[int] = [Singleton.array_to_grid_position(idx).x-1,Singleton.array_to_grid_position(idx).y+6-1]
		lanes[closed_lanes[0]] = LaneStatus.CLOSED
		lanes[closed_lanes[1]] = LaneStatus.CLOSED
		open_lanes.erase(closed_lanes[0])
		open_lanes.erase(closed_lanes[1])



#DEBUG FUNCTIONS
func debug_array_to_spawner_grid() ->void:
	for i in range(-1,Singleton.num_columns*2 + Singleton.num_rows*2 -3):
		print(Singleton.array_to_spawner_grid(i))

func debug_spawner_grid_to_array() -> void:
	for i in range(Singleton.num_rows):
		for j in range(Singleton.num_columns):
			print(Singleton.spawner_grid_to_array(Vector2i(j,i)))
