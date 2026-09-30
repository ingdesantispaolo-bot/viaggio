/**
 * THE LONG MERIDIAN - Breathtaking Landscapes, Celestial Sky & Landmark Megastructures
 * Renders distant mountain horizons, glowing Aurora Borealis ribbons, starfields, suspension bridges and neon motels.
 */

export class LandscapeManager {
  constructor(scene, roadGenerator = null) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;

    this.group = new THREE.Group();
    this.scene.add(this.group);

    // Dynamic components
    this.auroraMesh = null;
    this.auroraTime = 0;
    this.distantMountains = [];
    this.landmarks = [];
    this.spawnedMilestones = new Set();

    this.initSkyAndMountains();
  }

  getRoadInfo(z) {
    if (this.roadGenerator && typeof this.roadGenerator.getRoadInfoAt === 'function') {
      return this.roadGenerator.getRoadInfoAt(z);
    }
    return { x: 0, y: 0, roadAngle: 0 };
  }

  initSkyAndMountains() {
    // 1. Starfield Dome
    const starCount = 600;
    const starGeo = new THREE.BufferGeometry();
    const starPositions = new Float32Array(starCount * 3);
    for (let i = 0; i < starCount; i++) {
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(Math.random() * 0.8 + 0.2);
      const r = 240;
      starPositions[i * 3 + 0] = r * Math.sin(phi) * Math.cos(theta);
      starPositions[i * 3 + 1] = r * Math.cos(phi) + 10;
      starPositions[i * 3 + 2] = r * Math.sin(phi) * Math.sin(theta);
    }
    starGeo.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
    const starMat = new THREE.PointsMaterial({
      color: 0xffffff,
      size: 1.2,
      transparent: true,
      opacity: 0.85
    });
    this.starPoints = new THREE.Points(starGeo, starMat);
    this.group.add(this.starPoints);

    // 2. Giant Low-Hanging Celestial Moon
    const moonGeo = new THREE.SphereGeometry(18, 16, 16);
    const moonMat = new THREE.MeshBasicMaterial({
      color: 0xffeed8,
      transparent: true,
      opacity: 0.88
    });
    this.moon = new THREE.Mesh(moonGeo, moonMat);
    this.moon.position.set(65, 80, 200);
    this.group.add(this.moon);

    // Moon Glow Halo
    const haloGeo = new THREE.PlaneGeometry(65, 65);
    const haloMat = new THREE.MeshBasicMaterial({
      color: 0xffc488,
      transparent: true,
      opacity: 0.22,
      blending: THREE.AdditiveBlending,
      side: THREE.DoubleSide
    });
    const halo = new THREE.Mesh(haloGeo, haloMat);
    halo.position.copy(this.moon.position);
    halo.position.z -= 1;
    this.group.add(halo);

    // 3. Shimmering Aurora Borealis Ribbon Shader
    this.initAuroraBorealis();

    // 4. Distant Mountain Ranges (Left and Right Horizons)
    this.initDistantMountains();
  }

  initAuroraBorealis() {
    // Ribbon mesh with waving sinusoidal deformation
    const width = 180;
    const height = 45;
    const segmentsW = 32;
    const segmentsH = 8;
    this.auroraGeo = new THREE.PlaneGeometry(width, height, segmentsW, segmentsH);

    // Create vibrant gradient canvas for Aurora ribbon
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 64;
    const ctx = canvas.getContext('2d');
    const grad = ctx.createLinearGradient(0, 64, 0, 0);
    grad.addColorStop(0, 'rgba(0, 0, 0, 0)');
    grad.addColorStop(0.3, 'rgba(16, 185, 129, 0.45)');  // Emerald green
    grad.addColorStop(0.7, 'rgba(6, 182, 212, 0.55)');   // Cyan
    grad.addColorStop(0.9, 'rgba(168, 85, 247, 0.35)');  // Violet
    grad.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, 256, 64);

    const auroraTex = new THREE.CanvasTexture(canvas);
    this.auroraMat = new THREE.MeshBasicMaterial({
      map: auroraTex,
      transparent: true,
      opacity: 0.75,
      blending: THREE.AdditiveBlending,
      side: THREE.DoubleSide,
      depthWrite: false
    });

    this.auroraMesh = new THREE.Mesh(this.auroraGeo, this.auroraMat);
    this.auroraMesh.position.set(0, 68, 140);
    this.auroraMesh.rotation.x = 0.35;
    this.group.add(this.auroraMesh);
  }

  initDistantMountains() {
    const mountainMat = new THREE.MeshStandardMaterial({
      color: 0x1b2028,
      roughness: 0.95,
      metalness: 0.08
    });

    const snowCapMat = new THREE.MeshStandardMaterial({
      color: 0xf1f5f9,
      roughness: 0.9,
      metalness: 0.05
    });

    // Create continuous jagged snow-capped mountain ridge modules on Left (-X) and Right (+X)
    [-1, 1].forEach((side) => {
      for (let i = 0; i < 6; i++) {
        const mGroup = new THREE.Group();
        const baseZ = i * 95;
        const xPos = side * (135 + Math.random() * 30);

        // Multiple overlapping jagged mountain cones with alpine snow peaks
        for (let j = 0; j < 4; j++) {
          const height = 45 + Math.random() * 40;
          const radius = 30 + Math.random() * 25;
          const cone = new THREE.Mesh(
            new THREE.ConeGeometry(radius, height, 6),
            mountainMat
          );
          const cx = (Math.random() - 0.5) * 30;
          const cz = (Math.random() - 0.5) * 45;
          cone.position.set(cx, height * 0.45, cz);
          cone.rotation.y = Math.random() * Math.PI;
          mGroup.add(cone);

          // Realistic Alaskan snow cap
          const capHeight = height * 0.38;
          const capRadius = radius * 0.38;
          const snowCap = new THREE.Mesh(
            new THREE.ConeGeometry(capRadius, capHeight, 6),
            snowCapMat
          );
          snowCap.position.set(cx, height * 0.81, cz);
          snowCap.rotation.y = cone.rotation.y;
          mGroup.add(snowCap);
        }

        mGroup.position.set(xPos, -2, baseZ);
        this.group.add(mGroup);
        this.distantMountains.push({ group: mGroup, side: side, z: baseZ });
      }
    });
  }

  update(playerZ, delta, biome) {
    // 1. Shift Stars, Moon and Aurora to follow player forward movement
    this.starPoints.position.z = playerZ;
    this.moon.position.z = playerZ + 200;

    // 2. Animate Aurora Borealis ribbon wave
    if (this.auroraMesh) {
      this.auroraTime += delta * 1.2;
      this.auroraMesh.position.z = playerZ + 140;

      const pos = this.auroraGeo.attributes.position.array;
      for (let i = 0; i < pos.length; i += 3) {
        const u = pos[i]; // X
        pos[i + 1] = 68 + Math.sin(u * 0.04 + this.auroraTime) * 6 + Math.cos(u * 0.08 + this.auroraTime * 0.7) * 3;
      }
      this.auroraGeo.attributes.position.needsUpdate = true;
    }

    // 3. Recycle Distant Mountains
    this.distantMountains.forEach((m) => {
      if (m.group.position.z < playerZ - 90) {
        m.group.position.z += 90 * 6;
      }
    });

    // 4. Deterministic Sector Milestone Landmarks
    // Each sector (650m) has:
    // - Boundary Gantry at sectorStart + 16m
    // - Contextual Thematic Megastructure at sectorStart + 350m
    const minSector = Math.floor(Math.max(0, playerZ - 60) / 650);
    const maxSector = Math.floor((playerZ + 240) / 650);

    for (let s = minSector; s <= maxSector; s++) {
      const sectorStart = s * 650;

      // 4a. Sector Boundary Highway Gantry Arch
      const gantryKey = `gantry_${s}`;
      const gantryZ = sectorStart + 16;
      if (!this.spawnedMilestones.has(gantryKey) && gantryZ > playerZ - 60) {
        this.spawnedMilestones.add(gantryKey);
        const group = this.createHighwayGantryLandmark(gantryZ, s);
        if (group) {
          this.scene.add(group);
          this.landmarks.push({ meshGroup: group, z: gantryZ });
        }
      }

      // 4b. Biome-Specific Narrative Megastructure at midpoint (sectorStart + 350m)
      const megaKey = `mega_${s}`;
      const megaZ = sectorStart + 350;
      if (!this.spawnedMilestones.has(megaKey) && megaZ > playerZ - 60) {
        this.spawnedMilestones.add(megaKey);
        const biomeIndex = s % 6;
        let res = null;

        if (biomeIndex === 0) {
          // Sector 0 (Rusty Periphery): Overgrown Collapsed Highway Flyover
          res = { group: this.createOverheadFlyover(megaZ) };
        } else if (biomeIndex === 1) {
          // Sector 1 (Black Pine Woods): The "NORTH STAR" Neon Diner & Motel oasis
          res = { group: this.createNeonDinerLandmark(megaZ) };
        } else if (biomeIndex === 2) {
          // Sector 2 (Flooded Marshland): Monumental Red Suspension Bridge Tower
          res = { group: this.createSuspensionBridgeTower(megaZ) };
        } else if (biomeIndex === 3) {
          // Sector 3 (The Glass Crater): Monolithic Parabolic Satellite Radar Dish
          res = { group: this.createSatelliteDish(megaZ) };
        } else if (biomeIndex === 4) {
          // Sector 4 (Iron Gorge): Canyon High-Wire Suspension Crossing
          res = { group: this.createSuspensionBridgeTower(megaZ) };
        } else {
          // Sector 5 (Permafrost Highlands): Wind Farm of 3 Staggered Turbines
          res = this.createWindTurbineLandmark(megaZ);
        }

        if (res && res.group) {
          this.scene.add(res.group);
          this.landmarks.push({
            meshGroup: res.group,
            rotor: res.rotor || null,
            z: megaZ
          });
        }
      }
    }

    // 5. Clean up landmarks behind with proper geometry disposal
    for (let i = this.landmarks.length - 1; i >= 0; i--) {
      const lm = this.landmarks[i];
      if (lm.meshGroup.position.z < playerZ - 80) {
        this.scene.remove(lm.meshGroup);
        lm.meshGroup.traverse((child) => {
          if (child.isMesh && child.geometry) {
            child.geometry.dispose();
          }
        });
        this.landmarks.splice(i, 1);
      }
    }

    // 6. Animate rotating landmarks (e.g. wind turbine blades)
    for (let i = 0; i < this.landmarks.length; i++) {
      const lm = this.landmarks[i];
      if (lm.rotor) {
        lm.rotor.rotation.z += delta * 0.45;
      }
    }
  }

  getNearbyColliders(playerZ, range = 35.0) {
    const minZ = playerZ - 10.0;
    const maxZ = playerZ + range;
    const colliders = [];
    for (let i = 0; i < this.landmarks.length; i++) {
      const lm = this.landmarks[i];
      if (lm.z >= minZ && lm.z <= maxZ && lm.meshGroup && lm.meshGroup.userData && lm.meshGroup.userData.colliders) {
        lm.meshGroup.userData.colliders.forEach((c) => {
          colliders.push({
            position: { x: c.x, y: 0, z: c.z },
            mesh: lm.meshGroup,
            collider: { radius: c.radius, type: c.type, solid: true, isBreakable: false }
          });
        });
      }
    }
    return colliders;
  }

  createSuspensionBridgeTower(z) {
    const group = new THREE.Group();
    const roadInfo = this.getRoadInfo(z);
    group.position.set(roadInfo.x, roadInfo.y, z);
    group.rotation.y = roadInfo.roadAngle || 0;

    const steelMat = new THREE.MeshStandardMaterial({
      color: 0x8a2b20, // International orange/red bridge steel
      roughness: 0.6,
      metalness: 0.7
    });
    const cableMat = new THREE.LineBasicMaterial({ color: 0x333333, linewidth: 2 });
    const lightMat = new THREE.MeshBasicMaterial({ color: 0xff2222 });

    // Dual Giant Pylons (Left & Right of 24m road + shoulders)
    [-14.5, 14.5].forEach((px) => {
      const pylon = new THREE.Mesh(new THREE.BoxGeometry(1.8, 38, 2.2), steelMat);
      pylon.position.set(px, 19, 0);
      pylon.castShadow = true;
      group.add(pylon);

      // Red aircraft warning beacon at summit
      const beacon = new THREE.Mesh(new THREE.SphereGeometry(0.5, 8, 8), lightMat);
      beacon.position.set(px, 38.3, 0);
      group.add(beacon);

      const beaconLight = new THREE.PointLight(0xff2222, 1.5, 25);
      beaconLight.position.set(px, 38.3, 0);
      group.add(beaconLight);
    });

    // Horizontal Portal Crossbeam
    const crossbeam = new THREE.Mesh(new THREE.BoxGeometry(31, 1.8, 2.0), steelMat);
    crossbeam.position.set(0, 32, 0);
    crossbeam.castShadow = true;
    group.add(crossbeam);

    // Suspension Main Cables arching down to the road deck
    [-14.5, 14.5].forEach((px) => {
      const curve = new THREE.QuadraticBezierCurve3(
        new THREE.Vector3(px, 37, 0),
        new THREE.Vector3(px * 0.9, 12, 45),
        new THREE.Vector3(px * 0.85, 1, 90)
      );
      const points = curve.getPoints(20);
      const cableGeo = new THREE.BufferGeometry().setFromPoints(points);
      const cableLine = new THREE.Line(cableGeo, cableMat);
      group.add(cableLine);
    });

    group.userData.colliders = [
      { x: roadInfo.x - 14.5, z: z, radius: 1.8, type: 'structure' },
      { x: roadInfo.x + 14.5, z: z, radius: 1.8, type: 'structure' }
    ];

    return group;
  }

  createNeonDinerLandmark(z) {
    const group = new THREE.Group();
    // Placed off to the right shoulder
    group.position.set(16, 0, z);

    const darkWallMat = new THREE.MeshStandardMaterial({ color: 0x242830, roughness: 0.8 });
    const neonCyan = new THREE.MeshBasicMaterial({ color: 0x06b6d4 });
    const neonPink = new THREE.MeshBasicMaterial({ color: 0xf43f5e });

    // Diner Building Shell
    const building = new THREE.Mesh(new THREE.BoxGeometry(14, 4.2, 18), darkWallMat);
    building.position.set(0, 2.1, 0);
    building.castShadow = true;
    group.add(building);

    // Glowing Neon Roof Sign ("NORTH STAR - LAST STOP")
    const signBox = new THREE.Mesh(new THREE.BoxGeometry(8.5, 2.2, 0.4), darkWallMat);
    signBox.position.set(0, 5.4, 6);
    group.add(signBox);

    const neonBar1 = new THREE.Mesh(new THREE.BoxGeometry(7.5, 0.25, 0.5), neonPink);
    neonBar1.position.set(0, 5.8, 6.1);
    group.add(neonBar1);

    const neonBar2 = new THREE.Mesh(new THREE.BoxGeometry(6.0, 0.25, 0.5), neonCyan);
    neonBar2.position.set(0, 5.0, 6.1);
    group.add(neonBar2);

    // Pink / Cyan Ambient Neon Glow onto the asphalt
    const neonLight = new THREE.PointLight(0xf43f5e, 2.5, 35);
    neonLight.position.set(0, 5.5, 6);
    group.add(neonLight);

    const cyanGlow = new THREE.PointLight(0x06b6d4, 1.8, 28);
    cyanGlow.position.set(0, 2.5, 9);
    group.add(cyanGlow);

    group.userData.colliders = [
      { x: 16.0, z: z, radius: 6.5, type: 'building' }
    ];

    return group;
  }

  createOverheadFlyover(z) {
    const group = new THREE.Group();
    const roadInfo = this.getRoadInfo(z);
    group.position.set(roadInfo.x, roadInfo.y, z);
    group.rotation.y = (roadInfo.roadAngle || 0) + 0.25;

    const concMat = new THREE.MeshStandardMaterial({ color: 0x474c52, roughness: 0.9 });
    const steelMat = new THREE.MeshStandardMaterial({ color: 0x282c30, metalness: 0.6 });

    // Overhead highway deck crossing at 7m height
    const deck = new THREE.Mesh(new THREE.BoxGeometry(52, 1.4, 9), concMat);
    deck.position.set(0, 7.5, 0);
    deck.rotation.y = 0.25; // angled crossing
    deck.castShadow = true;
    group.add(deck);

    // Broken collapsed section with exposed rebar
    const rebarMat = new THREE.MeshStandardMaterial({ color: 0x7c2d12, metalness: 0.8 });
    for (let r = 0; r < 5; r++) {
      const rebar = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.04, 2.5, 4), rebarMat);
      rebar.position.set(10 + r * 0.8, 6.8, (Math.random() - 0.5) * 3);
      rebar.rotation.z = Math.PI / 4;
      group.add(rebar);
    }

    // Heavy concrete bridge piers set back beyond 24m gravel shoulders
    [-14.2, 14.2].forEach((px) => {
      const pier = new THREE.Mesh(new THREE.CylinderGeometry(1.2, 1.4, 7.5, 8), concMat);
      pier.position.set(px, 3.75, 0);
      pier.castShadow = true;
      group.add(pier);
    });

    group.userData.colliders = [
      { x: roadInfo.x - 14.2, z: z, radius: 1.8, type: 'structure' },
      { x: roadInfo.x + 14.2, z: z, radius: 1.8, type: 'structure' }
    ];

    return group;
  }

  createSatelliteDish(z) {
    const group = new THREE.Group();
    group.position.set(-32, 0, z);

    const dishMat = new THREE.MeshStandardMaterial({ color: 0xcfd8dc, roughness: 0.5, metalness: 0.6 });
    const mastMat = new THREE.MeshStandardMaterial({ color: 0x37474f, roughness: 0.8 });

    // Tower base
    const mast = new THREE.Mesh(new THREE.CylinderGeometry(1.5, 3.5, 18, 6), mastMat);
    mast.position.y = 9;
    mast.castShadow = true;
    group.add(mast);

    // Giant Parabolic Dish (18m diameter)
    const dish = new THREE.Mesh(
      new THREE.SphereGeometry(9, 16, 8, 0, Math.PI * 2, 0, Math.PI * 0.35),
      dishMat
    );
    dish.position.set(0, 18, 0);
    dish.rotation.x = -Math.PI / 3;
    dish.castShadow = true;
    group.add(dish);

    // Central receiver antenna
    const subAntenna = new THREE.Mesh(new THREE.CylinderGeometry(0.15, 0.2, 7.0, 5), mastMat);
    subAntenna.position.set(0, 20.5, 3.5);
    subAntenna.rotation.x = -Math.PI / 3;
    group.add(subAntenna);

    group.userData.colliders = [
      { x: -32, z: z, radius: 5.5, type: 'structure' }
    ];

    return group;
  }

  createWindTurbineLandmark(z) {
    const group = new THREE.Group();
    // Placed far on left or right rolling hills
    const side = Math.random() < 0.5 ? -1 : 1;
    group.position.set(side * 42, 0, z);

    const whiteMat = new THREE.MeshStandardMaterial({ color: 0xecf0f1, roughness: 0.4 });
    const darkMat = new THREE.MeshStandardMaterial({ color: 0x2c3e50, roughness: 0.8 });

    // 1. Tapered wind turbine mast (32m tall)
    const mast = new THREE.Mesh(new THREE.CylinderGeometry(0.8, 2.2, 32, 10), whiteMat);
    mast.position.y = 16;
    mast.castShadow = true;
    group.add(mast);

    // 2. Nacelle housing on top
    const nacelle = new THREE.Mesh(new THREE.BoxGeometry(2.4, 2.2, 6.0), whiteMat);
    nacelle.position.set(0, 32, 0);
    nacelle.castShadow = true;
    group.add(nacelle);

    // Red flashing hazard beacon on nacelle
    const beacon = new THREE.Mesh(
      new THREE.SphereGeometry(0.35, 6, 6),
      new THREE.MeshBasicMaterial({ color: 0xff0000 })
    );
    beacon.position.set(0, 33.3, -2.5);
    group.add(beacon);

    const beaconLight = new THREE.PointLight(0xff0000, 1.2, 20);
    beaconLight.position.set(0, 33.3, -2.5);
    group.add(beaconLight);

    // 3. 3-Blade Rotor Hub (attached at front of nacelle, facing road)
    const rotorGroup = new THREE.Group();
    rotorGroup.position.set(0, 32, 3.2);

    const hub = new THREE.Mesh(new THREE.SphereGeometry(1.2, 8, 8), darkMat);
    rotorGroup.add(hub);

    // 3 long aerodynamic blades (16m long each)
    for (let b = 0; b < 3; b++) {
      const angle = (b * Math.PI * 2) / 3;
      const blade = new THREE.Mesh(new THREE.BoxGeometry(0.65, 16, 0.15), whiteMat);
      blade.position.set(Math.sin(angle) * 8.0, Math.cos(angle) * 8.0, 0);
      blade.rotation.z = -angle;
      blade.castShadow = true;
      rotorGroup.add(blade);
    }

    group.add(rotorGroup);

    group.userData.colliders = [
      { x: side * 42, z: z, radius: 3.0, type: 'structure' }
    ];

    return { group: group, rotor: rotorGroup };
  }

  createHighwayGantryLandmark(z, sectorIndex = 0) {
    const group = new THREE.Group();
    const roadInfo = this.getRoadInfo(z);
    group.position.set(roadInfo.x, roadInfo.y, z);
    group.rotation.y = roadInfo.roadAngle || 0;

    const steelMat = new THREE.MeshStandardMaterial({ color: 0x3e444c, roughness: 0.6, metalness: 0.7 });
    const signMat = new THREE.MeshStandardMaterial({ color: 0x0f172a, roughness: 0.8 });

    // Dual vertical lattice support legs straddling the 24m road deck + shoulders
    [-13.8, 13.8].forEach((lx) => {
      const leg = new THREE.Mesh(new THREE.BoxGeometry(0.8, 10.0, 0.8), steelMat);
      leg.position.set(lx, 5.0, 0);
      leg.castShadow = true;
      group.add(leg);
    });

    // Horizontal truss span over roadway
    const span = new THREE.Mesh(new THREE.BoxGeometry(29.5, 1.4, 1.4), steelMat);
    span.position.set(0, 9.5, 0);
    span.castShadow = true;
    group.add(span);

    // Overhead Digital Electronic Matrix Signs (Facing approaching driver)
    const signBoard = new THREE.Mesh(new THREE.BoxGeometry(23.0, 2.3, 0.25), signMat);
    signBoard.position.set(0, 9.3, -0.7);
    group.add(signBoard);

    // Dynamic High-Visibility LED Matrix Canvas
    const canvas = document.createElement('canvas');
    canvas.width = 512;
    canvas.height = 128;
    const ctx = canvas.getContext('2d');

    // Matrix amber background
    ctx.fillStyle = '#05070a';
    ctx.fillRect(0, 0, 512, 128);

    // Border
    ctx.strokeStyle = '#f59e0b';
    ctx.lineWidth = 4;
    ctx.strokeRect(4, 4, 504, 120);

    const destMessages = [
      { top: 'FOX & GOLDSTREAM DREDGE 8 [MP 11]', sub: 'DALTON HWY 11 - FAIRBANKS MINING BELT / SLOW VEHICLES' },
      { top: 'YUKON RIVER - E.L. PATTON BRIDGE [MP 56]', sub: 'BLACK SPRUCE TAIGA - CAUTION ICE FOG & PIPELINE CREWS' },
      { top: 'COLDFOOT TRUCK STOP - SLATE CREEK [MP 175]', sub: 'KOYUKUK FLATS - SEVERE MUSKEG MUD / REDUCE SPEED' },
      { top: 'ARCTIC CIRCLE LAT 66° 33\' N [MP 244]', sub: 'CHANDALAR DEW LINE - GEOMAGNETIC STATIC RISK' },
      { top: 'ATIGUN PASS ELEV 4739 FT [MP 290]', sub: 'BROOKS RANGE DIVIDE - 12% STEEP GRADE / ROCKFALL HAZARD' },
      { top: 'DEADHORSE & PRUDHOE BAY [MP 414]', sub: 'BEAUFORT SEA - CONTINUOUS PERMAFROST / EXTREME BLIZZARD' }
    ];

    const idx = (sectorIndex || 0) % destMessages.length;
    const msg = destMessages[idx];

    // Primary Text (Amber LED)
    ctx.fillStyle = '#f59e0b';
    ctx.font = 'bold 22px monospace';
    ctx.textAlign = 'center';
    ctx.fillText(msg.top, 256, 48);

    // Hazard Subtitle (Yellow-Red)
    ctx.fillStyle = '#ef4444';
    ctx.font = 'bold 15px monospace';
    ctx.fillText(msg.sub, 256, 88);

    const signTexture = new THREE.CanvasTexture(canvas);
    const ledSignMat = new THREE.MeshBasicMaterial({ map: signTexture });
    const signScreen = new THREE.Mesh(new THREE.PlaneGeometry(13.2, 1.8), ledSignMat);
    signScreen.position.set(0, 8.8, -0.84);
    group.add(signScreen);

    // Lane control green arrows
    [-3.2, 3.2].forEach((ax) => {
      const laneSignal = new THREE.Mesh(
        new THREE.BoxGeometry(0.5, 0.5, 0.3),
        new THREE.MeshBasicMaterial({ color: 0x10b981 }) // Green check
      );
      laneSignal.position.set(ax, 7.6, -0.7);
      group.add(laneSignal);
    });

    // Downward illumination floodlights on roadway
    const flood = new THREE.SpotLight(0xffeedd, 2.5, 20, Math.PI / 4, 0.4, 1.5);
    flood.position.set(0, 8.8, 0);
    flood.target.position.set(0, 0, 0);
    group.add(flood);
    group.add(flood.target);

    group.userData.colliders = [
      { x: roadInfo.x - 13.8, z: z, radius: 1.0, type: 'pole' },
      { x: roadInfo.x + 13.8, z: z, radius: 1.0, type: 'pole' }
    ];

    return group;
  }
}
