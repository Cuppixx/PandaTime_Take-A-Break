@tool
class_name PTwindowBreak extends Window

# Constants
const IMAGE_ROOT_PATH:String = "res://addons/panda_time/images/"
const IMAGE_EXTENSIONS:Array[String] = ["png","jpg","jpeg","svg"]
const SEPARATOR:String = "/"
const ERR:String = "--> PT: An error occurred when trying to access the path!"
const TIMER_TEXT:String = "%s : %s : %s"
const SESSION_TEXT:String = "%d min"

const BASE_DB_PAGE_FLIP   :int =   3
const BASE_DB_SCRIBBLE    :int = -10
const BASE_DB_PENCIL_TICK :int = -18

#region @onready vars
@onready var parent := $".."

@onready var bg_color:ColorRect = $Control/ColorRect
@onready var bg_texture:TextureRect = $Control/TextureRect

@onready var message_container:MarginContainer = $Control/MessageMarginContainer
@onready var message_bg:ColorRect = $Control/MessageMarginContainer/ColorRect
@onready var message_label:Label = $Control/MessageMarginContainer/MessageLabel

@onready var timer:Timer = $Timer
@onready var timer_label:Label = $Control/TimerMarginContainer/TimerLabel

@onready var settings_bg:ColorRect = $Control/SettingsMarginContainer/ColorRect
@onready var next_button:Button = $Control/SettingsMarginContainer/MarginContainer/VBoxContainer/NextButton
@onready var session_label:Label = $Control/SettingsMarginContainer/MarginContainer/VBoxContainer/HBoxContainer/SessionLabel
@onready var session_slider:HSlider = $Control/SettingsMarginContainer/MarginContainer/VBoxContainer/HBoxContainer/SessionHSlider

@onready var anim_player:AnimationPlayer = $AnimationPlayer

@onready var page_flip_audio:AudioStreamPlayer
@onready var scribble_audio:AudioStreamPlayer
@onready var pencil_tick_audio:AudioStreamPlayer
#endregion

# Variables
var is_ready:bool = false
var file_array = []
var is_timer_countdown:bool = false
var countdown_time:int = 5 * 60 # In seconds
var new_session_time:int

