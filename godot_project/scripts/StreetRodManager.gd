extends Node
class_name StreetRodManager

# ==============================================================================
# VALICO DEI MOTORI '93 - STREET ROD AMIGA 500 NARRATIVE & CAREER SYSTEM
# ==============================================================================
# Inspired by California Dreams' legendary Street Rod (Amiga 500, 1989/1991):
# 1. Classified Newspaper ("Il Mercatino delle Ruote '93"): Buy & sell used cars
# 2. Workshop / Garage: Mechanical overhaul, tuning parts, racing tires, paint shop
# 3. Diner "Da Bepi": Meet rivals (Gino, Kurt, Hans, Il Duca) with dialogue trees
# 4. Drag Racing & Mountain Touge: Cash bets and Pink Slips (libretto di circolazione)
# 5. Narrative Travel Contracts: Barn finds, express part deliveries, storm rescue
# 6. Authentic Amiga 500 Audio: Procedural chiptunes, cash counter, wrench clicks
# ==============================================================================

signal career_updated(info: Dictionary)
signal notification_posted(title: String, message: String, icon: String, sound_type: String)
signal car_switched(car_data: Dictionary)
signal race_started(race_info: Dictionary)
signal race_finished(race_result: Dictionary)
signal contract_selected(contract_info: Dictionary)
signal contract_completed(contract_info: Dictionary)
signal profile_updated(profile_info: Dictionary)

const SAVE_PATH = "user://street_rod_save_1993.json"

# Audio SFX Player
var sfx_player: AudioStreamPlayer = null

# Career State
var cash_lire: int = 3500000 # 3.500.000 Lire initial pocket money
var reputation: int = 40 # 0 - 1000 ("Novellino" to "Re del Passo")
var current_car_idx: int = 0
var max_garage_slots: int = 14
var last_tracked_z: float = 0.0

# Player Character Profile & CSAI Racing License (Giving Life to Paolo)
var player_profile: Dictionary = {
	"name": "Paolo",
	"title": "Ingegnere Meccanico & Collaudatore",
	"avatar": "🏎️👨‍🔧",
	"license_code": "CSAI-1993-VR40",
	"license_tier": "Licenza CSAI Gran Turismo - Cat. B",
	"license_expiry": "Stagione Corse 1993/1994",
	"rank_title": "Collaudatore delle Alpi",
	"skills": {
		"meccanica": 78,
		"assetto_curve": 82,
		"respiro_quota": 74
	},
	"stats": {
		"km_driven": 24.5,
		"missions_completed": 1,
		"races_won": 3,
		"cars_collected": 2,
		"top_speed_kmh": 168.0,
		"favorite_car": "Fiat 127 Special"
	}
}

var active_contract_id: String = "delivery_agip"

# The Player's Garage (starts with two authentic Italian classics ready to drive and tune)
var garage: Array = [
	{
		"car_id": "fiat_127",
		"name": "Fiat 127 Special (1974)",
		"nickname": "La Furia di Bepi",
		"body_color": "Verde Muschio",
		"color_rgb": Color(0.18, 0.35, 0.20),
		"engine_health": 0.88,
		"body_health": 0.75,
		"tire_health": 0.82,
		"tire_type": "touring",
		"tuning_parts": ["scarico_sport"],
		"mileage_km": 142380,
		"bought_price_lire": 1400000,
		"estimated_value": 1650000
	},
	{
		"car_id": "panda_4x4",
		"name": "Fiat Panda 4x4 Sisley (1983)",
		"nickname": "L'Arrampicatrice del Passo",
		"body_color": "Blu Notte Metallizzato",
		"color_rgb": Color(0.08, 0.18, 0.45),
		"engine_health": 0.92,
		"body_health": 0.84,
		"tire_health": 0.88,
		"tire_type": "studded",
		"tuning_parts": [],
		"mileage_km": 98400,
		"bought_price_lire": 2400000,
		"estimated_value": 2800000
	}
]

# Newspaper Classified Ads Catalog (Refreshed regularly)
var classified_ads: Array = []

