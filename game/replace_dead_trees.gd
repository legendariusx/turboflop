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
	print("Replacement complete.")
				
func _replace_dead_tree_instances(root: Node, palm_variants: Array):
	for child in root.get_children():
		if "dead_tree" in child.name:
			var palm_scene = palm_variants[randi() % palm_variants.size()]
			var palm_instance = palm_scene.instantiate()
			palm_instance.transform = child.transform
			palm_instance.name = child.name
			var parent = child.get_parent()
			var index = parent.get_children().find(child)

			parent.remove_child(child)
			child.free()

			parent.add_child(palm_instance)
			parent.move_child(palm_instance, index)
			continue
		else:
			var nchild = child.get_children()
			if nchild.size() == 1:
				if "DeadTree" in nchild[0].name:
					var palm_scene = palm_variants[randi() % palm_variants.size()]
					var palm_instance = palm_scene.instantiate()
					palm_instance.transform = child.transform
					palm_instance.name = child.name
					var parent = child.get_parent()
					var index = parent.get_children().find(child)

					parent.remove_child(child)
					child.free()

					parent.add_child(palm_instance)
					parent.move_child(palm_instance, index)
					continue
			
		_replace_dead_tree_instances(child, palm_variants)
