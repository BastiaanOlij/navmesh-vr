extends RayCast

var current_collider = null

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if (is_enabled()):
		if (is_colliding()):
			var colliding_with = get_collider()
			
			if (current_collider):
				if (colliding_with == current_collider):
					return
				
				# tell our current collider we are longer colliding
				current_collider.set_colliding(false)
			
			# tell our new collider we are colliding
			current_collider = colliding_with
			current_collider.set_colliding(true)
		elif (current_collider):
			# tell our current collider we are longer colliding
			current_collider.set_colliding(false)
			current_collider = null