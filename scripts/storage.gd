class_name NeoStorage
extends RefCounted
const PATH := "user://neo_grid_mv.json"
static func defaults() -> Dictionary:
	return {"schema":4,"record":0,"circuit_record":0,"unlocked":0,"medals":[0,0,0,0,0,0],"experts":[0,0,0,0,0,0],"legacy_circuit_record":0,"overdrive_record":0,"train_record":0,"trail_style":0,"volume":0.55,"mute":false,"quality":2,"reduced":false,"camera_top":false,"camera_motion":0.65}
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
	for key in ["circuit_record","legacy_circuit_record","overdrive_record","train_record","unlocked","trail_style"]:
		var value=parsed.get(key,0)
		result[key]=maxi(0,int(value)) if value is float or value is int else 0
	result.unlocked=clampi(result.unlocked,0,5)
	result.trail_style=clampi(result.trail_style,0,1)
	for field in ["medals","experts"]:
		var saved=parsed.get(field,[]);result[field]=[0,0,0,0,0,0]
		if saved is Array:
			for i in mini(6,saved.size()):
				if saved[i] is float or saved[i] is int:result[field][i]=clampi(int(saved[i]),0,7)
	if int(parsed.get("schema",0))<4:
		result.legacy_circuit_record=result.circuit_record;result.circuit_record=0
	result.schema=4
	result.volume=clampf(float(parsed.get("volume",0.55)) if parsed.get("volume",0.55) is float or parsed.get("volume",0.55) is int else 0.55,0.0,1.0)
	result.camera_motion=clampf(float(parsed.get("camera_motion",0.65)) if parsed.get("camera_motion",0.65) is float or parsed.get("camera_motion",0.65) is int else 0.65,0.0,1.0)
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

