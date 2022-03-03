class_name InventoryGrid extends GridContainer

# Signals

# Constants
const INVENTORY_PANEL_SCENE := preload("res://UIInventoryPanel.tscn")
const CELL_SIZE := 32

# Export Variables
export(int) var InventoryColumns
export(int) var InventorySlots

# Item Handling Vars
var items := []


# Grid Handling Vars
var grid := {}
var grid_height := 0
var grid_width := 0
var grid_slots := []

# Local Variables

# Public Variables
export var inv_name := "Base Inventory"

# Node References
# Use the following to ensure references do not break when rearranging nodes:
# export(NodePath) onready var variable_name = get_node(variable_name) as NodeType


# Main Functions
func _ready() -> void:
	columns = InventoryColumns
	for _i in range(InventorySlots):
		var panel = INVENTORY_PANEL_SCENE.instance()
		add_child(panel)
		grid_slots.append(panel)
	for item in get_tree().get_nodes_in_group("item"):
		items.append(item)
	yield(get_tree(), "idle_frame")
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	initialize_grid_spaces()
	
	
# Item Handlers
func grab_item(pos) -> Control:
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	var item_pos = item.rect_global_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	items.remove(items.find(item))
	return item
	
func get_item_under_pos(pos :Vector2) -> Control:
	for item in items:
		for block in item.building_blocks:
			if block.get_global_rect().has_point(pos):
#				#print("Found Item: ", item)
				return item
	return null

# Helper Functions
func pos_to_grid_coord(pos) -> Dictionary:
	var local_pos = pos - rect_global_position
	var results = {}
	results.x = int(local_pos.x / CELL_SIZE)
	results.y = int(local_pos.y / CELL_SIZE)
	return results

func get_grid_size(item :Control) -> Dictionary:
	var results = {}
	var s = item.rect_size
	results.x = clamp(int(s.x / CELL_SIZE), 1, 500)
	results.y = clamp(int(s.y / CELL_SIZE), 1, 500)
	
	return results


# Grid Handlers
		
func set_grid_space(x, y, w, h, state) -> void:
	for i in range(x, x + w):
		if grid.has(i):
			for j in range(y, y + h):
				if grid[i].has(j):
					grid[i][j] = state

func initialize_grid_spaces():
	#Iterate over rows second
	for x in range(grid_width):
		grid[x] = {}
		#iterate over columns first
		for y in range(grid_height):
			grid[x][y] = false
	var x_coord := 0
	var y_coord := 0
	for slot in grid_slots:
		var coords : Dictionary = pos_to_grid_coord(slot.rect_global_position)
		slot.label.text = str(coords["x"]) + ", " + str(coords["y"])
			
		

# Boolean functions
func insert_item(item : InventoryItem) -> bool:
	var item_pos = item.rect_global_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.rect_global_position = rect_global_position + Vector2(g_pos.x, g_pos.y) * CELL_SIZE
		items.append(item)
		return true
	else:
		return false

func is_grid_space_available(x,y,w,h) -> bool:
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if grid[i][j]:
				return false
	return true
	
func insert_item_at_first_available_spot(item) -> bool:
	for y in grid_height:
		for x in grid_width:
			if !grid[x][y]:
				item.rect_global_position = rect_global_position + Vector2(x,y) * CELL_SIZE
				if insert_item(item):
					return true
					
	return false
# Signal receivers functions
