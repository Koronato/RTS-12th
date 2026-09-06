extends Node
class_name Server

##data
@export var status : String = "EMPTY"
@export var player_list = {}
@export var units = {}
@export var map = {}
@export var border : Vector2

##options
@export var map_options : MapOptions = MapOptions.new()

enum cmd_list {
	get_map,
	palyer_login,
}
var map_gen

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
					Vector2(map_options.map_width,map_options.map_height)))

func receive(command,args:Array) -> void:#存疑
	match command:
		cmd_list.palyer_login:
			player_login(args[0])
		cmd_list.get_map:
			pass
		_:
			return

##Player
func player_login(name:String) -> void:
	if player_list.has(name):
		return
	var data := PlayerData.new()
	player_list.set(name,data)
