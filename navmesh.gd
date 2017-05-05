
extends Navigation

# Member variables
const SPEED = 4.0

var begin = Vector3()
var end = Vector3()
var m = FixedMaterial.new()

var path = []
var draw_path = false

var camera = null
var orientation = null
var current_navpoint = null

func _process(delta):
	# update our camera location using our sensor data
	var tform = camera.get_transform()
	tform.basis = orientation.get_orientation()
	camera.set_transform(tform)
	
	# process our robots path if required
	if (path.size() > 1):
		var to_walk = delta*SPEED
		var to_watch = Vector3(0, 1, 0)
		while(to_walk > 0 and path.size() >= 2):
			var pfrom = path[path.size() - 1]
			var pto = path[path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			if (d <= to_walk):
				path.remove(path.size() - 1)
				to_walk -= d
			else:
				path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
				to_walk = 0
		
		var atpos = path[path.size() - 1]
		var atdir = to_watch
		atdir.y = 0
		
		var t = Transform()
		t.origin = atpos
		t=t.looking_at(atpos + atdir, Vector3(0, 1, 0))
		get_node("robot_base").set_transform(t)
		
		if (path.size() < 2):
			path = []


func _update_path():
	var p = get_simple_path(begin, end, true)
	path = Array(p) # Vector3array too complex to use, convert to regular array
	path.invert()

	if (draw_path):
		var im = get_node("draw")
		im.set_material_override(m)
		im.clear()
		im.begin(Mesh.PRIMITIVE_POINTS, null)
		im.add_vertex(begin)
		im.add_vertex(end)
		im.end()
		im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		for x in p:
			im.add_vertex(x)
		im.end()


func _input(event):
	if (event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.pressed):
		# Use the global transform to create the vector to find our location
		var tform = get_node("Stereo_Camera/RayCast").get_global_transform()
		var from = tform.origin
		var to = from + tform.basis.xform(Vector3(0.0, 0.0, -100.0))
		var p = get_closest_point_to_segment(from, to)
		
		begin = get_closest_point(get_node("robot_base").get_translation())
		end = p

		_update_path()

func _on_navpoint_selected(p_navpoint):
	if current_navpoint:
		if (current_navpoint == p_navpoint):
			return
		
		# show this navpoint
		current_navpoint.set_hidden(false)
		
	# select our new navpoint
	current_navpoint = p_navpoint
	
	# hide our new navpoint
	current_navpoint.set_hidden(true)
	
	# move our camera to this location
	var pos = current_navpoint.get_translation()
	camera.set_translation(pos)
	
	# update null orientation for our camera
	var tform = camera.get_transform()
	tform = tform.looking_at(Vector3(0.0, tform.origin.y, 0.0), Vector3(0.0, 1.0, 0.0))
	orientation.set_null_orientation(tform.basis)
	
	# and request a new reference frame
	orientation.request_new_reference_frame()

func _ready():
	set_process_input(true)
	set_process(true)
	m.set_line_width(3)
	m.set_point_size(3)
	m.set_fixed_flag(FixedMaterial.FLAG_USE_POINT_SIZE, true)
	m.set_flag(Material.FLAG_UNSHADED, true)
	#begin = get_closest_point(get_node("start").get_translation())
	#end = get_closest_point(get_node("end").get_translation())
	#call_deferred("_update_path")
	
	camera = get_node("Stereo_Camera")
	orientation = get_node("/root/orientation")
	
	# hook all our navpoints
	for navpoint in get_node("NavPoints").get_children():
		navpoint.connect("NavPoint_selected", self, "_on_navpoint_selected")
	
	# and start at navpoint 1
	_on_navpoint_selected(get_node("NavPoints/NavPoint_1"))

func _on_Reset_Reference_Frame_Btn_pressed():
	orientation.request_new_reference_frame()
