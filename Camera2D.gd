extends Camera2D



func _on_player_entered():
	$AnimationPlayer.play("move_right")

func _on_player_exited():
	$AnimationPlayer.active = false
