extends Node
class_name VehicleAudio

# THE LONG MERIDIAN - High-Fidelity Physical Vehicle Audio Engine (Godot 4)
# Synthesizes authentic 4-stroke internal combustion pressure pulses,
# dynamic carburetor/intake induction roar, valve-train mechanical chatter,
# Garrett turbo spool whistle, tire/road friction, transmission gear shift clicks,
# and overrun deceleration backfires.

@export var vehicle: VehicleController

var engine_player: AudioStreamPlayer
var intake_player: AudioStreamPlayer
var mech_player: AudioStreamPlayer
var road_player: AudioStreamPlayer
var turbo_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var radio_player: AudioStreamPlayer

var last_gear: String = "D1"
var last_hazard_state: bool = false
var click_stream: AudioStreamWAV
var thud_stream: AudioStreamWAV
var road_joint_stream: AudioStreamWAV
var church_bell_stream: AudioStreamWAV
var current_model: String = "panda_4x4"

# Engine State (SILENT IN GARAGE)
var is_engine_running: bool = false
var starter_player: AudioStreamPlayer
var starter_stream: AudioStreamWAV
var ratchet_stream: AudioStreamWAV
var ui_click_stream: AudioStreamWAV
var cash_stream: AudioStreamWAV

# Acoustic Synthesis & Overrun Pops
var exhaust_pop_player: AudioStreamPlayer
var exhaust_pop_stream: AudioStreamWAV
var overrun_pop_timer: float = 0.0

# Turbo Blow-Off Valve (BOV / Sfiato aria compressa in rilascio)
var bov_player: AudioStreamPlayer
var bov_stream: AudioStreamWAV
var last_throttle: float = 0.0
var last_boost: float = 0.0

var cached_engine_streams: Dictionary = {}
var cached_intake_streams: Dictionary = {}
var cached_mech_streams: Dictionary = {}

# Section Volume Mixers (0.0 to 1.5, default 1.0)
var master_volume: float = 1.0
var engine_volume: float = 1.0
var ambient_volume: float = 1.0
var radio_volume: float = 1.0

# 1993 Vintage Car Radio & Custom MP3 Player
var radio_stations: Array = []
var custom_mp3_tracks: Array = []
var current_radio_idx: int = 0 # Starts with AUTORADIO SPENTA
var church_bell_timer: float = 3.0
const MP3_SEARCH_DIRS = ["res://radio", "user://radio"]
const AUDIO_CONFIG_PATH = "user://audio_settings.json"

signal audio_settings_changed(master: float, engine: float, ambient: float, radio: float)
signal radio_station_changed(station_name: String, is_playing: bool)

func _ready():
	# 1. Synthesize Audio Streams
	var road_stream = create_road_stream()
	var turbo_stream = create_turbo_stream()
	click_stream = create_click_stream()
	thud_stream = create_thud_stream()
	road_joint_stream = create_road_joint_stream()
	church_bell_stream = create_church_bell_stream()
	exhaust_pop_stream = create_exhaust_pop_stream()
	bov_stream = create_bov_stream()
	starter_stream = create_starter_stream()
	ratchet_stream = create_ratchet_stream()
	ui_click_stream = create_ui_click_stream()
	cash_stream = create_cash_stream()
	
	# 2. Layer 1: Core Combustion & Exhaust Pulse Train Player
	engine_player = AudioStreamPlayer.new()
	engine_player.volume_db = -80.0
	engine_player.autoplay = false
	add_child(engine_player)
	
	# 2b. Layer 2: Dynamic Induction & Intake Plenum Roar Player
	intake_player = AudioStreamPlayer.new()
	intake_player.volume_db = -80.0
	intake_player.autoplay = false
	add_child(intake_player)
	
	# 2c. Layer 3: Valve-Train & Camshaft Mechanical Chatter Player
	mech_player = AudioStreamPlayer.new()
	mech_player.volume_db = -80.0
	mech_player.autoplay = false
	add_child(mech_player)
	
	update_engine_stream_for_model(current_model)
	
	# Starter Motor & Garage Audio Player
	starter_player = AudioStreamPlayer.new()
	starter_player.volume_db = -6.0
	starter_player.autoplay = false
	add_child(starter_player)
	
	# Exhaust Pop / Overrun Burble Player
	exhaust_pop_player = AudioStreamPlayer.new()
	exhaust_pop_player.stream = exhaust_pop_stream
	exhaust_pop_player.volume_db = -14.0
	add_child(exhaust_pop_player)
	
	# Turbo Blow-Off Valve (BOV) Sfiato Player
	bov_player = AudioStreamPlayer.new()
	bov_player.stream = bov_stream
	bov_player.volume_db = -80.0
	bov_player.autoplay = false
	add_child(bov_player)
	
	# 3. Road & Wind Audio Player
	road_player = AudioStreamPlayer.new()
	road_player.stream = road_stream
	road_player.volume_db = -80.0
	road_player.autoplay = true
	add_child(road_player)
	
	# 4. Turbo Spool Whistle Player (Garrett T3, KKK K27, Twin-Turbo & Roots)
	turbo_player = AudioStreamPlayer.new()
	turbo_player.stream = turbo_stream
	turbo_player.volume_db = -80.0
	turbo_player.autoplay = true
	add_child(turbo_player)
	
	# 5. SFX Player for gear and relay clicks
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -8.0
	add_child(sfx_player)
	
	# 6. Carica impostazioni volumi e sistema autoradio con supporto MP3
	load_audio_settings()
	radio_player = AudioStreamPlayer.new()
	radio_player.autoplay = false
	add_child(radio_player)
	setup_radio_system()

func set_sound_profile(model_id: String):
	current_model = model_id
	update_engine_stream_for_model(model_id)

func get_engine_family_for_model(model_id: String) -> String:
	match model_id:
		"fiat_topolino":
			return "vintage_sidevalve"
		"alfa_8c":
			return "straight_8_supercharged"
		"lancia_aurelia":
			return "aurelia_v6"
		"alfa_gta":
			return "twin_cam_weber"
		"fiat_127":
			return "small_ohv"
		"fiat_131_abarth":
			return "twin_cam_16v"
		"lancia_stratos":
			return "dino_v6"
		"porsche_930_turbo":
			return "flat_6_aircooled_turbo"
		"renault_4":
			return "renault_cleon"
		"mercedes_gwagen":
			return "inline_6_m110"
		"panda_4x4":
			return "fire_1000"
		"golf_gti_1990":
			return "vw_16v_na"
		"bmw_320_e30":
			return "inline_6_m20"
		"delta_integrale":
			return "turbo_16v"
		"mercedes_a250":
			return "modern_turbo_4"
		"porsche_carrera_4s":
			return "flat_6_twinturbo_modern"
		"countach_lpi800":
			return "v12_italian_screamer"
		_:
			return "fire_1000"

func update_engine_stream_for_model(model_id: String):
	var family = get_engine_family_for_model(model_id)
	if not cached_engine_streams.has(family):
		cached_engine_streams[family] = create_engine_stream_for_family(family)
	if not cached_intake_streams.has(family):
		cached_intake_streams[family] = create_intake_stream_for_family(family)
	if not cached_mech_streams.has(family):
		cached_mech_streams[family] = create_mech_stream_for_family(family)
		
	if engine_player:
		engine_player.stream = cached_engine_streams[family]
		if is_engine_running and not engine_player.playing:
			engine_player.play()
	if intake_player:
		intake_player.stream = cached_intake_streams[family]
		if is_engine_running and not intake_player.playing:
			intake_player.play()
	if mech_player:
		mech_player.stream = cached_mech_streams[family]
		if is_engine_running and not mech_player.playing:
			mech_player.play()

