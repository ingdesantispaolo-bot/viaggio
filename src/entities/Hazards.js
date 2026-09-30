/**
 * THE LONG MERIDIAN - Realistic Highway Scenarios & Road Travel Obstacle System
 * Replaces frantic arcade obstacle slaloms with authentic, realistic highway events
 * (Roadworks zones with cone tapers and flashing LED chevron trailers, disabled vehicles
 * with hazard 4-way blinkers and emergency triangles, alpine rockfall scree, fallen storm timber,
 * and asphalt subsidence potholes) spaced realistically every 400m-680m.
 * All scenarios strictly provide advance warning signage and guaranteed open lane clearance.
 */

import { CONFIG } from '../config.js';

export class Hazards {
  constructor(scene, roadGenerator, audioEngine, cameraController) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;
    this.audioEngine = audioEngine;
    this.cameraController = cameraController;

    this.hazardList = [];
    this.interactiveCones = [];
    this.blinkingLights = [];
    this.steamEmitters = [];

    // Realistic highway spacing: first event at 280m, subsequent events every 420m-680m
    this.nextHazardZ = 280;
    this.spawnInterval = 520; // Avg ~520m between highway events

    // Global blink animation clock for hazard lights and arrow signs
    this.blinkClock = 0.0;
    this.blinkState = false;

