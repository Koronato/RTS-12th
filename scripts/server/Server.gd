extends Node
class_name Server

##data
@export var status : String = "EMPTY"
@export var player_list = {}
@export var units = {}
@export var map = []
@export var border : Vector2

##options
@export var map_options : MapOptions = MapOptions.new()

##values
var _uid : int = 0
var _uid_lock = Mutex.new()

var peer
var server_multiplayer

@export var cmd_list = {
	get_map="get_map",
	get_border="get_border",
	reg_player="reg_player",
	player_pos_sync="player_pos_sync",
}
var map_gen
signal init_done #NOTICE:可能会移除

func server_init() -> void:
	status = "INIT"
	
	#必要的组件初始化
	map_gen = MapGen.new()
	map_gen.map_options = map_options
	
	#地图生成
	await map_gen._main() #未完成,子线程生成地图
	map = map_gen.map
	 #边界设置
	border = CubeCoord.cube_to_local(
				CubeCoord.cell_to_cube(
					Vector2i(map_options.map_width,map_options.map_height)))
					
	await _start_server()
	init_done.emit()

##Chores
func _start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	server_multiplayer = multiplayer.create_default_interface()
	peer.create_server(25564)
	get_tree().set_multiplayer(server_multiplayer,self.get_path()) #独立mutiplayer以适应内置服务端
	
	print("Server started")
	print("Server id:%s",multiplayer.get_unique_id())

func receive(command:String,args:Array=[]):
	match command:
		cmd_list.reg_player:
			return reg_player(args[0])
		cmd_list.get_map:
			return get_map()
		cmd_list.player_pos_sync:
			return player_pos_sync(args[0])
		cmd_list.get_border:
			return get_border()
		_:
			return

func get_uid() -> int:
	_uid_lock.lock()
	_uid += 1
	_uid_lock.unlock()
	return _uid #直接获取_uid可能会导致不同步问题,不推荐
	
func reg_unit(data:BaseUnitData) -> BaseUnitData:
	var uid = get_uid()
	units.set(data,uid)
	data.uid = uid
	return data

func get_map() -> Array:
	return map

func get_border() -> Vector2:
	return border
	
##Player
func login(player_name:String) -> Dictionary:
	var data = {
		is_succeed = false
	}
	
	return data

func reg_player(player_name:String) -> PlayerData: #此函数应用于注册玩家单位,改造中
	if player_list.has(player_name):
		#查重
		#...
		return PlayerData.new()
	var data := PlayerData.new()
	var unit_data := PlayerUnitData.new() #在服务端注册Unit
	#填充数据
	unit_data.name = player_name
	data.name = player_name
	#注册并同步数据
	unit_data = reg_unit(unit_data) as PlayerUnitData
	data.uid = unit_data.uid
	
	return data

func player_pos_sync(data:PlayerData) -> PlayerData: #仅用于一个玩家坐标同步
	player_list.set(data.name,data)
	units.set(data.uid,data)
	var rdata = data
	#监察合理性
	#...
	return data