var message := {
	1:   "Stretch those legs!",
	2:   "Eyes need rest too.",
	3:   "Time for a breather!",
	4:   "Refresh your mind.",
	5:   "Break time, buddy!",
	6:   "Take a walk outside.",
	7:   "A break awaits you.",
	8:   "Pause and relax.",
	9:   "Stretch and unwind.",
	10:  "Blink away fatigue.",
	11:  "Relaxation incoming!",
	12:  "Let's stretch it out!",
	13:  "Move those muscles!",
	14:  "A moment of zen.",
	15:  "Eyes off the screen.",
	16:  "Chill for a bit.",
	17:  "Take a breather.",
	18:  "Time to recharge.",
	19:  "Ready for a break?",
	20:  "Refresh and revive.",
	21:  "Clear your mind.",
	22:  "Breathe deeply now.",
	23:  "Brain break time!",
	24:  "Unwind and relax.",
	25:  "Relaxation station.",
	26:  "Step away for a sec.",
	27:  "Time to chillax.",
	28:  "Switch off, recharge.",
	29:  "Refresh your focus.",
	30:  "Let's take five.",
	31:  "Detox from screens.",
	32:  "A break is brewing.",
	33:  "Relax and rejuvenate.",
	34:  "Revitalize yourself.",
	35:  "Get up and move.",
	36:  "Ease your mind.",
	37:  "Break, don't break!",
	38:  "Revive your energy.",
	39:  "Step back and relax.",
	40:  "Relax, it's break time.",
	41:  "Time to decompress.",
	42:  "Take a little breather.",
	43:  "Just breathe, relax.",
	44:  "Break time, cheers!",
	45:  "Unplug for a while.",
	46:  "Relax and recharge.",
	47:  "Take a mini vacation.",
	48:  "Disconnect, rejuvenate.",
	49:  "Break time bliss!",
	50:  "Recharge your batteries!",
	51:  "Refresh your focus, friend.",
	52:  "Give your mind a break.",
	53:  "Eyes off, relax on.",
	54:  "A short break, big impact.",
	55:  "Take a breather, champ.",
	56:  "Step away, clear mind.",
	57:  "Reset and re-energize.",
	58:  "Relax, you've earned it.",
	59:  "Pause, then play better.",
	60:  "Unwind, then conquer.",
	61:  "Detox from the screen.",
	62:  "Rejuvenate your spirit.",
	63:  "Mindfulness moment now.",
	64:  "Reboot your brain.",
	65:  "Break time, find peace.",
	66:  "A moment to recharge.",
	67:  "Step back, find balance.",
	68:  "Refresh, refocus, restart.",
	69:  "Revive your creativity.",
	70:  "Take a timeout, superstar.",
	71:  "Decompress and de-stress.",
	72:  "Unplug, unwind, relax.",
	73:  "A brief escape awaits.",
	74:  "Break the routine, relax.",
	75:  "Renew your energy, now.",
	76:  "Refreshment break, ah!",
	77:  "Quick break, big results.",
	78:  "Time out for tranquility.",
	79:  "Chill out, cool down.",
	80:  "Take five, rejuvenate.",
	81:  "Relax, then rock on.",
	82:  "Reconnect with yourself.",
	83:  "Hit pause, find peace.",
	84:  "Revitalize your spirit.",
	85:  "Refresh, then return.",
	86:  "Unwind, then work wonders.",
	87:  "Breathe, reset, resume.",
	88:  "Pause for self-care.",
	89:  "Recharge, refuel, relax.",
	90:  "Refreshment break, hooray!",
	91:  "Short break, big benefits.",
	92:  "A break, the best medicine.",
	93:  "Time to chill, recharge.",
	94:  "Revitalize, then conquer.",
	95:  "A quick break, huge help.",
	96:  "Find calm, then conquer.",
	97:  "Short break, sharp mind.",
	98:  "Pause for positivity.",
	99:  "Refresh, then rock it!",
	100: "A break, a better you.",

	101: "Take a code break.",
	102: "Debug later, relax now.",
	103: "Chill, no syntax stress.",
	104: "Time for coding siesta.",
	105: "Decompress your code.",
	106: "Ctrl+Alt+Chill mode.",
	107: "Pause for byte-size fun.",
	108: "Relax, code will wait.",
	109: "Chillax and debug.",
	110: "Debug tomorrow, Chill now.",
	111: "Relax, no semicolon panic.",
	112: "Coffee break, code waits.",
	113: "Chill vibes, no bugs.",
	114: "Relax, no stack overflow.",
	115: "Unwind, refactor later.",
	116: "Take a chill pill.",
	117: "Code off, chill on.",
	118: "A delightful timeout.",
	119: "Error-free zone, relax.",
	120: "Chill like a compiler.",
	121: "Timeout for code cooldown.",
	122: "Debug delay, chill play.",
	123: "Chillwave coding playlist.",
	124: "Breakpoint for relaxation.",
	125: "Pause for coding laughter.",
	126: "Chill code, hot cocoa.",
	127: "No stress, just JSON.",
	128: "Relax, no merge conflicts.",
	129: "Code freeze, chill breeze.",
	130: "Escape the curly braces.",
	131: "Chill, no race conditions.",
	132: "Breathe, code gently.",
	133: "No more compiler tantrums.",
	134: "Take a code nap.",
	135: "Ctrl+Zzz relaxation.",
	136: "Chillax, no runtime errors.",
	137: "Relax, no memory leaks.",
	138: "Syntax serenity now.",
	139: "Decompress with code memes.",
	140: "Chill like a coding ninja.",
	141: "Code unwind session.",
	142: "Debug postponed!",
	143: "Code later, laugh now.",
	144: "Chill, no infinite loops.",
	145: "Time to code your dreams.",
	146: "Freetime, no bugs invited!",
	147: "Code zen zone activated.",
	148: "Take a chill byte.",
	149: "Relax, happiness loading.",

	150: "Time to RTFMM.",
}
var timeout_message := {
	1:  "Break is done",
	2:  "Break is over",
	3:  "Break is up",
	4:  "No more break",

	5:  "Time is done",
	6:  "Time is over",
	7:  "Time is up",
	8:  "Time to code",

	9:  "Enough rest",
	10: "Work calls",
	11: "Back to coding",
	12: "Resume coding",
	13: "Fun is over",
	14: "Back at it",
}



func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: queue_free()
		_: pass


