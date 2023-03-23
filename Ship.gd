extends KinematicBody2D

export (String) var ship_name = "Ship " + str(self.get_instance_id())

signal ship_clicked_on

onready var agent = $NavigationAgent2D
onready var animation_player = $AnimationPlayer

var velocity = Vector2.ZERO
var speed = 200
var target_position = null
onready var sprite = $ShipA

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	agent.max_speed = speed
	get_tree().call_group("Level", "connect_ship_signals", self)

func _on_Ship_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
#			print("got a mouse event! " + ship_name)
			emit_signal("ship_clicked_on", self)

func _physics_process(delta):
	if agent.is_navigation_finished():
#		print("Navigation is done!")
		target_position = null
		return
		
	if not target_position:
		return
		
	var next_location = agent.get_next_location()
	var agent_position = global_transform.origin
	
	var direction = agent_position.direction_to(next_location)
	
	
#	velocity = speed * direction
	
	var new_velocity = Utils.follow_with_steering(velocity, agent_position, next_location, speed)
	
	agent.set_velocity(new_velocity)
	
func _on_Ship_mouse_entered():
	animation_player.play("mouse_over")
	get_tree().call_group("Level", "mouse_over", self)


func _on_Ship_mouse_exited():
	animation_player.play("mouse_exit")
	get_tree().call_group("Level", "mouse_exit", self)

func clicked():
	animation_player.play("selected")
	

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	sprite.rotation = safe_velocity.angle() + 90
	velocity = move_and_slide(safe_velocity)
