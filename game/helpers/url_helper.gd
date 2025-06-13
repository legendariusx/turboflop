class_name URLHelper

extends Resource

const JAVASCRIPT_HOST_CODE := &"`${window.location.protocol}//${window.location.host}`"
const DEFAULT_HOST := &"http://localhost:3000"

static func is_localhost() -> bool:
	var host = JavaScriptBridge.eval(JAVASCRIPT_HOST_CODE)
	return "localhost" in host

static func get_spacetimedb_url() -> String:
	if OS.get_name() != "Web" or is_localhost():
		return DEFAULT_HOST
	return JavaScriptBridge.eval(JAVASCRIPT_HOST_CODE)
