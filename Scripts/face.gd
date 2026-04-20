extends Node2D
var shaking:bool
var rng:RandomNumberGenerator
@export var shake_range:float
var max_lanes:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shaking = false
	Singleton.obstacle_spawned.connect(_obstacle_spawned)
	Singleton.remaining_lanes.connect(_change_face)
	rng = RandomNumberGenerator.new()
	max_lanes = Singleton.num_columns + Singleton.num_rows -4
	pass # Replace with function body.

func _obstacle_spawned() -> void:
	shaking = true
	$Timer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _change_face(num:int) -> void:
	if(num<4):
		$AnimatedSprite2D.set_animation("dead")
	elif(num<max_lanes-4):
		$AnimatedSprite2D.set_animation("nervous")

func _on_timer_timeout() -> void:
	shaking = false


func _on_subtimer_timeout() -> void:
	if (shaking):
		$AnimatedSprite2D.position.x = rng.randf_range(-shake_range,shake_range)
		$AnimatedSprite2D.position.y = rng.randf_range(-shake_range,shake_range)
