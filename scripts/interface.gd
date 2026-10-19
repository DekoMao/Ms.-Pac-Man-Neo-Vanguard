extends RefCounted
## The 3D viewport and live HUD occupy disjoint rectangles. Menus are bounded.
static func zones(size:Vector2, live:bool=true) -> Dictionary:
	var play:=Rect2(Vector2(16,92),Vector2(maxf(320,size.x-272),maxf(260,size.y-132)))
	if not live:play=Rect2(Vector2(16,16),size-Vector2(32,32))
	return {"play":play,"header":Rect2(16,12,size.x-32,68),
		"sidebar":Rect2(size.x-240,92,224,size.y-132),
		"footer":Rect2(16,size.y-30,size.x-32,20)}

static func bar(height:float=6) -> ProgressBar:
	var b:=ProgressBar.new();b.show_percentage=false;b.custom_minimum_size=Vector2(0,height)
	return b

static func compact_panel(g) -> PanelContainer:
	var p:PanelContainer=g.panel()
	var style:StyleBoxFlat=p.get_theme_stylebox("panel").duplicate()
	style.bg_color=Color("091321");style.border_color=Color("25465d")
	style.set_corner_radius_all(8)
	style.content_margin_left=14;style.content_margin_right=14
	style.content_margin_top=10;style.content_margin_bottom=10
	p.add_theme_stylebox_override("panel",style)
	return p

