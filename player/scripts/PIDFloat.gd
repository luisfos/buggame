extends RefCounted
class_name PIDFloat

enum DerivativeMeasurement {
    VELOCITY,
    ERROR_RATE_OF_CHANGE
}

# PID coefficients
var _p: float
var _i: float
var _d: float

var output_min: float
var output_max: float
var integral_saturation: float
var derivative_measurement: DerivativeMeasurement

# Internal state
var value_last: float = 0.0
var error_last: float = 0.0
var target_last: float = 0.0 # only for debugging, not used internally
var result_last: float = 0.0
var integration_stored: float = 0.0
var velocity: float = 0.0  # Used for debugging/monitoring
var derivative_initialized: bool = false

# Constructor to initialize PID values
func _init(
    kp: float, ki: float, kd: float,
    output_min_: float = -1.0, output_max_: float = 1.0,
    integral_saturation_: float = 0.0,
    derivative_measurement_: DerivativeMeasurement = DerivativeMeasurement.ERROR_RATE_OF_CHANGE
):
    _p = kp
    _i = ki
    _d = kd
    output_min = output_min_
    output_max = output_max_
    integral_saturation = integral_saturation_
    derivative_measurement = derivative_measurement_

func reset() -> void:
    derivative_initialized = false
    integration_stored = 0.0
    error_last = 0.0
    value_last = 0.0
    velocity = 0.0

# Standard PID update for linear values
func update(dt: float, current_value: float, target_value: float) -> float:
    if dt <= 0:
        push_error("Delta time (dt) must be greater than zero.")
        return 0.0

    target_last = target_value
    var error = target_value - current_value

    # Proportional term
    var P = _p * error

    # Integral term with clamping (anti-windup)
    integration_stored = clamp(integration_stored + (error * dt), -integral_saturation, integral_saturation)
    var I = _i * integration_stored

    # Derivative term calculations
    var error_rate_of_change = (error - error_last) / dt
    error_last = error

    var value_rate_of_change = (current_value - value_last) / dt
    value_last = current_value
    velocity = value_rate_of_change

    # Select derivative measurement method
    var derive_measure = 0.0
    if derivative_initialized:
        if derivative_measurement == DerivativeMeasurement.VELOCITY:
            derive_measure = -value_rate_of_change  # Reduces derivative kick
        else:
            derive_measure = error_rate_of_change
    else:
        derivative_initialized = true  # First update, skip derivative term

    var D = _d * derive_measure

    # Compute final output
    var result = P + I + D
    result_last = result
    return clamp(result, output_min, output_max)

# Angle difference calculation (keeps angles within [-π, π] range)
# careful theres a builtin called angle_difference
func angle_difference_degree(a: float, b: float) -> float:        
    return int(a - b + 540.0) % 360 - 180   #calculate modular difference, and remap to [-180, 180]
    # return fmod(a - b + 180, 360) - 180
    # return fmod(a - b + PI, 2 * PI) - PI

# Angular PID update for rotation control in degrees
func update_angle(dt: float, current_angle: float, target_angle: float) -> float:
    if dt <= 0:
        push_error("Delta time (dt) must be greater than zero.")
        return 0.0

    # print("current: ", current_angle)
    # print("target: ", target_angle)
    target_last = target_angle
    var error = angle_difference_degree(target_angle, current_angle)
    # print("error: ", error)

    # Proportional term
    var P = _p * error

    # Integral term with clamping
    integration_stored = clamp(integration_stored + (error * dt), -integral_saturation, integral_saturation)
    var I = _i * integration_stored

    # Derivative term calculations
    var error_rate_of_change = angle_difference_degree(error, error_last) / dt
    error_last = error

    var value_rate_of_change = angle_difference_degree(current_angle, value_last) / dt
    value_last = current_angle
    velocity = value_rate_of_change

    # Select derivative measurement method
    var derive_measure = 0.0
    if derivative_initialized:
        if derivative_measurement == DerivativeMeasurement.VELOCITY:
            derive_measure = -value_rate_of_change
        else:
            derive_measure = error_rate_of_change
    else:
        derivative_initialized = true  # First update, skip derivative term

    var D = _d * derive_measure

    # Compute final output
    var result = P + I + D
    result_last = result
    return clamp(result, output_min, output_max)
