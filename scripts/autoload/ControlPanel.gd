extends Panel

@export var switch : bool = false
@export var logs : Array = []
@export var MAXLOG : int = 500

func _ready() -> void:
	switch = false
	self.position.y = 0 - self.size.y

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dev"):
		if switch:
			self.position.y = 0 - self.size.y
			self.visible = !switch
			
			switch = false
		else:
			self.position.y = 0
			self.visible = !switch
			switch = true

##Logger
func add_log(log:Dictionary) -> void:
	var _lock = Mutex.new()
	logs.append(log)
	if logs.size() >= MAXLOG:
		logs.pop_front()
	#add to logout
	# msg
	var endl = ""
	if %LogOut.text.ends_with("\n"):
		endl = ""
	else:
		endl = "\n"
	if log.type == "message":
		%LogOut.text = %LogOut.text + endl + get_prefix("Msg ") + log.message
	elif log.type == "error": #百年内无人看懂
		match log.error_type:
			Logger.ERROR_TYPE_WARNING:
				var texts = %LogOut.text + endl + "[color=yellow]" + get_prefix("Warn") + "form %s :: %s : %s @ %s" + "[/color]"
				texts = texts % [log.file,log.line,log.code,log.rationale]
				%LogOut.text = texts
			Logger.ERROR_TYPE_ERROR:
				var texts = %LogOut.text + endl + "[color=red]" + get_prefix("Erro") + "form %s :: %s : %s @ %s" + "[/color]"
				texts = texts % [log.file,log.line,log.code,log.rationale]
				%LogOut.text = texts
			Logger.ERROR_TYPE_SCRIPT:
				var texts = %LogOut.text + endl + "[color=white]" + get_prefix("Src ") + "form %s :: %s : %s @ %s" + "[/color]"
				texts = texts % [log.file,log.line,log.code,log.rationale]
				%LogOut.text = texts
			Logger.ERROR_TYPE_SHADER:
				var texts = %LogOut.text + endl + "[color=grey]" + get_prefix("Shader") + "form %s :: %s : %s @ %s" + "[/color]"
				texts = texts % [log.file,log.line,log.code,log.rationale]
				%LogOut.text = texts

func get_prefix(type:String = "Null") -> String:
	var t = Time.get_datetime_dict_from_system()
	var result = "[%s/%s]:" % [(str(t.hour)+":"+str(t.minute)+":"+str(t.second)),type]
	return result 

func _log_message(message: String, error: bool) -> void:
	add_log({type="message",message=message,error=error})

func _log_error(
		function: String, 
		file: String, 
		line: int, 
		code: String, 
		rationale: String, 
		editor_notify: bool, 
		error_type: int, 
		script_backtraces: Array[ScriptBacktrace]
	) -> void:
	add_log({type="error",
		function=function,
		file=file,
		line=line,
		code=code,
		rationale=rationale,
		editor_notify=editor_notify,
		error_type=error_type,
		script_backtraces=script_backtraces
		})

class CustomLogger extends Logger:
	func _log_message(message: String, error: bool) -> void:
		ControlPanel.call_deferred("_log_message",message,error)
	func _log_error( #looooooooooooooog (why not pack to dict? good Q)
		function: String, 
		file: String, 
		line: int, 
		code: String, 
		rationale: String, 
		editor_notify: bool, 
		error_type: int, 
		script_backtraces: Array[ScriptBacktrace]
		) -> void:
			ControlPanel.call_deferred("_log_error",
				function,
				file,
				line,
				code,
				rationale,
				editor_notify,
				error_type,
				script_backtraces
				)

var logger : CustomLogger

func _init() -> void:
	logger = CustomLogger.new()
	OS.add_logger(logger)
