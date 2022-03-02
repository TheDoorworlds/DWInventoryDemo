class_name WorldDrop extends Node2D

# Signals
signal picked_up(item)

# Constants
const DROP_ITEM_SIZE := 16

# Export Variables
export(PackedScene) var InventoryBlueprint = null
export (Array, Rect2) var _sprite_regions := [
	Rect2(0, 0, DROP_ITEM_SIZE, DROP_ITEM_SIZE),
	Rect2(0, DROP_ITEM_SIZE, DROP_ITEM_SIZE, DROP_ITEM_SIZE),
	Rect2(DROP_ITEM_SIZE, 0, DROP_ITEM_SIZE, DROP_ITEM_SIZE),
	Rect2(DROP_ITEM_SIZE, DROP_ITEM_SIZE, DROP_ITEM_SIZE, DROP_ITEM_SIZE)
]

# Local Variables
var _rng := RandomNumberGenerator.new()


# Public Variables


# Node References
# Use the following to ensure references do not break when rearranging nodes:
# export(NodePath) onready var variable_name = get_node(variable_name) as NodeType

onready var area := $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var animation = $AnimationPlayer
onready var sprite = $Sprite
onready var tween = $Tween


# Main Functions
func _ready() -> void:
	area.connect("area_entered", self, "_on_Area2D_area_entered")
	choose_sprite()
	sprite.region_rect = _sprite_regions[(_rng.randi_range(0, _sprite_regions.size()-1))]
	_pop_out()



# Setter functions
func choose_sprite() -> void:
	_rng.randomize()
	var number_of_regions := _sprite_regions.size()
	var sprite_choice := _rng.randi_range(0, number_of_regions - 1)
	sprite.region_rect = _sprite_regions[sprite_choice]


# Animation Handlers
func _pop_out() -> void:
	collision_shape.disabled = true
	var direction := Vector2.UP.rotated(rand_range(-PI, PI))
	direction *= rand_range(20, 70)
	var target_position := global_position + direction
	var height_position := global_position + direction * Vector2(0.5, 2 * -sign(direction.y))
	
	tween.interpolate_property(
		self, 
		"global_position",
		global_position,
		height_position,
		0.15,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	tween.interpolate_property(
		self,
		"global_position",
		height_position,
		target_position,
		0.25,
		0,
		Tween.EASE_IN,
		0.15
	)
	tween.start()
	
	yield(tween, "tween_all_completed")
	collision_shape.disabled = false
	animation.play("float")

func animate_pickup(target :Area2D) -> void:
	var travel_distance := 0.1
	
	collision_shape.set_deferred("disabled", true)
	
	while true:
		var distance_to_target := global_position.distance_to(target.global_position)
		if distance_to_target < 5.0:
			break
		
		global_position = global_position.move_toward(target.global_position, travel_distance)
		travel_distance += 0.1
		
		yield(get_tree(), "idle_frame")
	queue_free()

# Boolean functions


# Signal receivers functions

func _on_Area2D_area_entered(local_area: Area2D) -> void:
	if local_area.is_in_group("player"):
		var pickup_item = InventoryBlueprint.instance()
		animate_pickup(local_area)
		Events.emit_signal("picked_up_inventory_item", pickup_item)

