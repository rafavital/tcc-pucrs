extends MeshInstance3D

@onready var text_edit = $SubViewport/DebugGUI/TextEdit


func _on_car_reward_changed(value):
	text_edit.set_text("Reward: %.2f".format(value))
