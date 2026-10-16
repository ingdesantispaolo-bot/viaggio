extends Node
class_name WorldPOIManager

# ==============================================================================
# VALICO DEI MOTORI '93 - WORLD POI INTERACTION & DIORAMA SYSTEM
# ==============================================================================
# Collega in modo organico e immersivo il mondo 3D con botteghe, bar, cascine e officine:
# 1. Beacons 3D su strada: stalli di sosta delimitati da strisce gialle, cartello storico
#    e medaglione rotante luminoso (☕, 🥖, 🔧, 🥩, ⛪, 🌾, ⛽, 🏆).
# 2. Rilevamento di prossimità in tempo reale con prompt a schermo [E] / [SPAZIO].
# 3. Transizione cinematografica: telecamera in inquadratura diorama d'ispezione sulla
#    facciata del negozio, con auto parcheggiata davanti alla vetrina.
# 4. Scheda interattiva Amiga 500 con oste locale, dialoghi, gossip, compravendita e missioni.
# 5. Raccordo con StoryCampaignManager per l'avanzamento della Trama e delle Consegne.
# ==============================================================================

signal poi_entered_zone(poi_info: Dictionary)
signal poi_exited_zone(poi_info: Dictionary)
signal poi_screen_opened(poi_info: Dictionary)
signal poi_screen_closed

@export var vehicle: Node3D = null
@export var camera_controller: Camera3D = null
@export var story_manager: Node = null
@export var street_rod_manager: Node = null

var poi_registry: Dictionary = {}
var active_poi_near: Dictionary = {}
var is_visiting_poi: bool = false
var current_visited_poi: Dictionary = {}
var beacon_nodes: Dictionary = {}

# Modal UI Container
var poi_ui_canvas: CanvasLayer = null
var poi_modal_control: Control = null
var is_modal_open: bool = false

func _ready():
	init_poi_registry()
	setup_poi_beacons_in_world()
	setup_poi_modal_ui()

