extends MeshInstance3D

@export var points: Array[Vector2] = []
@export var thickness: float = 0.3

@export var camera: Camera3D

var scene_root: Node
var mouse_pos_in_plane = Vector3(0.0, 0.0, 0.0)

var drawing = false

var grid: PackedByteArray
var cell_size = Vector2(0.01, 0.01)
var plank_size = Vector2(0.8, 0.5)
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


func _ready() -> void:
	var grid_dims = plank_size / cell_size
	grid_width = int(round(grid_dims.x))
	grid_height = int(round(grid_dims.y))

	for i in range(grid_width * grid_height):
		grid.append(1)


func _input(event):
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event
		if e.button_index == MOUSE_BUTTON_LEFT:
			drawing = e.pressed
			if drawing:
				points.clear()
		
	if event is InputEventMouseMotion:
		# Step 1: Get the mouse position in the viewport
		var mouse_pos = event.position

		# Step 2: Convert the 2D mouse position to a 3D ray
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_direction = camera.project_ray_normal(mouse_pos)
		
		# Step 3: Define the plane to intersect with (e.g., a plane at y = 0)
		var plane = Plane(Vector3(0, 1, 0), 0)  # A horizontal plane at y=0
		
		# Step 4: Intersect the ray with the plane
		var intersection = plane.intersects_ray(ray_origin, ray_direction)
		
		if intersection != null:
			mouse_pos_in_plane = intersection


func _process(delta: float) -> void:
	particles.emitting = false

	if drawing:
		var mouse_2d = Vector2(mouse_pos_in_plane.x, mouse_pos_in_plane.z)
		debug0.global_position = mouse_pos_in_plane

		var pnorm = point_to_grid_space(mouse_2d)
		var w = grid_space_to_world(pnorm) 
		debug1.global_position = Vector3(w.x, 0.0, w.y)

		points.push_back(mouse_2d)
		var n =  points.size()
		if n % 2 == 0 && n > 0:
			cut_grid_with_points(points[0], points[1])
			points.clear()

	convert_grid_to_mesh(grid, self.mesh)


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
	
	var pp1_outside = pp1.x < 0.0 || pp1.y > 1.0
	var pp2_outside = pp2.x < 0.0 || pp2.y > 1.0

	if pp1_outside && pp2_outside:
		return

	var min = vector2_min(vector2_floor(pp1), vector2_floor(pp2))
	var max = vector2_max(vector2_ceil(pp1), vector2_ceil(pp2))

	var i1 = grid_space_to_index(pp1)
	var n = grid.size()
	if i1 >= 0 && i1 < n:
		if grid[i1] == 1:
			particles.emitting = true
			grid[i1] = 0
			print(pp1)


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

			mesh.surface_add_vertex(br)
			mesh.surface_add_vertex(tl)
			mesh.surface_add_vertex(tr)

			mesh.surface_add_vertex(br)
			mesh.surface_add_vertex(bl)
			mesh.surface_add_vertex(tl)

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
