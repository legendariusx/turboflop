@tool
@icon("res://addons/SpacetimeDB/Icons/node_icon.svg")
extends Node
class_name RowReceiver

@export var data_to_receive: Resource : set=on_set;

signal update(row)
signal delete(row)

func on_set(schema:Resource):
	if schema != null:
		name = "Receiver [%s]" % schema.resource_path.get_file()
		name = name.replace("_gd", "")
	else:
		name = "Receiver [EMPTY]"
	data_to_receive = schema;
	pass;

func _ready() -> void:
	if Engine.is_editor_hint():
		return;
	SpacetimeDB.row_inserted.connect(_on_insert)
	SpacetimeDB.row_updated.connect(_on_insert)
	SpacetimeDB.row_deleted.connect(_on_delete)

	if data_to_receive:
		data_to_receive = data_to_receive.new()
	else:
		push_error("No data schema. Node path: ", get_path())
		return;
	
	await get_parent().ready
	
	var data = SpacetimeDB.get_local_database().get_all_rows(data_to_receive.get_meta("table_name"))
	for i in data:
		_on_insert(data_to_receive.get_meta("table_name"), i)
	
func _on_insert(table_name: String, row: Resource):
	if row.get_meta("table_name") != data_to_receive.get_meta("table_name"):
		return
	update.emit(row)

func _on_delete(table_name: String, row: Resource):
	if row.get_meta("table_name") != data_to_receive.get_meta("table_name"):
		return
	delete.emit(row)
	pass;
	
