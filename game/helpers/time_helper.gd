class_name TimeHelper

extends Node

static func format_time_ms(ms: int) -> String:
	var time_dict = Time.get_datetime_dict_from_unix_time(float(ms / 1000))
	var out_str = ""
	if time_dict.hour > 0:
		out_str += "%02d:" % time_dict.hour
	if time_dict.minute > 0:
		out_str += "%02d:" % time_dict.minute
	return out_str + "%02d.%03d" % [time_dict.second, ms % 1000]
