extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var tricking_right_glow: AnimatedSprite2D = %"Tricking Right Glow?"
@onready var ground_ray_left: RayCast2D = %"Ground Ray Left"
@onready var ground_ray_right: RayCast2D = %"Ground Ray Right"
@onready var jump_sfx: AudioStreamPlayer = %"Jump SFX"
@onready var skid_sfx: AudioStreamPlayer = %"Skid SFX"
@onready var spin_sfx: AudioStreamPlayer = %"Spin SFX"
@onready var spindash_sfx: AudioStreamPlayer = %"Spindash SFX"
@onready var trick_sfx: AudioStreamPlayer = %"Trick SFX"
@onready var bounce_sfx: AudioStreamPlayer = %"Bounce SFX"
@onready var die_sfx: AudioStreamPlayer = %"Die SFX"

const jump_velocity = -933.3
const max_speed = 1500
const skid_speed = 350
const acceleration = 200
const friction = 750
const min_speed = 150
const spindash_interval = 250
const spindash_max = 2500
const sprite_offset = 8
const roll_friction = 200
const roll_acceleration = 60
const ramp_launch_speed = 500
const launch_power = 0.75

const gravity = 2500

@export var starting_velocity = Vector2(0.0, 0.0)

var last_output = "Placeholder String"

var frames_on_ramp = 0
var last_floor_angle = 0.0
var launched = false
var spindash_charge = 750    # half constant
var last_floor_is_ramp = false
var is_on_slope = false
var level_started = false

var direction = 0
var jumping = false
var skidding = false
var spindashing = false
var rolling = false
var crouching = false
var homing = false
var tricking = false
var bouncing = false
var trick_bounce = false
var falling = false
var sprite_offset_check = false
var spindash_press = 0
var facing = 1
var dead = false
var debug_mode = false