func init_poi_registry():
	poi_registry = {
		# =====================================================================
		# 1. BORGO STORICO SAN CRISTOFORO (km 0.0 - 0.9)
		# =====================================================================
		"officina_paolo": {
			"id": "officina_paolo",
			"name": "OFFICINA MECCANICA PAOLO",
			"icon": "🔧",
			"badge": "GARAGE & TUNING D'EPOCA",
			"category": "Officina & Preparazione",
			"world_pos": Vector3(-16.0, 0.0, 8.0),
			"road_trigger_pos": Vector3(-4.6, 0.0, 8.0),
			"parking_pos": Vector3(-12.5, 0.45, 8.0),
			"parking_rot_y": deg_to_rad(-90.0),
			"cam_pos": Vector3(-9.5, 1.85, 3.2),
			"cam_look": Vector3(-16.0, 1.1, 8.0),
			"host_name": "Ing. Paolo | Maestro Collaudatore",
			"host_avatar": "👨‍🔧",
			"host_quote": "Ciao ragazzo! Benvenuto nella mia officina. Qui non ci sono centraline elettroniche: solo cacciaviti per i Weber, chiavi inglesi e tanta passione. Sulla 127 possiamo fare miracoli!",
			"actions": [
				{"id": "tune_weber", "label": "🔧 Apri Vano Motore & Carburatori Weber", "desc": "Elabora l'aspirazione e monta tromboncini cromati"},
				{"id": "service_oil", "label": "🛢️ Tagliando Olio Agip Sint 2000 (L. 250.000)", "desc": "Ripristina compressione motore al 100%"},
				{"id": "paint_shop", "label": "🎨 Verniciatura Storica & Assetto", "desc": "Rosso Corsa, Verde Muschio, Azzurro Iseo"},
				{"id": "car_switch", "label": "🚗 Parco Auto nel Garage", "desc": "Metti sui cavalletti o scambia la tua auto"}
			]
		},
		"bar_sport": {
			"id": "bar_sport",
			"name": "BAR DELLO SPORT 'DA TONINO'",
			"icon": "☕",
			"badge": "CAFFÈ, GOSSIP & SFIDE",
			"category": "Ritrovo Piloti & Diner",
			"world_pos": Vector3(20.0, 0.0, -23.0),
			"road_trigger_pos": Vector3(4.6, 0.0, -23.0),
			"parking_pos": Vector3(8.5, 0.45, -23.0),
			"parking_rot_y": deg_to_rad(90.0),
			"cam_pos": Vector3(12.0, 1.9, -17.5),
			"cam_look": Vector3(20.0, 1.3, -23.0),
			"host_name": "Tonino | Il Barista della Piazza",
			"host_avatar": "☕👨",
			"host_quote": "Ben arrivato a San Cristoforo! Un espresso corretto grappa per scaldare i riflessi? Qui al bar si ritrovano tutti i piloti prima di salire verso il passo.",
			"actions": [
				{"id": "drink_espresso", "label": "☕ Espresso della Casa (L. 1.500)", "desc": "Ripristina prontezza di riflessi e concentrazione"},
				{"id": "read_gazzetta", "label": "📰 Leggi La Gazzetta dello Sport '93", "desc": "Ultime cronache sul valico alpino e classifiche"},
				{"id": "challenge_gino", "label": "🏁 Sfida d'Accelerazione 400m contro Gino", "desc": "Sparo al semaforo contro la Panda 4x4 per la Trama!"},
				{"id": "gossip_rivals", "label": "💬 Gossip sui Piloti del Passo", "desc": "Scopri i segreti e i punti deboli di Kurt e del Duca"}
			]
		},
		"panetteria": {
			"id": "panetteria",
			"name": "PANETTERIA 'IL FORNO ANTICO'",
			"icon": "🥖",
			"badge": "PANE CASERECCIO & FOCACCIA",
			"category": "Bottega Storica",
			"world_pos": Vector3(14.0, 0.0, 23.0),
			"road_trigger_pos": Vector3(4.6, 0.0, 23.0),
			"parking_pos": Vector3(8.2, 0.45, 23.0),
			"parking_rot_y": deg_to_rad(90.0),
			"cam_pos": Vector3(8.0, 1.85, 28.5),
			"cam_look": Vector3(14.0, 1.25, 23.0),
			"host_name": "Teresa | La Fornaia di Piazza",
			"host_avatar": "👩‍🍳",
			"host_quote": "Che profumo di forno a legna! Ho appena sfornato la focaccia all'olio d'oliva e le pagnotte di segale. Mi serve un pilota svelto per una consegna alla cascina!",
			"actions": [
				{"id": "take_delivery_focaccia", "label": "🥖 Ritira Cestino Focaccia Calda (Missione Trama)", "desc": "Consegna espresso alla Cascina San Rocco (+L. 450.000)"},
				{"id": "buy_focaccia_snack", "label": "🥪 Trancio di Focaccia Genovese (L. 3.000)", "desc": "Snack saporito per il viaggio alpino"},
				{"id": "talk_teresa", "label": "💬 Chiacchiera con Teresa", "desc": "Consigli sui fienili e sulla gente della pianura"}
			]
		},
		"macelleria": {
			"id": "macelleria",
			"name": "MACELLERIA 'DA MARIO & FIGLI'",
			"icon": "🥩",
			"badge": "SALUMI TIPICI & FIORENTINE",
			"category": "Bottega Storica",
			"world_pos": Vector3(-18.0, 0.0, 32.0),
			"road_trigger_pos": Vector3(-4.6, 0.0, 32.0),
			"parking_pos": Vector3(-8.5, 0.45, 32.0),
			"parking_rot_y": deg_to_rad(-90.0),
			"cam_pos": Vector3(-11.0, 1.85, 26.5),
			"cam_look": Vector3(-18.0, 1.25, 32.0),
			"host_name": "Mario | Il Macellaio del Borgo",
			"host_avatar": "🥩👨‍🍳",
			"host_quote": "Benvenuto giovane! Guarda che bresaole di cervo e che salami nostrani. Il Duca lassù al valico ordina sempre la mia carne per le cene dopo-gara!",
			"actions": [
				{"id": "take_meat_delivery", "label": "🥩 Cassa Salumi per l'Autogrill Agip (Missione)", "desc": "Porta le provviste alla Stazione Agip '93 (+L. 800.000)"},
				{"id": "buy_bresaola", "label": "🥓 Panino con Bresaola e Parmigiano (L. 5.000)", "desc": "Sostentamento da vero pilota da salita"},
				{"id": "talk_mario", "label": "💬 Chiacchiera con Mario", "desc": "Aneddoti sui rally degli anni '70 e le Stratos"}
			]
		},
		"chiesa": {
			"id": "chiesa",
			"name": "CHIESA DI SAN CRISTOFORO",
			"icon": "⛪",
			"badge": "PATRONO DEGLI AUTOMOBILISTI",
			"category": "Monumento Storico",
			"world_pos": Vector3(38.0, 0.0, 14.0),
			"road_trigger_pos": Vector3(4.6, 0.0, 14.0),
			"parking_pos": Vector3(10.5, 0.45, 14.0),
			"parking_rot_y": deg_to_rad(90.0),
			"cam_pos": Vector3(18.0, 3.2, 8.0),
			"cam_look": Vector3(38.0, 6.0, 14.0),
			"host_name": "Don Attilio | Il Parroco dei Motori",
			"host_avatar": "⛪👴",
			"host_quote": "La pace sia con te, figliolo! San Cristoforo veglia su tutti i viaggiatori che affrontano la salita alpina. Prima di correre sui tornanti, una benedizione non guasta mai.",
			"actions": [
				{"id": "church_blessing", "label": "⛪ Benedizione di San Cristoforo (Offerta L. 10.000)", "desc": "+15% Aderenza e stabilità nei tratti viscidi"},
				{"id": "ring_bells", "label": "🔔 Ascolta il Rintocco delle Campane Storiche", "desc": "Armonia rilassante per stemperare la tensione pre-gara"},
				{"id": "talk_priest", "label": "💬 Consigli del Parroco", "desc": "La storia del vecchio valico e dei piloti del passato"}
			]
		},

		# =====================================================================
		# 2. PIANURA AGRICOLA DEI PODERI (km 0.1 - 1.4)
		# =====================================================================
		"cascina_san_rocco": {
			"id": "cascina_san_rocco",
			"name": "CASCINA PADANA 'SAN ROCCO'",
			"icon": "🌾",
			"badge": "FATTORIA, FIENILI & MUCCHE",
			"category": "Podere Rurale",
			"world_pos": Vector3(35.0, 0.0, 280.0),
			"road_trigger_pos": Vector3(5.0, 0.0, 280.0),
			"parking_pos": Vector3(14.0, 0.45, 280.0),
			"parking_rot_y": deg_to_rad(90.0),
			"cam_pos": Vector3(18.0, 2.5, 265.0),
			"cam_look": Vector3(35.0, 2.0, 280.0),
			"host_name": "Fattore Renzo | Custode dei Poderi",
			"host_avatar": "🧑‍🌾",
			"host_quote": "Maremma bucaiola che bella macchinetta! Sei arrivato giusto in tempo. Abbiamo i campi di grano da mietere e un fienile vecchio che nasconde vecchie glorie a motore!",
			"actions": [
				{"id": "deliver_bread_complete", "label": "🌾 Consegna la Focaccia di Teresa (Completa Obiettivo)", "desc": "Incassa la ricompensa e sblocca il Capitolo 2!"},
				{"id": "barn_find_clue", "label": "🏚️ Cerca nel Vecchio Fienile (Barn Find)", "desc": "Trova un albero a camme d'epoca o ricambi per la 127"},
				{"id": "fresh_milk", "label": "🥛 Tazza di Latte Fresco di Malga", "desc": "Ristoro rurale prima del rettifilo"}
			]
		},

		# =====================================================================
		# 3. VALICO INTERMEDIO & ALTA QUOTA (km 1.4 - 5.4)
		# =====================================================================
		"stazione_agip": {
			"id": "stazione_agip",
			"name": "STAZIONE DI SERVIZIO AGIP '93",
			"icon": "⛽",
			"badge": "SUPER ROSSA 98 OTTANI & OASI RALLY",
			"category": "Autogrill & Rifornimento",
			"world_pos": Vector3(14.0, 3.5, 1460.0),
			"road_trigger_pos": Vector3(5.0, 3.5, 1460.0),
			"parking_pos": Vector3(12.0, 3.75, 1460.0),
			"parking_rot_y": deg_to_rad(90.0),
			"cam_pos": Vector3(8.0, 5.0, 1445.0),
			"cam_look": Vector3(14.0, 4.2, 1460.0),
			"host_name": "Sandra | Rifornitrice dell'Agip '93",
			"host_avatar": "⛽👩",
			"host_quote": "Oasi del Valico! Qui riforniamo le leggende del rally. Abbiamo la vera benzina Super Rossa a 98 ottani. Occhio che lì al tavolo c'è Kurt con la BMW che aspetta uno sfidante!",
			"actions": [
				{"id": "fuel_up_super", "label": "⛽ Pieno di Benzina Super 98 Ottani (L. 60.000)", "desc": "Massima potenza e serbatoio pieno al 100%"},
				{"id": "challenge_kurt", "label": "🏎️ Sfida Kurt al Semaforo del Valico (Capitolo 2)", "desc": "Duello contro la BMW 320i E30!"},
				{"id": "deliver_meat_agip", "label": "📦 Consegna la Carne della Macelleria Mario", "desc": "Incassa L. 800.000 dal ristorante dell'Agip"}
			]
		},
		"valico_duca": {
			"id": "valico_duca",
			"name": "VALICO DEL DUCA (2650m s.l.m.)",
			"icon": "🏆",
			"badge": "TRAGUARDO FINALE & COPPA DEL VALICO",
			"category": "Traguardo Epico",
			"world_pos": Vector3(0.0, 180.0, 5380.0),
			"road_trigger_pos": Vector3(0.0, 180.0, 5370.0),
			"parking_pos": Vector3(0.0, 180.5, 5375.0),
			"parking_rot_y": 0.0,
			"cam_pos": Vector3(0.0, 184.0, 5355.0),
			"cam_look": Vector3(0.0, 181.5, 5390.0),
			"host_name": "Il Duca | Signore del Valico",
			"host_avatar": "👑🏎️",
			"host_quote": "Sei arrivato fin quassù con quella piccola 127... ammiro il tuo coraggio. Ma per vincere la Coppa del Valico 1993 dovrai battere la mia Lancia Delta Integrale!",
			"actions": [
				{"id": "final_race_duca", "label": "🏆 SFIDA FINALE: LA COPPA DEL VALICO '93", "desc": "Gara decisiva sul ghiaccio contro la Lancia Delta Integrale!"},
				{"id": "admire_summit", "label": "❄️ Ammira il Panorama delle Alpi Innevate", "desc": "Quota 2650 metri, il tetto del Meridiano"}
			]
		}
	}

