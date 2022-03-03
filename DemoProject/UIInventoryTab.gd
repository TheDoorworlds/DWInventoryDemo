extends Control

# Testing Vars
var item_scene := preload("res://Items/InventoryItemBase.tscn")

# Signals

signal dropped_item(item)
signal item_inserted(item)

# Item Variables
var item_held : InventoryItem = null
var item_offset : Vector2 = Vector2.ZERO
var last_container : InventoryGrid = null
var last_pos := Vector2.ZERO

# Reference Variables
var inv_grids := []



# Testing vars
var colors := [
	Color.red,
	Color.green,
	Color.yellow,
	Color.teal,
	Color.purple,
	Color.white,
	Color.pink,
	Color.blue
]

onready var items_container := $ItemsContainer

# Main Functions
func _ready() -> void:
	randomize()
	for grid in get_tree().get_nodes_in_group("inv_grid"):
		if grid.inv_name == "Pouch":
			inv_grids.append(grid)
		else:
			inv_grids.insert(0, grid)
	yield(get_tree(), "idle_frame")
	for grid in inv_grids:
		grid.initialize_grid_spaces()
	connect_signals()

func _process(delta: float) -> void:
	var cursor_pos := get_global_mouse_position()
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_offset

func connect_signals() -> void:
	Events.connect("picked_up_inventory_item", self, "_on_picked_up_invetory_item")

func _input(event: InputEvent) -> void:
	var cursor_pos := get_global_mouse_position()
	if event.is_action_pressed("inv_grab"):
		grab(cursor_pos)
	if event.is_action_released("inv_grab"):
		release(cursor_pos)


# Item Handlers

func grab(cursor_pos) -> void:
	var grid = get_grid_under_cursor(cursor_pos)
	if grid != null and grid.has_method("grab_item"):
		item_held = grid.grab_item(cursor_pos)
		if item_held != null:
			last_container = grid
			last_pos = item_held.rect_global_position
			item_offset = item_held.rect_global_position - cursor_pos
			items_container.move_child(item_held, items_container.get_child_count())
	

func release(cursor_pos) -> void:
	if item_held == null:
		return
	var grid = get_grid_under_cursor(cursor_pos)
	if grid == null:
		drop_item()
	elif grid.has_method("insert_item"):
		if grid.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()

func drop_item() -> void:
	item_held.queue_free()
	emit_signal("dropped_item", item_held)
	item_held = null
	
func return_item() -> void:
	item_held.rect_global_position = last_pos
	if last_container.insert_item(item_held):
		emit_signal("item_inserted", item_held)
	item_held = null

# Helper Functions
func get_grid_under_cursor(cursor_pos) -> InventoryGrid:	
	# Checks grids for cursor point
	for grid in inv_grids:
		if grid.get_global_rect().has_point(cursor_pos):
			return grid
	return null
#

# Signal Receivers
func _on_dropped_item(item):
	print("Dropped Item: " + str(item))



# Testing Functions
func pickup_item(pickup :InventoryItem) -> bool:
	var item = pickup
	item.modulate = colors[randi() % colors.size()]
	items_container.add_child(item)
	var full_grids := []
	for grid in inv_grids:
		if grid.insert_item_at_first_available_spot(item) == true:
			return true
		if grid.insert_item_at_first_available_spot(item) == false:
			full_grids.append(true)
			continue
			
	var delete :bool = false
	if full_grids.empty():
		return true
	elif full_grids.size() == inv_grids.size():
		item.queue_free()
		return false
	return true


# Signal Receivers
func _on_picked_up_invetory_item(item :InventoryItem):
	if item:
		if !pickup_item(item):
			emit_signal("dropped_item", item)
