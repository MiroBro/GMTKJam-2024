extends Node3D

@export var points: Array[Vector2] = []
@export var thickness: float = 0.3

@export var camera: Camera3D

var scene_root: Node
var mouse_pos_in_plane = Vector3(0.0, 0.0, 0.0)
var saw_pos = Vector3(0.0, 0.0, 0.0)

var drawing = false

var grid: PackedByteArray
var cell_size = Vector2(0.013, 0.013)
# var cell_size = Vector2(0.1, 0.1)
var plank_size = Vector2(1.05, 0.65)
var plank_half_size = plank_size / 2.0

var plank_corrected = (plank_size - cell_size) / 2.0;

var plank_offset = -Vector3(plank_half_size.x, 0.0, plank_half_size.y)

@export var debug0: Node3D
@export var debug1: Node3D
@export var debug2: Node3D

@export var particles: CPUParticles3D

var grid_width
var grid_height

var cell = Vector3(cell_size.x, thickness, cell_size.y)

@export var normal_bg: AudioStreamPlayer3D
@export var cutting_bg: AudioStreamPlayer3D

@export var rb_template: RigidBody3D

var plank: MeshInstance3D
@export var plank_collision_shape: CollisionShape3D

func _ready() -> void:
	plank = self.get_child(0)

	scene_root = get_tree().current_scene

	var grid_dims = plank_size / cell_size
	grid_width = int(round(grid_dims.x))
	grid_height = int(round(grid_dims.y))
	
	saw_pos = debug0.global_position
	mouse_pos_in_plane = debug0.global_position

	for i in range(grid_width * grid_height):
		grid.append(1)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_direction = camera.project_ray_normal(mouse_pos)
		var plane = Plane(Vector3(0, 1, 0), 0)  # A horizontal plane at y=0
		var intersection = plane.intersects_ray(ray_origin, ray_direction)

		if intersection != null:
			mouse_pos_in_plane = intersection

	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event
		if e.button_index == MOUSE_BUTTON_LEFT:
			drawing = e.pressed
			if drawing:
				points.clear()

		if e.button_index == MOUSE_BUTTON_RIGHT:
			if e.pressed:
				var mouse_2d = Vector2(mouse_pos_in_plane.x, mouse_pos_in_plane.z)
				var pnorm = point_to_grid_space(mouse_2d)
				var idx = grid_space_to_index(pnorm)

				# flood_fill_mesh_from_index(grid, idx)
				var island_indices: PackedInt32Array
				var island_lens: Array[int]
				find_islands(island_indices, island_lens)

				# spawn_rigidbody_version_of_mesh(plank)


func spawn_rigidbody_version_of_mesh(ref: MeshInstance3D):
	var it: RigidBody3D = rb_template.duplicate()
	it.freeze = false
	it.global_position = ref.global_position
	var new_mesh = ref.duplicate()
	ref.mesh = ref.mesh.duplicate()

	var shape = ref.mesh.create_convex_shape()
	var it2: CollisionShape3D = it.get_child(0)
	it2.shape = new_mesh.mesh.create_convex_shape()
	it.add_child(new_mesh)
	scene_root.add_child(it)


var speed = 10.0
var target_speed = 20.0

var normal_from = 0.0
var cutting_from = 0.0

func find_and_delete_islands():
	var island_indices: PackedInt32Array
	var island_lens: Array[int]
	
	find_islands(island_indices, island_lens)
	var i = -1
	var any = false
	for l in island_lens:
		var should_remove = true
		for jjjj in l:
			i += 1
			i = int(i)
			var grid_idx = island_indices[i]
			if grid_idx == 0:
				should_remove = false

		if should_remove:
			camera.add_trauma(2.0)
			i -= l
			var rb_grid = grid.duplicate();
			for j in rb_grid.size():
				rb_grid[j] = 0

			for jjjj in l:
				i += 1
				var grid_idx = island_indices[i]
				grid[grid_idx] = 0
				rb_grid[grid_idx] = 1


			var rb_mesh = plank.mesh.duplicate()
			rb_mesh.clear_surfaces()
			convert_grid_to_mesh(rb_grid, rb_mesh)
			var new_node = plank.duplicate()
			new_node.mesh = rb_mesh
			spawn_rigidbody_version_of_mesh(new_node)
			any = true

	if any:
		plank_collision_shape.shape = plank.mesh.create_convex_shape()


func fix_music():
	if not drawing and not normal_bg.playing:
		normal_bg.play(normal_from)
	if drawing and not cutting_bg.playing:
		cutting_bg.play(cutting_from)
		
	if not drawing:
		cutting_from = cutting_bg.get_playback_position()
		cutting_bg.stop()
	if drawing:
		normal_from = cutting_bg.get_playback_position()
		normal_bg.stop()


