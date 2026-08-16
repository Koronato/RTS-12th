extends Sprite2D

enum Status{
	STAND = 0,
	MOVE = 1,
	BROKEN = 2
}
@export var status : Status
var increment : float = 0.002
var inner_flame
var speed : float = 2.5
var p : float = 0.0

func _ready() -> void:
	inner_flame = get_node("inner_flame")
	
func _process(delta: float) -> void:
	p += speed * delta
	p = wrapf(p,0.0,2*PI)
	match status:
		Status.STAND:
			var t = sin(p)
			var s = lerp(0.7,0.85,t)
			inner_flame.scale = Vector2(s,s)
		Status.MOVE:
			pass
		Status.BROKEN:
			pass
