class_name GameManager
extends Node2D

@onready var dialogue_box: DialogueBox = %DialogueBox
@onready var players := {
	"ship":
	{
		viewport = %LeftSplitscreenViewport,
		camera = %LeftSplitscreenCamera2D,
		player = %Piloting.spaceship,
		parallax_background = %Piloting.left_splitscreen_background
	},
	"zoomed_ship":
	{
		viewport = %RightSplitscreenViewport,
		camera = %RightSplitscreenCamera2D,
		player = %Piloting.spaceship,
		parallax_background = %Piloting.right_splitscreen_background
	},
	"engineer":
	{
		viewport = %RightSplitscreenOverlaySubViewport,
		camera = %RightSplitscreenOverlayCamera2D,
		player = %Repair.engineer
	}
}


func _ready():
	# assign the ship's level view to the split screen
	players["zoomed_ship"].viewport.world_2d = players["ship"].viewport.world_2d
	players["ship"].parallax_background.custom_viewport = (players["ship"].viewport)
	players["zoomed_ship"].parallax_background.custom_viewport = (players["zoomed_ship"].viewport)

	# assign splitscreen camera to follow the zoomed_ship and engineer
	for node in players.values():
		if node != players["zoomed_ship"]:
			var remote_transform := RemoteTransform2D.new()
			remote_transform.remote_path = node.camera.get_path()
			node.player.add_child(remote_transform)

	show_controls_tutorial()

func _process(delta: float) -> void:
	# pin camera to engineer as they walk around
	var engineer = players["engineer"].player
	var engineer_relative_position = engineer.position

	var relative_angle = Vector2(0, 0).angle_to_point(engineer_relative_position)
	var relative_distance = Vector2(0, 0).distance_to(engineer_relative_position) * 0.04

	var spaceship: Spaceship = players["zoomed_ship"].player
	var combined_angle = deg_to_rad(90) - relative_angle - deg_to_rad(spaceship.rotation_degrees)

	var new_point_location = rotated_point(
		spaceship.global_position, combined_angle, relative_distance
	)

	var zoomed_camera = players["zoomed_ship"].camera
	zoomed_camera.global_position = new_point_location
	zoomed_camera.rotation = spaceship.rotation


func rotated_point(_center, _angle, _distance):
	return _center + Vector2(sin(_angle), cos(_angle)) * _distance


func show_controls_tutorial():
	dialogue_box.set_text("Pilot: Find the busted computer and those shields up now! We've got incoming drones!

WASD: Move spaceship
ARROWS: Move engineer
SPACE or ENTER: Repair Computer
", 8)