func _process(delta: float) -> void:
	particles.emitting = false

	fix_music()

	if drawing:
		camera.add_trauma(0.2)
		speed = lerp(speed, target_speed, 5.0 * delta)

		var mouse_2d = Vector2(mouse_pos_in_plane.x, mouse_pos_in_plane.z)
		var saw_2dd = Vector2(saw_pos.x, saw_pos.z)
		var p = point_to_grid_space(saw_2dd)
		if p.x > 0.0 && p.x < 1.0 && p.y > 0.0 && p.y < 1.0:
			
			var i = grid_space_to_index(p)
			if grid[i] == 1:
				speed = 0.5
		
		if points.size() > 0:
			var old_p = points[0]
			if old_p.distance_to(mouse_2d) > 0.1:
				
				debug0.look_at(mouse_pos_in_plane)
		saw_pos = lerp(saw_pos, mouse_pos_in_plane, delta * speed)

		var saw_2d = Vector2(saw_pos.x, saw_pos.z)

		debug0.global_position = saw_pos
		debug1.global_position = mouse_pos_in_plane

		points.push_back(saw_2d)
		var n =  points.size()
		#if n % 2 == 0 && n > 0:
		if n > 1:
			var cut_any = false
			for i in range(1, n-1):
				cut_any = cut_any or cut_grid_with_points(points[i-1], points[i])

			if cut_any:
				particles.emitting = true
				points.pop_front()

	find_and_delete_islands()
	convert_grid_to_mesh(grid, plank.mesh)

# from 0.0->1.0 in xy
func point_to_grid_space(p: Vector2):
	var pp = p / plank_corrected
	var pnorm = pp / 2.0 + Vector2(0.5, 0.5)
	return pnorm

func grid_space_to_index(pnorm: Vector2):
	var index_pos_cont = pnorm * Vector2(float(grid_width - 1), float(grid_height - 1))
	var index_pos = vector2_round(index_pos_cont)
	var x = int(index_pos.x)
	var y = int(index_pos.y)
	return y * grid_width + x

func point_to_index(p: Vector2):
	var pnorm = point_to_grid_space(p)
	return grid_space_to_index(pnorm)

func index_to_grid_space(i: int):
	var x = i % grid_width
	var y = i / grid_width
	var pnorm = Vector2(float(x), float(y)) / Vector2(float(grid_width - 1), float(grid_height - 1))
	return pnorm

func index_to_world_space(i: int):
	var pnorm = index_to_grid_space(i)
	return grid_space_to_world(pnorm)

func grid_space_to_world(pnorm: Vector2):
	var p = (pnorm - Vector2(0.5, 0.5)) * 2.0
	var middle = p * plank_corrected
	return middle

func vector2_min(a: Vector2, b: Vector2) -> Vector2:
	return Vector2(min(a.x, b.x), min(a.y, b.y))

func vector2_round(v: Vector2) -> Vector2:
	return Vector2(round(v.x), round(v.y))

func vector2_ceil(v: Vector2) -> Vector2:
	return Vector2(ceil(v.x), ceil(v.y))

func vector2_floor(v: Vector2) -> Vector2:
	return Vector2(floor(v.x), floor(v.y))

func vector2_max(a: Vector2, b: Vector2) -> Vector2:
	return Vector2(max(a.x, b.x), max(a.y, b.y))


func cut_grid_with_points(p1: Vector2, p2: Vector2):
	var pp1 = point_to_grid_space(p1)
	var pp2 = point_to_grid_space(p2)

	var any_cuts = false
	var d = pp2-pp1

	if d.length() > 0.000001:
		var m = 100 * max(d.abs().x, d.abs().y)
		d = d / m

		var newp = pp1
		for j in 100:
			var pp1_outside = pp1.x < 0.0 || pp1.y > 1.0
			newp = pp1 + j *d

			if (pp1 - newp).length() > (pp2-pp1).length():
				break
			if !(0 < newp.x && newp.x < 1 && 0 < newp.y && newp.y < 1):
				continue

			var i2 = grid_space_to_index(newp)
			if i2 >= 0 && i2 < grid.size():
				if grid[i2] == 1:
					grid[i2] = 0
					any_cuts = true

	return any_cuts

	#for p in [pp1, pp2]:
	#	var index = grid_space_to_index(int(round(p.x)), int(round(p.y)))
	#	if index >= 0 && index < n:
	#		if grid[index] == 1:
	#			particles.emitting = true
	#		grid[index] = 0

	#for x in range(int(min.x), int(max.x)):
	#	for y in range(int(min.y), int(max.y)):
	#		var index = grid_space_to_index(x, y)
	#		if index >= 0 && index < n:
	#			grid[index] = 0

