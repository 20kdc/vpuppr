extends PanelContainer

const CONFIG_KEYS := {
	"OPEN_SEE_FACE_CAMERA_NAME": "open_see_face_camera_name",
	"OPEN_SEE_FACE_CAMERA_INDEX": "open_see_face_camera_index",
	"OPEN_SEE_FACE_TRACKER_FPS": "open_see_face_tracker_fps",
	"OPEN_SEE_FACE_SHOULD_LAUNCH_TRACKER": "open_see_face_should_launch_tracker",
	"OPEN_SEE_FACE_ADDRESS": "open_see_face_address",
	"OPEN_SEE_FACE_PORT": "open_see_face_port"
}

func _init() -> void:
	for val in CONFIG_KEYS.values():
		var res: Result = AM.cm.runtime_subscribe_to_signal(val)
		if Result.failed(res) and \
				(res == null or res.unwrap_err().error_code() != Error.Code.PUB_SUB_ALREADY_CONNECTED):
			AM.logger.error(Result.to_log_string(res))
			return

	_hv_fill_expand(self)
	
	var scroll_container := ScrollContainer.new()
	_hv_fill_expand(scroll_container)

	var vbox := VBoxContainer.new()
	_hv_fill_expand(vbox)

	#region Actual list of ui elements

	vbox.add_child(_camera_select())
	vbox.add_child(_tracker_fps())
	vbox.add_child(_should_launch_tracker())
	vbox.add_child(_tracker_address())
	vbox.add_child(_tracker_port())

	if OS.get_name().to_lower() in ["x11", "osx"]:
		vbox.add_child(_python_path())

	vbox.add_child(_toggle_tracking())

	#endregion

	scroll_container.add_child(vbox)
	add_child(scroll_container)

static func _hv_fill_expand(control: Control) -> void:
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND_FILL

static func _h_fill_expand(control: Control) -> void:
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _camera_select() -> OptionButton:
	var ob := OptionButton.new()
	_h_fill_expand(ob)
	ob.hint_tooltip = """
The camera to use for tracking.
	"""

	var popup: PopupMenu = ob.get_popup()
	popup.connect(
		"index_pressed",
		load(
			"%s/data/tracking_gui_descriptor.gd" % \
				AM.em.get_context("OpenSeeFace").expect("Unable to get context").context_path
		),
		"_on_camera_selected",
		[ob]
	)

	var os_name := OS.get_name().to_lower()

	var results := []

	var output := []
	match os_name:
		"windows":
			var exe_path: String = "%s/OpenSeeFaceFolder/OpenSeeFace/facetracker.exe" % \
					AM.em.get_context("OpenSeeFace").expect("Unable to get context").context_path
			OS.execute(exe_path, ["-l", "1"], true, output)
		"osx", "x11":
			var exe_path := "%s/%s" % [
				OS.get_executable_path().get_base_dir(),
				"/resources/scripts/get_video_devices.sh"
			]
			if OS.is_debug_build():
				exe_path = "%s/%s" % [
					ProjectSettings.globalize_path("res://export"),
					"/resources/scripts/get_video_devices.sh"
				]
			OS.execute(exe_path, [], true, output)

	if not output.empty():
		results.append_array((output[0] as String).split("\n"))
		match os_name:
			"windows":
				results.pop_back()
				results.pop_front()
			"osx", "x11":
				results.pop_back()
	else:
		results.append("Unable to list cameras")
		results.append("Please report this as a bug")

	if results.size() < 1:
		popup.add_check_item("No cameras found")
		popup.add_check_item("Please report this as a bug")
		popup.set_item_checked(0, true)
		ob.text = popup.get_item_text(0)
		return ob

	for option in results:
		popup.add_check_item(option)

	var camera_name = AM.cm.get_data("open_see_face_camera_name")
	if typeof(camera_name) == TYPE_NIL:
		camera_name = ""
		AM.ps.publish("open_see_face_camera_name", camera_name)

	var camera_index = AM.cm.get_data("open_see_face_camera_index")
	if typeof(camera_index) == TYPE_NIL:
		camera_index = 0
		AM.ps.publish("open_see_face_camera_index", camera_index)

	# TODO compare the camera index to the actual camera name

	var found := false
	if not camera_name.empty():
		for i in popup.get_item_count():
			var item_text: String = popup.get_item_text(i)
			
			if item_text == camera_name:
				camera_index = i
				popup.set_item_check(i, true)
				ob.text = item_text
				found = true
				break

	if not found:
		var item_text: String = popup.get_item_text(0)

		camera_index = 0
		popup.set_item_checked(0, true)
		ob.text = item_text
		AM.ps.publish("open_see_face_camera", item_text)
	
	# Update the camera index every time since camera order can change between computer reboots
	AM.ps.publish("open_see_face_camera_index", camera_index)

	return ob

func _on_camera_selected(idx: int, ob: OptionButton) -> void:
	var popup: PopupMenu = ob.get_popup()

	popup.set_item_checked(idx, not popup.is_item_checked(idx))

