class_name State

extends Node

@export var query := ""
@export var table_name := ""

signal update(row: Resource)
signal delete(row: Resource)

var _query_id := -1

var data: Array[Resource] = []:
	get():
		return SpacetimeDB.get_local_database().get_all_rows(table_name)

func _init(parent: Node = null) -> void:
	assert(table_name != "", "table_name has to be set")
	assert(query != "", "query has to be set")
	
	if parent:
		if not parent.is_node_ready():
			await parent.ready
		parent.add_child(self)
	
	if not SpacetimeDB.is_connected_db():
		await SpacetimeDB.connected
		
	SpacetimeDB.row_updated.connect(_on_row_update)
	SpacetimeDB.row_inserted.connect(_on_row_update)
	SpacetimeDB.row_deleted.connect(_on_row_delete)
	_query_id = SpacetimeDB.subscribe([query])

func _exit_tree() -> void:
	if _query_id != -1:
		SpacetimeDB.unsubscribe(_query_id)

static func get_pk_val(row: Resource):
	return row.get(row.get_meta("primary_key"))

func find_index_by_pk(primary_key) -> int:
	return data.find_custom(func(row: Resource): return primary_key == get_pk_val(row))

func find_index(row: Resource) -> int:
	return find_index_by_pk(get_pk_val(row))

func find_by_pk(primary_key) -> Resource:
	var index = find_index_by_pk(primary_key)
	if index != -1: return data[index]
	else: return null

func _on_row_update(u_table_name: StringName, u_row: Resource):
	if u_table_name == table_name:
		update.emit(u_row)

func _on_row_delete(u_table_name: StringName, u_row: Resource):
	if u_table_name == table_name:
		delete.emit(u_row)

func reset():
	data = []
