/**
 * THE LONG MERIDIAN - Main Game Application Coordinator
 * Boots all subsystems, manages loop and transitions between driving and foot scavenging.
 */

import { Renderer } from './engine/Renderer.js';
import { CameraController } from './engine/CameraController.js';
import { TouchInput } from './engine/TouchInput.js';
import { WebAudioEngine } from './engine/WebAudioEngine.js';

import { BiomeManager } from './world/BiomeManager.js';
import { RoadGenerator } from './world/RoadGenerator.js';
import { ScenerySpawner } from './world/ScenerySpawner.js';
import { POIManager } from './world/POIManager.js';
import { LandscapeManager } from './world/LandscapeManager.js';

import { Vehicle } from './entities/Vehicle.js';
import { PlayerCharacter } from './entities/PlayerCharacter.js';
import { Hazards } from './entities/Hazards.js';

import { SurvivalState } from './systems/SurvivalState.js';
import { InventorySystem } from './systems/InventorySystem.js';
import { WeatherDirector } from './systems/WeatherDirector.js';
import { UpgradeSystem } from './systems/UpgradeSystem.js';
import { MalfunctionManager } from './systems/MalfunctionManager.js';

import { DashboardHUD } from './ui/DashboardHUD.js';
import { InventoryModal } from './ui/InventoryModal.js';
import { ScavengeModal } from './ui/ScavengeModal.js';
import { UpgradeModal } from './ui/UpgradeModal.js';
import { MeridianAtlasModal } from './ui/MeridianAtlasModal.js';
import { StoryDiaryModal } from './ui/StoryDiaryModal.js';
import { StoryDirector } from './systems/StoryDirector.js';

export class Game {
  constructor() {
    this.container = document.getElementById('app');
    this.canvasContainer = document.getElementById('canvas-container');

    // State
    this.isFootMode = false;
    this.lastTime = performance.now();
    this.isRunning = false;

    // Toast element
    this.biomeToast = null;

    this.init();
  }

  init() {
    // 1. Audio & Input
    this.audioEngine = new WebAudioEngine();
    this.touchInput = new TouchInput();

    // 2. Rendering & Camera
    this.renderer = new Renderer(this.canvasContainer);
    this.renderer.setAudioEngine(this.audioEngine);
    this.cameraController = new CameraController(this.renderer.camera);

    // 3. World Systems
    this.biomeManager = new BiomeManager(this.renderer, this.audioEngine);
    this.roadGenerator = new RoadGenerator(this.renderer.scene, this.biomeManager);
    this.scenerySpawner = new ScenerySpawner(this.renderer.scene, this.roadGenerator, this.biomeManager);
    this.poiManager = new POIManager(this.renderer.scene, this.roadGenerator);
    this.landscapeManager = new LandscapeManager(this.renderer.scene, this.roadGenerator);

    // 4. Entities
    this.vehicle = new Vehicle(this.renderer.scene, this.audioEngine);
    this.playerCharacter = new PlayerCharacter(this.renderer.scene, this.audioEngine);
    this.hazards = new Hazards(this.renderer.scene, this.roadGenerator, this.audioEngine, this.cameraController);

    // 5. Survival, Progression & Malfunctions
    this.survivalState = new SurvivalState(this.audioEngine);
    this.inventorySystem = new InventorySystem(this.vehicle, this.survivalState, this.audioEngine);
    this.weatherDirector = new WeatherDirector(this.renderer, this.audioEngine, this.biomeManager);
    this.upgradeSystem = new UpgradeSystem(this.vehicle, this.inventorySystem, this.audioEngine);
    this.malfunctionManager = new MalfunctionManager(this.vehicle, this.inventorySystem, this.audioEngine);
    this.storyDirector = new StoryDirector(this.vehicle, this.survivalState, this.inventorySystem, this.audioEngine, this.poiManager);

    // 6. UI Layer
    this.dashboardHUD = new DashboardHUD(
      this.container,
      this.vehicle,
      this.survivalState,
      this.touchInput,
      this.audioEngine,
      this.malfunctionManager
    );
    this.dashboardHUD.setStoryDirector(this.storyDirector);

    this.inventoryModal = new InventoryModal(this.container, this.inventorySystem, this.audioEngine);
    this.scavengeModal = new ScavengeModal(this.container, this.inventorySystem, this.audioEngine);
    this.upgradeModal = new UpgradeModal(this.container, this.vehicle, this.upgradeSystem, this.audioEngine, this.inventorySystem);
    this.meridianAtlasModal = new MeridianAtlasModal(this.container, this.audioEngine);
    this.storyDiaryModal = new StoryDiaryModal(this.container, this.storyDirector, this.audioEngine);

    // Setup Toasts
    this.setupToast();
    this.setupDerelictToast();

    // Setup UI Callbacks
    this.bindCallbacks();

    // Start Loop
    this.isRunning = true;
    requestAnimationFrame((t) => this.loop(t));

    // Show initial welcome toast
    this.showBiomeToast(this.biomeManager.currentBiome);
  }