# Story Rivals & Diner Characters (Living World AAA Dialogue & Affinity System)
var rivals = {
	"bepi": {
		"id": "bepi",
		"name": "Mastro Bepi",
		"role": "Oste Meccanico del Diner & Ex Collaudatore",
		"car_name": "Nessuna (Banco Attrezzi)",
		"avatar_icon": "👨‍🦳",
		"rep_required": 0,
		"affinity": 35,
		"status": "friendly",
		"quote": "Bevi questo espresso caldo, ragazzo. Su questa montagna, il carburatore si accorda a orecchio col respiro dell'altitudine.",
		"dialogue_advice": [
			"Sulla 127 e sui motori ad aste e bilancieri, ricordati che sopra i 1500 metri l'aria si fa rarefatta. Se monti doppi carburatori Weber, ritarda l'anticipo di due gradi o imbratterai le candele sul San Rocco!",
			"Nelle staccate in discesa prima del ponte, non bloccare l'anteriore. Usa la scalata tacco-punta: doppietta veloce per sincronizzare i giri prima di inserire la seconda.",
			"Se senti battere in testa quando affronti la salita dei larici, passa dalla Sandra all'Agip e metti qualche litro di benzina Super rossa ad alti ottani."
		],
		"dialogue_rumors": [
			"Gino si vanta tanto della sua Golf GTI 16V, ma soffre nei transitori: se lo tieni sotto pressione nei primi 200 metri del rettifilo, sbaglia la cambiata tra prima e seconda.",
			"Negli anni '70 qui saliva la squadra corse ufficiale con le Fulvia HF e le Stratos. Dicevano che il Duca conserva ancora nei suoi capannoni un motore da corsa preparato da Repetto...",
			"Chiara non cerca solo vecchi rottami: suo nonno era il custode dei fienili della forestale e conosce ogni cascina abbandonata dove riposano teli impolverati."
		]
	},
	"gino": {
		"id": "gino",
		"name": "Gino 'Il Corsaiolo'",
		"role": "Re del Semaforo di San Rocco",
		"car_id": "golf_gti_1990",
		"car_name": "VW Golf GTI 16V Mk2",
		"avatar_icon": "😎",
		"rep_required": 40,
		"affinity": 10,
		"status": "ready",
		"bet_lire": 500000,
		"drag_time_target": 15.6,
		"quote": "Pensi che quel tuo rottame possa starmi dietro al semaforo del lago? Ti brucio in seconda marcia!",
		"dialogue_advice": [
			"Vuoi partire forte al semaforo? Non mollare la frizione di colpo: porta i giri a 3800, fai pattinare le gomme per dieci metri per scaldarle e poi butta dentro la seconda secca!",
			"I cerchi BBS a nido d'ape e lo scarico sdoppiato non sono solo estetica: alleggeriscono le masse non sospese. Nei cambi di direzione del lungolago fa tutta la differenza."
		],
		"dialogue_rumors": [
			"Kurt crede che solo le trazioni posteriori bavaresi sappiano curvare. Ma quando piove sull'asfalto viscido della gola, la sua BMW gira come una trottola se osa dare gas!",
			"Il Duca non degna nessuno di uno sguardo. Vive rintanato nel fortino all'80° Parallelo. Dicono che accetti sfide solo se metti sul tavolo il libretto originale firmato."
		]
	},
	"chiara": {
		"id": "chiara",
		"name": "Chiara 'La Cacciatrice'",
		"role": "Esploratrice di Fienili & Guida Alpina",
		"car_name": "Fiat Panda 4x4 Trekking",
		"avatar_icon": "👩‍🔧",
		"rep_required": 100,
		"affinity": 20,
		"status": "friendly",
		"quote": "Ho scoperto un fienile abbandonato dietro San Rocco. Se hai un cric, due cinghie e buone gomme, l'auto è tua!",
		"dialogue_advice": [
			"Sulle pietraie e sul fango non serve la potenza bruta: serve galleggiamento. Tieni la pressione gomme a 1.6 bar e marce corte per non scavare solchi.",
			"Se la strada comincia a gelare prima della galleria, guarda il riflesso dei fari: se l'asfalto brilla come uno specchio scuro, è verglas. Niente frenate brusche!"
		],
		"dialogue_rumors": [
			"Ho intravisto una sagoma rettangolare coperta da sacchi di iuta nella cascina del vecchio mugnaio a Valbruna... sembra proprio una gloriosa Renault 4 con il cambio a cruscotto!",
			"Hans fa il duro col suo Mercedes G-Wagen, ma ha paura della nebbia cieca nel canyon. Se lo sfidi di notte o con la foschia, va a passo d'uomo."
		]
	},
	"kurt": {
		"id": "kurt",
		"name": "Kurt 'Der Bayer'",
		"role": "Ingegnere dei Tornanti & Cultore Bavarese",
		"car_id": "bmw_320_e30",
		"car_name": "BMW 320i E30 (6 Cilindri)",
		"avatar_icon": "🧐",
		"rep_required": 180,
		"affinity": 15,
		"status": "ready",
		"bet_lire": 1200000,
		"drag_time_target": 16.2,
		"quote": "La trazione posteriore bavarese non ammette errori nei tornanti. Scommettiamo sul Passo dei Larici?",
		"dialogue_advice": [
			"Il segreto del 6 cilindri in linea è l'equilibrio 50:50 sui due assi. In ingresso curva devi frenare dritto, trasferire il carico sull'avantreno, e solo allora inserire il muso.",
			"Non dare gas a metà tornante a ruote ancora sterzate, a meno che tu non voglia finire contro il guardrail. Aspetta di vedere l'uscita prima di spalancare le farfalle."
		],
		"dialogue_rumors": [
			"La leggenda narra che nel 1982 una squadra di collaudatori di Monaco salì quassù di nascosto per testare i primi prototipi di M3 contro le Delta... persero per tre secondi sui larici.",
			"Mastro Bepi è modesto, ma conserva ancora la tuta con lo stemma dell'elefantino HF nel retrobottega. Ascolta i suoi consigli sull'assetto!"
		]
	},
	"sandra": {
		"id": "sandra",
		"name": "Sandra della Stazione Agip",
		"role": "Custode della Pompa di Benzina & Meteo Alpino",
		"car_name": "Autobianchi A112 Abarth",
		"avatar_icon": "⛽",
		"rep_required": 80,
		"affinity": 30,
		"status": "friendly",
		"quote": "Pieno fatto e parabrezza sgrassato! Occhio che lassù dopo la galleria la temperatura è scesa sotto zero.",
		"dialogue_advice": [
			"Quando la salita diventa ripida e il serbatoio è sotto un quarto, la benzina rischia di sciacquare lontano dal pescante nei tornanti veloci. Tieni sempre almeno metà serbatoio!",
			"Ho messo da parte dei filtri benzina metallici a maglia fine: con la ruggine dei vecchi serbatoi di montagna evitano che i getti del carburatore si ostruiscano sul più bello."
		],
		"dialogue_rumors": [
			"Don Attilio ogni domenica mattina cronometra di nascosto le auto che passano davanti al sagrato con un Heuer d'epoca. Conosce i tempi sul giro di tutti noi!",
			"Ieri sera il Duca è sceso con la Delta scura a fare il pieno di benzina speciale... il fischio della sua turbina Garrett si sentiva fino in paese prima ancora che sbucasse dalla curva."
		]
	},
	"don_attilio": {
		"id": "don_attilio",
		"name": "Don Attilio",
		"role": "Parroco di San Cristoforo & Cronometrista Storico",
		"car_name": "Citroën 2CV Gialla",
		"avatar_icon": "⛪",
		"rep_required": 120,
		"affinity": 40,
		"status": "friendly",
		"quote": "Benedico le vostre vetture ogni domenica, figliolo, ma ricordati: il Signore protegge i prudenti, sui tornanti ghiacciati tocca alle tue gomme!",
		"dialogue_advice": [
			"Il segreto della salita è il ritmo, come i rintocchi delle campane. Se spezzi il ritmo scalando all'improvviso, perdi l'inerzia e la montagna ti respinge.",
			"Ascolta il suono dell'eco tra le pareti di roccia: ti dice prima della curva se sta scendendo un boscaiolo o se la strada davanti a te è libera."
		],
		"dialogue_rumors": [
			"Nel 1974 vidi Sandro Munari fermarsi proprio davanti a questo sagrato per cambiare una gomma forata. Mi regalò la sua candela di ricambio: la conservo ancora in sagrestia come una reliquia!",
			"La strada del valico fu costruita dai genieri militari negli anni '30: ci sono ancora vecchi ricoveri in pietra dove i piloti dei rally si riparavano dalle bufere."
		]
	},
	"hans": {
		"id": "hans",
		"name": "Hans 'Il Taglialegna'",
		"role": "Veterano dei Valichi & Signore della Neve",
		"car_id": "mercedes_gwagen",
		"car_name": "Mercedes G-Wagen 280GE",
		"avatar_icon": "🧔",
		"rep_required": 350,
		"affinity": 10,
		"status": "ready",
		"bet_lire": 2000000,
		"drag_time_target": 18.2,
		"quote": "Quando nevica sul valico, le vostre berlinette da città restano a piedi. Solo un vero telaio a longheroni taglia il traguardo.",
		"dialogue_advice": [
			"Sulla neve alta e sul fango dei boscaioli, inserisci il blocco del differenziale centrale prima di fermarti. Se provi a bloccarlo dopo che stai già slittando, hai già perso.",
			"Le gomme da asfalto slick lassù sono un suicidio. Ti servono tasselli profondi o le Nokian chiodate, altrimenti ti ritrovo nella scarpata con la motosega!"
		],
		"dialogue_rumors": [
			"Il Duca pensa di essere il re solo perché la sua Delta ha la trazione integrale Torsen. Ma quando la neve supera i trenta centimetri, lo spanciamento lo ferma, mentre il mio G-Wagen passa sopra i tronchi!",
			"Oltre il mulino c'è un sentiero tra le baite che taglia due tornanti... se hai il coraggio di passare sui ponticelli di tronchi, puoi recuperare dieci secondi sul cronometro."
		]
	},
	"duca": {
		"id": "duca",
		"name": "Il Duca del Meridiano",
		"role": "CAMPIONE INCONTRASTATO (BOSS FINALE)",
		"car_id": "delta_integrale",
		"car_name": "Lancia Delta HF Integrale Evo",
		"avatar_icon": "👑",
		"rep_required": 650,
		"affinity": 5,
		"status": "locked",
		"bet_lire": 5000000,
		"drag_time_target": 13.8,
		"quote": "La Regina dei Rally non si concede ai pivelli. Torna quando avrai battuto tutti e scommesso il libretto.",
		"dialogue_advice": [
			"Vuoi sapere come si guida una Gruppo A da 210 cavalli? Devi fidarti del differenziale anteriore. Quando la macchina sembra sottosterzare verso il burrone, devi affondare il gas, non toglierlo. I quattro differenziali faranno il resto.",
			"La perfezione meccanica è spietata. Un manicotto allentato o una valvola wastegate sporca e la turbina perde tre decimi di bar. E tre decimi di bar su questo valico significano sconfitta."
		],
		"dialogue_rumors": [
			"Molti credono che questa Delta sia solo un'auto. In realtà è l'ultimo telaio assemblato a mano a Chivasso con specifiche per il Rally di Sanremo. Ha vinto tre titoli ed è imbattuta su questo passo dal 1991.",
			"Se mai riuscirai a battermi quassù all'80° Parallelo, le chiavi e il libretto originale saranno tuoi. Ma prima dovrai dimostrare di avere il sangue freddo di un vero pilota."
		]
	}
}

