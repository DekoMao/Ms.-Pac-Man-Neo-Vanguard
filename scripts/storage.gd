class_name NeoStorage
extends RefCounted
const PATH := "user://neo_grid_mv.json"
static func defaults() -> Dictionary:
	return {"schema":1,"record":0,"volume":0.55,"mute":false,"quality":2,"reduced":false,"camera_top":false}
static func read_settings(path:String=PATH) -> Dictionary:
	var result:=defaults()
	if not FileAccess.file_exists(path):return result
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null:return result
	var parser:=JSON.new()
	var parse_status=parser.parse(file.get_as_text())
	var parsed=parser.data if parse_status==OK else null
	file.close()
	if not parsed is Dictionary:
		DirAccess.copy_absolute(path,path+".corrompido-"+str(Time.get_unix_time_from_system()))
		return result
	for key in result:
		if parsed.has(key) and typeof(parsed[key])==typeof(result[key]):result[key]=parsed[key]
	# JSON decodes numbers as floats. Accept bounded record and quality explicitly.
	if parsed.get("record") is float or parsed.get("record") is int:result.record=maxi(0,int(parsed.record))
	if parsed.get("quality") is float or parsed.get("quality") is int:result.quality=clampi(int(parsed.quality),0,2)
	result.volume=clampf(float(parsed.get("volume",0.55)) if parsed.get("volume",0.55) is float or parsed.get("volume",0.55) is int else 0.55,0.0,1.0)
	return result
static func write_settings(data:Dictionary,path:String=PATH) -> Error:
	var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file==null:return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data,"\t"));file.flush();file.close()
	# Retain a previous good version before replacement (Windows rename cannot overwrite).
	if FileAccess.file_exists(path):
		var err=DirAccess.copy_absolute(path,path+".bak")
		if err!=OK:return err
		if DirAccess.remove_absolute(path)!=OK:return ERR_CANT_CREATE
	return DirAccess.rename_absolute(path+".tmp",path)
