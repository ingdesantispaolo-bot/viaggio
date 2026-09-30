/**
 * THE LONG MERIDIAN - Enhanced Survival Cockpit Dashboard HUD
 * Premium industrial aesthetic, large analog dials with tick markings, textured tactile controls.
 */

export class DashboardHUD {
  constructor(container, vehicle, survivalState, touchInput, audioEngine, malfunctionManager = null) {
    this.container = container;
    this.vehicle = vehicle;
    this.survivalState = survivalState;
    this.touchInput = touchInput;
    this.audioEngine = audioEngine;
    this.malfunctionManager = malfunctionManager;

    this.onToggleMode = null;
    this.onOpenInventory = null;
    this.onOpenWorkshop = null;
    this.onOpenGarage = null;
    this.onOpenAtlas = null;
    this.onOpenStoryDiary = null;
    this.onScavenge = null;
    this.storyDirector = null;

    this.currentModelId = null;
    this.element = null;
    this.buildHUD();
  }

  buildHUD() {
    this.element = document.createElement('div');
    this.element.id = 'cockpit-dashboard';
    this.element.innerHTML = `
      <!-- Top Status Header Ticker -->
      <div class="cockpit-top-bar">
        <div class="top-bar-inner">
          <div class="biome-badge" id="hud-biome-badge">
            <span class="biome-dot"></span>
            <span class="biome-label">SETTORE:</span>
            <span id="hud-biome-name">THE RUSTY PERIPHERY</span>
          </div>

          <div class="telemetry-readout">
            <span class="tele-item"><span class="tele-lbl">GPS:</span> <strong id="hud-gps">LAT 64°12'N</strong></span>
            <span class="tele-item"><span class="tele-lbl">ELEV:</span> <strong id="hud-elev">380 M</strong></span>
            <span class="tele-item"><span class="tele-lbl">RAD:</span> <strong id="hud-rad-val" class="rad-safe">0.02 mSv</strong></span>
          </div>

          <div class="odometer-display">
            <span class="odo-label">CORRIDOIO NORD</span>
            <span id="hud-odometer">0000.0</span> <span class="odo-unit">KM</span>
          </div>

          <div class="time-display" id="hud-time">08:30</div>
        </div>
      </div>

      <!-- Story Objective Pinned Tracker -->
      <div class="story-objective-banner" id="story-objective-banner" title="Clicca per aprire il Diario di Bordo e Missioni">
        <div class="story-ch-badge" id="story-ch-badge">CAPITOLO I</div>
        <div class="story-obj-body">
          <span class="story-target-icon">🎯</span>
          <span class="story-obj-desc" id="story-obj-text">Mettiti in marcia e percorri i primi 200 metri lungo la costiera</span>
        </div>
        <div class="story-badge-action">DIARIO 📖</div>
      </div>

      <!-- Main Cockpit Console Container (Full-Width Vintage Industrial Cockpit) -->
      <div class="cockpit-console-frame">
        <!-- 1. Left Pod: Driver Steering Controls & Telemetry -->
        <div class="console-pod pod-left">
          <div class="pod-header">SISTEMA DI STERZO</div>
          
          <div class="turn-signals-bar">
            <div class="blinker-lamp" id="blinker-l" title="Indicatore di Direzione Sinistro">◀</div>
            <button class="hazard-button" id="btn-hazard" title="Luci di Emergenza (4 Frecce)">
              <span class="hazard-icon">⚠️</span>
              <span class="hazard-text">HAZARD</span>
            </button>
            <div class="blinker-lamp" id="blinker-r" title="Indicatore di Direzione Destro">▶</div>
          </div>

          <div class="steering-assembly">
            <div class="steering-wheel-graphic" id="steering-wheel">
              <div class="wheel-rim">
                <div class="wheel-spoke spoke-left"></div>
                <div class="wheel-spoke spoke-right"></div>
                <div class="wheel-spoke spoke-bottom"></div>
                <div class="wheel-hub" id="wheel-hub" title="Clacson • Premi per suonare (oppure premi H)">
                  <span class="hub-logo">MERIDIAN</span>
                </div>
              </div>
            </div>

            <div class="rack-telemetry-badge">
              <span class="rack-lbl">ANGOLO RACK:</span>
              <strong id="rack-angle-val">0.0°</strong>
            </div>

            <!-- Touch Steering Slider / Buttons -->
            <div class="steering-touch-track" id="steering-track">
              <span class="steer-arrow arrow-left">◀</span>
              <div class="steering-knob" id="steering-knob">
                <div class="knob-marker"></div>
              </div>
              <span class="steer-arrow arrow-right">▶</span>
            </div>
            <div class="control-label">TRASCINA O USA A / D</div>
          </div>
        </div>

        <!-- 2. Center Pod: Upper Aux Deck + Main Gauges + Switches -->
        <div class="console-pod pod-center">
          <div class="cluster-sub-header">
            <span class="cluster-brand-name" id="hud-cluster-brand">VEGLIA BORLETTI PANDA</span>
            <span class="cluster-gear-badge gear-drive" id="hud-gear-badge">▶ DRIVE</span>
            <span class="cluster-drivetrain-tag" id="hud-drivetrain-badge">4WD STEYR INSERIBILE</span>
          </div>

          <!-- Upper Vintage Auxiliary Equipment Console (Fills upper space authentically) -->
          <div class="vintage-aux-deck">
            <!-- 1. Climate & Air Louvers Unit -->
            <div class="aux-module aux-climate" title="Impianto Climatizzazione e Bocchette Abitacolo">
              <div class="aux-title-tiny">CLIMA & AERAZIONE</div>
              <div class="climate-louvers">
                <div class="air-vent-grill"><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slider"></div></div>
                <div class="air-vent-grill"><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slider"></div></div>
              </div>
              <div class="climate-controls">
                <span class="climate-icon">❄️</span>
                <div class="climate-slider-bar"><div class="climate-thumb" id="climate-thumb"></div></div>
                <span class="climate-icon">🔥</span>
                <div class="fan-knob-badge" id="fan-knob">FAN II</div>
              </div>
            </div>

            <!-- 2. Alaska Dalton CB Radio Transceiver -->
            <div class="aux-module aux-cb-radio" title="Ricetrasmettitore CB Midland Alan 48 - Canale Emergenza 19">
              <div class="aux-title-tiny">CB TRANSCEIVER • 27 MHz</div>
              <div class="cb-faceplate">
                <div class="cb-screen">
                  <span class="cb-ch">CH 19</span>
                  <span class="cb-status" id="cb-channel-name">MERIDIAN CONVOY • EMGCY</span>
                </div>
                <div class="cb-smeter">
                  <span class="smeter-lbl">SIGNAL</span>
                  <div class="smeter-bar-strip">
                    <span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot"></span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 3. Triple VDO Auxiliary Gauges (Battery Volts, Oil Press/Temp, Road Status & Ambient Temp) -->
            <div class="aux-module aux-triple-gauges">
              <div class="mini-vdo-gauge" title="Tensione Alternatore / Batteria">
                <div class="vdo-label">VOLT</div>
                <div class="vdo-val" id="vdo-volts">14.2V</div>
                <div class="vdo-bar"><div class="vdo-bar-fill" id="vdo-volts-fill" style="width: 82%"></div></div>
              </div>
              <div class="mini-vdo-gauge" title="Pressione Olio Motore">
                <div class="vdo-label">PRESS OLIO</div>
                <div class="vdo-val" id="vdo-oil">3.6 BAR</div>
                <div class="vdo-bar"><div class="vdo-bar-fill" id="vdo-oil-fill" style="width: 72%"></div></div>
              </div>
              <div class="mini-vdo-gauge vdo-surface-gauge" title="Stato Fondo Stradale e Temperatura Esterna">
                <div class="vdo-label">FONDO STRADALE</div>
                <div class="vdo-road-text" id="vdo-road-status" style="color: #22c55e;">ASFALTO 100%</div>
                <div class="vdo-ambient-temp" id="vdo-ext-temp">-12°C ARCTIC</div>
              </div>
            </div>
          </div>

          <!-- Dynamic Vehicle Cluster Main Row (Populated by setupVehicleDashboard) -->
          <div class="cluster-main-row" id="cluster-main-row">
            <!-- Will be dynamically injected by setupVehicleDashboard -->
          </div>

          <!-- Heavy Duty Cockpit Toggle Switch Deck -->
          <div class="heavy-switches-deck">
            <button class="cockpit-toggle-btn btn-engine" id="btn-ignition" title="Avvia/Spegni Motore">
              <div class="toggle-light-ring" id="led-ignition"></div>
              <span class="toggle-icon">⚡</span>
              <span class="toggle-title">ENGINE</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-lights" title="Fari Abbaglianti">
              <div class="toggle-light-ring on" id="led-lights"></div>
              <span class="toggle-icon">💡</span>
              <span class="toggle-title">LIGHTS</span>
            </button>

            <button class="cockpit-toggle-btn btn-mode-switch" id="btn-mode" title="Sali/Scendi dal Mezzo">
              <span class="toggle-icon" id="mode-icon">🚶</span>
              <span class="toggle-title" id="mode-text">DISMOUNT</span>
            </button>

            <button class="cockpit-toggle-btn btn-garage-switch" id="btn-garage" title="Garage & Parco Veicoli Classici">
              <span class="toggle-icon">🏎️</span>
              <span class="toggle-title">GARAGE</span>
            </button>

            <button class="cockpit-toggle-btn btn-repair-switch" id="btn-repair" title="Riparazione Guasti Sul Posto">
              <div class="toggle-light-ring" id="led-repair"></div>
              <span class="toggle-icon">🛠️</span>
              <span class="toggle-title" id="repair-text">REPAIR</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-inventory" title="Bagagliaio & Zaino">
              <span class="toggle-icon">🎒</span>
              <span class="toggle-title">CARGO</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-workshop" title="Officina Meccanica">
              <span class="toggle-icon">🔧</span>
              <span class="toggle-title">UPGRADE</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-atlas" title="Atlante del Meridiano & Log di Rotta">
              <span class="toggle-icon">🗺️</span>
              <span class="toggle-title">ATLAS</span>
            </button>

            <button class="cockpit-toggle-btn btn-diary-switch" id="btn-diary" title="Diario di Bordo & Missioni (Story)">
              <span class="toggle-icon">📖</span>
              <span class="toggle-title">STORY</span>
            </button>
          </div>
        </div>

        <!-- 3. Right Pod: Pedals & Transmission -->
        <div class="console-pod pod-right">
          <div class="pod-header">ACCELERATORE / FRENO</div>

          <div class="pod-aux-row">
            <div class="lighter-socket" title="Presa 12V Accendisigari"><div class="lighter-knob" id="lighter-knob">12V</div></div>
            <div class="glovebox-lock" title="Chiusura Vano Portaoggetti"><span class="lock-keyway"></span></div>
            <div class="gear-status-display" id="hud-gear-pedal-badge">DRIVE</div>
          </div>

          <div class="pedals-deck">
            <!-- Brake / Reverse Pedal -->
            <div class="cockpit-pedal pedal-brake" id="pedal-brake">
              <div class="pedal-ribs"></div>
              <span class="pedal-name">BRAKE / REV</span>
            </div>

            <!-- Throttle Pedal -->
            <div class="cockpit-pedal pedal-gas" id="pedal-gas">
              <div class="pedal-ribs"></div>
              <span class="pedal-name">THROTTLE</span>
            </div>
          </div>

          <!-- Handbrake Lever Bar -->
          <button class="handbrake-bar" id="btn-handbrake">
            <span class="hb-icon">🛑</span>
            <span class="hb-text">P - EMERGENCY PARK</span>
          </button>
        </div>
      </div>

      <!-- Scavenge / Proximity Action Floating Banner -->
      <div class="proximity-banner" id="proximity-banner" style="display: none;">
        <span class="banner-icon" id="prox-icon">⛽</span>
        <div class="banner-info">
          <div class="banner-title" id="prox-title">Stazione di Servizio</div>
          <div class="banner-subtitle">Avvicinati a piedi per recuperare rifornimenti</div>
        </div>
        <button class="banner-action-btn" id="btn-scavenge-action">ISPEZIONA</button>
      </div>

      <!-- Emergency Breakdown Diagnostic Alert Banner -->
      <div class="breakdown-alert-banner" id="breakdown-banner" style="display: none;">
        <div class="breakdown-icon-col">
          <span class="breakdown-pulsing-icon">⚠️</span>
        </div>
        <div class="breakdown-text-col">
          <div class="breakdown-title" id="breakdown-title">GUASTO CRITICO RILEVATO</div>
          <div class="breakdown-desc" id="breakdown-desc">Pneumatico squarciato. Sterzo compromesso.</div>
          <div class="breakdown-req" id="breakdown-req">Necessario: 1x Ruota di Scorta</div>
        </div>
        <div class="breakdown-action-col">
          <button class="breakdown-fix-btn" id="btn-breakdown-fix">RIPARA</button>
        </div>
      </div>

      <!-- Floating Incoming CB Radio Transmission Overlay -->
      <div class="cb-radio-dispatch-overlay" id="cb-radio-overlay" style="display: none;">
        <div class="cb-overlay-header">
          <div class="cb-live-indicator">
            <span class="cb-red-dot"></span>
            <span class="cb-rec-text">CB RX LIVE • 27.185 MHz</span>
          </div>
          <span class="cb-channel-badge">CH 19</span>
          <button class="cb-dismiss-btn" id="btn-dismiss-cb" title="Chiudi trasmissione (oppure premi [C] o [Esc])">✕ CHIUDI [C]</button>
        </div>
        <div class="cb-overlay-body">
          <div class="cb-avatar-box" id="cb-avatar">🐻</div>
          <div class="cb-text-box">
            <div class="cb-speaker-line">
              <strong id="cb-speaker-name">SOFIA MARETTI (CAPO SPEDIZIONE)</strong>
              <span class="cb-callsign-tag" id="cb-callsign">TRANS-EARTH DISPATCH</span>
            </div>
            <p class="cb-message-text" id="cb-message">Messaggio in arrivo...</p>
          </div>
        </div>
        <div class="cb-progress-bar-container">
          <div class="cb-progress-bar-fill" id="cb-progress-fill" style="width: 100%;"></div>
        </div>
        <div class="cb-hint-bar">
          <span>📻 Hai tempo per leggere. Premi <strong style="color:#f1f5f9;">[C]</strong> o <span class="cb-dismiss-link" id="cb-dismiss-link">✕ CHIUDI</span> quando hai finito</span>
          <span>📖 Rileggi sempre nel <strong>Diario (J)</strong></span>
        </div>
      </div>

      <!-- Objective Completed Achievement Toast -->
      <div class="story-achievement-toast" id="story-toast" style="display: none;">
        <span class="toast-trophy">🏆</span>
        <div class="toast-body">
          <div class="toast-header">OBIETTIVO SPEDIZIONE COMPLETATO!</div>
          <div class="toast-desc" id="toast-desc">Descrizione obiettivo</div>
        </div>
      </div>
    `;

    this.container.appendChild(this.element);
    const initialConfig = (this.vehicle && this.vehicle.getCurrentModelConfig) ? this.vehicle.getCurrentModelConfig() : (typeof CONFIG !== 'undefined' ? CONFIG.VEHICLES_CATALOG.panda_4x4 : null);
    this.setupVehicleDashboard(initialConfig);
    this.bindEvents();
  }