# ==============================================================================
# TOPOGRAPHIC VALLEY LOCATIONS (CARTA TOPOGRAFICA IGM / TOURING '93)
# ==============================================================================
var valley_map_locations: Array = [
	{
		"id": "san_cristoforo",
		"name": "Borgo Storico di San Cristoforo",
		"km_range": "km 0.0 - 0.9",
		"target_z": 920.0,
		"altitude_m": 420,
		"gradient_pct": "+2.5%",
		"weather": "Sereno autunnale (14°C)",
		"surface": "Lastricato in porfido & asfalto riparato",
		"characters": "Mastro Bepi, Don Attilio, Gino",
		"services": "Officina Bepi, Bar dello Sport, Cabina SIP, Fontana del '700",
		"lore": "Antico borgo di pietra che fa da porta d'ingresso alla vallata. Punto di ritrovo di tutti gli appassionati e quartier generale dell'Officina Meccanica di Mastro Bepi."
	},
	{
		"id": "lago_san_rocco",
		"name": "Rettifilo del Lago di San Rocco",
		"km_range": "km 0.9 - 1.4",
		"target_z": 1250.0,
		"altitude_m": 510,
		"gradient_pct": "+1.2%",
		"weather": "Brezza lacustre (12°C)",
		"surface": "Asfalto liscio a grana fine (Pista Drag 1/4 miglio)",
		"characters": "Gino 'Il Corsaiolo', Chiara",
		"services": "Semaforo Drag di partenza, Molo barche, Chiosco Miramare",
		"lore": "Il famoso rettilineo lungo la sponda del lago alpino. Qui dal tramonto in poi i giovani si sfidano nella partenza da fermo al semaforo sulle 400 yarde."
	},
	{
		"id": "stazione_agip",
		"name": "Stazione di Servizio Agip 1993",
		"km_range": "km 1.4 - 2.0",
		"target_z": 1780.0,
		"altitude_m": 680,
		"gradient_pct": "+4.8%",
		"weather": "Sole velato & nubi basse (10°C)",
		"surface": "Piazzale in cemento bitumato con pompe carburante",
		"characters": "Sandra Agip, Chiara",
		"services": "Pompe Super Rossa 100 ottani, Compressore gomme, Cabina SIP",
		"lore": "L'ultimo avamposto prima dell'alta quota. Sandra gestisce con passione la pompa di benzina e conserva fusti di additivo speciale per i motori da gara."
	},
	{
		"id": "gola_canyon",
		"name": "Gola dell'Orrido & Ponte dei Ciclopi",
		"km_range": "km 2.0 - 3.2",
		"target_z": 2400.0,
		"altitude_m": 1150,
		"gradient_pct": "+7.5%",
		"weather": "Pioggia battente & foschia di gola (6°C)",
		"surface": "Asfalto umido rugoso con buche da disgelo e paracarri",
		"characters": "Chiara 'La Cacciatrice'",
		"services": "Rifugio di emergenza ANAS, Cascata dell'Orrido",
		"lore": "Parete rocciosa verticale a picco sul torrente glaciale. Il Ponte dei Ciclopi fu eretto nel dopoguerra: carreggiata stretta e asfalto perennemente scivoloso."
	},
	{
		"id": "tornanti_larici",
		"name": "Tornanti dei Larici d'Oro (Touge)",
		"km_range": "km 3.2 - 4.4",
		"target_z": 3800.0,
		"altitude_m": 1650,
		"gradient_pct": "+9.8%",
		"weather": "Vento freddo & aghi di pino umidi (3°C)",
		"surface": "Catrame ruvido montano con 14 tornanti tecnici",
		"characters": "Kurt 'Der Bayer'",
		"services": "Postazione cronometristi del rally, Guardrail in acciaio",
		"lore": "La mecca della guida tecnica alpina. 14 tornanti a gomito che premiano il bilanciamento dei pesi, l'assetto ribassato e la precisione millimetrica dello sterzo."
	},
	{
		"id": "pista_boscaioli",
		"name": "Pista dei Boscaioli & Vecchio Mulino",
		"km_range": "km 4.4 - 5.4",
		"target_z": 4900.0,
		"altitude_m": 2100,
		"gradient_pct": "+11.2%",
		"weather": "Nevischio e fango gelato (-1°C)",
		"surface": "Sterrato misto ghiaia, solchi di fango e lastre di ghiaccio",
		"characters": "Hans 'Il Taglialegna'",
		"services": "Segheria alpina, Mulino a vento dell'altopiano, Fienili storici",
		"lore": "Il regno della trazione integrale e delle gomme chiodate. Hans pattuglia questi boschi col suo Mercedes G-Wagen trasportando tronchi d'abete."
	},
	{
		"id": "passo_meridiano",
		"name": "Base Polare 80° Parallelo & Valico del Duca",
		"km_range": "km 5.4 - 6.0",
		"target_z": 5600.0,
		"altitude_m": 2650,
		"gradient_pct": "+6.0%",
		"weather": "Bufera di neve polare (-7°C)",
		"surface": "Ghiaccio compatto innevato, muri di neve alti 2 metri",
		"characters": "Il Duca del Meridiano",
		"services": "Hangar elicotteri, Osservatorio meteo, Traguardo d'onore",
		"lore": "Il punto più alto del meridiano, dove l'aria è gelida e solo i campioni osano sfidare il Duca per la corona e il libretto della Lancia Delta Integrale."
	}
]

# ==============================================================================
# 4 NARRATIVE CHAPTERS ("I QUADERNI DEL PASSO '93")
# ==============================================================================
var notebook_chapters: Array = [
	{
		"id": 1,
		"title": "CAPITOLO I: I RAGAZZI DEL FONDOVALLE",
		"subtitle": "Dal garage di Bepi al Semaforo del Lago",
		"quota_range": "420m - 510m s.l.m.",
		"desc": "Sei arrivato al Valico con poche lire in tasca e una Fiat 127 vissuta. Fatti notare al Diner, guadagnati la fiducia di Mastro Bepi e zittisci la Golf GTI di Gino al semaforo.",
		"rep_required": 0,
		"completed": false
	},
	{
		"id": 2,
		"title": "CAPITOLO II: I CONTRABBANDIERI DELLE GOLE",
		"subtitle": "La tempesta dell'Orrido e la stazione Agip",
		"quota_range": "510m - 1150m s.l.m.",
		"desc": "Oltrepassa il rettifilo, conquista i ricambi speciali alla stazione Agip di Sandra ed esplora i fienili sperduti con Chiara prima che la pioggia allaghi il Ponte dei Ciclopi.",
		"rep_required": 100,
		"completed": false
	},
	{
		"id": 3,
		"title": "CAPITOLO III: I MAESTRI DEL TOUGE",
		"subtitle": "La danza dei 14 tornanti contro Kurt e la BMW",
		"quota_range": "1150m - 1650m s.l.m.",
		"desc": "L'asfalto sale implacabile tra i larici dorati. Monta assetto sportivo e semi-slick: affronta Kurt sul Touge tecnico dove ogni frazione di secondo vale una fortuna.",
		"rep_required": 220,
		"completed": false
	},
	{
		"id": 4,
		"title": "CAPITOLO IV: IL DUELLO ALL'80° PARALLELO",
		"subtitle": "La corona del Valico & Il libretto della Regina",
		"quota_range": "1650m - 2650m s.l.m.",
		"desc": "Supera la bufera del Mulino con Hans ed entra nella fortezza del Duca. È il momento di scommettere tutto nel Pink Slip Match contro la leggendaria Delta Integrale!",
		"rep_required": 500,
		"completed": false
	}
]

# ==============================================================================
# VINTAGE CAR RADIO (1993 AM/FM DIAL)
# ==============================================================================
var radio_stations: Array = [
	{
		"id": "off",
		"name": "AUTORADIO SPENTA",
		"freq": "---",
		"desc": "Nessuna trasmissione"
	},
	{
		"id": "radio_valico",
		"name": "RADIO VALICO FM",
		"freq": "104.2 MHz",
		"genre": "Italo-Disco & Synthwave '93",
		"desc": "La musica dei giovani del lago: bassline serrato e melodie di sintetizzatore"
	},
	{
		"id": "onda_verde",
		"name": "ONDA VERDE ALPINO",
		"freq": "98.5 MHz",
		"genre": "Bollettino Traffico & Meteo Valichi",
		"desc": "Notiziario ANAS in tempo reale: transiti, allarmi gelo e cronaca delle corse"
	},
	{
		"id": "monte_rosa",
		"name": "RADIO MONTE ROSA",
		"freq": "89.0 MHz",
		"genre": "Melodie Alpine & Rintocchi di Valle",
		"desc": "Fisarmonica nostalgica, echi montani e rintocchi di campane di paese"
	}
]
var current_radio_station_idx: int = 1 # Starts playing Radio Valico 104.2 FM

