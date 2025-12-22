extends Node2D
class_name TurnManager

enum Turn {
	PLAYER,
	ENEMY
}

@export var player_board: CardBoard
@export var enemy_board: CardBoard

var current_turn := Turn.PLAYER

signal turn_changed(turn)

func end_turn():
	current_turn = Turn.ENEMY if current_turn == Turn.PLAYER else Turn.PLAYER
	emit_signal("turn_changed", current_turn)
