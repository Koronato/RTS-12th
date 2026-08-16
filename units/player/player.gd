extends Sprite2D

@export var MaxSpeed : float = 10 
@export var friction : float = 0.9

var ix : float = 0.0
var iy : float = 0.0


func _physics_process(delta: float) -> void:
	#---玩家移动---#
	#判定输入
	if Input.is_action_pressed("player_forward"):
		iy -= 2
	if Input.is_action_pressed("player_back"):
		iy += 2
	if Input.is_action_pressed("player_right"):
		ix += 2
	if Input.is_action_pressed("player_left"):
		ix -= 2
	#限制范围
	ix = clampf(ix,-1*MaxSpeed,MaxSpeed)
	iy = clampf(iy,-1*MaxSpeed,MaxSpeed)
	#特殊量
	#-简陋摩擦力实现
	ix *= friction
	iy *= friction
	if ix < 0.001 and ix > -0.001:
		ix = 0
	if iy < 0.001 and iy > -0.001:
		iy = 0
	#加上
	self.position += Vector2(ix,iy)
	
	#---方向判断---
	var mouse_point = get_viewport().get_mouse_position()
	var face_r = (mouse_point - self.global_position).angle() + PI/2
	self.global_rotation = lerp_angle(self.global_rotation,face_r,0.1)
