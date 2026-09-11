extends Node

var server = Server.new()
var client = preload("uid://qgccs2w55ct4").instantiate()
var Conn = LocalConn.new()

func _ready() -> void:
	#服务器初始化
	server.map_options = Global.map_options
	server.server_init()
	add_child(server,true)
	await server.init_done
	#连接初始化
	Conn.server = server
	add_child(Conn,true)
	#客户端初始化 进行在服务器之后
	add_child(client,true)
