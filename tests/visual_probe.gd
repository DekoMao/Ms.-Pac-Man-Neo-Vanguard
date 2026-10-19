extends Node
const Scene=preload("res://scenes/main.tscn")
const Store=preload("res://scripts/storage.gd")
var game:Node3D
var frame:=0
var original:Dictionary
func _ready():
	original=Store.read_settings()
	game=Scene.instantiate();add_child(game)
	game.start_game();game.sim.paused=true
	game.music.stop();game.sound.stop()
	game.settings.quality=2;game.settings.camera_top=false;game.apply_settings()
	print("VISUAL_PROBE frame0=High-oblique frame2=Low-oblique frame4=High-top; frozen scene fixture, not gameplay")
func _process(_dt):
	frame+=1
	if frame==3:
		game.settings.quality=0;game.apply_settings()
	if frame==5:
		game.settings.quality=2;game.settings.camera_top=true;game.first_frame=true;game.apply_settings()
func _exit_tree():
	Store.write_settings(original)
