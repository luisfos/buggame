extends RefCounted
class_name PID_2D

var _p: float
var _i: float
var _d: float
var _max: float

var _prev_error: Vector2
var _error_integral: Vector2

# todo add limits / derivative kick solve
# https://www.youtube.com/watch?v=y3K6FUgrgXw

func _init(p: float, i: float, d: float, max_output: float) -> void:
    _p = p # spring, causes overshoot
    _i = i
    _d = d # damper, breaking force
    _max = max_output
    _prev_error = Vector2.ZERO
    _error_integral = Vector2.ZERO

func update(error: Vector2, delta: float) -> Vector2:
    _error_integral += error * delta
    var error_derivative: Vector2 = (error - _prev_error) / delta
    _prev_error = error
    
    var output : Vector2 = _p * error + _i * _error_integral + _d * error_derivative
    # output.x = clampf(output.x, -_max, _max)
    # output.y = clampf(output.y, -_max, _max)
    return output
