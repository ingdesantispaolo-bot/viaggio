/**
 * THE LONG MERIDIAN - High-Fidelity Procedural Web Audio Synthesizer Engine
 * 100% self-contained sound effects, multi-oscillator internal combustion synthesis,
 * turbo blow-off flutter, surface tire rolling/gravel crunch, exhaust overrun backfires,
 * and dynamic weather soundscapes via the Web Audio API.
 */

function makeDistortionCurve(amount = 25) {
  const n = 2048;
  const curve = new Float32Array(n);
  const deg = Math.PI / 180;
  for (let i = 0; i < n; ++i) {
    const x = (i * 2) / n - 1;
    curve[i] = ((3 + amount) * x * 20 * deg) / (Math.PI + amount * Math.abs(x));
  }
  return curve;
}

export class WebAudioEngine {
  constructor() {
    this.ctx = null;
    this.masterGain = null;
    this.isMuted = false;
    this.isInitialized = false;

    // Engine sound nodes & cluster
    this.engineOsc = null;
    this.engineSubOsc = null;
    this.engineHarmonicOsc = null;
    this.engineIntakeGain = null;
    this.engineFilter = null;
    this.engineDistortion = null;
    this.engineGain = null;
    this.turboOsc = null;
    this.turboGain = null;
    this.isEngineRunning = false;

    this.currentProfile = {
      baseFreq: 38,
      timbre: 'raspy_4cyl',
      cylinders: 4,
      turboWhistle: 0.0,
      dieselKnock: 0.0
    };

    // Surface / road rolling sound
    this.surfaceRollNode = null;
    this.surfaceRollFilter = null;
    this.surfaceRollGain = null;
    this.gravelCrunchNode = null;
    this.gravelCrunchFilter = null;
    this.gravelCrunchGain = null;

    // Brake squeal node
    this.brakeSquealOsc = null;
    this.brakeSquealGain = null;

    // Ambient nodes
    this.windNode = null;
    this.windGain = null;
    this.rainNode = null;
    this.rainGain = null;
    this.geigerInterval = null;

    // Music drone
    this.droneOsc1 = null;
    this.droneOsc2 = null;
    this.droneGain = null;
  }

  init() {
    if (this.isInitialized) return;
    try {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.setValueAtTime(0.58, this.ctx.currentTime);
      this.masterGain.connect(this.ctx.destination);

      this.setupEngineSound();
      this.setupSurfaceSound();
      this.setupBrakeSound();
      this.setupAmbientSound();
      this.setupDroneAtmosphere();

      this.isInitialized = true;
    } catch (e) {
      console.warn('WebAudio initialization delayed until user gesture:', e);
    }
  }

