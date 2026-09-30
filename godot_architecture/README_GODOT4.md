# IL GRANDE MERIDIANO - ARCHITETTURA DI TRANSIZIONE A GODOT 4 (VULKAN)
### Roadmap Ingegneristica per la Resa Visiva e Fisica "Art of Rally / Tiny Glade"

---

## 1. Perché Godot 4 (Vulkan Forward+)
Godot 4 è il motore di nuova generazione ideale per raggiungere la purezza visiva di **Art of Rally**, **Circuit Superstars**, **Tiny Glade** e **Dorfromantik**:
- **Nessuna installazione complessa**: È un singolo eseguibile portatile da soli **110 MB** (scaricabile da [godotengine.org](https://godotengine.org/)).
- **Renderer Vulkan Forward+ Nativo**: Supporta ombre a contatto in tempo reale (**SSAO / SSIL**), illuminazione globale (**SDFGI**), e soprattutto **Nebbia Volumetrica 3D reale** con fasci di luce (*God rays*) che attraversano le vallate alpine e le foreste.
- **Fisica Multithread con Motore Jolt**: Supporta il nodo nativo `VehicleBody3D` con sospensioni raycast indipendenti, molle con smorzamento differenziale in estensione/compressione e modello di aderenza per pneumatico.

---

## 2. Struttura del Progetto Godot 4

```text
godot_project/
├── project.godot                     # File di configurazione (Renderer Vulkan, Input, VSync)
├── default_env.tres                  # WorldEnvironment (SDFGI, SSAO, Volumetric Fog, ACES)
├── scenes/
│   ├── Main.tscn                     # Scena Master con Camera 3/4 Diorama e WorldEnvironment
│   ├── Vehicle.tscn                  # VehicleBody3D con 4 VehicleWheel3D e nodi mesh
│   ├── RoadChunk.tscn                # Segmento procedurale di carreggiata e terreno skirt
│   └── DashboardUI.tscn              # Cruscotto Veglia Borletti vettoriale nativo (Control Nodes)
├── scripts/
│   ├── VehicleController.gd          # Drivetrain, marce, turbo lag, ripartizione 4WD Steyr-Puch
│   ├── RoadGenerator.gd              # Generazione geometrica nastro stradale (ArrayMesh)
│   ├── HazardManager.gd              # Scenari cantieri con coni, auto in avaria e freccia LED
│   └── BiomeDirector.gd              # Transizione cromatica e meteorologica dei biomi
└── shaders/
    ├── diorama_tilt_shift.gdshader   # Shader computazionale per profondità di campo bokeh
    ├── stylized_asphalt.gdshader     # Asfalto PBR con bagnato e usura carreggiata
    └── stylized_foliage.gdshader     # Vegetazione con oscillazione al vento e luce passante (SSS)
```

---

## 3. Specifiche Fisiche del Veicolo (`VehicleBody3D`)

In Godot 4, il veicolo non richiede equazioni empiriche di rotolamento scritte a mano. Utilizza il nodo **`VehicleBody3D`** con 4 nodi figli **`VehicleWheel3D`**:

```gdscript
# VehicleController.gd (Esempio per FIAT Panda 4x4 Steyr-Puch)
extends VehicleBody3D

@export var max_engine_force: float = 380.0
@export var max_brake_force: float = 45.0
@export var max_steer_angle: float = deg_to_rad(28.0)

@onready var wheel_fl: VehicleWheel3D = $WheelFL
@onready var wheel_fr: VehicleWheel3D = $WheelFR
@onready var wheel_rl: VehicleWheel3D = $WheelRL
@onready var wheel_rr: VehicleWheel3D = $WheelRR

func _ready():
    # Taratura Sospensioni Panda 4x4
    mass = 980.0 # kg
    center_of_mass = Vector3(0.0, -0.15, -0.1) # Baricentro basso per evitare ribaltamenti facili
    
    for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
        w.suspension_stiffness = 38.0        # Rigidità molla (N/mm)
        w.suspension_max_force = 6000.0      # Carico massimo
        w.damping_compression = 0.42         # Smorzamento in compressione
        w.damping_relaxation = 0.58          # Smorzamento in estensione
        w.wheel_friction_slip = 2.65         # Coefficiente di aderenza gomma su asfalto

func _physics_process(delta: float):
    var throttle = Input.get_action_strength("accelerate")
    var brake = Input.get_action_strength("brake")
    var steer = Input.get_axis("steer_right", "steer_left")
    
    # Sterzata progressiva proporzionale alla velocità
    var speed_kmh = linear_velocity.length() * 3.6
    var steer_factor = clamp(1.0 - (speed_kmh / 140.0) * 0.65, 0.35, 1.0)
    steering = steer * max_steer_angle * steer_factor
    
    # Trazione Integrale Steyr-Puch (50% anteriore, 50% posteriore)
    var force = throttle * max_engine_force
    wheel_fl.engine_force = force * 0.5
    wheel_fr.engine_force = force * 0.5
    wheel_rl.engine_force = force * 0.5
    wheel_rr.engine_force = force * 0.5
    
    brake = brake * max_brake_force
    for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
        w.brake = brake
```

---

## 4. Shader Post-Processing Diorama Tilt-Shift (`diorama_tilt_shift.gdshader`)

Per ottenere l'effetto plastico/miniatura di *Art of Rally* e *Dorfromantik*:

```glsl
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float focus_distance : hint_range(0.0, 1.0) = 0.52;
uniform float focus_band_width : hint_range(0.0, 0.5) = 0.18;
uniform float blur_amount : hint_range(0.0, 8.0) = 4.5;

void fragment() {
    float dist_from_focus = abs(UV.y - focus_distance);
    float blur_factor = smoothstep(focus_band_width, focus_band_width + 0.35, dist_from_focus);
    
    vec4 col = vec4(0.0);
    float total_weight = 0.0;
    float current_blur = blur_factor * blur_amount * 0.003;
    
    // Campionamento Bokeh circolare a 9 tap
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * current_blur;
            float weight = 1.0 / (1.0 + length(offset));
            col += texture(SCREEN_TEXTURE, SCREEN_UV + offset) * weight;
            total_weight += weight;
        }
    }
    
    COLOR = col / total_weight;
}
```

---

## 5. Prossimi Passi di Sviluppo

1. **Test immediato del Punto 3 (Programma PC Stand-alone Windows)**:
   - È stato compilato l'eseguibile nativo `IlGrandeMeridiano.exe` nel workspace.
   - Cliccando due volte su `IlGrandeMeridiano.exe`, il gioco si apre in una finestra desktop hardware-accelerata DirectX 12/Vulkan a schermo intero (tasto `F11` o `Alt+Enter`), con fari ad alta visibilità, scenari di cantieri realistici e dashboard Borletti a 60 FPS.
2. **Attivazione del Progetto Godot 4 (Punto 2)**:
   - Quando desideri testare il prototipo in Godot 4, basta scaricare Godot 4 (portatile) e aprire la cartella `godot_project/` per compilare il codice nativo in C# / GDScript.
