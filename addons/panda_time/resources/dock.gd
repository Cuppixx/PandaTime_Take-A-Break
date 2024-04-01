@tool
class_name PandaTimeDock extends Control

@onready var timer:Timer = $BreakTimer
@onready var timer_label:Label = $VBoxContainer/TimerLabel
@onready var skip_button:Button = $VBoxContainer/HBoxContainer/SkipButton
@onready var stop_button:Button = $VBoxContainer/HBoxContainer/StopButton
@onready var settings_button:Button = $VBoxContainer/SettingsButton

# Path and Stats
const PT_WINDOW_BREAK:Resource = preload("res://addons/panda_time/resources/window_break.tscn")
const ROOT_PATH:String = "user://"
const FILE_NAME:String = "panda_time.tres"
var stats:StatsDataPT

# Timer Stuff
const TIMER_TEXT:String = "%s:%s:%s"

# Reminder Stuff
var snoozed:bool = false
var snooze_time:int = 0
var dismissed:bool = false

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

		skip_button.pressed.connect(func() -> void: _open_new_session_window())
		stop_button.pressed.connect(func() -> void:
			if timer.paused == false: timer.paused = true
			else: timer.paused = false
		)
		settings_button.pressed.connect(func() -> void:
			settings_button.disabled = true
			var window:Resource = load("res://addons/panda_time/resources/window_settings.tscn")
			var window_instance:PTwindowSettings = window.instantiate()
			window_instance.stats = stats
			window_instance.position = DisplayServer.screen_get_size() / 2 - window_instance.size / 2
			DisplayServer.set_native_icon("res://addons/panda_time/resources/images/icon.ico")
			add_child(window_instance,false,Node.INTERNAL_MODE_FRONT)
			window_instance.set_current_screen(DisplayServer.window_get_current_screen())
			window_instance.tree_exiting.connect(func() -> void:
				#var window_instance_old:Window = get_child(0,true)
				#stats = window_instance_old.stats
				stats = window_instance.stats
				settings_button.disabled = false
			)
		)

func _on_break_timer_timeout() -> void:
	var hours:String = str(stats.break_time_counter / 3600)
	var minutes:String = str(stats.break_time_counter % 3600 / 60)
	var seconds:String = str(stats.break_time_counter % 3600 % 60)
	if int(hours) < 10: hours = str(0)+hours
	if int(minutes) < 10: minutes = str(0)+minutes
	if int(seconds) < 10: seconds = str(0)+seconds
	timer_label.text = TIMER_TEXT % [hours,minutes,seconds]
	if stats.break_time_counter == 0:
		if snoozed:
			stats.break_time_counter = snooze_time
			snoozed = false
		elif dismissed:
			stats.break_time_counter = stats.break_time
			dismissed = false
		else:
			_open_new_session_window()
	if stats.break_time_counter == stats.reminder_time:
		if stats.reminder_window_enabled:
			_open_new_reminder_window()
	emit_signal("pt_remaining_time",timer_label.text)
	stats.break_time_counter -= 1

signal pt_remaining_time(remaining_time:String)
func _open_new_reminder_window() -> void:
	var window:PTwindowReminder = load("res://addons/panda_time/resources/window_reminder.tscn").instantiate()

	window.is_ready = true
	window.visible = false
	window.position.y = DisplayServer.screen_get_usable_rect().size.y - window.size.y - 20
	DisplayServer.set_native_icon("res://addons/panda_time/resources/images/icon.ico")
	add_child(window)
	window.set_current_screen(DisplayServer.window_get_current_screen())

func _open_new_session_window() -> void:
	timer.stop()

	skip_button.disabled = true
	stop_button.disabled = true
	settings_button.disabled = true

	var window:PTwindowBreak = PT_WINDOW_BREAK.instantiate()
	match stats.break_window_exclusive:
		true: window.exclusive = false
		false: window.exclusive = true
	window.size = Vector2i.ONE * (450 * (stats.break_window_size * 0.01))
	window.position = DisplayServer.screen_get_size() / 2 - window.size / 2
	window.new_break_time = stats.break_time
	DisplayServer.set_native_icon("res://addons/panda_time/resources/images/icon.ico")
	add_child(window,false,Node.INTERNAL_MODE_FRONT)
	window.set_current_screen(DisplayServer.window_get_current_screen())

	window.tree_exiting.connect(func() -> void:
		snoozed = false
		dismissed = false
		stats.break_time_counter = window.new_break_time
		stats.break_time = window.new_break_time
		_on_break_timer_timeout()
		timer.paused = false
		timer.start(1)
		skip_button.disabled = false
		stop_button.disabled = false
		settings_button.disabled = false
	)

func write_savefile() -> void:
	ResourceSaver.save(stats,ROOT_PATH+FILE_NAME,0)

func _load_savefile() -> Resource:
	return ResourceLoader.load(ROOT_PATH+FILE_NAME,"",0)

func _verify_file() -> bool:
	if DirAccess.open(ROOT_PATH).file_exists(FILE_NAME) == true: return true
	else: return false