func _tracker_fps() -> HBoxContainer:
	var r := HBoxContainer.new()
	_h_fill_expand(r)
	r.hint_tooltip = """
The FPS to run OpenSeeFace at. A higher value results in more accurate tracking but also
more CPU usage.
	""".strip_edges()

	var label := Label.new()
	_h_fill_expand(label)
	label.text = "Tracker FPS"

	var line_edit := LineEdit.new()
	_h_fill_expand(line_edit)

	var initial_value = AM.cm.get_data("open_see_face_tracker_fps")
	if typeof(initial_value) == TYPE_NIL:
		initial_value = int(12)
		AM.ps.publish("open_see_face_tracker_fps", initial_value)

	line_edit.text = str(initial_value)

	r.add_child(label)
	r.add_child(line_edit)

	return r

func _should_launch_tracker() -> CheckButton:
	var r := CheckButton.new()
	_h_fill_expand(r)

	r.text = "Should launch tracker"
	r.hint_tooltip = """
Whether or not to launch OpenSeeFace or just listen for OpenSeeFace data.

This is generally only useful if Puppeteer is unable to automatically start OpenSeeFace. In that case,
you will need to start OpenSeeFace from a terminal.
	""".strip_edges()

	var initial_value = AM.cm.get_data("open_see_face_should_launch_tracker")
	if typeof(initial_value) == TYPE_NIL:
		initial_value = true
		AM.ps.publish("open_see_face_should_launch_tracker", initial_value)

	r.pressed = initial_value

	return r

func _tracker_address() -> HBoxContainer:
	var r := HBoxContainer.new()
	_h_fill_expand(r)
	r.hint_tooltip = """
The ip address to listen at. Do not change this unless you know what you are doing.
	""".strip_edges()

	var label := Label.new()
	_h_fill_expand(label)
	label.text = "Address"

	var line_edit := LineEdit.new()
	_h_fill_expand(line_edit)
	
	var initial_value = AM.cm.get_data("open_see_face_address")
	if typeof(initial_value) == TYPE_NIL:
		initial_value = "127.0.0.1"
		AM.ps.publish("open_see_face_address", initial_value)

	line_edit.text = str(initial_value)

	r.add_child(label)
	r.add_child(line_edit)

	return r

func _tracker_port() -> HBoxContainer:
	var r := HBoxContainer.new()
	_h_fill_expand(r)
	r.hint_tooltip = """
The port to listen on. Do not change this unless you know what you are doing.
	""".strip_edges()

	var label := Label.new()
	_h_fill_expand(label)
	label.text = "Port"

	var line_edit := LineEdit.new()
	_h_fill_expand(line_edit)
	
	var initial_value = AM.cm.get_data("open_see_face_port")
	if typeof(initial_value) == TYPE_NIL:
		initial_value = int(11573)
		AM.ps.publish("open_see_face_port", initial_value)

	line_edit.text = str(initial_value)

	r.add_child(label)
	r.add_child(line_edit)

	return r

func _toggle_tracking() -> Button:
	var r := Button.new()
	_h_fill_expand(r)
	r.text = "Start"

	r.connect("pressed", self, "_on_toggle_tracking", [r])

	return r

func _on_toggle_tracking(button: Button) -> void:
	var trackers = get_tree().current_scene.get("trackers")
	if typeof(trackers) != TYPE_ARRAY:
		AM.logger.error("OpenSeeFace: Incompatible runner, no trackers property found")
		return

	var tracker: TrackingBackendInterface
	var found := false
	for i in trackers:
		if i.get_name() == "OpenSeeFace" and i is TrackingBackendInterface:
			tracker = i
			found = true
			break

	# When this callback is triggered and tracking is already started, then the tracker
	# is being turned off. Thus if the button were to be pressed again, it would be for
	# starting the tracker
	if found:
		tracker.stop_receiver()
		trackers.erase(tracker)

		button.text = "Start"
	else:
		var osf_res: Result = AM.em.load_resource("OpenSeeFace", "open_see_face.gd")
		if not osf_res or osf_res.is_err():
			AM.logger.error("OpenSeeFace: Unable to load tracker")
			return

		var osf = osf_res.unwrap().new()

		trackers.append(osf)

		button.text = "Stop"

	AM.ps.publish(GlobalConstants.TRACKER_TOGGLED, not found, "OpenSeeFace")

func _python_path() -> HBoxContainer:
	var r := HBoxContainer.new()
	_h_fill_expand(r)

	var label := Label.new()
	_h_fill_expand(label)
	label.text = "Python path"
	label.hint_tooltip = """
The absolute path to the python version to use. This should be defined if your system's
python version is not within Python 3.6 - Python 3.9.
	""".strip_edges()

	var line_edit := LineEdit.new()
	_h_fill_expand(line_edit)
	line_edit.placeholder_text = "/path/to/python/binary"

	r.add_child(label)
	r.add_child(line_edit)

	return r