  bindEvents() {
    // 1. Ignition toggle
    const btnIgnition = this.element.querySelector('#btn-ignition');
    btnIgnition.addEventListener('click', () => {
      this.vehicle.isEngineOn = !this.vehicle.isEngineOn;
      if (this.vehicle.isEngineOn) {
        this.audioEngine.startEngine();
      } else {
        this.audioEngine.stopEngine();
      }
      this.updateSwitchesVisuals();
    });
    if (this.touchInput) {
      this.touchInput.onToggleIgnition = () => btnIgnition.click();
    }

    // 2. Lights toggle
    const btnLights = this.element.querySelector('#btn-lights');
    btnLights.addEventListener('click', () => {
      this.vehicle.toggleLights();
      this.updateSwitchesVisuals();
    });

    // 3. Mode switch (Drive vs Foot)
    const btnMode = this.element.querySelector('#btn-mode');
    btnMode.addEventListener('click', () => {
      if (this.onToggleMode) this.onToggleMode();
    });

    // 4. Inventory button
    const btnInv = this.element.querySelector('#btn-inventory');
    btnInv.addEventListener('click', () => {
      if (this.onOpenInventory) this.onOpenInventory();
    });

    // 4b. Quick Repair & Breakdown Fix buttons
    const btnRepair = this.element.querySelector('#btn-repair');
    if (btnRepair) {
      btnRepair.addEventListener('click', () => {
        this.executeEmergencyRepair();
      });
    }

    const btnBreakdownFix = this.element.querySelector('#btn-breakdown-fix');
    if (btnBreakdownFix) {
      btnBreakdownFix.addEventListener('click', () => {
        this.executeEmergencyRepair();
      });
    }

    // 5. Workshop & Garage buttons
    const btnWorkshop = this.element.querySelector('#btn-workshop');
    btnWorkshop.addEventListener('click', () => {
      if (this.onOpenWorkshop) this.onOpenWorkshop('upgrades');
    });

    const btnGarage = this.element.querySelector('#btn-garage');
    if (btnGarage) {
      btnGarage.addEventListener('click', () => {
        if (this.onOpenGarage) this.onOpenGarage();
        else if (this.onOpenWorkshop) this.onOpenWorkshop('garage');
      });
    }

    // 5b. Atlas Route Log button
    const btnAtlas = this.element.querySelector('#btn-atlas');
    if (btnAtlas) {
      btnAtlas.addEventListener('click', () => {
        if (this.onOpenAtlas) this.onOpenAtlas();
      });
    }

    // 5c. Story Logbook & Objective Banner buttons
    const btnDiary = this.element.querySelector('#btn-diary');
    if (btnDiary) {
      btnDiary.addEventListener('click', () => {
        if (this.onOpenStoryDiary) this.onOpenStoryDiary();
      });
    }

    const storyBanner = this.element.querySelector('#story-objective-banner');
    if (storyBanner) {
      storyBanner.addEventListener('click', () => {
        if (this.onOpenStoryDiary) this.onOpenStoryDiary();
      });
    }

    // 6. Proximity scavenge action
    const btnScavenge = this.element.querySelector('#btn-scavenge-action');
    btnScavenge.addEventListener('click', () => {
      if (this.onScavenge) this.onScavenge();
    });

    // 7. Touch Steer Track & Wheel Rotation
    const track = this.element.querySelector('#steering-track');
    const knob = this.element.querySelector('#steering-knob');
    const wheel = this.element.querySelector('#steering-wheel');
    let isSteering = false;

    const handleSteerMove = (clientX) => {
      const rect = track.getBoundingClientRect();
      const relX = clientX - rect.left;
      const normalized = (relX / rect.width) * 2 - 1;
      const clamped = Math.max(-1, Math.min(1, normalized));
      this.touchInput.setTouchSteer(clamped, true);
      knob.style.transform = `translateX(${clamped * (rect.width * 0.42)}px)`;
      if (wheel) {
        wheel.style.transform = `rotate(${clamped * 65}deg)`;
      }
    };

    track.addEventListener('pointerdown', (e) => {
      isSteering = true;
      track.setPointerCapture(e.pointerId);
      handleSteerMove(e.clientX);
    });

    track.addEventListener('pointermove', (e) => {
      if (isSteering) handleSteerMove(e.clientX);
    });

    const resetSteer = (e) => {
      isSteering = false;
      this.touchInput.setTouchSteer(0, false);
      knob.style.transform = `translateX(0px)`;
      if (wheel) wheel.style.transform = `rotate(0deg)`;
      if (e && e.pointerId && track.hasPointerCapture && track.hasPointerCapture(e.pointerId)) {
        track.releasePointerCapture(e.pointerId);
      }
    };
    track.addEventListener('pointerup', resetSteer);
    track.addEventListener('pointercancel', resetSteer);

    // 7b. Steering Wheel Center Hub (Horn / Clacson)
    const wheelHub = this.element.querySelector('#wheel-hub') || this.element.querySelector('.wheel-hub');
    if (wheelHub) {
      wheelHub.style.cursor = 'pointer';
      wheelHub.addEventListener('pointerdown', (e) => {
        e.stopPropagation();
        if (this.vehicle && this.vehicle.honkHorn) {
          this.vehicle.honkHorn();
        }
        wheelHub.classList.add('hub-pressed');
        setTimeout(() => wheelHub.classList.remove('hub-pressed'), 350);
      });
    }

    // 8. Throttle Pedal
    const pedalGas = this.element.querySelector('#pedal-gas');
    pedalGas.addEventListener('pointerdown', (e) => {
      pedalGas.classList.add('pressed');
      this.touchInput.setTouchThrottle(1.0, true);
      if (e.pointerId && pedalGas.setPointerCapture) pedalGas.setPointerCapture(e.pointerId);
    });
    const releaseGas = (e) => {
      pedalGas.classList.remove('pressed');
      this.touchInput.setTouchThrottle(0.0, false);
      if (e && e.pointerId && pedalGas.hasPointerCapture && pedalGas.hasPointerCapture(e.pointerId)) {
        pedalGas.releasePointerCapture(e.pointerId);
      }
    };
    pedalGas.addEventListener('pointerup', releaseGas);
    pedalGas.addEventListener('pointercancel', releaseGas);
    pedalGas.addEventListener('pointerleave', releaseGas);

    // 9. Brake Pedal
    const pedalBrake = this.element.querySelector('#pedal-brake');
    pedalBrake.addEventListener('pointerdown', (e) => {
      pedalBrake.classList.add('pressed');
      this.touchInput.setTouchBrake(1.0, true);
      if (e.pointerId && pedalBrake.setPointerCapture) pedalBrake.setPointerCapture(e.pointerId);
    });
    const releaseBrake = (e) => {
      pedalBrake.classList.remove('pressed');
      this.touchInput.setTouchBrake(0.0, false);
      if (e && e.pointerId && pedalBrake.hasPointerCapture && pedalBrake.hasPointerCapture(e.pointerId)) {
        pedalBrake.releasePointerCapture(e.pointerId);
      }
    };
    pedalBrake.addEventListener('pointerup', releaseBrake);
    pedalBrake.addEventListener('pointercancel', releaseBrake);
    pedalBrake.addEventListener('pointerleave', releaseBrake);

    // 10. Handbrake
    const btnHb = this.element.querySelector('#btn-handbrake');
    btnHb.addEventListener('pointerdown', () => {
      btnHb.classList.add('active');
      this.touchInput.setTouchHandbrake(true);
    });
    const releaseHb = () => {
      btnHb.classList.remove('active');
      this.touchInput.setTouchHandbrake(false);
    };
    btnHb.addEventListener('pointerup', releaseHb);
    btnHb.addEventListener('pointercancel', releaseHb);

    // 11. Hazard Light Toggle (4 Frecce)
    const btnHazard = this.element.querySelector('#btn-hazard');
    if (btnHazard) {
      btnHazard.addEventListener('click', () => {
        this.hazardActive = !this.hazardActive;
        btnHazard.classList.toggle('active', this.hazardActive);
        if (this.audioEngine && this.audioEngine.playSwitchClick) {
          this.audioEngine.playSwitchClick(this.hazardActive);
        }
      });
    }

    // 12. 12V Cigarette Lighter
    const lighterKnob = this.element.querySelector('#lighter-knob');
    if (lighterKnob) {
      lighterKnob.addEventListener('click', () => {
        lighterKnob.classList.add('pushed');
        if (this.audioEngine && this.audioEngine.playSwitchClick) {
          this.audioEngine.playSwitchClick(true);
        }
        setTimeout(() => {
          lighterKnob.classList.remove('pushed');
          if (this.audioEngine && this.audioEngine.playSwitchClick) {
            this.audioEngine.playSwitchClick(false);
          }
        }, 3000);
      });
    }

    // 13. Blower Fan Speed Selector
    const fanKnob = this.element.querySelector('#fan-knob');
    if (fanKnob) {
      const speeds = ['OFF', 'FAN I', 'FAN II', 'FAN III', 'FAN IV'];
      let speedIdx = 2;
      fanKnob.addEventListener('click', () => {
        speedIdx = (speedIdx + 1) % speeds.length;
        fanKnob.textContent = speeds[speedIdx];
        if (this.audioEngine && this.audioEngine.playSwitchClick) {
          this.audioEngine.playSwitchClick(speedIdx > 0);
        }
      });
    }

    // 14. CB Radio Dispatch Dismiss Controls & Hotkeys
    const btnDismissCb = this.element.querySelector('#btn-dismiss-cb');
    const linkDismissCb = this.element.querySelector('#cb-dismiss-link');
    const dismissRadio = () => {
      if (this.storyDirector) {
        this.storyDirector.dismissRadioMessage();
      } else {
        const overlay = this.element.querySelector('#cb-radio-overlay');
        if (overlay) overlay.style.display = 'none';
      }
    };
    if (btnDismissCb) btnDismissCb.addEventListener('click', dismissRadio);
    if (linkDismissCb) linkDismissCb.addEventListener('click', dismissRadio);

    // Keyboard listener for 'KeyC', 'KeyX', or 'Escape' to dismiss radio message
    window.addEventListener('keydown', (e) => {
      if (e.code === 'KeyC' || e.code === 'KeyX' || e.code === 'Escape') {
        const overlay = this.element.querySelector('#cb-radio-overlay');
        if (overlay && overlay.style.display !== 'none') {
          dismissRadio();
        }
      }
    });
  }