# ==============================================================================
# CREAZIONE BEACON VISIVI 3D SUL TRACCIATO
# ==============================================================================
func setup_poi_beacons_in_world():
	for poi_id in poi_registry.keys():
		var p = poi_registry[poi_id]
		var beacon = Node3D.new()
		beacon.name = "POIBeacon_" + poi_id
		var trig_pos: Vector3 = p.get("road_trigger_pos", Vector3.ZERO)
		beacon.position = trig_pos
		add_child(beacon)
		beacon_nodes[poi_id] = beacon
		
		# Determine which side of the roadway this POI lies on
		var w_pos: Vector3 = p.get("world_pos", Vector3.ZERO)
		var poi_side = 1.0 if w_pos.x >= trig_pos.x else -1.0
		
		# 1. Stallo di Sosta Delimitato a Terra (Piazzola dipinta sulla banchina/bordo stradale)
		var decal = MeshInstance3D.new()
		var p_mesh = PlaneMesh.new()
		p_mesh.size = Vector2(3.2, 6.8)
		var d_mat = StandardMaterial3D.new()
		d_mat.albedo_color = Color(0.96, 0.78, 0.18, 0.75) # Giallo sosta ANAS
		d_mat.roughness = 0.88
		decal.mesh = p_mesh
		decal.position = Vector3(0.0, 0.005, 0.0)
		beacon.add_child(decal)
		
		# 2. Cartello Turistico Stradale d'Epoca (Marrone con scritta in lettere bianche, fuori dalla carreggiata)
		var pole_offset_x = poi_side * 2.8
		var pole = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.05
		cyl.bottom_radius = 0.05
		cyl.height = 2.8
		var p_mat = StandardMaterial3D.new()
		p_mat.albedo_color = Color(0.25, 0.25, 0.28)
		pole.mesh = cyl
		pole.position = Vector3(pole_offset_x, 1.4, 0.0)
		beacon.add_child(pole)
		
		var sign_board = MeshInstance3D.new()
		var s_box = BoxMesh.new()
		s_box.size = Vector3(0.12, 0.75, 2.2)
		var s_mat = StandardMaterial3D.new()
		s_mat.albedo_color = Color(0.35, 0.22, 0.15) # Marrone cartelli d'interesse storico/turistico
		sign_board.mesh = s_box
		sign_board.position = Vector3(pole_offset_x, 2.5, 0.0)
		beacon.add_child(sign_board)
		
		# 3. Medaglione Luminoso Fluttuante con Icona 3D (posizionato in banchina sopra il cartello)
		var badge = MeshInstance3D.new()
		var b_cyl = CylinderMesh.new()
		b_cyl.top_radius = 0.45
		b_cyl.bottom_radius = 0.45
		b_cyl.height = 0.12
		var b_mat = StandardMaterial3D.new()
		b_mat.albedo_color = Color(1.0, 0.85, 0.25)
		b_mat.emission_enabled = true
		b_mat.emission = Color(1.0, 0.85, 0.25)
		b_mat.emission_energy_multiplier = 1.2
		badge.mesh = b_cyl
		badge.rotation.x = deg_to_rad(90.0)
		badge.position = Vector3(pole_offset_x, 3.3, 0.0)
		badge.name = "FloatingEmblem"
		beacon.add_child(badge)
		
		# Luce calda d'atmosfera
		var omni = OmniLight3D.new()
		omni.light_color = Color(1.0, 0.88, 0.60)
		omni.light_energy = 1.5
		omni.omni_range = 8.0
		omni.position = Vector3(pole_offset_x, 3.2, 0.0)
		beacon.add_child(omni)

