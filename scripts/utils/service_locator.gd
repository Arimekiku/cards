extends Node

var services: Dictionary[Variant, Service]

func _init() -> void:
	services = {
		CardDatabase : CardDatabase.new(),
		SceneManager: SceneManager.new(),
		EventBus: EventBus.new(),
		TooltipManager: TooltipManager.new(),
		EncounterContext: EncounterContext.new(),
		VFXService: VFXService.new()
	}

func _ready() -> void:
	for service in services.values():
		service.init()

func get_service(type: Variant) -> Service:
	return services.get(type, null)
