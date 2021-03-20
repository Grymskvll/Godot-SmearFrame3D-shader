// TODO: use 3D noise texture if/when it's added to Godot

shader_type spatial;

uniform bool smear_enabled = true;
uniform float smear_amount = 2;
uniform float front_smear_factor: hint_range(0, 1) = 0.3;
uniform float rear_smear_factor: hint_range(0, 1) = 1;
uniform float front_normal_bias: hint_range(0, 1) = 0.25;
uniform float rear_normal_bias: hint_range(0, 1) = 0.25;
uniform float noise_factor: hint_range(0, 1) = 0.3;
uniform float noise_max = 1;
uniform float noise_min = -0.5;
//uniform sampler3D noise_tex;
uniform sampler2D noise_tex;

uniform vec3 _transl = vec3(0,0,0);

float range_lerp(float value, float istart, float istop, float ostart, float ostop) {
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

vec3 smear(vec3 vertex, vec3 normal, mat4 mv_matrix) {
	if (!smear_enabled || _transl == vec3(0,0,0)) {
		return vec3(0,0,0);
	}
	
	vec3 smear_transl = _transl;
	
	vec3 trans_norm = normalize(smear_transl);
	vec3 vert_norm = normal.xyz;
	float dir_dot = dot(trans_norm, vert_norm);
	if (dir_dot < 0f) {
		vert_norm = normalize(mix(vert_norm, -trans_norm, rear_normal_bias));
	} else {
		vert_norm = normalize(mix(vert_norm, trans_norm, front_normal_bias));
	}
	dir_dot = dot(trans_norm, vert_norm);
	dir_dot = clamp(dir_dot, -rear_smear_factor, front_smear_factor);
	smear_transl = smear_transl.xyz * smear_amount * dir_dot;
	
	vec2 noise_coords = (mv_matrix * vec4(vertex, 1.0)).xy;
	float noise = range_lerp(texture(noise_tex, noise_coords).r, 0, 1, noise_max, noise_min);
	smear_transl = mix(smear_transl, smear_transl * noise, noise_factor);
	
	return smear_transl;
}

void vertex() {
	VERTEX.xyz += smear(VERTEX.xyz, NORMAL.xyz, MODELVIEW_MATRIX);
}




