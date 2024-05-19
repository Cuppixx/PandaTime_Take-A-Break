@tool
class_name PTwindowSettings extends Window

var stats:StatsDataPT = StatsDataPT.new()

#region @onready vars
@onready var session_label:Label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SessionLabel
@onready var session_time_slider:HSlider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SessionHSlider
@onready var break_window_exclusive_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/ExclusiveButton
@onready var break_window_message_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/MessageButton
@onready var break_window_size_label:Label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SizeLabel
@onready var break_window_size_slider:HSlider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer/SizeHSlider
@onready var break_window_countdown_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer2/CountdownButton
@onready var break_window_countdown_label:Label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer2/CountdownLabel
@onready var break_window_countdown_slider:HSlider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer2/CountdownHSlider
@onready var break_window_countdown_timeout_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer2/CountdownTimeoutButton
@onready var break_window_countdown_timeout_label:Label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer2/CountdownTimeoutLabel
@onready var break_window_countdown_timeout_slider:HSlider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer2/CountdownTimeoutHSlider
@onready var break_window_image_filter_colorpicker:ColorPickerButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer3/ImageColorPickerButton
@onready var break_window_ui_filter_colorpicker:ColorPickerButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer3/UiColorPickerButton

@onready var reminder_window_enabled_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer4/ReminderButton
@onready var reminder_window_popup_time_label:Label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer4/ReminderLabel
@onready var reminder_window_popup_time_slider:HSlider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer4/ReminderHSlider

@onready var audio_button:CheckButton = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer5/AudioButton
@onready var audio_slider:HSlider = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer5/AudioHSlider
@onready var audio_label:Label = $ScrollContainer/Control/MarginContainer/VBoxContainer/GridContainer5/Label

@onready var reset_button:Button = $ScrollContainer/Control/MarginContainer/VBoxContainer/ResetButton
#endregion

const SESSION_TIME_TEXT:String = "Session Time: %.0f min"
const BREAK_WINDOW_SIZE_TEXT:String = "Break Window Size %d percent"
const COUNTDOWN_TIME_TEXT:String = " Countdown Time: %.0f min"
const AUTOCLOSE_TEXT:String = " Autoclose '%.0f' sec after Timeout"
const REMINDER_TIME_TEXT:String = "Reminder at '%.0f' sec left"
const AUDIO_ADDEND_TEXT:String = "Audio Addend: %.0f"

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: queue_free()
		_: pass

func _ready() -> void:
	var editor_settings:EditorSettings = EditorInterface.get_editor_settings()
	var interface_base_color := editor_settings.get_setting("interface/theme/base_color")
	$ColorRect.color = interface_base_color

	_load_settings()
	_connect_settings()

func _load_settings() -> void:
	session_time_slider.value = stats.session_time / 60
	session_label.text = SESSION_TIME_TEXT % [session_time_slider.value]
	break_window_size_slider.value = stats.break_window_size
	break_window_size_label.text = BREAK_WINDOW_SIZE_TEXT % [break_window_size_slider.value]
	break_window_exclusive_button.set_pressed_no_signal(!stats.break_window_exclusive)
	break_window_message_button.set_pressed_no_signal(!stats.break_window_message)

	break_window_countdown_button.set_pressed_no_signal(stats.break_window_timer_countdown)
	break_window_countdown_timeout_button.set_pressed_no_signal(stats.break_window_close_on_timeout)
	if break_window_countdown_button.button_pressed == false:
		break_window_countdown_timeout_button.disabled = true
	break_window_countdown_slider.value = stats.break_window_time / 60
	break_window_countdown_slider.editable = stats.break_window_timer_countdown
	break_window_countdown_label.text = COUNTDOWN_TIME_TEXT % [break_window_countdown_slider.value]
	break_window_countdown_timeout_slider.value = stats.break_window_timeout_time
	break_window_countdown_timeout_slider.editable = stats.break_window_close_on_timeout
	break_window_countdown_timeout_label.text = AUTOCLOSE_TEXT % [break_window_countdown_timeout_slider.value]

	break_window_image_filter_colorpicker.color = stats.break_window_image_filter_color
	break_window_ui_filter_colorpicker.color = stats.break_window_ui_bg_color

	reminder_window_enabled_button.set_pressed_no_signal(stats.reminder_window_enabled)
	reminder_window_popup_time_slider.value = stats.reminder_time
	reminder_window_popup_time_label.text = REMINDER_TIME_TEXT % [stats.reminder_time]

	audio_button.set_pressed_no_signal(stats.audio_enabled)
	audio_slider.value = stats.audio_addend
	audio_label.text = AUDIO_ADDEND_TEXT % [audio_slider.value]

func _connect_settings() -> void:
	# First Grid
	session_time_slider.value_changed.connect(func(value:float) -> void:
		session_label.text = SESSION_TIME_TEXT % [value]
		stats.session_time = value*60
	)
	break_window_size_slider.value_changed.connect(func(value:float) -> void:
		break_window_size_label.text = BREAK_WINDOW_SIZE_TEXT % [value]
		stats.break_window_size = value
	)
	break_window_exclusive_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_exclusive = !toggled_on
	)
	break_window_message_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_message = !toggled_on
	)

	# Second Grid
	break_window_countdown_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_timer_countdown = toggled_on
		break_window_countdown_slider.editable = toggled_on
		break_window_countdown_timeout_button.button_pressed = toggled_on
		break_window_countdown_timeout_button.disabled = !toggled_on
		break_window_countdown_timeout_slider.editable = toggled_on
	)
	break_window_countdown_timeout_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.break_window_close_on_timeout = toggled_on
		break_window_countdown_timeout_slider.editable = toggled_on
	)
	break_window_countdown_slider.value_changed.connect(func(value:float) -> void:
		break_window_countdown_label.text = COUNTDOWN_TIME_TEXT % [value]
		stats.break_window_time = value * 60
	)
	break_window_countdown_timeout_slider.value_changed.connect(func(value:float) -> void:
		break_window_countdown_timeout_label.text = AUTOCLOSE_TEXT % [value]
		stats.break_window_timeout_time = int(value)
	)

	# Third Grid
	break_window_image_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_image_filter_color = color
	)
	break_window_ui_filter_colorpicker.color_changed.connect(func(color:Color) -> void:
		stats.break_window_ui_bg_color = color
	)

	# Fourth Grid
	reminder_window_enabled_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.reminder_window_enabled = toggled_on
	)
	reminder_window_popup_time_slider.value_changed.connect(func(value:float) -> void:
		reminder_window_popup_time_label.text = REMINDER_TIME_TEXT % [value]
		stats.reminder_time = int(value)
	)

	# Fith Grid
	audio_button.toggled.connect(func(toggled_on:bool) -> void:
		stats.audio_enabled = toggled_on
	)
	audio_slider.value_changed.connect(func(value:float) -> void:
		audio_label.text = AUDIO_ADDEND_TEXT % [value]
		stats.audio_addend = int(value)
	)

func _on_reset_button_pressed() -> void:
	stats = StatsDataPT.new()
	_load_settings()
