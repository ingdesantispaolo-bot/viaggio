/**
 * THE LONG MERIDIAN - High-Fidelity 3D Multi-Model European Classic Survivor Vehicles
 * Features 11 authentic European real-world models (1960s-1990s) with authentic physics,
 * distinct silhouettes, specialized drivetrain handling, turbo lag, and suspension dynamics.
 */

import { CONFIG } from '../config.js';
import { TextureGenerator } from '../engine/TextureGenerator.js';

export class Vehicle {
  constructor(scene, audioEngine) {
    this.scene = scene;
    this.audioEngine = audioEngine;

    // Active model ID and specs from catalog
    this.modelId = CONFIG.DEFAULT_VEHICLE_ID || 'panda_4x4';
    this.modelConfig = CONFIG.VEHICLES_CATALOG[this.modelId] || CONFIG.VEHICLES_CATALOG.panda_4x4;

    // Transform & Motion
    this.position = new THREE.Vector3(0, 0, 5);
    this.velocity = new THREE.Vector3(0, 0, 0);
    this.rotation = new THREE.Euler(0, 0, 0, 'YXZ');
    this.forwardSpeed = 0.0;
    this.lateralSpeed = 0.0;
    this.steerAngle = 0.0;
    this.isEngineOn = true;
    this.isLightsOn = true;
    this.isBraking = false;
    this.wasThrottling = false;

    // Transmission & Reverse Interlock
    this.gearState = 'DRIVE'; // 'DRIVE' or 'REVERSE'
    this.standstillTimer = 0.0;
    this.wasBraking = false;
    this.reverseArmed = false;
    this.is4WDEngaged = true; // Steyr-Puch 4WD engaged by default
    this.priminaCrawlerActive = false; // Primina crawler 1st gear for Panda 4x4

    // Engine & Drivetrain Live Telemetry
    this.speedKmh = 0;
    this.rpm = 0.0;             // Normalized 0..1
    this.engineRpmActual = 850; // Actual RPM (e.g. 850 - 7000)
    this.boostBar = 0.0;        // Live turbo boost pressure (Bar)
    this.gear = 1;
    this.hull = 100;
    this.fuel = this.modelConfig.fuelTankL * 0.85;
    this.maxFuel = this.modelConfig.fuelTankL;
    this.engineTemp = 75;
    this.battery = 100;
    this.tireWear = 0;
    this.oversteerSlip = 0.0;

    // Dynamic Physical Dimensions & 2-DOF Vehicle Dynamics State
    this.modelDims = this.getModelDimensions(this.modelId);
    this.currentRoll = 0.0;
    this.currentPitch = 0.0;
    this.lastSpeed = 0.0;
    this.actualTurnRate = 0.0;
    this.yawRate = 0.0;
    this.lateralSpeed = 0.0;
    this.slipAngle = 0.0;
    this.weightTransferLong = 0.0;
    this.hasFlatTire = false;
    this.chassisScrapeTimer = 0.0;
    this.terrainZone = 'PAVED';
    this.terrainStatusText = 'ASFALTO (CARREGGIATA)';
    this.terrainStatusColor = '#22c55e';

    // Progressive Non-Linear Steering & Impact Shock State
    this.filteredSteer = 0.0;
    this.impactShockPitch = 0.0;
    this.impactShockRoll = 0.0;

    // Installed Modular Upgrades
    this.upgrades = {
      bullbar: false,
      roof_lights: false,
      offroad_tires: false,
      aux_tank: false,
      turbo_cooler: false,
      armored_hull: false,
      studded_tires: false,
      rally_suspension: false,
      diff_lock_lsd: false,
      block_heater: false,
      copper_radiator: false,
      turbo_boost_kit: false,
      snorkel_intake: false,
      skid_plate: false,
      heavy_bullbar: false,
      aux_fuel_cell: false,
      roof_cargo_rack: false,
      rally_light_bar: false,
      cb_radar_scanner: false,
      agm_dual_battery: false
    };
    this.radarAlert = null;
    this.radarAlertTimer = 0;

    // 3D Meshes & Lights Group
    this.group = new THREE.Group();
    this.wheels = [];
    this.frontWheels = [];
    this.headlights = [];
    this.lightCones = [];
    this.taillights = [];
    this.upgradeMeshes = {};
    this.exhaustTip = new THREE.Vector3();
    this.antenna = null;

    this.buildCurrentVehicleMesh();
    this.scene.add(this.group);
  }

  /**
   * Switch the active vehicle to any model in the catalog
   */
  setModel(newModelId) {
    if (!CONFIG.VEHICLES_CATALOG[newModelId]) {
      console.warn(`Model ${newModelId} not found in catalog!`);
      return false;
    }

    this.modelId = newModelId;
    this.modelConfig = CONFIG.VEHICLES_CATALOG[newModelId];
    this.modelDims = this.getModelDimensions(newModelId);

    // Reset dynamic suspension angles & 2-DOF physics state
    this.currentRoll = 0.0;
    this.currentPitch = 0.0;
    this.steerAngle = 0.0;
    this.actualTurnRate = 0.0;
    this.yawRate = 0.0;
    this.lateralSpeed = 0.0;
    this.slipAngle = 0.0;
    this.weightTransferLong = 0.0;
    this.filteredSteer = 0.0;
    this.impactShockPitch = 0.0;
    this.impactShockRoll = 0.0;
    this.oversteerSlip = 0.0;

    // Adapt fuel capacity and adjust fuel proportionally
    const fuelRatio = this.maxFuel > 0 ? this.fuel / this.maxFuel : 0.8;
    this.maxFuel = this.modelConfig.fuelTankL + (this.upgrades.aux_tank ? 40 : 0);
    this.fuel = Math.min(this.maxFuel, Math.max(10, fuelRatio * this.maxFuel));

    // Reset turbo boost
    this.boostBar = 0.0;

    // Rebuild 3D mesh
    this.buildCurrentVehicleMesh();

    // Inform audio engine of new engine acoustic profile
    if (this.audioEngine && this.audioEngine.setEngineProfile) {
      this.audioEngine.setEngineProfile(this.modelConfig.soundProfile);
    }

    return true;
  }

  getCurrentModelConfig() {
    return this.modelConfig;
  }

  /**
   * Cleans and rebuilds the 3D meshes for the active car model
   */
  buildCurrentVehicleMesh() {
    // 1. Remove all old children from group
    while (this.group.children.length > 0) {
      const obj = this.group.children[0];
      this.group.remove(obj);
      if (obj.geometry) obj.geometry.dispose();
      if (obj.material) {
        if (Array.isArray(obj.material)) obj.material.forEach((m) => m.dispose());
        else obj.material.dispose();
      }
    }

    this.wheels = [];
    this.frontWheels = [];
    this.headlights = [];
    this.lightCones = [];
    this.taillights = [];
    this.upgradeMeshes = {};

    const cfg = this.modelConfig;

    // 2. Curated Model Palettes & Materials
    const palette = this.getModelPalette(cfg.id);

    const bodyMat = new THREE.MeshStandardMaterial({
      color: palette.bodyColor,
      roughness: palette.roughness || 0.45,
      metalness: palette.metalness || 0.55
    });

    const trimMat = new THREE.MeshStandardMaterial({
      color: palette.trimColor || 0x1f2326,
      roughness: 0.8,
      metalness: 0.3
    });

    const chromeMat = new THREE.MeshStandardMaterial({
      color: 0xdde3ea,
      roughness: 0.18,
      metalness: 0.95
    });

    const glassMat = new THREE.MeshStandardMaterial({
      color: 0x111a22,
      roughness: 0.1,
      metalness: 0.9,
      transparent: true,
      opacity: 0.85
    });

    const tireMat = new THREE.MeshStandardMaterial({
      color: 0x141517,
      roughness: 0.95
    });

    const rimMat = new THREE.MeshStandardMaterial({
      color: palette.rimColor || 0x6e7882,
      roughness: 0.3,
      metalness: 0.85
    });

    // 3. Dimensional Scaling based on car type
    const dims = this.getModelDimensions(cfg.id);

    // Main lower chassis
    const chassisGeo = new THREE.BoxGeometry(dims.width * 0.96, dims.chassisHeight, dims.length * 0.98);
    const chassis = new THREE.Mesh(chassisGeo, trimMat);
    chassis.position.y = dims.groundY + dims.chassisHeight * 0.5;
    chassis.castShadow = true;
    chassis.receiveShadow = true;
    this.group.add(chassis);

    // Main lower body shell (fenders, doors, rocker panels)
    const bodyGeo = new THREE.BoxGeometry(dims.width, dims.bodyHeight, dims.length);
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = chassis.position.y + dims.chassisHeight * 0.5 + dims.bodyHeight * 0.5;
    body.castShadow = true;
    body.receiveShadow = true;
    this.group.add(body);

    // Model-Specific Hood, Grille & Front Fascia
    this.buildFrontFascia(cfg.id, dims, body.position.y, bodyMat, trimMat, chromeMat);

    // Model-Specific Cabin Greenhouse (roof, pillars, windshield, side windows)
    this.buildCabinGreenhouse(cfg.id, dims, body.position.y, bodyMat, trimMat, glassMat, chromeMat);

    // Model-Specific Rear Fascia & Tailgate
    this.buildRearFascia(cfg.id, dims, body.position.y, bodyMat, trimMat, chromeMat);

    // 4. Wheels & Suspension Setup
    this.buildWheels(dims, tireMat, rimMat, chromeMat, trimMat);

    // 5. Headlights & Volumetric Fog Light Cones
    this.buildLighting(dims, body.position.y, chromeMat);

    // 6. Model-Specific Exterior Details (Spoilers, Snorkel, Spare Wheels, Roof Rails)
    this.buildModelSpecificAccoutrements(cfg.id, dims, body.position.y, bodyMat, trimMat, chromeMat);

    // 7. Radio Antenna
    const antX = -dims.width * 0.44;
    const antZ = -dims.length * 0.38;
    const antBaseY = body.position.y + dims.bodyHeight * 0.5 + dims.cabinHeight;

    const antBase = new THREE.Mesh(new THREE.CylinderGeometry(0.03, 0.05, 0.15, 6), trimMat);
    antBase.position.set(antX, antBaseY, antZ);
    this.group.add(antBase);

    this.antenna = new THREE.Mesh(
      new THREE.CylinderGeometry(0.012, 0.018, 1.8, 4),
      new THREE.MeshStandardMaterial({ color: 0xa0aec0, metalness: 0.9 })
    );
    this.antenna.position.set(antX, antBaseY + 0.9, antZ);
    this.group.add(this.antenna);

    // 8. Re-apply any installed modular upgrades (bullbar, roof lights, etc.)
    this.buildUpgradeModules(dims, body.position.y, trimMat);
  }

