@tool
class_name PTwindowReminder extends Window

var is_ready:bool = false
var is_mouse_inside:bool = false

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST: _collapse_window()
		_: pass

func _ready() -> void:
	if is_ready:
		get_parent().pt_remaining_time.connect(func(remaining_time:String) -> void:
			$Control/MarginContainer/VBoxContainer/Label.text = remaining_time.erase(1,3)
		)
		$AnimationPlayer.play("slide_in")
		var parent:Control = get_parent()
		var bg_color_picker:ColorPickerButton = $Control/ColorPickerButton
		$Control/ColorRect.color = parent.stats.reminder_window_bg_color
		bg_color_picker.color = parent.stats.reminder_window_bg_color
		bg_color_picker.color_changed.connect(func(color:Color) -> void:
			$Control/ColorRect.color = color
			parent.stats.reminder_window_bg_color = color
		)

func _collapse_window() -> void:
	$AnimationPlayer.play("slide_out")
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_dismiss_button_pressed() -> void:
	get_parent().dismissed = true
	_collapse_window()

func _on_snooze_button_pressed() -> void:
	get_parent().snoozed = true
	get_parent().snooze_time = $Control/MarginContainer/VBoxContainer/HBoxContainer/HSlider.value
	_collapse_window()

func _on_quit_button_pressed() -> void:
	_collapse_window()

func _on_h_slider_value_changed(value: float) -> void:
	$Control/MarginContainer/VBoxContainer/HBoxContainer/Label.text = str(value)
