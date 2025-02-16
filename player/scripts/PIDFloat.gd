extends RefCounted
class_name PIDFloat

enum DerivativeMeasurement {
    VELOCITY,
    ERROR_RATE_OF_CHANGE
}

# PID coefficients
var proportional_gain: float
var integral_gain: float
var derivative_gain: float

var output_min: float
var output_max: float
var integral_saturation: float
var derivative_measurement: DerivativeMeasurement

# Internal state
var value_last: float = 0.0
var error_last: float = 0.0
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
    proportional_gain = kp
    integral_gain = ki
    derivative_gain = kd
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

    var error = target_value - current_value

    # Proportional term
    var P = proportional_gain * error

    # Integral term with clamping (anti-windup)
    integration_stored = clamp(integration_stored + (error * dt), -integral_saturation, integral_saturation)
    var I = integral_gain * integration_stored

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

    var D = derivative_gain * derive_measure

    # Compute final output
    var result = P + I + D
    return clamp(result, output_min, output_max)

# Angle difference calculation (keeps angles within [-π, π] range)
func angle_difference(a: float, b: float) -> float:
    return fmod(a - b + PI, 2 * PI) - PI

# Angular PID update for rotation control
func update_angle(dt: float, current_angle: float, target_angle: float) -> float:
    if dt <= 0:
        push_error("Delta time (dt) must be greater than zero.")
        return 0.0

    var error = angle_difference(target_angle, current_angle)

    # Proportional term
    var P = proportional_gain * error

    # Integral term with clamping
    integration_stored = clamp(integration_stored + (error * dt), -integral_saturation, integral_saturation)
    var I = integral_gain * integration_stored

    # Derivative term calculations
    var error_rate_of_change = angle_difference(error, error_last) / dt
    error_last = error

    var value_rate_of_change = angle_difference(current_angle, value_last) / dt
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

    var D = derivative_gain * derive_measure

    # Compute final output
    var result = P + I + D
    return clamp(result, output_min, output_max)
