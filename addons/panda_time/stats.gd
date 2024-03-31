class_name StatsDataPT extends Resource

# Dock / Global Settings
@export var break_time_counter:int = 45 * 60 # In seconds
@export var break_time:int = 45 * 60 # In seconds

# Break Window Settings
@export var break_window_exclusive:bool = false
@export var break_window_size:float = 150 # In percentage (100 == minimum / 200 = maximum)
@export var break_window_message:bool = true

@export var break_window_timer_countdown:bool = true
@export var break_window_time:int = 5 * 60 # In seconds
@export var break_window_close_on_timeout:bool = true
@export var break_window_timeout_time:int = 8 # In seconds
#auto close and timer for auto close

@export var break_window_custom_image_folder_path:String = "res://addons/panda_time/images/"
@export var break_window_image_filter_color:Color = Color.html("006763")
@export var break_window_ui_bg_color:Color = Color.html("00004169")

# Reminder Window Settings
@export var reminder_window_enabled:bool = true
@export var reminder_time:int = 0.5 * 60 # In seconds
@export var reminder_window_bg_color:Color = Color.html("00004169")
