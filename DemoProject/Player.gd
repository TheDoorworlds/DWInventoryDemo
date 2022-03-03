extends KinematicBody2D

var velocity := Vector2.ZERO

const SPEED_FACTOR := 10

export var acceleration := 10
export var max_speed := 15

func _ready() -> void:
	Events.set("player", self)

func _get_direction() -> Vector2:
	return Vector2(
		(Input.get_action_strength("right") - Input.get_action_strength("left")),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

func _physics_process(delta: float) -> void:
	var input_vector = _get_direction()
	if input_vector != Vector2.ZERO:
		velocity += input_vector * acceleration * delta * SPEED_FACTOR
		velocity = velocity.clamped(max_speed * delta * SPEED_FACTOR)
	else:
		velocity = Vector2.ZERO
	
	move_and_collide(velocity)
