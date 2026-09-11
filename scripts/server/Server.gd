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

@export var cmd_list = {
	get_map="get_map",
	player_login="player_login",
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
	init_done.emit()

func receive(command:String,args:Array=[]):
	match command:
		cmd_list.player_login:
			return player_login(args[0])
		cmd_list.get_map:
			return get_map()
		_:
			return

##Player
func player_login(player_name:String) -> PlayerData:
	if player_list.has(name):
		return PlayerData.new()
	var data := PlayerData.new()
	data.name = name
	data.uid = len(player_list) + 1
	player_list.set(name,data)
	return data

func get_map() -> Array:
	return map