  setupToast() {
    this.biomeToast = document.createElement('div');
    this.biomeToast.className = 'biome-toast';
    this.biomeToast.innerHTML = `
      <div class="toast-accent-strip"></div>
      <div class="toast-content">
        <h2 id="toast-title">CORRIDOIO NORDICO</h2>
        <p id="toast-sub">Inizio Spedizione</p>
        <div class="toast-extra" id="toast-extra">Caricamento coordinate...</div>
      </div>
    `;
    this.canvasContainer.appendChild(this.biomeToast);
  }

  setupDerelictToast() {
    this.derelictToast = document.createElement('div');
    this.derelictToast.className = 'derelict-toast';
    this.derelictToast.style.cssText = `
      position: absolute;
      top: 90px;
      left: 50%;
      transform: translateX(-50%) translateY(-15px);
      background: rgba(14, 18, 24, 0.96);
      border: 1px solid rgba(255, 179, 0, 0.65);
      box-shadow: 0 8px 32px rgba(0,0,0,0.85), 0 0 25px rgba(255, 179, 0, 0.25);
      border-radius: 8px;
      padding: 10px 18px;
      display: flex;
      align-items: center;
      gap: 12px;
      z-index: 1200;
      opacity: 0;
      pointer-events: none;
      transition: opacity 0.4s ease, transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    `;
    this.derelictToast.innerHTML = `
      <div style="font-size: 26px; line-height: 1;">📻</div>
      <div>
        <div style="font-size: 10px; font-weight: 800; letter-spacing: 0.15em; color: #ffb300; text-transform: uppercase;">SEGNALE CB ALASKA • RELITTO INDIVIDUATO</div>
        <div id="derelict-toast-title" style="font-size: 14px; font-weight: 700; color: #fff; margin-top: 2px;">Fiat Panda 4x4 Steyr-Puch</div>
        <div id="derelict-toast-desc" style="font-size: 11px; color: rgba(255,255,255,0.7); margin-top: 1px;">Coordinate registrate nel Dalton Registry. Apri Garage (G) per il restauro.</div>
      </div>
    `;
    this.canvasContainer.appendChild(this.derelictToast);
  }

  showDerelictToast(car) {
    if (!this.derelictToast) return;
    const titleEl = this.derelictToast.querySelector('#derelict-toast-title');
    const descEl = this.derelictToast.querySelector('#derelict-toast-desc');
    if (titleEl) titleEl.textContent = `${car.name} (${car.year})`;
    if (descEl) descEl.textContent = `📍 ${car.discoveryLocation || 'Lungo la Dalton'} • Apri il Garage (G) per ispezionare il restauro`;
    
    this.derelictToast.style.opacity = '1';
    this.derelictToast.style.transform = 'translateX(-50%) translateY(0)';
    if (this.audioEngine && this.audioEngine.playSwitchClick) {
      this.audioEngine.playSwitchClick(true);
    }

    setTimeout(() => {
      if (this.derelictToast) {
        this.derelictToast.style.opacity = '0';
        this.derelictToast.style.transform = 'translateX(-50%) translateY(-10px)';
      }
    }, 6000);
  }

