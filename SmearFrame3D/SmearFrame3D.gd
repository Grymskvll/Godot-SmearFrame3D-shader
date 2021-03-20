# TODO:	add exports to access SmearFrame3D.shader uniforms from this script
# 		(smear_enabled, smear_amount, etc)

#tool
class_name SmearFrame3D extends Spatial

export (bool) var enabled = true setget set_enabled
export (float) var smear_amount = true setget set_smear_amount
export (float, 0, 1) var front_smear_factor = 0.3 setget set_front_smear_factor
export (float, 0, 1) var rear_smear_factor = 1 setget set_rear_smear_factor
export (float, 0, 1) var front_normal_bias = 0.25 setget set_front_normal_bias
export (float, 0, 1) var rear_normal_bias = 0.25 setget set_rear_normal_bias
export (float, 0, 1) var noise_factor = 0.3 setget set_noise_factor
export (float) var noise_max = 1 setget set_noise_max
export (float) var noise_min = -0.5 setget set_noise_min
export (int) var tuned_to_fps = 60
export (float) var smear_speed_min = 0.7
export (float) var smear_speed_ease = 1.0
export (int) var noise_tex_width = 256
export (int) var noise_tex_height = 256

onready var smear_target = get_parent()
onready var mat = smear_target.get_active_material(0)
onready var _prev_position = smear_target.global_transform.origin
onready var _position = smear_target.global_transform.origin
onready var noise_tex = NoiseTexture.new()

#func _get_configuration_warning():
#	if not smear_target as GeometryInstance:
#		return 'Not under a GeometryInstance'
#	return ''

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		smear_target = get_parent()
		mat = smear_target.get_active_material(0)
#		update_configuration_warning()

func _ready():
#	if Engine.editor_hint:
#		set_process(false)
#		return
	
#	var noise_tex = mat.get_shader_param("noise_tex")
#	noise_tex.noise.seed = randi()
	
	noise_tex.width = noise_tex_width
	noise_tex.height = noise_tex_height
	noise_tex.seamless = true
#	noise_tex.resource_local_to_scene = true
	noise_tex.noise = OpenSimplexNoise.new()
	noise_tex.noise.seed = randi()
	mat.set_shader_param("noise_tex", noise_tex)


#func _process(delta):	# I get stuttering in fullscreen with _process
func _physics_process(delta):
	if delta == 0: return
	_position = smear_target.global_transform.origin
	var transl = _position - _prev_position
	_prev_position = _position

	var dist = transl.length()
	if dist < smear_speed_min:
		transl = Vector3.ZERO
	var mult = 1
	var smear_transl_max = smear_speed_min + smear_speed_ease
	if smear_transl_max > 0:
		mult = min(1, dist / (smear_speed_min + smear_speed_ease))

	var mult_mult = (1.0 / tuned_to_fps) / delta
	transl *= mult * mult_mult

	mat.set_shader_param("_transl", transl)


func _set_shader_param(param, setting):
	if not is_inside_tree(): yield(self, 'ready')
	mat.set_shader_param(param, setting)

func set_enabled(setting):
	enabled = setting
	_set_shader_param("smear_enabled", setting)	# Note different name

func set_smear_amount(setting):
	smear_amount = setting
	_set_shader_param("smear_amount", setting)

func set_front_smear_factor(setting):
	front_smear_factor = setting
	_set_shader_param("front_smear_factor", setting)

func set_rear_smear_factor(setting):
	rear_smear_factor = setting
	_set_shader_param("rear_smear_factor", setting)

func set_front_normal_bias(setting):
	front_normal_bias = setting
	_set_shader_param("front_normal_bias", setting)

func set_rear_normal_bias(setting):
	rear_normal_bias = setting
	_set_shader_param("rear_normal_bias", setting)

func set_noise_factor(setting):
	noise_factor = setting
	_set_shader_param("noise_factor", setting)

func set_noise_max(setting):
	noise_max = setting
	_set_shader_param("noise_max", setting)

func set_noise_min(setting):
	noise_min = setting
	_set_shader_param("noise_min", setting)
