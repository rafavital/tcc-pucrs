extends Area3D




func _on_body_entered(body):
	if body is VehicleBody3D:
		body.call("on_out_of_bounds")