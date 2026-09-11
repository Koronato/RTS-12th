### NOTICE : MOST OF func in this lib are for CUBE FLAT , IF you want to use with CUBE POINTY , PLEASE ATTENTION
##  NOTICE : cube(x,y,z)(q,r,s)  axial(x,y)(q,r)
extends RefCounted
class_name CubeCoord

#常见枚举
enum CUBE_DIRECTION_FLAT{
	TOP = 0,
	RIGHT_TOP = 1,
	RIGHT_BOTTOM = 2,
	BOTTOM = 3,
	LEFT_BOTTOM = 4,
	LEFT_TOP = 5
}
const CubeDirectionFlatDict := {
	CUBE_DIRECTION_FLAT.TOP : Vector3i(0,-1,1),
	CUBE_DIRECTION_FLAT.RIGHT_TOP : Vector3i(1,-1,0),
	CUBE_DIRECTION_FLAT.RIGHT_BOTTOM : Vector3i(1,0,-1),
	CUBE_DIRECTION_FLAT.BOTTOM : Vector3i(0,1,-1),
	CUBE_DIRECTION_FLAT.LEFT_BOTTOM : Vector3i(-1,1,0),
	CUBE_DIRECTION_FLAT.LEFT_TOP : Vector3i(-1,0,1),
}

#获取方向
static func cube_direction(d:Variant) -> Vector3i:
	if d is int:
		if CUBE_DIRECTION_FLAT.find_key(d) == null: #判错
			push_error("Unknown Direction Num %s" % d)
			return Vector3i.ZERO
		return CubeDirectionFlatDict[d] #返回方向
		
	if d is String:
		d = d.to_upper() #去除大小写差异
		if !CUBE_DIRECTION_FLAT.has(d):
			push_error("Unknown Direction Type %s" % d)
			return Vector3i.ZERO
		
		return CubeDirectionFlatDict[CUBE_DIRECTION_FLAT[d]] #返回
	push_error("Invalid Args %s, Args must be enum or String" % d)
	return Vector3i.ZERO
static func cube_d_str_to_int(d:String) -> int:  #字符串到索引值
	d = d.to_upper()
	if !CUBE_DIRECTION_FLAT.has(d):
			push_error("Unknown Direction Type %s" % d)
			return -1
	return CUBE_DIRECTION_FLAT[d]
#判断有效
static func is_valid(coord:Vector3i) -> bool:
	if coord.x + coord.y + coord.z == 0: #x + y + z = 0
		return true
	else:
		return false
static func check_validity(coord:Vector3i) -> void:
	#This function will push_error instead return bool
	if coord.x + coord.y + coord.z == 0:
		return
	else:
		push_error("%v is not a cube coord" % coord)

#转换
static func cube_to_axial(coord:Variant):
	if coord is Vector3i:
		check_validity(coord)
		return Vector2i(coord.x,coord.y)        #!
	if coord is Array[Vector3i]:
		var result:Array[Vector2i]
		for c in coord:
			result.append(Vector2i(c.x,c.y))    #!
		return result
	push_error("%s is invaild" % coord)
	return Vector2i.ZERO
	
static func axial_to_cube(coord:Variant):
	if coord is Vector2i:
		return Vector3i(coord.x,coord.y,-coord.x-coord.y) #!
	if coord is Array[Vector2i]:
		var result : Array[Vector3i]
		for c in coord:
			result.append(Vector3i(c.x,c.y,-c.x-c.y))     #!
		return result
	push_error("%s is invaild" % coord)
	return Vector3i.ZERO
#像素(xOy)
static func cube_to_local(coord:Variant,scale:Vector2=Vector2.ONE,offset:Vector2=Vector2.ZERO):
	if coord is Vector3i:
		var x:float = (3.0/2.0) * coord.x * scale.x
		var y:float = ((sqrt(3)/2.0) * coord.x + sqrt(3) * coord.y) * scale.y
		return Vector2(x,y)+offset
	if coord is Array[Vector3i]:
		var result:Array[Vector2]
		for c in coord:
			var x:float = (3.0/2.0) * c.x * scale.x
			var y:float = ((sqrt(3)/2.0) * c.x + sqrt(3) * c.y) * scale.y
			result.append(Vector2(x,y)+offset)
		return result
	push_error("%s is invaild" % coord)
	return Vector2.ZERO
static func local_to_cube(coord: Variant, scale: Vector2 = Vector2.ONE, offset: Vector2 = Vector2.ZERO) -> Variant:
	if coord is Vector2 or coord is Vector2i:
		var p := Vector2(coord) - offset

		var q := (2.0 / 3.0) * p.x / scale.x
		var r := (-1.0 / 3.0) * p.x / scale.x + (sqrt(3.0) / 3.0) * p.y / scale.y

		return cube_round(Vector3(q, r, -q - r))

	if coord is Array:
		var result: Array[Vector3i] = []
		for c in coord:
			var p := Vector2(c) - offset

			var q := (2.0 / 3.0) * p.x / scale.x
			var r := (-1.0 / 3.0) * p.x / scale.x + (sqrt(3.0) / 3.0) * p.y / scale.y

			result.append(cube_round(Vector3(q, r, -q - r)))
		return result

	push_error("%s is invalid" % coord)
	return Vector3i.ZERO