func set_engine_running(running: bool):
	is_engine_running = running
	if not running:
		if engine_player:
			engine_player.stop()
			engine_player.volume_db = -80.0
		if intake_player:
			intake_player.stop()
			intake_player.volume_db = -80.0
		if mech_player:
			mech_player.stop()
			mech_player.volume_db = -80.0
		if turbo_player: turbo_player.volume_db = -80.0
		if road_player: road_player.volume_db = -80.0
	else:
		if engine_player:
			engine_player.volume_db = -12.5
			if not engine_player.playing and engine_player.stream:
				engine_player.play()
		if intake_player:
			intake_player.volume_db = -80.0
			if not intake_player.playing and intake_player.stream:
				intake_player.play()
		if mech_player:
			mech_player.volume_db = -22.0
			if not mech_player.playing and mech_player.stream:
				mech_player.play()

func play_starter_crank(on_completed: Callable = Callable()):
	if starter_player and starter_stream:
		starter_player.stream = starter_stream
		starter_player.volume_db = clamp(-6.0 + get_engine_gain_db(), -80.0, 4.0)
		starter_player.play()
		# Timer realistico: il motorino d'avviamento fa girare l'albero motore prima dell'accensione
		var t_wait = 0.65
		var timer = get_tree().create_timer(t_wait)
		timer.timeout.connect(func():
			set_engine_running(true)
			if on_completed.is_valid():
				on_completed.call()
		)
	else:
		set_engine_running(true)
		if on_completed.is_valid():
			on_completed.call()

func _process(delta: float):
	if not vehicle:
		return
		
	# SE IL VEICOLO È IN GARAGE O MOTORE SPENTO: SILENZIO ASSOLUTO! ZERO RUMORE FASTIDIOSO!
	if not is_engine_running:
		if engine_player and engine_player.playing: engine_player.stop()
		if intake_player and intake_player.playing: intake_player.stop()
		if mech_player and mech_player.playing: mech_player.stop()
		if turbo_player: turbo_player.volume_db = -80.0
		if road_player: road_player.volume_db = -80.0
		return
		
	# Riproduzione garantita quando il motore è in moto
	if engine_player and not engine_player.playing and engine_player.stream:
		engine_player.play()
	if intake_player and not intake_player.playing and intake_player.stream:
		intake_player.play()
	if mech_player and not mech_player.playing and mech_player.stream:
		mech_player.play()
		
	var rpm = vehicle.engine_rpm
	var speed = vehicle.current_speed_kmh
	var throttle = vehicle.ai_throttle if vehicle.is_ai_controlled else clamp(Input.get_action_strength("accelerate"), 0.0, 1.0)
	var boost = vehicle.current_boost_bar if ("current_boost_bar" in vehicle) else 0.0
	
	# 1. PITCH TRACKING LINEARE E ACCURATO (REF_RPM = 1200.0)
	# Supporta fino a 8700 RPM (Countach V12 -> 7.25 pitch) senza tagliare l'allungo
	var target_pitch = clamp(rpm / 1200.0, 0.40, 8.00)
	var p_lerp = delta * 18.0
	engine_player.pitch_scale = max(0.1, lerp(engine_player.pitch_scale, target_pitch, p_lerp))
	if intake_player:
		intake_player.pitch_scale = engine_player.pitch_scale
	if mech_player:
		mech_player.pitch_scale = engine_player.pitch_scale
	
	# 2. VOLUME & TIMBRICA STRATIFICATA: Calibrata con regolazione per sezioni
	var rpm_norm = clamp((rpm - 750.0) / 6500.0, 0.0, 1.0)
	var eg_db = get_engine_gain_db()
	var amb_db = get_ambient_gain_db()
	
	# Canale 1: Scarico e combustione (corposo, profondo, -13 dB al minimo fino a max -4.5 dB)
	var target_engine_vol = -13.0 + (throttle * 3.5) + (rpm_norm * 4.0) + eg_db
	if current_model == "countach_lpi800" and rpm > 5000.0:
		target_engine_vol += ((rpm - 5000.0) / 3700.0) * 3.2 # Urlo V12 ad alto regime
	engine_player.volume_db = lerp(engine_player.volume_db, clamp(target_engine_vol, -80.0, -1.0), delta * 14.0)
	
	# Canale 2: Ruggito di aspirazione / carburatori / tromboncini Weber (silenzioso a filo, tuono a pieno carico)
	if intake_player:
		var target_intake_vol = -80.0
		if throttle > 0.04:
			var intake_power = (throttle - 0.04) / 0.96
			target_intake_vol = -24.0 + (intake_power * 13.5) + (rpm_norm * 3.8) + eg_db
		intake_player.volume_db = lerp(intake_player.volume_db, clamp(target_intake_vol, -80.0, 0.0), delta * 16.0)
		
	# Canale 3: Ticchettio meccanico punterie / distribuzione / ventola magnesio
	if mech_player:
		var target_mech_vol = -24.0 + (rpm_norm * 5.0) + (1.5 if throttle < 0.2 else 0.0) + eg_db
		if current_model == "porsche_930_turbo":
			# Ventola posteriore assiale a 11 pale in magnesio
			target_mech_vol += 4.0 + (rpm_norm * 3.5)
		mech_player.volume_db = lerp(mech_player.volume_db, clamp(target_mech_vol, -80.0, -2.0), delta * 10.0)
	
	# Blow-Off Valve (BOV / Dump Valve): Sfiato dell'aria compressa in rilascio acceleratore
	if bov_player and (current_model in ["delta_integrale", "porsche_930_turbo", "porsche_carrera_4s", "mercedes_a250"]):
		if last_boost > 0.22 and throttle < 0.12 and (last_throttle - throttle) > 0.28:
			play_blow_off_valve(last_boost)
			
	last_throttle = throttle
	last_boost = boost
	
	# Scoppiettii e borbottii allo scarico in rilascio dell'acceleratore (Overrun deceleration burble/pops)
	if throttle < 0.08 and rpm > 2100.0 and speed > 12.0:
		overrun_pop_timer -= delta
		if overrun_pop_timer <= 0.0:
			var pop_min = 0.20
			var pop_max = 0.52
			if current_model in ["porsche_930_turbo", "delta_integrale", "alfa_gta"]:
				pop_min = 0.12
				pop_max = 0.32
			overrun_pop_timer = randf_range(pop_min, pop_max)
			play_exhaust_pop()
	else:
		overrun_pop_timer = 0.12
	
	# 2. Turbo Spool & Supercharger Whistle (Garrett, KKK K27, Twin-Turbo, Twin-Roots, BlueDirect)
	if (current_model in ["delta_integrale", "porsche_930_turbo", "porsche_carrera_4s", "mercedes_a250", "alfa_8c"]) and boost > 0.04:
		var max_b = 1.45
		if current_model == "porsche_930_turbo": max_b = 0.85
		elif current_model == "porsche_carrera_4s": max_b = 1.25
		elif current_model == "mercedes_a250": max_b = 1.20
		elif current_model == "alfa_8c": max_b = 0.65
		
		var b_norm = clamp(boost / max_b, 0.0, 1.0)
		var turbo_vol = -36.0 + (b_norm * 27.0) + eg_db
		turbo_player.volume_db = lerp(turbo_player.volume_db, clamp(turbo_vol, -80.0, 0.0), delta * 12.0)
		
		var p_scale = 1.0
		if current_model == "alfa_8c":
			p_scale = lerp(0.85, 2.2, clamp(rpm / 5400.0, 0.0, 1.2)) # Whine volumetrico Roots da giri
		else:
			p_scale = lerp(1.0, 2.6, b_norm) # Fischio turbina da boost
		turbo_player.pitch_scale = max(0.1, p_scale)
	else:
		turbo_player.volume_db = lerp(turbo_player.volume_db, -80.0, delta * 8.0)
	
	# 3. Road surface & wind rushing audio (bilanciato per non coprire il motore)
	if speed > 2.0:
		var road_vol = -50.0 + clamp(speed / 150.0, 0.0, 1.0) * 32.0 + amb_db
		road_player.volume_db = lerp(road_player.volume_db, clamp(road_vol, -80.0, 0.0), delta * 8.0)
		road_player.pitch_scale = max(0.1, lerp(0.8, 1.4, clamp(speed / 130.0, 0.0, 1.0)))
	else:
		road_player.volume_db = lerp(road_player.volume_db, -80.0, delta * 8.0)
		
	# 4. Gear shift mechanical click
	if vehicle.gear_name != last_gear:
		last_gear = vehicle.gear_name
		play_click(1.15)
		
	# 5. Hazard flasher relay click
	if vehicle.hazard_state != last_hazard_state:
		last_hazard_state = vehicle.hazard_state
		play_click(0.85 if vehicle.hazard_state else 0.75)
		
	# 6. Borgo San Cristoforo Church Bell Acoustic Tolls (Z in [840, 1080])
	var pz = vehicle.global_position.z
	if pz >= 840.0 and pz <= 1080.0:
		church_bell_timer -= delta
		if church_bell_timer <= 0.0:
			church_bell_timer = 18.0
			play_church_bells()
	else:
		church_bell_timer = 2.5

