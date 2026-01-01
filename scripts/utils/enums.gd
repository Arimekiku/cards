class_name Enums

enum CharacterType { PLAYER, ENEMY }

enum CardType { MINION, SPELL, NONE }

enum CardSide { FRONT, BACK }

enum DeathCause {
	NORMAL,
	ERASE
}

enum SpellTargetType {
	TARGET,            # один довільний таргет (міньйон або герой)
	NON_HERO_TARGET,   # один таргет, але не герой
	ENEMY_TARGET,      # один ворожий таргет
	ALLY_TARGET,       # один союзний таргет
	HERO,              # герой (вибір або авто)
	ENEMY_MINIONS,
	ALLY_MINIONS,
	ALL_MINIONS,
	ALL,
	NO_TARGET
}
