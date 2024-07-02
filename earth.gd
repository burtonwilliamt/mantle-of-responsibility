extends Node2D

var velocity: Vector2
var speed = 700
var max_zoom = Vector2.ONE*10
var min_zoom = Vector2.ONE*.1
var zoom_increment = 0.1

var earth_radius = 6.3781e6 # meters

var zoom_levels: Array[float] = []
var current_zoom: int

func _init_zoom_levels():
	zoom_levels = []
	var num_levels = 50
	var multiplier = 1.1
	var neutral_zoom = 0.01
	for i in range(num_levels):
		var power = i - num_levels/2
		zoom_levels.append(neutral_zoom * (multiplier ** power))
	current_zoom = num_levels/2

func update_zoom(zoom: float):
	$Camera2D.zoom = Vector2.ONE * zoom
	$Orbit.update_zoom(zoom)

func _ready():
	_init_zoom_levels()
	var sp_width = $Sprite2D.get_rect()
	var earth_scale = (earth_radius * 2 / sp_width.size[0])/1000 # scale to km
	$Sprite2D.scale = Vector2(earth_scale, earth_scale)
	update_zoom(zoom_levels[current_zoom])

func _process(delta):
	if Input.is_action_just_pressed("zoom_in"):
		current_zoom = min(len(zoom_levels) - 1, current_zoom + 1)
		update_zoom(zoom_levels[current_zoom])
	if Input.is_action_just_pressed("zoom_out"):
		current_zoom = max(0, current_zoom - 1)
		update_zoom(zoom_levels[current_zoom])
	# $Camera2D.zoom = $Camera2D.zoom.clamp(min_zoom, max_zoom)
	velocity = Input.get_vector("left", "right", "up", "down")
	# Scale the speed by the current zoom, when we're zoomed out we want to move faster.
	$Camera2D.position += velocity*speed*(1/$Camera2D.zoom[0])*delta
