extends Node3D
class_name ParkSpot

@onready var cars = $Cars
@onready var body = $Cars/StaticBody3D

func _ready():
	for car in cars.get_children():
		car.hide()
	
	cars.get_children().pick_random().show()	

func hide_car () -> void :
	cars.hide()
	body.process_mode = Node.PROCESS_MODE_DISABLED

func show_car () -> void : 
	cars.show()
	body.process_mode = Node.PROCESS_MODE_INHERIT
