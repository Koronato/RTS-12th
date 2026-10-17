extends Camera2D

@export var focus : Node2D = null
@export var move : bool = false
@export var speed : Vector2 = Vector2(10,10)

func _physics_process(delta: float) -> void:
	_move()

func _move() -> void:
	if !move:
		return
	if !focus:
		var ix : float = 0.0
		var iy : float = 0.0
		if Input.is_action_pressed("up"):
			iy = -speed.y
		if Input.is_action_pressed("down"):
			iy = speed.y
		if Input.is_action_pressed("left"):
			ix = -speed.x
		if Input.is_action_pressed("right"):
			ix = speed.x
		
		self.position += Vector2(ix,iy)
		return
	if focus:
		self.position = focus.position
		return
