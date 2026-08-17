extends Camera2D

@export var decay = 2
@export var max_offset = Vector2(8, 6)
@export var max_roll = 0.5
@export var noise: FastNoiseLite = FastNoiseLite.new()

var trauma = 0.0
var trauma_power = 2
var time = 0.0

func _ready():
	randomize()
	noise.seed = randi()
	noise.frequency = 0.25

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	if trauma > 0:
		time += delta * 100
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		offset = Vector2.ZERO
		rotation = 0

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * noise.get_noise_2d(time, 0)
	offset.x = max_offset.x * amount * noise.get_noise_2d(time, 1)
	offset.y = max_offset.y * amount * noise.get_noise_2d(time, 2)