  updateSwitchesVisuals() {
    const ledIgnition = this.element.querySelector('#led-ignition');
    const ledLights = this.element.querySelector('#led-lights');

    if (ledIgnition) {
      ledIgnition.className = `toggle-light-ring ${this.vehicle.isEngineOn ? 'on active-engine' : ''}`;
    }
    if (ledLights) {
      ledLights.className = `toggle-light-ring ${this.vehicle.isLightsOn ? 'on' : ''}`;
    }
  }

  setModeVisual(isOnFoot) {
    const modeIcon = this.element.querySelector('#mode-icon');
    const modeText = this.element.querySelector('#mode-text');
    if (isOnFoot) {
      modeIcon.textContent = '🚗';
      modeText.textContent = 'ENTER CAR';
    } else {
      modeIcon.textContent = '🚶';
      modeText.textContent = 'DISMOUNT';
    }
  }

  showNearbyPOI(poi) {
    const banner = this.element.querySelector('#proximity-banner');
    if (!poi || poi.scavenged) {
      banner.style.display = 'none';
      return;
    }
    banner.style.display = 'flex';
    this.element.querySelector('#prox-icon').textContent = poi.config.icon || (poi.isSettlement ? '🏛️' : '📍');
    this.element.querySelector('#prox-title').textContent = poi.config.name;

    const sub = this.element.querySelector('.banner-subtitle');
    const actBtn = this.element.querySelector('#btn-scavenge-action');
    if (poi.isSettlement) {
      if (sub) sub.textContent = 'COMUNITÀ POPOLATA — COMMERCIO, STORIA & RIFORNIMENTI';
      if (actBtn) actBtn.textContent = 'ACCEDI ALL\'HUB';
      banner.className = 'proximity-banner settlement-banner-active';
    } else {
      if (sub) sub.textContent = 'SITO STRUTTURALE — RECUPERA MATERIALI E RISORSE';
      if (actBtn) actBtn.textContent = 'ISPEZIONA';
      banner.className = 'proximity-banner';
    }
  }

