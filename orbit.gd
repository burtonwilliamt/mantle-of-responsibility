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

@export_group("Visuals")
@export var orbit_dot: PackedScene


var gravitational_constant = 6.6743e-11 # Nm^2/kg^2
var mass_of_earth = 5.9722e24 # kg

var period: float
var apoapsis: float
var periapsis: float
var semi_minor_axis: float
## The distance from elipse center to the focal point.
var focal_offset: float

## Update orbit constants like period and apoapsis.
func _calculate():
	period = 2*PI*sqrt(semi_major_axis**3/(gravitational_constant * mass_of_earth))
	apoapsis = (1 + eccentricity) * semi_major_axis
	periapsis = (1 - eccentricity) * semi_major_axis
	semi_minor_axis = semi_major_axis * sqrt(1 - eccentricity**2)
	focal_offset = semi_major_axis - periapsis

var _max_error = 2*PI/1_000_000

func _estimate_eccentric_anomaly(mean_anomaly: float) -> float:
	var E = mean_anomaly

	var attempts = 0
	# Newton-Raphson method of estimation. Might be worth investigating alternatives.
	while true:
		attempts += 1
		var approx_mean_anomaly = (E - eccentricity * sin(E))
		var error =  approx_mean_anomaly - mean_anomaly
		# print("Current guess: ", E)
		# print("Calculated as: ", approx_mean_anomaly)
		# print("Actual:        ", mean_anomaly)
		# print("Error:         ", error)
		if absf(error) < _max_error:
			# print("Success with error: ", error)
			# print("Took this many attempts: ", attempts)
			return E
		if attempts > 100:
			print("Failed after 100 attempts with error: ", error)
			return E
		var deriv = 1 - eccentricity * cos(E)
		# print("Deriv:         ", deriv)
		E -= error/deriv
	return 0.0

func position(t: float) -> Vector2:
	t = fmod(t, period)
	var n = 2*PI/period
	var M = n*t
	var E = _estimate_eccentric_anomaly(M)
	# Maybe this works? I would need to handle something like atan2, and also decide the sign of the sqrt.
	# The value should at least be in the same half as E.
	# var theta = 2*atan(sqrt(((1+eccentricity)*(tan(E/2)**2))/(1-eccentricity)))
	return Vector2(semi_major_axis*cos(E) + focal_offset, semi_minor_axis * sin(E))


func _ready():
	_calculate()
	var num_dots = 100
	var delta = period/num_dots
	for i in range(num_dots):
		var dot = orbit_dot.instantiate()	
		dot.position = position(delta*(i))/1000
		self.add_child(dot)
		

func _process(delta):
	pass