func line_intersects_rectangle(p1: Vector2, p2: Vector2, rect_position: Vector2, rect_size: Vector2) -> bool:
	# Define the rectangle's edges
	var rect_top_left = rect_position
	var rect_top_right = rect_position + Vector2(rect_size.x, 0)
	var rect_bottom_left = rect_position + Vector2(0, rect_size.y)
	var rect_bottom_right = rect_position + rect_size
	
	# Check if the line intersects any of the rectangle's edges
	if line_intersects_line(p1, p2, rect_top_left, rect_top_right):
		return true
	if line_intersects_line(p1, p2, rect_top_right, rect_bottom_right):
		return true
	if line_intersects_line(p1, p2, rect_bottom_right, rect_bottom_left):
		return true
	if line_intersects_line(p1, p2, rect_bottom_left, rect_top_left):
		return true
	
	# Also check if the line is completely inside the rectangle
	if is_point_in_rect(p1, rect_position, rect_size) and is_point_in_rect(p2, rect_position, rect_size):
		return true
	
	return false

# Helper function to check if two lines intersect
func line_intersects_line(p1_start: Vector2, p1_end: Vector2, p2_start: Vector2, p2_end: Vector2) -> bool:
	var d = (p2_end.y - p2_start.y) * (p1_end.x - p1_start.x) - (p2_end.x - p2_start.x) * (p1_end.y - p1_start.y)
	if d == 0:
		return false  # Lines are parallel
	
	var u = ((p2_start.x - p1_start.x) * (p1_end.y - p1_start.y) - (p2_start.y - p1_start.y) * (p1_end.x - p1_start.x)) / d
	var v = ((p2_start.x - p1_start.x) * (p2_end.y - p2_start.y) - (p2_start.y - p1_start.y) * (p2_end.x - p2_start.x)) / d
	
	return (u >= 0 and u <= 1 and v >= 0 and v <= 1)

# Helper function to check if a point is inside a rectangle
func is_point_in_rect(point: Vector2, rect_position: Vector2, rect_size: Vector2) -> bool:
	return (point.x >= rect_position.x and point.x <= rect_position.x + rect_size.x and point.y >= rect_position.y and point.y <= rect_position.y + rect_size.y)



func find_islands(island_indices: PackedInt32Array, island_lens: Array[int]) :
	#var island_indices: PackedInt32Array
	#var island_lens: Array[int]
	var all_visited = grid.duplicate()
	var n = all_visited.size()
	for i in n:
		all_visited[i] = 0
	
	for next_island_start in n:
		if grid[next_island_start] == 0:
			continue
		if all_visited[next_island_start]:
			continue
		all_visited[next_island_start] = 1
		var island = flood_fill_mesh_from_index(grid, next_island_start)
		for idx in island:
			all_visited[idx] = 1
		island_indices.append_array(island)
		island_lens.push_back(island.size())

		
	

func flood_fill_mesh_from_index(grid: PackedByteArray, idx: int) -> PackedInt32Array:
	var visited = grid.duplicate()
	for i in visited.size():
		visited[i] = 0
		
	var indices: PackedInt32Array;
	var dfs: Array[int]
	indices.push_back(idx)
	dfs.push_back(idx)
	visited[idx] = 1
	
	
	var safety = 0
	while true:
		if dfs.is_empty():
			break
		if safety > grid.size():
			break
		safety += 1
		var idx2 = dfs.pop_back()
		var x = idx2 % grid_width
		var y = idx2 / grid_width
		
		
		var v1 = Vector2(x+1,y)
		var v2 = Vector2(x,y+1)
		var v3 = Vector2(x-1,y)
		var v4 = Vector2(x,y-1)
		
		for p in [v1,v2,v3,v4]:
			var xn = int(p.x);
			var yn = int(p.y)
			if !(0 <= xn && xn < grid_width && 0 <= yn && yn < grid_height):
				continue	
			var nidx = xn + yn*grid_width
			if grid[nidx] == 0:
				continue
			if visited[nidx] == 1:
				continue
			else:
				visited[nidx] = 1
				indices.push_back(int(nidx))
				dfs.push_back(nidx)
	return indices


