
class_name OrbitModel

var eccentricity: float
## a, half the distance from periapsis to apoapsis in meters
var semi_major_axis: float

# These aren't needed in 2d orbits.
# @export var inclination: float # i
# @export var longitude_of_the_ascending_node: float # capital omega 

# omega, the rotaion of the orbit around the focal point with massive body
var arg_of_periapsis: float
# theta, the angle from periapsis to current orbiting body
var true_anomaly: float

var _gravitational_constant = 6.6743e-11 # Nm^2/kg^2
var _mass_of_earth = 5.9722e24 # kg

var period: float
var apoapsis: float
var periapsis: float
var semi_minor_axis: float
## The distance from elipse center to the focal point.
var focal_offset: float

## Update orbit constants like period and apoapsis.
func calculate():
	period = 2*PI*sqrt(semi_major_axis**3/(_gravitational_constant * _mass_of_earth))
	apoapsis = (1 + eccentricity) * semi_major_axis
	periapsis = (1 - eccentricity) * semi_major_axis
	semi_minor_axis = semi_major_axis * sqrt(1 - eccentricity**2)
	focal_offset = semi_major_axis - periapsis

	# print("eccentricity: ", self.eccentricity)
	# print("semi_major_axis: ", self.semi_major_axis)
	# print("arg_of_periapsis: ", self.arg_of_periapsis)
	# print("true_anomaly: ", self.true_anomaly)
	# print("---derived---")
	# print("period: ", self.period)
	# print("apoapsis: ", self.apoapsis)
	# print("periapsis: ", self.periapsis)
	# print("semi_minor_axis: ", self.semi_minor_axis)
	# print("focal_offset: ", self.focal_offset)

var _max_error = 2*PI/1_000_000

func _estimate_eccentric_anomaly(mean_anomaly: float) -> float:
	var E = mean_anomaly

	var attempts = 0
	# Newton-Raphson method of estimation. Might be worth investigating alternatives.
	while true:
		attempts += 1
		var approx_mean_anomaly = (E - eccentricity * sin(E))
		var error =  approx_mean_anomaly - mean_anomaly
		if absf(error) < _max_error:
			return E
		if attempts > 100:
			print("Failed after 100 attempts with error: ", error)
			return E
		var deriv = 1 - eccentricity * cos(E)
		E -= error/deriv
	return 0.0

func position(t: float) -> Vector2:
	t = fmod(t, period)
	var n = 2*PI/period
	var M = n*t
	# M = E - sin(E)
	var E = _estimate_eccentric_anomaly(M)
	# Maybe this works? I would need to handle something like atan2, and also decide the sign of the sqrt.
	# The value should at least be in the same half as E.
	# var theta = 2*atan(sqrt(((1+eccentricity)*(tan(E/2)**2))/(1-eccentricity)))
	return Vector2(semi_major_axis*cos(E) - focal_offset, semi_minor_axis * sin(E))/1000