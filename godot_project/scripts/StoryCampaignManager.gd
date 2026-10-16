extends Node
class_name StoryCampaignManager

# ==============================================================================
# VALICO DEI MOTORI '93 - TRAMA UFFICIALE & CAMPAGNA NARRATIVA
# ==============================================================================
# Trama: "LA COPPA DEL MERIDIANO '93 - DALLA BOTTEGA AL VALICO DEL DUCA"
#
# Scopo Dichiarato del Gioco:
# Il giocatore arriva a San Cristoforo nell'autunno del 1993 con una Fiat 127 Special (1974),
# 3.500.000 Lire in tasca e il sogno di vincere la leggendaria "Coppa del Valico" (istituita nel 1968),
# una cronoscalata clandestina d'alta quota sul Valico del Duca (2650m s.l.m.) prima che il gelo
# e le bufere invernali chiudano definitivamente il passo alpino.
#
# Per qualificarsi alla Coppa e battere il leggendario "Duca", il giocatore deve:
# 1. Conquistare il rispetto del borgo (completando incarichi per i bottegai di San Cristoforo).
# 2. Elaborare la propria 127 nell'Officina di Paolo (Weber 40, scarico Abarth, gomme Pirelli P7).
# 3. Battere i 4 rivali storici lungo le tappe del Meridiano:
#    - Gino (Panda 4x4) nello sparo 400m al semaforo del borgo
#    - Kurt (BMW E30) al piazzale della Stazione Agip '93
#    - Marco (Golf GTI 16V) sui Tornanti dei Larici
#    - Il Duca (Lancia Delta Integrale 'Martini Racing') nella finale del Valico
# ==============================================================================

signal campaign_updated(info: Dictionary)
signal objective_completed(obj_id: String, reward_lire: int, reward_rep: int)
signal chapter_advanced(new_chapter_idx: int)
signal campaign_won

var current_chapter: int = 1
var active_objective_id: String = "c1_visit_town"

# Roster dei Capitoli della Trama
var chapters = [
	{
		"index": 1,
		"title": "CAPITOLO 1: LA FURIA DI SAN CRISTOFORO",
		"subtitle": "La Bottega, il Borgo e la Prima Sfida",
		"location": "Borgo Storico di San Cristoforo (km 0.0 - 0.9)",
		"lore": "Arrivi a San Cristoforo. L'aria profuma di pane fresco, porfido bagnato e gas di scarico delle 127 elaborate. Fatti conoscere dai bottegai in piazza e sconfiggi Gino al semaforo per dimostrare a Paolo che hai la stoffa del pilota.",
		"rival_name": "Gino 'Il Boscaiolo'",
		"rival_car": "Fiat Panda 4x4 Sisley (1983)",
		"reward_lire": 800000,
		"reward_rep": 50,
		"completed": false,
		"objectives": [
			{
				"id": "c1_visit_town",
				"text": "Esci dal Garage ed entra al Bar dello Sport o alla Panetteria in Piazza a San Cristoforo.",
				"target_poi": "bar_sport",
				"done": false
			},
			{
				"id": "c1_accept_delivery",
				"text": "Parla con Teresa alla Panetteria o con Tonino al Bar e prendi la prima consegna per la Cascina.",
				"target_poi": "panetteria",
				"done": false
			},
			{
				"id": "c1_beat_gino",
				"text": "Sfida e batti Gino (Panda 4x4) nello sparo 400m al semaforo di Corso Garibaldi.",
				"target_poi": "bar_sport",
				"done": false
			}
		]
	},
	{
		"index": 2,
		"title": "CAPITOLO 2: I PODERI PADANI & L'OASI AGIP '93",
		"subtitle": "La Campagna Dorata e il Duello Bavarese",
		"location": "Pianura dei Poderi & Stazione Agip '93 (km 0.9 - 2.0)",
		"lore": "Hai lasciato il borgo. La strada corre tra i campi di grano dorato, i fienili e i filari di cipressi. Consegna le provviste al Fattore Renzo alla Cascina San Rocco, raggiungi il valico intermedio dell'Agip '93 e affronta Kurt sulla BMW 320i E30.",
		"rival_name": "Kurt 'Il Bavarese'",
		"rival_car": "BMW 320i E30 (1990)",
		"reward_lire": 1500000,
		"reward_rep": 100,
		"completed": false,
		"objectives": [
			{
				"id": "c2_deliver_cascina",
				"text": "Raggiungi Cascina San Rocco (km 0.28) e consegna il cestino di provviste al Fattore Renzo.",
				"target_poi": "cascina_san_rocco",
				"done": false
			},
			{
				"id": "c2_reach_agip",
				"text": "Guida fino alla Stazione Agip '93 (km 1.48) e fai il pieno di Super Rossa 98 ottani.",
				"target_poi": "stazione_agip",
				"done": false
			},
			{
				"id": "c2_beat_kurt",
				"text": "Sfida Kurt sulla BMW 320i E30 al bivio dell'Agip e dimostra la superiorità del telaio leggero italiano.",
				"target_poi": "stazione_agip",
				"done": false
			}
		]
	},
	{
		"index": 3,
		"title": "CAPITOLO 3: L'ORRIDO DEI CICLOPI & IL TOUGE DEI LARICI",
		"subtitle": "La Forra Rocciosa e la Salita Tecnica",
		"location": "Viadotto dei Ciclopi & Tornanti dei Larici (km 2.0 - 4.6)",
		"lore": "La roccia si fa verticale. Il Viadotto dei Ciclopi scavalca una gola spaventosa a 1150m di quota, prima che la strada si arrampichi nei 14 tornanti a gomito dei Larici d'Oro. Qui Marco con la sua Golf GTI 16V detta legge da tre stagioni.",
		"rival_name": "Marco 'Il Regolarista'",
		"rival_car": "Volkswagen Golf GTI 16V (1989)",
		"reward_lire": 2500000,
		"reward_rep": 250,
		"completed": false,
		"objectives": [
			{
				"id": "c3_cross_viaduct",
				"text": "Attraversa il Ponte dei Ciclopi e scala i Tornanti dei Larici senza uscire di strada.",
				"target_poi": "tornanti_larici",
				"done": false
			},
			{
				"id": "c3_weber_tune",
				"text": "Monta i doppi carburatori Weber 40 DCOE o l'assetto Abarth da Paolo per affrontare la salita ripida.",
				"target_poi": "officina_paolo",
				"done": false
			},
			{
				"id": "c3_beat_marco",
				"text": "Sconfiggi Marco sulla Golf GTI sui tornanti d'alta quota e ottieni la Licenza Oro CSAI.",
				"target_poi": "tornanti_larici",
				"done": false
			}
		]
	},
	{
		"index": 4,
		"title": "CAPITOLO 4: LA GLORIA SUL VALICO DEL DUCA",
		"subtitle": "Neve, Ghiaccio e la Lancia Delta Integrale 'Martini'",
		"location": "Valico Glaciale del Duca (km 4.6 - 5.4, Quota 2650m)",
		"lore": "Sei giunto sul tetto del Meridiano. La barriera del valico è sferzata dal vento polare e dalla neve. Davanti al Rifugio Alpino ti attende Il Duca, l'imbattuto signore della montagna al volante della sua mostruosa Lancia Delta HF Integrale Martini Racing.",
		"rival_name": "Il Duca di San Rocco",
		"rival_car": "Lancia Delta HF Integrale 'Martini Racing' (1991)",
		"reward_lire": 5000000,
		"reward_rep": 500,
		"completed": false,
		"objectives": [
			{
				"id": "c4_reach_summit",
				"text": "Raggiungi la barriera innevata del Valico del Duca a quota 2650m.",
				"target_poi": "valico_duca",
				"done": false
			},
			{
				"id": "c4_final_duel",
				"text": "Affronta il Duca nel duello finale della Coppa del Valico 1993 sulla pista ghiacciata.",
				"target_poi": "valico_duca",
				"done": false
			},
			{
				"id": "c4_claim_trophy",
				"text": "Alza la Coppa del Valico '93 e sblocca la mitica Lancia Delta HF Integrale nel Garage di Paolo!",
				"target_poi": "valico_duca",
				"done": false
			}
		]
	}
]

