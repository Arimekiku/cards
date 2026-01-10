class_name Enums

enum CharacterType { PLAYER, ENEMY }

enum CardType { MINION, SPELL, NONE }

enum CardSide { FRONT, BACK }

enum DeathCause {
	NORMAL,
	ERASE
}

enum TargetType {
	NO_TARGET,
	TARGET,
	SELF,
	MINIONS,
	FACE,
	RANDOM
}

enum TargetGroup {
	NO_GROUP,
	ALLY,
	ENEMY,
	FILTER,
}
