extends Node2D

@onready var map_gen = $MapGen
@onready var Layers = $Layers
@onready var border_right = $Borders/Right
@onready var border_bottom = $Borders/Bottom
@onready var layer_list:Array[TileMapLayer]
var tile_set = preload("res://assets/sets/normal_tile_set.tres")
var debugon:bool = false

func _ready() -> void:
	for c in Layers.get_children():
		if c is TileMapLayer:
			layer_list.append(c)
	#地图生成
	map_gen.TMP = layer_list
	map_gen.map_seed = Global.map_seed
	map_gen.map_width = Global.map_width
	map_gen.map_height = Global.map_height
	map_gen.noise_frequency = Global.noise_frequency
	map_gen.WaSpro = Global.water_and_soil_proportion
	
	if debugon:
		map_gen._debug(500)
	else:
		map_gen._main()
		await  map_gen.map_gen_done
	
	#设置边界
	var border_lb_point = layer_list[0].map_to_local(
		CubeCoord.cube_to_cell(
			CubeCoord.local_to_cube(
				Vector2(Global.map_width,-Global.map_height)
				)
			)
		)
	border_right.position.x = border_lb_point.x + tile_set.tile_size.x / 2 - tile_set.tile_size.y
	border_bottom.position.y = border_lb_point.y + tile_set.tile_size.y / 2
