extends Node

var orientation = Matrix3()
var threshold = 0.1
var reference_frame = Matrix3()
var null_orientation = Matrix3()
var frames = 0
var request_reference_frame = true

func get_orientation():
	var result = null_orientation
	result = result * reference_frame
	result = result * orientation
	return result
	
func request_new_reference_frame():
	request_reference_frame = true
	
func set_null_orientation(p_null_orientation):
	null_orientation = p_null_orientation

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	
func _process(delta):
	var acc = Input.get_accelerometer()
	var grav = Input.get_gravity()
	var gyro = Input.get_gyroscope()
	if grav.length() <= threshold:
		grav = acc
	
	if OS.get_name() == "Android":
		grav = Vector3(-grav.x, grav.y, -grav.z)
		gyro = Vector3(-gyro.x, gyro.y, -gyro.z)
	
	var rotate = Matrix3()
	rotate = rotate.rotated(orientation.x, -gyro.x * delta)
	rotate = rotate.rotated(orientation.y, -gyro.y * delta)
	rotate = rotate.rotated(orientation.z, -gyro.z * delta)
	orientation = rotate * orientation

	if grav.length() > threshold:
		var down = Vector3(0.0, -1.0, 0.0)
		
		var grav_adj = orientation.xform(grav.normalized())
		
		var dot = grav_adj.dot(down)
		if ((dot > -1.0) && (dot < 1.0)):
			var axis = grav_adj.cross(down)
			axis = axis.normalized()
			
			var rotate = Matrix3()
			rotate = rotate.rotated(axis, -acos(dot) * 0.2)
			orientation = rotate * orientation
	
	frames = frames + 1
	if frames < 10:
		return
	
	if request_reference_frame:
		request_reference_frame = false
		var reference = Matrix3()
		reference.z = Vector3(orientation.z.x, 0.0, orientation.z.z).normalized()
		reference.y = Vector3(0.0, 1.0, 0.0)
		reference.x = reference.y.cross(reference.z)
		reference_frame = reference.inverse()