# ==============================================================================
# MONITORAGGIO PROSSIMITÀ IN TEMPO REALE
# ==============================================================================
func _process(delta: float):
	# Animazione rotazione medaglioni
	for b_id in beacon_nodes.keys():
		var b_node = beacon_nodes[b_id]
		if b_node:
			var fl = b_node.get_node_or_null("FloatingEmblem")
			if fl:
				fl.rotation.y += delta * 1.8
				
	if not vehicle or is_visiting_poi:
		return
		
	var v_pos = vehicle.global_position
	var found_near: Dictionary = {}
	var min_dist = 99999.0
	
	for poi_id in poi_registry.keys():
		var p = poi_registry[poi_id]
		var trig_pos: Vector3 = p.get("road_trigger_pos", Vector3.ZERO)
		var d = v_pos.distance_to(trig_pos)
		if d < 14.0 and d < min_dist:
			min_dist = d
			found_near = p
			
	if not found_near.is_empty():
		if active_poi_near.get("id") != found_near.get("id"):
			active_poi_near = found_near
			poi_entered_zone.emit(active_poi_near)
	else:
		if not active_poi_near.is_empty():
			poi_exited_zone.emit(active_poi_near)
			active_poi_near = {}
			
	# Gestione tasto [E] o [INVIO] per entrare nel POI
	if not active_poi_near.is_empty():
		if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_E):
			open_poi_visit(active_poi_near.get("id"))

