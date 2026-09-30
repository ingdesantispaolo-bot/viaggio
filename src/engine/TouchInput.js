/**
 * THE LONG MERIDIAN - Touch & Keyboard Input Manager
 * Non-latching, reliable input mapping for both tablet multitouch and keyboard.
 * Keyboard inputs reset instantaneously on keyup; touch inputs take precedence when actively held.
 */

export class TouchInput {
  constructor() {
    // Current resolved input state
    this.steer = 0.0;       // -1.0 (left) to +1.0 (right)
    this.throttle = 0.0;    // 0.0 to 1.0
    this.brake = 0.0;       // 0.0 to 1.0
    this.handbrake = false; // boolean
    this.interact = false;  // boolean
    this.lights = false;    // toggle
    this.horn = false;      // boolean
    this.footMoveX = 0.0;   // for player on foot
    this.footMoveZ = 0.0;   // for player on foot

    // Active touch gesture flags
    this.touchSteerActive = false;
    this.touchSteerVal = 0.0;

    this.touchThrottleActive = false;
    this.touchThrottleVal = 0.0;

    this.touchBrakeActive = false;
    this.touchBrakeVal = 0.0;

    this.touchHandbrakeActive = false;
    this.touchHandbrakeVal = false;

    this.onToggleIgnition = null;
    this.onOpenJournal = null;
    this.onHonkHorn = null;
    this.onToggle4WD = null;
    this.onTogglePrimina = null;

    // Keyboard state tracking
    this.keys = {};

    this.initKeyboard();
  }

  initKeyboard() {
    window.addEventListener('keydown', (e) => {
      this.keys[e.code] = true;
      if (e.code === 'KeyE') this.interact = true;
      if (e.code === 'KeyL') this.lights = !this.lights;
      if (e.code === 'KeyH') {
        this.horn = true;
        if (this.onHonkHorn) this.onHonkHorn();
      }
      if (e.code === 'KeyX' && this.onToggle4WD) this.onToggle4WD();
      if (e.code === 'KeyP' && this.onTogglePrimina) this.onTogglePrimina();
      if (e.code === 'KeyI' && this.onToggleIgnition) this.onToggleIgnition();
      if ((e.code === 'KeyJ' || e.code === 'KeyM') && this.onOpenJournal) this.onOpenJournal();
    });

    window.addEventListener('keyup', (e) => {
      this.keys[e.code] = false;
      if (e.code === 'KeyE') this.interact = false;
      if (e.code === 'KeyH') this.horn = false;
    });

    // Reset all inputs if window loses focus
    window.addEventListener('blur', () => {
      this.keys = {};
      this.steer = 0.0;
      this.throttle = 0.0;
      this.brake = 0.0;
      this.handbrake = false;
    });
  }

  update() {
    // 1. Keyboard readings (zero if not pressed)
    let kSteer = 0.0;
    if (this.keys['KeyA'] || this.keys['ArrowLeft']) kSteer -= 1.0;
    if (this.keys['KeyD'] || this.keys['ArrowRight']) kSteer += 1.0;

    const kThrottle = (this.keys['KeyW'] || this.keys['ArrowUp']) ? 1.0 : 0.0;
    const kBrake = (this.keys['KeyS'] || this.keys['ArrowDown']) ? 1.0 : 0.0;
    const kHandbrake = !!this.keys['Space'];

    // 2. Resolve: Touch controls take precedence if actively engaged, otherwise keyboard
    this.steer = this.touchSteerActive ? this.touchSteerVal : kSteer;
    this.throttle = this.touchThrottleActive ? this.touchThrottleVal : kThrottle;
    this.brake = this.touchBrakeActive ? this.touchBrakeVal : kBrake;
    this.handbrake = this.touchHandbrakeActive ? this.touchHandbrakeVal : kHandbrake;

    // 3. Foot movement mapping (screen left is +X, screen right is -X)
    this.footMoveX = -this.steer;
    this.footMoveZ = this.throttle > 0 ? this.throttle : (this.brake > 0 ? -this.brake : 0);
  }

  setTouchSteer(value, active = true) {
    this.touchSteerActive = active;
    this.touchSteerVal = Math.max(-1.0, Math.min(1.0, value));
    if (!active) this.touchSteerVal = 0.0;
  }

  setTouchThrottle(value, active = true) {
    this.touchThrottleActive = active;
    this.touchThrottleVal = Math.max(0.0, Math.min(1.0, value));
    if (!active) this.touchThrottleVal = 0.0;
  }

  setTouchBrake(value, active = true) {
    this.touchBrakeActive = active;
    this.touchBrakeVal = Math.max(0.0, Math.min(1.0, value));
    if (!active) this.touchBrakeVal = 0.0;
  }

  setTouchHandbrake(state) {
    this.touchHandbrakeActive = state;
    this.touchHandbrakeVal = state;
  }
}
