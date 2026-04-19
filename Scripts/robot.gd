extends Node2D

var direction:Vector2 = Vector2.RIGHT
@export var speed_normal: float = 100
var speed: float
var is_stopped:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set sprite
	$RobotSprite.rotation = direction.angle() #TODO: Change this to specific up/down/left/right sprite or flip etc
	
	speed = speed_normal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!is_stopped):
		position += direction * speed * delta


func _on_robot_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event.is_action_pressed("left_click")):
		is_stopped = !is_stopped


func _on_robot_crash_area_area_entered(area: Area2D) -> void:
	print("Crash with ", area)
	Singleton.crash_occurred((position+area.get_parent().position)*0.5)
	queue_free()