func _physics_process(delta: float) -> void:
	if !debug_mode:
		if !dead:
			set_collision_layer_value(1, true)
			set_collision_mask_value(1, true)
		if !level_started and !velocity:
			velocity = starting_velocity
			level_started = true
	
		if !is_on_floor():
			if !sprite.animation in ["tricking_up_start", "tricking_down_start", "tricking_right_start"]:
				velocity += -up_direction * gravity * delta
	
		if sprite.animation in ["tricking_up_start", "tricking_down_start", "tricking_right_start"] or bouncing or trick_bounce and !dead:
			direction = 0
		else:
			direction = Input.get_axis("left", "right") if !dead else 0
		if direction and !spindashing and !rolling and !dead:
			if abs(velocity.x) > abs(min_speed - 1):
				var accel = acceleration
			
				if is_on_floor():
					var normal = get_floor_normal()
					if direction > 0:
						if normal.x < 0:
							accel *= 0.7
						elif normal.x > 0:
							accel *= 1.6
				
					elif direction < 0:
						if normal.x > 0:
							accel *= 0.7
						elif normal.x < 0:
							accel *= 1.6
						
				velocity.x = move_toward(velocity.x, direction * max_speed, accel * delta)
			else:
				velocity.x = direction * min_speed
		elif !spindashing and !rolling:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		
		if Input.is_action_just_pressed("jump") and !spindashing and !crouching and !dead:
			if is_on_floor():
				velocity += get_floor_normal() * -jump_velocity
				sprite.play("jump_1")
				jumping = true
				jump_sfx.play()
			elif !is_on_floor() and jumping:
				if !homing:
					if direction > 0 or direction < 0:
						velocity.x = 1800 * direction
						velocity.y = 0
					else:
						velocity.x = 1800 * facing
						velocity.y = 0
					spindash_sfx.play()
					homing = true
				
		if !is_on_floor() and Input.is_action_pressed("trick") and launched and !tricking and !dead:
			if Input.is_action_pressed("up"):
				sprite.play("tricking_up_start")
				trick_sfx.play()
				velocity = Vector2.ZERO
				tricking = true
			elif Input.is_action_pressed("left"):
				trick_sfx.play()
				velocity.x = -700
				velocity.y = -700
				tricking = true
			elif Input.is_action_pressed("down"):
				sprite.play("tricking_down_start")
				velocity = Vector2.ZERO
				tricking = true
			elif Input.is_action_pressed("right"):
				trick_sfx.play()
				sprite.play("tricking_right_start")
				velocity = Vector2.ZERO
				tricking = true
			else:
				trick_sfx.play()
				velocity.x = -700
				velocity.y = -700
				tricking = true
	
		if velocity.y > 0 and sprite.animation == "tricking_up" and !dead:
			sprite.play("tricking_up_fall_start")
			
		if Input.is_action_just_released("jump") and velocity.y < 0 and !Input.is_action_pressed("up") and !spindashing and !crouching and !dead:
			velocity.y *= 0.5
			
		if abs(velocity.x) < 0.5 and is_on_floor() and Input.is_action_pressed("down") and !rolling and !launched and !tricking and !falling and !trick_bounce and !bouncing and !dead:
			if !crouching and !spindashing:
				crouching = true
				sprite.play("crouch")
				sprite.position.y = 2
			if Input.is_action_just_pressed("jump"):
				spindashing = true
				spindash_press += 1
				if !sprite_offset_check and spindash_press == 1 and spindashing:
					sprite.position.y = 9
					sprite.play("spindash")
				sprite_offset_check = true
				spin_sfx.play()
				if spindash_press > 1:
					sprite.play("spindash_charge")
				spindash_charge = min(spindash_charge + spindash_interval, spindash_max)
		elif Input.is_action_just_released("down") and is_on_floor() and !dead:
			if spindash_charge > 750:
				velocity.x = facing * spindash_charge
				spindash_sfx.play()
				sprite.play("jump_3")
				rolling = true
				spindashing = false
				sprite_offset_check = false
				spindash_press = 0
				spindash_charge = 750
				sprite.position.y = 9
			else:
				sprite.frame = sprite.sprite_frames.get_frame_count("crouch") - 1
				sprite.play("crouch", -1.0)
				await get_tree().create_timer(0.3).timeout
				sprite.position.y = 1
			crouching = false
	
		if abs(velocity.x) > skid_speed and is_on_floor() and sign(direction) != sign(velocity.x) and direction != 0 and !spindashing and !rolling and !crouching and !dead:
			if !skidding:
				skidding = true
				if sign(facing) != sign(velocity.x):
					facing *= -1
				sprite.play("skid_start")
				skid_sfx.play()
				if abs(velocity.x) > 1600:
					velocity.x = move_toward(velocity.x, 0, friction * 190 * delta)
				elif abs(velocity.x) >= 1300:
					velocity.x = move_toward(velocity.x, 0, friction * 170 * delta)
				elif abs(velocity.x) >= 1100:
					velocity.x = move_toward(velocity.x, 0, friction * 110 * delta)
				else:
					velocity.x = move_toward(velocity.x, 0, friction * 80 * delta)
		elif !dead:
			skidding = false
	
		if is_on_floor() and !jumping and !skidding and !rolling and !spindashing and !crouching and !falling and !tricking and !bouncing and !trick_bounce and !dead:
			if abs(velocity.x) > 1600:
				sprite_play("full_speed")
			elif abs(velocity.x) > 1100:
				sprite_play("run")
			elif abs(velocity.x) > 650:
				sprite_play("half_run")
			elif abs(velocity.x) > 300:
				sprite_play("jog")
			elif abs(velocity.x) > 0:
				sprite_play("walk")
			else:
				sprite_play("idle")
		
		if (ground_ray_left.is_colliding() or ground_ray_right.is_colliding()) and velocity.y > 0 and !trick_bounce and !bouncing and !dead:
			if !falling:
				sprite.play("fall_start")
				falling = true
	
		if abs(velocity.x) > 0 and Input.is_action_just_pressed("down") and is_on_floor():
			if !rolling:
				rolling = true
				sprite.play("jump_3")
				spin_sfx.play()
				sprite.position.y = 9
		
		if (abs(velocity.x) == 0 or Input.is_action_just_pressed("jump")) and is_on_floor():
			if rolling:
				rolling = false
				sprite.position.y = 1
	
		if abs(velocity.x) > 0 and crouching:
			crouching = false
		
		if is_on_floor():
			if last_floor_is_ramp and abs(velocity.x) > ramp_launch_speed:
				floor_snap_length = 0
			else:
				floor_snap_length = 24
		elif !is_on_wall() and last_floor_angle < deg_to_rad(90.0):
			floor_snap_length = 48
		
		move_and_slide()
		
		if !is_on_floor() and velocity.y < -100 and !launched and !jumping and !spindashing and !rolling and !crouching and !tricking and !skidding:
			launched = true
		
		if is_on_floor() and !dead:
			if launched:
				launched = false
			if homing:
				homing = false
			if tricking:
				tricking = false
			if jumping:
				jumping = false
			if falling:
				falling = false
			if bouncing:
				bouncing = false
			if trick_bounce:
				sprite.play("jump_3")
				velocity += get_floor_normal() * -jump_velocity * 1.25
				bounce_sfx.play()
				bouncing = true
				trick_bounce = false
			if tricking_right_glow.animation == "on":
				tricking_right_glow.play("off")
		
		if Input.is_action_just_pressed("enter_debug"):
			debug_mode = true
	
		if abs(velocity.x) < skid_speed and sign(direction) != sign(velocity.x) and is_on_floor() and direction != 0 and !rolling and !skidding:
			velocity.x = 0
	
		if facing == 1 or dead:
			sprite.flip_h = false
		elif facing == -1:
			sprite.flip_h = true
	
		if is_on_floor() or sprite.animation in ["fall_start", "fall", "jump_0", "jump_1", "jump_2", "jump_3"] and !dead:
			if velocity.x < -10 and direction < 0:
				facing = -1
				sprite.flip_h = true
			elif velocity.x > 10 and direction > 0:
				facing = 1
				sprite.flip_h = false
		if !is_on_floor() and !tricking and sprite.animation not in ["fall_start", "fall"] and !dead:
			if direction < 0:
				facing = -1
				sprite.flip_h = true
			elif direction > 0:
				facing = 1
				sprite.flip_h = false
	else:
		if Input.is_action_just_pressed("enter_debug"):
			debug_mode = false
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		if Input.is_action_pressed("down"):
			position.y += 10
		if Input.is_action_pressed("right"):
			position.x += 10
		if Input.is_action_pressed("up"):
			position.y -= 10
		if Input.is_action_pressed("left"):
			position.x -= 10