# ==============================================================================
# VISITA CINEMATOGRAFICA DEL PUNTO D'INTERESSE
# ==============================================================================
func open_poi_visit(poi_id: String):
	if is_visiting_poi or not poi_registry.has(poi_id):
		return
		
	is_visiting_poi = true
	current_visited_poi = poi_registry[poi_id]
	
	# 1. Parcheggia dolcemente il veicolo
	if vehicle:
		vehicle.linear_velocity = Vector3.ZERO
		vehicle.angular_velocity = Vector3.ZERO
		var p_pos: Vector3 = current_visited_poi.get("parking_pos", vehicle.global_position)
		vehicle.global_position = p_pos
		vehicle.rotation.y = current_visited_poi.get("parking_rot_y", vehicle.rotation.y)
		vehicle.freeze = true
		
	# 2. Transizione Camera Diorama d'Ispezione
	if camera_controller:
		camera_controller.set_process(false)
		camera_controller.set_physics_process(false)
		var c_pos: Vector3 = current_visited_poi.get("cam_pos", Vector3.ZERO)
		var c_look: Vector3 = current_visited_poi.get("cam_look", Vector3.ZERO)
		
		var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(camera_controller, "global_position", c_pos, 0.9)
		tw.tween_property(camera_controller, "fov", 42.0, 0.9)
		tw.chain().tween_callback(func():
			camera_controller.look_at(c_look, Vector3.UP)
		)
		
	# 3. Notifica StoryCampaignManager
	if story_manager:
		if poi_id == "bar_sport" or poi_id == "panetteria":
			story_manager.complete_objective("c1_visit_town")
		elif poi_id == "cascina_san_rocco":
			story_manager.complete_objective("c2_deliver_cascina")
		elif poi_id == "stazione_agip":
			story_manager.complete_objective("c2_reach_agip")
		elif poi_id == "valico_duca":
			story_manager.complete_objective("c4_reach_summit")
			
	# 4. Apri la Scheda Interattiva Amiga 500
	populate_and_show_modal(current_visited_poi)
	poi_screen_opened.emit(current_visited_poi)