  showBiomeToast(biome) {
    this.biomeToast.querySelector('#toast-title').textContent = biome.name.toUpperCase();
    this.biomeToast.querySelector('#toast-sub').textContent = `${biome.subname} — HUB: ${biome.settlementName}`;
    const extra = this.biomeToast.querySelector('#toast-extra');
    if (extra) {
      extra.textContent = `⚠️ PERICOLO: ${biome.environmentalThreat || 'Attenzione al fondo stradale'}`;
    }
    this.biomeToast.style.opacity = '1';
    this.biomeToast.style.transform = 'translateX(-50%) translateY(0)';

    setTimeout(() => {
      this.biomeToast.style.opacity = '0';
      this.biomeToast.style.transform = 'translateX(-50%) translateY(-10px)';
    }, 5500);
  }

  bindCallbacks() {
    // Mode switch: Drive <-> Foot
    this.dashboardHUD.onToggleMode = () => {
      this.toggleMode();
    };

    // Inventory modal
    this.dashboardHUD.onOpenInventory = () => {
      this.inventoryModal.toggle();
    };

    // Workshop & Garage modals
    this.dashboardHUD.onOpenWorkshop = (tab = 'upgrades') => {
      this.upgradeModal.toggle(tab);
    };

    this.dashboardHUD.onOpenGarage = () => {
      this.upgradeModal.toggle('garage');
    };

    // Atlas Route Log modal
    this.dashboardHUD.onOpenAtlas = () => {
      this.meridianAtlasModal.toggle(this.biomeManager.currentBiome.id);
    };

    // Story Diary & Campaign Logbook modal
    this.dashboardHUD.onOpenStoryDiary = () => {
      this.storyDiaryModal.toggle();
    };
    if (this.touchInput) {
      this.touchInput.onOpenJournal = () => {
        this.storyDiaryModal.toggle();
      };
    }

    // Story Director callbacks
    this.storyDirector.onRadioDispatch = (tx) => {
      this.dashboardHUD.handleRadioDispatch(tx);
    };

    this.storyDirector.onObjectiveCompleted = (obj, ch) => {
      this.dashboardHUD.handleObjectiveCompleted(obj);
    };

    this.storyDirector.onChapterCompleted = (ch) => {
      this.showBiomeToast({
        name: `CAPITOLO ${ch.number} COMPLETATO!`,
        subname: ch.title,
        settlementName: 'Ricompense Disponibili',
        environmentalThreat: 'Apri il Diario di Bordo (STORY) per riscuotere scorte e sblocchi!'
      });
    };

    // Scavenge / Settlement action
    this.dashboardHUD.onScavenge = () => {
      const activePOI = this.poiManager.activeNearbyPOI;
      if (activePOI && !activePOI.scavenged) {
        this.scavengeModal.openWithPOI(activePOI);
      }
    };

    // Biome change toast callback
    this.biomeManager.onBiomeChangeCallback = (newBiome) => {
      this.showBiomeToast(newBiome);
    };

    // Fleet derelict discovery callback
    this.upgradeSystem.onDerelictDiscovered = (car) => {
      this.showDerelictToast(car);
    };

    // User gesture to resume WebAudio
    window.addEventListener('pointerdown', () => {
      this.audioEngine.ensureContext();
    }, { once: true });
  }

