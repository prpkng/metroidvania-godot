@tool
@warning_ignore_start('unused_variable')

var foliage_entities: Dictionary[String, PackedScene]

func initialize_foliage(entity_layer: LDTKEntityLayer) -> void:
	var definition: Dictionary = entity_layer.definition
	var entities: Array = entity_layer.entities
	
	var foliage_count := 0
	
	for entity: Dictionary in entities:
		# Perform operations here
		if "foliage" in entity.definition.tags:
			var scene := foliage_entities[entity.identifier]
			var node := scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			node.position = entity.position
			entity_layer.add_child(node)
			foliage_count += 1
			
	
	if foliage_count > 0: Log.info("Successfully initialized %s foliage entities!" % foliage_count)

func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	foliage_entities = {
		"Grass": load("uid://catgxueyt0c2s"),
		"Grass_2": load("uid://bl146s4pcdmhe"),
		"Tall_Grass": load("uid://b5bvv2et8ib51"),
		"Mushroom": load("uid://psq64oj8iiy2"),
		"Tall_Mushroom": load("uid://bwt0lx8xpp3fw"),
		"Poppy": load("uid://bk4lo4mp8hg7g"),
	}
	
	var info: LDtkLevelInfo
	if entity_layer.get_parent().has_node("LevelInfo"):
		info = entity_layer.get_parent().get_node("LevelInfo")
	else:
		info = load("res://Scenes/LDtk/scripts/level_info.gd").new()
		info.name = "LevelInfo"
		entity_layer.add_sibling(info)
	
	match entity_layer.name:
		"Entities":
			info.entities = entity_layer
			for entity: Dictionary in entity_layer.entities:
				if entity.identifier == "PlayerStart":
					var player_start := Marker2D.new()
					player_start.name = "Player Start"
					player_start.position = entity.position
					info.player_start = player_start
					entity_layer.add_child(player_start)
					break
			if info.player_start == null:
				Log.error("Level %s is missing a Player Start!!!" % entity_layer.get_parent().name)
			
		"Decorations":
			info.decorations = entity_layer
			initialize_foliage(entity_layer)
			

	return entity_layer