func close_poi_visit():
	if not is_visiting_poi:
		return
		
	is_visiting_poi = false
	if poi_ui_canvas:
		poi_ui_canvas.visible = false
	is_modal_open = false
	
	# Sblocca veicolo e riattiva telecamera
	if vehicle:
		vehicle.freeze = false
		vehicle.linear_velocity = Vector3.ZERO
		
	if camera_controller:
		camera_controller.set_process(true)
		camera_controller.set_physics_process(true)
		camera_controller.setup_initial_position()
		
	poi_screen_closed.emit()

# ==============================================================================
# INTERFACCIA RETRO AMIGA 500: SCHEDA BOTTEGA & PERSONAGGIO
# ==============================================================================
func setup_poi_modal_ui():
	poi_ui_canvas = CanvasLayer.new()
	poi_ui_canvas.name = "POICanvasLayer"
	poi_ui_canvas.layer = 15
	poi_ui_canvas.visible = false
	add_child(poi_ui_canvas)
	
	poi_modal_control = Control.new()
	poi_modal_control.name = "POIModalRoot"
	poi_modal_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	poi_ui_canvas.add_child(poi_modal_control)

var modal_content_box: PanelContainer = null
var lbl_poi_title: Label = null
var lbl_poi_badge: Label = null
var lbl_host_avatar: Label = null
var lbl_host_name: Label = null
var lbl_host_quote: Label = null
var actions_vbox: VBoxContainer = null