  setupVehicleDashboard(cur) {
    if (!cur) return;
    this.currentModelId = cur.id;

    // 1. Remove previous dash themes and apply current car theme
    this.element.className = this.element.className.replace(/\bdash-theme-\S+/g, '').trim();
    this.element.classList.add(`dash-theme-${cur.id}`);

    // 2. Custom Steering Wheel per manufacturer & model
    const wheelRim = this.element.querySelector('#steering-wheel .wheel-rim');
    const hubLogo = this.element.querySelector('#steering-wheel .hub-logo');
    if (wheelRim) {
      wheelRim.classList.remove('wheel-alfa', 'wheel-delta', 'wheel-bmw', 'wheel-mercedes');
      if (cur.id === 'alfa_giulia') wheelRim.classList.add('wheel-alfa');
      else if (cur.id === 'delta_integrale') wheelRim.classList.add('wheel-delta');
      else if (cur.id === 'bmw_e30_ix') wheelRim.classList.add('wheel-bmw');
      else if (cur.id.startsWith('mercedes')) wheelRim.classList.add('wheel-mercedes');
    }
    if (hubLogo) {
      if (cur.id === 'alfa_giulia') hubLogo.textContent = 'ALFA';
      else if (cur.id === 'delta_integrale') hubLogo.textContent = 'HF';
      else if (cur.id === 'bmw_e30_ix') hubLogo.textContent = '///M';
      else if (cur.id.startsWith('mercedes')) hubLogo.textContent = 'BENZ';
      else if (cur.id === 'volvo_245') hubLogo.textContent = 'VOLVO';
      else if (cur.id === 'defender_110') hubLogo.textContent = 'LAND';
      else if (cur.id === 'audi_quattro') hubLogo.textContent = 'QUATTRO';
      else if (cur.id === 'peugeot_504_dangel') hubLogo.textContent = 'DANGEL';
      else if (cur.id === 'golf_country') hubLogo.textContent = 'SYNCRO';
      else hubLogo.textContent = 'FIAT';
    }

    // 3. Cluster Headers
    const brandEl = this.element.querySelector('#hud-cluster-brand');
    if (brandEl) brandEl.textContent = `${cur.dashTheme.clusterName} — ${cur.maker.toUpperCase()} ${cur.name.toUpperCase()}`;
    const driveEl = this.element.querySelector('#hud-drivetrain-badge');
    if (driveEl) driveEl.textContent = cur.drivetrainBadge;

    // 4. Construct cluster row HTML
    const clusterRow = this.element.querySelector('#cluster-main-row');
    if (!clusterRow) return;

    const maxSpeed = cur.dashTheme.speedoMax || 160;
    const speedTicksSvg = this.generateSpeedoTicks(maxSpeed, cur.dashTheme.tickColor || '#94a3b8');

    // 1. Dial 1: Speedometer (KM/H)
    const speedoHtml = `
      <div class="dial-housing" title="Tachimetro Stradale (KM/H)">
        <div class="gauge-dial">
          <svg class="gauge-svg" viewBox="0 0 120 120">
            <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
            <circle cx="60" cy="60" r="48" class="dial-track-groove" />
            ${speedTicksSvg}
            <line id="speed-needle" class="gauge-needle" x1="60" y1="60" x2="60" y2="22" stroke="${cur.dashTheme.needleColor || '#ef4444'}" />
            <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
            <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
          </svg>
          <div class="dial-digital-box">
            <span class="dial-val" id="dial-speed-val">0</span>
            <span class="dial-unit">KM/H</span>
          </div>
        </div>
      </div>
    `;

    // 2. Dial 2: Tachometer / Contagiri Motore (RPM x1000)
    const redline = cur.dashTheme.redlineRpm || 6000;
    const maxRpm = Math.ceil(redline / 1000) * 1000 + 1000;
    const tachTicksSvg = this.generateTachTicks(redline, maxRpm, cur.dashTheme.tickColor || '#94a3b8');
    const tachHtml = `
      <div class="dial-housing" title="Contagiri Motore (RPM x1000)">
        <div class="gauge-dial">
          <svg class="gauge-svg" viewBox="0 0 120 120">
            <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
            <circle cx="60" cy="60" r="48" class="dial-track-groove" />
            ${tachTicksSvg}
            <line id="rpm-needle" class="gauge-needle" x1="60" y1="60" x2="60" y2="22" stroke="${cur.dashTheme.needleColor || '#ef4444'}" />
            <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
            <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
          </svg>
          <div class="dial-digital-box">
            <span class="dial-val" id="dial-rpm-val">0.8</span>
            <span class="dial-unit">RPM x1000</span>
          </div>
        </div>
      </div>
    `;

    // 3. Center MFD with Vitals, Annunciators, and Model-Specific Aux Instrument
    const auxInstrumentHtml = this.generateCustomAuxWidgetHtml(cur);

    const mfdHtml = `
      <div class="mfd-screen">
        <div class="mfd-vitals-stack">
          <div class="mfd-row">
            <span class="mfd-icon">⛽</span>
            <span class="mfd-label">FUEL</span>
            <div class="mfd-bar-track">
              <div class="mfd-bar-fill fuel-bar" id="hud-fuel-fill" style="width: 100%"></div>
            </div>
            <span class="mfd-val" id="hud-fuel-num">--L</span>
          </div>
          <div class="mfd-row">
            <span class="mfd-icon">🛡️</span>
            <span class="mfd-label">HULL</span>
            <div class="mfd-bar-track">
              <div class="mfd-bar-fill hull-bar" id="hud-hull-fill" style="width: 100%"></div>
            </div>
            <span class="mfd-val" id="hud-hull-num">100%</span>
          </div>
          <div class="mfd-row">
            <span class="mfd-icon">🌡️</span>
            <span class="mfd-label">COOLANT</span>
            <div class="mfd-bar-track">
              <div class="mfd-bar-fill temp-bar" id="hud-temp-fill" style="width: 40%"></div>
            </div>
            <span class="mfd-val" id="hud-temp-num">80°C</span>
          </div>
        </div>

        <div class="annunciator-panel">
          <div class="ann-lamp" id="lamp-tire"><span class="ann-dot"></span> TIRE</div>
          <div class="ann-lamp" id="lamp-leak"><span class="ann-dot"></span> RAD</div>
          <div class="ann-lamp" id="lamp-elec"><span class="ann-dot"></span> ELEC</div>
          <div class="ann-lamp" id="lamp-fuel"><span class="ann-dot"></span> PUMP</div>
          <div class="ann-lamp ann-glow" id="lamp-glow" style="${cur.isDiesel ? '' : 'display: none;'}"><span class="ann-dot"></span> GLOW</div>
        </div>

        <div class="survivor-pills-row">
          <div class="pill-box"><span class="pill-title">HP</span><strong id="hud-hp">100</strong></div>
          <div class="pill-box"><span class="pill-title">HUNGER</span><strong id="hud-hunger">100%</strong></div>
          <div class="pill-box"><span class="pill-title">THIRST</span><strong id="hud-thirst">100%</strong></div>
          <div class="pill-box"><span class="pill-title">BODY</span><strong id="hud-temp">37.0°C</strong></div>
        </div>

        <!-- Live Terrain & Surface Telemetry Bar -->
        <div class="terrain-radar-strip" id="hud-terrain-strip">
          <span class="terrain-icon" id="hud-terrain-icon">🛣️</span>
          <span class="terrain-text" id="hud-terrain-text">ASFALTO (CARREGGIATA)</span>
          <span class="terrain-badge" id="hud-terrain-badge" style="background: rgba(34, 197, 94, 0.2); color: #22c55e;">GRIP 100%</span>
        </div>

        <!-- Dedicated Vehicle-Specific Instrument Console -->
        ${auxInstrumentHtml}
      </div>
    `;

    // 4. Dial 4: Clinometro 4x4 Inclinometro Off-Road (Pendenza & Rollio)
    const inclinometerHtml = `
      <div class="dial-housing" title="Clinometro & Inclinometro 4x4 (Pendenza Salita/Discesa e Rollio Laterale)">
        <div class="gauge-dial">
          <svg class="gauge-svg" viewBox="0 0 120 120">
            <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
            <circle cx="60" cy="60" r="48" class="dial-track-groove" />
            <!-- Pitch scale lines -->
            <line x1="28" y1="46" x2="42" y2="46" stroke="#64748b" stroke-width="1.8" />
            <line x1="78" y1="46" x2="92" y2="46" stroke="#64748b" stroke-width="1.8" />
            <line x1="24" y1="60" x2="44" y2="60" stroke="#38bdf8" stroke-width="2.4" />
            <line x1="76" y1="60" x2="96" y2="60" stroke="#38bdf8" stroke-width="2.4" />
            <line x1="28" y1="74" x2="42" y2="74" stroke="#64748b" stroke-width="1.8" />
            <line x1="78" y1="74" x2="92" y2="74" stroke="#64748b" stroke-width="1.8" />
            <g id="incline-horizon-group" transform="translate(60,60)">
              <line id="incline-horizon-line" x1="-32" y1="0" x2="32" y2="0" stroke="#fbbf24" stroke-width="2.5" />
              <polygon points="0,-4 -4,4 4,4" fill="#ef4444" />
            </g>
            <circle cx="60" cy="60" r="14" fill="none" stroke="#475569" stroke-width="1.5" stroke-dasharray="3,2" />
            <!-- 4x4 Vehicle Center Indicator -->
            <rect x="52" y="58" width="16" height="5" rx="1.5" fill="#94a3b8" />
            <circle cx="54" cy="63" r="1.8" fill="#38bdf8" />
            <circle cx="66" cy="63" r="1.8" fill="#38bdf8" />
            <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
          </svg>
          <div class="dial-digital-box" style="margin-top: 40px;">
            <span class="dial-val" id="dial-incline-val" style="font-size: 14px; color: #fbbf24; font-family: var(--font-tech);">0°</span>
            <span class="dial-unit" style="font-size: 9px; letter-spacing: 0.5px;">CLINOMETRO</span>
          </div>
        </div>
      </div>
    `;

    // 5. Dial 5: Veglia Borletti Quartz Clock or Turbo/Econometer
    let rightDialHtml = '';
    if (cur.id === 'panda_4x4') {
      const clockTicksSvg = this.generateClockTicks();
      rightDialHtml = `
        <div class="dial-housing" title="Orologio Analogico Veglia Borletti Quartz">
          <div class="gauge-dial">
            <svg class="gauge-svg" viewBox="0 0 120 120">
              <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
              <circle cx="60" cy="60" r="48" class="dial-track-groove" />
              ${clockTicksSvg}
              <line id="clock-hour-needle" class="gauge-needle clock-needle-hour" x1="60" y1="60" x2="60" y2="34" />
              <line id="clock-min-needle" class="gauge-needle clock-needle-min" x1="60" y1="60" x2="60" y2="20" />
              <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
              <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
            </svg>
            <div class="dial-digital-box">
              <span class="dial-val" id="dial-clock-val" style="font-size:12px;letter-spacing:1px;color:#38bdf8;">VEGLIA</span>
              <span class="dial-unit">QUARTZ</span>
            </div>
          </div>
        </div>
      `;
    } else {
      let subGaugeHtml = '';
      if (cur.hasTurbo) {
        const maxBoost = cur.turboBoostMaxBar || 1.5;
        const turboTicksSvg = this.generateTurboTicks(maxBoost);
        subGaugeHtml = `
          <div class="turbo-mini-gauge" id="turbo-dial-housing" title="Manometro Sovralimentazione Turbo (Bar)">
            <svg class="gauge-svg" viewBox="0 0 120 120">
              <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="#080b0e" />
              ${turboTicksSvg}
              <line id="turbo-needle" class="gauge-needle" x1="60" y1="60" x2="60" y2="24" stroke="${cur.dashTheme.needleColor || '#ef4444'}" />
              <circle cx="60" cy="60" r="6" class="gauge-center-bezel" />
            </svg>
            <span class="turbo-mini-val" id="dial-turbo-val">0.0</span>
            <span class="turbo-mini-unit">BAR</span>
          </div>
        `;
      }
      const clockTicksSvg = this.generateClockTicks();
      rightDialHtml = `
        <div style="display:flex;flex-direction:column;align-items:center;">
          <div class="dial-housing" title="Orologio di Bordo">
            <div class="gauge-dial">
              <svg class="gauge-svg" viewBox="0 0 120 120">
                <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
                <circle cx="60" cy="60" r="48" class="dial-track-groove" />
                ${clockTicksSvg}
                <line id="clock-hour-needle" class="gauge-needle clock-needle-hour" x1="60" y1="60" x2="60" y2="34" />
                <line id="clock-min-needle" class="gauge-needle clock-needle-min" x1="60" y1="60" x2="60" y2="20" />
                <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
                <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
              </svg>
              <div class="dial-digital-box">
                <span class="dial-val" id="dial-clock-val" style="font-size:12px;letter-spacing:1px;color:#38bdf8;">TIME</span>
                <span class="dial-unit">CHRONO</span>
              </div>
            </div>
          </div>
          ${subGaugeHtml}
        </div>
      `;
    }

    // Symmetric 5-Element Center Binnacle: Speedo | Tach | MFD | Clinometer | Clock/Turbo
    clusterRow.innerHTML = speedoHtml + tachHtml + mfdHtml + inclinometerHtml + rightDialHtml;

    // Interactive Model Controls (Steyr 4WD Lever, Primina, etc.)
    const steyrConsole = this.element.querySelector('.steyr-lever-console');
    if (steyrConsole) {
      steyrConsole.style.cursor = 'pointer';
      steyrConsole.title = 'Leva Trazione Steyr-Puch: Clicca per inserire/disinserire 4WD (Tasto X)';
      steyrConsole.onclick = () => {
        if (this.vehicle && this.vehicle.toggle4WD) {
          const res = this.vehicle.toggle4WD();
          if (res) this.showToast(res.message);
        }
      };
    }
    const priminaLamp = this.element.querySelector('#lamp-primina');
    if (priminaLamp) {
      priminaLamp.style.cursor = 'pointer';
      priminaLamp.title = 'Primina Ridotta: Clicca per inserire/disinserire marcia ridotta (Tasto P)';
      priminaLamp.onclick = () => {
        if (this.vehicle && this.vehicle.togglePrimina) {
          const res = this.vehicle.togglePrimina();
          if (res) this.showToast(res.message);
        }
      };
    }
  }

