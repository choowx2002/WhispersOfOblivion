extends Node2D


@export var ground_map: TileMapLayer
@export var grass_map: TileMapLayer
@export var slow_map: TileMapLayer

func get_surface_type(global_pos: Vector2) -> String:
	if slow_map:
		var cell = slow_map.local_to_map(slow_map.to_local(global_pos))
		if slow_map.get_cell_source_id(cell) != -1:
			return "slow"
			
	if grass_map:
		var cell = grass_map.local_to_map(grass_map.to_local(global_pos))
		if grass_map.get_cell_source_id(cell) != -1:
			return "grass"
	
	if ground_map:
		var cell = ground_map.local_to_map(ground_map.to_local(global_pos))
		if ground_map.get_cell_source_id(cell) != -1:
			return "ground"
	
	return "default"
