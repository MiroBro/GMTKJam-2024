extends TextureRect

var vectors : PackedVector2Array = []

@export var reference_mesh: MeshInstance3D
@export var reference_banana: Node3D

var poly : Polygon2D = Polygon2D.new()

var maxX = -100.0
var maxY = -100.0

func convex_hull(points: PackedVector2Array) -> PackedVector2Array:
	if points.size() <= 1:
		return points

	points.sort()

	var lower: Array[Vector2] = []
	var upper: Array[Vector2] = []

	for point in points:
		while lower.size() >= 2 and _cross(lower[lower.size() - 2], lower[lower.size() - 1], point) <= 0:
			lower.pop_back()
		lower.append(point)

	for i in range(points.size() - 1, -1, -1):
		var point = points[i]
		while upper.size() >= 2 and _cross(upper[upper.size() - 2], upper[upper.size() - 1], point) <= 0:
			upper.pop_back()
		upper.append(point)

	lower.pop_back()
	upper.pop_back()

	# Concatenate lower and upper hull to get the full hull
	var result: PackedVector2Array = PackedVector2Array(lower)
	result.append_array(upper)

	return result

# Calculate the cross product of vectors AB and AC
func _cross(a: Vector2, b: Vector2, c: Vector2) -> float:
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)

# Helper function to compute the cross product
func cross_product(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)


func find_discrete_outlines(points: PackedVector2Array, n: int = 20):
	var dots: PackedFloat32Array
	var dirs: PackedVector2Array
	var output: PackedVector2Array

	var dt = 1.0 / float(n)

	for i in n:
		dots.append(-1000.0)
		var t = float(i) / float(n) 
		var angle = 3.141502 * 2.0 * t
		var x = cos(angle)
		var y = sin(angle)
		dirs.append(Vector2(x, y))
		output.append(Vector2(0.0, 0.0))

	for point in points:
		var i = -1
		for dir in dirs:
			i = i + 1
			var d = dir.dot(point)
			if d > dots[i] && d > dt:
				dots[i] = d
				output[i] = point

	return output

func make_thing(mesh: MeshInstance3D):
	maxX = -1000
	maxY = -1000

	# assuming object is in a coordinate system where 0,0 is top-left (NOT CENTERD)
	vectors = PackedVector2Array(
		[
			#Vector2(100,70),
	  		#Vector2(300, 200),
	  		#Vector2(65, 265)
		])

	var m = mesh.mesh.create_outline(0.1)
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(m, 0)
	var vert_count = mdt.get_vertex_count()
	print("num vertices: ", vert_count)

	for i in range(vert_count):
		var vert = mdt.get_vertex(i)
		var it = mesh.transform * vert
		vert.y = 0.0
		vectors.append(Vector2(vert.x, vert.z) * 300.0)

	vectors = convex_hull(vectors)
	# vectors = find_discrete_outlines(vectors, 20)
	# vectors = find_outline(vectors)

	for n in vectors.size():
		if vectors[n][0] > maxX:
			maxX = vectors[n][0]
		if vectors[n][1] > maxY:
			maxY = vectors[n][1]
	poly.offset = Vector2(- maxX / 2, - maxY / 2)

	poly.polygon.clear()
	poly.set_polygon(vectors)
	poly.set_antialiased(true)
	poly.color = Color(1, 1, 1, 0.2)
	poly.set_use_parent_material(true)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if reference_mesh:
		make_thing(reference_mesh)
	add_child(poly)


func _draw() -> void:
	var m = vectors.size()
	for n in m:
		#print(n)
		if (n != m-1):
			draw_dashed_line(vectors[n] - Vector2(maxX/2, maxY/2), vectors[n+1] - Vector2(maxX/2, maxY/2), Color(1, 1, 1, 1), 5, 15, false)
		else:
			draw_dashed_line(vectors[n] - Vector2(maxX/2, maxY/2), vectors[0] - Vector2(maxX/2, maxY/2), Color(1, 1, 1, 1), 5, 15, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