func populate_and_show_modal(p: Dictionary):
	if poi_modal_control == null: return
	
	for child in poi_modal_control.get_children():
		child.queue_free()
		
	# Sfondo semitrasparente scuro
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.03, 0.05, 0.75)
	poi_modal_control.add_child(bg)
	
	# Finestra Principale Amiga 500 Stile Deluxe
	modal_content_box = PanelContainer.new()
	modal_content_box.custom_minimum_size = Vector2(880, 520)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.12, 0.96)
	sb.border_color = Color(0.96, 0.74, 0.16) # Giallo Oro
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.shadow_size = 24
	sb.shadow_color = Color(0, 0, 0, 0.8)
	modal_content_box.add_theme_stylebox_override("panel", sb)
	
	# Posizionamento centrale
	modal_content_box.set_anchors_preset(Control.PRESET_CENTER)
	modal_content_box.position = Vector2(160, 60)
	poi_modal_control.add_child(modal_content_box)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	modal_content_box.add_child(margin)
	
	var root_vb = VBoxContainer.new()
	root_vb.add_theme_constant_override("separation", 14)
	margin.add_child(root_vb)
	
	# 1. Header con Nome POI, Badge e pulsante Chiudi
	var h_hb = HBoxContainer.new()
	h_hb.add_theme_constant_override("separation", 12)
	root_vb.add_child(h_hb)
	
	var icon_lbl = Label.new()
	icon_lbl.text = p.get("icon", "🏛️")
	icon_lbl.add_theme_font_size_override("font_size", 28)
	h_hb.add_child(icon_lbl)
	
	var title_vb = VBoxContainer.new()
	title_vb.add_theme_constant_override("separation", 2)
	h_hb.add_child(title_vb)
	
	lbl_poi_title = Label.new()
	lbl_poi_title.text = p.get("name", "PUNTO D'INTERESSE")
	lbl_poi_title.add_theme_font_size_override("font_size", 16)
	lbl_poi_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
	title_vb.add_child(lbl_poi_title)
	
	lbl_poi_badge = Label.new()
	lbl_poi_badge.text = "%s • %s" % [p.get("badge", ""), p.get("category", "")]
	lbl_poi_badge.add_theme_font_size_override("font_size", 10)
	lbl_poi_badge.add_theme_color_override("font_color", Color(0.45, 0.85, 1.0))
	title_vb.add_child(lbl_poi_badge)
	
	var sp_head = Control.new()
	sp_head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h_hb.add_child(sp_head)
	
	var btn_exit = Button.new()
	btn_exit.text = " ✕ TORNA ALLA GUIDA [ESC / SPAZIO] "
	btn_exit.add_theme_font_size_override("font_size", 11)
	btn_exit.pressed.connect(close_poi_visit)
	h_hb.add_child(btn_exit)
	
	root_vb.add_child(HSeparator.new())
	
	# 2. Corpo Centrale: Profilo Oste & Dialogo a Sinistra, Azioni e Servizi a Destra
	var body_hb = HBoxContainer.new()
	body_hb.add_theme_constant_override("separation", 20)
	body_hb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vb.add_child(body_hb)
	
	# Sinistra: Oste e Dialogo Narrativo
	var left_vb = VBoxContainer.new()
	left_vb.custom_minimum_size = Vector2(360, 0)
	left_vb.add_theme_constant_override("separation", 10)
	body_hb.add_child(left_vb)
	
	var host_box = PanelContainer.new()
	var sb_host = StyleBoxFlat.new()
	sb_host.bg_color = Color(0.10, 0.13, 0.18)
	sb_host.border_color = Color(0.25, 0.35, 0.50)
	sb_host.set_border_width_all(1)
	sb_host.set_corner_radius_all(6)
	host_box.add_theme_stylebox_override("panel", sb_host)
	left_vb.add_child(host_box)
	
	var host_m = MarginContainer.new()
	host_m.add_theme_constant_override("margin_left", 12)
	host_m.add_theme_constant_override("margin_right", 12)
	host_m.add_theme_constant_override("margin_top", 10)
	host_m.add_theme_constant_override("margin_bottom", 10)
	host_box.add_child(host_m)
	
	var host_vb = VBoxContainer.new()
	host_vb.add_theme_constant_override("separation", 6)
	host_m.add_child(host_vb)
	
	var h_info_hb = HBoxContainer.new()
	h_info_hb.add_theme_constant_override("separation", 8)
	host_vb.add_child(h_info_hb)
	
	lbl_host_avatar = Label.new()
	lbl_host_avatar.text = p.get("host_avatar", "👨")
	lbl_host_avatar.add_theme_font_size_override("font_size", 24)
	h_info_hb.add_child(lbl_host_avatar)
	
	lbl_host_name = Label.new()
	lbl_host_name.text = p.get("host_name", "Gestore")
	lbl_host_name.add_theme_font_size_override("font_size", 11)
	lbl_host_name.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	h_info_hb.add_child(lbl_host_name)
	
	lbl_host_quote = Label.new()
	lbl_host_quote.text = "\"%s\"" % p.get("host_quote", "")
	lbl_host_quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_host_quote.add_theme_font_size_override("font_size", 10)
	lbl_host_quote.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96))
	host_vb.add_child(lbl_host_quote)
	
	# Scheda Obiettivo Trama Corrente
	if story_manager:
		var quest_box = PanelContainer.new()
		var sb_q = StyleBoxFlat.new()
		sb_q.bg_color = Color(0.14, 0.11, 0.06)
		sb_q.border_color = Color(0.85, 0.65, 0.15)
		sb_q.set_border_width_all(1)
		sb_q.set_corner_radius_all(6)
		quest_box.add_theme_stylebox_override("panel", sb_q)
		left_vb.add_child(quest_box)
		
		var q_vb = VBoxContainer.new()
		q_vb.add_theme_constant_override("separation", 4)
		var q_m = MarginContainer.new()
		q_m.add_theme_constant_override("margin_left", 10)
		q_m.add_theme_constant_override("margin_right", 10)
		q_m.add_theme_constant_override("margin_top", 8)
		q_m.add_theme_constant_override("margin_bottom", 8)
		q_m.add_child(q_vb)
		quest_box.add_child(q_m)
		
		var q_t = Label.new()
		q_t.text = "🎯 OBIETTIVO ATTUALE DELLA TRAMA:"
		q_t.add_theme_font_size_override("font_size", 9)
		q_t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
		q_vb.add_child(q_t)
		
		var q_desc = Label.new()
		q_desc.text = story_manager.get_active_objective_text()
		q_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		q_desc.add_theme_font_size_override("font_size", 9)
		q_desc.add_theme_color_override("font_color", Color(0.92, 0.95, 0.98))
		q_vb.add_child(q_desc)
		
	# Destra: Azioni e Servizi Interattivi
	var right_vb = VBoxContainer.new()
	right_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vb.add_theme_constant_override("separation", 8)
	body_hb.add_child(right_vb)
	
	var act_header = Label.new()
	act_header.text = "⚡ SERVIZI, INTERAZIONI & MISSIONI DISPONIBILI:"
	act_header.add_theme_font_size_override("font_size", 11)
	act_header.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45))
	right_vb.add_child(act_header)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vb.add_child(scroll)
	
	actions_vbox = VBoxContainer.new()
	actions_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(actions_vbox)
	
	for act in p.get("actions", []):
		var btn = Button.new()
		btn.text = "%s\n  %s" % [act.get("label", ""), act.get("desc", "")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 10)
		btn.custom_minimum_size = Vector2(0, 44)
		var a_id = act.get("id", "")
		btn.pressed.connect(func(): on_action_triggered(a_id, p))
		actions_vbox.add_child(btn)
		
	poi_ui_canvas.visible = true
	is_modal_open = true

