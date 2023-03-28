extends KinematicBody2D

export (String) var ship_name = "Ship " + str(self.get_instance_id())

signal ship_clicked_on

onready var agent = $NavigationAgent2D
onready var animation_player = $AnimationPlayer

var velocity = Vector2.ZERO
var speed = 200
var target_position = null
var previous_target_position = null

onready var sprite = $ShipA

onready var target = get_node(target_path)

export (float) var slow_radius = 200

export (NodePath) var target_path = NodePath()
export (float) var follow_offset = 200.0

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	agent.max_speed = speed
	get_tree().call_group("Level", "connect_ship_signals", self)
	
	if target:
		target_position = target.global_position

func _on_Ship_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
#			print("got a mouse event! " + ship_name)
			emit_signal("ship_clicked_on", self)

func _physics_process(delta):
	if target != self and target != null:
		handle_follow_leader(delta)
		return
		
	if agent.is_navigation_finished():
#		print("Navigation is done!")
		target_position = null
		return
		
	if not target_position:
		return
		
	var next_location = agent.get_next_location()
	var agent_position = global_transform.origin
	
	var direction = agent_position.direction_to(next_location)
	
	
#	var intended_velocity = speed * direction
	
#	var new_velocity = Utils.follow_with_steering(velocity, agent_position, next_location, speed, slow_radius)
	var new_velocity = Utils.arrive_to(velocity, agent_position, next_location, target_position, speed, slow_radius)
	
	agent.set_velocity(new_velocity)
	
func handle_follow_leader(delta):
	if not target_position:
		return
		
	if agent.is_navigation_finished():
#		set_physics_process(false)
		return
		
#	if global_transform.origin.distance_to(target_position) < follow_offset:
##		agent.set_velocity(Vector2.ZERO)
#		return
		
	var next_location = agent.get_next_location()
	var agent_position = global_transform.origin
	
	var direction = agent_position.direction_to(next_location)
	
#	var target_position_according_to_offset = agent_position.move_toward(target_position, follow_offset)
	var new_velocity = Utils.arrive_to(velocity, agent_position, next_location, target_position, speed, slow_radius)
#	sprite.rotation = new_velocity.angle() + 90
#
#	velocity = move_and_slide(new_velocity)
	agent.set_velocity(new_velocity)
	
func _on_Ship_mouse_entered():
	animation_player.play("mouse_over")
	get_tree().call_group("Level", "mouse_over", self)


func _on_Ship_mouse_exited():
	animation_player.play("mouse_exit")
	get_tree().call_group("Level", "mouse_exit", self)

func clicked():
	animation_player.play("selected")
	agent.radius = 0
	agent.neighbor_dist = 0

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
#	if safe_velocity == Vector2.ZERO and target:
#		pass
		
	sprite.rotation = safe_velocity.angle() + 90
	velocity = move_and_slide(safe_velocity)


func _on_Timer_timeout():
	if target == self or target == null:
		return
	
#	agent.avoidance_enabled = false
	
	target_position = target.global_position
	
#	if target_position == previous_target_position:
#		return
		
	agent.target_desired_distance = follow_offset	
	agent.set_target_location(target.global_position)
	previous_target_position = target_position

func _on_NavigationAgent2D_navigation_finished():
	target_position = null