  generateCustomAuxWidgetHtml(cur) {
    switch (cur.id) {
      case 'panda_4x4':
        return `
          <div class="steyr-lever-console">
            <div class="steyr-lever-graphic">
              <div class="steyr-boot"><div class="steyr-knob" id="steyr-knob-pos"></div></div>
              <span style="font-size:8px;font-family:var(--font-tech);color:#94a3b8;">STEYR-PUCH</span>
            </div>
            <div class="steyr-indicators">
              <div class="steyr-lamp active-steyr" id="lamp-4wd-steyr"><span class="ann-dot" style="background:#22c55e;"></span> 4WD INSERITA</div>
              <div class="steyr-lamp" id="lamp-primina"><span class="ann-dot" style="background:#eab308;"></span> PRIMINA CRAWLER</div>
            </div>
          </div>
        `;
      case 'delta_integrale':
        return `
          <div class="torsen-split-widget">
            <div class="torsen-header"><span>TORSEN AWD RIPARTIZIONE</span><span id="torsen-split-text">47% ANT / 53% POST</span></div>
            <div class="torsen-bar-housing"><div class="torsen-front-fill" id="torsen-front-bar" style="width:47%;"></div><div class="torsen-rear-fill"></div><div class="torsen-center-mark"></div></div>
          </div>
        `;
      case 'mercedes_w123':
        return `
          <div class="bosch-glow-widget">
            <div class="glow-coil-graphic" id="bosch-coil-box"><div class="glow-coil-filament"></div></div>
            <div style="font-family:var(--font-tech);font-size:8px;color:#fdba74;">BOSCH GLÜHZEIT<br><strong id="bosch-glow-status" style="color:#f97316;">VORGELÜHT</strong></div>
            <div style="font-family:var(--font-tech);font-size:8px;color:#cbd5e1;text-align:right;">ÖLDRUCK<br><strong id="w123-oil-val" style="font-size:11px;color:#fb923c;">3.0 BAR</strong></div>
          </div>
        `;
      case 'mercedes_gwagen':
        return `
          <div class="gwagen-diff-locks">
            <div class="diff-lock-lever diff-lock-engaged"><span style="color:#ef4444;">REAR</span><div class="diff-switch-body"><div class="diff-switch-toggle"></div></div><div class="diff-lock-led"></div></div>
            <div class="diff-lock-lever diff-lock-engaged"><span style="color:#ef4444;">CENTER</span><div class="diff-switch-body"><div class="diff-switch-toggle"></div></div><div class="diff-lock-led"></div></div>
            <div class="diff-lock-lever"><span style="color:#94a3b8;">FRONT</span><div class="diff-switch-body"><div class="diff-switch-toggle"></div></div><div class="diff-lock-led"></div></div>
          </div>
          <div class="inclinometer-widget">
            <div class="incline-dial"><div class="incline-horizon" id="incline-horizon-bar"></div><div class="incline-car-silhouette"></div></div>
            <div class="incline-values"><span>ROLL: <strong id="incline-roll-val">0.0°</strong></span><span>PITCH: <strong id="incline-pitch-val">0.0°</strong></span></div>
          </div>
        `;
      case 'defender_110':
        return `
          <div class="defender-volts-widget">
            <span class="volts-label">SMITHS DUAL BATTERY / WINCH</span>
            <span class="volts-val" id="defender-volts-num">14.2 V</span>
          </div>
          <div class="lt230-transfer-schematic">
            <span class="lt230-chip active-hi">HIGH RATIO</span>
            <span class="lt230-chip active-lock">DIFF-LOCK ENGAGED</span>
          </div>
        `;
      case 'volvo_245':
        return `
          <div class="volvo-safety-widget">
            <div class="volvo-lamp-chip active-lambda" id="volvo-lambda"><span class="ann-dot" style="background:#f59e0b;"></span> LAMBDASOND (λ)</div>
            <div class="volvo-lamp-chip" id="volvo-frost"><span class="ann-dot" style="background:#38bdf8;"></span> FROST ALERT ❄️</div>
          </div>
        `;
      case 'audi_quattro':
        return `
          <div class="quattro-schematic-widget">
            <svg class="quattro-chassis-svg" viewBox="0 0 50 30"><rect x="5" y="4" width="8" height="6" fill="#38bdf8"/><rect x="37" y="4" width="8" height="6" fill="#38bdf8"/><rect x="5" y="20" width="8" height="6" fill="#ef4444"/><rect x="37" y="20" width="8" height="6" fill="#ef4444"/><line x1="25" y1="7" x2="25" y2="23" stroke="#e2e8f0" stroke-width="2"/><circle cx="25" cy="15" r="4" fill="#ef4444"/></svg>
            <div class="quattro-status-text">QUATTRO PERMANENT AWD<br><strong style="color:#ef4444;">TORQUE SENSING ACTIVE</strong></div>
          </div>
        `;
      case 'bmw_e30_ix':
        return `
          <div class="bmw-si-widget">
            <span class="si-title">SI-BOARD</span>
            <div class="si-leds-track" id="bmw-si-leds">
              <div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led yellow"></div><div class="si-led red"></div>
            </div>
            <span style="font-size:7px;color:#94a3b8;">SERVICE</span>
          </div>
        `;
      case 'alfa_giulia':
        return `
          <div class="alfa-vintage-aux-widget">
            <div><span class="alfa-oil-label">PRESSIONE OLIO (KG/CM²)</span><br><span class="alfa-oil-num" id="alfa-oil-val">4.5</span></div>
            <div class="alfa-choke-knob"><div class="choke-handle"></div><span>STARTER (ARIA)</span></div>
          </div>
        `;
      case 'peugeot_504_dangel':
        return `
          <div class="safari-compass-widget">
            <div class="compass-rose" id="safari-compass-rose"><div class="compass-needle"></div><span style="font-size:6px;position:absolute;top:1px;color:#ef4444;font-weight:bold;">N</span></div>
            <div style="display:flex;flex-direction:column;gap:1px;"><span style="font-size:7px;color:#94a3b8;">RORETTE EXPEDITION</span><span class="compass-cardinal" id="compass-heading-text">N 012°</span></div>
          </div>
        `;
      case 'golf_country':
      default:
        return `
          <div class="golf-syncro-widget">
            <div class="syncro-slip-lamp" id="golf-syncro-slip"><span class="ann-dot" style="background:#4ade80;"></span> SYNCRO VISCOUS AWD</div>
            <div class="golf-bullbar-toggle"><div class="bullbar-led"></div><span>HELLA RALLYE</span></div>
          </div>
        `;
    }
  }

