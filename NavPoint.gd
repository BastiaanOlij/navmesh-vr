extends StaticBody
signal NavPoint_selected

var mesh_material
var is_hitting = false
var value = 0

func set_colliding(ray_is_hitting_this):
	is_hitting = ray_is_hitting_this
	if is_hitting:
		value = 0
		set_process(true)
	else:
		set_process(false)
		mesh_material.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(1.0, 1.0, 1.0, 0.7))

func _process(delta):
	value = value + delta
	if (value > 1.0):
		value = 1.0
		set_process(false)
		
		# emit signal
		emit_signal("NavPoint_selected", self)
		
	mesh_material.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(1.0 - value, 1.0 - value, 1.0, 0.7))

func _ready():
	mesh_material = FixedMaterial.new()
	mesh_material.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(1.0, 1.0, 1.0, 0.7))
	get_node("Mesh").set_material_override(mesh_material)