func play_click(pitch: float):
	if sfx_player and is_inside_tree() and click_stream:
		sfx_player.stream = click_stream
		sfx_player.pitch_scale = pitch
		sfx_player.volume_db = clamp(-10.0 + get_ambient_gain_db(), -80.0, 0.0)
		sfx_player.play()

func play_exhaust_pop():
	if exhaust_pop_player and is_inside_tree() and exhaust_pop_stream:
		exhaust_pop_player.pitch_scale = randf_range(0.85, 1.35)
		exhaust_pop_player.volume_db = clamp(randf_range(-16.0, -10.0) + get_engine_gain_db(), -80.0, 0.0)
		exhaust_pop_player.play()

func play_blow_off_valve(boost_pressure: float):
	if bov_player and is_inside_tree() and bov_stream:
		bov_player.pitch_scale = randf_range(0.92, 1.15)
		var vol = -18.0 + clamp(boost_pressure / 1.45, 0.0, 1.0) * 12.0 + get_engine_gain_db()
		bov_player.volume_db = clamp(vol, -80.0, 2.0)
		bov_player.play()

func create_bov_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.28) # 280ms
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	var noise_flt = 0.0
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var env = exp(-t * 14.0)
		# Flutter della valvola a fungo con sfiato d'aria in pressione (tshhh-t-t-t)
		var flutter = 1.0 + 0.45 * sin(t * 55.0 * TAU)
		var white = randf_range(-1.0, 1.0)
		noise_flt = lerp(noise_flt, white, 0.22)
		var s = noise_flt * env * flutter * 0.75
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_exhaust_pop_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 44100
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(44100 * 0.18) # 180ms
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 44100.0
		var env = exp(-t * 32.0)
		var thump_f = max(32.0, 68.0 - t * 240.0)
		var thump = sin(t * thump_f * TAU) * 0.55
		var crack = randf_range(-1.0, 1.0) * 0.42 * exp(-t * 55.0)
		var ping = sin(t * 340.0 * TAU) * exp(-t * 70.0) * 0.25
		var s = (thump + crack + ping) * env * 0.78
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_engine_stream() -> AudioStreamWAV:
	return create_engine_stream_for_family("fire_1000")