  generateSpeedoTicks(maxSpeed, tickColor) {
    let svg = '';
    const step = maxSpeed >= 240 ? 40 : 20;
    const numSteps = Math.floor(maxSpeed / step);
    for (let i = 0; i <= numSteps; i++) {
      const spd = i * step;
      const pct = spd / maxSpeed;
      const angleDeg = -135 + pct * 270;
      const rad = (angleDeg * Math.PI) / 180;
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + 40 * Math.sin(rad)).toFixed(1);
      const y2 = (60 - 40 * Math.cos(rad)).toFixed(1);
      const tx = (60 + 30 * Math.sin(rad)).toFixed(1);
      const ty = (60 - 30 * Math.cos(rad) + 3.5).toFixed(1);
      svg += `<line class="tick major" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${tickColor}" stroke-width="2.2" />`;
      svg += `<text x="${tx}" y="${ty}" font-family="monospace" font-size="9" fill="${tickColor}" text-anchor="middle" font-weight="900">${spd}</text>`;
      if (i < numSteps) {
        const halfPct = (spd + step / 2) / maxSpeed;
        const halfAngle = -135 + halfPct * 270;
        const halfRad = (halfAngle * Math.PI) / 180;
        const mx1 = (60 + 48 * Math.sin(halfRad)).toFixed(1);
        const my1 = (60 - 48 * Math.cos(halfRad)).toFixed(1);
        const mx2 = (60 + 44 * Math.sin(halfRad)).toFixed(1);
        const my2 = (60 - 44 * Math.cos(halfRad)).toFixed(1);
        svg += `<line class="tick minor" x1="${mx1}" y1="${my1}" x2="${mx2}" y2="${my2}" stroke="${tickColor}" stroke-width="1.2" opacity="0.65" />`;
      }
    }
    return svg;
  }

  generateTachTicks(redlineRpm, maxRpm, tickColor) {
    let svg = '';
    const maxK = Math.floor(maxRpm / 1000);
    const redlineK = redlineRpm / 1000;
    for (let k = 0; k <= maxK; k++) {
      const pct = (k * 1000) / maxRpm;
      const angleDeg = -135 + pct * 270;
      const rad = (angleDeg * Math.PI) / 180;
      const isRedline = k >= redlineK;
      const col = isRedline ? '#ef4444' : tickColor;
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + 40 * Math.sin(rad)).toFixed(1);
      const y2 = (60 - 40 * Math.cos(rad)).toFixed(1);
      const tx = (60 + 30 * Math.sin(rad)).toFixed(1);
      const ty = (60 - 30 * Math.cos(rad) + 3.5).toFixed(1);
      svg += `<line class="tick ${isRedline ? 'redline' : 'major'}" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${col}" stroke-width="2.4" />`;
      svg += `<text x="${tx}" y="${ty}" font-family="monospace" font-size="9.5" fill="${col}" text-anchor="middle" font-weight="900">${k}</text>`;
      if (k < maxK) {
        const halfPct = ((k + 0.5) * 1000) / maxRpm;
        const halfAngle = -135 + halfPct * 270;
        const halfRad = (halfAngle * Math.PI) / 180;
        const isHalfRed = (k + 0.5) >= redlineK;
        const hCol = isHalfRed ? '#ef4444' : tickColor;
        const mx1 = (60 + 48 * Math.sin(halfRad)).toFixed(1);
        const my1 = (60 - 48 * Math.cos(halfRad)).toFixed(1);
        const mx2 = (60 + 44 * Math.sin(halfRad)).toFixed(1);
        const my2 = (60 - 44 * Math.cos(halfRad)).toFixed(1);
        svg += `<line class="tick minor" x1="${mx1}" y1="${my1}" x2="${mx2}" y2="${my2}" stroke="${hCol}" stroke-width="1.3" opacity="0.65" />`;
      }
    }
    return svg;
  }

  generateClockTicks() {
    let svg = '';
    for (let h = 1; h <= 12; h++) {
      const angleDeg = h * 30;
      const rad = (angleDeg * Math.PI) / 180;
      const isMajor = (h % 3 === 0);
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + (isMajor ? 38 : 43) * Math.sin(rad)).toFixed(1);
      const y2 = (60 - (isMajor ? 38 : 43) * Math.cos(rad)).toFixed(1);
      svg += `<line class="tick major" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="#cbd5e1" stroke-width="${isMajor ? 2.5 : 1.5}" />`;
      if (isMajor) {
        const tx = (60 + 28 * Math.sin(rad)).toFixed(1);
        const ty = (60 - 28 * Math.cos(rad) + 3.5).toFixed(1);
        svg += `<text x="${tx}" y="${ty}" font-family="sans-serif" font-size="10" fill="#e2e8f0" text-anchor="middle" font-weight="900">${h}</text>`;
      }
    }
    return svg;
  }

  generateTurboTicks(maxBoost) {
    let svg = '';
    const steps = [0, 0.5, 1.0, 1.5, 2.0].filter(v => v <= maxBoost + 0.1);
    steps.forEach(b => {
      const pct = Math.min(1.0, b / maxBoost);
      const angleDeg = -135 + pct * 270;
      const rad = (angleDeg * Math.PI) / 180;
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + 40 * Math.sin(rad)).toFixed(1);
      const y2 = (60 - 40 * Math.cos(rad)).toFixed(1);
      const tx = (60 + 30 * Math.sin(rad)).toFixed(1);
      const ty = (60 - 30 * Math.cos(rad) + 3.5).toFixed(1);
      const col = b > 1.2 ? '#ef4444' : '#eab308';
      svg += `<line class="tick" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${col}" stroke-width="2" />`;
      svg += `<text x="${tx}" y="${ty}" font-family="monospace" font-size="9" fill="${col}" text-anchor="middle" font-weight="900">${b.toFixed(1)}</text>`;
    });
    return svg;
  }

  update(currentBiome, activePOI, weatherDirector = null) {
    // Header telemetry
    const biomeEl = this.element.querySelector('#hud-biome-name');
    if (biomeEl && currentBiome) biomeEl.textContent = currentBiome.name.toUpperCase();
    const km = (this.survivalState.distanceTraveledMeters / 1000).toFixed(1);
    const odoEl = this.element.querySelector('#hud-odometer');
    if (odoEl) odoEl.textContent = km.padStart(6, '0');

    const hrs = Math.floor(this.survivalState.timeOfDay).toString().padStart(2, '0');
    const mins = Math.floor((this.survivalState.timeOfDay % 1) * 60).toString().padStart(2, '0');
    const timeEl = this.element.querySelector('#hud-time');
    if (timeEl) timeEl.textContent = `${hrs}:${mins}`;

    // Turn signal flashers & Hazard simulation
    const blinkPhase = Math.floor(Date.now() / 320) % 2 === 0;
    const isSteerL = (this.vehicle && this.vehicle.steerAngle > 0.035) || this.hazardActive;
    const isSteerR = (this.vehicle && this.vehicle.steerAngle < -0.035) || this.hazardActive;
    const blinkerL = this.element.querySelector('#blinker-l');
    const blinkerR = this.element.querySelector('#blinker-r');
    if (blinkerL) blinkerL.classList.toggle('active', !!(isSteerL && blinkPhase));
    if (blinkerR) blinkerR.classList.toggle('active', !!(isSteerR && blinkPhase));

    // Steering rack angle degree readout
    const rackAngleEl = this.element.querySelector('#rack-angle-val');
    if (rackAngleEl && this.vehicle) {
      const deg = (-this.vehicle.steerAngle * (180 / Math.PI)).toFixed(1);
      rackAngleEl.textContent = `${deg > 0 ? '+' : ''}${deg}°`;
    }

    // Vintage Upper Aux Rack Gauges
    const vdoVolts = this.element.querySelector('#vdo-volts');
    const vdoVoltsFill = this.element.querySelector('#vdo-volts-fill');
    if (vdoVolts) {
      const volts = this.vehicle.isEngineOn ? 14.2 : 12.3;
      vdoVolts.textContent = `${volts}V`;
      if (vdoVoltsFill) vdoVoltsFill.style.width = `${((volts - 10) / 5) * 100}%`;
    }

    const vdoOil = this.element.querySelector('#vdo-oil');
    const vdoOilFill = this.element.querySelector('#vdo-oil-fill');
    if (vdoOil) {
      const oilPress = this.vehicle.isEngineOn ? (2.0 + this.vehicle.rpm * 2.4).toFixed(1) : '0.0';
      vdoOil.textContent = `${oilPress} BAR`;
      if (vdoOilFill) vdoOilFill.style.width = `${Math.min(100, (parseFloat(oilPress) / 5.0) * 100)}%`;
    }

    const roadImpact = weatherDirector ? weatherDirector.getRoadImpact() : null;
    const vdoRoadStatus = this.element.querySelector('#vdo-road-status');
    const vdoExtTemp = this.element.querySelector('#vdo-ext-temp');
    if (vdoRoadStatus) {
      if (this.vehicle && this.vehicle.terrainZone && this.vehicle.terrainZone !== 'PAVED') {
        vdoRoadStatus.textContent = this.vehicle.terrainStatusText;
        vdoRoadStatus.style.color = this.vehicle.terrainStatusColor;
      } else if (roadImpact) {
        vdoRoadStatus.textContent = `${roadImpact.statusLabel} • ${roadImpact.statusBadge}`;
        vdoRoadStatus.style.color = roadImpact.statusColor;
      } else {
        vdoRoadStatus.textContent = 'ASFALTO 100%';
        vdoRoadStatus.style.color = '#22c55e';
      }
    }
    if (vdoExtTemp && currentBiome) {
      const baseTemp = currentBiome.coldDanger ? -18 : (currentBiome.id === 'flooded_marshland' ? 12 : 2);
      const isNight = this.survivalState.timeOfDay < 6 || this.survivalState.timeOfDay > 20;
      const curTemp = isNight ? baseTemp - 8 : baseTemp;
      vdoExtTemp.textContent = `${curTemp}°C • ${currentBiome.name.toUpperCase()}`;
    }

    // Live Terrain Radar Strip in MFD
    const terrainStrip = this.element.querySelector('#hud-terrain-strip');
    const terrainText = this.element.querySelector('#hud-terrain-text');
    const terrainBadge = this.element.querySelector('#hud-terrain-badge');
    const terrainIcon = this.element.querySelector('#hud-terrain-icon');
    if (terrainStrip && terrainText && this.vehicle) {
      terrainText.textContent = this.vehicle.terrainStatusText || 'ASFALTO (CARREGGIATA)';
      if (this.vehicle.terrainZone === 'SHOULDER') {
        if (terrainIcon) terrainIcon.textContent = '🪨';
        if (terrainBadge) {
          terrainBadge.textContent = 'BANCHINA';
          terrainBadge.style.color = '#38bdf8';
          terrainBadge.style.background = 'rgba(56, 189, 248, 0.2)';
        }
      } else if (this.vehicle.terrainZone === 'OFFROAD_SAFE') {
        if (terrainIcon) terrainIcon.textContent = '🌲';
        if (terrainBadge) {
          terrainBadge.textContent = '4x4 NATIVO';
          terrainBadge.style.color = '#10b981';
          terrainBadge.style.background = 'rgba(16, 185, 129, 0.2)';
        }
      } else if (this.vehicle.terrainZone === 'OFFROAD_CRAWL') {
        if (terrainIcon) terrainIcon.textContent = '⚠️';
        if (terrainBadge) {
          terrainBadge.textContent = 'CRAWL LENTO';
          terrainBadge.style.color = '#f59e0b';
          terrainBadge.style.background = 'rgba(245, 158, 11, 0.2)';
        }
      } else if (this.vehicle.terrainZone === 'OFFROAD_HAZARD') {
        if (terrainIcon) terrainIcon.textContent = '💥';
        if (terrainBadge) {
          terrainBadge.textContent = 'RISCHIO DANNO!';
          terrainBadge.style.color = '#ef4444';
          terrainBadge.style.background = 'rgba(239, 68, 68, 0.25)';
        }
      } else {
        if (terrainIcon) terrainIcon.textContent = '🛣️';
        if (terrainBadge) {
          terrainBadge.textContent = roadImpact ? roadImpact.statusBadge : 'GRIP 100%';
          terrainBadge.style.color = roadImpact ? roadImpact.statusColor : '#22c55e';
          terrainBadge.style.background = 'rgba(34, 197, 94, 0.2)';
        }
      }
    }

    // Right Pod: Pedal console gear badge
    const gearPedalBadge = this.element.querySelector('#hud-gear-pedal-badge');
    if (gearPedalBadge && this.vehicle) {
      gearPedalBadge.textContent = this.vehicle.gearState === 'REVERSE' ? 'REV [R]' : `DRIVE (D${this.vehicle.gear || 1})`;
      gearPedalBadge.style.color = this.vehicle.gearState === 'REVERSE' ? '#ef4444' : '#22c55e';
    }

    // Model-Specific Dashboard Instrument Scaling
    const cur = (this.vehicle && this.vehicle.getCurrentModelConfig) ? this.vehicle.getCurrentModelConfig() : (typeof CONFIG !== 'undefined' ? CONFIG.VEHICLES_CATALOG.panda_4x4 : null);
    if (!cur) return;

    if (this.currentModelId !== cur.id) {
      this.setupVehicleDashboard(cur);
    }

    const brandEl = this.element.querySelector('#hud-cluster-brand');
    if (brandEl) brandEl.textContent = `${cur.dashTheme.clusterName} — ${cur.maker.toUpperCase()} ${cur.name.toUpperCase()}`;

    const driveEl = this.element.querySelector('#hud-drivetrain-badge');
    if (driveEl) driveEl.textContent = cur.drivetrainBadge;

    // Live Transmission & Gear Interlock Telemetry Display
    const gearBadge = this.element.querySelector('#hud-gear-badge');
    if (gearBadge && this.vehicle) {
      if (this.vehicle.gearState === 'REVERSE') {
        gearBadge.textContent = '◀ RETROMARCIA [R]';
        gearBadge.className = 'cluster-gear-badge gear-reverse';
      } else if (Math.abs(this.vehicle.forwardSpeed) <= 0.15) {
        if (this.vehicle.standstillTimer >= 1.0 || this.vehicle.reverseArmed) {
          gearBadge.textContent = '[ PREMI FRENO ➔ RETRO ]';
          gearBadge.className = 'cluster-gear-badge gear-ready-reverse';
        } else {
          const waitTime = Math.max(0, 1.0 - this.vehicle.standstillTimer).toFixed(1);
          gearBadge.textContent = `[ ATTENDI STOP ${waitTime}s ]`;
          gearBadge.className = 'cluster-gear-badge gear-neutral';
        }
      } else {
        gearBadge.textContent = `▶ DRIVE (D${this.vehicle.gear || 1})`;
        gearBadge.className = 'cluster-gear-badge gear-drive';
      }
    }

    // 1. Speedometer Needle & Text
    const speed = this.vehicle.speedKmh;
    const speedValEl = this.element.querySelector('#dial-speed-val');
    if (speedValEl) speedValEl.textContent = speed;
    const maxSpeed = cur.dashTheme.speedoMax || 160;
    const speedDeg = -135 + Math.min(1.0, speed / maxSpeed) * 270;
    const speedNeedle = this.element.querySelector('#speed-needle');
    if (speedNeedle) {
      speedNeedle.style.transform = `rotate(${speedDeg}deg)`;
      if (cur.dashTheme.needleColor) speedNeedle.style.stroke = cur.dashTheme.needleColor;
    }

    // 2. Tachometer / Contagiri Motore (RPM)
    const maxRpm = Math.ceil((cur.dashTheme.redlineRpm || 6000) / 1000) * 1000 + 1000;
    const actualRpm = this.vehicle.engineRpmActual || Math.round(cur.idleRpm + this.vehicle.rpm * ((cur.dashTheme.redlineRpm || 6000) - cur.idleRpm));
    const rpmValEl = this.element.querySelector('#dial-rpm-val');
    if (rpmValEl) rpmValEl.textContent = (actualRpm / 1000).toFixed(1);
    const rpmDeg = -135 + Math.min(1.0, actualRpm / maxRpm) * 270;
    const rpmNeedle = this.element.querySelector('#rpm-needle');
    if (rpmNeedle) {
      rpmNeedle.style.transform = `rotate(${rpmDeg}deg)`;
      if (cur.dashTheme.needleColor) rpmNeedle.style.stroke = cur.dashTheme.needleColor;
    }

    // 3. Clinometro & Inclinometro 4x4 Off-Road
    const pitchRad = this.vehicle.mesh ? this.vehicle.mesh.rotation.x : 0;
    const rollRad = this.vehicle.mesh ? this.vehicle.mesh.rotation.z : 0;
    const pitchDeg = Math.round(pitchRad * (180 / Math.PI));
    const rollDeg = Math.round(rollRad * (180 / Math.PI));
    const inclineHorizonGroup = this.element.querySelector('#incline-horizon-group');
    if (inclineHorizonGroup) {
      const translateY = Math.max(-18, Math.min(18, pitchDeg * 0.8));
      inclineHorizonGroup.setAttribute('transform', `translate(60, ${60 + translateY}) rotate(${-rollDeg})`);
    }
    const dialInclineVal = this.element.querySelector('#dial-incline-val');
    if (dialInclineVal) {
      dialInclineVal.textContent = `${pitchDeg >= 0 ? '+' : ''}${pitchDeg}°`;
    }

    // 4. Analog Clock / Veglia Quartz Needles
    const hNeedle = this.element.querySelector('#clock-hour-needle');
    const mNeedle = this.element.querySelector('#clock-min-needle');
    if (hNeedle && mNeedle) {
      const rawHrs = this.survivalState.timeOfDay || 8.5;
      const rawMins = (rawHrs % 1) * 60;
      const hrDeg = ((rawHrs % 12) + (rawMins / 60)) * 30;
      const minDeg = rawMins * 6;
      hNeedle.style.transform = `rotate(${hrDeg}deg)`;
      mNeedle.style.transform = `rotate(${minDeg}deg)`;
    }

    // Instrument Cluster Night Backlighting (Glows when headlights ON)
    this.element.classList.toggle('dials-night-backlit', !!this.vehicle.isLightsOn);

    const lampPrimina = this.element.querySelector('#lamp-primina');
    if (lampPrimina) {
      const isPrimina = speed < 22 && (this.touchInput.throttle > 0.1 || this.vehicle.speedKmh > 1);
      lampPrimina.className = `steyr-lamp ${isPrimina ? 'active-primina' : ''}`;
    }

    // 5. Dedicated Turbo Boost Manometer (Bar)
    const turboHousing = this.element.querySelector('#turbo-dial-housing');
    if (turboHousing && cur.hasTurbo) {
      const boost = this.vehicle.boostBar || 0;
      const turboVal = this.element.querySelector('#dial-turbo-val');
      if (turboVal) turboVal.textContent = boost.toFixed(2);
      const maxBoost = cur.turboBoostMaxBar || 1.5;
      const boostDeg = -135 + Math.min(1.0, boost / maxBoost) * 270;
      const turboNeedle = this.element.querySelector('#turbo-needle');
      if (turboNeedle) {
        turboNeedle.style.transform = `rotate(${boostDeg}deg)`;
        if (cur.dashTheme.needleColor) turboNeedle.style.stroke = cur.dashTheme.needleColor;
      }
    }

    // 4. Car-Specific Auxiliary Widgets
    if (cur.id === 'panda_4x4') {
      const lamp4wd = this.element.querySelector('#lamp-4wd-steyr');
      const lampPrimina = this.element.querySelector('#lamp-primina');
      const steyrKnob = this.element.querySelector('#steyr-knob-pos');

      const is4wd = this.vehicle.is4WDEngaged !== undefined ? this.vehicle.is4WDEngaged : true;
      const isPrimina = !!this.vehicle.priminaCrawlerActive;

      if (lamp4wd) {
        lamp4wd.className = `steyr-lamp ${is4wd ? 'active-steyr' : ''}`;
        const dot = lamp4wd.querySelector('.ann-dot');
        if (dot) dot.style.background = is4wd ? '#22c55e' : '#475569';
      }
      if (lampPrimina) {
        lampPrimina.className = `steyr-lamp ${isPrimina ? 'active-primina' : ''}`;
        const dot = lampPrimina.querySelector('.ann-dot');
        if (dot) dot.style.background = isPrimina ? '#eab308' : '#475569';
      }
      if (steyrKnob) {
        steyrKnob.style.transform = is4wd ? 'translateY(-8px)' : 'translateY(4px)';
        steyrKnob.style.boxShadow = is4wd ? '0 0 8px rgba(34, 197, 94, 0.7)' : 'none';
      }

      const driveEl = this.element.querySelector('#hud-drivetrain-badge');
      if (driveEl) {
        if (is4wd) {
          driveEl.textContent = isPrimina ? '4WD STEYR + PRIMINA CRAWLER' : '4WD STEYR INSERITA [50:50]';
          driveEl.style.color = isPrimina ? '#eab308' : '#22c55e';
        } else {
          driveEl.textContent = '2WD TRAZIONE ANTERIORE [100:0]';
          driveEl.style.color = '#94a3b8';
        }
      }
    } else if (cur.id === 'delta_integrale') {
      const torsenBar = this.element.querySelector('#torsen-front-bar');
      const torsenText = this.element.querySelector('#torsen-split-text');
      if (torsenBar && torsenText) {
        let frontPct = 47 - (this.touchInput.throttle * 7) + (this.touchInput.brake * 8);
        frontPct = Math.max(38, Math.min(58, Math.round(frontPct)));
        const rearPct = 100 - frontPct;
        torsenBar.style.width = `${frontPct}%`;
        torsenText.textContent = `${frontPct}% ANT / ${rearPct}% POST`;
      }
    } else if (cur.id === 'mercedes_w123') {
      const w123Oil = this.element.querySelector('#w123-oil-val');
      if (w123Oil) {
        const oilBar = this.vehicle.isEngineOn ? (1.5 + (actualRpm / 4500) * 1.5).toFixed(1) : '0.0';
        w123Oil.textContent = `${oilBar} BAR`;
      }
      const boschBox = this.element.querySelector('#bosch-coil-box');
      const boschStatus = this.element.querySelector('#bosch-glow-status');
      if (boschBox && boschStatus) {
        if (!this.vehicle.isEngineOn) {
          boschBox.classList.add('glow-coil-active');
          boschStatus.textContent = 'VORGELÜHT';
          boschStatus.style.color = '#f97316';
        } else {
          boschBox.classList.remove('glow-coil-active');
          boschStatus.textContent = 'BETRIEB';
          boschStatus.style.color = '#22c55e';
        }
      }
    } else if (cur.id === 'mercedes_gwagen') {
      const horizon = this.element.querySelector('#incline-horizon-bar');
      const rollEl = this.element.querySelector('#incline-roll-val');
      const pitchEl = this.element.querySelector('#incline-pitch-val');
      if (horizon && rollEl && pitchEl) {
        const steer = (this.vehicle && this.vehicle.filteredSteer !== undefined) ? this.vehicle.filteredSteer : this.touchInput.steer;
        const rollDeg = (steer * -18).toFixed(1);
        const pitchDeg = (this.touchInput.throttle * 5 - this.touchInput.brake * 8).toFixed(1);
        horizon.style.transform = `rotate(${rollDeg}deg) translateY(${pitchDeg * 1.5}px)`;
        rollEl.textContent = `${Math.abs(rollDeg)}° ${rollDeg > 0 ? 'R' : 'L'}`;
        pitchEl.textContent = `${pitchDeg >= 0 ? '+' : ''}${pitchDeg}°`;
      }
    } else if (cur.id === 'defender_110') {
      const voltEl = this.element.querySelector('#defender-volts-num');
      if (voltEl) {
        const volts = this.vehicle.isEngineOn ? (13.8 + (actualRpm / 5000) * 0.6).toFixed(1) : '12.4';
        voltEl.textContent = `${volts} V`;
      }
    } else if (cur.id === 'volvo_245') {
      const lambdaEl = this.element.querySelector('#volvo-lambda');
      const frostEl = this.element.querySelector('#volvo-frost');
      if (lambdaEl) {
        lambdaEl.className = `volvo-lamp-chip ${this.vehicle.isEngineOn ? 'active-lambda' : ''}`;
      }
      if (frostEl) {
        const isFreezing = (this.survivalState.timeOfDay < 7 || this.survivalState.timeOfDay > 20);
        frostEl.className = `volvo-lamp-chip ${isFreezing ? 'active-frost' : ''}`;
      }
    } else if (cur.id === 'bmw_e30_ix') {
      const econBar = this.element.querySelector('#bmw-econ-bar');
      if (econBar) {
        let econ = 0;
        if (this.vehicle.isEngineOn) {
          if (speed < 5) econ = this.touchInput.throttle > 0 ? 30 : 0;
          else econ = Math.min(30, (this.touchInput.throttle * actualRpm * 0.008) / (speed * 0.01));
        }
        econBar.style.width = `${Math.min(100, (econ / 30) * 100)}%`;
      }
    } else if (cur.id === 'alfa_giulia') {
      const alfaOil = this.element.querySelector('#alfa-oil-val');
      if (alfaOil) {
        const press = this.vehicle.isEngineOn ? (2.2 + (actualRpm / 7000) * 4.3).toFixed(1) : '0.0';
        alfaOil.textContent = press;
      }
    } else if (cur.id === 'peugeot_504_dangel') {
      const compassRose = this.element.querySelector('#safari-compass-rose');
      const compassText = this.element.querySelector('#compass-heading-text');
      if (compassRose && compassText) {
        const steer = (this.vehicle && this.vehicle.filteredSteer !== undefined) ? this.vehicle.filteredSteer : this.touchInput.steer;
        const headingDeg = Math.round(((steer * 45) + 360) % 360);
        compassRose.style.transform = `rotate(${-headingDeg}deg)`;
        const cardinals = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
        const card = cardinals[Math.floor(((headingDeg + 22.5) % 360) / 45)];
        compassText.textContent = `${card} ${headingDeg.toString().padStart(3, '0')}°`;
      }
    } else if (cur.id === 'golf_country') {
      const golfSlip = this.element.querySelector('#golf-syncro-slip');
      if (golfSlip) {
        const isSlipping = this.vehicle.isEngineOn && this.touchInput.throttle > 0.5 && speed < 35;
        golfSlip.className = `syncro-slip-lamp ${isSlipping ? 'slip-active' : ''}`;
      }
    }

    // Glow Plug Pre-Heat Indicator for Diesel Engines
    const lampGlow = this.element.querySelector('#lamp-glow');
    if (lampGlow) {
      if (cur.isDiesel) {
        lampGlow.style.display = 'flex';
        lampGlow.className = `ann-lamp ann-glow ${!this.vehicle.isEngineOn ? 'active-glow' : ''}`;
      } else {
        lampGlow.style.display = 'none';
      }
    }

    // Vitals in MFD
    const fuelPct = (this.vehicle.fuel / this.vehicle.maxFuel) * 100;
    const fuelFill = this.element.querySelector('#hud-fuel-fill');
    if (fuelFill) fuelFill.style.width = `${fuelPct}%`;
    const fuelNum = this.element.querySelector('#hud-fuel-num');
    if (fuelNum) fuelNum.textContent = `${Math.round(this.vehicle.fuel)}L`;

    const hullFill = this.element.querySelector('#hud-hull-fill');
    if (hullFill) hullFill.style.width = `${this.vehicle.hull}%`;
    const hullNum = this.element.querySelector('#hud-hull-num');
    if (hullNum) hullNum.textContent = `${Math.round(this.vehicle.hull)}%`;

    const tempNorm = Math.min(100, Math.max(0, (this.vehicle.engineTemp - 50) / 70 * 100));
    const tempFill = this.element.querySelector('#hud-temp-fill');
    if (tempFill) tempFill.style.width = `${tempNorm}%`;
    const tempNum = this.element.querySelector('#hud-temp-num');
    if (tempNum) tempNum.textContent = `${Math.round(this.vehicle.engineTemp)}°C`;

    // Survivor Vitals
    const hpEl = this.element.querySelector('#hud-hp');
    if (hpEl) hpEl.textContent = Math.round(this.survivalState.health);
    const hgEl = this.element.querySelector('#hud-hunger');
    if (hgEl) hgEl.textContent = `${Math.round(this.survivalState.hunger)}%`;
    const thEl = this.element.querySelector('#hud-thirst');
    if (thEl) thEl.textContent = `${Math.round(this.survivalState.thirst)}%`;
    const tpEl = this.element.querySelector('#hud-temp');
    if (tpEl) tpEl.textContent = `${this.survivalState.bodyTemp.toFixed(1)}°C`;

    // Proximity POI
    this.showNearbyPOI(activePOI);

    // Sync tactile steering wheel and knob visual with smoothed rack angle
    if (!this.touchInput.touchSteerActive) {
      const displaySteer = (this.vehicle && this.vehicle.filteredSteer !== undefined) ? this.vehicle.filteredSteer : this.touchInput.steer;
      const track = this.element.querySelector('#steering-track');
      const knob = this.element.querySelector('#steering-knob');
      const wheel = this.element.querySelector('#steering-wheel');
      if (track && knob) {
        const rect = track.getBoundingClientRect();
        const travel = (rect.width > 0 ? rect.width : 150) * 0.40;
        knob.style.transform = `translateX(${displaySteer * travel}px)`;
      }
      if (wheel) {
        wheel.style.transform = `rotate(${displaySteer * 60}deg)`;
      }
    }

    // Sync pedal pressed state visuals for keyboard
    const pedalGas = this.element.querySelector('#pedal-gas');
    if (pedalGas && !this.touchInput.touchThrottleActive) {
      if (this.touchInput.throttle > 0) pedalGas.classList.add('pressed');
      else pedalGas.classList.remove('pressed');
    }
    const pedalBrake = this.element.querySelector('#pedal-brake');
    if (pedalBrake && !this.touchInput.touchBrakeActive) {
      if (this.touchInput.brake > 0) pedalBrake.classList.add('pressed');
      else pedalBrake.classList.remove('pressed');
    }

    // Malfunction Annunciator Lamps & Emergency Diagnostic Banner
    if (this.malfunctionManager) {
      const f = this.malfunctionManager.faults;
      const lampTire = this.element.querySelector('#lamp-tire');
      const lampLeak = this.element.querySelector('#lamp-leak');
      const lampElec = this.element.querySelector('#lamp-elec');
      const lampFuel = this.element.querySelector('#lamp-fuel');
      const ledRepair = this.element.querySelector('#led-repair');
      const repairText = this.element.querySelector('#repair-text');

      if (lampTire) lampTire.className = `ann-lamp ${f.flat_tire ? 'active-alarm' : ''}`;
      if (lampLeak) lampLeak.className = `ann-lamp ${f.radiator_leak ? 'active-alarm' : ''}`;
      if (lampElec) lampElec.className = `ann-lamp ${f.electrical_short ? 'active-alarm' : ''}`;
      if (lampFuel) lampFuel.className = `ann-lamp ${f.fuel_leak ? 'active-alarm' : ''}`;

      const activeFaults = this.malfunctionManager.getActiveFaultSummaries();
      const hasFault = activeFaults.length > 0;

      if (ledRepair) {
        ledRepair.className = `toggle-light-ring ${hasFault ? 'on active-alarm-led' : ''}`;
      }
      if (repairText) {
        repairText.textContent = hasFault ? 'FIX FAULT' : 'REPAIR';
      }

      // Update Breakdown Alert Banner
      const breakdownBanner = this.element.querySelector('#breakdown-banner');
      if (breakdownBanner) {
        if (hasFault) {
          const current = activeFaults[0];
          breakdownBanner.style.display = 'flex';
          this.element.querySelector('#breakdown-title').textContent = current.title;
          this.element.querySelector('#breakdown-desc').textContent = current.effect;
          this.element.querySelector('#breakdown-req').textContent = `Richiesto: ${current.needed}`;

          const fixBtn = this.element.querySelector('#btn-breakdown-fix');
          if (fixBtn) {
            fixBtn.textContent = current.canRepair ? 'RIPARA ORA' : 'MANCA PEZZO';
            fixBtn.className = `breakdown-fix-btn ${current.canRepair ? 'can-repair' : 'missing-supplies'}`;
          }
        } else {
          breakdownBanner.style.display = 'none';
        }
      }
    }

    // Story Director Integration (Pinned Objective & CB Radio LCD update)
    if (this.storyDirector) {
      const activeCh = this.storyDirector.getActiveChapter();
      const activeObj = this.storyDirector.getActiveObjective();

      const chBadge = this.element.querySelector('#story-ch-badge');
      if (chBadge && activeCh) {
        chBadge.textContent = `CAPITOLO ${activeCh.number}`;
      }

      const objText = this.element.querySelector('#story-obj-text');
      if (objText && activeObj) {
        objText.textContent = activeObj.text;
      }

      // Midland Alan 48 CB Radio Display Sync
      const cbDisplay = this.element.querySelector('#cb-display-text');
      const cbSignal = this.element.querySelector('#cb-signal-fill');
      if (cbDisplay) {
        if (this.storyDirector.activeRadioDispatch) {
          const spk = this.storyDirector.activeRadioDispatch.speaker;
          cbDisplay.textContent = `CH 19 [ RX: ${spk.substring(0, 16)} ] 27.185 MHz`;
          cbDisplay.style.color = '#4ade80';
          cbDisplay.style.textShadow = '0 0 10px #22c55e';
          if (cbSignal) cbSignal.style.width = '100%';
        } else {
          cbDisplay.textContent = 'CH 19 [ MERIDIAN CONVOY • EMGCY ] 27.185 MHz';
          cbDisplay.style.color = '#22c55e';
          cbDisplay.style.textShadow = '0 0 6px #22c55e';
          if (cbSignal) cbSignal.style.width = '75%';
        }
      }

      // Update CB radio dispatch timer progress bar
      const progFill = this.element.querySelector('#cb-progress-fill');
      if (progFill && this.storyDirector) {
        if (this.storyDirector.activeRadioDispatch && this.storyDirector.maxDispatchDuration > 0) {
          const total = this.storyDirector.maxDispatchDuration || 24.0;
          const remain = Math.max(0, this.storyDirector.radioDispatchTimer || 0);
          const pct = Math.min(100, Math.max(0, (remain / total) * 100));
          progFill.style.width = `${pct.toFixed(1)}%`;
        }
      }
    }
  }

  setStoryDirector(storyDirector) {
    this.storyDirector = storyDirector;
  }

  handleRadioDispatch(tx) {
    const overlay = this.element.querySelector('#cb-radio-overlay');
    if (!overlay) return;

    if (!tx) {
      overlay.style.display = 'none';
      return;
    }

    overlay.style.display = 'flex';
    const avatar = this.element.querySelector('#cb-avatar');
    if (avatar) avatar.textContent = tx.avatar || '📻';

    const spkName = this.element.querySelector('#cb-speaker-name');
    if (spkName) spkName.textContent = tx.speaker;

    const callsign = this.element.querySelector('#cb-callsign');
    if (callsign) callsign.textContent = tx.callsign || 'CH 19 DISPATCH';

    const msg = this.element.querySelector('#cb-message');
    if (msg) msg.textContent = `"${tx.text}"`;

    const progFill = this.element.querySelector('#cb-progress-fill');
    if (progFill) progFill.style.width = '100%';
  }

  handleObjectiveCompleted(obj) {
    const toast = this.element.querySelector('#story-toast');
    if (!toast) return;

    const desc = this.element.querySelector('#toast-desc');
    if (desc) desc.textContent = obj.text;

    toast.style.display = 'flex';
    toast.style.opacity = '1';

    setTimeout(() => {
      toast.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
      toast.style.opacity = '0';
      toast.style.transform = 'translate(-50%, -20px)';
      setTimeout(() => {
        toast.style.display = 'none';
        toast.style.transform = 'translateX(-50%)';
      }, 600);
    }, 9500); // 9.5s duration to comfortably read expedition milestones
  }

  executeEmergencyRepair() {
    if (!this.malfunctionManager) return;
    const summaries = this.malfunctionManager.getActiveFaultSummaries();
    if (summaries.length === 0) {
      this.showToast('Nessun guasto meccanico rilevato sul veicolo.');
      return;
    }
    const current = summaries[0];
    const res = this.malfunctionManager.repairFault(current.type);
    if (res.success) {
      this.showToast(`🔧 RIPARATO: ${current.title}`);
    } else {
      this.showToast(`⚠️ ${res.reason || 'Materiali insufficienti nel bagagliaio!'}`);
    }
  }

  showToast(msg) {
    const toast = document.createElement('div');
    toast.className = 'hud-quick-toast';
    toast.textContent = msg;
    this.element.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translate(-50%, -15px)';
      setTimeout(() => toast.remove(), 400);
    }, 6500); // 6.5s duration for ample time to read HUD alerts
  }
}
