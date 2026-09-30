/**
 * THE LONG MERIDIAN - Realistic Highway Hazards & Road Obstacle System
 * 100% Proportioned, authentic road obstacles (fallen timber, blown truck tire treads,
 * rockfall boulders, dropped freight crates, frost-heave buckles, safety barrels).
 * All obstacles strictly occupy at most one lane, guaranteeing clear clearance to pass.
 */

import { CONFIG } from '../config.js';

export class Hazards {
  constructor(scene, roadGenerator, audioEngine, cameraController) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;
    this.audioEngine = audioEngine;
    this.cameraController = cameraController;

    this.hazardList = [];
    this.nextHazardZ = 60;
    this.spawnInterval = 45; // Generous highway spacing (every 40-70m)

    this.initAssets();
  }

  initAssets() {
    // Realistic materials for authentic highway debris
    this.matWoodBark = new THREE.MeshStandardMaterial({
      color: 0x3d2719,
      roughness: 0.95,
      metalness: 0.05
    });
    this.matWoodCut = new THREE.MeshStandardMaterial({
      color: 0xc8a46e,
      roughness: 0.85,
      metalness: 0.0
    });
    this.matTireRubber = new THREE.MeshStandardMaterial({
      color: 0x18191b,
      roughness: 0.95,
      metalness: 0.1
    });
    this.matGraniteRock = new THREE.MeshStandardMaterial({
      color: 0x5a544d,
      roughness: 0.92,
      metalness: 0.08
    });
    this.matCargoWood = new THREE.MeshStandardMaterial({
      color: 0x6e5239,
      roughness: 0.85,
      metalness: 0.1
    });
    this.matSteelDrum = new THREE.MeshStandardMaterial({
      color: 0x1e3a5f, // Industrial blue steel drum
      roughness: 0.45,
      metalness: 0.75
    });
    this.matRustedMetal = new THREE.MeshStandardMaterial({
      color: 0x7c2d12,
      roughness: 0.85,
      metalness: 0.4
    });
    this.matBarrelOrange = new THREE.MeshStandardMaterial({
      color: 0xea580c, // Safety orange
      roughness: 0.5,
      metalness: 0.1
    });
    this.matReflectiveWhite = new THREE.MeshStandardMaterial({
      color: 0xf8fafc,
      roughness: 0.3,
      emissive: 0x94a3b8,
      emissiveIntensity: 0.3
    });
    this.matPotholeAsphalt = new THREE.MeshStandardMaterial({
      color: 0x15171a,
      roughness: 0.98
    });
    this.matPotholeWater = new THREE.MeshStandardMaterial({
      color: 0x11161d,
      roughness: 0.08,
      metalness: 0.9,
      transparent: true,
      opacity: 0.88
    });
  }

  update(playerZ, vehicle, playerFoot, delta, malfunctionManager = null, renderer = null, scenerySpawner = null, landscapeManager = null) {
    // 1. Spawning
    const maxZ = playerZ + 220;
    while (this.nextHazardZ < maxZ) {
      this.spawnHazardAt(this.nextHazardZ);
      this.nextHazardZ += this.spawnInterval + (Math.random() * 30 - 10);
    }

    // 2. Highway Lane Hazard Collision Detection & Physics Resolution
    for (let i = this.hazardList.length - 1; i >= 0; i--) {
      const h = this.hazardList[i];

      // Decrement hit cooldown
      if (h.hitCooldown > 0) {
        h.hitCooldown -= delta;
      }

      // Check collision with Vehicle
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

      // Check Scavenge proximity on foot
      if (playerFoot && playerFoot.active && (h.type === 'dropped_crate' || h.type === 'dropped_drum') && !h.scavenged) {
        const footDist = playerFoot.position.distanceTo(h.position);
        h.canScavenge = (footDist < 2.5);
      }

      // Despawn
      if (h.position.z < playerZ - 60) {
        this.scene.remove(h.mesh);
        this.hazardList.splice(i, 1);
      }
    }

    // 3. Roadside Environment & Off-Road Props Collision Resolution
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

  spawnHazardAt(z) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(z);
    const halfW = roadInfo.width * 0.5;

    // Pick lane: strictly place either in LEFT lane (-3.4m) or RIGHT lane (+3.4m)
    // with subtle jitter, guaranteeing the other lane has > 6.0m of clear clearance!
    const side = Math.random() < 0.5 ? -1 : 1;
    const laneOffset = side * (halfW * 0.45 + (Math.random() - 0.5) * 1.2);
    const x = roadInfo.x + laneOffset;
    const y = roadInfo.y;

    const roll = Math.random();
    let type = 'blown_tire';

    if (roll < 0.22) type = 'fallen_timber';
    else if (roll < 0.45) type = 'blown_tire';
    else if (roll < 0.65) type = 'rockfall_debris';
    else if (roll < 0.80) type = 'dropped_crate';
    else if (roll < 0.92) type = 'frost_heave';
    else type = 'construction_drum';

    let mesh = null;
    let radius = 1.1;

    switch (type) {
      case 'fallen_timber': {
        // Realistic fallen pine log with branch stubs across part of one lane
        mesh = new THREE.Group();
        const trunkLen = 4.8;
        const trunkR = 0.26;
        const trunkGeo = new THREE.CylinderGeometry(trunkR * 0.8, trunkR, trunkLen, 7);
        const trunkMesh = new THREE.Mesh(trunkGeo, this.matWoodBark);
        trunkMesh.rotation.z = Math.PI / 2;
        trunkMesh.castShadow = true;
        trunkMesh.receiveShadow = true;
        mesh.add(trunkMesh);

        // Cut wood end rings
        const cutGeo = new THREE.CircleGeometry(trunkR * 0.8, 7);
        const cutMesh = new THREE.Mesh(cutGeo, this.matWoodCut);
        cutMesh.position.set(-trunkLen * 0.5, 0, 0);
        cutMesh.rotation.y = -Math.PI / 2;
        mesh.add(cutMesh);

        // 2 Branch nubs
        const branchGeo = new THREE.CylinderGeometry(0.08, 0.12, 0.9, 5);
        const b1 = new THREE.Mesh(branchGeo, this.matWoodBark);
        b1.position.set(-1.0, 0.35, 0.1);
        b1.rotation.x = 0.6;
        mesh.add(b1);

        const b2 = new THREE.Mesh(branchGeo, this.matWoodBark);
        b2.position.set(1.2, 0.3, -0.15);
        b2.rotation.x = -0.5;
        mesh.add(b2);

        // Angle naturally across the lane
        mesh.rotation.y = (Math.random() - 0.5) * 0.55;
        mesh.position.set(x, y + trunkR, z);
        radius = 2.1;
        break;
      }

      case 'blown_tire': {
        // "Alligatore" - Shredded semi-truck radial tire tread dropped on highway
        mesh = new THREE.Group();
        const treadGeo = new THREE.BoxGeometry(0.95, 0.12, 0.36);
        const tread = new THREE.Mesh(treadGeo, this.matTireRubber);
        tread.castShadow = true;
        tread.receiveShadow = true;
        mesh.add(tread);

        // Frayed steel cord whiskers
        const cordGeo = new THREE.BoxGeometry(0.35, 0.04, 0.08);
        const cord = new THREE.Mesh(cordGeo, this.matRustedMetal);
        cord.position.set(0.5, 0.04, 0.1);
        mesh.add(cord);

        mesh.rotation.y = (Math.random() - 0.5) * 1.2;
        mesh.position.set(x, y + 0.06, z);
        radius = 0.85;
        break;
      }

      case 'rockfall_debris': {
        // Cluster of 2-3 tumbled jagged granite boulders
        mesh = new THREE.Group();
        const count = 2 + Math.floor(Math.random() * 2);
        for (let k = 0; k < count; k++) {
          const rSize = 0.45 + Math.random() * 0.45;
          const rockGeo = new THREE.DodecahedronGeometry(rSize, 0);
          const rock = new THREE.Mesh(rockGeo, this.matGraniteRock);
          rock.position.set(
            (Math.random() - 0.5) * 1.4,
            rSize * 0.7,
            (Math.random() - 0.5) * 1.4
          );
          rock.rotation.set(Math.random() * 3, Math.random() * 3, Math.random() * 3);
          rock.castShadow = true;
          rock.receiveShadow = true;
          mesh.add(rock);
        }
        mesh.position.set(x, y, z);
        radius = 1.35;
        break;
      }

      case 'dropped_crate': {
        // Heavy wooden freight crate with steel corner reinforcements
        mesh = new THREE.Group();
        const crateGeo = new THREE.BoxGeometry(1.2, 0.95, 0.9);
        const crate = new THREE.Mesh(crateGeo, this.matCargoWood);
        crate.castShadow = true;
        crate.receiveShadow = true;
        mesh.add(crate);

        // Corner metal strapping
        const strapGeo = new THREE.BoxGeometry(1.22, 0.97, 0.06);
        const strap = new THREE.Mesh(strapGeo, this.matRustedMetal);
        mesh.add(strap);

        mesh.rotation.y = (Math.random() - 0.5) * 0.6;
        mesh.position.set(x, y + 0.48, z);
        radius = 1.15;
        break;
      }

      case 'frost_heave': {
        // Permafrost road buckle / asphalt pothole with water puddle
        mesh = new THREE.Group();
        const rimGeo = new THREE.CylinderGeometry(1.4, 1.6, 0.08, 10);
        const rim = new THREE.Mesh(rimGeo, this.matPotholeAsphalt);
        rim.receiveShadow = true;
        mesh.add(rim);

        const waterGeo = new THREE.CylinderGeometry(1.2, 1.2, 0.09, 10);
        const water = new THREE.Mesh(waterGeo, this.matPotholeWater);
        water.receiveShadow = true;
        mesh.add(water);

        mesh.position.set(x, y + 0.04, z);
        radius = 1.4;
        break;
      }

      case 'construction_drum': {
        // Highway safety traffic drum with retroreflective stripes
        mesh = new THREE.Group();
        // Weighted black rubber base
        const baseGeo = new THREE.CylinderGeometry(0.42, 0.45, 0.12, 12);
        const base = new THREE.Mesh(baseGeo, this.matTireRubber);
        base.position.y = 0.06;
        base.castShadow = true;
        mesh.add(base);

        // Orange barrel body
        const drumGeo = new THREE.CylinderGeometry(0.3, 0.35, 1.05, 12);
        const drum = new THREE.Mesh(drumGeo, this.matBarrelOrange);
        drum.position.y = 0.6;
        drum.castShadow = true;
        mesh.add(drum);

        // 2 Retroreflective white stripes
        const stripe1 = new THREE.Mesh(new THREE.CylinderGeometry(0.32, 0.33, 0.18, 12), this.matReflectiveWhite);
        stripe1.position.y = 0.52;
        mesh.add(stripe1);

        const stripe2 = new THREE.Mesh(new THREE.CylinderGeometry(0.31, 0.32, 0.18, 12), this.matReflectiveWhite);
        stripe2.position.y = 0.82;
        mesh.add(stripe2);

        mesh.position.set(x, y, z);
        radius = 0.9;
        break;
      }
    }

    if (mesh) {
      this.scene.add(mesh);
      this.hazardList.push({
        type: type,
        position: new THREE.Vector3(x, y, z),
        mesh: mesh,
        radius: radius,
        destroyed: false,
        scavenged: false,
        canScavenge: false,
        hitCooldown: 0.0
      });
    }
  }

  resolveVehicleCollision(hazard, vehicle, dist, contactRadius, dx, dz, malfunctionManager = null, renderer = null) {
    // 1. Cooldown Guard & Gentle Separation:
    // If obstacle is already on cooldown, prevent multi-frame damage and velocity freeze,
    // but gently push the car outward so it never gets wedged or stuck.
    if (hazard.hitCooldown > 0) {
      const overlap = contactRadius - dist;
      if (overlap > 0) {
        const nx = dist > 0.01 ? (dx / dist) : (dx >= 0 ? 1 : -1);
        vehicle.position.x += nx * overlap * 0.35;
      }
      return;
    }

    // Activate collision cooldown (prevents rapid-fire damage and stuck physics)
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

    // 2. Immediate Dispenetration: Push vehicle out of hazard volume
    vehicle.position.x += nx * (overlap + 0.14);
    vehicle.position.z += nz * (overlap + 0.14);

    // 3. Dynamic Suspension & Chassis Shock Impulse
    if (vehicle.applyImpactImpulse) {
      vehicle.applyImpactImpulse(nx, nz, speedMs);
    }

    // 4. Type-Specific Impact Mechanics
    // ----------------------------------------------------
    // Type A: Pothole / Frost Heave (Suspension shock, never stops car dead)
    if (hazard.type === 'frost_heave') {
      if (speedKmh > 30) {
        this.cameraController.addTrauma(0.35 * speedRatio);
        this.audioEngine.playSuspensionThump(0.4 + speedRatio * 0.5);
        vehicle.forwardSpeed *= 0.91;
        if (renderer) {
          renderer.emitImpactDebris(contactPoint, 'rock', 8);
        }
        if (malfunctionManager && speedKmh > 70 && !vehicle.upgrades.rally_suspension && Math.random() < 0.22) {
          malfunctionManager.triggerFault('flat_tire');
        }
      }
      return;
    }

    // Type B: Blown Truck Tire Tread (Light rubber debris explodes and scatters)
    if (hazard.type === 'blown_tire') {
      this.audioEngine.playImpact(0.35);
      this.cameraController.addTrauma(0.25);
      vehicle.forwardSpeed *= 0.94;
      vehicle.takeDamage(Math.round(2 + speedRatio * 4));
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) {
        renderer.emitImpactDebris(contactPoint, 'rubber', 14);
      }
      if (malfunctionManager && !vehicle.upgrades.studded_tires && Math.random() < 0.12) {
        malfunctionManager.triggerFault('flat_tire');
      }
      return;
    }

    // Type C: Construction Drum (Orange plastic barrel knocked flying with sparks)
    if (hazard.type === 'construction_drum') {
      this.audioEngine.playImpact(0.4);
      this.cameraController.addTrauma(0.2);
      vehicle.forwardSpeed *= 0.96;
      vehicle.takeDamage(Math.round(1 + speedRatio * 3));
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) {
        renderer.emitImpactDebris(contactPoint, 'barrel', 16);
        renderer.emitImpactSparks(contactPoint, 10);
      }
      return;
    }

    // Type D: Dropped Freight Crate (Wooden crate shatters with splinters)
    if (hazard.type === 'dropped_crate') {
      const damage = Math.round(5 + speedRatio * 11);
      vehicle.takeDamage(damage);
      // Glancing speed reduction: preserves momentum, NEVER stops dead!
      vehicle.forwardSpeed = Math.max(3.8, vehicle.forwardSpeed * 0.82);
      this.cameraController.addTrauma(Math.min(0.8, 0.25 + speedRatio * 0.5));
      this.audioEngine.playImpact(0.65);
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) {
        renderer.emitImpactDebris(contactPoint, 'wood', 20);
        renderer.emitImpactSparks(contactPoint, 8);
      }
      return;
    }

    // Type E: Rigid Heavy Obstacles (Fallen Timber & Granite Rockfall)
    const isRock = hazard.type === 'rockfall_debris';
    const baseDmg = isRock ? 15 : 10;
    const damage = Math.round(baseDmg + speedRatio * (isRock ? 26 : 20));
    vehicle.takeDamage(damage);

    this.cameraController.addTrauma(Math.min(1.0, 0.4 + speedRatio * 0.65));
    this.audioEngine.playImpact(Math.min(1.0, 0.65 + speedRatio * 0.35));
    this.audioEngine.playSuspensionThump(0.5 + speedRatio * 0.5);

    if (renderer) {
      renderer.emitImpactDebris(contactPoint, isRock ? 'rock' : 'wood', 24);
      renderer.emitImpactSparks(contactPoint, 16);
    }

    // Lateral Glancing Deflection:
    // Real vehicles deflect sideways rather than coming to a dead halt!
    const deflectDir = Math.sign(nx) || (Math.random() < 0.5 ? 1 : -1);
    vehicle.position.x += deflectDir * (0.45 + speedRatio * 0.55);

    // Momentum Retention:
    // Retains at least 3.5 m/s (~12.6 km/h) of rolling speed so the car never stalls or gets locked in place!
    const massFactor = 1200 / (vehicle.modelConfig.weightKg || 1200);
    const retention = Math.max(0.52, 0.72 - speedRatio * 0.20 * massFactor);
    vehicle.forwardSpeed = Math.max(3.5, vehicle.forwardSpeed * retention);

    // Mechanical Fault Risk
    if (malfunctionManager) {
      if (isRock && !vehicle.upgrades.skid_plate && Math.random() < 0.40) {
        malfunctionManager.triggerFault('flat_tire');
      }
      if (speedRatio > 0.60 && !(vehicle.upgrades.heavy_bullbar || vehicle.upgrades.bullbar) && Math.random() < 0.30) {
        malfunctionManager.triggerFault('radiator_leak');
        if (renderer) {
          renderer.emitImpactDebris(vehicle.position, 'steam', 18);
        }
      }
    }

    // Obstacle Dynamic Displacement:
    // If car has Bullbar OR is moving fast (> 55 km/h), the obstacle is smashed / cleared from the road!
    const hasBullbar = !!(vehicle.upgrades.heavy_bullbar || vehicle.upgrades.bullbar);
    if (hasBullbar || speedRatio > 0.62) {
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
    } else {
      // Shove the obstacle aside toward the nearest shoulder so it doesn't block repeat travel
      const shoveDir = -deflectDir;
      hazard.position.x += shoveDir * 1.8;
      hazard.mesh.position.x = hazard.position.x;
      hazard.mesh.rotation.y += 0.4;
    }
  }

  resolveSolidObstacleCollision(obs, vehicle, dist, contactRadius, dx, dz, delta, malfunctionManager, renderer) {
    const col = obs.collider;
    if (!col || !col.solid) return;

    if (obs.hitCooldown && obs.hitCooldown > 0) {
      obs.hitCooldown -= delta;
      return;
    }

    let nx = dx / (dist || 0.001);
    let nz = dz / (dist || 0.001);

    // 1. OVERLAP PENETRATION RESOLUTION (Separation)
    const overlap = Math.max(0.04, contactRadius - dist);
    vehicle.position.x += nx * overlap;
    vehicle.position.z += nz * overlap;

    const psi = vehicle.rotation ? vehicle.rotation.y : 0;
    const sinPsi = Math.sin(psi);
    const cosPsi = Math.cos(psi);

    // Current world velocities before impact
    const Vx = vehicle.forwardSpeed * sinPsi + vehicle.lateralSpeed * cosPsi;
    const Vz = vehicle.forwardSpeed * cosPsi - vehicle.lateralSpeed * sinPsi;
    const speedTotal = Math.hypot(Vx, Vz);
    const speedKmh = speedTotal * 3.6;

    // Normal velocity: closing velocity towards the obstacle (negative means moving INTO obstacle)
    const Vn = Vx * nx + Vz * nz;

    // Tangential unit vector and velocity
    const tx = -nz;
    const tz = nx;
    const Vt = Vx * tx + Vz * tz;

    const contactPoint = new THREE.Vector3(
      obs.position.x + nx * (col.radius || 1.0),
      vehicle.position.y + 0.35,
      obs.position.z + nz * (col.radius || 1.0)
    );

    // Only process dynamic collision if car was closing into obstacle
    if (Vn < 0) {
      obs.hitCooldown = 0.25;

      // Case A: BREAKABLE ROADSIDE OBJECT (Wooden fence, snow marker pole, milestone post)
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

      // Case B: SOLID RIGID OBSTACLE (Trees, Granite Walls, Rocks, Steel Utility Poles, Streetlamps, Buildings, Bridge Pylons, Wrecks)
      const impactSeverity = Math.abs(Vn);

      // Rebound Restitution (e = 0.24) and Tangential Friction (sliding along obstacle with drag)
      const restitution = 0.24;
      const tangentialFriction = 0.58;
      const Vn_new = impactSeverity * restitution;
      const Vt_new = Vt * tangentialFriction;

      // New world velocity vector after rebound
      const Vx_new = Vn_new * nx + Vt_new * tx;
      const Vz_new = Vn_new * nz + Vt_new * tz;

      // Project new world velocity back into vehicle local coordinate frame:
      const u_new = Vx_new * sinPsi + Vz_new * cosPsi;
      const v_new = Vx_new * cosPsi - Vz_new * sinPsi;

      // Preserve rolling direction, damp velocity
      vehicle.forwardSpeed = u_new;
      vehicle.lateralSpeed = THREE.MathUtils.clamp(v_new, -3.5, 3.5);

      // Rotational Torque Deflection:
      const localAngle = Math.atan2(nx, nz) - psi;
      const deflectSign = Math.sign(Math.sin(localAngle)) || (Math.random() < 0.5 ? 1 : -1);
      vehicle.yawRate += deflectSign * THREE.MathUtils.clamp(impactSeverity * 0.22, 0.4, 2.5);

      // Suspension Dynamic Shock (pitch dive / roll heave)
      vehicle.impactShockPitch = -Math.sign(vehicle.forwardSpeed || 1) * Math.min(0.24, impactSeverity * 0.022);
      vehicle.impactShockRoll = -deflectSign * Math.min(0.28, impactSeverity * 0.026);

      // Physical Damage with Bullbar Armor Attenuation
      const baseDmg = 8 + impactSeverity * 2.8;
      let armorFactor = 1.0;
      if (vehicle.upgrades.heavy_bullbar) armorFactor = 0.22;
      else if (vehicle.upgrades.bullbar) armorFactor = 0.48;
      vehicle.takeDamage(Math.round(baseDmg * armorFactor));

      // Audio & Camera Trauma
      this.cameraController.addTrauma(Math.min(1.0, 0.35 + impactSeverity * 0.06));
      this.audioEngine.playImpact(Math.min(1.0, 0.55 + impactSeverity * 0.05));
      this.audioEngine.playSuspensionThump(0.65);

      // Visual Particles (Debris & High-Energy Sparks)
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

      // Malfunction Risks
      if (malfunctionManager && impactSeverity > 7.0 && !vehicle.upgrades.heavy_bullbar) {
        if (!vehicle.upgrades.skid_plate && Math.random() < 0.35) {
          malfunctionManager.triggerFault('flat_tire');
        }
        if (impactSeverity > 11.0 && Math.random() < 0.30) {
          malfunctionManager.triggerFault('radiator_leak');
          if (renderer) renderer.emitImpactDebris(vehicle.position, 'steam', 18);
        }
      }
    }
  }
}
