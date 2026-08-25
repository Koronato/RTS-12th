#NOTICE:This class is used on MapGenerate,Using in other places is not Recommend,but also work
extends Node
class_name MapGen

#Needs Data
@export var map_seed:int
@export var map_height:int
@export var map_width:int

@export var noise_frequency:float
@export var custom_pic:Image
@export var WaSpro:float = 0.5 # == Water and Soil proprotion
@export var TMP:Array[TileMapLayer]

#global
@export var map_pic:Image
#@export var map:Array
@export var status:String = "NO PROCESSS"

signal map_gen_done

enum TileList{
	WATRE=0,
	DUST=1,
	STONE=2,
}
#TilesL0 == Tiles layout zero
const TilesL0 = {   
	TileList.WATRE:Vector2i(2,0),
	TileList.DUST:Vector2i(0,0),
	TileList.STONE:Vector2i(0,1),
}

#噪声生成
func noise_gen(seed:int,width:int,height:int,frequency:float) -> Array[float]:
	var noise = FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = frequency
	
	var pic = NoiseTexture2D.new()
	pic.height = height
	pic.width = width
	pic.noise = noise
	await pic.changed
	
	var img := pic.get_image()
	var result:Array[float]
	for x in width:
		for y in height:
			result.append(img.get_pixel(x,y).v)
	if not result:
		push_error("Generate Failed at noise_gen")
	return result
#地形判断
func tile_decide(v:float):
	if v <= 1.0 and v >= WaSpro:
		return TilesL0[TileList.DUST]
	if v < WaSpro and v>=0:
		return TilesL0[TileList.WATRE]
	
	return TilesL0[TileList.STONE]

#生成 主程序
func _main():
	status = "Noise Generating"
	var v0 := await noise_gen(map_seed,map_width,map_height,noise_frequency)
	
	status = "Tile setting at Layer 0"
	var step:int = 0
	for x in map_width:
		for y in map_height:
			var deepth = v0[step]
			var coord = CubeCoord.cube_to_cell(CubeCoord.local_to_cube(Vector2(x,-y)))
			coord.y = coord.y
			coord.x = coord.x
			TMP[0].set_cell(coord,
				0,
				tile_decide(deepth),)
			#print("set %v" % coord)
			step += 1
	
	map_gen_done.emit()
func _debug(s:int):
	status = "DEBUG"
	for x in range(s):
		for y in range(s):
			var coord = CubeCoord.cube_to_cell(CubeCoord.local_to_cube(Vector2(x,-y)))
			TMP[0].set_cell(coord,1,Vector2i(0,0))
			