# Narrative Contracts & Missions (Italian Grand Tour Campaign)
var contracts = [
	{
		"id": "delivery_agip",
		"title": "🏔️ RODAGGIO AL PASSO DELLE ALPI & AGIP 1840M",
		"client": "Mastro Bepi (Diner)",
		"destination": "Stazione Agip Alpi Quota 1840m (Z = 720m)",
		"target_dist_m": 720.0,
		"lore": "Raggiungi la Stazione Agip delle Alpi entro 3:30 min per sbloccare la Licenza Abarth Sport e rifornire di benzina speciale Super Rossa.",
		"reward_lire": 650000,
		"reward_rep": 50,
		"completed": false,
		"active": true
	},
	{
		"id": "drag_gino",
		"title": "⚔️ LA SFIDA AL SEMAFORO DEL LAGO DI LARICI",
		"client": "Gino 'Il Corsaiolo'",
		"destination": "Rettifilo del Lago (Z = 450m)",
		"target_dist_m": 450.0,
		"lore": "Batti la VW Golf GTI 16V di Gino nella partenza bruciante da fermo sui 400 metri del lungolago.",
		"reward_lire": 500000,
		"reward_rep": 80,
		"completed": false,
		"active": false
	},
	{
		"id": "barn_find_r4",
		"title": "🏚️ RECUPERO NEL FIENILE DI BORGO SAN CRISTOFORO",
		"client": "Chiara 'La Cacciatrice'",
		"destination": "Cascina di San Cristoforo (Z = 1015m)",
		"target_dist_m": 1015.0,
		"lore": "Chiara ha individuato una leggendaria Renault 4 GTL dimenticata in un fienile. Raggiungila per aggiungerla alla collezione!",
		"reward_lire": 400000,
		"reward_rep": 90,
		"unlocked_car": "renault_4",
		"completed": false,
		"active": false
	},
	{
		"id": "canyon_cyclopes",
		"title": "🌉 ATTRAVERSAMENTO DELLA FORRA & PONTE DEI CICLOPI",
		"client": "Mastro Bepi",
		"destination": "Ponte dei Ciclopi Quota 1280m (Z = 1485m)",
		"target_dist_m": 1485.0,
		"lore": "Affronta il baratro della Forra dell'Appennino e supera il viadotto ad archi senza danneggiare il carico di ricambi.",
		"reward_lire": 1200000,
		"reward_rep": 140,
		"completed": false,
		"active": false
	},
	{
		"id": "touge_kurt",
		"title": "🍂 IL DUELLO DEI TORNANTI NELLE COLLINE TOSCANE",
		"client": "Kurt 'Der Bayer'",
		"destination": "Autogrill Valico del Meridiano (Z = 3155m)",
		"target_dist_m": 3155.0,
		"lore": "Sfida la BMW 320i E30 di Kurt tra i cipressi e le colline toscane prima del tramonto.",
		"reward_lire": 1800000,
		"reward_rep": 180,
		"completed": false,
		"active": false
	},
	{
		"id": "boss_duca",
		"title": "👑 LA CORONA DEL DUCA AL VALICO GLACIALE (QUOTA 2650M)",
		"client": "Il Duca del Meridiano",
		"destination": "Rifugio del Duca - Quota 2650m (Z = 5200m)",
		"target_dist_m": 5200.0,
		"lore": "La resa dei conti definitiva sul ghiacciaio alpino: batti la Lancia Delta HF Integrale Evo per diventare la nuova Leggenda d'Italia!",
		"reward_lire": 5000000,
		"reward_rep": 400,
		"unlocked_car": "delta_integrale",
		"completed": false,
		"active": false
	}
]

# Workshop Available Upgrades
var tuning_catalog = {
	"scarico_sport": {
		"name": "Scarico Sportivo & Collettori 4-in-1",
		"desc": "+8% Coppia motrice, sound grintoso da competizione",
		"price_lire": 450000,
		"torque_mult": 1.08,
		"icon": "💨"
	},
	"carburatori_doppi": {
		"name": "Doppi Carburatori Weber / Iniezione Sport",
		"desc": "+12% Coppia, risposta gas istantanea senza vuoti",
		"price_lire": 750000,
		"torque_mult": 1.12,
		"icon": "⚡"
	},
	"camme_spinte": {
		"name": "Albero a Camme Profilo Stradale Spinto",
		"desc": "+500 RPM a limitatore e allungo mozzafiato agli alti",
		"price_lire": 900000,
		"redline_boost": 500.0,
		"icon": "⚙️"
	},
	"assetto_corsa": {
		"name": "Assetto Sportivo Ribassato con Molle Rigide",
		"desc": "-40% Rollio in curva, tenuta granitica sui tornanti",
		"price_lire": 600000,
		"stiff_mult": 1.35,
		"roll_mult": 0.60,
		"icon": "🔩"
	},
	"overboost_turbo": {
		"name": "Kit Wastegate Rinforzata & Valvola Overboost",
		"desc": "+0.25 bar picco di sovralimentazione (solo motori Turbo)",
		"price_lire": 1100000,
		"boost_add": 0.25,
		"requires_turbo": true,
		"icon": "🌀"
	}
}

# Tire Types Available
var tires_catalog = {
	"touring": {
		"name": "Michelin Touring (Stradali Standard)",
		"desc": "Equilibrate per asfalto asciutto e bagnato leggero",
		"price_lire": 280000,
		"friction_bonus": 0.0,
		"mud_bonus": 0.0
	},
	"semislick": {
		"name": "Pirelli P-Zero Corsa (Semi-Slick)",
		"desc": "+25% aderenza su asfalto asciutto; scivolano su fango",
		"price_lire": 680000,
		"friction_bonus": 0.40,
		"mud_bonus": -0.30
	},
	"studded": {
		"name": "Nokian Hakkapeliitta (Chiodate da Ghiaccio/Fango)",
		"desc": "+45% trazione su ghiaccio, neve e fango alpino",
		"price_lire": 580000,
		"friction_bonus": -0.10,
		"mud_bonus": 0.65
	}
}

# Vintage Paint Palette
var paint_palette = [
	{"name": "Rosso Corsa", "color": Color(0.85, 0.08, 0.08)},
	{"name": "Giallo Ginestra", "color": Color(0.95, 0.82, 0.10)},
	{"name": "Verde Muschio", "color": Color(0.18, 0.35, 0.20)},
	{"name": "Blu Notte Metallizzato", "color": Color(0.08, 0.18, 0.45)},
	{"name": "Bianco Alpi", "color": Color(0.92, 0.94, 0.92)},
	{"name": "Grigio Meteora", "color": Color(0.38, 0.40, 0.42)},
	{"name": "Nero Vulcano", "color": Color(0.08, 0.08, 0.09)}
]

func _ready():
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -6.0
	add_child(sfx_player)
	
	load_career()
	generate_classified_ads()
	broadcast_career()

