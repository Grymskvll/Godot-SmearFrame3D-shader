// TODO: use 3D noise texture if/when it's added to Godot

// Please make sure your mesh is smooth shaded! Otherwise the smear gets 
// fragmented.

shader_type spatial;

uniform bool smear_enabled = true;

// If smear_amount is 1 and there's no noise added, the vertex will at most get
// smeared to its position on the previous frame (if vertex normal is aligned 
// with movement). At >1 (or with noise added) it can extend past its position 
// on previous frame.
uniform float smear_amount = 2;

// Amount of smear ahead of/behind our motion:
uniform float front_smear_factor: hint_range(0, 1) = 0.3;
uniform float rear_smear_factor: hint_range(0, 1) = 1;

// Treat the vertex normal as if it's better aligned with or against our
// movement (this prevents pinching in complex meshes (mostly useful if noise 
// factor is low)):
uniform float front_normal_bias: hint_range(0, 1) = 0.25;
uniform float rear_normal_bias: hint_range(0, 1) = 0.25;

// How much noise to add to the smear:
uniform float noise_factor: hint_range(0, 1) = 0.3;
uniform float noise_max = 1;	// How far the noise spikes extend from the mesh
uniform float noise_min = -0.5;	// How far the noise spikes extend into the mesh

//uniform sampler3D noise_tex;
uniform sampler2D noise_tex;	// We sample this texture for noise

// Translation of reference point since last frame (edited from script).
// Could be mesh origin. Could be a bone, or something else.
uniform vec3 _transl = vec3(0,0,0);

// Not built in
float range_lerp(float value, float istart, float istop, float ostart, float ostop) {
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

vec3 smear(vec3 vertex, vec3 normal, mat4 mv_matrix) {
	if (!smear_enabled || _transl == vec3(0,0,0)) {
		return vec3(0,0,0);
	}
	
	vec3 smear_transl = _transl;	// Copy so we can edit it
	
	// Bias normals with/against movement:
	vec3 trans_norm = normalize(smear_transl);
	vec3 vert_norm = normal.xyz;
	float dir_dot = dot(trans_norm, vert_norm);
	if (dir_dot < 0f) {
		// slerp is more accurate but expensive so nlerp suffices I think
		vert_norm = normalize(mix(vert_norm, -trans_norm, rear_normal_bias));
	} else {
		vert_norm = normalize(mix(vert_norm, trans_norm, front_normal_bias));
	}
	dir_dot = dot(trans_norm, vert_norm);
	
	// Limit front/rear smear:
	dir_dot = clamp(dir_dot, -rear_smear_factor, front_smear_factor);
	smear_transl = smear_transl.xyz * smear_amount * dir_dot;
	
	// Add noise:
	// Weird workaround for not having 3D noise texture: we convert the vertex
	// coordinates from model space to view space and sample using xy (z is 
	// depth from camera PoV).
	vec2 noise_coords = (mv_matrix * vec4(vertex, 1.0)).xy;
	float noise = range_lerp(texture(noise_tex, noise_coords).r, 0, 1, noise_max, noise_min);
	smear_transl = mix(smear_transl, smear_transl * noise, noise_factor);
	
	return smear_transl;
}

void vertex() {
	VERTEX.xyz += smear(VERTEX.xyz, NORMAL.xyz, MODELVIEW_MATRIX);
}




