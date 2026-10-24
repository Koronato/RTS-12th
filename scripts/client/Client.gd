extends Node2D
class_name Client

@export var Conn : LocalConn
@export var player_data : PlayerData = PlayerData.new()
@export var map_layer : Array = []
@export var tile_set = load("uid://dxd5dltwag3u0")
var peer
var client_multiplayer

func _ready() -> void:
	Conn = $/root/Game.Conn
	##连接
	await _start_client()
	#登录
	player_data = Conn.send("reg_player",[Global.player_name])
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
	
	var border = Conn.send("get_border") as Vector2
	$Borders/Right.position.x = border.x
	$Borders/Bottom.position.y = border.y
	##初始化
	#玩家设置
	%Camera.move = true #解放摄像机
	
func _start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	client_multiplayer = MultiplayerAPI.create_default_interface()
	peer.create_client("127.0.0.1",25564)
	client_multiplayer.multiplayer_peer = peer
	get_tree().set_multiplayer(client_multiplayer,self.get_path()) #独立mutiplayer以适应内置服务端
	
	print("Client started")
	print("Client peer id: %s",multiplayer.get_unique_id())