func _init():
	print("[StoryCampaignManager] 📜 Inizializzazione Campagna Ufficiale: Coppa del Meridiano '93...")

func get_current_chapter_data() -> Dictionary:
	var idx = clamp(current_chapter - 1, 0, chapters.size() - 1)
	return chapters[idx]

func get_active_objective() -> Dictionary:
	var c_data = get_current_chapter_data()
	for obj in c_data.get("objectives", []):
		if not obj.get("done", false):
			return obj
	return {}

func get_active_objective_text() -> String:
	var obj = get_active_objective()
	if not obj.is_empty():
		return obj.get("text", "")
	if current_chapter >= 4 and chapters[3].get("completed", false):
		return "🏆 CAMPIONE DEL VALICO '93! Hai vinto la Coppa del Meridiano e dominato ogni vetta!"
	return "Raggiungi il prossimo punto d'interesse lungo il percorso."

func complete_objective(obj_id: String) -> bool:
	var c_data = get_current_chapter_data()
	var all_done = true
	var found = false
	
	for obj in c_data.get("objectives", []):
		if obj.get("id") == obj_id and not obj.get("done", false):
			obj["done"] = true
			found = true
			var r_lire = 250000
			var r_rep = 25
			objective_completed.emit(obj_id, r_lire, r_rep)
			print("[StoryCampaignManager] ✅ OBIETTIVO COMPLETATO: " + obj.get("text", ""))
		if not obj.get("done", false):
			all_done = false
			
	if found:
		if all_done:
			advance_to_next_chapter()
		else:
			campaign_updated.emit(get_campaign_status())
			
	return found

func advance_to_next_chapter():
	var c_data = get_current_chapter_data()
	c_data["completed"] = true
	print("[StoryCampaignManager] 🌟 CAPITOLO %d COMPLETATO CON SUCCESSO: %s!" % [current_chapter, c_data.get("title", "")])
	
	if current_chapter < 4:
		current_chapter += 1
		chapter_advanced.emit(current_chapter)
		campaign_updated.emit(get_campaign_status())
	else:
		print("[StoryCampaignManager] 🏆 VITTORIA TOTALE DELLA COPPA DEL MERIDIANO '93!")
		campaign_won.emit()
		campaign_updated.emit(get_campaign_status())

func get_campaign_status() -> Dictionary:
	return {
		"current_chapter": current_chapter,
		"active_objective_text": get_active_objective_text(),
		"active_objective": get_active_objective(),
		"chapter_data": get_current_chapter_data(),
		"all_chapters": chapters,
		"is_completed": (current_chapter >= 4 and chapters[3].get("completed", false))
	}
