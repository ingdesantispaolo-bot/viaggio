extends Node
class_name VehicleAudio

# THE LONG MERIDIAN - Procedural Vehicle Audio Engine (Godot 4)
# Synthesizes 4/6-cylinder engine acoustic cycles, Garrett turbo spool whistle,
# wind/tire road friction, transmission gear shift clicks, and hazard relay pulses.

@export var vehicle: VehicleController

var engine_player: AudioStreamPlayer
var road_player: AudioStreamPlayer
var turbo_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var last_gear: String = "D1"
var last_hazard_state: bool = false
var click_stream: AudioStreamWAV
var current_model: String = "panda_4x4"

func _ready():
    # 1. Synthesize Audio Streams
    var engine_stream = create_engine_stream()
    var road_stream = create_road_stream()
    var turbo_stream = create_turbo_stream()
    click_stream = create_click_stream()
    
    # 2. Engine Audio Player
    engine_player = AudioStreamPlayer.new()
    engine_player.stream = engine_stream
    engine_player.volume_db = -12.0
    engine_player.autoplay = true
    add_child(engine_player)
    
    # 3. Road & Wind Audio Player
    road_player = AudioStreamPlayer.new()
    road_player.stream = road_stream
    road_player.volume_db = -80.0
    road_player.autoplay = true
    add_child(road_player)
    
    # 4. Turbo Spool Whistle Player (Garrett T3 on Lancia Delta)
    turbo_player = AudioStreamPlayer.new()
    turbo_player.stream = turbo_stream
    turbo_player.volume_db = -80.0
    turbo_player.autoplay = true
    add_child(turbo_player)
    
    # 5. SFX Player for gear and relay clicks
    sfx_player = AudioStreamPlayer.new()
    sfx_player.volume_db = -8.0
    add_child(sfx_player)

func set_sound_profile(model_id: String):
    current_model = model_id

func _process(delta: float):
    if not vehicle:
        return
        
    var rpm = vehicle.engine_rpm
    var speed = vehicle.current_speed_kmh
    var throttle = Input.get_action_strength("accelerate")
    
    # 1. Engine pitch and volume modulation based on vehicle model
    var pitch_mult = 0.62
    if current_model == "delta_integrale":
        pitch_mult = 0.72
    elif current_model == "mercedes_gwagen":
        pitch_mult = 0.52 # Deeper 6-cylinder
        
    var target_pitch = clamp((rpm / 1000.0) * pitch_mult, 0.70, 3.85)
    engine_player.pitch_scale = lerp(engine_player.pitch_scale, target_pitch, delta * 14.0)
    
    var base_vol = -14.0 + (throttle * 7.5) + ((rpm - 850.0) / 5000.0) * 5.0
    engine_player.volume_db = lerp(engine_player.volume_db, clamp(base_vol, -24.0, 2.0), delta * 12.0)
    
    # 2. Turbo Spool Whistle (Lancia Delta Garrett T3)
    if current_model == "delta_integrale" and vehicle.current_boost_bar > 0.05:
        var boost = vehicle.current_boost_bar
        var turbo_vol = -38.0 + (boost / 1.45) * 26.0
        turbo_player.volume_db = lerp(turbo_player.volume_db, turbo_vol, delta * 10.0)
        turbo_player.pitch_scale = lerp(1.0, 2.6, boost / 1.45)
    else:
        turbo_player.volume_db = lerp(turbo_player.volume_db, -80.0, delta * 8.0)
    
    # 3. Road surface & wind rushing audio
    if speed > 2.0:
        var road_vol = -45.0 + clamp(speed / 150.0, 0.0, 1.0) * 36.0
        road_player.volume_db = lerp(road_player.volume_db, road_vol, delta * 8.0)
        road_player.pitch_scale = lerp(0.8, 1.4, clamp(speed / 130.0, 0.0, 1.0))
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

func play_click(pitch: float):
    if sfx_player and click_stream:
        sfx_player.stream = click_stream
        sfx_player.pitch_scale = pitch
        sfx_player.play()

func create_engine_stream() -> AudioStreamWAV:
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
    
    var base_freq = 38.0
    for i in range(sample_count):
        var t = float(i) / 22050.0
        var phase = t * base_freq * TAU
        
        var s = sin(phase) * 0.55
        s += sin(phase * 2.0) * 0.30
        s += sin(phase * 3.0) * 0.18
        s += sin(phase * 4.0) * 0.12
        s += sin(phase * 6.0) * 0.06
        s = tanh(s * 1.8) * 0.75
        
        var sample_16 = int(clamp(s * 32767.0, -32768.0, 32767.0))
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
    
    # Garrett T3 turbo compressor high-pitched whine
    var turbo_freq = 920.0
    for i in range(sample_count):
        var t = float(i) / 22050.0
        var s = sin(t * turbo_freq * TAU) * 0.35
        s += sin(t * turbo_freq * 2.0 * TAU) * 0.15
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
