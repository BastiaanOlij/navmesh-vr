extends Spatial

# info about our HMD
export var iod = 6.5
export var lcd_width = 10.5
export var lcd_lens = 4.0

# info about distortion
export var k1 = 0.01
export var k2 = 0.01
export var upscale = 1.0

# near and far plane
export var near = 0.1
export var far = 100.0

export var world_scale = 100.0

var left_eye_pos = null
var left_viewport = null
var left_eye = null
var left_sprite = null

var right_eye_pos = null
var right_viewport = null
var right_eye = null
var right_sprite = null

var divider = null

func update_cam():
	var f1 = (iod / 2.0) / (2.0 * lcd_lens)
	var f2 = ((lcd_width - iod) / 2.0) / (2.0 * lcd_lens)
	var f3 = (lcd_width / 4.0) / (2.0 * lcd_lens)
	
	# upscale fov
	f3 *= upscale
	var add_width = ((f1 + f2) * (upscale - 1.0)) / 2.0
	f1 += add_width
	f2 += add_width
	
	left_eye.set_frustum(-f2, f1, f3, -f3, near, far)
	right_eye.set_frustum(-f1, f2, f3, -f3, near, far)
	
	left_eye_pos.set_translation(Vector3(-iod * 0.5 / world_scale, 0.0, 0.0))
	right_eye_pos.set_translation(Vector3(iod * 0.5 / world_scale, 0.0, 0.0))
	
	left_sprite.get_material().set_shader_param("lcd_width", lcd_width);
	left_sprite.get_material().set_shader_param("iod", iod);
	left_sprite.get_material().set_shader_param("k1", k1);
	left_sprite.get_material().set_shader_param("k2", k2);
	left_sprite.get_material().set_shader_param("upscale", upscale);
	
	right_sprite.get_material().set_shader_param("lcd_width", lcd_width);
	right_sprite.get_material().set_shader_param("iod", iod);
	right_sprite.get_material().set_shader_param("k1", k1);
	right_sprite.get_material().set_shader_param("k2", k2);
	right_sprite.get_material().set_shader_param("upscale", upscale);

func resize():
	var screen_size = OS.get_window_size()
	var target_size = Vector2(screen_size.x / 2.0, screen_size.y)
	
	left_viewport.set_rect(Rect2(Vector2(0.0, 0.0), Vector2(target_size.x * upscale, target_size.y)))
	right_viewport.set_rect(Rect2(Vector2(0.0, 0.0), Vector2(target_size.x * upscale, target_size.y)))
	
	left_sprite.set_scale(Vector2(1.0 / upscale, 1.0))
	right_sprite.set_scale(Vector2(1.0 / upscale, 1.0))
	right_sprite.set_pos(Vector2(target_size.x, 0.0))
	
	left_sprite.get_material().set_shader_param("aspect_ratio", target_size.x / target_size.y);
	right_sprite.get_material().set_shader_param("aspect_ratio", target_size.x / target_size.y);

	divider.set_pos(Vector2(target_size.x, 0.0))
	divider.set_scale(Vector2(2.0, target_size.y))

func _ready():
	left_eye_pos = get_node("Left_Eye_Pos")
	left_viewport = get_node("Viewport_Left")
	left_eye = get_node("Viewport_Left/Left_Eye")
	left_sprite = get_node("ViewportSprite_Left")
	
	right_eye_pos = get_node("Right_Eye_Pos")
	right_viewport = get_node("Viewport_Right")
	right_eye = get_node("Viewport_Right/Right_Eye")
	right_sprite = get_node("ViewportSprite_Right")
	
	divider = get_node("Divider")
	
	resize()
	
	update_cam()
	
	var root = get_node("/root")
	root.connect("size_changed", self, "resize")

	set_process(true)
	
func _process(delta):
	left_eye.set_global_transform(left_eye_pos.get_global_transform())
	right_eye.set_global_transform(right_eye_pos.get_global_transform())
	