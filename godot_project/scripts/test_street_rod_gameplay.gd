extends SceneTree

const StreetRodManager = preload("res://scripts/StreetRodManager.gd")

# ==============================================================================
# TEST & BENCHMARK: STREET ROD AMIGA 500 CAREER, ECONOMY & RACING SYSTEM
# ==============================================================================

func _init():
	print("\n====================================================================")
	print(">>> AVVIO TEST: STREET ROD AMIGA 500 - VALICO DEI MOTORI '93")
	print("====================================================================")
	
	if FileAccess.file_exists("user://street_rod_save_1993.json"):
		DirAccess.remove_absolute("user://street_rod_save_1993.json")
		
	var mgr = StreetRodManager.new()
	root.add_child(mgr)
	mgr._ready()
	
	# 1. Test Iniziale
	print("\n[TEST 1] Verifica Stato Carriera Iniziale:")
	print("  Soldi Iniziali: L. %s" % mgr.format_lire(mgr.cash_lire))
	print("  Reputazione: %d [%s]" % [mgr.reputation, mgr.get_reputation_title()])
	print("  Auto nel Garage: %d (%s)" % [mgr.garage.size(), mgr.garage[0].name])
	assert(mgr.cash_lire == 3500000, "Cash iniziale errato")
	assert(mgr.garage.size() == 1, "Garage iniziale deve avere 1 auto")
	print("  -> TEST 1 SUPERATO ✓")
	
	# 2. Test Annunci Giornale
	print("\n[TEST 2] Generazione Annunci 'Il Mercatino delle Ruote':")
	print("  Annunci disponibili: %d" % mgr.classified_ads.size())
	for i in range(mgr.classified_ads.size()):
		var ad = mgr.classified_ads[i]
		print("  #%d: %s | Anno %d | Km %d | L. %s" % [
			i + 1, ad.title, ad.year, ad.mileage_km, mgr.format_lire(ad.price_lire)
		])
	assert(mgr.classified_ads.size() > 0, "Nessun annuncio generato")
	print("  -> TEST 2 SUPERATO ✓")
	
	# 3. Test Acquisto Auto Usata
	print("\n[TEST 3] Acquisto Auto Usata dal Giornale:")
	var initial_cash = mgr.cash_lire
	var target_ad_idx = 0
	for i in range(mgr.classified_ads.size()):
		if mgr.classified_ads[i].price_lire <= mgr.cash_lire:
			target_ad_idx = i
			break
	var ad_to_buy = mgr.classified_ads[target_ad_idx]
	var buy_price = ad_to_buy.price_lire
	print("  Tentativo acquisto: %s (L. %s)" % [ad_to_buy.title, mgr.format_lire(buy_price)])
	var buy_ok = mgr.buy_car(target_ad_idx)
	assert(buy_ok, "Acquisto auto fallito")
	print("  Nuovo Saldo: L. %s (Detratti L. %s)" % [mgr.format_lire(mgr.cash_lire), mgr.format_lire(buy_price)])
	print("  Auto in Garage: %d" % mgr.garage.size())
	assert(mgr.garage.size() == 2, "L'auto non è stata aggiunta al garage")
	assert(mgr.cash_lire == initial_cash - buy_price, "Conteggio Lire errato")
	print("  -> TEST 3 SUPERATO ✓")
	
	# 4. Test Selezione Auto Attiva
	print("\n[TEST 4] Selezione Auto nel Box:")
	mgr.select_active_car(1)
	var active = mgr.get_active_car()
	print("  Auto Attiva: %s [%s]" % [active.name, active.body_color])
	assert(mgr.current_car_idx == 1, "Indice auto attiva errato")
	print("  -> TEST 4 SUPERATO ✓")
	
	# 5. Test Officina & Manutenzione
	print("\n[TEST 5] Officina Meccanica - Tagliando e Riparazioni:")
	active.engine_health = 0.72
	active.body_health = 0.65
	var pre_serv_cash = mgr.cash_lire
	print("  Stato Motore pre-tagliando: %d%%" % int(active.engine_health * 100))
	mgr.service_engine()
	assert(active.engine_health >= 0.99, "Tagliando motore non ha ripristinato salute")
	print("  Stato Motore post-tagliando: %d%% (Costo L. 250.000)" % int(active.engine_health * 100))
	mgr.repair_body()
	assert(active.body_health >= 0.99, "Riparazione carrozzeria non ha ripristinato salute")
	print("  Stato Carrozzeria post-riparazione: %d%% (Costo L. 350.000)" % int(active.body_health * 100))
	assert(mgr.cash_lire == pre_serv_cash - 600000, "Costo manutenzione errato")
	print("  -> TEST 5 SUPERATO ✓")
	
	# 6. Test Gomme Speciali
	print("\n[TEST 6] Montaggio Gomme da Gara Semi-Slick:")
	mgr.buy_tires("semislick")
	assert(active.tire_type == "semislick", "Tipo gomma non aggiornato")
	print("  Gomme montate: %s (Battistrada 100%%)" % active.tire_type.to_upper())
	print("  -> TEST 6 SUPERATO ✓")
	
	# 7. Test Elaborazioni / Tuning Street Rod
	print("\n[TEST 7] Elaborazione Meccanica (Tuning Street Rod):")
	mgr.cash_lire += 3000000 # Budget premio officina per elaborazioni complete
	mgr.install_tuning_part("scarico_sport")
	mgr.install_tuning_part("carburatori_doppi")
	assert(active.tuning_parts.has("scarico_sport"), "Scarico sportivo mancante")
	assert(active.tuning_parts.has("carburatori_doppi"), "Doppi carburatori mancanti")
	print("  Modifiche installate: %s" % str(active.tuning_parts))
	print("  Reputazione attuale: %d" % mgr.reputation)
	print("  -> TEST 7 SUPERATO ✓")
	
	# 8. Test Verniciatura Forno
	print("\n[TEST 8] Verniciatura in Cabina:")
	mgr.paint_car("Rosso Corsa")
	assert(active.body_color == "Rosso Corsa", "Colore non aggiornato")
	print("  Nuova Livrea: %s" % active.body_color)
	print("  -> TEST 8 SUPERATO ✓")
	
	# 9. Test Vendita Auto Restaurata per Profitto
	print("\n[TEST 9] Vendita Auto Restaurata (Calcolo Plusvalore):")
	var val_vendita = mgr.calculate_car_sale_value(active)
	var pre_sale_cash = mgr.cash_lire
	print("  Valore di Mercato Riconosciuto: L. %s" % mgr.format_lire(val_vendita))
	mgr.sell_car(1)
	assert(mgr.garage.size() == 1, "Auto venduta non rimossa dal garage")
	assert(mgr.cash_lire == pre_sale_cash + val_vendita, "Incasso vendita errato")
	print("  Auto rimaste nel garage: %d | Nuovo Saldo: L. %s" % [mgr.garage.size(), mgr.format_lire(mgr.cash_lire)])
	print("  -> TEST 9 SUPERATO ✓")
	
	# 10. Test Sfida Drag Race contro Gino
	print("\n[TEST 10] Sfida 1/4 di Miglio contro Gino 'Il Corsaiolo':")
	var drag_chal = mgr.challenge_rival("gino", false)
	assert(drag_chal.success, "Sfida a Gino fallita")
	print("  Scommessa in Palio: L. %s" % mgr.format_lire(drag_chal.bet_lire))
	# Simuliamo vittoria con tempo 14.8s vs target di Gino 15.6s
	var res = mgr.resolve_drag_race("gino", 14.8, false)
	print("  Tempo Giocatore: %.2fs vs Gino: %.2fs" % [res.player_time, res.rival_time])
	assert(res.won, "Dovrebbe risultare vittoria")
	print("  Esito: VITTORIA! Reputazione salita a %d [%s]" % [mgr.reputation, mgr.get_reputation_title()])
	print("  -> TEST 10 SUPERATO ✓")
	
	# 11. Test Missioni di Viaggio e Barn Find
	print("\n[TEST 11] Missioni di Viaggio & Barn Find:")
	var c1 = mgr.contracts[0]
	print("  Verifica Contratto: %s (Destinazione: %s)" % [c1.title, c1.destination])
	mgr.check_journey_progress(800.0)
	assert(c1.completed, "Contratto 1 dovrebbe essere completato a 800m")
	print("  Contratto 1 Completato! Ricompensa accreditata.")
	
	# Contratto 2 (Barn find a 960m)
	assert(mgr.contracts[1].active, "Contratto 2 barn find dovrebbe essere sbloccato e attivo")
	mgr.check_journey_progress(1000.0)
	assert(mgr.contracts[1].completed, "Barn find dovrebbe essere completato a 1000m")
	print("  Barn Find Completato! Auto storica recuperata dal fienile.")
	print("  Auto nel garage ora: %d" % mgr.garage.size())
	for g_c in mgr.garage:
		print("    - %s (%s, %s)" % [g_c.name, g_c.nickname, g_c.body_color])
	print("  -> TEST 11 SUPERATO ✓")
	
	# 12. Test Sintesi Sonora Amiga
	print("\n[TEST 12] Sintesi Sonora Amiga 500 (AudioStreamWAV):")
	var s_cash = mgr.synth_cash_counter()
	var s_wrench = mgr.synth_wrench_click()
	var s_fanfare = mgr.synth_amiga_fanfare()
	assert(s_cash.data.size() > 0, "Audio monete vuoto")
	assert(s_wrench.data.size() > 0, "Audio chiave inglese vuoto")
	assert(s_fanfare.data.size() > 0, "Audio fanfara vuoto")
	print("  Tutti i campioni sonori sintetizzati con successo (format 16-bit 22kHz)!")
	print("  -> TEST 12 SUPERATO ✓")
	
	print("\n====================================================================")
	print(">>> TUTTI I 12 TEST DEL SISTEMA STREET ROD COMPLETATI CON SUCCESSO! ✓")
	print("====================================================================\n")
	
	mgr.queue_free()
	quit()
