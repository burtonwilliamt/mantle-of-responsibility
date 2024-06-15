extends Node2D

var velocity: Vector2
var speed = 500
var max_zoom = Vector2.ONE*10
var min_zoom = Vector2.ONE*.1
var zoom_increment = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("zoom_in"):
		$Camera2D.zoom *= Vector2.ONE*(1+zoom_increment)
	if Input.is_action_just_pressed("zoom_out"):
		$Camera2D.zoom *= Vector2.ONE*(1-zoom_increment)
	$Camera2D.zoom = $Camera2D.zoom.clamp(min_zoom, max_zoom)
	velocity = Input.get_vector("left", "right", "up", "down")
	# Scale the speed by the current zoom, when we're zoomed out we want to move faster.
	$Camera2D.position += velocity*speed*(1/$Camera2D.zoom[0])*delta