# ==============================================================================
# CAR MARKET / NEWSPAPER ADS GENERATOR
# ==============================================================================
func generate_classified_ads():
	classified_ads.clear()
	
	# Model templates with period flavor
	var templates = [
		{
			"car_id": "fiat_127",
			"name": "Fiat 127 Special (1974)",
			"desc": "Unico proprietario anziano, motore 903cc brillantesimo. Carburatore pulito da poco, piccoli punti ruggine sottoporta.",
			"base_price": 1350000,
			"year": 1974,
			"colors": ["Giallo Ginestra", "Bianco Alpi", "Rosso Corsa"]
		},
		{
			"car_id": "panda_4x4",
			"name": "Fiat Panda 4x4 Steyr-Puch (1983)",
			"desc": "Inarrestabile sulle pietraie. Trazione integrale Steyr con primina. Fondo sano, carrozzeria vissuta ma perfetta per i passi alpini.",
			"base_price": 2400000,
			"year": 1983,
			"colors": ["Verde Muschio", "Rosso Corsa", "Bianco Alpi"]
		},
		{
			"car_id": "renault_4",
			"name": "Renault 4 GTL 1108cc (1980)",
			"desc": "Leva del cambio a ombrello sul cruscotto. Consumi irrisori, sospensioni morbidissime che mangiano buche e sassi.",
			"base_price": 1600000,
			"year": 1980,
			"colors": ["Bianco Alpi", "Blu Notte Metallizzato", "Grigio Meteora"]
		},
		{
			"car_id": "golf_gti_1990",
			"name": "Volkswagen Golf GTI 16V Mk2 (1990)",
			"desc": "La regina dei giovani anni '90! Motore 1.8 16 valvole con scarico doppio, cerchi BBS, sedili tartan, sempre tagliandata.",
			"base_price": 7200000,
			"year": 1990,
			"colors": ["Rosso Corsa", "Nero Vulcano", "Grigio Meteora"]
		},
		{
			"car_id": "bmw_320_e30",
			"name": "BMW 320i E30 6 Cilindri (1990)",
			"desc": "Velluto a 6 cilindri bavarese, trazione posteriore pura. Assetto perfetto per chi sa guidare nei tornanti.",
			"base_price": 8600000,
			"year": 1990,
			"colors": ["Blu Notte Metallizzato", "Grigio Meteora", "Nero Vulcano"]
		},
		{
			"car_id": "mercedes_gwagen",
			"name": "Mercedes-Benz G-Wagen 280GE (1985)",
			"desc": "Carrarmato tedesco a 3 blocchi differenziali. Inarrestabile ovunque, anche nelle peggiori bufere di neve a -20°C.",
			"base_price": 14500000,
			"year": 1985,
			"colors": ["Verde Muschio", "Grigio Meteora", "Nero Vulcano"]
		},
		{
			"car_id": "delta_integrale",
			"name": "Lancia Delta HF Integrale Evo (1991)",
			"desc": "LA LEGGENDA DEI RALLY. Trazione Torsen 4WD, turbo Garrett T3, 210 CV di pura gloria italiana. Auto da collezione.",
			"base_price": 32000000,
			"year": 1991,
			"colors": ["Rosso Corsa", "Giallo Ginestra", "Bianco Alpi"]
		},
		{
			"car_id": "mercedes_a250",
			"name": "Mercedes A 250 Sport AMG (2016)",
			"desc": "PROTOTIPO DEL FUTURO! 2.0 Turbo 211 CV, cambio a 7 marce con palette al volante. Prestazioni extraterrestri per il 1993.",
			"base_price": 42000000,
			"year": 2016,
			"colors": ["Grigio Meteora", "Nero Vulcano", "Rosso Corsa"]
		},
		{
			"car_id": "fiat_topolino",
			"name": "Fiat 500A Topolino (1936)",
			"desc": "Capolavoro dell'Ing. Dante Giacosa! Capote apribile in tela, portiere a vento. Meccanica 569cc restaurata con passione.",
			"base_price": 4800000,
			"year": 1936,
			"colors": ["Amaranto e Nero", "Verde Bosco", "Grigio Pietra"]
		},
		{
			"car_id": "alfa_8c",
			"name": "Alfa Romeo 8C 2900B Spider Corto (1938)",
			"desc": "LA REGINA DELLA MILLE MIGLIA! 8 cilindri in linea bialbero con doppio compressore Roots. Telaio Touring Superleggera originale, certificata ASI Targa Oro.",
			"base_price": 280000000,
			"year": 1938,
			"colors": ["Rosso Amaranto Touring", "Rosso Corsa Alfa", "Blu Savoia"]
		},
		{
			"car_id": "lancia_aurelia",
			"name": "Lancia Aurelia B20 GT 2500 (1953)",
			"desc": "LA PRIMA GRAN TURISMO AL MONDO. Primo motore V6 di serie, ponte De Dion e freni entrobordo. Volante Nardi in mogano, linea Pininfarina senza tempo.",
			"base_price": 45000000,
			"year": 1953,
			"colors": ["Blu Lancia Metallizzato", "Grigio Metallizzato", "Nero Pastello"]
		},
		{
			"car_id": "alfa_gta",
			"name": "Alfa Romeo Giulia Sprint GTA (1965)",
			"desc": "GRAN TURISMO ALLEGGERITA AUTODELTA! Scocca in lega di Peraluman 25 (745 kg!), motore Twin Spark con doppi Weber 45 DCOE. Una lama nei tornanti.",
			"base_price": 58000000,
			"year": 1965,
			"colors": ["Rosso Alfa Corsa", "Bianco Spino Autodelta", "Rosso Monza"]
		},
		{
			"car_id": "fiat_131_abarth",
			"name": "Fiat 131 Abarth Rally (1976)",
			"desc": "3 VOLTE CAMPIONESSA DEL MONDO RALLY! 2.0 16V Lampredi Abarth, parafanghi allargati Bertone, presa d'aria asimmetrica e alettone sul baule.",
			"base_price": 26000000,
			"year": 1976,
			"colors": ["Blu Navy Olio Fiat", "Rosso Corsa Abarth", "Bianco Alitalia"]
		},
		{
			"car_id": "lancia_stratos",
			"name": "Lancia Stratos HF Stradale (1974)",
			"desc": "REGINA ASSOLUTA DEI RALLY. Motore centrale Ferrari Dino 2.4 V6, cuneo spaziale Bertone disegnato da Marcello Gandini. Passo ultracorto da gara.",
			"base_price": 85000000,
			"year": 1974,
			"colors": ["Giallo/Verde Lime Bertone", "Rosso Corsa", "Blu Stratos"]
		}
	]
	
	# Balanced Selection across historical and sport tiers (7 assorted ads in newspaper)
	var affordable_indices = [0, 1, 2, 8] # 127, Panda, R4, Topolino
	var mid_indices = [3, 4, 12] # Golf GTI, BMW 320, 131 Abarth
	var historic_legends = [9, 10, 11, 13] # Alfa 8C, Aurelia B20, Giulia GTA, Stratos HF
	var top_indices = [5, 6, 7] # G-Wagen, Delta Integrale, A250
	
	affordable_indices.shuffle()
	mid_indices.shuffle()
	historic_legends.shuffle()
	top_indices.shuffle()
	
	var chosen_templates = [
		templates[affordable_indices[0]],
		templates[affordable_indices[1]],
		templates[mid_indices[0]],
		templates[mid_indices[1]],
		templates[historic_legends[0]],
		templates[historic_legends[1]],
		templates[top_indices[0]]
	]
	
	for i in range(chosen_templates.size()):
		var tmpl = chosen_templates[i]
		var cond_eng = randf_range(0.65, 0.98)
		var cond_body = randf_range(0.60, 0.95)
		var km = randi_range(65000, 195000)
		var price_mod = (cond_eng * 0.6 + cond_body * 0.4) * (1.0 - float(km) / 500000.0)
		var final_price = int(tmpl.base_price * clamp(price_mod, 0.70, 1.25) / 10000.0) * 10000
		var c_name = tmpl.colors[randi() % tmpl.colors.size()]
		
		classified_ads.append({
			"id": "ad_%d_%d" % [i, randi() % 1000],
			"car_id": tmpl.car_id,
			"title": tmpl.name,
			"desc": tmpl.desc,
			"year": tmpl.year,
			"engine_health": cond_eng,
			"body_health": cond_body,
			"mileage_km": km,
			"price_lire": final_price,
			"color_name": c_name,
			"color_rgb": get_color_by_name(c_name)
		})

