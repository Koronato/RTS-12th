#NOTICE:This class is used on MapGenerate,Using in other places is not Recommend,but also work
extends RefCounted
class_name MapGen

##Needs Data
@export var map_options : MapOptions

##global
#@export var map_pic:Image
@export var map:Array
@export var status:String = "ENPTY"

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
func noise_gen(options:MapOptions) -> Array[float]:
	var noise = FastNoiseLite.new()
	noise.seed = options.map_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = options.noise_frequency
	
	var pic = NoiseTexture2D.new()
	pic.height = options.map_height
	pic.width = options.map_width
	pic.noise = noise
	await pic.changed
	
	var img := pic.get_image()
	var result:Array[float]
	for x in pic.width:
		for y in pic.height:
			result.append(img.get_pixel(x,y).v)
	if not result:
		push_error("Generate Failed at noise_gen")
	return result
#地形判断
func tile_decide(v:float):
	if v <= 1.0 and v >= map_options.WaSpro:
		return TilesL0[TileList.DUST]
	if v < map_options.WaSpro and v>=0:
		return TilesL0[TileList.WATRE]
	
	return TilesL0[TileList.STONE]

#生成 主程序
func _main():
	status = "Noise Generating"

	var v := await noise_gen(map_options)
	var layer := {}
	
	status = "Tile setting at Layer 0"
	var step:int = 0
	for x in map_options.map_width:
		for y in map_options.map_width:
			var deepth = v[step]
			var coord = CubeCoord.cube_to_cell(CubeCoord.local_to_cube(Vector2(x,-y)))
			
			layer.set(coord,tile_decide(deepth))
			#print("set %v" % coord)
			step += 1
	map.append(layer)
	
	map_gen_done.emit()
	status = "ENPTY"

func _debug(_s:int):
	status = "DEBUG"
	pass
	status = "ENPTY"
