extends TextureRect

@export var b : BaseButton
@onready var button_group = b.button_group
@export var mapsize : int
@export var frequency : float = 0.01
@export var map_seed : int

func _ready() -> void:
	button_group.connect("pressed",Callable(self,"_on_change"))
	mapsize = 64
	map_seed = randi()
	self.texture = await view_summon(map_seed,64)

func _on_change(_gun_mu) -> void:
	var t = %seed.text
	var map_seed = t.hash()
	mapsize = button_group.get_pressed_button().get_meta("mapsize")
	
	self.texture = await view_summon(map_seed,mapsize)
	
func view_summon(mapseed:int,mapsize:int) -> ImageTexture: #噪声生成
	#噪声配置
	var noise = FastNoiseLite.new()
	noise.seed = mapseed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = frequency
	#转化为普通图片
	var i = NoiseTexture2D.new()
	i.noise = noise
	i.width = mapsize
	i.height = mapsize
	await i.changed #等噪声生成完毕
	var img = ImageTexture.create_from_image(i.get_image()) #转化为图片
	#判定区域 (mapsize x mapsize)
	var mimg = img.get_image() #取出image
	mimg.convert(Image.FORMAT_RGB8) #噪声出来的是灰度图
	for y in mapsize:
		for x in mapsize:
			var p = mimg.get_pixel(x,y)
			if p.v >=0.3:
				p = Color("#F2BF7C")
				mimg.set_pixel(x,y,p)
			else:
				p = Color("#3369CC")
				mimg.set_pixel(x,y,p)
	img.set_image(mimg)
	return img
