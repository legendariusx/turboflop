class_name AmbientAircrafts
extends Node3D

const ARROW_SCENE: PackedScene = preload("res://assets/models/Arrow.tscn")
@export_group("Spawn Settings")
@export var aircraft_scenes: Array[PackedScene]
@export var max_aircrafts: int = 5
@export var min_spawn_height: float = 75.0
@export var max_spawn_height: float = 125.0
@export_group("Flow Field Settings")
@export var show_flow_field: bool = true
@export var flow_field_size: float = 300.0
@export var flow_field_visual_resolution: int = 70
@export var frequency: float = 0.01

var _noise_generator: FastNoiseLite    = FastNoiseLite.new()
var _aircrafts: Array[AmbientAircraft] = []


func _ready() -> void:
	randomize()

	_noise_generator.seed = randi()
	_noise_generator.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise_generator.frequency = frequency

	for i in range(max_aircrafts):
		_spawn_new_aircraft()


	if not show_flow_field:
		return

	# init arrows for flow field visualization
	for x in range(flow_field_visual_resolution):
		for z in range(flow_field_visual_resolution):
			var arrow_node: Node3D = ARROW_SCENE.instantiate()
			add_child(arrow_node)

			arrow_node.global_position = Vector3(
				(x / (flow_field_visual_resolution - 1.0)) * flow_field_size - flow_field_size / 2.0,
				min_spawn_height,
				(z / (flow_field_visual_resolution - 1.0)) * flow_field_size - flow_field_size / 2.0
			)

			var direction: Vector3 = _get_flow_field_direction(arrow_node.global_position)
			var rotation_axis: Vector3 = direction.cross(-arrow_node.basis.z).normalized()
			var rotation_angle: float = direction.angle_to(-arrow_node.basis.z) + PI / 2.0
			arrow_node.basis = Basis().rotated(rotation_axis, rotation_angle)


func _process(_delta: float) -> void:
	for aircraft in _aircrafts:
		var direction: Vector3 = _get_flow_field_direction(aircraft.node.global_position)
		aircraft.node.global_position += direction * aircraft.speed * _delta

		var rotation_axis: Vector3 = direction.cross(-aircraft.node.basis.z).normalized()
		var rotation_angle: float = direction.angle_to(-aircraft.node.basis.z)
		aircraft.node.basis = Basis().rotated(rotation_axis, rotation_angle)


func _spawn_new_aircraft() -> void:
	var new_aircraft_node: Node3D = aircraft_scenes[randi() % aircraft_scenes.size()].instantiate()
	add_child(new_aircraft_node)

	var spawn_size: float       = 100.0
	var spawn_position: Vector3 = Vector3(randf_range(-spawn_size, spawn_size), min_spawn_height, randf_range(-spawn_size, spawn_size))
	new_aircraft_node.global_position = spawn_position

	var direction: Vector3 = _get_flow_field_direction(new_aircraft_node.global_position)
	look_at(direction)

	var new_aircraft = AmbientAircraft.new(direction, new_aircraft_node, randf_range(10.0, 15.0))
	_aircrafts.append(new_aircraft)


func _get_flow_field_direction(pos: Vector3) -> Vector3:
	var angle: float = _noise_generator.get_noise_3dv(pos) * PI

	return Vector3(0.0, 0.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), angle)


class AmbientAircraft:
	var orientation: Vector3
	var node: Node3D
	var speed: float


	func _init(u_orientation: Vector3, u_node: Node3D, u_speed: float) -> void:
		self.orientation = u_orientation
		self.node = u_node
		self.speed = u_speed