  /**
   * Period-correct color palettes for the 11 European models
   */
  getModelPalette(modelId) {
    switch (modelId) {
      case 'panda_4x4':
        return { bodyColor: 0x4a5d4e, trimColor: 0x1f2322, rimColor: 0xd1d5db, roughness: 0.65, metalness: 0.25 }; // Forest Green
      case 'delta_integrale':
        return { bodyColor: 0xb91c1c, trimColor: 0x111315, rimColor: 0xe2e8f0, roughness: 0.35, metalness: 0.65 }; // Rosso Monza WRC
      case 'mercedes_w123':
        return { bodyColor: 0xc4cad2, trimColor: 0x24282c, rimColor: 0xe2e8f0, roughness: 0.3, metalness: 0.8 }; // Classic Silbermetallic
      case 'mercedes_gwagen':
        return { bodyColor: 0x3d433b, trimColor: 0x181a18, rimColor: 0x475569, roughness: 0.7, metalness: 0.3 }; // NATO Olivgrün
      case 'defender_110':
        return { bodyColor: 0x38483e, trimColor: 0x181b19, rimColor: 0xf8fafc, roughness: 0.75, metalness: 0.2 }; // Keswick Green + Limestone wheels
      case 'volvo_245':
        return { bodyColor: 0x273b4d, trimColor: 0x15181b, rimColor: 0xcfd8dc, roughness: 0.45, metalness: 0.5 }; // Swedish Dark Blue
      case 'audi_quattro':
        return { bodyColor: 0x991b1b, trimColor: 0x151618, rimColor: 0xe2e8f0, roughness: 0.32, metalness: 0.7 }; // Tornado Red / Audi Sport
      case 'bmw_e30_ix':
        return { bodyColor: 0x22262c, trimColor: 0x121417, rimColor: 0xd8e0e8, roughness: 0.35, metalness: 0.75 }; // Diamantschwarz Metallic
      case 'alfa_giulia':
        return { bodyColor: 0x881313, trimColor: 0x1a1c1e, rimColor: 0xe2e8f0, roughness: 0.3, metalness: 0.8 }; // Rosso Alfa 501
      case 'peugeot_504_dangel':
        return { bodyColor: 0xb48235, trimColor: 0x1c1e1d, rimColor: 0xd1d5db, roughness: 0.6, metalness: 0.35 }; // Sahara Safari Ochre
      case 'golf_country':
        return { bodyColor: 0x214d3b, trimColor: 0x181e1a, rimColor: 0x94a3b8, roughness: 0.5, metalness: 0.45 }; // Montana Waldgrün
      default:
        return { bodyColor: 0x3e4843, trimColor: 0x1f2326, rimColor: 0x64707a, roughness: 0.5, metalness: 0.5 };
    }
  }

  /**
   * Silhouette bounding parameters for each car
   */
  getModelDimensions(modelId) {
    switch (modelId) {
      case 'panda_4x4':
        return { width: 1.55, length: 3.40, groundY: 0.40, chassisHeight: 0.36, bodyHeight: 0.54, cabinHeight: 0.70, cabinLength: 2.1, wheelRadius: 0.36, wheelWidth: 0.24, wheelBase: 2.15, trackWidth: 1.38, isHatch: true };
      case 'delta_integrale':
        return { width: 1.74, length: 3.90, groundY: 0.33, chassisHeight: 0.32, bodyHeight: 0.48, cabinHeight: 0.64, cabinLength: 2.2, wheelRadius: 0.36, wheelWidth: 0.28, wheelBase: 2.48, trackWidth: 1.52, isRallyWide: true };
      case 'mercedes_w123':
        return { width: 1.78, length: 4.72, groundY: 0.36, chassisHeight: 0.34, bodyHeight: 0.50, cabinHeight: 0.66, cabinLength: 3.0, wheelRadius: 0.38, wheelWidth: 0.26, wheelBase: 2.80, trackWidth: 1.50, isWagon: true };
      case 'mercedes_gwagen':
        return { width: 1.82, length: 4.25, groundY: 0.50, chassisHeight: 0.44, bodyHeight: 0.62, cabinHeight: 0.82, cabinLength: 2.6, wheelRadius: 0.44, wheelWidth: 0.30, wheelBase: 2.85, trackWidth: 1.54, isBoxy4x4: true };
      case 'defender_110':
        return { width: 1.84, length: 4.60, groundY: 0.52, chassisHeight: 0.46, bodyHeight: 0.66, cabinHeight: 0.86, cabinLength: 3.0, wheelRadius: 0.46, wheelWidth: 0.30, wheelBase: 2.98, trackWidth: 1.56, isSafari: true };
      case 'volvo_245':
        return { width: 1.74, length: 4.78, groundY: 0.36, chassisHeight: 0.34, bodyHeight: 0.52, cabinHeight: 0.68, cabinLength: 3.1, wheelRadius: 0.38, wheelWidth: 0.26, wheelBase: 2.78, trackWidth: 1.48, isBrickWagon: true };
      case 'audi_quattro':
        return { width: 1.72, length: 4.40, groundY: 0.34, chassisHeight: 0.34, bodyHeight: 0.48, cabinHeight: 0.62, cabinLength: 2.4, wheelRadius: 0.38, wheelWidth: 0.28, wheelBase: 2.54, trackWidth: 1.52, isCoupeFlared: true };
      case 'bmw_e30_ix':
        return { width: 1.68, length: 4.32, groundY: 0.35, chassisHeight: 0.33, bodyHeight: 0.46, cabinHeight: 0.64, cabinLength: 2.6, wheelRadius: 0.37, wheelWidth: 0.26, wheelBase: 2.56, trackWidth: 1.46, isSportTouring: true };
      case 'alfa_giulia':
        return { width: 1.62, length: 4.14, groundY: 0.35, chassisHeight: 0.32, bodyHeight: 0.48, cabinHeight: 0.64, cabinLength: 2.3, wheelRadius: 0.36, wheelWidth: 0.24, wheelBase: 2.51, trackWidth: 1.42, isClassicSaloon: true };
      case 'peugeot_504_dangel':
        return { width: 1.72, length: 4.60, groundY: 0.48, chassisHeight: 0.40, bodyHeight: 0.54, cabinHeight: 0.70, cabinLength: 2.9, wheelRadius: 0.42, wheelWidth: 0.28, wheelBase: 2.86, trackWidth: 1.50, isSafariWagon: true };
      case 'golf_country':
        return { width: 1.68, length: 3.98, groundY: 0.46, chassisHeight: 0.38, bodyHeight: 0.52, cabinHeight: 0.68, cabinLength: 2.3, wheelRadius: 0.40, wheelWidth: 0.26, wheelBase: 2.46, trackWidth: 1.46, isRaisedSyncro: true };
      default:
        return { width: 1.75, length: 4.20, groundY: 0.42, chassisHeight: 0.38, bodyHeight: 0.56, cabinHeight: 0.70, cabinLength: 2.5, wheelRadius: 0.40, wheelWidth: 0.28, wheelBase: 2.60, trackWidth: 1.50 };
    }
  }

