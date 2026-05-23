extends Node

# Current active story node ID
var current_id: String = "start"


# Story graph (data-driven branching system)
var nodes := {

	"start": {
		"text": "Where do you escape?",
		"choices": [
			{"text": "Main Entrance", "next": "fail_entrance"},
			{"text": "Vent", "next": "vent_path"},
			{"text": "Back Exit", "next": "back_exit"}
		]
	},

	"fail_entrance": {
		"text": "You ran straight into guards. You got caught.",
		"choices": [
			{"text": "try again", "next": "start"}
			]
	},

	"vent_path": {
		"text": "You crawl into the ventilation system.",
		"choices": [
			{"text": "Go left", "next": "trap_room"},
			{"text": "Go right", "next": "control_room"}
		]
	},

	"back_exit": {
		"text": "You slip out through the back exit. Clean escape.",
		"choices": []
	},

	"trap_room": {
		"text": "It was a trap. You fall into a locked chamber.",
		"choices": [
			{"text": "Try again", "next": "vent_path"}
		]
	},

	"control_room": {
		"text": "You reach the control room and disable security.",
		"choices": [
			{"text": "Escape now", "next": "success"}
		]
	},

	"success": {
		"text": "You successfully escaped.",
		"choices": []
	}
}


# Get current node data
func get_current() -> Dictionary:
	return nodes.get(current_id, {})


# Change story state
func go_to(node_id: String) -> void:
	if nodes.has(node_id):
		current_id = node_id


# Optional helper: reset story
func reset() -> void:
	current_id = "start"
