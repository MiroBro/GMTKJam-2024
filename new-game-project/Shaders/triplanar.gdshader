shader_type spatial;

uniform sampler2D side_texture : source_color;
uniform sampler2D front_texture : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    float scale = 20.0;
	// Called for every pixel the material is visible on.
	vec4 projected_coords = INV_VIEW_MATRIX * vec4(VERTEX, 1.0) * scale;
	 vec3 albedoX = texture(front_texture, projected_coords.zy).rgb;
	 vec3 albedoY = texture(side_texture, projected_coords.xz).rgb;
	 vec3 albedoZ = texture(side_texture, projected_coords.xy).rgb;
	vec3 world_normal = abs(INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 normal_weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);
	ALBEDO = albedoX * normal_weights.x + albedoY * normal_weights.y + albedoZ * normal_weights.z;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
