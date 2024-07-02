class_name OrbitPath
extends Node2D

@export var color: Color

var model: OrbitModel
var line: Line2D
var _width: float = 1.0

func update_zoom(zoom_level: float):
	_width = 3*(1/zoom_level)
	self.update()

func update():
	model.calculate()
	if line != null:
		self.remove_child(line)
	line = Line2D.new()
	line.default_color = color
	line.width = _width
	line.antialiased = true
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	var num_segments = 100
	var delta = model.period/(num_segments-1)
	for i in range(num_segments):
		line.add_point(model.position(delta*(i)))
	self.add_child(line)