@tool
extends Node3D
class_name TerrainGenerator
@export var Generate = false
@export var Clear_Terrain = false

@export var Voxel_Scale = float(1)
@export var Height_Scale = float(1)

@export var texture : Texture2D
@export var Height : Texture2D

func _Generate_Terrain():
	
	var Size = Voxel_Scale * 180
	
	var img = Image.load_from_file(texture.resource_path)
	var Nimg = Image.load_from_file(Height.resource_path)
	
	
	
	
	for W in range(img.get_width()):
		for ph in range(img.get_height()):
			var Voxel = Sprite3D.new()
			
			
			Voxel.texture = load("res://GFX/Pixel.png")
			Voxel.modulate = img.get_pixel(ph,W)
			Voxel.billboard = true
			add_child(Voxel)
			Voxel.set_owner(get_tree().edited_scene_root)
			
			var Scale_Height = Height_Scale * 10
			
			var H = Nimg.get_pixel(ph,W).get_luminance() * Scale_Height
			
			Voxel.scale = Vector3(Size,Size,Size)
			Voxel.position = Vector3(ph,H,W)




func _process(_delta):
	
	if Generate:
		if get_child_count() >= 0:
			for node in get_children():
				node.queue_free()
		_Generate_Terrain()
	if Clear_Terrain:
		if get_child_count() >= 0:
			print(get_child_count()," Children deleted.")
			for node in get_children():
				node.queue_free()
	Generate = false
	Clear_Terrain = false
