class_name Error
extends Reference

enum Code {
	NONE = 0,

	NULL_VALUE,
	SIGNAL_DOES_NOT_EXIST,
	CONNECT_FAILED,
	
	#region File

	FILE_NOT_FOUND,
	FILE_PARSE_FAILURE,
	FILE_WRITE_FAILURE,
	FILE_UNEXPECTED_DATA,
	FILE_DELETE_FAILED,
	
	#endregion

	#region PubSub

	PUB_SUB_INVALID_SIGNAL_NAME,
	PUB_SUB_USER_SIGNAL_ALREADY_EXISTS,
	PUB_SUB_SIGNAL_NOT_FOUND,
	PUB_SUB_ALREADY_CONNECTED,

	PUB_SUB_PLUGIN_ALREADY_EXISTS,
	PUB_SUB_PLUGIN_NOT_FOUND,

	#endregion

	#region ConfigManager

	CONFIG_MANAGER_DATA_NOT_FOUND,
	CONFIG_MANAGER_METADATA_LOAD_ERROR,
	CONFIG_MANAGER_MODEL_CONFIG_LOAD_ERROR,

	#endregion

	#region ExtensionManager

	EXTENSION_MANAGER_RESOURCE_PATH_DOES_NOT_EXIST,
	EXTENSION_MANAGER_CONFIG_DOES_NOT_EXIST,
	EXTENSION_MANAGER_RESOURCE_CONFIG_PARSE_FAILURE,
	EXTENSION_MANAGER_MISSING_GENERAL_SECTION,
	EXTENSION_MANAGER_MISSING_EXTENSION_NAME,
	EXTENSION_MANAGER_MISSING_EXTENSION_SECTION_KEY,
	EXTENSION_MANAGER_EMPTY_QUERY,
	EXTENSION_MANAGER_BAD_QUERY,
	EXTENSION_MANAGER_EXTENSION_DOES_NOT_EXIST,
	EXTENSION_MANAGER_EXTENSION_RESOURCE_DOES_NOT_EXIST,
	EXTENSION_MANAGER_BAD_GDNATIVE_ENTRYPOINT,
	EXTENSION_MANAGER_FAILED_PROCESSING_GDNATIVE,
	EXTENSION_MANAGER_BAD_GDNATIVE_CLASS,

	#endregion

	#region Extension

	EXTENSION_RESOURCE_ALREADY_EXISTS,
	EXTENSION_UNHANDLED_EXTENSION_TYPE,

	#endregion

	#region ExtensionContext

	EXTENSION_CONTEXT_RESOURCE_NOT_FOUND,

	#endregion

	#region TempCacheManager

	TEMP_CACHE_MANAGER_KEY_NOT_FOUND,

	#endregion

	#region BaseConfig

	BASE_CONFIG_PARSE_FAILURE,
	BASE_CONFIG_UNEXPECTED_DATA,
	BASE_CONFIG_DATA_NOT_FOUND,
	BASE_CONFIG_UNHANDLED_FIND_SET_DATA_TYPE,

	#endregion

	#region Metadata
	
	METADATA_NOT_FOUND,
	METADATA_PARSE_FAILURE,
	METADATA_UNEXPECTED_DATA,
	METADATA_CONFIG_ALREADY_EXISTS,

	#endregion

	#region ModelConfig

	MODEL_CONFIG_NOT_FOUND,
	MODEL_CONFIG_PARSE_FAILURE,
	MODEL_CONFIG_UNEXPECTED_DATA,

	#endregion

	#region Viewer

	VIEWER_FILE_NOT_FOUND,
	VIEWER_UNHANDLED_FILE_FORMAT,

	#endregion

	#region Runner

	RUNNER_NO_LOADERS_FOUND,
	RUNNER_FILE_NOT_FOUND,
	RUNNER_LOAD_FILE_FAILED,
	RUNNER_UNHANDLED_FILE_FORMAT
	RUNNER_NO_PREVIEW_IMAGE_FOUND,

	#endregion

	#region Gui

	GUI_SETUP_ERROR,

	GUI_TRACKER_LOAD_FILE_FAILED,
	GUI_TRACKER_FILE_EMPTY,
	GUI_TRACKER_INVALID_DESCRIPTOR,
	GUI_TRACKER_UNHANDLED_FILE_FORMAT,
	GUI_TRACKER_INVALID_GDSCRIPT,
	GUI_TRACKER_INVALID_JSON,

	GUI_TREE_ITEM_NOT_FOUND,

	#endregion
}

var _error: int
var _description: String

func _init(error: int, description: String = "") -> void:
	_error = error
	_description = description

func _to_string() -> String:
	return "Code: %d\nName: %s\nDescription: %s" % [_error, error_name(), _description]

## The error code contained by the Error
##
## @return: int - The error code
func error_code() -> int:
	return _error

## The name of the error code contained by the Error
##
## @return: String - The name of the error code currently contained by the Error
func error_name() -> String:
	return Code.keys()[_error]

## The description of the error
##
## @return: String - The description of the error
func error_description() -> String:
	return _description
