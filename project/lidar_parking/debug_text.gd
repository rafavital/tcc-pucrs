extends TextEdit


var _reward : float
var _engine : float
var _steering : float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_text("Engine: %.2d\nSteering:%.2f\nReward:%.2f" %[_engine, sign(_steering),_reward])

func set_reward (value):
	_reward = value
	
func set_engine (value):
	_engine = value
	
func set_steering (value):
	_steering = value