  toggleMode() {
    if (this.isFootMode) {
      // Re-enter vehicle from anywhere
      this.isFootMode = false;
      this.playerCharacter.despawn();
      this.dashboardHUD.setModeVisual(false);
      this.dashboardHUD.showToast('🚗 Risalito a bordo del veicolo');
      if (this.audioEngine && this.audioEngine.playSwitchClick) {
        this.audioEngine.playSwitchClick(true);
      }
    } else {
      // Dismount vehicle
      if (this.vehicle.speedKmh > 15) {
        this.dashboardHUD.showToast('⚠️ Frena prima di scendere dal veicolo!');
        return;
      }
      this.isFootMode = true;
      // Spawn player on left side of vehicle
      const spawnPos = this.vehicle.position.clone().add(new THREE.Vector3(-1.8, 0, 0));
      this.playerCharacter.spawnAt(spawnPos);
      this.dashboardHUD.setModeVisual(true);
      this.dashboardHUD.showToast('🚶 Sei a piedi. Premi [E] o [ENTER CAR] per risalire');
    }
  }

  loop(currentTime) {
    if (!this.isRunning) return;
    const delta = Math.min((currentTime - this.lastTime) / 1000, 0.1);
    this.lastTime = currentTime;

    // 1. Process Input
    this.touchInput.update();

    // 2. Active target (Vehicle or Foot)
    const activeTarget = this.isFootMode ? this.playerCharacter : this.vehicle;
    const activePos = activeTarget.position;

    // 3. Query Road Info at active Z
    const roadInfo = this.roadGenerator.getRoadInfoAt(activePos.z);
    const roadImpact = this.weatherDirector.getRoadImpact();

    // 4. Update Entities
    if (this.isFootMode) {
      this.playerCharacter.update(delta, this.touchInput, roadInfo);
      this.vehicle.update(delta, { throttle: 0, brake: 1.0, steer: 0 }, roadInfo, this.renderer, roadImpact);
    } else {
      this.vehicle.update(delta, this.touchInput, roadInfo, this.renderer, roadImpact);
    }

    // Update exhaust particles
    this.renderer.updateExhaust(delta);

    // Update Malfunctions
    this.malfunctionManager.update(delta, this.touchInput, this.renderer);

    // 5. Update Hazards & Collisions
    this.hazards.update(activePos.z, this.vehicle, this.playerCharacter, delta, this.malfunctionManager, this.renderer);

    // 6. Update World Systems & Landscapes
    this.biomeManager.update(activePos.z);
    this.roadGenerator.update(activePos.z);
    this.scenerySpawner.update(activePos.z);
    this.poiManager.update(activePos);
    this.landscapeManager.update(activePos.z, delta, this.biomeManager.currentBiome);
    this.weatherDirector.update(delta, activePos.z, this.roadGenerator);
    this.upgradeSystem.update(activePos.z);
    this.storyDirector.update(delta);

    // 7. Update Survival State
    this.survivalState.update(delta, activePos.z, this.biomeManager.currentBiome, !this.isFootMode);

    // 8. Update Camera & Dynamic Celestial Day/Night Lighting
    const forwardVel = this.isFootMode ? this.playerCharacter.walkSpeed * 0.5 : this.vehicle.forwardSpeed;
    const targetHeading = this.isFootMode ? (this.playerCharacter.rotationY || 0) : (this.vehicle.rotation ? this.vehicle.rotation.y : 0);
    const roadHeading = (roadInfo && roadInfo.roadAngle !== undefined) ? roadInfo.roadAngle : 0;
    this.cameraController.update(delta, activePos, forwardVel, targetHeading, roadHeading);

    this.renderer.updateDayNightLighting(
      this.survivalState.timeOfDay,
      this.weatherDirector.currentWeather,
      this.biomeManager.currentBiome,
      this.vehicle.isLightsOn
    );
    this.renderer.updateLightFollow(activePos);

    // 9. Update Cockpit Dashboard HUD
    this.dashboardHUD.update(this.biomeManager.currentBiome, this.poiManager.activeNearbyPOI, this.weatherDirector);

    // 10. Render 3D Scene
    this.renderer.render();

    requestAnimationFrame((t) => this.loop(t));
  }
}

// Safe initialization handling both pre and post DOMContentLoaded
function bootGame() {
  if (!window.game) {
    window.game = new Game();
  }
}

if (document.readyState === 'loading') {
  window.addEventListener('DOMContentLoaded', bootGame);
} else {
  bootGame();
}
