@tool
class_name PandaTimeDockItem extends TextureButton
var color:Color
func _ready() -> void:
	color = EditorInterface.get_editor_settings().get_setting("interface/theme/accent_color")
	self_modulate = color
	self.toggled.connect(func(toggled:bool) -> void:
		if toggled: self_modulate = Color.RED
		else: self_modulate = color
	)
func set_disabled_custom(disabled:bool) -> void:
	self.disabled = disabled
	if disabled: self_modulate = Color.DIM_GRAY
	else: self_modulate = color
