extends Node2D

enum LaneStatus {
	LEFT,
	RIGHT,
	CLOSED,
	OPEN
}

@export var grid_tile:PackedScene
@export var grid_scene:PackedScene
@export var grid_position_offset:Vector2
@export var robot_scene:PackedScene
@export var finish_point_scene:PackedScene

var grid_obstacles:Array[int] = []
var grid_instance
var lanes:Array[LaneStatus] = []
var open_lanes:Array[int] = []
var lane_contents:Array[int] = []

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
	
	lane_contents.resize(lanes.size())
	lane_contents.fill(0)
	
	Singleton.crash_occurred.connect(_crash_occurred)
	Singleton.robot_exited_lane.connect(_robot_exited_lane)
	for i in range(Singleton.num_rows):
		for j in range(Singleton.num_columns):
			if (i != 0 and j != 0 and i != Singleton.num_rows -1 and j != Singleton.num_columns-1):
				var instance = grid_tile.instantiate()
				instance.position = Vector2(j*Singleton.grid_size,i*Singleton.grid_size)
				grid_instance.add_child(instance)
		
	for i in range((Singleton.num_columns-1)*2+(Singleton.num_rows-1)*2):
		if (i != 0 and i != Singleton.num_columns-1 and i != Singleton.num_columns -1 + Singleton.num_rows-1 and i != Singleton.num_columns -1 + Singleton.num_rows-1+Singleton.num_columns -1):
			var finish_point_instance = finish_point_scene.instantiate()
			var spawner_grid = Singleton.array_to_spawner_grid(i)
			if (spawner_grid.x == 0 or spawner_grid.y == 0):
				finish_point_instance.get_node("FinishPointArea").set_collision_layer_value(3,true)
			elif(spawner_grid.x == Singleton.num_columns -1 or spawner_grid.y == Singleton.num_rows -1):
				finish_point_instance.get_node("FinishPointArea").set_collision_layer_value(4,true)
			else: print("Error: Cannot set finish point collision area")
			finish_point_instance.position = Singleton.grid_index_to_position(Singleton.array_to_spawner_grid(i))
			grid_instance.add_child(finish_point_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(open_lanes)
	#print(lanes)
	pass

func _on_spawn_timer_timeout() -> void:
	var robot_instance = robot_scene.instantiate()
	var selected_lane:int
	if (open_lanes.is_empty()):
		print("Out of lanes")
	else:
		selected_lane = open_lanes.pick_random()
		var spawner_selected:Vector2i
		if (lanes[selected_lane] == LaneStatus.OPEN):
			var starting_point:int = randi_range(0,1)
			if (selected_lane<Singleton.num_rows-2):
				if (starting_point == 0): spawner_selected = Vector2i(0,selected_lane+1)
				else: spawner_selected = Vector2i(Singleton.num_rows-1,selected_lane+1)
			else:
				if (starting_point == 0): spawner_selected = Vector2i(selected_lane-(Singleton.num_rows-2)+1,0)
				else: spawner_selected = Vector2i(selected_lane-(Singleton.num_rows-2)+1,Singleton.num_columns-1)
		elif (lanes[selected_lane] == LaneStatus.LEFT):
			if (selected_lane<Singleton.num_rows-2):
				spawner_selected = Vector2i(Singleton.num_rows-1,selected_lane+1)
			else:
				spawner_selected = Vector2i(selected_lane-(Singleton.num_rows-2)+1,Singleton.num_columns-1)
				
		elif (lanes[selected_lane] == LaneStatus.RIGHT):
			if (selected_lane<Singleton.num_rows-2):
				spawner_selected = Vector2i(0,selected_lane+1)
			else:
				spawner_selected = Vector2i(selected_lane-(Singleton.num_rows-2)+1,0)
				
		else: print("ERROR Trying to spawn in a closed lane")
		print(spawner_selected)
		robot_instance.position = Singleton.grid_index_to_position(spawner_selected)
		robot_instance.direction = Singleton.get_travel_direction(spawner_selected)
		if (robot_instance.direction == Vector2.DOWN or robot_instance.direction == Vector2.RIGHT):
			robot_instance.get_node("RobotCrashArea").set_collision_mask_value(4,true)
			robot_instance.set_heading_right(true)
			lanes[selected_lane] = LaneStatus.RIGHT
			#If I am heading right, I will reach the one on the right
		elif (robot_instance.direction == Vector2.UP or robot_instance.direction == Vector2.LEFT):
			robot_instance.get_node("RobotCrashArea").set_collision_mask_value(3,true)
			robot_instance.set_heading_right(false)
			lanes[selected_lane] = LaneStatus.LEFT
			#If I am heading left, I will reach the one on the left
		lane_contents[selected_lane] += 1
		robot_instance.lane = selected_lane
		print("Lanes: ", lanes)
		grid_instance.add_child(robot_instance)

func _crash_occurred(pos:Vector2) -> void:
	add_obstacle(Singleton.grid_position_to_array(Singleton.grid_position_to_index(pos)))

func add_obstacle(idx:int) -> void:
	if (grid_obstacles[idx]):
		print("Already occupied with obstacle")
	else:
		if (Singleton.array_to_grid_position(idx).x != 0 and Singleton.array_to_grid_position(idx).x != Singleton.num_columns and Singleton.array_to_grid_position(idx).y != 0 and Singleton.array_to_grid_position(idx).y != Singleton.num_rows):
			grid_obstacles[idx] = 1
			var obstacle_instance = Singleton.obstacle_scene.instantiate()
			obstacle_instance.position = Singleton.grid_index_to_position(Singleton.array_to_grid_position(idx))
			grid_instance.add_child(obstacle_instance)
			
			var closed_lanes:Array[int] = [Singleton.array_to_grid_position(idx).y-1,Singleton.array_to_grid_position(idx).x+6-1]
			
			lanes[closed_lanes[0]] = LaneStatus.CLOSED
			lanes[closed_lanes[1]] = LaneStatus.CLOSED
			open_lanes.erase(closed_lanes[0])
			open_lanes.erase(closed_lanes[1])
			print("Lanes: ",lanes)
			print("Open lanes: ", open_lanes)
		else: print("Obstacle spawned on edge, ignoring")

func _robot_exited_lane(lane:int):
	lane_contents[lane] -= 1
	if (lane_contents[lane] <= 0 and lanes[lane] != LaneStatus.CLOSED):
		lanes[lane] = LaneStatus.OPEN

#DEBUG FUNCTIONS
func debug_array_to_spawner_grid() ->void:
	for i in range(-1,Singleton.num_columns*2 + Singleton.num_rows*2 -3):
		print(Singleton.array_to_spawner_grid(i))

func debug_spawner_grid_to_array() -> void:
	for i in range(Singleton.num_rows):
		for j in range(Singleton.num_columns):
			print(Singleton.spawner_grid_to_array(Vector2i(j,i)))
