@tool
extends MeshInstance3D
class_name VoxTerrainGenrator

@export var Generate_Terrain = false
@export var Clear_Terrain = false
@export var Generate_Collision = false
@export var Clear_Collision = false

@export var Height_Scale = float(1.0)

@export var texture : Texture2D
@export var Height : Texture2D
@export var Voxel_Material: Material # this material is what will give the mesh its software voxel look
# this is done by using the "use point size" option, each point of the mesh will render as a pixel coloured by it vertex colour (if use vertex colours is enabled)
# the effect will look different depending on the point size and screen resolution so you will have to take that into consideration



func _Generate_Terrain_mesh():
	
	var img = Image.load_from_file(texture.resource_path)
	var Nimg = Image.load_from_file(Height.resource_path) # texture and heightmap are stored to a var for  quick access
	
	var AMesh = ArrayMesh.new() 
	
	var Surfface_Array = []
	Surfface_Array.resize(Mesh.ARRAY_MAX)
	
	var verts = PackedVector3Array()
	var normals = PackedVector3Array()
	var uv = PackedVector2Array()
	var color = PackedColorArray()
	# above arrays are for generating the point mesh
	
	
	for PW in range(img.get_width()):
		for PH in range(img.get_height()): # go through pixels colomn by colomn
			
			var Scale_Height = Height_Scale * 10 # the abstraction for the Height scale option
			
			var H = Nimg.get_pixel(PH,PW).get_luminance() * Scale_Height # the pixel lumen value is used for determining height 
			#since the lumen is stored as a float between 0 and 1 you will  have to multiply it by 10
			
			
			verts.append(Vector3(PW,H,PH))
			normals.append(Vector3(0,1,0))
			color.append(img.get_pixel(PH,PW))
			uv.append(Vector2(PW,PH)) # and assign values to above arrays
	
	Surfface_Array[Mesh.ARRAY_VERTEX] = verts
	Surfface_Array[Mesh.ARRAY_TEX_UV] = uv
	Surfface_Array[Mesh.ARRAY_NORMAL] = normals
	Surfface_Array[Mesh.ARRAY_COLOR] = color # this sets the vertex colour to the colour of the pixel it is associated with  
	AMesh.add_surface_from_arrays(AMesh.PRIMITIVE_POINTS, Surfface_Array)
	AMesh.surface_set_material(0,Voxel_Material)
	self.mesh = AMesh  # mesh is generated and material applied


# the same process above is used (with some changes) to generate the collision
func _Generate_Collision():
	
	var img = Image.load_from_file(texture.resource_path)
	var Nimg = Image.load_from_file(Height.resource_path)
	
	var ColH = PackedFloat32Array()
	
	for PW in range(img.get_width()):
		for PH in range(img.get_height()):
			
			var Scale_Height = Height_Scale * 10
			
			var H = Nimg.get_pixel(PW,PH).get_luminance() * Scale_Height
			
			ColH.append(H)
			
	var shape = HeightMapShape3D.new()
	var Collider = CollisionShape3D.new()
	shape.map_width = Nimg.get_width()
	shape.map_depth = Nimg.get_height()
	shape.map_data = ColH
	
	Collider.shape = shape
	
	var Body = StaticBody3D.new()
	
	add_child(Body)
	Body.set_owner(get_tree().edited_scene_root)
	
	Body.add_child(Collider)
	
	@warning_ignore("integer_division")
	var pos = img.get_width() / 2 # the collision wont be centered within the terrain so we will have to adjust it to compensate
	
	Collider.position = Vector3(pos,0,pos)
	Collider.set_owner(get_tree().edited_scene_root)


func _process(_delta):
	
	if Generate_Terrain and not _Generate_Terrain_mesh():
		if not self.mesh == null:
			self.mesh = null
		Generate_Terrain = false
		_Generate_Terrain_mesh()
	if Generate_Collision:
		if get_child_count() >= 1:
			for node in get_children():
				node.queue_free()
		Clear_Collision = false
		Generate_Collision = false
		_Generate_Collision()
	if Clear_Terrain:
		if not self.mesh == null:
			self.mesh = null
		Clear_Terrain = false
	if Clear_Collision:
		if get_child_count() >= 1:
			for node in get_children():
				node.queue_free()
		Clear_Collision = false

