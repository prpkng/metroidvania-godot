@tool
@warning_ignore_start('unused_variable')

const FOLIAGE_ENTITIES: Dictionary[String, PackedScene] = {
	"Grass": preload("uid://catgxueyt0c2s"),
	"Grass_2": preload("uid://bl146s4pcdmhe"),
	"Tall_Grass": preload("uid://b5bvv2et8ib51"),
	"Mushroom": preload("uid://psq64oj8iiy2"),
	"Tall_Mushroom": preload("uid://bwt0lx8xpp3fw"),
	"Poppy": preload("uid://bk4lo4mp8hg7g"),
}

func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	var definition: Dictionary = entity_layer.definition
	var entities: Array = entity_layer.entities
	
	var foliage_count := 0
	
	for entity: Dictionary in entities:
		# Perform operations here
		if "foliage" in entity.definition.tags:
			var scene := FOLIAGE_ENTITIES[entity.identifier]
			var node := scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			node.position = entity.position
			entity_layer.add_child(node)
			foliage_count += 1
			
	
	if foliage_count > 0: Log.info("Successfully initialized %s foliage entities!" % foliage_count)

	return entity_layer