func on_action_triggered(act_id: String, p: Dictionary):
	print("[WorldPOIManager] ⚡ Azione attivata: %s presso %s" % [act_id, p.get("name", "")])
	
	if act_id == "drink_espresso":
		lbl_host_quote.text = "\"Ecco a te il tuo espresso, pilota! Tazzina bollente e miscela arabica. I tuoi riflessi ora sono al massimo per la salita!\""
	elif act_id == "read_gazzetta":
		lbl_host_quote.text = "\"📰 Gazzetta dello Sport: 'Grande attesa per la Coppa del Valico 1993. Il Duca domina le prove con la Delta Integrale, ma a San Cristoforo si parla di una Fiat 127 Special molto agguerrita...'\""
	elif act_id == "take_delivery_focaccia":
		if story_manager:
			story_manager.complete_objective("c1_accept_delivery")
		lbl_host_quote.text = "\"Grazie mille ragazzo! Porta questo cestino ancora caldo al Fattore Renzo alla Cascina San Rocco lungo la pianura. Ti ricompenserà con pezzi d'epoca!\""
	elif act_id == "deliver_bread_complete":
		if story_manager:
			story_manager.complete_objective("c2_deliver_cascina")
		lbl_host_quote.text = "\"Mamma mia che bontà! La focaccia di Teresa è insuperabile! Tieni queste Lire e questo vecchio getto del carburatore per la tua 127. Ora corri all'Agip!\""
	elif act_id == "fuel_up_super":
		if vehicle and vehicle.has_method("refuel_tank"):
			vehicle.refuel_tank(50.0)
		if story_manager:
			story_manager.complete_objective("c2_reach_agip")
		lbl_host_quote.text = "\"Pieno fatto! 45 litri di Super Rossa 98 ottani nel serbatoio. Il tuo motore canterà che è una meraviglia!\""
	elif act_id == "challenge_gino":
		close_poi_visit()
		var main_node = get_tree().root.get_node_or_null("Main")
		if main_node and main_node.has_node("RaceDirector"):
			main_node.get_node("RaceDirector").start_drag_race("gino", false, 3)
	elif act_id == "challenge_kurt":
		close_poi_visit()
		var main_node = get_tree().root.get_node_or_null("Main")
		if main_node and main_node.has_node("RaceDirector"):
			main_node.get_node("RaceDirector").start_drag_race("kurt", false, 3)
	elif act_id == "final_race_duca":
		close_poi_visit()
		var main_node = get_tree().root.get_node_or_null("Main")
		if main_node and main_node.has_node("RaceDirector"):
			main_node.get_node("RaceDirector").start_drag_race("duca", true, 3)
	elif act_id == "tune_weber" or act_id == "service_oil" or act_id == "paint_shop" or act_id == "car_switch":
		close_poi_visit()
		var main_node = get_tree().root.get_node_or_null("Main")
		if main_node and main_node.has_method("enter_garage"):
			main_node.enter_garage()
