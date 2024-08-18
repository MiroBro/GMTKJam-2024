extends TextureRect

var vectors : PackedVector2Array = []
var maxX = 0
var maxY = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var poly : Polygon2D = Polygon2D.new()
	
	# assuming object is in a chordinate system where 0,0 is top-left (NOT CENTERD)
	vectors = PackedVector2Array(
		[
			Vector2(100,70),
	  		Vector2(300, 200),
	  		Vector2(65, 265)
		])
	
	# Center the shapes around the origin
	for n in vectors.size():
		if vectors[n][0] > maxX:
			maxX = vectors[n][0]
		if vectors[n][1] > maxY:
			maxY = vectors[n][1]
	
	poly.offset = Vector2(- maxX / 2, - maxY / 2)

	poly.set_polygon(vectors)
	poly.set_antialiased(true)
	poly.color = Color(1, 1, 1, 0.2)
	poly.set_use_parent_material(true)	
	add_child(poly)	

	pass # Replace with function body.

# Draw dottet line around polyon
func _draw() -> void:
	#draw_circle(Vector2(0,0), 5, Color(1, 1,1, 0.2))
	#draw_line(Vector2(0,0), Vector2(0,20), Color(1, 1, 1, 0.2), 4)
	#draw_line(Vector2(-10,20), Vector2(10,20), Color(1, 1, 1, 0.2), 4)
	
	for n in vectors.size():
		#print(n)
		if (n != vectors.size()-1):
			draw_dashed_line(vectors[n] - Vector2(maxX/2, maxY/2), vectors[n+1] - Vector2(maxX/2, maxY/2), Color(1, 1, 1, 1), 5, 15, false)
		else:
			draw_dashed_line(vectors[n] - Vector2(maxX/2, maxY/2), vectors[0] - Vector2(maxX/2, maxY/2), Color(1, 1, 1, 1), 5, 15, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
