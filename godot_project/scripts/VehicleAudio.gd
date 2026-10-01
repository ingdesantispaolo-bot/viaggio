extends Node
class_name VehicleAudio

# THE LONG MERIDIAN - Procedural Vehicle Audio Engine (Godot 4)
# Synthesizes realistic 4-cylinder engine acoustic cycles, wind/tire road friction,
# transmission gear shift clicks, and hazard relay pulses without external audio files.

@export var vehicle: VehicleController

var engine_player: AudioStreamPlayer
var road_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var last_gear: String = "D1"
var last_hazard_state: bool = false
var click_stream: AudioStreamWAV

func _ready():
    # 1. Synthesize Audio Streams
    var engine_stream = create_engine_stream()
    var road_stream = create_road_stream()
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
    
    # 4. SFX Player for gear and relay clicks
    sfx_player = AudioStreamPlayer.new()
    sfx_player.volume_db = -8.0
    add_child(sfx_player)

func _process(delta: float):
    if not vehicle:
        return
        
    var rpm = vehicle.engine_rpm
    var speed = vehicle.current_speed_kmh
    var throttle = Input.get_action_strength("accelerate")
    
    # 1. Engine pitch and volume modulation
    # Idle at 850 RPM = pitch 0.85, Top revs at 6000 RPM = pitch 3.6
    var target_pitch = clamp((rpm / 1000.0) * 0.62, 0.72, 3.85)
    engine_player.pitch_scale = lerp(engine_player.pitch_scale, target_pitch, delta * 14.0)
    
    # Engine load sound (louder when throttle is pressed)
    var base_vol = -14.0 + (throttle * 7.5) + ((rpm - 850.0) / 5000.0) * 5.0
    engine_player.volume_db = lerp(engine_player.volume_db, clamp(base_vol, -24.0, 2.0), delta * 12.0)
    
    # 2. Road surface & wind rushing audio
    if speed > 2.0:
        var road_vol = -45.0 + clamp(speed / 130.0, 0.0, 1.0) * 36.0
        road_player.volume_db = lerp(road_player.volume_db, road_vol, delta * 8.0)
        road_player.pitch_scale = lerp(0.8, 1.4, clamp(speed / 120.0, 0.0, 1.0))
    else:
        road_player.volume_db = lerp(road_player.volume_db, -80.0, delta * 8.0)
        
    # 3. Gear shift mechanical click
    if vehicle.gear_name != last_gear:
        last_gear = vehicle.gear_name
        play_click(1.15)
        
    # 4. Hazard flasher relay click
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
    
    # Synthesize 4-cylinder engine fundamental pulses with rich odd/even harmonics
    var base_freq = 38.0 # Hz at idle
    for i in range(sample_count):
        var t = float(i) / 22050.0
        var phase = t * base_freq * TAU
        
        # Asymmetric 4-stroke pressure pulses
        var s = sin(phase) * 0.55
        s += sin(phase * 2.0) * 0.30
        s += sin(phase * 3.0) * 0.18
        s += sin(phase * 4.0) * 0.12
        s += sin(phase * 6.0) * 0.06
        
        # Non-linear combustion saturation
        s = tanh(s * 1.8) * 0.75
        
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
    
    # Synthesize smooth low-pass filtered noise for tire tread on asphalt and wind
    var filter_val = 0.0
    for i in range(sample_count):
        var white = randf_range(-1.0, 1.0)
        filter_val = lerp(filter_val, white, 0.08) # Low-pass filter
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
    
    var sample_count = 1100 # ~50 milliseconds
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
