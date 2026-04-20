extends ColorRect

@export var speed:float
var delete_time:float
var time:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time = 0
	delete_time = 60
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= delta*speed
	position.y += delta*speed
	time += delta
	if (time>delete_time): queue_free()
	pass
