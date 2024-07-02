extends Node2D

@export_group("Orbit Parameters")
## e, how circular is this orbit is (0 is circular, 1 is parabola)
@export_range(0, 1) var eccentricity: float
## a, half the distance from periapsis to apoapsis in meters
@export var semi_major_axis: float

# These aren't needed in 2d orbits.
# @export var inclination: float # i
# @export var longitude_of_the_ascending_node: float # capital omega 

# omega, the rotaion of the orbit around the focal point with massive body
@export_range(0, 2*PI) var arg_of_periapsis: float
# theta, the angle from periapsis to current orbiting body
@export_range(0, 2*PI) var true_anomaly: float

@export var speedup: float = 100

@export_group("Visuals")
@export var orbit_dot: PackedScene


var orbit_path_scene = preload("res://orbit_path.tscn")

var _model: OrbitModel
var _path: OrbitPath
var _ship: Node2D
var _elapsed_time: float = 0.0


func update_zoom(zoom_level: float):
	_path.update_zoom(zoom_level)

func _ready():
	_model = OrbitModel.new()
	_model.eccentricity = eccentricity
	_model.semi_major_axis = semi_major_axis
	_model.arg_of_periapsis = arg_of_periapsis
	_model.true_anomaly = true_anomaly
	_model.calculate()

	_path = orbit_path_scene.instantiate()
	_path.model = _model
	_path.update()
	self.add_child(_path)

	_ship = orbit_dot.instantiate()
	_ship.position = _model.position(0)
	self.add_child(_ship)

func _process(delta):
	_elapsed_time += delta * speedup
	_ship.position = _model.position(_elapsed_time)

