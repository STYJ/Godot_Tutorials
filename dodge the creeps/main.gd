extends Node

# exposes a variable called Mob on the inspector 
export (PackedScene) var Mob

var score
const MULTIPLIER = 0.99

func _ready():
	randomize()

func game_over():
	_stop_timers()
	$HUD.show_game_over()
	get_tree().call_group("mobs", "queue_free")
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

# When the MobTimer counts down to 0, spawn a mob.
func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.offset = randi()
	
	# Create a Mob instance and add it to the scene.
	var mob = Mob.instance()
	add_child(mob)
	
	# Set the mob's direction perpendicular to the path direction. 
	# We use Pi because GDScript uses radians, not degrees
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	
	# Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position
	
	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Set the velocity (speed & direction).
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)

# When ScoreTimer counts down to 0, add a score.
func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

# When StartTimer counts down to 0, start! 
func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	$MultiplierTimer.start()

# Reduce MobTimer every time MultiplierTimer times out
func _on_MultiplierTimer_timeout():
	$MobTimer.wait_time = $MobTimer.wait_time * MULTIPLIER

# Stop all timers
func _stop_timers():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$MultiplierTimer.stop()