#针对TileSet hex,diamond down
static func cube_to_cell(coord:Variant):
	if coord is Vector3i:
		return Vector2i(-coord.y,coord.z)
	if coord is Array[Vector3i]:
		var result:Array[Vector2i]
		for c in coord:
			result.append(Vector2i(-c.y,c.z))
		return result
	push_error("%s is invaild" % coord)
	return Vector2i.ZERO
static func cell_to_cube(coord:Variant):
	if coord is Vector2i:
		return Vector3i(coord.x-coord.y,-coord.x,coord.y)
	if coord is Array[Vector2]:
		var result:Array[Vector3i]
		for c in coord:
			result.append(Vector3i(c.x-c.y,-c.x,c.y))
		return result
	push_error("%s is invaild" % coord)
	return Vector2i.ZERO
#距离公式
static func cube_distance(from_point:Vector3i,to_point:Vector3i) -> int:
	var vec := from_point - to_point
	return int((abs(vec.x) + abs(vec.y) + abs(vec.z)) / 2) #(dx+dy+dz)/2

#取近似
static func cube_round(coord:Vector3) -> Vector3i:
	var coordi:Vector3i = coord.round()
	#取差
	var dx = abs(coord.x-coordi.x)
	var dy = abs(coord.y-coordi.y)
	var dz = abs(coord.z-coordi.z)
	
	if dx > dy and dx > dz:
		coordi.x = -1*coordi.y-coordi.z
	elif dy > dz:
		coordi.y = -1*coordi.x-coordi.z
	else :
		coordi.z = -1*coordi.x-coordi.y
	return coordi
	
#画线方法 NOTICE 暂时未实现偏移 因此可能出现抖动
static func get_line_raw(from_point:Vector3i,to_point:Vector3i,_epsilon:bool=true) -> Array[Vector3]:
	var result:Array[Vector3] = []
	var dist = cube_distance(from_point,to_point)
	if dist == 0:
		return [from_point]
	var point_a = Vector3(from_point)
	var point_b = Vector3(to_point)
	var i:int = 0
	while i <= dist:
		result.append(lerp(point_a,point_b,float(i)/float(dist)))
		i += 1
	return result
static func get_line(from_point:Vector3i,to_point:Vector3i,epsilon:bool=true) -> Array[Vector3i]:
	var result:Array[Vector3i] = []
	for i in get_line_raw(from_point,to_point,epsilon):
		result.append(cube_round(i))
	return result

#范围方法
static func get_range(center:Vector3i,r:int) -> Array[Vector3i]:
	var result:Array[Vector3i] = []
	for x in range(-1*r,r+1):
		for y in range(max(-r,-x-r),min(r,-x+r)+1):
			var z = -x-y
			result.append(center + Vector3i(x,y,z))
	return result

#获取邻居方法
static func cube_neighbor(point:Vector3i,direction:Variant,s:int=1) -> Vector3i:
	return point + cube_direction(direction) * s
static func cube_neighbor_all(point:Vector3i,s:int=1) -> Array[Vector3i]:
	var result:Array[Vector3i] = []
	for i in range(0,6):
		result.append(point + cube_direction(i)*s)
	return result

#环 方法  NOTICE 暂未验证,可能出现问题
static func cube_ring(center:Vector3i,radius:int,start_direction:Variant=0) -> Array[Vector3i]:
	# in this function , 'd' means direction
	var result:Array[Vector3i] = []
	var d:int = 0 #为什么参数不可变 😡(怒)
	#值的合法判断
	if radius <= 0:  #当radius<=0时,接下来的代码无意义,提前结束
		push_warning("The radius:%s <= 0,ring will return center" % radius)
		return [center]
	if not (start_direction is int or start_direction is String):
		push_error("Invalid type of agrs %s" % start_direction)
		return [center]
	if start_direction is String:
		d = cube_d_str_to_int(start_direction)
	else:
		d = start_direction % 6
	
	var ring_point:Vector3i = center + cube_direction(d) * radius
	var move_d:int #the direction on the loop of side(j)
	for i in range(0,6):
		move_d = (d+2)%6
		for j in range(0,radius):
			result.append(ring_point)
			ring_point = cube_neighbor(ring_point,move_d)
		d = (d + 1) % 6
	return result
  #if you want spiral instead range , this is a good way
static func cube_spiral_ring(center:Vector3i,radius:int,start_direction:Variant=0) -> Array[Vector3i]:
	var result:Array[Vector3i] = [center]
	for i in range(1,radius+1):
		result.append_array(cube_ring(center,i,start_direction))
	return result
