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
			palm_instance.transform = child.transform
			palm_instance.name = child.name

			root.remove_child(child)
			child.free()

			root.add_child(palm_instance)
			continue
		else:
			var nchild = child.get_children()
			if nchild.size() == 1:
				if "DeadTree" in nchild[0].name:
					var palm_scene = palm_variants[randi() % palm_variants.size()]
					var palm_instance = palm_scene.instantiate()
					palm_instance.transform = child.transform
					palm_instance.name = child.name

					root.remove_child(child)
					child.free()

					root.add_child(palm_instance)
					continue
			
		_replace_dead_tree_instances(child, palm_variants)
