class_name Drag3D extends Spatial

export(bool) var enabled = true setget set_enabled, get_enabled
export(String) var drag_group_name = "Drag3D"
export(float) var grab_distance_max = 1000
export(bool) var perspective_correction = true

var drag_obj
var drag_depth = 0
var drag_ofs = Vector3.ZERO


func _physics_process(_delta):
	if Input.is_action_just_pressed("mouse_left"):
		_check_collision()
	
	if Input.is_action_just_released("mouse_left"):
		release()

	if drag_obj:
		_update_obj_pos()


func _check_collision():
	var camera = get_viewport().get_camera()
	
	var pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(pos)
	var to = from + camera.project_ray_normal(pos) * grab_distance_max
	var space_state = get_world().direct_space_state
	var col_res = space_state.intersect_ray(from, to, [self])
	
	if not col_res \
	or not col_res.collider.is_in_group(drag_group_name):
		return

	drag_obj = col_res.collider
	var drag_obj_pos = drag_obj.global_transform.origin
	drag_ofs = col_res.position - drag_obj_pos

	if perspective_correction:
		var cam_normal = -camera.get_camera_transform().basis.z
		drag_depth = cam_normal.dot(col_res.position - from)
	else:
		drag_depth = from.distance_to(col_res.position)


func _update_obj_pos():
	var camera = get_viewport().get_camera()
	
	var dest
	var pos = get_viewport().get_mouse_position()

	if perspective_correction:
		dest = camera.project_position(pos, drag_depth)
	else:
		var from = camera.project_ray_origin(pos)
		dest = from + camera.project_ray_normal(pos) * drag_depth

	drag_obj.global_transform.origin = dest - drag_ofs


func release():
	drag_obj = null


func set_enabled(setting: bool):
	enabled = setting
	set_physics_process(setting)
	if setting == false:
		release()

func get_enabled():
	return enabled
