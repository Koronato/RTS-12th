extends Node2D
class_name Client

@export var Conn : LocalConn
@export var player_data : PlayerData = PlayerData.new()
@export var map_layer : Array = []
@export var tile_set = load("uid://dxd5dltwag3u0")

func _ready() -> void:
	Conn = $/root/Game.Conn
	#登录
	player_data = Conn.send("player_login",[Global.player_name])
	if player_data.uid == -1:
		assert(false,"Had This Name")
		return
	
	#获取地图数据
	var map = Conn.send("get_map") as Array
	for data:Dictionary in map:
		var layer := TileMapLayer.new()
		layer.tile_set = tile_set
		layer.position = Vector2(0,0)
		for key in data:
			layer.set_cell(key,1,data[key])
		$Layers.add_child(layer,true)
		map_layer.append(layer)
		
	
	
