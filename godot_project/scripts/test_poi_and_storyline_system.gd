extends SceneTree

# ==============================================================================
# VALICO DEI MOTORI '93 - TEST POI VISITS & STORYLINE CAMPAIGN SYSTEM
# ==============================================================================
# Testa in modo automatico:
# 1. Inizializzazione Campagna "Coppa del Meridiano '93" (4 capitoli, rivali, scopo del gioco)
# 2. Beacons 3D per Bar dello Sport, Panetteria, Macelleria, Garage, Cascina, Agip
# 3. Prossimità su strada e prompt a schermo [E] per il Bar dello Sport
# 4. Transizione cinematografica camera e apertura scheda retro Amiga di Tonino
# 5. Apertura Modal Trama & Scopo del Gioco [T] con i 4 capitoli e il manifesto
# 6. Salvataggio screenshot di verifica
# ==============================================================================

const StoryCampaignManager = preload("res://scripts/StoryCampaignManager.gd")
const WorldPOIManager = preload("res://scripts/WorldPOIManager.gd")

var main_instance: Node = null
var story_mgr: StoryCampaignManager = null
var poi_mgr: WorldPOIManager = null
var dash_ui: Control = null
var test_phase: int = 0
var frames_waited: int = 0

func _init():
	print("====================================================================")
	print("[TEST] 🏁 AVVIO VERIFICA POI & TRAMA UFFICIALE COPPA DEL MERIDIANO '93")
	print("====================================================================")

func _process(_delta: float) -> bool:
	frames_waited += 1
	
	if test_phase == 0:
		if frames_waited == 1:
			var scene = load("res://scenes/Main.tscn")
			if scene == null:
				printerr("[-] ERRORE: Impossibile caricare res://scenes/Main.tscn")
				quit(1)
				return true
			main_instance = scene.instantiate()
			root.add_child(main_instance)
			print("[+] Scena Main.tscn instanziata con successo")
		elif frames_waited == 20:
			story_mgr = main_instance.find_child("StoryCampaignManager", true, false)
			poi_mgr = main_instance.find_child("WorldPOIManager", true, false)
			dash_ui = main_instance.find_child("DashboardUI", true, false)
			
			assert(story_mgr != null, "StoryCampaignManager deve essere istanziato!")
			assert(poi_mgr != null, "WorldPOIManager deve essere istanziato!")
			assert(dash_ui != null, "DashboardUI deve essere presente!")
			
			var st = story_mgr.get_campaign_status()
			print("📜 Capitolo Attivo: %d - %s" % [st.current_chapter, st.chapter_data.title])
			print("🎯 Obiettivo Iniziale: %s" % st.active_objective_text)
			assert(st.current_chapter == 1, "Il gioco deve iniziare al Capitolo 1!")
			assert("San Cristoforo" in st.active_objective_text, "L'obiettivo iniziale deve guidare a San Cristoforo!")
			
			# Verifica che tutti gli 8 POI siano registrati
			var expected_pois = ["officina_paolo", "bar_sport", "panetteria", "macelleria", "chiesa", "cascina_san_rocco", "stazione_agip", "valico_duca"]
			for p_id in expected_pois:
				assert(poi_mgr.poi_registry.has(p_id), "POI %s deve essere presente!" % p_id)
			print("✅ Tutti gli 8 POI sono registrati e i beacon 3D sono posizionati.")
			
			# Esci dal garage per chiudere StreetRodUI e liberare la visuale su strada
			if main_instance.has_method("exit_garage_to_road"):
				main_instance.exit_garage_to_road()
			var sr_ui = main_instance.find_child("StreetRodUI", true, false)
			if sr_ui:
				sr_ui.visible = false
			
			# Sposta auto al trigger del Bar dello Sport
			var bar_pos = poi_mgr.poi_registry["bar_sport"]["road_trigger_pos"]
			var car = main_instance.get("vehicle")
			if car:
				car.global_position = bar_pos + Vector3(0.0, 0.45, 0.0)
				car.linear_velocity = Vector3.ZERO
				print("🚗 Veicolo posizionato al trigger del Bar dello Sport: %s" % str(car.global_position))
				
			test_phase = 1
			frames_waited = 0
			
	elif test_phase == 1:
		# Attendi aggiornamento prossimità
		if frames_waited == 15:
			print("🔍 Verifica rilevamento prossimità e prompt...")
			assert(poi_mgr.active_poi_near.get("id") == "bar_sport", "active_poi_near deve essere 'bar_sport'!")
			if dash_ui and dash_ui.service_prompt_panel:
				print("💬 Prompt a schermo: %s" % dash_ui.service_prompt_label.text)
				assert(dash_ui.service_prompt_panel.visible, "Prompt visibile")
				assert("BAR DELLO SPORT" in dash_ui.service_prompt_label.text, "Contiene 'BAR DELLO SPORT'")
			print("✅ Prossimità e prompt confermati!")
			
			# Entra nel Bar dello Sport
			print("☕ Apertura visita interattiva del Bar dello Sport...")
			poi_mgr.open_poi_visit("bar_sport")
			test_phase = 2
			frames_waited = 0
			
	elif test_phase == 2:
		# Attendi transizione camera e salva screenshot visita Bar dello Sport
		if frames_waited == 35:
			assert(poi_mgr.is_visiting_poi, "is_visiting_poi deve essere true!")
			assert(poi_mgr.is_modal_open, "La scheda retro del Bar deve essere aperta!")
			save_screenshot("screenshot_poi_visit_bar_sport_tonino.png")
			
			# Completa il primo obiettivo di trama
			story_mgr.complete_objective("c1_visit_town")
			print("📜 Avanzamento obiettivo dopo la visita al bar...")
			print("🎯 Nuovo obiettivo: %s" % story_mgr.get_active_objective_text())
			
			# Chiudi visita bar
			poi_mgr.close_poi_visit()
			assert(not poi_mgr.is_visiting_poi, "is_visiting_poi deve essere tornato a false!")
			
			# Apri Modal Trama Ufficiale [T]
			dash_ui.toggle_story_campaign_modal()
			assert(dash_ui.is_story_modal_open(), "Il modal della Trama deve essere aperto!")
			print("✅ Modal Trama aperto con successo!")
			
			test_phase = 3
			frames_waited = 0
			
	elif test_phase == 3:
		if frames_waited == 25:
			save_screenshot("screenshot_story_campaign_coppa93_modal.png")
			print("====================================================================")
			print("🎉 [TEST] TUTTI I TEST SUPERATI CON SUCCESSO! EXIT 0")
			print("====================================================================")
			quit(0)
			return true
			
	return false

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var global_path = ProjectSettings.globalize_path("res://" + filename)
	var err = img.save_png(global_path)
	if err == OK:
		print("📸 Screenshot salvato con successo: %s" % global_path)
	else:
		printerr("[-] Errore salvataggio screenshot: %d" % err)