  ensureContext() {
    if (!this.isInitialized) this.init();
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  setEngineProfile(profile) {
    if (!profile) return;
    this.currentProfile = Object.assign(this.currentProfile, profile);
  }

  setupEngineSound() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Primary cylinder firing oscillator (sawtooth)
    this.engineOsc = this.ctx.createOscillator();
    this.engineOsc.type = 'sawtooth';
    this.engineOsc.frequency.setValueAtTime(38, now);

    // 2. Sub-octave crankshaft bass thud (triangle, 0.5x freq)
    this.engineSubOsc = this.ctx.createOscillator();
    this.engineSubOsc.type = 'triangle';
    this.engineSubOsc.frequency.setValueAtTime(19, now);

    // 3. Cylinder valve/cam harmonic rasp (square/pulse, 1.5x freq)
    this.engineHarmonicOsc = this.ctx.createOscillator();
    this.engineHarmonicOsc.type = 'square';
    this.engineHarmonicOsc.frequency.setValueAtTime(57, now);
    const harmonicGain = this.ctx.createGain();
    harmonicGain.gain.setValueAtTime(0.22, now);
    this.engineHarmonicOsc.connect(harmonicGain);

    // 4. Air intake rushing noise buffer (adds authentic throatiness on throttle)
    const intakeBufSize = this.ctx.sampleRate * 2;
    const intakeBuf = this.ctx.createBuffer(1, intakeBufSize, this.ctx.sampleRate);
    const intakeData = intakeBuf.getChannelData(0);
    for (let i = 0; i < intakeBufSize; i++) {
      intakeData[i] = (Math.random() * 2 - 1) * 0.4;
    }
    const intakeSource = this.ctx.createBufferSource();
    intakeSource.buffer = intakeBuf;
    intakeSource.loop = true;
    const intakeFilter = this.ctx.createBiquadFilter();
    intakeFilter.type = 'bandpass';
    intakeFilter.frequency.setValueAtTime(450, now);
    intakeFilter.Q.setValueAtTime(2.2, now);
    this.engineIntakeGain = this.ctx.createGain();
    this.engineIntakeGain.gain.setValueAtTime(0.0, now);
    intakeSource.connect(intakeFilter);
    intakeFilter.connect(this.engineIntakeGain);
    intakeSource.start();

    // 5. Engine Pre-Mix Bus
    const preMix = this.ctx.createGain();
    preMix.gain.setValueAtTime(0.65, now);
    this.engineOsc.connect(preMix);
    this.engineSubOsc.connect(preMix);
    harmonicGain.connect(preMix);
    this.engineIntakeGain.connect(preMix);

    // 6. Warm Analog Waveshaper Distortion (turns harsh synth into authentic combustion rumble)
    this.engineDistortion = this.ctx.createWaveShaper();
    this.engineDistortion.curve = makeDistortionCurve(18);
    this.engineDistortion.oversample = '2x';
    preMix.connect(this.engineDistortion);

    // 7. Dynamic Resonant Lowpass Filter (opens up as throttle & RPM increase)
    this.engineFilter = this.ctx.createBiquadFilter();
    this.engineFilter.type = 'lowpass';
    this.engineFilter.frequency.setValueAtTime(160, now);
    this.engineFilter.Q.setValueAtTime(4.2, now);
    this.engineDistortion.connect(this.engineFilter);

    // 8. Main Engine Gain
    this.engineGain = this.ctx.createGain();
    this.engineGain.gain.setValueAtTime(0, now);
    this.engineFilter.connect(this.engineGain);
    this.engineGain.connect(this.masterGain);

    // 9. Turbocharger High-Pitch Spool Whistle
    this.turboOsc = this.ctx.createOscillator();
    this.turboGain = this.ctx.createGain();
    this.turboOsc.type = 'sine';
    this.turboOsc.frequency.setValueAtTime(1400, now);
    this.turboGain.gain.setValueAtTime(0, now);

    const turboFilter = this.ctx.createBiquadFilter();
    turboFilter.type = 'bandpass';
    turboFilter.frequency.setValueAtTime(2400, now);
    turboFilter.Q.setValueAtTime(7.5, now);

    this.turboOsc.connect(turboFilter);
    turboFilter.connect(this.turboGain);
    this.turboGain.connect(this.masterGain);

    this.engineOsc.start();
    this.engineSubOsc.start();
    this.engineHarmonicOsc.start();
    this.turboOsc.start();
  }

  setupSurfaceSound() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Continuous tire rolling noise (Pink/Brown noise approximation)
    const rollBufSize = this.ctx.sampleRate * 2;
    const rollBuf = this.ctx.createBuffer(1, rollBufSize, this.ctx.sampleRate);
    const rollData = rollBuf.getChannelData(0);
    let lastOut = 0.0;
    for (let i = 0; i < rollBufSize; i++) {
      const white = Math.random() * 2 - 1;
      rollData[i] = (lastOut + 0.04 * white) / 1.04;
      lastOut = rollData[i];
      rollData[i] *= 2.5;
    }
    this.surfaceRollNode = this.ctx.createBufferSource();
    this.surfaceRollNode.buffer = rollBuf;
    this.surfaceRollNode.loop = true;

    this.surfaceRollFilter = this.ctx.createBiquadFilter();
    this.surfaceRollFilter.type = 'lowpass';
    this.surfaceRollFilter.frequency.setValueAtTime(180, now);

    this.surfaceRollGain = this.ctx.createGain();
    this.surfaceRollGain.gain.setValueAtTime(0.0, now);

    this.surfaceRollNode.connect(this.surfaceRollFilter);
    this.surfaceRollFilter.connect(this.surfaceRollGain);
    this.surfaceRollGain.connect(this.masterGain);
    this.surfaceRollNode.start();