static func build(g) -> void:
	g.ui=CanvasLayer.new();g.add_child(g.ui)
	var root:=Control.new();root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);g.ui.add_child(root);g.screen_root=root
	var theme:=Theme.new();theme.default_font=load("res://assets/DejaVuSans.ttf");root.theme=theme
	var background:=ColorRect.new();background.color=Color("040a14");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);background.mouse_filter=Control.MOUSE_FILTER_IGNORE;root.add_child(background)
	g.game_frame=SubViewportContainer.new();g.game_frame.stretch=true;g.game_frame.mouse_filter=Control.MOUSE_FILTER_IGNORE;root.add_child(g.game_frame)
	g.game_view=SubViewport.new();g.game_view.world_3d=g.get_world_3d();g.game_view.gui_disable_input=true
	g.game_view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	g.game_view.msaa_3d=g.get_viewport().msaa_3d;g.game_frame.add_child(g.game_view)
	g.camera.reparent(g.game_view,false);g.camera.current=true
	g.hud=Control.new();g.hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);g.hud.mouse_filter=Control.MOUSE_FILTER_IGNORE;root.add_child(g.hud)
	g.header=compact_panel(g);g.hud.add_child(g.header)
	var row:=HBoxContainer.new();row.add_theme_constant_override("separation",24);g.header.add_child(row)
	var points:=VBoxContainer.new();row.add_child(points);points.add_child(g.label("PONTOS",10,Color("8baabe")))
	g.score_label=g.label("000000",23);points.add_child(g.score_label)
	var lives:=VBoxContainer.new();row.add_child(lives);lives.add_child(g.label("VIDAS",10,Color("8baabe")))
	g.life_label=g.label("● ● ●",18,Color("ffcf75"));lives.add_child(g.life_label)
	g.phase_label=g.label("",17,Color.WHITE);g.phase_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	g.phase_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;g.phase_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(g.phase_label)
	g.flow_label=g.label("FLOW ×1.0",17,Color("efb5d8"));g.flow_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(g.flow_label)
	g.sidebar=compact_panel(g);g.hud.add_child(g.sidebar)
	var side:=VBoxContainer.new();side.add_theme_constant_override("separation",5);g.sidebar.add_child(side)
	g.collection_label=g.label("",19,Color("ffe0a2"));side.add_child(g.collection_label)
	g.collection_caption=g.label("",11,Color("b9cddb"));side.add_child(g.collection_caption)
	g.collection_bar=bar();side.add_child(g.collection_bar)
	g.collection_detail=g.label("",10,Color("9fb8ca"));side.add_child(g.collection_detail)
	g.minimap=Control.new();g.minimap.set_script(load("res://scripts/minimap.gd"));g.minimap.sim=g.sim
	g.minimap.custom_minimum_size=Vector2(192,148);side.add_child(g.minimap)
	var map_button:Button=g.button("M · ampliar mapa",g.show_map)
	map_button.focus_mode=Control.FOCUS_NONE
	map_button.custom_minimum_size=Vector2(0,28);map_button.add_theme_font_size_override("font_size",12);side.add_child(map_button)
	side.add_child(HSeparator.new())
	g.mission_label=g.label("",12,Color("a9d7c4"));g.mission_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;side.add_child(g.mission_label)
	g.ability_label=g.label("",11,Color("aaceda"));side.add_child(g.ability_label)
	side.add_child(g.label("DASH · ESPAÇO",10,Color("92afc3")))
	g.energy_bar=bar();g.energy_bar.max_value=100;side.add_child(g.energy_bar)
	g.power_caption=g.label("POWER",11,Color("8ddbec"));side.add_child(g.power_caption)
	g.power_bar=bar();g.power_bar.max_value=6;side.add_child(g.power_bar)
	g.risk_label=g.label("",11,Color("b5c9d5"));g.risk_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;side.add_child(g.risk_label)
	g.toast=g.label("",11,Color("ffd18c"));g.toast.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;g.toast.max_lines_visible=3;side.add_child(g.toast)
	g.status_label=g.label("WASD / SETAS · MOVER    ESPAÇO · DASH    E / R · PODERES    M · MAPA    C · CÂMERA    P / ESC · PAUSA",11,Color("7e9bae"))
	g.status_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;g.hud.add_child(g.status_label)
	g.menu_scrim=ColorRect.new();g.menu_scrim.color=Color(0.01,0.02,0.05,0.68);g.menu_scrim.mouse_filter=Control.MOUSE_FILTER_IGNORE;root.add_child(g.menu_scrim)
	g.menu=g.panel();root.add_child(g.menu)
	g.menu_scroll=ScrollContainer.new();g.menu_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;g.menu.add_child(g.menu_scroll)
	g.menu_content=VBoxContainer.new();g.menu_content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;g.menu_content.add_theme_constant_override("separation",12);g.menu_scroll.add_child(g.menu_content)
	g.menu_content.child_entered_tree.connect(func(child):
		if child is Label:child.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;child.size_flags_horizontal=Control.SIZE_EXPAND_FILL)
	g.map_overlay=g.panel();g.map_overlay.visible=false;root.add_child(g.map_overlay)
	var overview:=VBoxContainer.new();overview.add_theme_constant_override("separation",8);g.map_overlay.add_child(overview)
	overview.add_child(g.label("MAPA DA ÁREA",22,Color("ffe19a")))
	g.overview_caption=g.label("",14);overview.add_child(g.overview_caption)
	g.overview_map=Control.new();g.overview_map.set_script(load("res://scripts/minimap.gd"));g.overview_map.sim=g.sim;overview.add_child(g.overview_map)
	overview.add_child(g.label("• Pontos  ◉ Power  ◆ Fruta  ▲ Você  ↔ Túneis",12,Color("b3d1df")))
	overview.add_child(g.label("Últimos 10 itens: círculo branco. Tempo pausado.",11,Color("91afbf")))
	overview.add_child(g.button("Retomar · M / Esc",g.resume_game))
	root.resized.connect(func():layout(g));layout(g)

static func place(control:Control,rect:Rect2) -> void:
	control.position=rect.position;control.size=rect.size

static func layout(g) -> void:
	if not is_instance_valid(g) or not is_instance_valid(g.screen_root):return
	var z:=zones(g.screen_root.size,g.hud.visible)
	g.play_rect=z.play
	place(g.game_frame,z.play);place(g.header,z.header);place(g.sidebar,z.sidebar);place(g.status_label,z.footer)
	place(g.menu_scrim,z.play)
	var menu_size:=Vector2(minf(600,z.play.size.x-32),clampf(g.menu_content.get_combined_minimum_size().y+28,180,minf(580,z.play.size.y-16)))
	place(g.menu,Rect2(z.play.get_center()-menu_size*0.5,menu_size))
	g.overview_map.custom_minimum_size=Vector2(0,minf(340,z.play.size.y-200))
	g.map_overlay.size=Vector2(minf(560,z.play.size.x-32),0)
	g.map_overlay.position=z.play.get_center()-Vector2(g.map_overlay.size.x,g.map_overlay.get_combined_minimum_size().y)*0.5
