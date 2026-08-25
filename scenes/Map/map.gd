extends Node2D

@onready var map_gen = $MapGen
@onready var Layers = $Layers
@onready var layer_list:Array

func _ready() -> void:
	for c in Layers.get_children():
		layer_list.append(c)
	#地图生成
	map_gen.TMP = layer_list
	map_gen.map_seed = Global.map_seed
	map_gen.map_width = Global.map_width
	map_gen.map_height = Global.map_height
	map_gen.noise_frequency = Global.noise_frequency
	map_gen.WaSpro = Global.water_and_soil_proportion
	
	map_gen._main()
