extends KinematicBody2D

var velocity = Vector2()
export (int) var SPEED
export (int) var HEALTH
var current_hp
var is_attacking = false
var attack_on_cooldown = false
var moving_left = true
var alive = true

onready var ray_wall = $RayWall
onready var ray_char = $RayChar
onready var ray_behind = $RayBehind
# Called when the node enters the scene tree for the first time.
func _ready():
	current_hp = HEALTH
	pass # Replace with function body.

func _physics_process(_delta):
	#Check if attacking then check raycasts
	if alive == true:
		if is_attacking == false:
			if ray_char.is_colliding() && attack_on_cooldown == false:
				$AnimatedSprite.play("attack")
				$AttackCollision/start.disabled = false
				$SwingTimer.start()
				is_attacking = true
			elif ray_wall.is_colliding():
				swap_sides()
			elif ray_behind.is_colliding():
				$TurnTimer.start()
		
		#Check if still not attacking then move (or not if attacking)
		if is_attacking == false:
			if moving_left == true:
				velocity.x = -SPEED
				$AnimatedSprite.play("walk")
			else:
				velocity.x = SPEED
				$AnimatedSprite.play("walk")
		else:
			velocity.x = 0
		
		velocity = move_and_slide(velocity,Vector2.UP)
		
		velocity.x = lerp(velocity.x,0,0.2)

#Turns the boss around
func swap_sides():
	if moving_left == true:
		moving_left = false
		$AnimatedSprite.set_flip_h(true)
		$AttackCollision.scale = Vector2(-1,1)
		$RayWall.scale = Vector2(-1,1)
		$RayChar.scale = Vector2(-1,1)
		$RayBehind.scale = Vector2(-1,1)
	else:
		moving_left = true
		$AnimatedSprite.set_flip_h(false)
		$AttackCollision.scale = Vector2(1,1)
		$RayWall.scale = Vector2(1,1)
		$RayChar.scale = Vector2(1,1)
		$RayBehind.scale = Vector2(1,1)


func _on_SwingTimer_timeout():
	$AttackCollision/start.disabled = true
	$AttackCollision/end.disabled = false

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		attack_on_cooldown = true
		$AttackCollision/end.disabled = true
		is_attacking = false
		$AttackCooldownTimer.start()
		$AnimatedSprite.play("idle")


func _on_AttackCooldownTimer_timeout():
	attack_on_cooldown = false

func _on_TurnTimer_timeout():
	swap_sides()


func _on_AttackCollision_body_entered(_body):
	CharacterController.player_hit()

func boss_hit(dmg):
	current_hp -= dmg
	if current_hp <=0:
		CharacterController.emit_signal("boss_dead")
		#Temporary idle animation, swap to dead animation later
		$AnimatedSprite.play("idle")
		alive = false