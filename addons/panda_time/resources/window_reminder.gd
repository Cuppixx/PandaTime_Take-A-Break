@tool
class_name PTwindowReminder extends Window

#region @onready vars
@onready var parent := $".."

@onready var bg_color_rect:ColorRect = $Control/ColorRect
@onready var time_label:Label = $Control/MarginContainer/VBoxContainer/TimeLabel
@onready var snooze_slider:HSlider = $Control/MarginContainer/VBoxContainer/HBoxContainer/SnoozeHSlider
@onready var snooze_label:Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/SnoozeLabel

@onready var anim_player:AnimationPlayer = $AnimationPlayer

@onready var page_flip_audio:AudioStreamPlayer
@onready var scribble_audio:AudioStreamPlayer
@onready var pencil_tick_audio:AudioStreamPlayer
#endregion

const BASE_DB_PAGE_FLIP:int = 0
const BASE_DB_SCRIBBLE:int = -15
const BASE_DB_PENCIL_TICK:int = -23

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: _collapse_window()
		_: pass

var is_ready:bool = false
func _ready() -> void:
	if is_ready:
		# Get Audio Refs
		page_flip_audio = $"../Audio/AudioStreamPlayer1"
		if parent.stats.audio_enabled:
			page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + parent.stats.audio_addend
			page_flip_audio.play()

		scribble_audio = $"../Audio/AudioStreamPlayer2"
		pencil_tick_audio = $"../Audio/AudioStreamPlayer3"

		parent.pt_free_reminder.connect(_collapse_window)
		parent.pt_remaining_time.connect(func(remaining_time:String) -> void:
			time_label.text = remaining_time.erase(1,3)
		)

		anim_player.play("slide_in")

		_set_snooze_time_label(parent.stats.snooze_time)
		snooze_slider.value = parent.stats.snooze_time

		# 252525 569eff
		var editor_settings:EditorSettings = EditorInterface.get_editor_settings()
		var interface_base_color:Color = editor_settings.get_setting("interface/theme/base_color")
		#print(interface_base_color)

		$Control/MarginContainerCollapse/ColorRect.color = interface_base_color

		var interface_accent_color:Color = editor_settings.get_setting("interface/theme/accent_color")
		interface_accent_color.a = 0.05
		#print(interface_accent_color)
		bg_color_rect.color = interface_base_color.blend(interface_accent_color)
		#print(bg_color_rect.color)
		#print(bg_color_rect.color.get_luminance())
		if bg_color_rect.color.get_luminance() <= 0.5:
			bg_color_rect.color = interface_base_color.lightened(0.125)
		else:
			bg_color_rect.color = interface_base_color.darkened(0.125)
		bg_color_rect.color = bg_color_rect.color.clamp(Color(0.2,0.2,0.2),Color(0.8,0.8,0.8))

func _collapse_window() -> void:
	if parent.stats.audio_enabled:
		page_flip_audio.volume_db = BASE_DB_PAGE_FLIP + parent.stats.audio_addend
		page_flip_audio.play()
	anim_player.play("slide_out")
	if parent.stats.audio_enabled: await page_flip_audio.finished
	else: await anim_player.animation_finished
	queue_free()

func _set_snooze_time_label(snooze_time:int) -> void:
	snooze_label.text = "%.0f sec" % [snooze_time]
	if snooze_time >= 10 and snooze_time < 100: snooze_label.text = str(0)+snooze_label.text

func _on_dismiss_button_pressed() -> void:
	parent.dismissed = true
	_collapse_window()

func _on_snooze_button_pressed() -> void:
	parent.snooze = true
	parent.snooze_time = snooze_slider.value
	_collapse_window()

func _on_quit_button_pressed() -> void: _collapse_window()

func _on_h_slider_drag_started() -> void:
	if parent.stats.audio_enabled:
		scribble_audio.volume_db = BASE_DB_SCRIBBLE + parent.stats.audio_addend
		scribble_audio.play()

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	scribble_audio.stop()
	if parent.stats.audio_enabled:
		pencil_tick_audio.volume_db = BASE_DB_PENCIL_TICK + parent.stats.audio_addend
		pencil_tick_audio.play()

func _on_h_slider_value_changed(value: float) -> void:
	parent.stats.snooze_time = value
	_set_snooze_time_label(value)