func _ready() -> void:
	if is_ready:
		page_flip_audio = $"../Audio/AudioStreamPlayer1"
		scribble_audio = $"../Audio/AudioStreamPlayer2"
		pencil_tick_audio = $"../Audio/AudioStreamPlayer3"

		# Startup
		if parent.stats.audio_enabled:
			page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + parent.stats.audio_addend
			page_flip_audio.play()
		anim_player.speed_scale = 3
		anim_player.play("fade_in")

		# Set random Background and Text
		_get_dir_contents(IMAGE_ROOT_PATH)
		if file_array.size() > 0: bg_texture.texture = load(file_array[randi_range(0,file_array.size()-1)])
		if parent.stats.break_window_message == true:
			message_bg.color = parent.stats.break_window_ui_bg_color
			message_label.text = message[randi_range(1,message.size())]
		else:
			message_label.text = ""
			message_container.visible = false

		# Load Settings and Data
		bg_color.color = parent.stats.break_window_image_filter_color
		settings_bg.color = parent.stats.break_window_ui_bg_color

		is_timer_countdown = parent.stats.break_window_timer_countdown
		countdown_time = parent.stats.break_window_time
		timer_label.text = TIMER_TEXT % ["00","00","00"]

		_set_session_time_label()
		session_slider.value = new_session_time / 60

		# Connect Signals
		next_button.pressed.connect(_close_window)
		session_slider.drag_started.connect(func() -> void:
			if parent.stats.audio_enabled:
				scribble_audio.volume_db = BASE_DB_SCRIBBLE + parent.stats.audio_addend
				scribble_audio.play()
		)
		session_slider.drag_ended.connect(func(_bool:bool) -> void:
			scribble_audio.stop()
			if parent.stats.audio_enabled:
				pencil_tick_audio.volume_db = BASE_DB_PENCIL_TICK + parent.stats.audio_addend
				pencil_tick_audio.play()
		)
		session_slider.value_changed.connect(func(value:float) -> void:
			new_session_time = value * 60
			_set_session_time_label()
		)

		# Start the break time
		timer.start(1)

func _close_window() -> void:
	if parent.stats.audio_enabled:
		page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + parent.stats.audio_addend
		page_flip_audio.play()

	anim_player.speed_scale = 11
	anim_player.play("fade_out")

	if parent.stats.audio_enabled: await page_flip_audio.finished
	else: await anim_player.animation_finished
	queue_free()

func _set_session_time_label() -> void:
	session_label.text = SESSION_TEXT % [new_session_time / 60]
	if (new_session_time / 60) < 10: session_label.text = str(0)+str(0)+session_label.text
	elif (new_session_time / 60) >= 10 and (new_session_time / 60) < 100:
		session_label.text = str(0)+session_label.text

func _get_dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): _get_dir_contents(path+SEPARATOR+file_name)
			else:
				if file_name.get_extension().to_lower() in IMAGE_EXTENSIONS:
					file_array.append(dir.get_current_dir(true)+SEPARATOR+file_name)
			file_name = dir.get_next()
	else: push_error(ERR)

var hours:String = str(0)
var minutes:String = str(0)
var seconds:String = str(0)
func _on_timer_timeout() -> void:
	# Counting the timer down
	if is_timer_countdown:
		hours = str(countdown_time / 3600)
		minutes = str(countdown_time % 3600 / 60)
		seconds = str(countdown_time % 3600 % 60)
		if int(hours) < 10: hours = str(0)+hours
		if int(minutes) < 10: minutes = str(0)+minutes
		if int(seconds) < 10: seconds = str(0)+seconds
		if countdown_time > 0: timer_label.text = TIMER_TEXT % [hours,minutes,seconds]
		if countdown_time == 0:
			$AudioPlayer1.play()
			timer_label.self_modulate = Color(1,0,0,9.5)
			timer_label.text = (timeout_message[randi_range(1,timeout_message.size())]).to_upper()
		elif countdown_time == -(parent.stats.break_window_timeout_time):
			timer.stop()
			if parent.stats.break_window_close_on_timeout == true: _close_window()
			else: timer_label.visible = true
		elif countdown_time >= -(parent.stats.break_window_timeout_time) and countdown_time < 0:
			match timer_label.visible:
				true: timer_label.visible = false
				false: timer_label.visible = true
		countdown_time -= 1
	# Counting the timer up
	else:
		seconds = str(int(seconds) + 1)
		if int(seconds) >= 60: seconds = str(0); minutes = str(int(minutes) + 1)
		if int(minutes) >= 60: minutes = str(0); hours = str(int(hours) + 1)
		var final_hours:String = hours
		var final_minutes:String = minutes
		var final_seconds:String = seconds
		if int(final_hours) < 10: final_hours = str(0)+hours
		if int(final_minutes) < 10: final_minutes = str(0)+minutes
		if int(final_seconds) < 10: final_seconds = str(0)+seconds
		timer_label.text = TIMER_TEXT % [final_hours,final_minutes,final_seconds]
