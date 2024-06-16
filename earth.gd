extends Node2D

var velocity: Vector2
var speed = 700
var max_zoom = Vector2.ONE*10
var min_zoom = Vector2.ONE*.1
var zoom_increment = 0.1

var earth_radius = 6.3781e6 # meters

func _ready():
	var sp_width = $Sprite2D.get_rect()
	var earth_scale = (earth_radius * 2 / sp_width.size[0])/1000 # scale to km
	$Sprite2D.scale = Vector2(earth_scale, earth_scale)
	$Camera2D.zoom = Vector2.ONE * 0.01

func _process(delta):
	if Input.is_action_just_pressed("zoom_in"):
		$Camera2D.zoom *= Vector2.ONE*(1+zoom_increment)
	if Input.is_action_just_pressed("zoom_out"):
		$Camera2D.zoom *= Vector2.ONE*(1-zoom_increment)
	# $Camera2D.zoom = $Camera2D.zoom.clamp(min_zoom, max_zoom)
	velocity = Input.get_vector("left", "right", "up", "down")
	# Scale the speed by the current zoom, when we're zoomed out we want to move faster.
	$Camera2D.position += velocity*speed*(1/$Camera2D.zoom[0])*delta