func buy_car(ad_index: int) -> bool:
	if ad_index < 0 or ad_index >= classified_ads.size():
		return false
	var ad = classified_ads[ad_index]
	if cash_lire < ad.price_lire:
		post_notification("FONDI INSUFFICIENTI", "Non hai abbastanza Lire in tasca per questo acquisto!", "💸", "error")
		return false
	if garage.size() >= max_garage_slots:
		post_notification("GARAGE PIENO", "Hai già %d auto nel box! Vendine una per fare spazio." % max_garage_slots, "🚗", "error")
		return false
		
	cash_lire -= ad.price_lire
	reputation += 30
	play_sfx("cash")
	
	var new_car = {
		"car_id": ad.car_id,
		"name": ad.title,
		"nickname": ad.title.split("(")[0].strip_edges(),
		"body_color": ad.color_name,
		"color_rgb": ad.color_rgb,
		"engine_health": ad.engine_health,
		"body_health": ad.body_health,
		"tire_health": 0.85,
		"tire_type": "touring",
		"tuning_parts": [],
		"mileage_km": ad.mileage_km,
		"bought_price_lire": ad.price_lire,
		"estimated_value": int(ad.price_lire * 1.15)
	}
	garage.append(new_car)
	classified_ads.remove_at(ad_index)
	
	post_notification("CONGRATULAZIONI!", "Hai acquistato: %s per L. %s!" % [new_car.name, format_lire(ad.price_lire)], "📜", "fanfare")
	broadcast_career()
	save_career()
	return true

func sell_car(garage_index: int) -> bool:
	if garage_index < 0 or garage_index >= garage.size():
		return false
	if garage.size() <= 1:
		post_notification("ATTENZIONE", "Non puoi vendere l'unica auto che possiedi! Rimarresti a piedi.", "⚠️", "error")
		return false
		
	var car = garage[garage_index]
	var sale_value = calculate_car_sale_value(car)
	cash_lire += sale_value
	reputation += 15
	play_sfx("cash")
	
	garage.remove_at(garage_index)
	if current_car_idx >= garage.size():
		current_car_idx = garage.size() - 1
		
	post_notification("AUTO VENDUTA!", "Hai venduto %s per L. %s!" % [car.name, format_lire(sale_value)], "💰", "cash")
	broadcast_career()
	save_career()
	return true

func calculate_car_sale_value(car: Dictionary) -> int:
	var base = car.get("bought_price_lire", 1500000)
	var health_mult = (car.get("engine_health", 0.8) * 0.5 + car.get("body_health", 0.8) * 0.3 + car.get("tire_health", 0.8) * 0.2)
	var parts_bonus = car.get("tuning_parts", []).size() * 350000
	var final_val = int((base * health_mult + parts_bonus) / 10000.0) * 10000
	return max(400000, final_val)

func select_active_car(garage_index: int) -> bool:
	if garage_index < 0 or garage_index >= garage.size():
		return false
	current_car_idx = garage_index
	play_sfx("wrench")
	emit_signal("car_switched", garage[current_car_idx])
	broadcast_career()
	save_career()
	return true

# ==============================================================================
# WORKSHOP REPAIRS & TUNING
# ==============================================================================
func service_engine() -> bool:
	var car = get_active_car()
	var cost = 250000
	if cash_lire < cost:
		post_notification("FONDI INSUFFICIENTI", "Un tagliando completo costa L. 250.000!", "💸", "error")
		return false
	if car.engine_health >= 0.99:
		post_notification("MOTORE PERFETTO", "Il motore è già a punto e non necessita tagliando.", "🔧", "info")
		return false
		
	cash_lire -= cost
	car.engine_health = 1.0
	play_sfx("wrench")
	post_notification("TAGLIANDO ESEGUITO", "Olio sintetico Castrol e candele nuove montate. Motore al 100%!", "🛢️", "wrench")
	broadcast_career()
	save_career()
	return true

func repair_body() -> bool:
	var car = get_active_car()
	var cost = 350000
	if cash_lire < cost:
		post_notification("FONDI INSUFFICIENTI", "Raddrizzare la carrozzeria costa L. 350.000!", "💸", "error")
		return false
	if car.body_health >= 0.99:
		post_notification("CARROZZERIA PERFETTA", "Nessuna ammaccatura o ruggine da riparare.", "✨", "info")
		return false
		
	cash_lire -= cost
	car.body_health = 1.0
	play_sfx("wrench")
	post_notification("CARROZZERIA RIMESSA A NUOVO", "Lattoniere e antiruggine completati. Struttura al 100%!", "🔨", "wrench")
	broadcast_career()
	save_career()
	return true

func buy_tires(tire_type: String) -> bool:
	if not tires_catalog.has(tire_type):
		return false
	var t_info = tires_catalog[tire_type]
	if cash_lire < t_info.price_lire:
		post_notification("FONDI INSUFFICIENTI", "Questo treno gomme costa L. %s!" % format_lire(t_info.price_lire), "💸", "error")
		return false
		
	var car = get_active_car()
	cash_lire -= t_info.price_lire
	car.tire_type = tire_type
	car.tire_health = 1.0
	play_sfx("wrench")
	post_notification("GOMME MONTATE", "Montate 4 gomme nuove: %s!" % t_info.name, "🛞", "wrench")
	broadcast_career()
	save_career()
	return true

func install_tuning_part(part_id: String) -> bool:
	if not tuning_catalog.has(part_id):
		return false
	var part = tuning_catalog[part_id]
	var car = get_active_car()
	
	if car.tuning_parts.has(part_id):
		post_notification("GIÀ INSTALLATO", "Questo componente è già presente sotto il cofano!", "⚙️", "info")
		return false
	if part.get("requires_turbo", false) and not (car.car_id in ["delta_integrale", "mercedes_a250"]):
		post_notification("NON COMPATIBILE", "La valvola Overboost richiede un motore sovralimentato con Turbina!", "🚫", "error")
		return false
	if cash_lire < part.price_lire:
		post_notification("FONDI INSUFFICIENTI", "Questo componente costa L. %s!" % format_lire(part.price_lire), "💸", "error")
		return false
		
	cash_lire -= part.price_lire
	car.tuning_parts.append(part_id)
	reputation += 25
	play_sfx("wrench")
	post_notification("ELABORAZIONE COMPLETATA!", "Installato: %s! Potenza e risposta migliorate." % part.name, part.icon, "wrench")
	broadcast_career()
	save_career()
	return true

func paint_car(color_name: String) -> bool:
	var col = get_color_by_name(color_name)
	var cost = 200000
	if cash_lire < cost:
		post_notification("FONDI INSUFFICIENTI", "La verniciatura in forno costa L. 200.000!", "💸", "error")
		return false
		
	var car = get_active_car()
	cash_lire -= cost
	car.body_color = color_name
	car.color_rgb = col
	play_sfx("wrench")
	post_notification("VERNICIATURA COMPLETATA", "La vettura splende in livrea: %s!" % color_name, "🎨", "fanfare")
	broadcast_career()
	save_career()
	return true

# ==============================================================================
# TRAVEL CONTRACTS & DISCOVERY TRACKER
# ==============================================================================
func check_journey_progress(player_distance_m: float):
	# 1. Realtime career mileage accumulation
	if last_tracked_z > 0.0 and player_distance_m > last_tracked_z:
		var delta_dist = player_distance_m - last_tracked_z
		if delta_dist > 0.0 and delta_dist < 200.0: # Filter out teleport spikes
			add_career_km(delta_dist / 1000.0)
	last_tracked_z = player_distance_m
	
	# 2. Check active contract destination completion
	for c in contracts:
		if c.get("active", false) and not c.get("completed", false):
			var target_z = c.get("target_dist_m", -1.0)
			if target_z > 0.0 and player_distance_m >= target_z:
				complete_contract(c)

