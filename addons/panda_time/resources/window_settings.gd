@tool
class_name PTwindowSettings extends Window

var stats:StatsDataPT = StatsDataPT.new()

@onready var session_time_slider = $ScrollContainer/Control/VBoxContainer/GridContainer/HSlider
@onready var break_window_exclusive_button =$ScrollContainer/Control/VBoxContainer/GridContainer/Button2
@onready var break_window_size_slider =$ScrollContainer/Control/VBoxContainer/GridContainer/HSlider2
@onready var break_window_message_button =$ScrollContainer/Control/VBoxContainer/GridContainer/Button3
@onready var break_window_countdown_button =$ScrollContainer/Control/VBoxContainer/GridContainer/Button4
@onready var break_window_countdown_slider =$ScrollContainer/Control/VBoxContainer/GridContainer/HSlider3
@onready var break_window_image_filter_colorpicker =$ScrollContainer/Control/VBoxContainer/GridContainer/ColorPickerButton
@onready var break_window_ui_filter_colorpicker =$ScrollContainer/Control/VBoxContainer/GridContainer/ColorPickerButton2

@onready var reminder_window_enabled_butoon =$ScrollContainer/Control/VBoxContainer/GridContainer/Button5
@onready var reminder_window_popup_time_slider =$ScrollContainer/Control/VBoxContainer/GridContainer/HSlider4

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: queue_free()
		_: pass

func _ready() -> void:
	_load_settings()
	_connect_settings()

func _load_settings() -> void:
	print(stats.break_time / 60)
	session_time_slider.value = stats.break_time / 60
	$ScrollContainer/Control/VBoxContainer/GridContainer/Label.text = "Session Time: %.0f min" % [session_time_slider.value]
	break_window_size_slider.value = stats.break_window_size
	$ScrollContainer/Control/VBoxContainer/GridContainer/Label2.text = "Size %d percent" % [break_window_size_slider.value]

func _connect_settings() -> void:
	session_time_slider.value_changed.connect(func(value:float) -> void:
		$ScrollContainer/Control/VBoxContainer/GridContainer/Label.text = "Session Time: %.0f min" % [value]
		stats.break_time = value*60
	)
	break_window_exclusive_button.pressed.connect(func() -> void:
		match stats.break_window_exclusive:
			true: stats.break_window_exclusive = false
			false: stats.break_window_exclusive = true
	)
	break_window_size_slider.value_changed.connect(func(value:float) -> void:
		$ScrollContainer/Control/VBoxContainer/GridContainer/Label2.text = "Size %d percent" % [break_window_size_slider.value]
		stats.break_window_size = value
	)
	break_window_message_button.pressed.connect(func() -> void:
		match stats.break_window_message:
			true: stats.break_window_message = false
			false: stats.break_window_message = true
	)
	break_window_countdown_button.pressed.connect(func() -> void:
		match stats.break_window_timer_countdown:
			true: stats.break_window_timer_countdown = false
			false: stats.break_window_timer_countdown = true
	)
	break_window_countdown_slider.value_changed.connect(func(value:float) -> void:
		stats.break_window_time = value * 60
	)
	break_window_image_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_image_filter_color = color
	)
	break_window_ui_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_ui_bg_color = color
	)
	reminder_window_enabled_butoon.pressed.connect(func() -> void:
		match stats.reminder_window_enabled:
			true: stats.reminder_window_enabled = false
			false: stats.reminder_window_enabled = true
	)
	reminder_window_popup_time_slider.value_changed.connect(func(value:float) -> void:
		stats.reminder_time = int(value)
		print(value)
	)
