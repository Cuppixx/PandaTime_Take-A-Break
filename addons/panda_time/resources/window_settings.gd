@tool
class_name PTwindowSettings extends Window

var stats:StatsDataPT = StatsDataPT.new()

@onready var session_label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SessionLabel
@onready var session_time_slider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SessionHSlider
@onready var break_window_exclusive_button = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/ExclusiveButton
@onready var break_window_message_button = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/MessageButton
@onready var break_window_size_label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SizeLabel
@onready var break_window_size_slider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SizeHSlider
@onready var break_window_countdown_button = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/CountdownButton
@onready var break_window_countdown_label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/CountdownLabel
@onready var break_window_countdown_slider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/CountdownHSlider
@onready var break_window_countdown_timeout_button = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/CountdownTimeoutButton
@onready var break_window_countdown_timeout_label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/CountdownTimeoutLabel
@onready var break_window_countdown_timeout_slider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/CountdownTimeoutHSlider
@onready var break_window_image_filter_colorpicker = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/ImageColorPickerButton
@onready var break_window_ui_filter_colorpicker = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/UiColorPickerButton

@onready var reminder_window_enabled_butoon = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/ReminderButton
@onready var reminder_window_popup_time_label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/ReminderLabel
@onready var reminder_window_popup_time_slider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/ReminderHSlider

@onready var reset_button = $ScrollContainer/Control/MarginContainer/VBoxContainer/ResetButton

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: queue_free()
		_: pass

func _ready() -> void:
	_load_settings()
	_connect_settings()

func _load_settings() -> void:
	session_time_slider.value = stats.break_time / 60
	session_label.text = "Session Time: %.0f min" % [session_time_slider.value]

	break_window_exclusive_button.set_pressed_no_signal(!stats.break_window_exclusive)
	break_window_message_button.set_pressed_no_signal(!stats.break_window_message)

	break_window_size_slider.value = stats.break_window_size
	break_window_size_label.text = "Break Window Size %d percent" % [break_window_size_slider.value]

	break_window_countdown_button.set_pressed_no_signal(stats.break_window_timer_countdown)
	break_window_countdown_slider.value = stats.break_window_time / 60
	break_window_countdown_slider.editable = stats.break_window_timer_countdown
	break_window_countdown_label.text = "Countdown Time: %.0f min" % [break_window_countdown_slider.value]
	break_window_countdown_timeout_button.set_pressed_no_signal(stats.break_window_close_on_timeout)
	if break_window_countdown_button.button_pressed == false:
		break_window_countdown_timeout_button.disabled = true
	break_window_countdown_timeout_slider.value = stats.break_window_timeout_time
	break_window_countdown_timeout_slider.editable = stats.break_window_close_on_timeout
	break_window_countdown_timeout_label.text = "Autoclose '%.0f' sec after Timeout" % [break_window_countdown_timeout_slider.value]

	break_window_image_filter_colorpicker.color = stats.break_window_image_filter_color
	break_window_ui_filter_colorpicker.color = stats.break_window_ui_bg_color

	reminder_window_enabled_butoon.set_pressed_no_signal(stats.reminder_window_enabled)

	reminder_window_popup_time_slider.value = stats.reminder_time
	reminder_window_popup_time_label.text = "Reminder at '%.0f' sec left" % [stats.reminder_time]


func _connect_settings() -> void:
	session_time_slider.value_changed.connect(func(value:float) -> void:
		session_label.text = "Session Time: %.0f min" % [value]
		stats.break_time = value*60
	)
	break_window_exclusive_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_exclusive = !toggled_on
	)
	break_window_message_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_message = !toggled_on
	)
	break_window_size_slider.value_changed.connect(func(value:float) -> void:
		break_window_size_label.text = "Break Window Size %d percent" % [value]
		stats.break_window_size = value
	)
	break_window_countdown_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_timer_countdown = toggled_on
		break_window_countdown_slider.editable = toggled_on
		break_window_countdown_timeout_button.button_pressed = toggled_on
		break_window_countdown_timeout_button.disabled = !toggled_on
		break_window_countdown_timeout_slider.editable = toggled_on
	)
	break_window_countdown_slider.value_changed.connect(func(value:float) -> void:
		break_window_countdown_label.text = "Countdown Time: %.0f min" % [value]
		stats.break_window_time = value * 60
	)
	break_window_countdown_timeout_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_close_on_timeout = toggled_on
		break_window_countdown_timeout_slider.editable = toggled_on
	)
	break_window_countdown_timeout_slider.value_changed.connect(func(value:float) -> void:
		break_window_countdown_timeout_label.text = "Autoclose '%.0f' sec after Timeout" % [value]
		stats.break_window_timeout_time = int(value)
	)
	break_window_image_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_image_filter_color = color
	)
	break_window_ui_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_ui_bg_color = color
	)
	reminder_window_enabled_butoon.toggled.connect(func(toggled_on:bool) -> void:
		stats.reminder_window_enabled = toggled_on
	)
	reminder_window_popup_time_slider.value_changed.connect(func(value:float) -> void:
		reminder_window_popup_time_label.text = "Reminder at '%.0f' sec left" % [value]
		stats.reminder_time = int(value)
	)


func _on_reset_button_pressed() -> void:
	stats = StatsDataPT.new()
	_load_settings()
