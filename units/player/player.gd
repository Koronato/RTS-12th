extends CharacterBody2D

@export var speed : float = 100
@export var MaxSpeed : float = 1200
@export var friction : float = 0.95
@export var camera : Camera2D

var ix : float = 0.0
var iy : float = 0.0


func _physics_process(delta: float) -> void:
	#---玩家移动---#
	#判定输入
	if Input.is_action_pressed("player_forward"):
		iy -= speed
	if Input.is_action_pressed("player_back"):
		iy += speed
	if Input.is_action_pressed("player_right"):
		ix += speed
	if Input.is_action_pressed("player_left"):
		ix -= speed
	#限制范围
	ix = clampf(ix,-1*MaxSpeed,MaxSpeed)
	iy = clampf(iy,-1*MaxSpeed,MaxSpeed)
	#特殊量
	#-简陋摩擦力实现
	ix *= friction
	iy *= friction
	if ix < 0.01 and ix > -0.01:
		ix = 0
	if iy < 0.01 and iy > -0.01:
		iy = 0
	#加上
	self.velocity = Vector2(ix,iy)
	move_and_slide()
	
	#---方向判断---
	var face_r : float = 0
	if camera: #当有camera时
		if get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position()):
			var mouse_point = camera.get_global_mouse_position()
			face_r = (mouse_point - self.global_position).angle() + PI/2
			self.global_rotation = lerp_angle(self.global_rotation,face_r,0.1)
	else:     #无camera时
		if get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position()):
			var mouse_point = get_viewport().get_mouse_position()
			face_r = (mouse_point - self.global_position).angle() + PI/2
			self.global_rotation = lerp_angle(self.global_rotation,face_r,0.1)