    // 2. Gravel / dirt shoulder scattering texture (textured crackle buffer)
    const gravelBuf = this.ctx.createBuffer(1, rollBufSize, this.ctx.sampleRate);
    const gravelData = gravelBuf.getChannelData(0);
    for (let i = 0; i < rollBufSize; i++) {
      // Intermittent sharp pebble pings and crunch
      gravelData[i] = Math.random() < 0.04 ? (Math.random() * 2 - 1) * 0.9 : (Math.random() * 2 - 1) * 0.08;
    }
    this.gravelCrunchNode = this.ctx.createBufferSource();
    this.gravelCrunchNode.buffer = gravelBuf;
    this.gravelCrunchNode.loop = true;

    this.gravelCrunchFilter = this.ctx.createBiquadFilter();
    this.gravelCrunchFilter.type = 'bandpass';
    this.gravelCrunchFilter.frequency.setValueAtTime(1400, now);
    this.gravelCrunchFilter.Q.setValueAtTime(2.0, now);

    this.gravelCrunchGain = this.ctx.createGain();
    this.gravelCrunchGain.gain.setValueAtTime(0.0, now);

    this.gravelCrunchNode.connect(this.gravelCrunchFilter);
    this.gravelCrunchFilter.connect(this.gravelCrunchGain);
    this.gravelCrunchGain.connect(this.masterGain);
    this.gravelCrunchNode.start();
  }

  setupBrakeSound() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    this.brakeSquealOsc = this.ctx.createOscillator();
    this.brakeSquealGain = this.ctx.createGain();

    this.brakeSquealOsc.type = 'sine';
    this.brakeSquealOsc.frequency.setValueAtTime(3200, now);
    this.brakeSquealGain.gain.setValueAtTime(0.0, now);

    const brakeFilter = this.ctx.createBiquadFilter();
    brakeFilter.type = 'bandpass';
    brakeFilter.frequency.setValueAtTime(3200, now);
    brakeFilter.Q.setValueAtTime(12.0, now);

    this.brakeSquealOsc.connect(brakeFilter);
    brakeFilter.connect(this.brakeSquealGain);
    this.brakeSquealGain.connect(this.masterGain);
    this.brakeSquealOsc.start();
  }

  setEngineRPM(normalizedRPM, isAccelerating = false, boostBar = 0, gear = 1, forwardSpeed = 0) {
    if (!this.ctx || !this.isEngineRunning) return;
    const now = this.ctx.currentTime;

    const p = this.currentProfile;
    const base = p.baseFreq || 38;
    const cylMultiplier = (p.cylinders || 4) / 4.0;

    // Pitch scales authentic to engine cylinder pulses
    const freq = (base + Math.pow(normalizedRPM, 1.35) * 145) * cylMultiplier;
    this.engineOsc.frequency.setTargetAtTime(freq, now, 0.06);
    this.engineSubOsc.frequency.setTargetAtTime(freq * 0.5, now, 0.06);
    this.engineHarmonicOsc.frequency.setTargetAtTime(freq * 1.5, now, 0.06);

    // Resonant lowpass filter opens with throttle and RPM
    const filterFreq = 120 + normalizedRPM * 540 + (isAccelerating ? 320 : 0);
    this.engineFilter.frequency.setTargetAtTime(filterFreq, now, 0.07);

    // Air intake throatiness gain on throttle
    if (this.engineIntakeGain) {
      const intakeVol = isAccelerating ? (0.08 + normalizedRPM * 0.16) : 0.01;
      this.engineIntakeGain.gain.setTargetAtTime(intakeVol, now, 0.08);
    }

    // Engine master volume
    const vol = 0.22 + normalizedRPM * 0.26 + (isAccelerating ? 0.09 : 0);
    this.engineGain.gain.setTargetAtTime(vol, now, 0.07);

    // Turbo whistle modulation proportional to active boost pressure
    if (this.turboGain && p.turboWhistle > 0) {
      if (boostBar > 0.05 || (isAccelerating && normalizedRPM > 0.25)) {
        const boostRatio = Math.min(1.2, (boostBar / 1.2) + (normalizedRPM * 0.3));
        const turboFreq = 1400 + boostRatio * 2200;
        this.turboOsc.frequency.setTargetAtTime(turboFreq, now, 0.08);
        const turboVol = p.turboWhistle * (0.04 + boostRatio * 0.12);
        this.turboGain.gain.setTargetAtTime(turboVol, now, 0.1);
      } else {
        this.turboGain.gain.setTargetAtTime(0, now, 0.15);
      }
    } else if (this.turboGain) {
      this.turboGain.gain.setTargetAtTime(0, now, 0.1);
    }
  }

  playTurboBlowOff(boostLevel = 1.0) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const intensity = Math.min(1.0, Math.max(0.3, boostLevel));

    // Layer 1: High-pressure air dump whoosh
    const whooshDuration = 0.35 + intensity * 0.2;
    const noise = this.createNoiseBurst(whooshDuration, 4200, 0.26 * intensity);
    if (noise) noise.start(now);

    // Layer 2: Compressor surge flutter chirp (tsu-tsu-tsu-tsu)
    for (let i = 0; i < 4; i++) {
      const t = now + 0.05 + i * 0.055;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(1850 - i * 180, t);
      osc.frequency.exponentialRampToValueAtTime(700, t + 0.04);

      g.gain.setValueAtTime(0.18 * (1.0 - i * 0.2) * intensity, t);
      g.gain.exponentialRampToValueAtTime(0.005, t + 0.045);

      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.05);
    }
  }

  playBackfire(intensity = 1.0) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const mag = Math.min(1.0, intensity);

    // 1. High frequency explosive bang / whip crack
    const crack = this.createNoiseBurst(0.09, 5200, 0.42 * mag);
    if (crack) crack.start(now);

    // 2. Deep sub-frequency tailpipe thump
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(110, now);
    osc.frequency.exponentialRampToValueAtTime(24, now + 0.18);

    g.gain.setValueAtTime(0.55 * mag, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.18);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.19);
  }

  setSurface(surface, normalizedSpeed, onShoulder) {
    if (!this.ctx || !this.surfaceRollGain) return;
    const now = this.ctx.currentTime;
    const speed = Math.max(0, Math.min(1.5, normalizedSpeed));

    if (speed < 0.02) {
      this.surfaceRollGain.gain.setTargetAtTime(0, now, 0.15);
      if (this.gravelCrunchGain) this.gravelCrunchGain.gain.setTargetAtTime(0, now, 0.15);
      return;
    }

    // Rolling tire hum on pavement
    const rollVol = Math.min(0.25, speed * 0.18);
    const filterFreq = 160 + speed * 320;
    this.surfaceRollGain.gain.setTargetAtTime(rollVol, now, 0.1);
    this.surfaceRollFilter.frequency.setTargetAtTime(filterFreq, now, 0.1);

    // Shoulder gravel rattle and scattering
    if (this.gravelCrunchGain) {
      if (onShoulder || (surface && (surface.id === 'gravel' || surface.id === 'dirt'))) {
        const gravelVol = Math.min(0.35, 0.08 + speed * 0.28);
        this.gravelCrunchGain.gain.setTargetAtTime(gravelVol, now, 0.08);
      } else {
        this.gravelCrunchGain.gain.setTargetAtTime(0, now, 0.18);
      }
    }
  }

  setBrakeSound(isBraking, speedRatio) {
    if (!this.ctx || !this.brakeSquealGain) return;
    const now = this.ctx.currentTime;
    if (isBraking && speedRatio > 0.15 && speedRatio < 0.85) {
      this.brakeSquealGain.gain.setTargetAtTime(0.045, now, 0.08);
    } else {
      this.brakeSquealGain.gain.setTargetAtTime(0, now, 0.1);
    }
  }

  playSuspensionThump(severity = 0.5) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const mag = Math.min(1.0, Math.max(0.1, severity));

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(85, now);
    osc.frequency.exponentialRampToValueAtTime(22, now + 0.14);

    g.gain.setValueAtTime(0.35 * mag, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.14);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.15);
  }

  startEngine() {
    this.ensureContext();
    if (!this.ctx) return;
    this.isEngineRunning = true;

    // Cranking sound burst
    this.playCrankEffect(() => {
      if (this.engineGain) {
        this.engineGain.gain.setTargetAtTime(0.25, this.ctx.currentTime, 0.2);
      }
    });
  }

  stopEngine() {
    if (!this.ctx || !this.isEngineRunning) return;
    this.isEngineRunning = false;
    if (this.engineGain) {
      this.engineGain.gain.setTargetAtTime(0, this.ctx.currentTime, 0.35);
    }
    if (this.surfaceRollGain) {
      this.surfaceRollGain.gain.setTargetAtTime(0, this.ctx.currentTime, 0.2);
    }
    if (this.gravelCrunchGain) {
      this.gravelCrunchGain.gain.setTargetAtTime(0, this.ctx.currentTime, 0.2);
    }
    this.playSwitchClick(false);
  }

  playCrankEffect(onStartCallback) {
    const now = this.ctx.currentTime;
    for (let i = 0; i < 3; i++) {
      const t = now + i * 0.12;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'square';
      osc.frequency.setValueAtTime(45 + i * 5, t);
      g.gain.setValueAtTime(0.3, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.08);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.09);
    }
    setTimeout(() => {
      if (onStartCallback) onStartCallback();
      this.playRevChirp();
    }, 400);
  }

  playRevChirp() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(90, now);
    osc.frequency.exponentialRampToValueAtTime(180, now + 0.25);
    osc.frequency.exponentialRampToValueAtTime(55, now + 0.55);
    g.gain.setValueAtTime(0.25, now);
    g.gain.linearRampToValueAtTime(0.01, now + 0.55);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.56);
  }

  setupAmbientSound() {
    if (!this.ctx) return;

    // Procedural Wind (Pink/Brownian Noise buffer)
    const bufferSize = this.ctx.sampleRate * 2;
    const noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const output = noiseBuffer.getChannelData(0);
    let lastOut = 0.0;
    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;
      output[i] = (lastOut + 0.02 * white) / 1.02;
      lastOut = output[i];
      output[i] *= 3.5;
    }

    this.windNode = this.ctx.createBufferSource();
    this.windNode.buffer = noiseBuffer;
    this.windNode.loop = true;

    const windFilter = this.ctx.createBiquadFilter();
    windFilter.type = 'bandpass';
    windFilter.frequency.setValueAtTime(260, this.ctx.currentTime);
    windFilter.Q.setValueAtTime(1.5, this.ctx.currentTime);

    this.windGain = this.ctx.createGain();
    this.windGain.gain.setValueAtTime(0.08, this.ctx.currentTime);

    this.windNode.connect(windFilter);
    windFilter.connect(this.windGain);
    this.windGain.connect(this.masterGain);

    this.windNode.start();
  }

  setSpeedWind(normalizedSpeed) {
    if (!this.ctx || !this.windGain) return;
    const targetVol = 0.05 + normalizedSpeed * 0.28;
    this.windGain.gain.setTargetAtTime(targetVol, this.ctx.currentTime, 0.2);
  }

  setupDroneAtmosphere() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    this.droneOsc1 = this.ctx.createOscillator();
    this.droneOsc2 = this.ctx.createOscillator();
    this.droneGain = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();

    this.droneOsc1.type = 'sine';
    this.droneOsc2.type = 'triangle';

    this.droneOsc1.frequency.setValueAtTime(55, now);     // A1
    this.droneOsc2.frequency.setValueAtTime(82.41, now);  // E2 (dark 5th)

    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(180, now);

    this.droneGain.gain.setValueAtTime(0.09, now);

    this.droneOsc1.connect(filter);
    this.droneOsc2.connect(filter);
    filter.connect(this.droneGain);
    this.droneGain.connect(this.masterGain);

    this.droneOsc1.start();
    this.droneOsc2.start();
  }

  playImpact(strength = 1.0) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(110 * strength, now);
    osc.frequency.exponentialRampToValueAtTime(20, now + 0.35);

    g.gain.setValueAtTime(Math.min(0.6 * strength, 0.8), now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.35);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.36);

    const noise = this.createNoiseBurst(0.2, 800, 0.35 * strength);
    if (noise) noise.start(now);
  }

  playTireScreech() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(650 + Math.random() * 80, now);
    osc.frequency.linearRampToValueAtTime(520, now + 0.22);

    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(750, now);
    filter.Q.setValueAtTime(8.0, now);

    g.gain.setValueAtTime(0.12, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.22);

    osc.connect(filter);
    filter.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.23);
  }

  playSwitchClick(isOn = true) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(isOn ? 980 : 720, now);
    osc.frequency.exponentialRampToValueAtTime(150, now + 0.035);

    g.gain.setValueAtTime(0.25, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.035);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.04);
  }

  playHorn() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc1 = this.ctx.createOscillator();
    const osc2 = this.ctx.createOscillator();
    const g = this.ctx.createGain();

    osc1.type = 'sawtooth';
    osc2.type = 'sawtooth';
    osc1.frequency.setValueAtTime(340, now); // F4
    osc2.frequency.setValueAtTime(425, now); // G#4

    g.gain.setValueAtTime(0.3, now);
    g.gain.linearRampToValueAtTime(0.28, now + 0.35);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.45);

    osc1.connect(g);
    osc2.connect(g);
    g.connect(this.masterGain);
    osc1.start(now);
    osc2.start(now);
    osc1.stop(now + 0.46);
    osc2.stop(now + 0.46);
  }

  playGeigerClick() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();

    osc.type = 'square';
    osc.frequency.setValueAtTime(2400 + Math.random() * 800, now);
    g.gain.setValueAtTime(0.2, now);
    g.gain.exponentialRampToValueAtTime(0.005, now + 0.012);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.015);
  }

  playLootPickup() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const notes = [440, 554, 659]; // A major arpeggio
    notes.forEach((freq, idx) => {
      const t = now + idx * 0.06;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, t);
      g.gain.setValueAtTime(0.18, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.12);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.13);
    });
  }

  playBreakdownAlarm() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    for (let i = 0; i < 2; i++) {
      const t = now + i * 0.12;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(i === 0 ? 1050 : 790, t);
      g.gain.setValueAtTime(0.25, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.09);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.1);
    }
  }

  playRadiatorHiss() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const duration = 1.2;
    const noise = this.createNoiseBurst(duration, 3800, 0.22);
    if (noise) {
      noise.start(now);
    }
  }

  playTireBlowout() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(140, now);
    osc.frequency.exponentialRampToValueAtTime(32, now + 0.3);
    g.gain.setValueAtTime(0.45, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.3);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.32);

    const noise = this.createNoiseBurst(0.35, 1200, 0.4);
    if (noise) noise.start(now);
  }

  playRepairWrench() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    for (let i = 0; i < 3; i++) {
      const t = now + i * 0.08;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'square';
      osc.frequency.setValueAtTime(1450 + i * 150, t);
      osc.frequency.exponentialRampToValueAtTime(300, t + 0.03);
      g.gain.setValueAtTime(0.28, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.035);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.04);
    }
  }

  playLightningThunder() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const crackle = this.createNoiseBurst(0.18, 5500, 0.35);
    if (crackle) crackle.start(now);

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(65, now + 0.15);
    osc.frequency.linearRampToValueAtTime(28, now + 2.2);

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(160, now + 0.15);

    g.gain.setValueAtTime(0.01, now);
    g.gain.linearRampToValueAtTime(0.35, now + 0.25);
    g.gain.exponentialRampToValueAtTime(0.01, now + 2.2);

    osc.connect(filter);
    filter.connect(g);
    g.connect(this.masterGain);
    osc.start(now + 0.15);
    osc.stop(now + 2.3);
  }

  createNoiseBurst(duration, cutoffFreq, gainVal) {
    if (!this.ctx) return null;
    const bufferSize = Math.max(1, Math.floor(this.ctx.sampleRate * duration));
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = Math.random() * 2 - 1;
    }
    const noise = this.ctx.createBufferSource();
    noise.buffer = buffer;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(cutoffFreq, this.ctx.currentTime);

    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(gainVal, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(this.masterGain);
    return noise;
  }

  playChassisScrape() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const scrapeNoise = this.createNoiseBurst(0.32, 900, 0.42);
    if (scrapeNoise) scrapeNoise.start(now);

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(75, now);
    osc.frequency.exponentialRampToValueAtTime(32, now + 0.28);
    g.gain.setValueAtTime(0.35, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.28);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.29);
  }

  playRadioStatic() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Squelch noise burst (radio gate open)
    const squelch = this.createNoiseBurst(0.08, 3800, 0.28);
    if (squelch) squelch.start(now);

    // 2. Vintage CB Roger Beep (Two-tone high chirp)
    const osc1 = this.ctx.createOscillator();
    const g1 = this.ctx.createGain();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(1180, now + 0.08);
    g1.gain.setValueAtTime(0.18, now + 0.08);
    g1.gain.exponentialRampToValueAtTime(0.001, now + 0.14);
    osc1.connect(g1);
    g1.connect(this.masterGain);
    osc1.start(now + 0.08);
    osc1.stop(now + 0.15);

    const osc2 = this.ctx.createOscillator();
    const g2 = this.ctx.createGain();
    osc2.type = 'sine';
    osc2.frequency.setValueAtTime(1760, now + 0.14);
    g2.gain.setValueAtTime(0.22, now + 0.14);
    g2.gain.exponentialRampToValueAtTime(0.001, now + 0.22);
    osc2.connect(g2);
    g2.connect(this.masterGain);
    osc2.start(now + 0.14);
    osc2.stop(now + 0.23);
  }

  playMissionSuccess() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // Triumphant orchestral chord: C5 -> E5 -> G5 -> C6
    const freqs = [523.25, 659.25, 783.99, 1046.50];
    freqs.forEach((freq, idx) => {
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = idx === 3 ? 'sine' : 'triangle';
      osc.frequency.setValueAtTime(freq, now + idx * 0.07);
      
      const startTime = now + idx * 0.07;
      g.gain.setValueAtTime(0.01, startTime);
      g.gain.linearRampToValueAtTime(0.28 / (idx + 1), startTime + 0.04);
      g.gain.exponentialRampToValueAtTime(0.001, startTime + 1.2);

      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(startTime);
      osc.stop(startTime + 1.25);
    });
  }

  playObjectiveDing() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(987.77, now); // B5
    osc.frequency.exponentialRampToValueAtTime(1318.51, now + 0.08); // E6

    g.gain.setValueAtTime(0.25, now);
    g.gain.exponentialRampToValueAtTime(0.001, now + 0.55);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.6);
  }

  playHorn(modelId = 'panda_4x4') {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // Frequencies tailored to vehicle origin & era:
    // Italian: Fiamm high-pitch dual trumpet (420Hz & 510Hz)
    // German: Bosch authoritative dual tone (340Hz & 415Hz)
    // British/Truck: Lucas heavy tone (290Hz & 370Hz)
    let f1 = 420;
    let f2 = 510;
    if (modelId === 'mercedes_w123' || modelId === 'mercedes_gwagen' || modelId === 'bmw_e30_ix' || modelId === 'audi_quattro') {
      f1 = 340;
      f2 = 415;
    } else if (modelId === 'defender_110' || modelId === 'volvo_245') {
      f1 = 295;
      f2 = 370;
    }

    [f1, f2].forEach((freq) => {
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(freq, now);
      // Slight pitch droop on attack
      osc.frequency.setValueAtTime(freq + 15, now);
      osc.frequency.exponentialRampToValueAtTime(freq, now + 0.04);

      const filter = this.ctx.createBiquadFilter();
      filter.type = 'bandpass';
      filter.frequency.setValueAtTime(freq, now);
      filter.Q.setValueAtTime(3.5, now);

      g.gain.setValueAtTime(0.01, now);
      g.gain.linearRampToValueAtTime(0.22, now + 0.02);
      g.gain.setValueAtTime(0.22, now + 0.35);
      g.gain.exponentialRampToValueAtTime(0.001, now + 0.45);

      osc.connect(filter);
      filter.connect(g);
      g.connect(this.masterGain);
      osc.start(now);
      osc.stop(now + 0.46);
    });
  }

  play4WDEngage(engaged = true) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // Steyr-Puch mechanical dog-clutch engage clunk
    const thud = this.createNoiseBurst(0.06, 600, 0.4);
    if (thud) thud.start(now);

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(engaged ? 180 : 120, now);
    osc.frequency.exponentialRampToValueAtTime(engaged ? 90 : 60, now + 0.09);

    g.gain.setValueAtTime(0.35, now);
    g.gain.exponentialRampToValueAtTime(0.001, now + 0.1);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.11);
  }

  playGlowPlugChime() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, now); // A5
    g.gain.setValueAtTime(0.2, now);
    g.gain.exponentialRampToValueAtTime(0.001, now + 0.8);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.85);
  }

  playRadioStatic() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Initial RF squelch burst (white noise through bandpass)
    const noise = this.createNoiseBurst(0.18, 1800, 0.28);
    if (noise) noise.start(now);

    // 2. Midland Alan 48 classic dual-tone Roger-Beep
    const beepTime = now + 0.2;
    [1046.5, 1318.5].forEach((freq, idx) => {
      const t = beepTime + idx * 0.08;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, t);
      g.gain.setValueAtTime(0.18, t);
      g.gain.exponentialRampToValueAtTime(0.001, t + 0.075);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.08);
    });
  }
}