func complete_contract(contract: Dictionary):
	contract.completed = true
	contract.active = false
	var rew_lire = contract.get("reward_lire", 0)
	var rew_rep = contract.get("reward_rep", 0)
	cash_lire += rew_lire
	reputation += rew_rep
	
	# Upgrade character progression & skills
	if player_profile.has("stats"):
		player_profile["stats"]["missions_completed"] = player_profile["stats"].get("missions_completed", 0) + 1
	if player_profile.has("skills"):
		player_profile["skills"]["meccanica"] = min(100, player_profile["skills"].get("meccanica", 70) + 2)
		player_profile["skills"]["assetto_curve"] = min(100, player_profile["skills"].get("assetto_curve", 70) + 2)
		player_profile["skills"]["respiro_quota"] = min(100, player_profile["skills"].get("respiro_quota", 70) + 3)
	
	var unlock_msg = ""
	if contract.has("unlocked_car") and not str(contract["unlocked_car"]).is_empty():
		var u_id = str(contract["unlocked_car"])
		unlock_msg = " Hai sbloccato una %s recuperata dal fienile!" % u_id.to_upper()
		if garage.size() < max_garage_slots:
			var barn_car = {
				"car_id": u_id,
				"name": ("Renault 4 GTL (1980)" if u_id == "renault_4" else "Lancia Delta Integrale Evo (1991)"),
				"nickname": "Il Ritrovamento di San Cristoforo",
				"body_color": ("Bianco Alpi" if u_id == "renault_4" else "Rosso Corsa"),
				"color_rgb": (Color(0.90, 0.92, 0.90) if u_id == "renault_4" else Color(0.85, 0.10, 0.10)),
				"engine_health": 0.65,
				"body_health": 0.55,
				"tire_health": 0.70,
				"tire_type": "touring",
				"tuning_parts": [],
				"mileage_km": 178000,
				"bought_price_lire": 0,
				"estimated_value": 2500000
			}
			garage.append(barn_car)
			unlock_msg += " (Aggiunta al Garage!)"
			
	emit_signal("contract_completed", contract)
	play_sfx("fanfare")
	post_notification("MISSIONE COMPIUTA! 🏆", "%s completata!\n+L. %s | +%d Rispetto!%s" % [
		contract.get("title", ""),
		format_lire(rew_lire),
		rew_rep,
		unlock_msg
	], "🏆", "fanfare")
	
	# Unlock next contract in sequence
	var cur_idx = -1
	for i in range(contracts.size()):
		if contracts[i].get("id") == contract.get("id"):
			cur_idx = i
			break
	if cur_idx >= 0 and cur_idx + 1 < contracts.size():
		contracts[cur_idx + 1].active = true
		active_contract_id = contracts[cur_idx + 1].get("id", "")
		
	broadcast_career()
	save_career()

# ==============================================================================
# DRAG RACING & RIVAL CHALLENGES
# ==============================================================================
func challenge_rival(rival_id: String, is_pink_slip: bool = false) -> Dictionary:
	if not rivals.has(rival_id):
		return {"success": false, "reason": "Rivale inesistente"}
	var r = rivals[rival_id]
	if reputation < r.rep_required:
		return {"success": false, "reason": "Rispetto insufficiente (richiesti %d pt)" % r.rep_required}
	var bet = r.bet_lire if not is_pink_slip else 0
	if not is_pink_slip and cash_lire < bet:
		return {"success": false, "reason": "Non hai abbastanza Lire per coprire la scommessa!"}
		
	return {
		"success": true,
		"rival_id": rival_id,
		"rival_name": r.name,
		"rival_car": r.car_name,
		"bet_lire": bet,
		"is_pink_slip": is_pink_slip,
		"target_time": r.drag_time_target
	}

func resolve_drag_race(rival_id: String, player_time: float, is_pink_slip: bool = false) -> Dictionary:
	var r = rivals[rival_id]
	var rival_time = r.drag_time_target + randf_range(-0.4, 0.5)
	var player_won = player_time < rival_time
	
	if player_won:
		if is_pink_slip:
			# Won rival's car!
			post_notification("VITTORIA A LIBRETTO!", "Hai battuto %s e vinto la sua %s!" % [r.name, r.car_name], "🏆", "fanfare")
			if garage.size() < max_garage_slots:
				garage.append({
					"car_id": r.car_id,
					"name": r.car_name,
					"nickname": "Trofeo di " + r.name,
					"body_color": "Rosso Corsa",
					"color_rgb": Color(0.85, 0.08, 0.08),
					"engine_health": 0.95,
					"body_health": 0.90,
					"tire_health": 0.90,
					"tire_type": "semislick",
					"tuning_parts": ["scarico_sport", "carburatori_doppi"],
					"mileage_km": 85000,
					"bought_price_lire": 0,
					"estimated_value": r.bet_lire * 3
				})
			reputation += 200
		else:
			cash_lire += r.bet_lire
			reputation += 80
			play_sfx("cash")
			post_notification("VITTORIA AL SEMAFORO!", "Hai battuto %s! Tempo: %.2fs vs %.2fs (+L. %s)" % [
				r.name, player_time, rival_time, format_lire(r.bet_lire)
			], "🏁", "fanfare")
	else:
		if not is_pink_slip:
			cash_lire = max(0, cash_lire - r.bet_lire)
			reputation = max(10, reputation - 20)
			play_sfx("error")
			post_notification("SCONFITTA AL RETTIFILO", "%s ti ha staccato! Tempo: %.2fs vs %.2fs (-L. %s)" % [
				r.name, player_time, rival_time, format_lire(r.bet_lire)
			], "💨", "error")
			
	broadcast_career()
	save_career()
	return {
		"won": player_won,
		"player_time": player_time,
		"rival_time": rival_time,
		"bet": r.bet_lire
	}

# ==============================================================================
# CAREER PERSISTENCE & HELPERS
# ==============================================================================
func get_active_car() -> Dictionary:
	if garage.is_empty():
		return {}
	current_car_idx = clamp(current_car_idx, 0, garage.size() - 1)
	return garage[current_car_idx]

func get_color_by_name(c_name: String) -> Color:
	for p in paint_palette:
		if p.name == c_name:
			return p.color
	return Color(0.18, 0.35, 0.20)

func format_lire(amount: int) -> String:
	var s = str(amount)
	var res = ""
	var cnt = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "." + res
	return res

func post_notification(title: String, message: String, icon: String, sfx: String):
	emit_signal("notification_posted", title, message, icon, sfx)
	play_sfx(sfx)

func broadcast_career():
	emit_signal("career_updated", {
		"cash_lire": cash_lire,
		"cash_formatted": format_lire(cash_lire),
		"reputation": reputation,
		"rep_title": get_reputation_title(),
		"player_profile": get_player_profile(),
		"garage": garage,
		"active_car_idx": current_car_idx,
		"active_car": get_active_car(),
		"active_contract": get_active_contract(),
		"classified_ads": classified_ads,
		"contracts": contracts,
		"rivals": rivals,
		"radio_station": get_current_radio_station(),
		"map_locations": valley_map_locations,
		"notebook_chapters": notebook_chapters
	})

func get_player_profile() -> Dictionary:
	var p = player_profile.duplicate(true)
	p["rank_title"] = get_reputation_title()
	return p

func update_player_profile(new_data: Dictionary):
	for k in new_data:
		player_profile[k] = new_data[k]
	emit_signal("profile_updated", player_profile)
	broadcast_career()
	save_career()

func get_active_contract() -> Dictionary:
	for c in contracts:
		if c.get("id") == active_contract_id or c.get("active", false):
			return c
	if not contracts.is_empty():
		return contracts[0]
	return {}

func set_active_contract(contract_id: String) -> bool:
	for c in contracts:
		if c.get("id") == contract_id:
			for other in contracts:
				other["active"] = false
			c["active"] = true
			active_contract_id = contract_id
			emit_signal("contract_selected", c)
			broadcast_career()
			save_career()
			post_notification("NUOVA MISSIONE ATTIVA 🎯", c.get("title", ""), "🎯", "wrench")
			return true
	return false

func add_career_km(km: float):
	if player_profile.has("stats"):
		player_profile["stats"]["km_driven"] = player_profile["stats"].get("km_driven", 0.0) + km
		save_career()

func get_reputation_title() -> String:
	if reputation < 80: return "Novellino dei Fondovalle"
	elif reputation < 180: return "Regolare del Diner"
	elif reputation < 350: return "Terrore dei Tornanti"
	elif reputation < 650: return "Asso del Valico"
	else: return "Re del Passo del Meridiano 👑"

