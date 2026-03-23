extends Control

@onready var start_button: Button = $Panel/VBoxContainer/VBoxContainer/Button

func _ready() -> void:
	
	start_button.pressed.connect(load_game)
	

func load_game() -> void:
	
	# Show a loading screen?
	
	# Load the first scene (the beach)
	var level: Node3D = load("res://levels/beach/beach.tscn").instantiate()
	
	# Switch to the scene, deleting this one in the process
	get_tree().change_scene_to_node(level)
	
