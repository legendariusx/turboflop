@tool
extends EditorScript

func _run():
	randomize()
	var palm_variants = [
		load("res://assets/models/PalmTree1.tscn"),
		load("res://assets/models/PalmTree2.tscn"),
		load("res://assets/models/PalmTree3.tscn"),
	]
	var current_scene = get_editor_interface().get_edited_scene_root()
	_replace_dead_tree_instances(current_scene, palm_variants)
	get_editor_interface().mark_scene_as_unsaved()
	print("Replacement complete.")
				
func _replace_dead_tree_instances(root: Node, palm_variants: Array):
	for child in root.get_children():
		if "dead_tree" in child.name:
			var palm_scene = palm_variants[randi() % palm_variants.size()]
			var palm_instance = palm_scene.instantiate()
			get_editor_interface().get_edited_scene_root().get_node("LevelObjects").add_child(palm_instance)
			palm_instance.owner = get_editor_interface().get_edited_scene_root()
			palm_instance.transform = child.transform
			palm_instance.scale = Vector3.ONE
			palm_instance.name = "PalmTree_" + Time.get_date_string_from_system()

			root.remove_child(child)
			child.free()
			continue
		else:
			var nchild = child.get_children()
			if nchild.size() == 1:
				if "DeadTree" in nchild[0].name:
					var palm_scene = palm_variants[randi() % palm_variants.size()]
					var palm_instance = palm_scene.instantiate()
					get_editor_interface().get_edited_scene_root().get_node("LevelObjects").add_child(palm_instance)
					palm_instance.owner = get_editor_interface().get_edited_scene_root()
					palm_instance.transform = child.transform
					palm_instance.scale = Vector3.ONE
					palm_instance.name = "PalmTree_" + Time.get_date_string_from_system()

					root.remove_child(child)
					child.free()
					continue
			
		_replace_dead_tree_instances(child, palm_variants)
