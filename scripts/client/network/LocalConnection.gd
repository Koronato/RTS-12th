extends Node
class_name LocalConn  #ection

@export var server : Server

func send(cmd,args:Array=[]):
	return server.receive(cmd,args)
