@tool
extends Node3D

@export_tool_button("Generate layers") var action: Variant = generate_layers

@export_range(1, 1024) var layer_amount: int
@export var base_meshes: Array[MeshInstance3D] = []
@export var mesh_container: PhysicsBody3D

var layers: Array[MeshInstance3D] = []

func _ready() -> void:
	generate_layers()

func generate_layers() -> void:
	for layer: MeshInstance3D in layers:
		if layer != null:
			layer.queue_free()
	
	layers.clear()
	
	layers.resize(base_meshes.size() * layer_amount)
	
	for base_mesh: MeshInstance3D in base_meshes:
		base_mesh.set_instance_shader_parameter("layer_count", layer_amount)
		base_mesh.set_instance_shader_parameter("is_ground", false)
		
		for i: int in layer_amount:
			var new_layer: MeshInstance3D = base_mesh.duplicate()
			new_layer.set_instance_shader_parameter("layer_index", i + 1)
			
			layers.append(new_layer)
			mesh_container.add_child(new_layer)
		
		base_mesh.set_instance_shader_parameter("is_ground", true)