# ==============================================================================
# CHARACTER DIALOGUE & LIVING WORLD LORE
# ==============================================================================
func talk_to_character(char_id: String, topic: String) -> Dictionary:
	if not rivals.has(char_id):
		return {"text": "Personaggio non presente al Diner.", "affinity": 0}
	var r = rivals[char_id]
	var response_text = ""
	var affinity_gain = 0
	
	match topic:
		"advice":
			var adv_list = r.get("dialogue_advice", [])
			if not adv_list.is_empty():
				var idx = randi() % adv_list.size()
				response_text = adv_list[idx]
			else:
				response_text = "Tieni gli occhi sulla strada e bada alla pressione dell'olio."
			affinity_gain = 8
		"rumors":
			var rum_list = r.get("dialogue_rumors", [])
			if not rum_list.is_empty():
				var idx = randi() % rum_list.size()
				response_text = rum_list[idx]
			else:
				response_text = "Si sentono strani rombi di notte salendo verso il ghiacciaio..."
			affinity_gain = 5
		"challenge":
			response_text = r.get("quote", "Vuoi sfidarmi? Metti i soldi sul tavolo!")
			affinity_gain = 2
		_:
			response_text = r.get("quote", "Benvenuto al Diner 'Da Bepi'.")
			affinity_gain = 1
			
	r["affinity"] = clamp(r.get("affinity", 10) + affinity_gain, 0, 100)
	play_sfx("wrench")
	return {
		"text": response_text,
		"affinity": r["affinity"],
		"char_name": r.name,
		"char_role": r.role
	}

# ==============================================================================
# DYNAMIC NEWSPAPER PRESS HEADLINES ("LA GAZZETTA DEL VALICO '93")
# ==============================================================================
func get_dynamic_news_headlines() -> Array:
	var headlines = []
	
	if reputation < 80:
		headlines.append("📰 CLAMORE A SAN CRISTOFORO: Un nuovo pilota si presenta all'officina di Bepi con una Fiat 127 Special!")
		headlines.append("⛽ BENZINA SUPER: La stazione Agip riceve il nuovo rifornimento di additivi speciali per motori d'epoca.")
		headlines.append("⚠️ ALLERTA METEO: Prime raffiche di bora sul Lago di San Rocco, pescatori e automobilisti all'erta.")
	elif reputation < 200:
		headlines.append("🏁 SFIDA AL RETTIFILO: Gino 'Il Corsaiolo' trema! Una berlinetta elaborata sfida la Golf GTI sul lago!")
		headlines.append("🏚️ MISTERO NEI FIENILI: Chiara dei Boschi avvista una scocca d'epoca abbandonata vicino alla vecchia mulattiera.")
		headlines.append("☕ AL DINER DA BEPI: Don Attilio cronometra le staccate del sagrato: 'Tempi da trofeo rallystico!'")
	elif reputation < 450:
		headlines.append("🏎️ LA GUERRA DEI TORNANTI: Kurt e la BMW 320i battuti sui larici d'oro da un magistrale assetto sportivo!")
		headlines.append("🌨️ BUFERA SUL CANYON: Hans col Mercedes G-Wagen avverte: 'Senza chiodi non si sale oltre il mulino!'")
		headlines.append("📻 ONDA VERDE ALPINO: Strada dell'Orrido chiusa ai turisti, autorizzati solo i collaudatori.")
	else:
		headlines.append("👑 LA CORONA TREMA: Il misterioso sfidante del fondovalle bussa alle porte della Fortezza dell'80° Parallelo!")
		headlines.append("⚡ DUELLO A LIBRETTO: La Lancia Delta HF Integrale Evo del Duca per la prima volta rischia di cambiare proprietario!")
		headlines.append("🏆 LA LEGGENDA DEL MERIDIANO: Mastro Bepi stappa il vino del '74: 'Un pilota così non si vedeva dai tempi di Munari!'")
		
	return headlines

# ==============================================================================
# CAR RADIO CONTROLS
# ==============================================================================
func switch_radio_station() -> Dictionary:
	current_radio_station_idx = (current_radio_station_idx + 1) % radio_stations.size()
	play_sfx("wrench")
	var st = radio_stations[current_radio_station_idx]
	post_notification("AUTORADIO 1993", "%s (%s)\n%s" % [st.name, st.freq, st.genre], "📻", "wrench")
	return st

func get_current_radio_station() -> Dictionary:
	return radio_stations[current_radio_station_idx]

func get_map_locations() -> Array:
	return valley_map_locations

func get_notebook_chapters() -> Array:
	return notebook_chapters

func save_career():
	var save_dict = {
		"cash_lire": cash_lire,
		"reputation": reputation,
		"current_car_idx": current_car_idx,
		"garage": garage,
		"contracts": contracts,
		"player_profile": player_profile,
		"active_contract_id": active_contract_id
	}
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(save_dict, "\t"))
		f.close()

func load_career():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var txt = f.get_as_text()
		f.close()
		var p = JSON.parse_string(txt)
		if p is Dictionary:
			cash_lire = p.get("cash_lire", 3500000)
			reputation = p.get("reputation", 40)
			current_car_idx = p.get("current_car_idx", 0)
			if p.has("garage") and p["garage"] is Array and not p["garage"].is_empty():
				garage = p["garage"]
			if p.has("contracts") and p["contracts"] is Array:
				contracts = p["contracts"]
			if p.has("player_profile") and p["player_profile"] is Dictionary:
				player_profile = p["player_profile"]
			if p.has("active_contract_id") and p["active_contract_id"] is String:
				active_contract_id = p["active_contract_id"]

# ==============================================================================
# AMIGA 500 PROCEDURAL SOUND SYNTHESIS
# ==============================================================================
func play_sfx(sfx_type: String):
	if not sfx_player or not sfx_player.is_inside_tree(): return
	var stream: AudioStreamWAV = null
	match sfx_type:
		"cash":
			stream = synth_cash_counter()
		"wrench":
			stream = synth_wrench_click()
		"fanfare":
			stream = synth_amiga_fanfare()
		"error":
			stream = synth_buzz()
		_:
			stream = synth_wrench_click()
			
	if stream:
		sfx_player.stream = stream
		sfx_player.play()

func synth_cash_counter() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count = int(22050 * 0.35)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = 0.0
		# Fast mechanical coin tick & bell
		var p1 = sin(t * 1760.0 * TAU) * exp(-fmod(t, 0.08) * 35.0) * 0.4
		var p2 = sin(t * 2637.0 * TAU) * exp(-t * 8.0) * 0.3
		s = p1 + p2
		bytes.encode_s16(i * 2, int(clamp(s * 32767.0, -32768.0, 32767.0)))
	wav.data = bytes
	return wav

func synth_wrench_click() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count = int(22050 * 0.22)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = sin(t * 440.0 * TAU) * exp(-t * 22.0) * 0.5 + (randf() * 2.0 - 1.0) * exp(-t * 40.0) * 0.3
		bytes.encode_s16(i * 2, int(clamp(s * 32767.0, -32768.0, 32767.0)))
	wav.data = bytes
	return wav

func synth_amiga_fanfare() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count = int(22050 * 0.65)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = 0.0
		if t < 0.15:
			s = sin(t * 523.25 * TAU) * 0.4 # C5
		elif t < 0.30:
			s = sin(t * 659.25 * TAU) * 0.4 # E5
		elif t < 0.45:
			s = sin(t * 783.99 * TAU) * 0.4 # G5
		else:
			var t_tail = t - 0.45
			s = (sin(t * 1046.5 * TAU) * 0.45 + sin(t * 1318.5 * TAU) * 0.25) * exp(-t_tail * 4.0) # C6 chord
		bytes.encode_s16(i * 2, int(clamp(s * 32767.0, -32768.0, 32767.0)))
	wav.data = bytes
	return wav

func synth_buzz() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count = int(22050 * 0.25)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = (1.0 if sin(t * 140.0 * TAU) > 0.0 else -1.0) * exp(-t * 6.0) * 0.35
		bytes.encode_s16(i * 2, int(clamp(s * 32767.0, -32768.0, 32767.0)))
	wav.data = bytes
	return wav
