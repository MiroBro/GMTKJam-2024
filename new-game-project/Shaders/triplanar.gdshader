shader_type spatial;

uniform sampler2D top_texture : source_color;
uniform sampler2D front_texture : source_color;
uniform sampler2D side_texture : source_color;
uniform vec3 top_tint;
uniform vec3 front_tint;
uniform vec3 side_tint;

uniform float scale;

//void vertex() {
	// Called for every vertex the material is visible on.
//}

void fragment() {
	mat4 INV_MODEL_MATRIX = inverse(MODEL_MATRIX);
	vec3 extracted_scale = vec3(length(MODEL_MATRIX[0]), length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
	vec3 projected_coords = (INV_MODEL_MATRIX * (INV_VIEW_MATRIX * vec4(VERTEX, 1.0))).xyz * extracted_scale;
	
	vec3 albedoX = texture(side_texture, projected_coords.zy * scale).rgb * side_tint;
	vec3 albedoY = texture(top_texture, projected_coords.xz * scale).rgb * top_tint;
	vec3 albedoZ = texture(front_texture, projected_coords.xy * scale).rgb * front_tint;
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 local_normal = ((INV_MODEL_MATRIX * vec4(world_normal, 0.0))).xyz;
	vec3 abs_normal = abs(local_normal);
	vec3 normal_weights = abs_normal / (abs_normal.x + abs_normal.y + abs_normal.z);
	ALBEDO = albedoX * normal_weights.x + albedoY * normal_weights.y + albedoZ * normal_weights.z;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