  /**
   * Front Fascia: Grille, Radiator, Bumper, and Brand Identification
   */
  buildFrontFascia(modelId, dims, bodyCenterY, bodyMat, trimMat, chromeMat) {
    const frontZ = dims.length * 0.5;

    // Heavy Front Bumper
    const bumperMat = (modelId === 'mercedes_w123' || modelId === 'alfa_giulia') ? chromeMat : trimMat;
    const bumperWidth = dims.width * (dims.isRallyWide ? 1.08 : 1.04);
    const bumperDepth = modelId === 'volvo_245' ? 0.42 : 0.28; // Massive 5-mph bumper on Volvo
    const fvBumper = new THREE.Mesh(new THREE.BoxGeometry(bumperWidth, 0.32, bumperDepth), bumperMat);
    fvBumper.position.set(0, dims.groundY + dims.chassisHeight * 0.7, frontZ + bumperDepth * 0.5);
    fvBumper.castShadow = true;
    this.group.add(fvBumper);

    // Radiator Grille & Brand Elements
    if (modelId === 'mercedes_w123') {
      // Classic Vertical Chrome Grille with 3-Pointed Star
      const grille = new THREE.Mesh(new THREE.BoxGeometry(0.75, 0.50, 0.12), chromeMat);
      grille.position.set(0, bodyCenterY + 0.05, frontZ + 0.02);
      this.group.add(grille);

      // Star mascot on top of hood
      const starStem = new THREE.Mesh(new THREE.CylinderGeometry(0.015, 0.015, 0.12, 6), chromeMat);
      starStem.position.set(0, bodyCenterY + 0.36, frontZ - 0.02);
      const starRing = new THREE.Mesh(new THREE.TorusGeometry(0.055, 0.01, 8, 12), chromeMat);
      starRing.position.set(0, bodyCenterY + 0.42, frontZ - 0.02);
      this.group.add(starStem);
      this.group.add(starRing);
    } else if (modelId === 'bmw_e30_ix') {
      // Iconic BMW Twin Kidney Grille
      [-0.14, 0.14].forEach((kx) => {
        const kidney = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.38, 0.1), chromeMat);
        kidney.position.set(kx, bodyCenterY, frontZ + 0.02);
        this.group.add(kidney);
      });
      // Outer black slats
      [-0.6, 0.6].forEach((gx) => {
        const slats = new THREE.Mesh(new THREE.BoxGeometry(0.55, 0.35, 0.08), trimMat);
        slats.position.set(gx, bodyCenterY, frontZ + 0.01);
        this.group.add(slats);
      });
    } else if (modelId === 'alfa_giulia') {
      // Classic Alfa Romeo Trilobo Heart Grille
      const heart = new THREE.Mesh(new THREE.ConeGeometry(0.18, 0.42, 3), chromeMat);
      heart.rotation.x = Math.PI;
      heart.position.set(0, bodyCenterY - 0.02, frontZ + 0.02);
      this.group.add(heart);
      // Horizontal chrome mustache whiskers
      [-0.5, 0.5].forEach((wx) => {
        const whisker = new THREE.Mesh(new THREE.BoxGeometry(0.65, 0.06, 0.06), chromeMat);
        whisker.position.set(wx, bodyCenterY, frontZ + 0.01);
        this.group.add(whisker);
      });
    } else if (modelId === 'delta_integrale') {
      // Rally aggressive black mesh grille with HF badge
      const grille = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, 0.32, 0.08), trimMat);
      grille.position.set(0, bodyCenterY, frontZ + 0.02);
      this.group.add(grille);

      // Hood cooling louvers
      [-0.35, 0.35].forEach((hx) => {
        const vent = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.06, 0.45), trimMat);
        vent.position.set(hx, bodyCenterY + dims.bodyHeight * 0.52, frontZ - 0.55);
        this.group.add(vent);
      });
    } else {
      // Standard robust mesh grille
      const grille = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.8, 0.38, 0.1), trimMat);
      grille.position.set(0, bodyCenterY, frontZ + 0.02);
      this.group.add(grille);
    }
  }

  /**
   * Cabin Greenhouse: Roof, Pillars, Windshield and Windows
   */
  buildCabinGreenhouse(modelId, dims, bodyCenterY, bodyMat, trimMat, glassMat, chromeMat) {
    const cabinY = bodyCenterY + dims.bodyHeight * 0.5 + dims.cabinHeight * 0.5;
    const cabinZ = -dims.length * 0.08;

    // Main roof shell
    const cabinGeo = new THREE.BoxGeometry(dims.width * 0.90, dims.cabinHeight, dims.cabinLength);
    const cabin = new THREE.Mesh(cabinGeo, bodyMat);
    cabin.position.set(0, cabinY, cabinZ);
    cabin.castShadow = true;
    this.group.add(cabin);

    // Front Windshield (sloped)
    const wsZ = cabinZ + dims.cabinLength * 0.5 + 0.04;
    const wsSlope = (modelId === 'mercedes_gwagen' || modelId === 'defender_110') ? -0.15 : -0.38;
    const ws = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.86, dims.cabinHeight * 0.85, 0.08), glassMat);
    ws.position.set(0, cabinY, wsZ);
    ws.rotation.x = wsSlope;
    this.group.add(ws);

    // Side Windows
    [-dims.width * 0.46, dims.width * 0.46].forEach((sx) => {
      const sideGlass = new THREE.Mesh(new THREE.BoxGeometry(0.06, dims.cabinHeight * 0.75, dims.cabinLength * 0.92), glassMat);
      sideGlass.position.set(sx, cabinY, cabinZ);
      this.group.add(sideGlass);

      // Side rearview mirrors
      const mirror = new THREE.Mesh(new THREE.BoxGeometry(0.24, 0.16, 0.1), trimMat);
      mirror.position.set(sx * 1.14, cabinY - 0.1, wsZ);
      this.group.add(mirror);
    });

    // Rear Window
    const rwZ = cabinZ - dims.cabinLength * 0.5 - 0.03;
    const rwSlope = dims.isCoupeFlared ? 0.55 : 0.08; // Audi Quattro fastback slant vs upright wagon
    const rw = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, dims.cabinHeight * 0.75, 0.08), glassMat);
    rw.position.set(0, cabinY, rwZ);
    rw.rotation.x = rwSlope;
    this.group.add(rw);

    // Roof Ribs on Panda 4x4
    if (modelId === 'panda_4x4') {
      [-0.45, -0.15, 0.15, 0.45].forEach((rx) => {
        const rib = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.04, dims.cabinLength * 0.9), trimMat);
        rib.position.set(rx, cabinY + dims.cabinHeight * 0.5 + 0.02, cabinZ);
        this.group.add(rib);
      });
    }

    // Roof Luggage Rails on Wagons (W123, Volvo 245, BMW Touring)
    if (dims.isWagon || dims.isBrickWagon || dims.isSportTouring) {
      [-dims.width * 0.40, dims.width * 0.40].forEach((rx) => {
        const rail = new THREE.Mesh(new THREE.BoxGeometry(0.05, 0.08, dims.cabinLength * 0.95), chromeMat);
        rail.position.set(rx, cabinY + dims.cabinHeight * 0.5 + 0.06, cabinZ);
        this.group.add(rail);
      });
    }
  }

  /**
   * Rear Fascia: Taillights, Bumper, and Model Tailgate
   */
  buildRearFascia(modelId, dims, bodyCenterY, bodyMat, trimMat, chromeMat) {
    const rearZ = -dims.length * 0.5;

    // Rear Bumper
    const bumperMat = (modelId === 'mercedes_w123' || modelId === 'alfa_giulia') ? chromeMat : trimMat;
    const bumperWidth = dims.width * (dims.isRallyWide ? 1.08 : 1.04);
    const rvBumper = new THREE.Mesh(new THREE.BoxGeometry(bumperWidth, 0.32, 0.28), bumperMat);
    rvBumper.position.set(0, dims.groundY + dims.chassisHeight * 0.7, rearZ - 0.14);
    rvBumper.castShadow = true;
    this.group.add(rvBumper);

    // Dual Taillights
    const tailY = bodyCenterY + 0.05;
    [-dims.width * 0.38, dims.width * 0.38].forEach((tx) => {
      const tail = new THREE.Mesh(
        new THREE.BoxGeometry(0.32, 0.18, 0.1),
        new THREE.MeshStandardMaterial({
          color: 0x990000,
          emissive: 0xdd1111,
          emissiveIntensity: 0.6,
          roughness: 0.3
        })
      );
      tail.position.set(tx, tailY, rearZ - 0.02);
      this.group.add(tail);
      this.taillights.push(tail);
    });

    // Rear Exhaust Tip
    const exhaustX = dims.width * 0.34;
    const exhaustY = dims.groundY + dims.chassisHeight * 0.5;
    const exhaustZ = rearZ - 0.22;
    this.exhaustTip.set(exhaustX, exhaustY, exhaustZ);

    const exhaust = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.07, 0.35, 8), trimMat);
    exhaust.rotation.x = Math.PI / 2;
    exhaust.position.set(exhaustX, exhaustY, exhaustZ);
    this.group.add(exhaust);

    // Dual Rally Exhaust for Delta Integrale
    if (modelId === 'delta_integrale') {
      const ex2 = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.07, 0.35, 8), chromeMat);
      ex2.rotation.x = Math.PI / 2;
      ex2.position.set(exhaustX - 0.18, exhaustY, exhaustZ);
      this.group.add(ex2);
    }
  }

  /**
   * Wheels & Suspension Layout based on track and wheelbase
   */
  buildWheels(dims, tireMat, rimMat, chromeMat, trimMat) {
    const halfBase = dims.wheelBase * 0.5;
    const halfTrack = dims.trackWidth * 0.5;
    const wheelY = dims.groundY;

    const wheelPositions = [
      { x: -halfTrack, y: wheelY, z: halfBase, isFront: true },
      { x: halfTrack, y: wheelY, z: halfBase, isFront: true },
      { x: -halfTrack, y: wheelY, z: -halfBase, isFront: false },
      { x: halfTrack, y: wheelY, z: -halfBase, isFront: false }
    ];

    wheelPositions.forEach((wp) => {
      const wheelGroup = new THREE.Group();
      wheelGroup.position.set(wp.x, wp.y, wp.z);

      // Outer Tire
      const tire = new THREE.Mesh(new THREE.CylinderGeometry(dims.wheelRadius, dims.wheelRadius, dims.wheelWidth, 16), tireMat);
      tire.rotation.z = Math.PI / 2;
      tire.castShadow = true;
      wheelGroup.add(tire);

      // Inner Rim
      const rimRadius = dims.wheelRadius * 0.65;
      const rim = new THREE.Mesh(new THREE.CylinderGeometry(rimRadius, rimRadius, dims.wheelWidth + 0.02, 10), rimMat);
      rim.rotation.z = Math.PI / 2;
      wheelGroup.add(rim);

      // Center Hub
      const hub = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.1, dims.wheelWidth + 0.04, 6), chromeMat);
      hub.rotation.z = Math.PI / 2;
      wheelGroup.add(hub);

      // Wheel Arch Flares (Paracolpi / Parafanghi allargati)
      const flareWidth = dims.isRallyWide || dims.isCoupeFlared ? 0.36 : 0.22;
      const flare = new THREE.Mesh(new THREE.BoxGeometry(flareWidth, 0.18, dims.wheelRadius * 2.3), trimMat);
      flare.position.set(wp.x * 0.94, wheelY + dims.wheelRadius * 0.85, wp.z);
      this.group.add(flare);

      this.group.add(wheelGroup);
      this.wheels.push(wheelGroup);
      if (wp.isFront) this.frontWheels.push(wheelGroup);
    });
  }

  /**
   * Headlights & Volumetric Light Cones
   */
  buildLighting(dims, bodyCenterY, chromeMat) {
    const beamTexture = TextureGenerator.createVolumetricBeamTexture();
    const frontZ = dims.length * 0.5 + 0.05;
    const lightY = bodyCenterY + 0.04;
    const lightSpread = dims.width * 0.34;

    [-lightSpread, lightSpread].forEach((hx) => {
      // Light Bezel
      const bezel = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.18, 0.14, 12), chromeMat);
      bezel.rotation.x = Math.PI / 2;
      bezel.position.set(hx, lightY, frontZ);
      this.group.add(bezel);

      // High-Intensity Long-Range SpotLight (Reaching 125m ahead!)
      const spot = new THREE.SpotLight(0xfff6e8, 8.5, 125, Math.PI / 4.0, 0.42, 0.85);
      spot.position.set(hx, lightY, frontZ + 0.05);
      spot.target.position.set(hx * 0.3, 0.1, frontZ + 75);
      spot.castShadow = true;
      spot.shadow.mapSize.width = 1024;
      spot.shadow.mapSize.height = 1024;
      spot.shadow.camera.near = 0.5;
      spot.shadow.camera.far = 125;
      this.group.add(spot);
      this.group.add(spot.target);
      this.headlights.push(spot);

      // Extended Volumetric Light Beam Cone (65m long!)
      const coneGeo = new THREE.ConeGeometry(5.8, 65, 16, 1, true);
      coneGeo.translate(0, -32.5, 0);
      coneGeo.rotateX(-Math.PI / 2);
      const coneMat = new THREE.MeshBasicMaterial({
        map: beamTexture,
        transparent: true,
        opacity: 0.38,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        side: THREE.DoubleSide
      });
      const coneMesh = new THREE.Mesh(coneGeo, coneMat);
      coneMesh.position.set(hx, lightY, frontZ + 0.05);
      this.group.add(coneMesh);
      this.lightCones.push(coneMesh);
    });

    // Broad Forward Road-Washing Fill Light (illuminates asphalt markings and hazards ahead)
    const fillLight = new THREE.SpotLight(0xffeedd, 5.5, 110, Math.PI / 3.0, 0.6, 0.8);
    fillLight.position.set(0, lightY + 0.15, frontZ);
    fillLight.target.position.set(0, 0.1, frontZ + 55);
    this.group.add(fillLight);
    this.group.add(fillLight.target);
    this.headlights.push(fillLight);
  }

  /**
   * Unique Model Accoutrements (Snorkel, Spoilers, Spare Tire on Hatch, Roof Racks)
   */
  buildModelSpecificAccoutrements(modelId, dims, bodyCenterY, bodyMat, trimMat, chromeMat) {
    const rearZ = -dims.length * 0.5;
    const roofY = bodyCenterY + dims.bodyHeight * 0.5 + dims.cabinHeight;

    // 1. Defender 110: Raised Snorkel on Passenger A-Pillar
    if (modelId === 'defender_110') {
      const snorkelPipe = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.05, 1.3, 8), trimMat);
      snorkelPipe.position.set(dims.width * 0.48, bodyCenterY + 0.65, dims.length * 0.22);
      const snorkelTop = new THREE.Mesh(new THREE.BoxGeometry(0.18, 0.14, 0.22), trimMat);
      snorkelTop.position.set(dims.width * 0.48, bodyCenterY + 1.32, dims.length * 0.22);
      this.group.add(snorkelPipe);
      this.group.add(snorkelTop);
    }

    // 2. G-Klasse W460 & Golf Country: External Door-Mounted Spare Wheel
    if (modelId === 'mercedes_gwagen' || modelId === 'golf_country') {
      const spareTire = new THREE.Mesh(
        new THREE.CylinderGeometry(dims.wheelRadius * 0.95, dims.wheelRadius * 0.95, dims.wheelWidth, 14),
        trimMat
      );
      spareTire.rotation.x = Math.PI / 2;
      spareTire.position.set(0.15, bodyCenterY + 0.15, rearZ - dims.wheelWidth * 0.5 - 0.08);
      spareTire.castShadow = true;
      this.group.add(spareTire);
    }

    // 3. G-Klasse W460: Fender-Top Turn Signal Pods
    if (modelId === 'mercedes_gwagen') {
      [-dims.width * 0.44, dims.width * 0.44].forEach((fx) => {
        const pod = new THREE.Mesh(
          new THREE.BoxGeometry(0.12, 0.1, 0.18),
          new THREE.MeshStandardMaterial({ color: 0xf59e0b, emissive: 0xf59e0b, emissiveIntensity: 0.4 })
        );
        pod.position.set(fx, bodyCenterY + dims.bodyHeight * 0.52, dims.length * 0.42);
        this.group.add(pod);
      });
    }

    // 4. Lancia Delta HF Integrale: Adjustable Rear Roof Spoiler
    if (modelId === 'delta_integrale') {
      const spoilerWing = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.88, 0.06, 0.32), trimMat);
      spoilerWing.position.set(0, roofY + 0.15, -dims.length * 0.32);
      spoilerWing.rotation.x = 0.32; // aggressive downforce pitch

      [-dims.width * 0.36, dims.width * 0.36].forEach((sx) => {
        const upright = new THREE.Mesh(new THREE.BoxGeometry(0.04, 0.18, 0.18), trimMat);
        upright.position.set(sx, roofY + 0.07, -dims.length * 0.32);
        this.group.add(upright);
      });
      this.group.add(spoilerWing);
    }

    // 5. Audi Ur-Quattro: Integrated Rear Trunk Spoiler
    if (modelId === 'audi_quattro') {
      const lip = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, 0.08, 0.22), trimMat);
      lip.position.set(0, bodyCenterY + dims.bodyHeight * 0.48, rearZ + 0.15);
      this.group.add(lip);
    }

    // 6. Golf Country & Peugeot 504 Dangel: Front Offroad Tubular Nudge Bar
    if (modelId === 'golf_country' || modelId === 'peugeot_504_dangel') {
      const nudge = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.65, 0.55, 0.12), trimMat);
      nudge.position.set(0, dims.groundY + dims.chassisHeight * 0.85, dims.length * 0.5 + 0.25);
      this.group.add(nudge);
    }

    // 7. Standard Survivor Expedition Cargo (Jerrycans & Pelican Case on Wagons / Offroaders)
    if (dims.isSafari || dims.isBoxy4x4 || dims.isWagon || dims.isBrickWagon) {
      const cargoCase = new THREE.Mesh(
        new THREE.BoxGeometry(0.55, 0.28, 0.45),
        new THREE.MeshStandardMaterial({ color: 0xd97706, roughness: 0.7 })
      );
      cargoCase.position.set(0.35, roofY + 0.16, -dims.length * 0.15);
      this.group.add(cargoCase);

      const redCan = new THREE.Mesh(
        new THREE.BoxGeometry(0.28, 0.38, 0.22),
        new THREE.MeshStandardMaterial({ color: 0xb91c1c, roughness: 0.5, metalness: 0.3 })
      );
      redCan.position.set(-0.35, roofY + 0.20, -dims.length * 0.15);
      this.group.add(redCan);
    }
  }

  /**
   * Modular Upgrades attached to dynamic dimensions
   */
  buildUpgradeModules(dims, bodyCenterY, trimMat) {
    const frontZ = dims.length * 0.5;
    const roofY = bodyCenterY + dims.bodyHeight * 0.5 + dims.cabinHeight;

    // 1. Heavy Bullbar Upgrade
    const bullbarGroup = new THREE.Group();
    const bullbarFrame = new THREE.Mesh(
      new THREE.BoxGeometry(dims.width * 1.05, 0.65, 0.35),
      new THREE.MeshStandardMaterial({ color: 0x111315, roughness: 0.4, metalness: 0.8 })
    );
    bullbarFrame.position.set(0, dims.groundY + dims.chassisHeight * 0.9, frontZ + 0.32);
    bullbarGroup.add(bullbarFrame);

    // Winch
    const winch = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 0.55, 8), trimMat);
    winch.rotation.z = Math.PI / 2;
    winch.position.set(0, dims.groundY + dims.chassisHeight * 0.85, frontZ + 0.42);
    bullbarGroup.add(winch);

    bullbarGroup.visible = !!this.upgrades.bullbar;
    this.group.add(bullbarGroup);
    this.upgradeMeshes.bullbar = bullbarGroup;

    // 2. Roof LED Lightbar Upgrade
    const lightbarGroup = new THREE.Group();
    const barFrame = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, 0.12, 0.14), trimMat);
    barFrame.position.set(0, roofY + 0.1, dims.length * 0.18);
    lightbarGroup.add(barFrame);

    for (let lx = -dims.width * 0.35; lx <= dims.width * 0.35; lx += 0.22) {
      const led = new THREE.Mesh(
        new THREE.BoxGeometry(0.12, 0.08, 0.08),
        new THREE.MeshStandardMaterial({ color: 0xffffff, emissive: 0xffffff, emissiveIntensity: 1.5 })
      );
      led.position.set(lx, roofY + 0.1, dims.length * 0.18 + 0.08);
      lightbarGroup.add(led);
    }

    lightbarGroup.visible = !!(this.upgrades.roof_lights || this.upgrades.rally_light_bar);
    this.group.add(lightbarGroup);
    this.upgradeMeshes.roof_lights = lightbarGroup;

    // 3. Roof Expedition Cargo Rack Upgrade
    const rackGroup = new THREE.Group();
    const rackMat = new THREE.MeshStandardMaterial({ color: 0x1f2428, roughness: 0.6, metalness: 0.8 });
    const rackFrame = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.78, 0.14, dims.length * 0.45), rackMat);
    rackFrame.position.set(0, roofY + 0.12, -dims.length * 0.12);
    rackGroup.add(rackFrame);

    const case1 = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.22, 0.4), new THREE.MeshStandardMaterial({ color: 0xb45309, roughness: 0.7 }));
    case1.position.set(-0.18, roofY + 0.22, -dims.length * 0.12);
    rackGroup.add(case1);

    const spareCan = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.35, 0.22), new THREE.MeshStandardMaterial({ color: 0x15803d, roughness: 0.6 }));
    spareCan.position.set(0.22, roofY + 0.24, -dims.length * 0.12);
    rackGroup.add(spareCan);

    rackGroup.visible = !!(this.upgrades.roof_cargo_rack);
    this.group.add(rackGroup);
    this.upgradeMeshes.roof_cargo_rack = rackGroup;
  }

  applyUpgrade(upgradeId) {
    this.upgrades[upgradeId] = true;

    // Bullbar
    if ((upgradeId === 'heavy_bullbar' || upgradeId === 'bullbar') && this.upgradeMeshes.bullbar) {
      this.upgradeMeshes.bullbar.visible = true;
      this.upgrades.heavy_bullbar = true;
      this.upgrades.bullbar = true;
    }

    // Roof Lightbar
    if ((upgradeId === 'rally_light_bar' || upgradeId === 'roof_lights') && this.upgradeMeshes.roof_lights) {
      this.upgradeMeshes.roof_lights.visible = true;
      this.upgrades.rally_light_bar = true;
      this.upgrades.roof_lights = true;
      this.headlights.forEach((h) => {
        h.intensity = 5.8;
        h.distance = 70;
        h.angle = Math.PI / 3.8;
      });
      this.lightCones.forEach((cone) => {
        cone.scale.set(1.5, 1.5, 1.5);
        cone.material.opacity = 0.45;
      });
    }

    // Roof Cargo Rack
    if (upgradeId === 'roof_cargo_rack' && this.upgradeMeshes.roof_cargo_rack) {
      this.upgradeMeshes.roof_cargo_rack.visible = true;
    }

    // Aux Fuel Tank
    if (upgradeId === 'aux_fuel_cell' || upgradeId === 'aux_tank') {
      this.upgrades.aux_fuel_cell = true;
      this.upgrades.aux_tank = true;
      this.maxFuel = this.modelConfig.fuelTankL + 40;
      this.fuel = Math.min(this.fuel + 40, this.maxFuel);
    }

    // Turbo Boost Kit
    if (upgradeId === 'turbo_boost_kit') {
      if (this.modelConfig.hasTurbo) {
        this.modelConfig.turboBoostMaxBar = (this.modelConfig.turboBoostMaxBar || 1.0) + 0.35;
      }
    }

    // Aliases
    if (upgradeId === 'copper_radiator' || upgradeId === 'turbo_cooler') {
      this.upgrades.copper_radiator = true;
      this.upgrades.turbo_cooler = true;
    }
    if (upgradeId === 'studded_tires' || upgradeId === 'offroad_tires') {
      this.upgrades.studded_tires = true;
      this.upgrades.offroad_tires = true;
    }
    if (upgradeId === 'skid_plate' || upgradeId === 'armored_hull') {
      this.upgrades.skid_plate = true;
      this.upgrades.armored_hull = true;
    }
  }

  toggleLights() {
    this.isLightsOn = !this.isLightsOn;
    this.headlights.forEach((light) => {
      const isFill = light.angle > Math.PI / 3.5;
      if (isFill) {
        light.intensity = this.isLightsOn ? 5.5 : 0;
      } else {
        light.intensity = this.isLightsOn ? (this.upgrades.roof_lights ? 14.5 : 8.5) : 0;
      }
    });
    this.lightCones.forEach((cone) => {
      cone.visible = this.isLightsOn;
    });
    this.audioEngine.playSwitchClick(this.isLightsOn);
  }

  honkHorn() {
    if (this.audioEngine && this.audioEngine.playHorn) {
      this.audioEngine.playHorn(this.modelId);
    }
    this.impactShockPitch = 0.025;
  }

  toggle4WD() {
    this.is4WDEngaged = !this.is4WDEngaged;
    if (this.audioEngine && this.audioEngine.play4WDEngage) {
      this.audioEngine.play4WDEngage(this.is4WDEngaged);
    }
  }

  togglePrimina() {
    if (this.modelId !== 'panda_4x4') return;
    this.priminaCrawlerActive = !this.priminaCrawlerActive;
    if (this.audioEngine && this.audioEngine.playSwitchClick) {
      this.audioEngine.playSwitchClick(this.priminaCrawlerActive);
    }
  }

  getExhaustPosition() {
    const worldPos = this.exhaustTip.clone();
    worldPos.applyEuler(this.rotation);
    worldPos.add(this.position);
    return worldPos;
  }

  getRearWheelPositions() {
    const dims = this.modelDims || { width: 1.65, length: 3.8 };
    const halfTrack = dims.width * 0.44;
    const rearZ = -dims.length * 0.36;
    const cosY = Math.cos(this.rotation.y);
    const sinY = Math.sin(this.rotation.y);

    const left = new THREE.Vector3(
      this.position.x - halfTrack * cosY + rearZ * sinY,
      this.position.y + 0.1,
      this.position.z + halfTrack * sinY + rearZ * cosY
    );
    const right = new THREE.Vector3(
      this.position.x + halfTrack * cosY + rearZ * sinY,
      this.position.y + 0.1,
      this.position.z - halfTrack * sinY + rearZ * cosY
    );
    return { left, right };
  }

  /**
   * Main Physics, Powertrain, Turbo, and Handling Simulation Loop
   */
  update(delta, input, roadInfo, renderer = null, weatherImpact = null) {
    const cfg = this.modelConfig;

    if (!this.isEngineOn) {
      if (input.throttle > 0 && this.fuel > 0) {
        this.isEngineOn = true;
        if (this.audioEngine && this.audioEngine.startEngine) {
          this.audioEngine.startEngine();
        }
      } else {
        if (this.forwardSpeed > 0) {
          this.forwardSpeed = Math.max(0, this.forwardSpeed - delta * 12.0);
        } else if (this.forwardSpeed < 0) {
          this.forwardSpeed = Math.min(0, this.forwardSpeed + delta * 12.0);
        }
        if (Math.abs(this.forwardSpeed) < 0.05) this.forwardSpeed = 0.0;
        this.speedKmh = Math.round(this.forwardSpeed * 3.6);
        this.rpm = Math.max(0, this.rpm - delta * 2.0);
        this.boostBar = Math.max(0, this.boostBar - delta * 3.0);
        this.steerAngle = THREE.MathUtils.lerp(this.steerAngle, 0, delta * 8.0);
        this.currentRoll = THREE.MathUtils.lerp(this.currentRoll, 0, delta * 12.0);
        this.currentPitch = THREE.MathUtils.lerp(this.currentPitch, 0, delta * 12.0);
        this.actualTurnRate = 0.0;
        this.audioEngine.setEngineRPM(0, false);
        this.updateMeshTransforms(delta);
        return;
      }
    }

    // ==========================================
    // 1. PHYSICAL CONSTANTS & MASS GEOMETRY
    // ==========================================
    const mass = cfg.weightKg || 1200;
    const g = 9.81;
    const totalWeight = mass * g;
    const wheelbase = (this.modelDims ? this.modelDims.length : 3.8) * 0.62; // Wheelbase L = a + b (~2.3 to 2.8m)
    const weightDistFront = 0.52; // 52% front, 48% rear static balance
    const distA = wheelbase * (1.0 - weightDistFront); // distance CG -> front axle
    const distB = wheelbase * weightDistFront;       // distance CG -> rear axle
    const cgHeight = 0.52; // Center of Gravity height in meters
    const yawInertia = mass * (distA * distB * 1.15); // Mass moment of inertia Iz

    // ==========================================
    // INTELLIGENT OFF-ROAD & WEATHER SURFACE FRICTION
    // ==========================================
    const weatherFriction = (weatherImpact && weatherImpact.frictionMultiplier !== undefined) ? weatherImpact.frictionMultiplier : 1.0;
    const baseSurfaceFriction = (roadInfo.surface ? roadInfo.surface.friction : 1.0) * weatherFriction;
    const roadHalfW = (roadInfo.width || 24.0) * 0.5;
    const pavedHalfW = roadHalfW * 0.78;
    const distFromCenter = this.position.x - roadInfo.x;
    const absDist = Math.abs(distFromCenter);

    const isRuggedOffroader = (
      cfg.id === 'panda_4x4' ||
      cfg.id === 'defender_110' ||
      cfg.id === 'mercedes_gwagen' ||
      cfg.id === 'peugeot_504_dangel' ||
      cfg.id === 'golf_country' ||
      cfg.drivetrain === '4WD_LOCK' ||
      this.upgrades.rally_suspension ||
      this.upgrades.offroad_tires
    );

    let rollCoeff = 0.015;
    let surfaceGripMult = 1.0;
    const currentSpeedKmh = Math.abs(this.forwardSpeed * 3.6);

    if (absDist <= pavedHalfW) {
      // Zone 1: Paved Carriageway
      this.terrainZone = 'PAVED';
      this.terrainStatusText = 'ASFALTO (CARREGGIATA)';
      this.terrainStatusColor = '#22c55e';
      rollCoeff = 0.015;
      surfaceGripMult = 1.0;
      this.chassisScrapeTimer = 0.0;
    } else if (absDist <= roadHalfW) {
      // Zone 2: Gravel Shoulder - "Non deve essere un problema"
      this.terrainZone = 'SHOULDER';
      this.terrainStatusText = 'BANCHINA GHIAIA [ OK ]';
      this.terrainStatusColor = '#38bdf8';
      const shoulderDamp = this.upgrades.rally_suspension ? 0.55 : 1.0;
      rollCoeff = 0.015 + 0.022 * shoulderDamp;
      surfaceGripMult = 0.88;
      this.chassisScrapeTimer = 0.0;
    } else {
      // Zone 3: Off-road Wilderness / Roadside Ditch
      // "A volte deve essere un problema a volte no"
      if (isRuggedOffroader) {
        // Rugged 4x4 or Off-Road Package: NOT A PROBLEM!
        this.terrainZone = 'OFFROAD_SAFE';
        this.terrainStatusText = 'TERRENO NATURALE [ 4x4 ATTIVA ✓ ]';
        this.terrainStatusColor = '#10b981';
        rollCoeff = 0.038;
        surfaceGripMult = 0.78;
        this.chassisScrapeTimer = 0.0;
      } else {
        // Low Street Car (Alfa Giulia, BMW E30, Mercedes W123, Volvo 245):
        if (currentSpeedKmh <= 35.0) {
          // Crawling slow: NOT A PROBLEM!
          this.terrainZone = 'OFFROAD_CRAWL';
          this.terrainStatusText = 'FUORISTRADA [ CRAWL LENTO OK ]';
          this.terrainStatusColor = '#f59e0b';
          rollCoeff = 0.052;
          surfaceGripMult = 0.68;
          this.chassisScrapeTimer = 0.0;
        } else {
          // Fast off-road in low street car: IT IS A PROBLEM!
          this.terrainZone = 'OFFROAD_HAZARD';
          this.terrainStatusText = '⚠️ FUORISTRADA: RISCHIO FONDO!';
          this.terrainStatusColor = '#ef4444';
          rollCoeff = 0.11;
          surfaceGripMult = 0.52;

          this.chassisScrapeTimer += delta;
          if (this.chassisScrapeTimer >= 1.2) {
            this.chassisScrapeTimer = 0.0;
            if (!this.upgrades.skid_plate && !this.upgrades.armored_hull) {
              this.hull = Math.max(0, this.hull - 2);
              this.impactShockPitch = 0.06 * (Math.random() - 0.5);
              this.impactShockRoll = 0.06 * (Math.random() - 0.5);
              if (this.audioEngine && this.audioEngine.playChassisScrape) {
                this.audioEngine.playChassisScrape();
              }
            }
          }
        }
      }
    }

    let tireGrip = (cfg.tractionBonus || 1.0) * surfaceGripMult;
    if (this.upgrades.studded_tires || this.upgrades.offroad_tires) {
      tireGrip *= (baseSurfaceFriction < 0.7 ? 1.35 : 1.15);
    }
    if (this.upgrades.diff_lock_lsd) {
      tireGrip *= 1.12;
    }
    const mu = baseSurfaceFriction * tireGrip;
    this.currentRollCoeff = rollCoeff;

    // ==========================================
    // 2. POWERTRAIN, THROTTLE & BRAKE FORCES
    // ==========================================
    const isThrottle = input.throttle > 0 && this.fuel > 0;
    this.isBraking = input.brake > 0;

    // Progressive Turbo Spool & Liftoff Sound FX
    const liftoff = this.wasThrottling && !isThrottle;
    if (liftoff) {
      if (cfg.hasTurbo && this.boostBar > 0.28) {
        this.audioEngine.playTurboBlowOff(this.boostBar);
      } else if (this.rpm > 0.62 && Math.random() < 0.65) {
        this.audioEngine.playBackfire(Math.min(1.0, this.rpm));
        if (renderer) renderer.emitBackfire(this.getExhaustPosition());
      }
    }
    this.wasThrottling = isThrottle;

    if (cfg.hasTurbo) {
      if (isThrottle) {
        this.boostBar = THREE.MathUtils.lerp(this.boostBar, cfg.turboBoostMaxBar, delta * 2.2);
      } else {
        this.boostBar = Math.max(0, this.boostBar - delta * 4.2);
      }
    } else {
      this.boostBar = 0.0;
    }

    // Engine Drive Force F_drive
    let F_drive = 0.0;
    let F_brake = 0.0;
    const maxSpeedMs = cfg.topSpeedKmh / 3.6;
    const speedAbs = Math.abs(this.forwardSpeed);

    // ==========================================
    // REVERSE TRANSMISSION INTERLOCK (PAOLO'S RULES)
    // 1. Car must come to a stop before reverse can be engaged.
    // 2. Must remain stopped for at least 1.0 second.
    // 3. To engage reverse, player must re-press the reverse/brake key (distinct press).
    // 4. Holding brake while stopping will NEVER engage reverse; keeps car stationary!
    // ==========================================
    const isStationary = speedAbs <= 0.15;

    if (this.gearState === 'DRIVE') {
      if (isStationary) {
        this.standstillTimer += delta;
        // Arm reverse after 1.0s standstill once brake is released or if stationary >= 1.0s
        if (!this.isBraking && this.standstillTimer >= 1.0) {
          this.reverseArmed = true;
        }
        // If 1 second standstill has elapsed and player presses brake again:
        if (this.isBraking && !this.wasBraking && (this.standstillTimer >= 1.0 || this.reverseArmed)) {
          this.gearState = 'REVERSE';
          this.standstillTimer = 0.0;
          this.reverseArmed = false;
          if (this.audioEngine && this.audioEngine.playSwitchClick) {
            this.audioEngine.playSwitchClick(true);
          }
        }
      } else {
        this.standstillTimer = 0.0;
        this.reverseArmed = false;
      }

      // DRIVE GEAR POWERTRAIN
      if (isThrottle) {
        const hpPerTon = cfg.powerHp / (mass / 1000.0);
        const baseAccel = (hpPerTon / 100.0) * 2.6;
        const aeroDrag = Math.max(0.20, 1.0 - Math.pow(speedAbs / Math.max(1.0, maxSpeedMs * 1.05), 1.6) * 0.75);
        const boostMult = this.upgrades.turbo_boost_kit ? 0.55 : 0.35;
        const turboBoost = cfg.hasTurbo ? (1.0 + (this.boostBar / Math.max(0.1, cfg.turboBoostMaxBar)) * boostMult) : 1.0;
        const accelTarget = baseAccel * aeroDrag * input.throttle * turboBoost;
        F_drive = accelTarget * mass;

        const baseFuelRate = cfg.fuelConsumptionRate || 0.032;
        const fuelBurn = baseFuelRate * delta * input.throttle * (1.0 + speedAbs / 35.0);
        this.fuel = Math.max(0, this.fuel - fuelBurn);
        const heatRate = (this.upgrades.copper_radiator || this.upgrades.turbo_cooler) ? 0.022 : 0.065;
        this.engineTemp = Math.min(130, this.engineTemp + heatRate * input.throttle * delta * 12.0);

        if (renderer) renderer.emitExhaust(this.getExhaustPosition(), true);
      } else {
        this.engineTemp = Math.max(70, this.engineTemp - delta * 0.05 * 15.0);
        if (renderer && Math.random() < 0.18) renderer.emitExhaust(this.getExhaustPosition(), false);
      }

      // DRIVE BRAKING: brings car to stop and locks it at 0 (NEVER reverses while in DRIVE)
      if (this.isBraking) {
        if (this.forwardSpeed > 0.25) {
          const brakeDecel = (cfg.handling.brakeForce || 28.0) * 0.28 * input.brake;
          F_brake = brakeDecel * mass;
          if (this.forwardSpeed > 16.0 && Math.random() < 0.12) {
            this.audioEngine.playTireScreech();
          }
        } else {
          this.forwardSpeed = 0.0;
          F_brake = 14.0 * mass;
        }
      }
    } else if (this.gearState === 'REVERSE') {
      // REVERSE GEAR POWERTRAIN
      // Brake pedal acts as reverse throttle!
      if (this.isBraking) {
        const revMax = 22.0 / 3.6; // ~22 km/h
        this.forwardSpeed = Math.max(-revMax, this.forwardSpeed - 4.8 * delta * input.brake);
        if (renderer) renderer.emitExhaust(this.getExhaustPosition(), true);
      } else if (!isThrottle) {
        // Coasting reverse decelerates back to 0
        if (this.forwardSpeed < 0) {
          this.forwardSpeed = Math.min(0, this.forwardSpeed + 8.0 * delta);
        }
      }

      // Throttle (W) acts as brake in reverse and shifts back to DRIVE!
      if (isThrottle) {
        if (this.forwardSpeed < -0.2) {
          this.forwardSpeed = Math.min(0, this.forwardSpeed + 14.0 * delta * input.throttle);
        } else {
          this.gearState = 'DRIVE';
          this.forwardSpeed = 0.0;
          this.standstillTimer = 0.0;
          this.reverseArmed = false;
          if (this.audioEngine && this.audioEngine.playSwitchClick) {
            this.audioEngine.playSwitchClick(false);
          }
        }
      }
    }

    // Emergency Handbrake
    if (input.handbrake && speedAbs > 0.1) {
      F_brake += 22.0 * mass;
      this.audioEngine.playTireScreech();
    }

    // Anti-Wedge Unstuck Breakaway Assist
    if (speedAbs < 1.6) {
      if (isThrottle && this.gearState === 'DRIVE') F_drive += 4.5 * mass;
      else if (this.isBraking && this.gearState === 'REVERSE') this.forwardSpeed -= 2.0 * delta;
    }

    // Rolling Resistance
    const F_rolling = (this.currentRollCoeff || 0.015) * totalWeight * Math.sign(this.forwardSpeed || 1);

    // ==========================================
    // 3. LONGITUDINAL WEIGHT TRANSFER & WHEEL LOADS
    // ==========================================
    const F_net_long = F_drive - (this.forwardSpeed >= 0 ? F_brake : -F_brake) - F_rolling;
    const accel_x = F_net_long / mass;

    // Weight transfer delta: Delta Fz = m * ax * (h / L)
    const weightTransfer = THREE.MathUtils.clamp(mass * accel_x * (cgHeight / wheelbase), -totalWeight * 0.38, totalWeight * 0.38);
    this.weightTransferLong = weightTransfer;

    // Dynamic vertical load per axle:
    // Braking (accel_x < 0, weightTransfer < 0): Front axle loads up, rear axle lightens!
    // Accelerating (accel_x > 0, weightTransfer > 0): Rear axle squats, front axle lightens!
    const Fz_front = Math.max(totalWeight * 0.18, totalWeight * weightDistFront - weightTransfer);
    const Fz_rear = Math.max(totalWeight * 0.18, totalWeight * (1.0 - weightDistFront) + weightTransfer);

    // Friction capacity per axle (Kamm circle limits)
    const F_cap_front = mu * Fz_front;
    const F_cap_rear = mu * Fz_rear;

    // Longitudinal forces per axle based on Drivetrain layout
    let Fx_front = 0.0;
    let Fx_rear = 0.0;

    if (F_drive > 0) {
      // Model-specific powertrain physics overrides
      if (this.modelId === 'panda_4x4') {
        const isCrawler = this.priminaCrawlerActive || (speedKmh < 24.0 && (input.throttle > 0.45 || absDist > pavedHalfW));
        if (isCrawler) {
          F_drive *= 1.85; // Primina Crawler massive mechanical reduction ratio
        }
        if (this.is4WDEngaged) {
          Fx_front = F_drive * 0.50;
          Fx_rear = F_drive * 0.50;
        } else {
          Fx_front = F_drive * 1.0;
          Fx_rear = 0.0;
        }
      } else if (cfg.id === 'delta_integrale' || cfg.id === 'audi_quattro') {
        // Rally Turbo boost surge at medium-high RPM
        const turboSurge = (this.rpm > 0.40 && isThrottle) ? (1.0 + (this.boostBar || 0.5) * 0.42) : 1.0;
        F_drive *= turboSurge;
        Fx_front = F_drive * 0.47;
        Fx_rear = F_drive * 0.53;
      } else if (cfg.id === 'defender_110') {
        // High torque diesel 200Tdi in low gears
        const lowEndGrunt = (speedKmh < 35.0 && isThrottle) ? 1.45 : 1.0;
        F_drive *= lowEndGrunt;
        Fx_front = F_drive * 0.50;
        Fx_rear = F_drive * 0.50;
      } else if (cfg.drivetrain === 'RWD') {
        Fx_rear = F_drive;
        Fx_front = 0.0;
      } else if (cfg.drivetrain === 'FWD') {
        Fx_front = F_drive;
        Fx_rear = 0.0;
      } else if (cfg.drivetrain === 'AWD_TORSEN') {
        Fx_front = F_drive * 0.47;
        Fx_rear = F_drive * 0.53;
      } else if (cfg.drivetrain === 'AWD_VISCOUS') {
        Fx_front = F_drive * 0.37;
        Fx_rear = F_drive * 0.63;
      } else {
        Fx_front = F_drive * 0.50;
        Fx_rear = F_drive * 0.50;
      }
    } else if (F_brake > 0) {
      // Natural front-biased brake distribution (68% front, 32% rear)
      Fx_front = -F_brake * 0.68;
      Fx_rear = -F_brake * 0.32;
    }

    // ==========================================
    // 4. NON-LINEAR STEERING & TIRE SLIP ANGLES
    // ==========================================
    const rawSteerTarget = -input.steer;
    let slewRate = 4.2;
    if (Math.abs(rawSteerTarget) < 0.01) slewRate = 8.5;
    else if (Math.sign(rawSteerTarget) !== Math.sign(this.filteredSteer) && Math.abs(this.filteredSteer) > 0.08) slewRate = 6.8;
    this.filteredSteer = THREE.MathUtils.damp(this.filteredSteer, rawSteerTarget, slewRate, delta);

    const absFiltered = Math.abs(this.filteredSteer);
    let shapedSteer = 0.0;
    if (absFiltered > 0.015) {
      const nonLin = 0.20 * absFiltered + 0.80 * Math.pow(absFiltered, 2.4);
      shapedSteer = Math.sign(this.filteredSteer) * Math.min(1.0, nonLin);
    }
    const flatTireBias = (this.hasFlatTire && speedAbs > 1.2) ? 0.035 : 0.0;
    const steerCmd = Math.max(-1.0, Math.min(1.0, shapedSteer + flatTireBias));

    const speedKmh = speedAbs * 3.6;
    const speedFactor = 1.0 / (1.0 + Math.pow(speedKmh / 38.0, 1.35));
    const modelAgility = cfg.handling.agility || 1.0;
    const maxSteerAngleRad = THREE.MathUtils.lerp(0.12, 0.44, speedFactor) * modelAgility;
    // POSITIVE steerCmd (D / Right) produces POSITIVE steerAngle (turns right towards +X)
    this.steerAngle = steerCmd * maxSteerAngleRad;

    // Kinematic Ackermann geometry for low-speed maneuvering and parking (avoids / u singularities)
    const tanSteer = Math.tan(this.steerAngle);
    const r_kin = (this.forwardSpeed / Math.max(0.1, wheelbase)) * tanSteer;
    const v_kin = this.forwardSpeed * (distB / Math.max(0.1, wheelbase)) * tanSteer;

    // Dynamic slip angles of front and rear tires
    // alpha_f = delta - atan2(v + a*r, |u|)
    // alpha_r = -atan2(v - b*r, |u|)
    const regSpeed = Math.max(1.5, speedAbs);
    const alpha_f = this.steerAngle - Math.atan2(this.lateralSpeed + distA * this.yawRate, regSpeed);
    const alpha_r = -Math.atan2(this.lateralSpeed - distB * this.yawRate, regSpeed);
    this.slipAngle = Math.atan2(this.lateralSpeed, regSpeed);

    // ==========================================
    // 5. KAMM FRICTION CIRCLE & LATERAL TIRE FORCES
    // ==========================================
    Fx_front = THREE.MathUtils.clamp(Fx_front, -F_cap_front, F_cap_front);
    Fx_rear = THREE.MathUtils.clamp(Fx_rear, -F_cap_rear, F_cap_rear);

    // Remaining lateral grip in Kamm's friction circle:
    // Fy_max = sqrt(max(0.04 * F_cap^2, F_cap^2 - Fx^2))
    // PHYSICAL COUPLING:
    // - RWD on throttle: Fx_rear -> F_cap_rear => Fy_max_rear collapses => POWER OVERSTEER!
    // - Hard braking: Fx_front -> F_cap_front => Fy_max_front collapses => BRAKE LOCKUP UNDERSTEER!
    // - Trail-braking: Front loaded, rear lightened => rear rotates smoothly around front apex!
    const Fy_max_front = Math.sqrt(Math.max(0.04 * F_cap_front * F_cap_front, F_cap_front * F_cap_front - Fx_front * Fx_front));
    const Fy_max_rear = Math.sqrt(Math.max(0.04 * F_cap_rear * F_cap_rear, F_cap_rear * F_cap_rear - Fx_rear * Fx_rear));

    // Cornering stiffness (scaled with dynamic vertical axle loads)
    const C_alpha_front = 24.0 * Fz_front;
    const C_alpha_rear = 26.0 * Fz_rear;

    const Fy_f_raw = C_alpha_front * alpha_f;
    const Fy_r_raw = C_alpha_rear * alpha_r;

    const Fy_front = THREE.MathUtils.clamp(Fy_f_raw, -Fy_max_front, Fy_max_front);
    const Fy_rear = THREE.MathUtils.clamp(Fy_r_raw, -Fy_max_rear, Fy_max_rear);

    // ==========================================
    // 6. 2-DOF EQUATIONS OF MOTION (LATERAL, LONGITUDINAL & YAW)
    // ==========================================
    const cosDelta = Math.cos(this.steerAngle);
    const sinDelta = Math.sin(this.steerAngle);
    const Fy_total = Fy_front * cosDelta + Fy_rear + Fx_front * sinDelta;

    // Net yaw moment Mz = a * (Fy_front*cosDelta + Fx_front*sinDelta) - b * Fy_rear
    let Mz_total = distA * (Fy_front * cosDelta + Fx_front * sinDelta) - distB * Fy_rear;

    // Oversteer / Understeer tendency tuning per car model
    const oversteerBias = (cfg.handling.oversteerTendency || 0.0);
    Mz_total += oversteerBias * Math.sign(this.steerAngle || this.yawRate) * Math.abs(Fx_rear) * 0.18;

    // Accelerations in vehicle body frame:
    // dv/dt = (Fy_total / m) - u * r
    // dr/dt = Mz_total / Iz
    const dv_dt = (Fy_total / mass) - this.forwardSpeed * this.yawRate;
    const dr_dt = Mz_total / yawInertia;

    const v_dyn = THREE.MathUtils.clamp(this.lateralSpeed + dv_dt * delta, -12.0, 12.0);
    const r_dyn = this.yawRate + dr_dt * delta;

    // Smooth blending between low-speed Kinematic Ackermann and high-speed Dynamic 2-DOF
    const blendDyn = THREE.MathUtils.clamp((speedAbs - 0.4) / 1.8, 0.0, 1.0);
    this.yawRate = THREE.MathUtils.lerp(r_kin, r_dyn, blendDyn);
    this.lateralSpeed = THREE.MathUtils.lerp(v_kin, v_dyn, blendDyn);

    const maxRotSpeed = THREE.MathUtils.lerp(1.65, 0.72, Math.min(1.0, speedKmh / 120.0));
    this.yawRate = THREE.MathUtils.clamp(this.yawRate, -maxRotSpeed, maxRotSpeed);
    this.actualTurnRate = this.yawRate;

    // Natural caster self-centering torque: returns rack to straight-ahead when hands off
    if (Math.abs(rawSteerTarget) < 0.02) {
      this.yawRate *= Math.max(0.65, 1.0 - delta * 4.0);
      this.lateralSpeed *= Math.max(0.65, 1.0 - delta * 4.5);
    }

    // Longitudinal acceleration update (ALWAYS integrated across all speed regimes)
    const du_dt = (Fx_front * cosDelta + Fx_rear - Fy_front * sinDelta - F_rolling) / mass + this.lateralSpeed * this.yawRate;
    this.forwardSpeed += du_dt * delta;

    // Standstill static friction deadband: if stopped and no input, lock to 0
    if (speedAbs < 0.08 && !isThrottle && !this.isBraking && !input.handbrake) {
      this.forwardSpeed = 0.0;
      this.lateralSpeed = 0.0;
      this.yawRate = 0.0;
      this.actualTurnRate = 0.0;
      this.oversteerSlip = 0.0;
    }

    this.forwardSpeed = THREE.MathUtils.clamp(this.forwardSpeed, -maxSpeedMs * 0.22, maxSpeedMs);
    this.speedKmh = Math.round(this.forwardSpeed * 3.6);

    this.oversteerSlip = Math.abs(this.slipAngle);
    if (this.oversteerSlip > 0.18 && speedAbs > 6.0) {
      if (Math.random() < 0.25) this.audioEngine.playTireScreech();
    }

    // ==========================================
    // 7. TRUE PHYSICAL WORLD TRAJECTORY INTEGRATION
    // ==========================================
    // Update heading angle: psi += yawRate * delta
    this.rotation.y += this.yawRate * delta;

    // Transform vehicle local velocities (u, v) into global world velocities (Vx, Vz)
    // Vx = u * sin(psi) + v * cos(psi)
    // Vz = u * cos(psi) - v * sin(psi)
    const sinPsi = Math.sin(this.rotation.y);
    const cosPsi = Math.cos(this.rotation.y);

    const worldVx = this.forwardSpeed * sinPsi + this.lateralSpeed * cosPsi;
    const worldVz = this.forwardSpeed * cosPsi - this.lateralSpeed * sinPsi;

    this.position.x += worldVx * delta;
    this.position.z += worldVz * delta;

    // Natural terrain boundary banking at outer wilderness (> 30m from highway centerline)
    const maxWilderness = roadHalfW + 30.0;
    if (absDist > maxWilderness) {
      const excess = absDist - maxWilderness;
      const pushDir = Math.sign(roadInfo.x - this.position.x);
      this.position.x += pushDir * excess * delta * 5.0;
      this.yawRate += pushDir * 0.45 * delta;
    }

    this.position.y = roadInfo.y;

    // 7. Engine Audio Telemetry & Environmental Road Sound
    const rpmFraction = Math.min(1.0, 0.15 + (Math.abs(this.speedKmh) / cfg.topSpeedKmh) * 0.85);
    this.rpm = rpmFraction;
    this.engineRpmActual = Math.round(cfg.idleRpm + rpmFraction * (cfg.redlineRpm - cfg.idleRpm));

    this.audioEngine.setEngineRPM(this.rpm, isThrottle, this.boostBar, this.gear, speedAbs);
    this.audioEngine.setSpeedWind(Math.abs(this.forwardSpeed) / maxSpeedMs);

    // Surface acoustics & dynamic brake squeal
    const isNowOnShoulder = Math.abs(this.position.x - roadInfo.x) > pavedHalfW;
    this.audioEngine.setSurface(roadInfo.surface, speedAbs / maxSpeedMs, isNowOnShoulder);
    this.audioEngine.setBrakeSound(this.isBraking, speedAbs / maxSpeedMs);

    // Dynamic Tire Spray & Gravel Dust
    if (renderer && speedAbs > 2.0) {
      const wheels = this.getRearWheelPositions();
      renderer.emitTireSpray(wheels.left, wheels.right, roadInfo.surface, speedAbs / maxSpeedMs, isNowOnShoulder);
    }

    // 8. Visual transforms, roll & pitch
    this.updateMeshTransforms(delta);

    // 9. Brake lights intensity
    this.taillights.forEach((t) => {
      t.material.emissiveIntensity = this.isBraking ? 2.8 : 0.6;
    });

    // 10. Out of fuel check
    if (this.fuel <= 0 && this.isEngineOn) {
      this.isEngineOn = false;
      this.audioEngine.stopEngine();
    }

    // Record previous brake input for reverse double-tap detection
    this.wasBraking = this.isBraking;
  }

  updateMeshTransforms(delta) {
    this.group.position.copy(this.position);
    this.group.rotation.y = this.rotation.y;

    const speedAbs = Math.abs(this.forwardSpeed);

    if (speedAbs < 0.15) {
      // WHEN STATIONARY: Roll and pitch are STRICTLY ZERO!
      // The car CANNOT roll over, flip or tilt when standing still!
      this.currentRoll = THREE.MathUtils.lerp(this.currentRoll, 0.0, delta * 14.0);
      this.currentPitch = THREE.MathUtils.lerp(this.currentPitch, 0.0, delta * 14.0);
      this.group.rotation.z = 0.0;
      this.group.rotation.x = 0.0;
    } else {
      // 1. Suspension Roll: Strictly a function of actual centrifugal lateral acceleration + impact shock
      // Outward roll: turning right (+latAccel) lifts right side and compresses left side (+roll)
      const latAccel = this.forwardSpeed * this.yawRate; // a_lat in m/s^2
      const rollFactor = this.modelConfig.handling.bodyRollFactor || 0.25;
      // Maximum lean angle clamped realistically to +- 0.065 rad (~3.7 degrees)
      const maxRoll = 0.065;
      const targetRoll = Math.max(-maxRoll, Math.min(maxRoll, (latAccel / 9.81) * rollFactor * 0.32));
      this.currentRoll = THREE.MathUtils.lerp(this.currentRoll, targetRoll, delta * 10.0);
      this.group.rotation.z = this.currentRoll + this.impactShockRoll;

      // 2. Pitch: Function of longitudinal acceleration (dv/dt) + impact shock dive
      const currentAccel = (this.forwardSpeed - this.lastSpeed) / Math.max(0.001, delta);
      this.lastSpeed = this.forwardSpeed;
      const maxPitch = 0.04; // ~2.3 degrees max dive/squat
      const targetPitch = Math.max(-maxPitch, Math.min(maxPitch, -(currentAccel / 9.81) * 0.04));
      this.currentPitch = THREE.MathUtils.lerp(this.currentPitch, targetPitch, delta * 8.0);
      this.group.rotation.x = this.currentPitch + this.impactShockPitch;
    }

    // Damped decay of impact shocks
    if (Math.abs(this.impactShockPitch) > 0.001) {
      this.impactShockPitch = THREE.MathUtils.lerp(this.impactShockPitch, 0.0, delta * 10.0);
    } else {
      this.impactShockPitch = 0.0;
    }
    if (Math.abs(this.impactShockRoll) > 0.001) {
      this.impactShockRoll = THREE.MathUtils.lerp(this.impactShockRoll, 0.0, delta * 10.0);
    } else {
      this.impactShockRoll = 0.0;
    }

    // Front wheel visual steering angle (realistic wheel turn)
    this.frontWheels.forEach((w) => {
      w.rotation.y = this.steerAngle;
    });

    // Wheel spin (only when car is moving)
    if (speedAbs > 0.05) {
      const wheelR = this.modelDims ? this.modelDims.wheelRadius : 0.42;
      const spinDelta = (this.forwardSpeed / wheelR) * delta;
      this.wheels.forEach((w) => {
        if (w.children.length > 0) w.children[0].rotation.x += spinDelta;
        if (w.children.length > 1) w.children[1].rotation.x += spinDelta;
      });
    }

    // Antenna whip sway
    if (this.antenna) {
      if (speedAbs < 0.15) {
        this.antenna.rotation.z = Math.sin(Date.now() * 0.003) * 0.02;
        this.antenna.rotation.x = 0;
      } else {
        this.antenna.rotation.z = this.steerAngle * 0.2 + Math.sin(Date.now() * 0.01) * 0.03;
        this.antenna.rotation.x = -(speedAbs / 35.0) * 0.25;
      }
    }
  }

  /**
   * Applies visceral physical impulse to suspension and yaw on obstacle collision
   */
  applyImpactImpulse(normalX, normalZ, impactSpeedMs = 15.0) {
    const intensity = Math.min(1.0, impactSpeedMs / 25.0);
    // Dynamic front nose dive
    this.impactShockPitch = -0.065 * intensity;
    // Dynamic lateral chassis tilt away from obstacle
    this.impactShockRoll = -Math.sign(normalX) * 0.055 * intensity;
    // Dynamic yaw deflection kick
    this.actualTurnRate += Math.sign(normalX) * 0.22 * intensity;
  }

  takeDamage(amount) {
    let reducedAmount = amount;
    if (this.upgrades.heavy_bullbar || this.upgrades.bullbar) {
      reducedAmount *= 0.35;
    }
    if (this.upgrades.skid_plate || this.upgrades.armored_hull) {
      reducedAmount *= 0.50;
    }
    this.hull = Math.max(0, this.hull - reducedAmount);
    this.audioEngine.playImpact(Math.min(1.0, amount / 25.0));
  }
}
