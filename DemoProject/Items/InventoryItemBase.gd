class_name InventoryItem extends Control

# Constants
const CELL_SIZE := 32

# Export Variables
export var item_name := "Base Item"

# Local Variables


# Public Variables
var building_blocks := []
var item_shape := {}
var item_height := 0
var item_width := 0

# Node References
# Use the following to ensure references do not break when rearranging nodes:
# export(NodePath) onready var variable_name = get_node(variable_name) as NodeType



func _ready() -> void:
	building_blocks = get_children()
	set_item_size()


# Helper functions
func set_item_size() -> void:
	var calculated_size := Vector2.ZERO
	
	for block in building_blocks:
		if block.rect_position.x + CELL_SIZE > calculated_size.x:
			calculated_size.x = block.rect_position.x + CELL_SIZE
		if block.rect_position.y + CELL_SIZE > calculated_size.y:
			calculated_size.y = block.rect_position.y + CELL_SIZE
	rect_size = calculated_size
	item_height = int(rect_size.y / CELL_SIZE)
	item_width = int(rect_size.x / CELL_SIZE)


# Helper Functions
func pos_to_grid_coord(pos :Vector2) -> Dictionary:
	var results = {}
	results.x = int(pos.x / CELL_SIZE)
	results.y = int(pos.y / CELL_SIZE)
	return results

# Boolean functions


# Signal receivers functions