func create_engine_stream_for_family(family: String) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 44100
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = 44100
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var raw_samples = PackedFloat32Array()
	raw_samples.resize(sample_count)
	
	# Frequenze fondamentali di scoppio fisiche a 1200 RPM (4 tempi):
	# 4 cilindri: (1200 / 60) * 2 = 40.0 Hz
	# 6 cilindri: (1200 / 60) * 3 = 60.0 Hz
	# 8 cilindri: (1200 / 60) * 4 = 80.0 Hz
	# 12 cilindri: (1200 / 60) * 6 = 120.0 Hz
	var f_fire = 40.0
	var h1 = 0.58
	var h2 = 0.36
	var h3 = 0.20
	var h4 = 0.12
	var h5 = 0.00
	var h6 = 0.06
	var h8 = 0.00
	var h10 = 0.00
	var h12 = 0.00
	var cam_sub = 0.10
	var drive = 1.7
	var gain = 0.76
	var is_dino = false
	var is_boxer = false
	var is_v12 = false
	
	match family:
		"vintage_sidevalve": # Fiat 500A Topolino 569cc valvole laterali (1936)
			f_fire = 40.0
			h1 = 0.68 # 1a armonica dominante: chug morbido e rotondo da bassa compressione (6.5:1)
			h2 = 0.28
			h3 = 0.08
			h4 = 0.04
			h5 = 0.00
			h6 = 0.00
			h8 = 0.00
			cam_sub = 0.06
			drive = 1.35 # Compressione dolce senza asperità
			gain = 0.74
			
		"straight_8_supercharged": # Alfa Romeo 8C 2900B 2.9L 8L DOHC Twin-Roots (1938)
			f_fire = 80.0 # 4 impulsi/giro = 80 Hz a 1200 RPM!
			h1 = 0.54
			h2 = 0.34
			h3 = 0.16
			h4 = 0.24 # Doppia ottava da 8 cilindri
			h5 = 0.06
			h6 = 0.12
			h8 = 0.10
			cam_sub = 0.05
			drive = 2.05
			gain = 0.76
			
		"aurelia_v6": # Lancia Aurelia B20 GT 2.5L V6 60° De Virgilio (1953)
			f_fire = 60.0
			h1 = 0.56
			h2 = 0.32
			h3 = 0.30 # Timbro baritonale nobile ed equilibrato
			h4 = 0.16
			h5 = 0.05
			h6 = 0.14
			h8 = 0.04
			cam_sub = 0.04
			drive = 1.80
			gain = 0.75
			
		"twin_cam_weber": # Alfa Romeo GTA 1.6L Bialbero Twin Spark 2x Weber 45 DCOE (1965)
			f_fire = 40.0
			h1 = 0.42
			h2 = 0.48 # 2a armonica feroce da cornetti aperti
			h3 = 0.32
			h4 = 0.28
			h5 = 0.14
			h6 = 0.20
			h8 = 0.10
			cam_sub = 0.22 # Camme spinte da corsa: minimo irregolare da competizione
			drive = 2.50
			gain = 0.79
			
		"small_ohv": # Fiat 127 Special 903cc Serie 100 Aste e Bilancieri (1974)
			f_fire = 40.0
			h1 = 0.46
			h2 = 0.32
			h3 = 0.36 # 3a armonica: rasp italiano vivace e squillante
			h4 = 0.18
			h5 = 0.24 # 5a armonica: squillo metallico punterie
			h6 = 0.08
			h8 = 0.04
			cam_sub = 0.12
			drive = 2.15
			gain = 0.77
			
		"twin_cam_16v": # Fiat 131 Abarth Rally 2.0L 16V Lampredi (1976)
			f_fire = 40.0
			h1 = 0.50
			h2 = 0.44
			h3 = 0.24
			h4 = 0.34 # 4a armonica: testata 16 valvole ad alto flusso
			h5 = 0.08
			h6 = 0.16
			h8 = 0.06
			cam_sub = 0.15
			drive = 2.30
			gain = 0.78
			
		"dino_v6": # Lancia Stratos HF 2.4L Ferrari Dino V6 65° (1974)
			f_fire = 60.0
			h1 = 0.38
			h2 = 0.36
			h3 = 0.38
			h4 = 0.24
			h5 = 0.18
			h6 = 0.26
			h8 = 0.10
			cam_sub = 0.10
			drive = 2.50
			gain = 0.79
			is_dino = true # Fasatura asimmetrica perni manovella 55°/65°
			
		"flat_6_aircooled_turbo": # Porsche 911 Turbo 3.0 (930) Boxer-6 aria + KKK K27 (1975)
			f_fire = 60.0
			h1 = 0.62 # Basso profondo gutturale con contropressione turbo
			h2 = 0.44
			h3 = 0.22
			h4 = 0.20
			h5 = 0.06
			h6 = 0.16
			h8 = 0.06
			cam_sub = 0.12
			drive = 2.20
			gain = 0.78
			is_boxer = true # Interferenza bancate contrapposte 180°
			
		"renault_cleon": # Renault 4 GTL 1.1L Cléon-Fonte OHV (1980)
			f_fire = 40.0
			h1 = 0.58
			h2 = 0.34
			h3 = 0.18
			h4 = 0.12
			h5 = 0.04
			h6 = 0.06
			h8 = 0.00
			cam_sub = 0.08
			drive = 1.60
			gain = 0.75
			
		"inline_6_m110": # Mercedes G-Klasse W460 2.8L M110 DOHC (1979)
			f_fire = 60.0
			h1 = 0.58 # Rombo profondo e massiccio da fuoristrada
			h2 = 0.32
			h3 = 0.28
			h4 = 0.18
			h5 = 0.04
			h6 = 0.14
			h8 = 0.06
			cam_sub = 0.05
			drive = 1.80
			gain = 0.76
			
		"fire_1000": # Fiat Panda 4x4 FIRE 1000 SOHC (1983)
			f_fire = 40.0
			h1 = 0.58
			h2 = 0.36
			h3 = 0.20
			h4 = 0.12
			h5 = 0.00
			h6 = 0.06
			h8 = 0.00
			cam_sub = 0.10
			drive = 1.70
			gain = 0.76
			
		"vw_16v_na": # Volkswagen Golf GTI 16V Mk2 1.8L DOHC KR K-Jetronic (1990)
			f_fire = 40.0
			h1 = 0.48
			h2 = 0.42
			h3 = 0.26
			h4 = 0.32 # Precisione tagliente 16 valvole aspirata
			h5 = 0.08
			h6 = 0.16
			h8 = 0.06
			cam_sub = 0.08
			drive = 2.10
			gain = 0.77
			
		"inline_6_m20": # BMW 320i E30 2.0L M20 6 cilindri (1990)
			f_fire = 60.0
			h1 = 0.50
			h2 = 0.22
			h3 = 0.44 # Urlo a turbina setoso bavarese
			h4 = 0.14
			h5 = 0.00
			h6 = 0.28 # 6a armonica vellutata
			h8 = 0.08
			cam_sub = 0.02 # Equilibratura perfetta a 6 cilindri
			drive = 1.60
			gain = 0.74
			
		"turbo_16v": # Lancia Delta HF Integrale Evo 2.0L 16V Turbo Garrett T3 (1991)
			f_fire = 40.0
			h1 = 0.66 # Ruggito possente e cupo con risonanza scarico rally
			h2 = 0.42
			h3 = 0.18
			h4 = 0.18
			h5 = 0.00
			h6 = 0.08
			h8 = 0.04
			cam_sub = 0.14
			drive = 2.00
			gain = 0.78
			
		"modern_turbo_4": # Mercedes A 250 Sport 2.0L Turbo BlueDIRECT DI (2016)
			f_fire = 40.0
			h1 = 0.56
			h2 = 0.38
			h3 = 0.20
			h4 = 0.16
			h5 = 0.04
			h6 = 0.10
			h8 = 0.04
			cam_sub = 0.06
			drive = 1.85
			gain = 0.76
			
		"flat_6_twinturbo_modern": # Porsche 911 Carrera 4S (992) 3.0L Boxer-6 Biturbo 24V (2020)
			f_fire = 60.0
			h1 = 0.56
			h2 = 0.40
			h3 = 0.26
			h4 = 0.22
			h5 = 0.04
			h6 = 0.18
			h8 = 0.06
			cam_sub = 0.04
			drive = 2.00
			gain = 0.77
			is_boxer = true
			
		"v12_italian_screamer": # Lamborghini Countach LPI 800-4 6.5L V12 Aspirato 60° (2021)
			f_fire = 120.0 # 12 CILINDRI: 6 scoppi/giro = 120 Hz a 1200 RPM!
			h1 = 0.42
			h2 = 0.38
			h3 = 0.32
			h4 = 0.26
			h5 = 0.16
			h6 = 0.30
			h8 = 0.18
			h10 = 0.14
			h12 = 0.12 # Armonica 1440 Hz a 1200 RPM -> Urlo da F1 ad alto regime (8700 RPM)!
			cam_sub = 0.03
			drive = 2.45
			gain = 0.79
			is_v12 = true

	for i in range(sample_count):
		var t = float(i) / 44100.0
		var phase = t * f_fire * TAU
		
		var s = 0.0
		if is_dino:
			# Accensione asimmetrica 55°/65° alternata
			s = sin(phase) * h1
			s += sin(phase * 1.0833) * 0.24
			s += sin(phase * 2.0) * h2
			s += sin(phase * 3.0) * h3
			s += sin(phase * 4.0) * h4
			s += sin(phase * 6.0) * h6
		elif is_boxer:
			# Flat-6: interferenza delle due bancate orizzontali contrapposte
			s = sin(phase) * h1
			s += sin(phase * 2.0) * h2
			s += sin(phase * 3.0) * h3
			s += sin(phase * 4.0) * h4
			if h5 > 0.0: s += sin(phase * 5.0) * h5
			if h6 > 0.0: s += sin(phase * 6.0) * h6
			if h8 > 0.0: s += sin(phase * 8.0) * h8
			# Sub-battito sincopato tipico Porsche Flat-6
			s += sin(phase * 0.5) * 0.15
		elif is_v12:
			# V12 Aspirato ad altissima frequenza armonica
			s = sin(phase) * h1
			s += sin(phase * 2.0) * h2
			s += sin(phase * 3.0) * h3
			s += sin(phase * 4.0) * h4
			s += sin(phase * 5.0) * h5
			s += sin(phase * 6.0) * h6
			s += sin(phase * 8.0) * h8
			s += sin(phase * 10.0) * h10
			s += sin(phase * 12.0) * h12
		else:
			s = sin(phase) * h1
			s += sin(phase * 2.0) * h2
			s += sin(phase * 3.0) * h3
			s += sin(phase * 4.0) * h4
			if h5 > 0.0: s += sin(phase * 5.0) * h5
			if h6 > 0.0: s += sin(phase * 6.0) * h6
			if h8 > 0.0: s += sin(phase * 8.0) * h8
			
		# Modulazione dell'albero a camme (10 Hz a 1200 RPM) per il borbottio vitale
		var cam_phase = t * 10.0 * TAU
		s += sin(cam_phase) * cam_sub
		s += sin(cam_phase * 2.0) * (cam_sub * 0.5)
		
		# Saturazione calda analogica (headroom calibrata a circa -2.4 dBFS)
		s = tanh(s * drive) * gain
		raw_samples[i] = s
		
	# Zero-crossing soft crossfade sugli ultimi 64 campioni
	var s0 = raw_samples[0]
	for k in range(64):
		var idx = sample_count - 64 + k
		var alpha = float(k + 1) / 64.0
		raw_samples[idx] = lerp(raw_samples[idx], s0, alpha * alpha)
		
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var sample_16 = int(clamp(raw_samples[i] * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_intake_stream_for_family(family: String) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 44100
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = 44100
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var raw_samples = PackedFloat32Array()
	raw_samples.resize(sample_count)
	
	var f_fire = 40.0
	var throat_boost = 1.0
	var air_mix = 0.25
	
	match family:
		"v12_italian_screamer":
			f_fire = 120.0
			throat_boost = 1.65
			air_mix = 0.35
		"twin_cam_weber":
			f_fire = 40.0
			throat_boost = 1.60
			air_mix = 0.30
		"dino_v6":
			f_fire = 60.0
			throat_boost = 1.45
			air_mix = 0.30
		"flat_6_aircooled_turbo":
			f_fire = 60.0
			throat_boost = 1.35
			air_mix = 0.25
		"flat_6_twinturbo_modern":
			f_fire = 60.0
			throat_boost = 1.25
			air_mix = 0.22
		"twin_cam_16v":
			f_fire = 40.0
			throat_boost = 1.30
			air_mix = 0.26
		"vw_16v_na":
			f_fire = 40.0
			throat_boost = 1.25
			air_mix = 0.25
		"straight_8_supercharged":
			f_fire = 80.0
			throat_boost = 1.30
			air_mix = 0.28
		"small_ohv":
			f_fire = 40.0
			throat_boost = 1.15
			air_mix = 0.20
		"aurelia_v6":
			f_fire = 60.0
			throat_boost = 1.10
			air_mix = 0.22
		"inline_6_m20":
			f_fire = 60.0
			throat_boost = 0.95
			air_mix = 0.20
		"inline_6_m110":
			f_fire = 60.0
			throat_boost = 1.05
			air_mix = 0.25
		"turbo_16v":
			f_fire = 40.0
			throat_boost = 1.20
			air_mix = 0.28
		"modern_turbo_4":
			f_fire = 40.0
			throat_boost = 1.05
			air_mix = 0.22
		"vintage_sidevalve":
			f_fire = 40.0
			throat_boost = 0.85
			air_mix = 0.15
		"renault_cleon":
			f_fire = 40.0
			throat_boost = 0.90
			air_mix = 0.18
		"fire_1000":
			f_fire = 40.0
			throat_boost = 1.00
			air_mix = 0.22
			
	var air_filter = 0.0
	for i in range(sample_count):
		var t = float(i) / 44100.0
		var phase = t * f_fire * TAU
		
		# Fruscio d'aspirazione dell'aria nei condotti
		var white = randf_range(-1.0, 1.0)
		air_filter = lerp(air_filter, white, 0.06)
		
		# Risonanza Helmholtz in fase perfetta con la fondamentale dello scarico
		var gulp = (sin(phase) * 0.50 + sin(phase * 2.0) * 0.35 + sin(phase * 3.0) * 0.15) * throat_boost
		var s = (gulp * 0.70 + air_filter * air_mix) * 0.68
		s = tanh(s * 1.6) * 0.72
		raw_samples[i] = s
		
	var s0 = raw_samples[0]
	for k in range(64):
		var idx = sample_count - 64 + k
		var alpha = float(k + 1) / 64.0
		raw_samples[idx] = lerp(raw_samples[idx], s0, alpha * alpha)
		
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var sample_16 = int(clamp(raw_samples[i] * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_mech_stream_for_family(family: String) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 44100
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = 44100
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var raw_samples = PackedFloat32Array()
	raw_samples.resize(sample_count)
	
	var num_events = 4
	var click_bright = 3200.0
	var click_decay = 65.0
	var is_aircooled_fan = false
	var is_supercharger_whine = false
	var is_v12_chatter = false
	
	match family:
		"v12_italian_screamer":
			num_events = 12 # 48 valvole e distribuzione densa
			click_bright = 4200.0
			click_decay = 80.0
			is_v12_chatter = true
		"straight_8_supercharged":
			num_events = 8
			click_bright = 2800.0
			click_decay = 60.0
			is_supercharger_whine = true # Fischio ingranaggi lobi Roots
		"flat_6_aircooled_turbo":
			num_events = 6
			click_bright = 3100.0
			click_decay = 65.0
			is_aircooled_fan = true # Ululato turbina ventola assiale magnesio
		"flat_6_twinturbo_modern", "inline_6_m20", "inline_6_m110", "dino_v6", "aurelia_v6":
			num_events = 6
			click_bright = 3300.0
			click_decay = 70.0
		"small_ohv":
			num_events = 4
			click_bright = 3800.0 # Tintinnio punterie aste e bilancieri Fiat 127
			click_decay = 55.0
		"vintage_sidevalve":
			num_events = 4
			click_bright = 2000.0 # Valvole laterali morbide Topolino
			click_decay = 90.0
		_:
			num_events = 4
			click_bright = 3200.0
			click_decay = 65.0
		
	for i in range(sample_count):
		var t = float(i) / 44100.0
		var u = fmod(t * 10.0 * float(num_events), 1.0)
		# Micro-click impulsivo ad altissimo decadimento per le punterie
		var click = sin(u * click_bright / 441.0 * TAU) * exp(-u * click_decay) * 0.40
		
		# Aggiunte timbriche caratteristiche storiche/architetturali
		if is_aircooled_fan:
			# Sibilo ventola assiale in magnesio a 11 pale Porsche 930
			var fan_whine = sin(t * 185.0 * TAU) * 0.24 + sin(t * 370.0 * TAU) * 0.10
			var fan_air = randf_range(-1.0, 1.0) * 0.08
			click = click * 0.60 + fan_whine + fan_air
		elif is_supercharger_whine:
			# Whine ingranaggi lobi Roots Alfa 8C (720 Hz)
			var roots_whine = sin(t * 720.0 * TAU) * 0.22 + sin(t * 1440.0 * TAU) * 0.08
			click = click * 0.65 + roots_whine
		elif is_v12_chatter:
			# Vibrazione fittissima a catena e bicchierini idraulici V12
			var v12_gear = sin(t * 240.0 * TAU) * 0.18 + sin(t * 480.0 * TAU) * 0.10
			click = click * 0.70 + v12_gear
			
		raw_samples[i] = clamp(click * 0.50, -0.65, 0.65)
		
	var s0 = raw_samples[0]
	for k in range(64):
		var idx = sample_count - 64 + k
		var alpha = float(k + 1) / 64.0
		raw_samples[idx] = lerp(raw_samples[idx], s0, alpha * alpha)
		
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var sample_16 = int(clamp(raw_samples[i] * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_turbo_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = 22050
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	var turbo_freq = 960.0
	var air_hiss = 0.0
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = sin(t * turbo_freq * TAU) * 0.32
		s += sin(t * turbo_freq * 2.0 * TAU) * 0.16
		s += sin(t * turbo_freq * 3.0 * TAU) * 0.06
		var white = randf_range(-1.0, 1.0)
		air_hiss = lerp(air_hiss, white, 0.12)
		s += air_hiss * 0.10
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_road_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = 22050
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	var filter_val = 0.0
	for i in range(sample_count):
		var white = randf_range(-1.0, 1.0)
		filter_val = lerp(filter_val, white, 0.08)
		var s = filter_val * 0.45
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_click_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = 1100
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / float(sample_count)
		var decay = exp(-t * 24.0)
		var s = sin(float(i) * 0.4) * decay * 0.6
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_chime_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.75) # 0.75 seconds
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = 0.0
		if t < 0.22:
			var env = exp(-t * 8.0)
			s = sin(t * 523.25 * TAU) * env * 0.45 # C5
		else:
			var t2 = t - 0.22
			var env2 = exp(-t2 * 6.0)
			s = (sin(t * 659.25 * TAU) * 0.40 + sin(t * 783.99 * TAU) * 0.25) * env2 # E5 + G5 chord
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func play_milestone_chime():
	var chime = create_chime_stream()
	var p = AudioStreamPlayer.new()
	p.stream = chime
	p.volume_db = -6.0
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func create_thud_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.18)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var env = exp(-t * 22.0)
		# Basso tonfo ammortizzatore fine corsa (70Hz transiente con componente rumorosa)
		var freq = 75.0 - t * 180.0
		var s = sin(t * max(30.0, freq) * TAU) * env * 0.65
		s += (randf() * 2.0 - 1.0) * env * 0.18
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_road_joint_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.09) # 90ms subtle tire tar seam thump
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var env = exp(-t * 42.0)
		var s = sin(t * 95.0 * TAU) * env * 0.40
		s += (randf() * 2.0 - 1.0) * env * 0.10
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func play_suspension_thud():
	if not thud_stream:
		thud_stream = create_thud_stream()
	var p = AudioStreamPlayer.new()
	p.stream = thud_stream
	p.volume_db = clamp(-4.0 + get_ambient_gain_db(), -80.0, 4.0)
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func play_road_joint_click():
	if not road_joint_stream:
		road_joint_stream = create_road_joint_stream()
	var p = AudioStreamPlayer.new()
	p.stream = road_joint_stream
	p.volume_db = clamp(-9.0 + get_ambient_gain_db(), -80.0, 4.0)
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func play_horn():
	var p = AudioStreamPlayer.new()
	p.stream = create_italian_horn_stream()
	p.volume_db = clamp(-4.0 + get_ambient_gain_db(), -80.0, 4.0)
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func play_impact_thud():
	if not thud_stream:
		thud_stream = create_thud_stream()
	var p = AudioStreamPlayer.new()
	p.stream = thud_stream
	p.pitch_scale = 0.75
	p.volume_db = clamp(0.0 + get_ambient_gain_db(), -80.0, 6.0)
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

# ==============================================================================
# 1993 CAR RADIO CONTROLS & DYNAMIC MP3 AUDIO STREAMING
# ==============================================================================
func setup_radio_system():
	ensure_user_radio_folder()
	scan_and_load_mp3_tracks()
	build_radio_stations_list()

func ensure_user_radio_folder():
	if not DirAccess.dir_exists_absolute("user://radio"):
		DirAccess.make_dir_recursive_absolute("user://radio")
	if not DirAccess.dir_exists_absolute("res://radio"):
		DirAccess.make_dir_recursive_absolute("res://radio")
	var readme_path = "user://radio/COME_INSERIRE_I_BRANI_MP3.txt"
	if not FileAccess.file_exists(readme_path):
		var f = FileAccess.open(readme_path, FileAccess.WRITE)
		if f:
			f.store_string("=== AUTORADIO VINTAGE '93 - GUIDA AI FILE MP3 ===\r\n\r\n" +
				"Inserisci in questa cartella i tuoi file audio preferiti con estensione .mp3.\r\n" +
				"Verranno caricati automaticamente dall'autoradio nel gioco!\r\n" +
				"Comandi in gioco:\r\n" +
				"  - Premi [R] durante la guida per cambiare traccia/stazione\r\n" +
				"  - Premi [V] per aprire il MIXER AUDIO e bilanciare:\r\n" +
				"      * Suono Motore\r\n" +
				"      * Suoni Ambientali\r\n" +
				"      * Volume Radio\r\n" +
				"      * Volume Generale (Master)\r\n" +
				"  - Nel pannello [V] puoi anche cliccare 'Ricarica MP3' senza riavviare il gioco!\r\n")
			f.close()

func load_mp3_file(path: String) -> AudioStreamMP3:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	var bytes = file.get_buffer(file.get_length())
	file.close()
	if bytes.is_empty():
		return null
	var stream = AudioStreamMP3.new()
	stream.data = bytes
	stream.loop = true
	return stream

func scan_and_load_mp3_tracks():
	custom_mp3_tracks.clear()
	for dir_path in MP3_SEARCH_DIRS:
		if DirAccess.dir_exists_absolute(dir_path):
			var dir = DirAccess.open(dir_path)
			if dir:
				dir.list_dir_begin()
				var f_name = dir.get_next()
				while f_name != "":
					if not dir.current_is_dir() and f_name.to_lower().ends_with(".mp3"):
						var full_p = dir_path.path_join(f_name)
						var s = load_mp3_file(full_p)
						if s:
							var clean_title = f_name.get_basename().replace("_", " ")
							custom_mp3_tracks.append({
								"name": clean_title,
								"freq": "MP3",
								"stream": s,
								"vol": -11.0,
								"path": full_p,
								"is_mp3": true
							})
							print("[Autoradio '93] 🎵 Caricato brano MP3: ", clean_title)
					f_name = dir.get_next()
				dir.list_dir_end()
	print("[Autoradio '93] Scansione completata: %d brani MP3 disponibili." % custom_mp3_tracks.size())

func build_radio_stations_list():
	radio_stations.clear()
	
	# 1. Spenta sempre al primo posto (Indice 0)
	radio_stations.append({
		"name": "AUTORADIO SPENTA",
		"freq": "---",
		"stream": null,
		"vol": -80.0,
		"is_mp3": false
	})
	
	# 2. File MP3 personalizzati
	for mp3 in custom_mp3_tracks:
		radio_stations.append(mp3)
		
	# 3. Canali vintage FM/AM procedurali anni '90 (sempre disponibili)
	radio_stations.append({
		"name": "Radio Valico FM",
		"freq": "104.2 MHz",
		"stream": synth_radio_valico_stream(),
		"vol": -14.0,
		"is_mp3": false
	})
	radio_stations.append({
		"name": "Onda Verde Alpino",
		"freq": "98.5 MHz",
		"stream": synth_onda_verde_stream(),
		"vol": -15.0,
		"is_mp3": false
	})
	radio_stations.append({
		"name": "Radio Monte Rosa",
		"freq": "89.0 MHz",
		"stream": synth_monte_rosa_stream(),
		"vol": -16.0,
		"is_mp3": false
	})
	
	if current_radio_idx >= radio_stations.size():
		current_radio_idx = 0
	if radio_player:
		apply_radio_station()

func apply_radio_station():
	if radio_stations.is_empty():
		if radio_player:
			radio_player.volume_db = -80.0
			radio_player.stop()
		emit_signal("radio_station_changed", "AUTORADIO SPENTA (---)", false)
		return
		
	var st = radio_stations[current_radio_idx]
	if radio_player:
		if st.stream != null:
			radio_player.stream = st.stream
			var rad_db = get_radio_gain_db()
			radio_player.volume_db = clamp(st.vol + rad_db, -80.0, 4.0)
			if not radio_player.playing and radio_player.is_inside_tree():
				radio_player.play()
			emit_signal("radio_station_changed", "%s (%s)" % [st.name, st.freq], true)
		else:
			radio_player.volume_db = -80.0
			radio_player.stop()
			emit_signal("radio_station_changed", "AUTORADIO SPENTA (---)", false)

func apply_radio_volume():
	if radio_player and not radio_stations.is_empty():
		var st = radio_stations[current_radio_idx]
		if st.stream != null and radio_player.playing:
			var rad_db = get_radio_gain_db()
			radio_player.volume_db = clamp(st.vol + rad_db, -80.0, 4.0)

func cycle_radio_station() -> String:
	if radio_stations.is_empty():
		return "AUTORADIO SPENTA (---)"
	current_radio_idx = (current_radio_idx + 1) % radio_stations.size()
	play_click(1.4)
	apply_radio_station()
	return get_current_radio_name()

func prev_radio_station() -> String:
	if radio_stations.is_empty():
		return "AUTORADIO SPENTA (---)"
	current_radio_idx = (current_radio_idx - 1 + radio_stations.size()) % radio_stations.size()
	play_click(1.2)
	apply_radio_station()
	return get_current_radio_name()

func toggle_radio_power() -> String:
	if current_radio_idx == 0:
		if radio_stations.size() > 1:
			current_radio_idx = 1
	else:
		current_radio_idx = 0
	play_click(1.1)
	apply_radio_station()
	return get_current_radio_name()

func select_radio_station(idx: int) -> String:
	if idx >= 0 and idx < radio_stations.size():
		current_radio_idx = idx
		apply_radio_station()
	return get_current_radio_name()

func get_current_radio_name() -> String:
	if radio_stations.is_empty():
		return "AUTORADIO SPENTA (---)"
	var st = radio_stations[current_radio_idx]
	return "%s (%s)" % [st.name, st.freq]

func is_radio_playing() -> bool:
	return current_radio_idx > 0 and (radio_player != null and (radio_player.playing or not radio_player.is_inside_tree()))

func get_custom_mp3_count() -> int:
	return custom_mp3_tracks.size()

func open_user_radio_folder():
	ensure_user_radio_folder()
	var global_path = ProjectSettings.globalize_path("user://radio")
	OS.shell_open(global_path)

# ==============================================================================
# SECTION VOLUME CONTROL & PERSISTENCE
# ==============================================================================
func get_master_gain_db() -> float:
	return linear_to_db(clamp(master_volume, 0.0001, 2.0)) if master_volume > 0.001 else -80.0

func get_engine_gain_db() -> float:
	var tot = master_volume * engine_volume
	return linear_to_db(clamp(tot, 0.0001, 2.0)) if tot > 0.001 else -80.0

func get_ambient_gain_db() -> float:
	var tot = master_volume * ambient_volume
	return linear_to_db(clamp(tot, 0.0001, 2.0)) if tot > 0.001 else -80.0

func get_radio_gain_db() -> float:
	var tot = master_volume * radio_volume
	return linear_to_db(clamp(tot, 0.0001, 2.0)) if tot > 0.001 else -80.0

func set_master_volume(val: float):
	master_volume = clamp(val, 0.0, 1.5)
	apply_radio_volume()
	save_audio_settings()
	emit_signal("audio_settings_changed", master_volume, engine_volume, ambient_volume, radio_volume)

func set_engine_volume(val: float):
	engine_volume = clamp(val, 0.0, 1.5)
	save_audio_settings()
	emit_signal("audio_settings_changed", master_volume, engine_volume, ambient_volume, radio_volume)

func set_ambient_volume(val: float):
	ambient_volume = clamp(val, 0.0, 1.5)
	save_audio_settings()
	emit_signal("audio_settings_changed", master_volume, engine_volume, ambient_volume, radio_volume)

func set_radio_volume(val: float):
	radio_volume = clamp(val, 0.0, 1.5)
	apply_radio_volume()
	save_audio_settings()
	emit_signal("audio_settings_changed", master_volume, engine_volume, ambient_volume, radio_volume)

func get_master_volume() -> float:
	return master_volume

func get_engine_volume() -> float:
	return engine_volume

func get_ambient_volume() -> float:
	return ambient_volume

func get_radio_volume() -> float:
	return radio_volume

func save_audio_settings():
	var data = {
		"master_volume": master_volume,
		"engine_volume": engine_volume,
		"ambient_volume": ambient_volume,
		"radio_volume": radio_volume
	}
	var f = FileAccess.open(AUDIO_CONFIG_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_audio_settings():
	if FileAccess.file_exists(AUDIO_CONFIG_PATH):
		var f = FileAccess.open(AUDIO_CONFIG_PATH, FileAccess.READ)
		if f:
			var txt = f.get_as_text()
			f.close()
			var json = JSON.new()
			if json.parse(txt) == OK and typeof(json.data) == TYPE_DICTIONARY:
				master_volume = clamp(float(json.data.get("master_volume", 1.0)), 0.0, 1.5)
				engine_volume = clamp(float(json.data.get("engine_volume", 1.0)), 0.0, 1.5)
				ambient_volume = clamp(float(json.data.get("ambient_volume", 1.0)), 0.0, 1.5)
				radio_volume = clamp(float(json.data.get("radio_volume", 1.0)), 0.0, 1.5)

func play_church_bells():
	if not church_bell_stream:
		church_bell_stream = create_church_bell_stream()
	var p = AudioStreamPlayer.new()
	p.stream = church_bell_stream
	p.volume_db = clamp(-10.0 + get_ambient_gain_db(), -80.0, 4.0)
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func create_italian_horn_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.42) # 420ms beep-beep
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var env = 1.0 if t < 0.35 else exp(-(t - 0.35) * 20.0)
		# Dual-tone classic Fiamm horn (435 Hz + 540 Hz)
		var s = (sin(t * 435.0 * TAU) * 0.55 + sin(t * 540.0 * TAU) * 0.45) * env * 0.85
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_church_bell_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 2.8) # 2.8s acoustic chime decay
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var env = exp(-t * 1.8)
		# Cathedral bell harmonics: 220Hz (Fundamental), 440Hz, 660Hz (Fifth), 880Hz, 1100Hz
		var s = sin(t * 220.0 * TAU) * env * 0.45
		s += sin(t * 440.0 * TAU) * exp(-t * 2.5) * 0.28
		s += sin(t * 659.25 * TAU) * exp(-t * 3.2) * 0.20
		s += sin(t * 880.0 * TAU) * exp(-t * 4.0) * 0.12
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func synth_radio_valico_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = int(22050 * 4.0) # 4.0s perfect loop at 120 BPM (2 bars)
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	var bass_notes = [110.0, 110.0, 130.81, 146.83, 110.0, 110.0, 98.0, 87.31] # A2, C3, D3, G2, F2
	var lead_notes = [440.0, 523.25, 659.25, 523.25, 587.33, 440.0, 493.88, 392.0]
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var beat_16th = int(t * 8.0) % 8
		var beat_sub = fmod(t * 8.0, 1.0)
		
		# 1. Groovy 1993 Synth Bassline
		var b_freq = bass_notes[beat_16th]
		var b_env = exp(-beat_sub * 4.5)
		var s_bass = sin(t * b_freq * TAU) * b_env * 0.35 + (1.0 if sin(t * b_freq * TAU) > 0.0 else -1.0) * b_env * 0.15
		
		# 2. Italo-Disco Lead Arpeggio
		var l_freq = lead_notes[(beat_16th + 2) % 8]
		var l_env = exp(-beat_sub * 2.8)
		var s_lead = sin(t * l_freq * TAU) * l_env * 0.22 + sin(t * l_freq * 2.0 * TAU) * l_env * 0.10
		
		# 3. Soft Hi-Hat pulse
		var s_hat = (randf() * 2.0 - 1.0) * exp(-beat_sub * 18.0) * 0.08
		
		var s = (s_bass + s_lead + s_hat) * 0.75
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func synth_onda_verde_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = int(22050 * 3.0) # 3.0s radio loop
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		# Gentle ANAS news chime chord (349Hz, 440Hz, 523Hz, 698Hz)
		var chord = sin(t * 349.23 * TAU) * 0.15 + sin(t * 440.0 * TAU) * 0.12 + sin(t * 523.25 * TAU) * 0.10
		chord *= (0.5 + 0.5 * sin(t * 1.5 * TAU))
		# Atmospheric AM radio carrier hiss
		var hiss = (randf() * 2.0 - 1.0) * 0.03
		var s = chord + hiss
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func synth_monte_rosa_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	var sample_count = int(22050 * 3.5) # 3.5s waltz loop
	wav.loop_begin = 0
	wav.loop_end = sample_count
	
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var vib = 1.0 + 0.03 * sin(t * 5.0 * TAU)
		# Accordion-like rich harmonic blend (220Hz, 440Hz, 660Hz, 880Hz)
		var s1 = sin(t * 220.0 * vib * TAU) * 0.20
		var s2 = sin(t * 277.18 * vib * TAU) * 0.18 # C#
		var s3 = sin(t * 329.63 * vib * TAU) * 0.16 # E
		var s = (s1 + s2 + s3) * (0.6 + 0.4 * sin(t * 2.0 * TAU))
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_starter_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.70)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	# Motorino d'avviamento Marelli 12V: ronzio elettrico + colpi di compressione a 11 Hz
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = 0.0
		if t < 0.55:
			var crank_phase = t * 11.5 * TAU
			var crank_pulse = exp(-fmod(t * 11.5, 1.0) * 8.0)
			var electric_whine = sin(t * 180.0 * TAU) * 0.22 + sin(t * 360.0 * TAU) * 0.12
			var comp_chug = (sin(crank_phase) * 0.55 + sin(crank_phase * 2.0) * 0.35) * crank_pulse
			s = (electric_whine + comp_chug) * 0.85
		else:
			# Scoppio di avviamento (ignition catch!)
			var catch_t = t - 0.55
			var env = exp(-catch_t * 9.0)
			s = (sin(catch_t * 65.0 * TAU) * 0.55 + sin(catch_t * 130.0 * TAU) * 0.35 + (randf()*2.0-1.0)*0.20) * env * 1.1
			
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_ratchet_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.22)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	# Chiave a cricchetto Beta: 4 scatti metallici rapidi (clic-clac-clic-clac)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = 0.0
		for click_idx in range(4):
			var c_time = 0.03 + float(click_idx) * 0.045
			if t >= c_time and t < c_time + 0.03:
				var dt = t - c_time
				var env = exp(-dt * 120.0)
				var ping = sin(dt * 3200.0 * TAU) * 0.55 + sin(dt * 5400.0 * TAU) * 0.35 + (randf()*2.0-1.0)*0.25
				s += ping * env
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_ui_click_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.05)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var env = exp(-t * 90.0)
		var s = (sin(t * 1400.0 * TAU) * 0.40 + sin(t * 2800.0 * TAU) * 0.30 + (randf()*2.0-1.0)*0.15) * env
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func create_cash_stream() -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	var sample_count = int(22050 * 0.32)
	var bytes = PackedByteArray()
	bytes.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var s = 0.0
		# Primo campanello (2093 Hz - Do7)
		if t < 0.15:
			var env = exp(-t * 18.0)
			s = sin(t * 2093.0 * TAU) * env * 0.50 + sin(t * 4186.0 * TAU) * env * 0.20
		else:
			# Secondo campanello più acuto (2637 Hz - Mi7) + rotazione meccanica monete
			var dt = t - 0.15
			var env = exp(-dt * 14.0)
			var chink = (randf()*2.0-1.0) * exp(-dt * 45.0) * 0.25
			s = (sin(dt * 2637.0 * TAU) * 0.55 + sin(dt * 5274.0 * TAU) * 0.20 + chink) * env
		var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, sample_16)
		
	wav.data = bytes
	return wav

func play_ratchet_wrench():
	if sfx_player and ratchet_stream:
		sfx_player.stream = ratchet_stream
		sfx_player.volume_db = clamp(-6.0 + get_ambient_gain_db(), -80.0, 4.0)
		sfx_player.play()

func play_ui_click():
	if sfx_player and ui_click_stream:
		sfx_player.stream = ui_click_stream
		sfx_player.volume_db = clamp(-10.0 + get_master_gain_db(), -80.0, 4.0)
		sfx_player.play()

func play_cash_register():
	if sfx_player and cash_stream:
		sfx_player.stream = cash_stream
		sfx_player.volume_db = clamp(-5.0 + get_master_gain_db(), -80.0, 4.0)
		sfx_player.play()
