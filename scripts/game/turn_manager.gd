extends Node2D
class_name TurnManager

@export var player_board: CardBoard
@export var enemy_board: CardBoard

var turn_sequense: Array[Enums.Turn] = [ 
	Enums.Turn.PLAYER,
	Enums.Turn.ENEMY
]
var current_turn: Enums.Turn = turn_sequense[0]

signal turn_changed(turn)

func end_turn():
	var index = turn_sequense.find(current_turn)
	current_turn = (index + 1) % turn_sequense.size() as Enums.Turn
	
	emit_signal("turn_changed", current_turn)

func _on_button_pressed() -> void:
	if current_turn == Enums.Turn.PLAYER:
		end_turn()
	else:
		print("хіхіххіхіхі")
		end_turn()
