@tool
class_name PandaTimeDock extends Control

#region @onready vars
@onready var timer:Timer = $SessionTimer
@onready var timer_label:Label = $MarginContainer/VBoxContainer/TimerLabel
@onready var skip_button:TextureButton = $MarginContainer/VBoxContainer/SkipButton
@onready var stop_button:TextureButton = $MarginContainer/VBoxContainer/StopButton
@onready var settings_button:TextureButton = $MarginContainer/VBoxContainer/SettingsButton
#endregion

# Signals
signal pt_remaining_time(remaining_time:String)
signal pt_free_reminder

# Path and Stats
const PT_WINDOW_BREAK:Resource = preload("res://addons/panda_time/resources/window_break.tscn")
const ICON_PATH:String = "res://addons/panda_time/resources/images/icon.ico"
const ROOT_PATH:String = "user://"
const FILE_NAME:String = "panda_time.tres"
var stats:StatsDataPT

# Timer Code
const TIMER_TEXT:String = "%s:%s:%s"

# Reminder Code
var snoozed:bool = false
var snooze_time:int = 0
var dismissed:bool = false

# Settings Code
var is_settings_window_open:bool = false

var plugin_is_running:bool = false
func _ready() -> void:
	if plugin_is_running:
		# Verify previous saved data
		if _verify_file() == false:
			stats = StatsDataPT.new()
			write_savefile()
		else: stats = _load_savefile()

		_on_break_timer_timeout()
		timer.paused = false
		timer.start(1)

		skip_button.pressed.connect(_open_new_session_window)
		stop_button.toggled.connect(func(toggled:bool) -> void:
			timer.paused = toggled
		)
		settings_button.pressed.connect(func() -> void:
			settings_button.set_disabled_custom(true)
			is_settings_window_open = true

			var window:Resource = load("res://addons/panda_time/resources/window_settings.tscn")
			var window_instance:PTwindowSettings = window.instantiate()

			window_instance.stats = stats
			window_instance.position = DisplayServer.screen_get_size() / 2 - window_instance.size / 2
			DisplayServer.set_native_icon(ICON_PATH)

			add_child(window_instance,false,Node.INTERNAL_MODE_FRONT)
			window_instance.set_current_screen(DisplayServer.window_get_current_screen())

			window_instance.tree_exiting.connect(func() -> void:
				stats = window_instance.stats
				settings_button.set_disabled_custom(false)
				is_settings_window_open = false
			)
		)

func _on_break_timer_timeout() -> void:
	var hours:String = str(stats.session_time_counter / 3600)
	var minutes:String = str(stats.session_time_counter % 3600 / 60)
	var seconds:String = str(stats.session_time_counter % 3600 % 60)
	if int(hours) < 10: hours = str(0)+hours
	if int(minutes) < 10: minutes = str(0)+minutes
	if int(seconds) < 10: seconds = str(0)+seconds
	timer_label.text = TIMER_TEXT % [hours,minutes,seconds]

	if stats.session_time_counter == 0:
		if dismissed:
			dismissed = false
			stats.session_time_counter = stats.session_time
		elif snoozed:
			snoozed = false
			stats.session_time_counter = snooze_time
		else: _open_new_session_window()
	elif stats.session_time_counter == stats.reminder_time:
		if stats.reminder_window_enabled: _open_new_reminder_window()

	emit_signal("pt_remaining_time",timer_label.text)
	stats.session_time_counter -= 1

func _open_new_reminder_window() -> void:
	var window:PTwindowReminder = load("res://addons/panda_time/resources/window_reminder.tscn").instantiate()

	window.is_ready = true
	window.visible = false
	window.position.y = DisplayServer.screen_get_usable_rect().size.y - window.size.y - 20
	DisplayServer.set_native_icon(ICON_PATH)

	add_child(window)
	window.set_current_screen(DisplayServer.window_get_current_screen())

func _open_new_session_window() -> void:
	timer.stop()
	pt_free_reminder.emit()

	skip_button.set_disabled_custom(true)
	stop_button.set_disabled_custom(true)
	settings_button.set_disabled_custom(true)

	var window:PTwindowBreak = PT_WINDOW_BREAK.instantiate()

	window.is_ready = true
	match stats.break_window_exclusive:
		true: window.exclusive = false
		false: window.exclusive = true
	window.size = Vector2i.ONE * (450 * (stats.break_window_size * 0.01))
	window.position = DisplayServer.screen_get_size() / 2 - window.size / 2
	window.new_session_time = stats.session_time
	DisplayServer.set_native_icon(ICON_PATH)

	add_child(window,false,Node.INTERNAL_MODE_FRONT)
	window.set_current_screen(DisplayServer.window_get_current_screen())

	window.tree_exiting.connect(func() -> void:
		snoozed = false
		dismissed = false

		stats.session_time_counter = window.new_session_time
		stats.session_time = window.new_session_time
		_on_break_timer_timeout()
		timer.paused = false
		timer.start(1)

		skip_button.set_disabled_custom(false)
		stop_button.set_disabled_custom(false)
		if !is_settings_window_open: settings_button.set_disabled_custom(false)
	)

func write_savefile() -> void: ResourceSaver.save(stats,ROOT_PATH+FILE_NAME,0)
func _load_savefile() -> Resource: return ResourceLoader.load(ROOT_PATH+FILE_NAME,"",0)

func _verify_file() -> bool:
	if DirAccess.open(ROOT_PATH).file_exists(FILE_NAME) == true: return true
	else: return false