    this.initAssets();
  }

  initAssets() {
    // 1. Roadworks & Construction Materials
    this.matConeOrange = new THREE.MeshStandardMaterial({
      color: 0xff5500,
      roughness: 0.45,
      metalness: 0.1
    });
    this.matConeWhite = new THREE.MeshStandardMaterial({
      color: 0xf8fafc,
      roughness: 0.25,
      emissive: 0x94a3b8,
      emissiveIntensity: 0.35
    });
    this.matRubberBlack = new THREE.MeshStandardMaterial({
      color: 0x18191b,
      roughness: 0.95,
      metalness: 0.05
    });
    this.matSignPost = new THREE.MeshStandardMaterial({
      color: 0x64748b,
      metalness: 0.8,
      roughness: 0.4
    });
    this.matSignYellow = new THREE.MeshStandardMaterial({
      color: 0xfbbf24,
      roughness: 0.4,
      metalness: 0.1
    });
    this.matSignBlack = new THREE.MeshBasicMaterial({
      color: 0x0f172a
    });
    this.matLedAmberOn = new THREE.MeshBasicMaterial({
      color: 0xffaa00
    });
    this.matLedAmberOff = new THREE.MeshStandardMaterial({
      color: 0x3d2800,
      roughness: 0.8
    });
    this.matMillingAsphalt = new THREE.MeshStandardMaterial({
      color: 0x1f2227,
      roughness: 0.95,
      metalness: 0.08
    });
    this.matBarricadeRed = new THREE.MeshStandardMaterial({
      color: 0xdc2626,
      roughness: 0.5
    });
    this.matBarricadeWhite = new THREE.MeshStandardMaterial({
      color: 0xf8fafc,
      roughness: 0.3
    });

    // 2. Disabled Vehicle & Emergency Materials
    this.matEmergencyRed = new THREE.MeshStandardMaterial({
      color: 0xef4444,
      roughness: 0.3,
      emissive: 0xef4444,
      emissiveIntensity: 0.45
    });
    this.matCarBodyVintage = new THREE.MeshStandardMaterial({
      color: 0x3b5368,
      roughness: 0.55,
      metalness: 0.45
    });
    this.matCarGlass = new THREE.MeshStandardMaterial({
      color: 0x11161d,
      roughness: 0.1,
      metalness: 0.85,
      transparent: true,
      opacity: 0.85
    });
    this.matCarChrome = new THREE.MeshStandardMaterial({
      color: 0xdde3ea,
      roughness: 0.2,
      metalness: 0.9
    });
    this.matHazardAmber = new THREE.MeshBasicMaterial({
      color: 0xff9900
    });

    // 3. Environmental Scree, Timber & Pothole Materials
    this.matGraniteRock = new THREE.MeshStandardMaterial({
      color: 0x5a544d,
      roughness: 0.92,
      metalness: 0.08
    });
    this.matGravelScree = new THREE.MeshStandardMaterial({
      color: 0x484038,
      roughness: 0.96,
      metalness: 0.05
    });
    this.matWoodBark = new THREE.MeshStandardMaterial({
      color: 0x3d2719,
      roughness: 0.95,
      metalness: 0.05
    });
    this.matWoodFoliage = new THREE.MeshStandardMaterial({
      color: 0x274328,
      roughness: 0.88
    });
    this.matPotholeAsphalt = new THREE.MeshStandardMaterial({
      color: 0x15171a,
      roughness: 0.98
    });
    this.matPotholeWater = new THREE.MeshStandardMaterial({
      color: 0x11161d,
      roughness: 0.04,
      metalness: 0.95,
      transparent: true,
      opacity: 0.92
    });
  }

  update(playerZ, vehicle, playerFoot, delta, malfunctionManager = null, renderer = null, scenerySpawner = null, landscapeManager = null) {
    // 1. Spawning realistic road scenarios ahead
    const maxZ = playerZ + 260;
    while (this.nextHazardZ < maxZ) {
      this.spawnHighwayScenarioAt(this.nextHazardZ);
      this.nextHazardZ += this.spawnInterval + (Math.random() - 0.5) * 220;
    }

    // 2. Synchronous blinker clock update (1.5 Hz frequency for hazard lights and roadwork arrows)
    this.blinkClock += delta;
    if (this.blinkClock >= 0.38) {
      this.blinkClock = 0;
      this.blinkState = !this.blinkState;
      for (let i = 0; i < this.blinkingLights.length; i++) {
        const item = this.blinkingLights[i];
        if (item && item.mesh) {
          item.mesh.material = this.blinkState ? (item.onMat || this.matLedAmberOn) : (item.offMat || this.matLedAmberOff);
        }
      }
    }

    // 3. Gentle radiator steam puffing from disabled vehicles
    for (let i = 0; i < this.steamEmitters.length; i++) {
      const emitter = this.steamEmitters[i];
      emitter.timer = (emitter.timer || 0) + delta;
      if (emitter.timer > 0.45 && renderer) {
        emitter.timer = 0;
        const distToPlayer = Math.abs(vehicle.position.z - emitter.position.z);
        if (distToPlayer < 90) {
          renderer.emitImpactDebris(emitter.position, 'steam', 1);
        }
      }
    }

    // 4. Interactive Traffic Cones Dynamics (Knocked cones fly, spin, bounce and slide to a rest)
    for (let i = this.interactiveCones.length - 1; i >= 0; i--) {
      const cone = this.interactiveCones[i];
      if (cone.isKnocked) {
        cone.vel.y -= 13.0 * delta; // Gravity
        cone.mesh.position.x += cone.vel.x * delta;
        cone.mesh.position.y += cone.vel.y * delta;
        cone.mesh.position.z += cone.vel.z * delta;

        cone.mesh.rotation.x += cone.rotVel.x * delta;
        cone.mesh.rotation.y += cone.rotVel.y * delta;
        cone.mesh.rotation.z += cone.rotVel.z * delta;

        // Ground collision & friction bounce
        const groundY = cone.baseY;
        if (cone.mesh.position.y < groundY + 0.15) {
          cone.mesh.position.y = groundY + 0.15;
          cone.vel.y = -cone.vel.y * 0.32; // Rebound
          cone.vel.x *= 0.72; // Sliding friction
          cone.vel.z *= 0.72;
          cone.rotVel.multiplyScalar(0.7);

          if (Math.abs(cone.vel.y) < 0.25 && cone.vel.length() < 0.3) {
            cone.vel.set(0, 0, 0);
            cone.rotVel.set(0, 0, 0);
          }
        }
      }

      // Check collision between car and active cone
      if (!cone.isKnocked) {
        const dx = vehicle.position.x - cone.mesh.position.x;
        const dz = vehicle.position.z - cone.mesh.position.z;
        const dist = Math.hypot(dx, dz);
        const carHalfWidth = vehicle.modelDims ? (vehicle.modelDims.width * 0.48) : 0.85;

        if (dist < 0.45 + carHalfWidth) {
          this.knockTrafficCone(cone, vehicle, dx, dz, renderer);
        }
      }

      // Despawn
      if (cone.mesh.position.z < playerZ - 70) {
        this.scene.remove(cone.mesh);
        this.interactiveCones.splice(i, 1);
      }
    }

    // 5. Solid Highway Obstacle Collisions & Scavenging Resolution
    for (let i = this.hazardList.length - 1; i >= 0; i--) {
      const h = this.hazardList[i];

      if (h.hitCooldown > 0) {
        h.hitCooldown -= delta;
      }

      // Vehicle collision
      if (!h.destroyed) {
        const dx = vehicle.position.x - h.position.x;
        const dz = vehicle.position.z - h.position.z;
        const dist = Math.hypot(dx, dz);
        const carHalfWidth = vehicle.modelDims ? (vehicle.modelDims.width * 0.48) : 0.82;
        const contactRadius = h.radius + carHalfWidth;

        if (dist < contactRadius) {
          this.resolveVehicleCollision(h, vehicle, dist, contactRadius, dx, dz, malfunctionManager, renderer);
        }
      }

      // Roadside Disabled Vehicle Scavenge Detection (On foot or pulled over alongside)
      if (h.type === 'disabled_vehicle' && !h.scavenged) {
        const distToCar = vehicle.position.distanceTo(h.position);
        const distToFoot = playerFoot && playerFoot.active ? playerFoot.position.distanceTo(h.position) : 999;

        if (distToFoot < 3.2 || (distToCar < 4.5 && Math.abs(vehicle.forwardSpeed) < 1.0)) {
          h.canScavenge = true;
          // Auto-prompt scavenging or collect supplies
          if (!h.scavenged && (playerFoot?.active || Math.abs(vehicle.forwardSpeed) < 0.5)) {
            h.scavenged = true;
            this.scavengeDisabledCar(h, vehicle);
          }
        } else {
          h.canScavenge = false;
        }
      }

      // Despawn
      if (h.position.z < playerZ - 75) {
        this.scene.remove(h.mesh);
        this.hazardList.splice(i, 1);
      }
    }

    // 6. Roadside Environment & Off-Road Props Collision Resolution
    const nearbyObstacles = [];
    if (scenerySpawner && typeof scenerySpawner.getNearbyColliders === 'function') {
      nearbyObstacles.push(...scenerySpawner.getNearbyColliders(playerZ, 28.0));
    }
    if (landscapeManager && typeof landscapeManager.getNearbyColliders === 'function') {
      nearbyObstacles.push(...landscapeManager.getNearbyColliders(playerZ, 32.0));
    }

    const carRadius = vehicle.modelDims ? Math.max(vehicle.modelDims.width * 0.48, 0.95) : 1.0;
    for (let i = 0; i < nearbyObstacles.length; i++) {
      const obs = nearbyObstacles[i];
      const col = obs.collider;
      if (!col || !col.solid) continue;

      const dx = vehicle.position.x - obs.position.x;
      const dz = vehicle.position.z - obs.position.z;
      const dist = Math.hypot(dx, dz);
      const contactRadius = (col.radius || 1.2) + carRadius;

      if (dist < contactRadius) {
        this.resolveSolidObstacleCollision(obs, vehicle, dist, contactRadius, dx, dz, delta, malfunctionManager, renderer);
      }
    }
  }

  /**
   * Spawns an authentic, coherent highway scenario (Roadworks zone, Disabled car with 4-way hazards,
   * Alpine scree, Fallen storm timber, or Asphalt subsidence)
   */
  spawnHighwayScenarioAt(z) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(z);
    const halfW = roadInfo.width * 0.5;

    // Pick lane to close / occupy: -1 for left lane, +1 for right lane
    // Guarantees the opposite lane is 100% open with > 7.0m of clear clearance!
    const side = Math.random() < 0.5 ? -1 : 1;

    const currentBiome = this.roadGenerator.biomeManager ? this.roadGenerator.biomeManager.currentBiome : null;
    const biomeId = currentBiome ? currentBiome.id : 'temperate_forest';

    const roll = Math.random();

    if (biomeId === 'alpine_peaks') {
      if (roll < 0.55) this.spawnAlpineScreeScenario(z, side, roadInfo);
      else if (roll < 0.85) this.spawnRoadworksScenario(z, side, roadInfo);
      else this.spawnDisabledVehicleScenario(z, side, roadInfo);
    } else if (biomeId === 'boreal_taiga' || biomeId === 'tropical_rainforest') {
      if (roll < 0.38) this.spawnStormTimberScenario(z, side, roadInfo);
      else if (roll < 0.72) this.spawnRoadworksScenario(z, side, roadInfo);
      else this.spawnDisabledVehicleScenario(z, side, roadInfo);
    } else {
      // Standard highway distribution
      if (roll < 0.42) this.spawnRoadworksScenario(z, side, roadInfo);
      else if (roll < 0.76) this.spawnDisabledVehicleScenario(z, side, roadInfo);
      else if (roll < 0.88) this.spawnPotholeClusterScenario(z, side, roadInfo);
      else this.spawnAlpineScreeScenario(z, side, roadInfo);
    }
  }

  // =========================================================================
  // SCENARIO 1: CANTIERE STRADALE / ROADWORKS ZONE
  // Advance warning sign 110m ahead, 7-cone taper, LED flashing chevron arrow trailer,
  // dark asphalt milling patch, safety barricades, and parked shoulder roller.
  // =========================================================================
  spawnRoadworksScenario(z, side, roadInfo) {
    const halfW = roadInfo.width * 0.5;
    const closedLaneX = roadInfo.x + side * (halfW * 0.48);
    const shoulderX = roadInfo.x + side * (halfW * 0.88);
    const y = roadInfo.y;

    // 1. Advance Roadside Warning Sign at Z - 110m (110m prior warning on shoulder)
    this.spawnWarningSign(
      z - 110,
      shoulderX,
      y,
      'roadworks',
      'LAVORI IN CORSO / ROADWORKS 100m'
    );

    // 2. Tapered Line of 7 Reflective Safety Cones (guiding traffic diagonally into open lane)
    const coneCount = 7;
    for (let k = 0; k < coneCount; k++) {
      const t = k / (coneCount - 1);
      const coneZ = z - 38 + t * 28; // Taper from Z-38m to Z-10m
      const coneX = roadInfo.x + side * (halfW * 0.78 - t * (halfW * 0.56));
      this.spawnInteractiveCone(coneX, y, coneZ);
    }

    // 3. Mobile Flashing Chevron Arrow Trailer Board at Z - 9m
    const trailerGroup = new THREE.Group();
    // Trailer frame & wheels
    const frameGeo = new THREE.BoxGeometry(1.4, 0.22, 1.8);
    const frame = new THREE.Mesh(frameGeo, this.matSignYellow);
    frame.position.y = 0.45;
    frame.castShadow = true;
    trailerGroup.add(frame);

    // 2 Trailer wheels
    const wheelGeo = new THREE.CylinderGeometry(0.32, 0.32, 0.22, 10);
    wheelGeo.rotateZ(Math.PI / 2);
    const w1 = new THREE.Mesh(wheelGeo, this.matRubberBlack);
    w1.position.set(-0.75, 0.32, 0.1);
    trailerGroup.add(w1);
    const w2 = new THREE.Mesh(wheelGeo, this.matRubberBlack);
    w2.position.set(0.75, 0.32, 0.1);
    trailerGroup.add(w2);

    // Large high-contrast matte black sign board
    const boardGeo = new THREE.BoxGeometry(1.6, 1.25, 0.12);
    const board = new THREE.Mesh(boardGeo, this.matSignBlack);
    board.position.set(0, 1.45, 0);
    board.castShadow = true;
    trailerGroup.add(board);

    // Yellow hazard border
    const borderGeo = new THREE.BoxGeometry(1.68, 1.33, 0.08);
    const border = new THREE.Mesh(borderGeo, this.matSignYellow);
    border.position.set(0, 1.45, -0.03);
    trailerGroup.add(border);

    // Animated Flashing LED Chevron Arrow (Points toward OPEN lane)
    // If closed lane is LEFT (side = -1), chevron points RIGHT (>). If closed lane is RIGHT (side = +1), points LEFT (<).
    const arrowDir = -side;
    const ledPoints = [
      { x: -0.35 * arrowDir, y: 1.15 },
      { x: -0.05 * arrowDir, y: 1.30 },
      { x: 0.30 * arrowDir, y: 1.45 }, // Apex
      { x: -0.05 * arrowDir, y: 1.60 },
      { x: -0.35 * arrowDir, y: 1.75 }
    ];

    const ledGeo = new THREE.CylinderGeometry(0.065, 0.065, 0.04, 8);
    ledGeo.rotateX(Math.PI / 2);

    ledPoints.forEach((lp) => {
      const led = new THREE.Mesh(ledGeo, this.matLedAmberOn);
      led.position.set(lp.x, lp.y, -0.08);
      trailerGroup.add(led);
      this.blinkingLights.push({
        mesh: led,
        onMat: this.matLedAmberOn,
        offMat: this.matLedAmberOff
      });
    });

    trailerGroup.position.set(closedLaneX, y, z - 9);
    trailerGroup.rotation.y = (roadInfo.roadAngle || 0);
    this.scene.add(trailerGroup);

    this.hazardList.push({
      type: 'roadworks_trailer',
      position: new THREE.Vector3(closedLaneX, y, z - 9),
      mesh: trailerGroup,
      radius: 1.35,
      destroyed: false,
      hitCooldown: 0.0
    });

    // 4. Milled Asphalt Repair Scar Patch on the closed lane (28m long)
    const patchGeo = new THREE.BoxGeometry(halfW * 0.65, 0.035, 28.0);
    const patch = new THREE.Mesh(patchGeo, this.matMillingAsphalt);
    patch.position.set(closedLaneX, y + 0.02, z + 8);
    patch.rotation.y = (roadInfo.roadAngle || 0);
    patch.receiveShadow = true;
    this.scene.add(patch);
    this.hazardList.push({
      type: 'asphalt_patch',
      position: new THREE.Vector3(closedLaneX, y, z + 8),
      mesh: patch,
      radius: 0.1, // Visual decal, non-colliding
      destroyed: true,
      hitCooldown: 999
    });

    // 5. Safety Striped Barricades (Cavalletti Stradali) at Z + 4m and Z + 18m
    [z + 4, z + 18].forEach((bz) => {
      const barGroup = new THREE.Group();
      const bPlank = new THREE.Mesh(new THREE.BoxGeometry(1.8, 0.35, 0.06), this.matBarricadeWhite);
      bPlank.position.y = 0.72;
      bPlank.castShadow = true;
      barGroup.add(bPlank);

      // Red reflective chevron stripes
      for (let s = -0.6; s <= 0.6; s += 0.4) {
        const stripe = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.36, 0.07), this.matBarricadeRed);
        stripe.position.set(s, 0.72, 0);
        stripe.rotation.z = 0.45;
        barGroup.add(stripe);
      }

      // 2 A-frame legs
      const legGeo = new THREE.CylinderGeometry(0.04, 0.04, 0.9, 5);
      const l1 = new THREE.Mesh(legGeo, this.matSignPost);
      l1.position.set(-0.75, 0.45, 0);
      barGroup.add(l1);
      const l2 = new THREE.Mesh(legGeo, this.matSignPost);
      l2.position.set(0.75, 0.45, 0);
      barGroup.add(l2);

      barGroup.position.set(closedLaneX + (Math.random() - 0.5) * 0.6, y, bz);
      barGroup.rotation.y = (roadInfo.roadAngle || 0);
      this.scene.add(barGroup);

      this.hazardList.push({
        type: 'safety_barricade',
        position: barGroup.position.clone(),
        mesh: barGroup,
        radius: 1.1,
        destroyed: false,
        hitCooldown: 0.0
      });
    });
  }

  // =========================================================================
  // SCENARIO 2: AUTO FERMA IN AVARIA / DISABLED VEHICLE
  // Vintage estate car pulled over on the shoulder with open hood, rising steam,
  // 4-way hazard blinkers flashing at 1.5 Hz, red reflective triangle 38m behind,
  // and scavengeable supplies (fuel, parts).
  // =========================================================================
  spawnDisabledVehicleScenario(z, side, roadInfo) {
    const halfW = roadInfo.width * 0.5;
    const shoulderX = roadInfo.x + side * (halfW * 0.76);
    const y = roadInfo.y;

    // 1. Red Reflective Emergency Triangle (Triangolo di Pericolo) placed 38m behind on the shoulder
    const triGroup = new THREE.Group();
    const triGeo = new THREE.RingGeometry(0.24, 0.38, 3);
    triGeo.rotateZ(Math.PI / 2);
    const triMesh = new THREE.Mesh(triGeo, this.matEmergencyRed);
    triMesh.position.y = 0.45;
    triMesh.castShadow = true;
    triGroup.add(triMesh);

    // Folding black tripod stand
    const standGeo = new THREE.CylinderGeometry(0.02, 0.02, 0.45, 4);
    const stand = new THREE.Mesh(standGeo, this.matRubberBlack);
    stand.position.y = 0.22;
    triGroup.add(stand);

    triGroup.position.set(roadInfo.x + side * (halfW * 0.82), y, z - 38);
    triGroup.rotation.y = (roadInfo.roadAngle || 0) + (side < 0 ? 0.08 : -0.08);
    this.scene.add(triGroup);

    this.hazardList.push({
      type: 'emergency_triangle',
      position: triGroup.position.clone(),
      mesh: triGroup,
      radius: 0.65,
      destroyed: false,
      hitCooldown: 0.0
    });

    // 2. The Broken Down Vintage Vehicle
    const carGroup = new THREE.Group();

    // Chassis & Body
    const bodyLength = 4.4;
    const bodyWidth = 1.75;
    const bodyHeight = 0.95;

    const lowerChassis = new THREE.Mesh(new THREE.BoxGeometry(bodyWidth * 0.95, 0.35, bodyLength), this.matRubberBlack);
    lowerChassis.position.y = 0.35;
    lowerChassis.castShadow = true;
    carGroup.add(lowerChassis);

    const mainBody = new THREE.Mesh(new THREE.BoxGeometry(bodyWidth, bodyHeight, bodyLength * 0.96), this.matCarBodyVintage);
    mainBody.position.y = 0.75;
    mainBody.castShadow = true;
    carGroup.add(mainBody);

    // Cabin Greenhouse & Roof
    const cabinGeo = new THREE.BoxGeometry(bodyWidth * 0.88, 0.75, bodyLength * 0.55);
    const cabin = new THREE.Mesh(cabinGeo, this.matCarGlass);
    cabin.position.set(0, 1.45, 0.15);
    carGroup.add(cabin);

    const roofGeo = new THREE.BoxGeometry(bodyWidth * 0.9, 0.08, bodyLength * 0.58);
    const roof = new THREE.Mesh(roofGeo, this.matCarBodyVintage);
    roof.position.set(0, 1.84, 0.15);
    carGroup.add(roof);

    // Raised Open Engine Hood (Bonnet tilted up at 40 degrees)
    const hoodGeo = new THREE.BoxGeometry(bodyWidth * 0.84, 0.06, 1.25);
    const hood = new THREE.Mesh(hoodGeo, this.matCarBodyVintage);
    hood.position.set(0, 1.42, -1.35);
    hood.rotation.x = -0.65; // Tilted open revealing engine bay!
    carGroup.add(hood);

    // Exposed Engine Block inside Engine Bay
    const engineBlock = new THREE.Mesh(new THREE.BoxGeometry(0.75, 0.5, 0.8), this.matSignPost);
    engineBlock.position.set(0, 0.9, -1.5);
    carGroup.add(engineBlock);

    // 4 Wheels
    const wGeo = new THREE.CylinderGeometry(0.34, 0.34, 0.24, 10);
    wGeo.rotateZ(Math.PI / 2);
    [
      { x: -0.85, z: -1.4 }, { x: 0.85, z: -1.4 },
      { x: -0.85, z: 1.4 },  { x: 0.85, z: 1.4 }
    ].forEach((wp) => {
      const wheel = new THREE.Mesh(wGeo, this.matRubberBlack);
      wheel.position.set(wp.x, 0.34, wp.z);
      wheel.castShadow = true;
      carGroup.add(wheel);
    });

    // 4-Way Hazard Blinkers (Front Left, Front Right, Rear Left, Rear Right)
    const blinkerGeo = new THREE.BoxGeometry(0.16, 0.08, 0.06);
    const blinkerPositions = [
      { x: -0.82, y: 0.85, z: -2.18 }, // Front left
      { x: 0.82,  y: 0.85, z: -2.18 }, // Front right
      { x: -0.82, y: 0.95, z: 2.18 },  // Rear left
      { x: 0.82,  y: 0.95, z: 2.18 }   // Rear right
    ];

    blinkerPositions.forEach((bp) => {
      const blinker = new THREE.Mesh(blinkerGeo, this.matHazardAmber);
      blinker.position.set(bp.x, bp.y, bp.z);
      carGroup.add(blinker);
      this.blinkingLights.push({
        mesh: blinker,
        onMat: this.matHazardAmber,
        offMat: this.matLedAmberOff
      });
    });

    // Align vehicle on the shoulder with authentic angled parking (~6 deg)
    carGroup.position.set(shoulderX, y, z);
    carGroup.rotation.y = (roadInfo.roadAngle || 0) + (side < 0 ? 0.1 : -0.1);
    this.scene.add(carGroup);

    // Register steam emitter at engine bay
    this.steamEmitters.push({
      position: new THREE.Vector3(shoulderX, y + 1.1, z - 1.5),
      timer: 0.0
    });

    this.hazardList.push({
      type: 'disabled_vehicle',
      position: new THREE.Vector3(shoulderX, y, z),
      mesh: carGroup,
      radius: 1.85,
      destroyed: false,
      scavenged: false,
      canScavenge: false,
      hitCooldown: 0.0
    });
  }

  // =========================================================================
  // SCENARIO 3: FRANA MONTANA & GHIAIA / ALPINE SCREE
  // Advance sign "CADUTA MASSI", textured gravel/scree strip with tire rumble,
  // 1 large shoulder boulder, 1 small lane rock (clear lane fully unobstructed).
  // =========================================================================
  spawnAlpineScreeScenario(z, side, roadInfo) {
    const halfW = roadInfo.width * 0.5;
    const shoulderX = roadInfo.x + side * (halfW * 0.88);
    const laneX = roadInfo.x + side * (halfW * 0.44);
    const y = roadInfo.y;

    // 1. Advance Sign 90m ahead on shoulder: "CADUTA MASSI / ROCKFALL"
    this.spawnWarningSign(
      z - 90,
      shoulderX,
      y,
      'rockfall',
      'CADUTA MASSI / ROCKFALL'
    );

    // 2. Textured Scree & Loose Gravel Ribbon across shoulder and closed lane edge
    const screeGeo = new THREE.BoxGeometry(halfW * 0.6, 0.04, 22.0);
    const scree = new THREE.Mesh(screeGeo, this.matGravelScree);
    scree.position.set(laneX, y + 0.02, z);
    scree.rotation.y = (roadInfo.roadAngle || 0);
    scree.receiveShadow = true;
    this.scene.add(scree);

    this.hazardList.push({
      type: 'scree_patch',
      position: new THREE.Vector3(laneX, y, z),
      mesh: scree,
      radius: 0.2, // Decal surface, audio rumble trigger
      destroyed: true,
      hitCooldown: 999
    });

    // 3. One distinct granite boulder safely resting on the shoulder
    const bigRockGeo = new THREE.DodecahedronGeometry(1.3, 1);
    const bigRock = new THREE.Mesh(bigRockGeo, this.matGraniteRock);
    bigRock.position.set(shoulderX, y + 0.9, z + 2);
    bigRock.rotation.set(Math.random() * 3, Math.random() * 3, Math.random() * 3);
    bigRock.castShadow = true;
    this.scene.add(bigRock);

    this.hazardList.push({
      type: 'rockfall_debris',
      position: bigRock.position.clone(),
      mesh: bigRock,
      radius: 1.35,
      destroyed: false,
      hitCooldown: 0.0
    });

    // 4. One smaller rock on the outer lane edge (easily steerable around)
    const smallRockGeo = new THREE.DodecahedronGeometry(0.55, 0);
    const smallRock = new THREE.Mesh(smallRockGeo, this.matGraniteRock);
    smallRock.position.set(laneX + (Math.random() - 0.5) * 0.8, y + 0.4, z - 4);
    smallRock.rotation.set(Math.random() * 3, Math.random() * 3, Math.random() * 3);
    smallRock.castShadow = true;
    this.scene.add(smallRock);

    this.hazardList.push({
      type: 'rockfall_debris',
      position: smallRock.position.clone(),
      mesh: smallRock,
      radius: 0.75,
      destroyed: false,
      hitCooldown: 0.0
    });
  }

  // =========================================================================
  // SCENARIO 4: RAMO CADUTO DOPO TEMPORALE / STORM FALLEN TIMBER
  // Fallen pine/oak branch blown across shoulder and edge of outer lane.
  // =========================================================================
  spawnStormTimberScenario(z, side, roadInfo) {
    const halfW = roadInfo.width * 0.5;
    const laneX = roadInfo.x + side * (halfW * 0.52);
    const y = roadInfo.y;

    const mesh = new THREE.Group();
    const trunkLen = 4.6;
    const trunkR = 0.24;

    const trunkGeo = new THREE.CylinderGeometry(trunkR * 0.75, trunkR, trunkLen, 7);
    const trunkMesh = new THREE.Mesh(trunkGeo, this.matWoodBark);
    trunkMesh.rotation.z = Math.PI / 2;
    trunkMesh.castShadow = true;
    mesh.add(trunkMesh);

    // 2 Branch nubs with pine needle foliage clumps
    const b1 = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.12, 1.1, 5), this.matWoodBark);
    b1.position.set(-1.1, 0.4, 0.2);
    b1.rotation.x = 0.65;
    mesh.add(b1);

    const f1 = new THREE.Mesh(new THREE.DodecahedronGeometry(0.45, 0), this.matWoodFoliage);
    f1.position.set(-1.3, 0.75, 0.45);
    mesh.add(f1);

    const b2 = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.12, 1.0, 5), this.matWoodBark);
    b2.position.set(1.2, 0.35, -0.2);
    b2.rotation.x = -0.55;
    mesh.add(b2);

    mesh.rotation.y = (roadInfo.roadAngle || 0) + (side < 0 ? 0.35 : -0.35);
    mesh.position.set(laneX, y + trunkR, z);
    this.scene.add(mesh);

    this.hazardList.push({
      type: 'fallen_timber',
      position: new THREE.Vector3(laneX, y + trunkR, z),
      mesh: mesh,
      radius: 1.8,
      destroyed: false,
      hitCooldown: 0.0
    });
  }

  // =========================================================================
  // SCENARIO 5: BUCHE E CEDIMENTO ASFALTO / POTHOLE CLUSTER
  // 2 organic sunken tarmac depressions with dark water puddles and suspension feedback.
  // =========================================================================
  spawnPotholeClusterScenario(z, side, roadInfo) {
    const halfW = roadInfo.width * 0.5;
    const laneX = roadInfo.x + side * (halfW * 0.42);
    const y = roadInfo.y;

    const group = new THREE.Group();

    // 2 potholes
    [
      { ox: 0, oz: 0, r: 1.35 },
      { ox: (Math.random() - 0.5) * 1.4, oz: 4.5, r: 1.05 }
    ].forEach((p) => {
      const rim = new THREE.Mesh(new THREE.CylinderGeometry(p.r, p.r + 0.25, 0.06, 10), this.matPotholeAsphalt);
      rim.position.set(p.ox, 0, p.oz);
      rim.receiveShadow = true;
      group.add(rim);

      const water = new THREE.Mesh(new THREE.CylinderGeometry(p.r * 0.85, p.r * 0.85, 0.07, 10), this.matPotholeWater);
      water.position.set(p.ox, 0.02, p.oz);
      water.receiveShadow = true;
      group.add(water);
    });

    group.position.set(laneX, y + 0.03, z);
    group.rotation.y = (roadInfo.roadAngle || 0);
    this.scene.add(group);

    this.hazardList.push({
      type: 'frost_heave',
      position: new THREE.Vector3(laneX, y, z),
      mesh: group,
      radius: 1.45,
      destroyed: false,
      hitCooldown: 0.0
    });
  }

  // =========================================================================
  // HELPER: Spawn Warning Sign on Shoulder (Preavviso di Sicurezza)
  // =========================================================================
  spawnWarningSign(z, x, y, symbolType, label) {
    const group = new THREE.Group();

    // Galvanized steel pole
    const poleGeo = new THREE.CylinderGeometry(0.045, 0.045, 2.2, 6);
    const pole = new THREE.Mesh(poleGeo, this.matSignPost);
    pole.position.y = 1.1;
    pole.castShadow = true;
    group.add(pole);

    // Diamond retroreflective sign plate
    const plateGeo = new THREE.BoxGeometry(0.85, 0.85, 0.04);
    const plate = new THREE.Mesh(plateGeo, this.matSignYellow);
    plate.position.set(0, 1.85, 0);
    plate.rotation.z = Math.PI / 4; // Diamond orientation
    plate.castShadow = true;
    group.add(plate);

    // Dark border
    const border = new THREE.Mesh(new THREE.BoxGeometry(0.76, 0.76, 0.05), this.matSignBlack);
    border.position.set(0, 1.85, 0.005);
    border.rotation.z = Math.PI / 4;
    group.add(border);

    // Inner yellow symbol field
    const inner = new THREE.Mesh(new THREE.BoxGeometry(0.68, 0.68, 0.06), this.matSignYellow);
    inner.position.set(0, 1.85, 0.01);
    inner.rotation.z = Math.PI / 4;
    group.add(inner);

    // Sign symbol pictogram
    const symGeo = new THREE.BoxGeometry(0.35, 0.35, 0.07);
    const sym = new THREE.Mesh(symGeo, this.matSignBlack);
    sym.position.set(0, 1.85, 0.015);
    group.add(sym);

    group.position.set(x, y, z);
    this.scene.add(group);

    this.hazardList.push({
      type: 'warning_sign',
      position: group.position.clone(),
      mesh: group,
      radius: 0.5,
      destroyed: true, // Non-colliding roadside warning sign
      hitCooldown: 999
    });
  }

  // =========================================================================
  // HELPER: Spawn Interactive Traffic Cone (Knockable physics)
  // =========================================================================
  spawnInteractiveCone(x, y, z) {
    const group = new THREE.Group();

    // Heavy black square rubber base
    const baseGeo = new THREE.BoxGeometry(0.42, 0.06, 0.42);
    const base = new THREE.Mesh(baseGeo, this.matRubberBlack);
    base.position.y = 0.03;
    base.castShadow = true;
    group.add(base);

    // Safety orange cone body
    const coneBody = new THREE.Mesh(new THREE.ConeGeometry(0.18, 0.72, 8), this.matConeOrange);
    coneBody.position.y = 0.39;
    coneBody.castShadow = true;
    group.add(coneBody);

    // 2 Retroreflective white stripes
    const s1 = new THREE.Mesh(new THREE.CylinderGeometry(0.11, 0.13, 0.12, 8), this.matConeWhite);
    s1.position.y = 0.32;
    group.add(s1);

    const s2 = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.095, 0.10, 8), this.matConeWhite);
    s2.position.y = 0.52;
    group.add(s2);

    group.position.set(x, y, z);
    this.scene.add(group);

    this.interactiveCones.push({
      mesh: group,
      baseY: y,
      isKnocked: false,
      vel: new THREE.Vector3(),
      rotVel: new THREE.Vector3()
    });
  }

  // =========================================================================
  // INTERACTION: Knock traffic cone with plastic clatter & physical skitter
  // =========================================================================
  knockTrafficCone(cone, vehicle, dx, dz, renderer) {
    cone.isKnocked = true;
    const speedMs = Math.abs(vehicle.forwardSpeed);
    const speedRatio = Math.min(1.0, speedMs / 25.0);

    const nx = (dx > 0 ? 1 : -1);
    cone.vel.set(
      nx * (3.5 + Math.random() * 4.0),
      2.8 + Math.random() * 2.5 * speedRatio,
      vehicle.forwardSpeed * 0.45 + (Math.random() - 0.5) * 2.0
    );

    cone.rotVel.set(
      (Math.random() - 0.5) * 16.0,
      (Math.random() - 0.5) * 16.0,
      (Math.random() - 0.5) * 16.0
    );

    // Tactile Audio & Particles
    if (this.audioEngine) {
      if (typeof this.audioEngine.playConeKnock === 'function') {
        this.audioEngine.playConeKnock(0.6 + speedRatio * 0.4);
      } else {
        this.audioEngine.playImpact(0.2);
      }
    }

    if (this.cameraController) {
      this.cameraController.addTrauma(0.08);
    }

    if (renderer) {
      renderer.emitImpactDebris(cone.mesh.position, 'barrel', 6);
    }

    // Minimal speed damping & negligible damage (real cars don't explode hitting plastic cones!)
    vehicle.forwardSpeed *= 0.985;
    vehicle.takeDamage(1);
  }

  // =========================================================================
  // INTERACTION: Scavenge Disabled Roadside Vehicle
  // =========================================================================
  scavengeDisabledCar(h, vehicle) {
    if (this.audioEngine) {
      this.audioEngine.playLootPickup();
    }

    // Award 12L fuel and scrap metal
    if (vehicle) {
      const addedFuel = Math.min(14, vehicle.maxFuel - vehicle.fuel);
      vehicle.fuel += addedFuel;
    }

    // Spawn green confirmation feedback particles
    if (h.mesh) {
      const toast = document.createElement('div');
      toast.style.cssText = `
        position: fixed;
        top: 25%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: rgba(15, 23, 42, 0.94);
        border: 1px solid #22c55e;
        color: #f8fafc;
        padding: 12px 24px;
        border-radius: 8px;
        font-family: 'Share Tech Mono', monospace;
        font-size: 15px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.8), 0 0 20px rgba(34, 197, 94, 0.3);
        z-index: 100;
        pointer-events: none;
        transition: opacity 1.2s ease, transform 1.2s ease;
      `;
      toast.innerHTML = `<span style="color:#22c55e; font-weight:bold;">🔧 VEICOLO ISPEZIONATO:</span> Recuperati +12L Carburante & Rottami di ricambio!`;
      document.body.appendChild(toast);

      setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translate(-50%, -80%)';
        setTimeout(() => toast.remove(), 1200);
      }, 2500);
    }
  }

  // =========================================================================
  // COLLISION: Resolve Vehicle Collision with Highway Lane Hazards
  // =========================================================================
  resolveVehicleCollision(hazard, vehicle, dist, contactRadius, dx, dz, malfunctionManager = null, renderer = null) {
    if (hazard.hitCooldown > 0) {
      const overlap = contactRadius - dist;
      if (overlap > 0) {
        const nx = dist > 0.01 ? (dx / dist) : (dx >= 0 ? 1 : -1);
        vehicle.position.x += nx * overlap * 0.35;
      }
      return;
    }

    hazard.hitCooldown = 0.85;

    const speedMs = Math.abs(vehicle.forwardSpeed);
    const speedKmh = speedMs * 3.6;
    const speedRatio = Math.min(1.0, speedKmh / 90.0);

    const nx = dist > 0.01 ? (dx / dist) : (dx >= 0 ? 1 : -1);
    const nz = dist > 0.01 ? (dz / dist) : 1;
    const overlap = Math.max(0, contactRadius - dist);

    const contactPoint = new THREE.Vector3(
      (vehicle.position.x + hazard.position.x) * 0.5,
      vehicle.position.y + 0.35,
      (vehicle.position.z + hazard.position.z) * 0.5
    );

    // Immediate Dispenetration
    vehicle.position.x += nx * (overlap + 0.14);
    vehicle.position.z += nz * (overlap + 0.14);

    if (vehicle.applyImpactImpulse) {
      vehicle.applyImpactImpulse(nx, nz, speedMs);
    }

    // Case 1: Pothole / Subsidence Puddle
    if (hazard.type === 'frost_heave') {
      if (speedKmh > 25) {
        this.cameraController.addTrauma(0.32 * speedRatio);
        this.audioEngine.playSuspensionThump(0.45 + speedRatio * 0.45);
        if (typeof this.audioEngine.playWaterSplash === 'function') {
          this.audioEngine.playWaterSplash(0.5 + speedRatio * 0.5);
        }
        vehicle.forwardSpeed *= 0.92;
        if (renderer) renderer.emitImpactDebris(contactPoint, 'steam', 6);
        if (malfunctionManager && speedKmh > 75 && !vehicle.upgrades.rally_suspension && Math.random() < 0.2) {
          malfunctionManager.triggerFault('flat_tire');
        }
      }
      return;
    }

    // Case 2: Safety Barricade / Cavalletto
    if (hazard.type === 'safety_barricade') {
      this.audioEngine.playImpact(0.45);
      this.cameraController.addTrauma(0.25);
      vehicle.forwardSpeed *= 0.91;
      vehicle.takeDamage(Math.round(2 + speedRatio * 5));
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) {
        renderer.emitImpactDebris(contactPoint, 'wood', 18);
        renderer.emitImpactSparks(contactPoint, 8);
      }
      return;
    }

    // Case 3: Emergency Triangle
    if (hazard.type === 'emergency_triangle') {
      this.audioEngine.playImpact(0.2);
      this.cameraController.addTrauma(0.1);
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) renderer.emitImpactDebris(contactPoint, 'barrel', 8);
      return;
    }

    // Case 4: Heavy Rigid Obstacles (Roadworks Trailer, Granite Boulders, Disabled Car, Fallen Timber)
    const isRock = hazard.type === 'rockfall_debris';
    const baseDmg = isRock ? 14 : 10;
    const damage = Math.round(baseDmg + speedRatio * (isRock ? 22 : 16));
    vehicle.takeDamage(damage);

    this.cameraController.addTrauma(Math.min(1.0, 0.4 + speedRatio * 0.6));
    this.audioEngine.playImpact(Math.min(1.0, 0.6 + speedRatio * 0.35));
    this.audioEngine.playSuspensionThump(0.5 + speedRatio * 0.4);

    if (renderer) {
      renderer.emitImpactDebris(contactPoint, isRock ? 'rock' : 'wood', 20);
      renderer.emitImpactSparks(contactPoint, 16);
    }

    // Lateral Glancing Deflection (preserves momentum, never stops dead)
    const deflectDir = Math.sign(nx) || (Math.random() < 0.5 ? 1 : -1);
    vehicle.position.x += deflectDir * (0.5 + speedRatio * 0.5);

    const massFactor = 1200 / (vehicle.modelConfig.weightKg || 1200);
    const retention = Math.max(0.55, 0.74 - speedRatio * 0.18 * massFactor);
    vehicle.forwardSpeed = Math.max(3.8, vehicle.forwardSpeed * retention);

    const hasBullbar = !!(vehicle.upgrades.heavy_bullbar || vehicle.upgrades.bullbar);
    if ((hasBullbar || speedRatio > 0.65) && hazard.type === 'fallen_timber') {
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
    } else {
      hazard.position.x += -deflectDir * 1.6;
      hazard.mesh.position.x = hazard.position.x;
    }
  }

  // =========================================================================
  // COLLISION: Resolve Solid Obstacle Collision with Roadside Environment Props
  // =========================================================================
  resolveSolidObstacleCollision(obs, vehicle, dist, contactRadius, dx, dz, delta, malfunctionManager, renderer) {
    const col = obs.collider;
    if (!col || !col.solid) return;

    if (obs.hitCooldown && obs.hitCooldown > 0) {
      obs.hitCooldown -= delta;
      return;
    }

    let nx = dx / (dist || 0.001);
    let nz = dz / (dist || 0.001);

    // Overlap Separation
    const overlap = Math.max(0.04, contactRadius - dist);
    vehicle.position.x += nx * overlap;
    vehicle.position.z += nz * overlap;

    const psi = vehicle.rotation ? vehicle.rotation.y : 0;
    const sinPsi = Math.sin(psi);
    const cosPsi = Math.cos(psi);

    const Vx = vehicle.forwardSpeed * sinPsi + vehicle.lateralSpeed * cosPsi;
    const Vz = vehicle.forwardSpeed * cosPsi - vehicle.lateralSpeed * sinPsi;
    const speedTotal = Math.hypot(Vx, Vz);
    const speedKmh = speedTotal * 3.6;

    const Vn = Vx * nx + Vz * nz;
    const tx = -nz;
    const tz = nx;
    const Vt = Vx * tx + Vz * tz;

    const contactPoint = new THREE.Vector3(
      obs.position.x + nx * (col.radius || 1.0),
      vehicle.position.y + 0.35,
      obs.position.z + nz * (col.radius || 1.0)
    );

    if (Vn < 0) {
      obs.hitCooldown = 0.25;

      const hasBullbar = !!(vehicle.upgrades.heavy_bullbar || vehicle.upgrades.bullbar);
      if (col.isBreakable && (speedKmh > 16.0 || hasBullbar)) {
        col.solid = false;
        if (obs.mesh) {
          obs.mesh.position.y -= 0.55;
          obs.mesh.rotation.x += (Math.random() - 0.5) * 0.9;
          obs.mesh.rotation.z += (Math.random() - 0.5) * 0.9;
        }

        const breakDamage = Math.round(1 + speedTotal * 0.25);
        vehicle.takeDamage(hasBullbar ? 0 : breakDamage);
        vehicle.forwardSpeed = Math.max(2.5, vehicle.forwardSpeed * 0.88);

        this.cameraController.addTrauma(0.25);
        this.audioEngine.playImpact(0.45);

        if (renderer) {
          const debrisType = col.type === 'fence' ? 'wood' : (col.type === 'milestone' ? 'rock' : 'wood');
          renderer.emitImpactDebris(contactPoint, debrisType, 16);
          renderer.emitImpactSparks(contactPoint, 8);
        }
        return;
      }

      // Solid Rigid Obstacle (Trees, Granite Walls, Rocks, Steel Utility Poles)
      const impactSeverity = Math.abs(Vn);
      const restitution = 0.24;
      const tangentialFriction = 0.58;
      const Vn_new = impactSeverity * restitution;
      const Vt_new = Vt * tangentialFriction;

      const Vx_new = Vn_new * nx + Vt_new * tx;
      const Vz_new = Vn_new * nz + Vt_new * tz;

      const u_new = Vx_new * sinPsi + Vz_new * cosPsi;
      const v_new = Vx_new * cosPsi - Vz_new * sinPsi;

      vehicle.forwardSpeed = u_new;
      vehicle.lateralSpeed = THREE.MathUtils.clamp(v_new, -3.5, 3.5);

      const localAngle = Math.atan2(nx, nz) - psi;
      const deflectSign = Math.sign(Math.sin(localAngle)) || (Math.random() < 0.5 ? 1 : -1);
      vehicle.yawRate += deflectSign * THREE.MathUtils.clamp(impactSeverity * 0.22, 0.4, 2.5);

      vehicle.impactShockPitch = -Math.sign(vehicle.forwardSpeed || 1) * Math.min(0.24, impactSeverity * 0.022);
      vehicle.impactShockRoll = -deflectSign * Math.min(0.28, impactSeverity * 0.026);

      const baseDmg = 8 + impactSeverity * 2.8;
      let armorFactor = 1.0;
      if (vehicle.upgrades.heavy_bullbar) armorFactor = 0.22;
      else if (vehicle.upgrades.bullbar) armorFactor = 0.48;
      vehicle.takeDamage(Math.round(baseDmg * armorFactor));

      this.cameraController.addTrauma(Math.min(1.0, 0.35 + impactSeverity * 0.06));
      this.audioEngine.playImpact(Math.min(1.0, 0.55 + impactSeverity * 0.05));
      this.audioEngine.playSuspensionThump(0.65);

      if (renderer) {
        let debrisType = 'wood';
        if (col.type === 'rock' || col.type === 'cliff' || col.type === 'wall' || col.type === 'milestone') {
          debrisType = 'rock';
        } else if (col.type === 'pole' || col.type === 'structure' || col.type === 'wreck' || col.type === 'barrier') {
          debrisType = 'sparks';
        }
        renderer.emitImpactDebris(contactPoint, debrisType, 22);
        renderer.emitImpactSparks(contactPoint, 18);
      }
    }
  }
}