func sprite_play(new_anim: String):
	if sprite.animation != new_anim:
		var current_frame = sprite.frame
		sprite.play(new_anim)
		sprite.frame = current_frame
		
func die():
	Global.timer_ticking = false
	sprite.rotation_degrees = 0
	if !dead:
		dead = true
		sprite.rotation_degrees = 0
		tricking_right_glow.play("off")
		set_process_input(false)
		velocity = Vector2(0.0, -1000.0)
		die_sfx.play()
		sprite.play("death_start")
		move_and_slide()
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
		Global.lives -= 1
		Global.minigames_done -= 1
		await get_tree().create_timer(1.5, true).timeout
		get_tree().change_scene_to_file("res://scenes/level_scene.tscn")
	
func _on_sprite_frame_changed() -> void:
	if !sprite:
		return # safety check
	if sprite.animation == "jump_0" and sprite.frame > 0:
		sprite.play("jump_3")
		velocity.y = 1000
		trick_bounce = true
	if sprite.animation == "jump_1" and sprite.frame > 0:
		sprite.play("jump_2")
	if sprite.animation == "jump_2" and sprite.frame > 1:
		sprite.play("jump_3")
	if sprite.animation == "jump_3" and sprite.frame > 1 and !rolling and !tricking and !trick_bounce and !bouncing:
		sprite.play("jump_2")
	if sprite.animation == "skid_start" and sprite.frame > 1:
		sprite.play("skid")
	if sprite.animation == "fall_start" and sprite.frame == 0:
		sprite.play("fall")
	if sprite.animation == "spindash_charge" and sprite.frame > 2:
		sprite.play("spindash")
	if sprite.animation == "tricking_up_start" and sprite.frame == 3:
		sprite.play("tricking_up")
		velocity.y = jump_velocity * 1.25
	if sprite.animation == "tricking_up_fall_start" and sprite.frame > 0:
		sprite.play("tricking_up_fall")
	if sprite.animation == "tricking_down_start" and sprite.frame > 2:
		sprite.play("jump_0")
	if sprite.animation == "tricking_right_start" and sprite.frame > 1:
		sprite.play("tricking_right")
		tricking_right_glow.play("on")
		velocity.x = 1800
	if sprite.animation == "death_start" and sprite.frame > 3:
		sprite.play("death_middle")
	if sprite.animation == "death_middle" and sprite.frame > 0:
		sprite.play("death")
