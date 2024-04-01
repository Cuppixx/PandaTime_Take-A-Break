@tool
class_name PTwindowReminder extends Window

#region @onready vars
@onready var parent:Control = $".."

@onready var time_label:Label = $Control/MarginContainer/VBoxContainer/Label
@onready var snooze_slider:HSlider = $Control/MarginContainer/VBoxContainer/HBoxContainer/HSlider
@onready var snooze_label:Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/Label

@onready var animation_player:AnimationPlayer = $AnimationPlayer

@onready var page_flip_audio:AudioStreamPlayer = $"../Audio/AudioStreamPlayer_PageFlip"
@onready var scribble_audio:AudioStreamPlayer = $"../Audio/AudioStreamPlayer_Scribble"
@onready var pencil_tick_audio:AudioStreamPlayer = $"../Audio/AudioStreamPlayer_PencilTick"
#endregion

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: _collapse_window()
		_: pass

var is_ready:bool = false
func _ready() -> void:
	if is_ready:
		page_flip_audio.play()
		parent.pt_remaining_time.connect(func(remaining_time:String) -> void:
			time_label.text = remaining_time.erase(1,3)
		)
		animation_player.play("slide_in")
		var bg_color_picker:ColorPickerButton = $Control/ColorPickerButton
		var bg_color_rect:ColorRect = $Control/ColorRect
		bg_color_rect.color = parent.stats.reminder_window_bg_color
		bg_color_picker.color = parent.stats.reminder_window_bg_color
		bg_color_picker.color_changed.connect(func(color:Color) -> void:
			bg_color_rect.color = color
			parent.stats.reminder_window_bg_color = color
		)
		_set_snooze_time_label(parent.stats.snooze_time)
		snooze_slider.value = parent.stats.snooze_time

func _collapse_window() -> void:
	page_flip_audio.play()
	animation_player.play("slide_out")
	await page_flip_audio.finished
	queue_free()

func _set_snooze_time_label(snooze_time:int) -> void:
	snooze_label.text = "%.0f sec" % [snooze_time]
	if snooze_time >= 10 and snooze_time < 100:
		snooze_label.text = str(0)+snooze_label.text

func _on_dismiss_button_pressed() -> void:
	get_parent().dismissed = true
	_collapse_window()

func _on_snooze_button_pressed() -> void:
	parent.snoozed = true; parent.snooze_time = snooze_slider.value
	_collapse_window()

func _on_quit_button_pressed() -> void:
	_collapse_window()

func _on_h_slider_drag_started() -> void: scribble_audio.play()

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	scribble_audio.stop(); pencil_tick_audio.play()

func _on_h_slider_value_changed(value: float) -> void:
	parent.stats.snooze_time = value
	_set_snooze_time_label(value)

func _on_color_picker_button_picker_created() -> void:
	pencil_tick_audio.play()

func _on_color_picker_button_popup_closed() -> void:
	pencil_tick_audio.play()