func convert_grid_to_mesh(grid: PackedByteArray, mesh: ImmediateMesh):
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)


	var half = cell / 2.0

	var f = cell * -Vector3(0.0, 0.0, 1.0)
	var r = cell * Vector3(1.0, 0.0, 0.0)

	var i = -1
	for value in grid:
		i = i + 1
		if value == 1:
			var middle = index_to_world_space(i)
			var mp = Vector3(middle.x, 0.15, middle.y)

			var bl = mp - half

			var tr = bl + f + r
			var br = bl + r
			var tl = bl + f


			var normal = Vector3.UP
			#add top
			mesh.surface_add_vertex(br)
			mesh.surface_set_normal(normal)
			mesh.surface_add_vertex(tl)
			mesh.surface_set_normal(normal)
			mesh.surface_add_vertex(tr)
			mesh.surface_set_normal(normal)

			mesh.surface_add_vertex(br)
			mesh.surface_set_normal(normal)
			mesh.surface_add_vertex(bl)
			mesh.surface_set_normal(normal)
			mesh.surface_add_vertex(tl)
			mesh.surface_set_normal(normal)
			
			var thick = 0.05 * Vector3.DOWN
			# add sides
			# if we want to we can make sure to only add this if we do not have four filled neighbours

			
			var bl_b = bl + thick
			var tr_b = tr + thick
			var br_b = br + thick
			var tl_b = tl + thick

			#front facing side
			mesh.surface_add_vertex(bl)
			mesh.surface_add_vertex(br_b)
			mesh.surface_add_vertex(bl_b)
			
			mesh.surface_add_vertex(br_b)
			mesh.surface_add_vertex(bl)
			mesh.surface_add_vertex(br)
			
			
			# back facing side
			mesh.surface_add_vertex(tl)
			mesh.surface_add_vertex(tl_b)
			mesh.surface_add_vertex(tr_b)
			
			mesh.surface_add_vertex(tr_b)
			mesh.surface_add_vertex(tr)
			mesh.surface_add_vertex(tl)

			# left side
			mesh.surface_add_vertex(bl)
			mesh.surface_add_vertex(bl_b)
			mesh.surface_add_vertex(tl_b)

			mesh.surface_add_vertex(bl)
			mesh.surface_add_vertex(tl_b)
			mesh.surface_add_vertex(tl)

			# right side
			mesh.surface_add_vertex(tr)
			mesh.surface_add_vertex(tr_b)
			mesh.surface_add_vertex(br_b)

			mesh.surface_add_vertex(tr)
			mesh.surface_add_vertex(br_b)
			mesh.surface_add_vertex(br)

			# add bottom
			mesh.surface_add_vertex(br_b)
			mesh.surface_add_vertex(tl_b)
			mesh.surface_add_vertex(tr_b)

			mesh.surface_add_vertex(br_b)
			mesh.surface_add_vertex(bl_b)
			mesh.surface_add_vertex(tl_b)

	mesh.surface_end()


func convert_points_and_cuts_to_mesh(polygon: Array[Vector2], mesh: ImmediateMesh):
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	var num_points = polygon.size()
	
	var bottom_y = -thickness;
	var top_y = 0.0;
	# Add top face
	for i in range(1, num_points - 1):
		mesh.surface_add_vertex(Vector3(polygon[0].x, top_y, polygon[0].y))
		mesh.surface_add_vertex(Vector3(polygon[i].x, top_y, polygon[i].y))
		mesh.surface_add_vertex(Vector3(polygon[i + 1].x, top_y, polygon[i + 1].y))

	# Add bottom face vertices (as triangles, with inverted winding)
	for i in range(1, num_points - 1):
		mesh.surface_add_vertex(Vector3(polygon[0].x, bottom_y, polygon[0].y ))
		mesh.surface_add_vertex(Vector3(polygon[i + 1].x, bottom_y, polygon[i + 1].y ))
		mesh.surface_add_vertex(Vector3(polygon[i].x, bottom_y, polygon[i].y ))

	# Add side faces vertices (as quads split into two triangles)
	for i in range(num_points):
		var next = (i + 1) % num_points

		var top_current = Vector3(polygon[i].x, top_y, polygon[i].y)
		var top_next = Vector3(polygon[next].x, top_y, polygon[next].y)
		var bottom_current = Vector3(polygon[i].x, bottom_y, polygon[i].y )
		var bottom_next = Vector3(polygon[next].x, bottom_y, polygon[next].y )

		# First triangle of the quad
		mesh.surface_add_vertex(top_current)
		mesh.surface_add_vertex(bottom_current)
		mesh.surface_add_vertex(bottom_next)

		# Second triangle of the quad
		mesh.surface_add_vertex(top_current)
		mesh.surface_add_vertex(bottom_next)
		mesh.surface_add_vertex(top_next)

	mesh.surface_end()
