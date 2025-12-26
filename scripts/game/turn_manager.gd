extends Node2D
class_name TurnManager

@export var player_board: CardBoard
@export var enemy_board: CardBoard

var turn_sequense: Array[Enums.CharacterType] = [ 
	Enums.CharacterType.PLAYER,
	Enums.CharacterType.ENEMY
]

var current_turn: Enums.CharacterType = turn_sequense[0]

signal turn_changed(turn)

func end_turn():
	var index = turn_sequense.find(current_turn)
	current_turn = (index + 1) % turn_sequense.size() as Enums.CharacterType
	print("---------",current_turn,"---------")
	turn_changed.emit(current_turn)

func _on_button_pressed() -> void:
	if current_turn == Enums.CharacterType.PLAYER:
		end_turn()
	else:
		return
