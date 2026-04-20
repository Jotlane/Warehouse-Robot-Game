extends Node2D

var direction:Vector2 = Vector2.RIGHT
@export var speed_normal: float = 100
var speed: float
var is_stopped:bool = false
var finish_mask:int
var lane:int
@export var accel: int

enum RobotState {
	moving,
	stopped,
	slow,
	speedup
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set sprite
	if (direction == Vector2.LEFT):
		$RobotAnimatedSprite.flip_h = true
	else:
		$RobotAnimatedSprite.rotation = direction.angle()
	speed = speed_normal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!is_stopped):
		if (speed<speed_normal):
			speed+=delta*accel
	else:
		if (speed>0):
			speed-=delta*accel
	if (speed<0): speed=0
	position += direction * speed * delta

func set_heading_right(right:bool):
	if (right): finish_mask = 8#4
	else: finish_mask = 4#3

func _on_robot_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event.is_action_pressed("left_click")):
		is_stopped = !is_stopped
		if (is_stopped): $HornAudio.play()
		else: $VroomAudio.play()

func _on_robot_crash_area_area_entered(area: Area2D) -> void:
	print("Crash with ", area)
	print("area layer:", area.get_collision_layer())
	if (area.get_collision_layer() & 2):
		print("explode")
		Singleton.crash_occurred.emit((position+area.get_parent().position)*0.5)
	elif (area.get_collision_layer() & finish_mask):
		print("clear")
		Singleton.robot_exited_lane.emit(lane)
		area.get_parent().get_node("AudioStreamPlayer").play()
	queue_free()
