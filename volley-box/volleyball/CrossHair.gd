extends CanvasLayer

@onready var power_bar = $PowerBar
@onready var label = $Label


func set_power(percent: float):

	percent = clamp(percent, 0.0, 1.0)

	power_bar.value = percent * 100

	label.text = str(int(percent * 100)) + "%"


func reset_power():

	power_bar.value = 0
	label.text = ""
