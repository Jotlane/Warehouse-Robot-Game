extends Node2D

var direction:Vector2 = Vector2.RIGHT
@export var speed: float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set sprite
	$RobotSprite.rotation = direction.angle() #TODO: Change this to specific up/down/left/right sprite or flip etc


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta
	pass
