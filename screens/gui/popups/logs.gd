extends VBoxContainer

const GODOT_LOG_PATH := "user://logs/godot.log"

onready var logs = $Logs as TextEdit

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	for i in AM.lm.logs:
		_on_log(i)
	
	AM.ps.connect("logger_rebroadcast", self, "_on_log")
	
	logs.add_keyword_color("INFO", Color.aquamarine)
	logs.add_keyword_color("DEBUG", Color.gold)
	logs.add_keyword_color("TRACE", Color.blue)
	logs.add_keyword_color("ERROR", Color.red)
	
	$HBoxContainer/Copy.connect("pressed", self, "_on_copy")
	$HBoxContainer/Open.connect("pressed", self, "_on_open")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_log(text: String) -> void:
	logs.text += "%s\n" % text

func _on_copy() -> void:
	OS.clipboard = logs.text

func _on_open() -> void:
	OS.shell_open(ProjectSettings.globalize_path(GODOT_LOG_PATH))

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
