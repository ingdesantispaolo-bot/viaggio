/**
 * THE LONG MERIDIAN - Enhanced Scenery & Roadside Environment Spawner
 * Spawns lush multi-layered pine trees, weathered boulders, utility poles with hanging sagged power lines, and wrecks.
 */

export class ScenerySpawner {
  constructor(scene, roadGenerator, biomeManager) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;
    this.biomeManager = biomeManager;

    this.props = [];
    this.nextSpawnZ = 12;
    this.spawnInterval = 7.0;

    this.lastPolePos = null;

    this.initSharedAssets();
  }

  initSharedAssets() {
    this.geoTrunk = new THREE.CylinderGeometry(0.28, 0.45, 3.8, 6);
    this.geoPineCone = new THREE.ConeGeometry(2.0, 4.5, 6);
    this.geoRock = new THREE.DodecahedronGeometry(1.3, 1);
    this.geoPole = new THREE.CylinderGeometry(0.14, 0.18, 7.5, 6);
    this.geoCrossArm = new THREE.BoxGeometry(2.6, 0.2, 0.2);

    this.matTrunk = new THREE.MeshStandardMaterial({ color: 0x332219, roughness: 0.95 });
    this.matPine1 = new THREE.MeshStandardMaterial({ color: 0x16261b, roughness: 0.85 });
    this.matPine2 = new THREE.MeshStandardMaterial({ color: 0x1d3324, roughness: 0.85 });
    this.matRock = new THREE.MeshStandardMaterial({ color: 0x48423d, roughness: 0.9 });
    this.matPole = new THREE.MeshStandardMaterial({ color: 0x2b2724, roughness: 0.85 });
    this.matWire = new THREE.LineBasicMaterial({ color: 0x111111, linewidth: 2 });
    this.matWreck = new THREE.MeshStandardMaterial({ color: 0x543228, roughness: 0.7, metalness: 0.4 });
    this.matBillboard = new THREE.MeshStandardMaterial({ color: 0x181a1c, roughness: 0.8 });

    // Highway Signage & Infrastructure Materials
    this.matMilestone = new THREE.MeshStandardMaterial({ color: 0xe2e8f0, roughness: 0.9 });
    this.matMilestoneCap = new THREE.MeshStandardMaterial({ color: 0xb91c1c, roughness: 0.6 });
    this.matSignPost = new THREE.MeshStandardMaterial({ color: 0x64748b, metalness: 0.8, roughness: 0.4 });
    this.matSignPlateYellow = new THREE.MeshStandardMaterial({ color: 0xf59e0b, roughness: 0.4 });
    this.matSignPlateWhite = new THREE.MeshStandardMaterial({ color: 0xf8fafc, roughness: 0.4 });
    this.matSignPlateBlue = new THREE.MeshStandardMaterial({ color: 0x0284c7, roughness: 0.4 });
    this.matSignBorderBlack = new THREE.MeshBasicMaterial({ color: 0x0f172a });
    this.matSignSymbolRed = new THREE.MeshBasicMaterial({ color: 0xdc2626 });
    this.matSnowPoleRed = new THREE.MeshBasicMaterial({ color: 0xdc2626 });
    this.matSnowPoleWhite = new THREE.MeshBasicMaterial({ color: 0xf8fafc });
    this.matFence = new THREE.MeshStandardMaterial({ color: 0x4a3728, roughness: 0.95 });
    this.matJersey = new THREE.MeshStandardMaterial({ color: 0x78716c, roughness: 0.9 });

    // Specialized biome materials
    this.matCrystalCyan = new THREE.MeshStandardMaterial({
      color: 0x06b6d4,
      emissive: 0x0891b2,
      emissiveIntensity: 0.85,
      roughness: 0.1,
      metalness: 0.9
    });
    this.matCrystalMagenta = new THREE.MeshStandardMaterial({
      color: 0xd946ef,
      emissive: 0xa21caf,
      emissiveIntensity: 0.9,
      roughness: 0.1,
      metalness: 0.9
    });
    this.matSnow = new THREE.MeshStandardMaterial({ color: 0xf1f5f9, roughness: 0.92 });
    this.matIce = new THREE.MeshStandardMaterial({ color: 0xa5f3fc, roughness: 0.15, metalness: 0.6, transparent: true, opacity: 0.85 });
    this.matRedRock = new THREE.MeshStandardMaterial({ color: 0x853a25, roughness: 0.92 });
    this.matRustedMetal = new THREE.MeshStandardMaterial({ color: 0x7c2d12, roughness: 0.8, metalness: 0.6 });
    this.matWoodLog = new THREE.MeshStandardMaterial({ color: 0x452a1c, roughness: 0.95 });
    this.matAmberGlow = new THREE.MeshBasicMaterial({ color: 0xf59e0b });
    this.matCyanGlow = new THREE.MeshBasicMaterial({ color: 0x06b6d4 });
  }

  update(playerZ) {
    const maxZ = playerZ + 230;

    // 1. Advance Linear Infrastructure (milestones, utility poles, streetlights, signs, snow poles)
    // Evaluated at fixed engineering intervals of 10m
    if (!this.nextInfrastructureZ) this.nextInfrastructureZ = 10;
    while (this.nextInfrastructureZ < maxZ) {
      this.spawnLinearInfrastructureAt(this.nextInfrastructureZ);
      this.nextInfrastructureZ += 10.0;
    }

    // 2. Advance Territorial Compounds & Natural Formations (groves, compounds, canyon cliffs)
    // Evaluated at regular spatial steps of 24m
    if (!this.nextClusterZ) this.nextClusterZ = 16;
    while (this.nextClusterZ < maxZ) {
      this.spawnTerritorialClusterAt(this.nextClusterZ);
      this.nextClusterZ += 24.0;
    }

    // 3. Despawn props left behind
    const despawnZ = playerZ - 75;
    for (let i = this.props.length - 1; i >= 0; i--) {
      const prop = this.props[i];
      if (prop.position.z < despawnZ) {
        this.scene.remove(prop);
        this.props.splice(i, 1);
      }
    }
  }

  spawnLinearInfrastructureAt(z) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(z);
    const biome = this.biomeManager.currentBiome;
    const relZ = ((z % 650) + 650) % 650;
    const halfW = roadInfo.width * 0.5;
    if (!this.spawnedMilestones) this.spawnedMilestones = new Set();

    // 1. Milestone Marker Posts (Cippi Chilometrici) - Exactly every 100m on Right Shoulder
    const mileIndex = Math.floor(z / 100);
    const mileKey = `mile_${mileIndex}`;
    if (!this.spawnedMilestones.has(mileKey) && (z % 100) < 10) {
      this.spawnedMilestones.add(mileKey);
      const km = (z / 1000).toFixed(1);
      const post = this.createMilestonePost(
        roadInfo.x + halfW + 0.85,
        roadInfo.y,
        z,
        `PK ${km}`
      );
      this.scene.add(post);
      this.props.push(post);
    }

    // 2. Regulatory & Hazard Highway Signs
    const signKey = `sign_${Math.floor(z / 60)}_${biome.id}`;
    if (!this.spawnedMilestones.has(signKey)) {
      let signType = null;
      if (relZ >= 20 && relZ < 30) {
        signType = 'speed_80';
      } else if (biome.id === 'rusty_periphery' && relZ >= 130 && relZ < 140) {
        signType = 'industrial';
      } else if (biome.id === 'black_pine_woods' && relZ >= 270 && relZ < 280) {
        signType = 'wildlife';
      } else if (biome.id === 'flooded_marshland' && relZ >= 40 && relZ < 50) {
        signType = 'flood';
      } else if (biome.id === 'glass_crater' && relZ >= 30 && relZ < 40) {
        signType = 'radiation';
      } else if (biome.id === 'iron_gorge' && ((relZ >= 30 && relZ < 40) || (relZ >= 250 && relZ < 260))) {
        signType = 'rockfall';
      } else if (biome.id === 'permafrost_highlands' && relZ >= 30 && relZ < 40) {
        signType = 'ice';
      }

      if (signType) {
        this.spawnedMilestones.add(signKey);
        const signMesh = this.createRoadSign(
          roadInfo.x + halfW + 1.25,
          roadInfo.y,
          z,
          signType
        );
        this.scene.add(signMesh);
        this.props.push(signMesh);
      }
    }

    // 3. Streetlights - Illuminated settlement, bridge, and industrial sectors!
    const cycleZ = z % 3900;
    const isStreetlit =
      (cycleZ >= 80 && cycleZ <= 420) ||    // Sector 0: Fairbanks & Fox Junction
      (cycleZ >= 760 && cycleZ <= 1020) ||  // Sector 1: Yukon River Patton Bridge & Camp
      (cycleZ >= 1420 && cycleZ <= 1680) || // Sector 2: Coldfoot Truck Stop & Slate Creek
      (cycleZ >= 2080 && cycleZ <= 2360) || // Sector 3: Arctic Circle Checkpoint & Chandalar
      (cycleZ >= 2740 && cycleZ <= 2960) || // Sector 4: Atigun Pass High Camp & Valley
      (cycleZ >= 3380 && cycleZ <= 3850);   // Sector 5: Deadhorse Terminal Industrial Strip

    if (isStreetlit) {
      const lampInterval = 32;
      const lampIndex = Math.floor(z / lampInterval);
      const lampKey = `lamp_${lampIndex}`;
      if (!this.spawnedMilestones.has(lampKey) && (z % lampInterval) < 10) {
        this.spawnedMilestones.add(lampKey);
        // Alternate lamp side along highway to create realistic illuminated avenue
        const lampSide = (lampIndex % 2 === 0) ? -1 : 1;
        const lampX = roadInfo.x + lampSide * (halfW + 1.6);
        const lamp = this.createStreetlamp(
          lampX,
          roadInfo.y,
          z,
          lampSide
        );
        this.scene.add(lamp);
        this.props.push(lamp);
      }
    }

    // 4. Utility Power Poles - Deterministic single side, regular 36m spacing
    const hasPoles = (biome.id === 'rusty_periphery' || biome.id === 'black_pine_woods' || biome.id === 'iron_gorge');
    if (hasPoles) {
      const poleSide = (biome.id === 'black_pine_woods') ? -1 : 1;
      const poleIndex = Math.floor(z / 36);
      const poleKey = `pole_${poleIndex}`;
      if (!this.spawnedMilestones.has(poleKey) && (z % 36) < 10) {
        this.spawnedMilestones.add(poleKey);
        const pole = this.createPowerPole(
          roadInfo.x + poleSide * (halfW + 3.2),
          roadInfo.y,
          z,
          poleSide
        );
        this.scene.add(pole);
        this.props.push(pole);
      }
    }

    // 5. Arctic Snow Alignment Poles (Paline da Neve) - Only in Permafrost
    if (biome.id === 'permafrost_highlands') {
      const snowIndex = Math.floor(z / 22);
      const snowKey = `snow_${snowIndex}`;
      if (!this.spawnedMilestones.has(snowKey) && (z % 22) < 10) {
        this.spawnedMilestones.add(snowKey);
        // Left & Right pair flanking asphalt edges
        [-1, 1].forEach((side) => {
          const pole = this.createSnowPole(
            roadInfo.x + side * (halfW + 0.35),
            roadInfo.y,
            z
          );
          this.scene.add(pole);
          this.props.push(pole);
        });
      }
    }
  }

  spawnTerritorialClusterAt(z) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(z);
    const biome = this.biomeManager.currentBiome;
    const relZ = ((z % 650) + 650) % 650;
    const halfW = roadInfo.width * 0.5;
    if (!this.spawnedMilestones) this.spawnedMilestones = new Set();

    let propsToSpawn = [];

    if (biome.id === 'rusty_periphery') {
      // Zone 1 (0-130m): Farmland with split-rail fences on right side
      if (relZ < 130) {
        propsToSpawn.push(this.createSplitRailFence(roadInfo.x + halfW + 4.5, roadInfo.y, z));
        if (Math.random() < 0.45) {
          propsToSpawn.push(this.createGrassTuft(roadInfo.x - halfW - 2.0, roadInfo.y, z));
        }
      }
      // Zone 2 (130-330m): Concentrated Industrial Petrochemical Yard on Left (-X)
      else if (relZ >= 180 && relZ < 250) {
        const clusterKey = `refinery_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(clusterKey)) {
          this.spawnedMilestones.add(clusterKey);
          propsToSpawn.push(this.createRefineryCompound(roadInfo.x - halfW - 8.0, roadInfo.y, z));
        }
      }
      // Zone 3 (330-470m): Highway Interchange with Jersey Barriers
      else if (relZ >= 330 && relZ < 470) {
        [-1, 1].forEach((s) => {
          propsToSpawn.push(this.createJerseyBarrier(roadInfo.x + s * (halfW + 0.3), roadInfo.y, z));
        });
      }
      // Zone 4 (470-650m): Junkyard perimeter on Right (+X)
      else if (relZ >= 500 && relZ < 560) {
        const junkKey = `junk_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(junkKey)) {
          this.spawnedMilestones.add(junkKey);
          propsToSpawn.push(this.createJunkyardCluster(roadInfo.x + halfW + 7.0, roadInfo.y, z));
        }
      }
    } else if (biome.id === 'black_pine_woods') {
      // Natural Groves: Check if in clearings (160-220m or 420-480m)
      const isClearing = (relZ >= 160 && relZ <= 220) || (relZ >= 420 && relZ <= 480);
      if (isClearing) {
        // Alpine open meadow: grass and low rocks only, wide view of sky/mountains!
        propsToSpawn.push(this.createGrassTuft(roadInfo.x - halfW - 3.0, roadInfo.y, z));
        propsToSpawn.push(this.createGrassTuft(roadInfo.x + halfW + 3.0, roadInfo.y, z));
      } else if (relZ >= 300 && relZ <= 330) {
        // Forester Station Outpost (Single dedicated clearing at z ~ 315m)
        const outpostKey = `forester_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(outpostKey)) {
          this.spawnedMilestones.add(outpostKey);
          propsToSpawn.push(this.createForesterOutpost(roadInfo.x + halfW + 12.0, roadInfo.y, z));
        }
      } else {
        // Cohesive Forest Stands (Clusters of trees set back from road)
        [-1, 1].forEach((side) => {
          propsToSpawn.push(this.createForestStand(roadInfo.x + side * (halfW + 5.5), roadInfo.y, z, side));
        });
      }
    } else if (biome.id === 'flooded_marshland') {
      if (relZ >= 220 && relZ <= 270) {
        // Stilt Village Cluster on Left
        const villageKey = `stilt_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(villageKey)) {
          this.spawnedMilestones.add(villageKey);
          propsToSpawn.push(this.createStiltVillage(roadInfo.x - halfW - 8.0, roadInfo.y, z));
        }
      } else {
        // Dead cypress in water, reeds, and glowing spore clusters
        propsToSpawn.push(this.createSkeletalCypress(roadInfo.x - halfW - 7.0, roadInfo.y, z));
        propsToSpawn.push(this.createBioluminescentSpores(roadInfo.x + halfW + 4.5, roadInfo.y, z));
        propsToSpawn.push(this.createGrassTuft(roadInfo.x - halfW - 1.5, roadInfo.y, z));
      }
    } else if (biome.id === 'glass_crater') {
      if (relZ >= 280 && relZ <= 320) {
        // Ground Zero Anomalous Core
        const coreKey = `core_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(coreKey)) {
          this.spawnedMilestones.add(coreKey);
          propsToSpawn.push(this.createLevitatingAnomalousCore(roadInfo.x + halfW + 9.0, roadInfo.y, z));
        }
      } else {
        // Geological crystal vein clusters along impact fault line
        propsToSpawn.push(this.createCrystalCluster(roadInfo.x - halfW - 6.0, roadInfo.y, z));
        if (Math.random() < 0.4) {
          propsToSpawn.push(this.createCraterSpikeField(roadInfo.x + halfW + 5.0, roadInfo.y, z));
        }
      }
    } else if (biome.id === 'iron_gorge') {
      // Continuous Towering Red-Rock Canyon Mesa Walls on both sides!
      propsToSpawn.push(this.createCanyonCliff(roadInfo.x - halfW - 4.5, roadInfo.y, z, -1));
      propsToSpawn.push(this.createCanyonCliff(roadInfo.x + halfW + 4.5, roadInfo.y, z, 1));
      if (relZ >= 270 && relZ <= 290) {
        propsToSpawn.push(this.createBalancedRockHoodoo(roadInfo.x + halfW + 14.0, roadInfo.y, z));
      }
    } else if (biome.id === 'permafrost_highlands') {
      if (relZ >= 270 && relZ <= 310) {
        // Polar Research Weather Station
        const polarKey = `polar_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(polarKey)) {
          this.spawnedMilestones.add(polarKey);
          propsToSpawn.push(this.createArcticGeodesicDome(roadInfo.x + halfW + 10.0, roadInfo.y, z));
        }
      } else {
        // Wind-resistant snow conifer stands & ice spires
        propsToSpawn.push(this.createSnowCoveredPines(roadInfo.x - halfW - 6.0, roadInfo.y, z));
        propsToSpawn.push(this.createGlacialIceSpire(roadInfo.x + halfW + 5.5, roadInfo.y, z));
      }
    }

    propsToSpawn.forEach((p) => {
      if (p) {
        this.scene.add(p);
        this.props.push(p);
      }
    });
  }

  // --- HIGHWAY INFRASTRUCTURE: MILESTONES & REGULATORY SIGNAGE ---
  createMilestonePost(x, y, z, text) {
    const group = new THREE.Group();
    // Concrete pillar
    const post = new THREE.Mesh(
      new THREE.BoxGeometry(0.32, 0.85, 0.22),
      this.matMilestone
    );
    post.position.y = 0.42;
    post.castShadow = true;
    group.add(post);

    // Red highway jurisdiction top cap
    const cap = new THREE.Mesh(
      new THREE.BoxGeometry(0.34, 0.16, 0.24),
      this.matMilestoneCap
    );
    cap.position.y = 0.9;
    group.add(cap);

    // Black text plaque facing driver (+Z)
    const plaque = new THREE.Mesh(
      new THREE.BoxGeometry(0.24, 0.28, 0.02),
      this.matSignBorderBlack
    );
    plaque.position.set(0, 0.52, -0.115);
    group.add(plaque);

    group.position.set(x, y, z);
    return group;
  }

  createRoadSign(x, y, z, signType) {
    const group = new THREE.Group();
    // Galvanized steel post
    const post = new THREE.Mesh(
      new THREE.CylinderGeometry(0.04, 0.04, 2.4, 6),
      this.matSignPost
    );
    post.position.y = 1.2;
    post.castShadow = true;
    group.add(post);

    let plate = null;
    let symbol = null;

    if (signType === 'speed_80') {
      // Circular European/International speed limit sign
      plate = new THREE.Mesh(
        new THREE.CylinderGeometry(0.48, 0.48, 0.04, 16),
        this.matSignPlateWhite
      );
      plate.rotation.x = Math.PI / 2;
      plate.position.set(0, 2.15, -0.04);
      group.add(plate);

      // Red border ring
      const ring = new THREE.Mesh(
        new THREE.TorusGeometry(0.44, 0.05, 4, 16),
        this.matSignSymbolRed
      );
      ring.position.set(0, 2.15, -0.06);
      group.add(ring);

      // Black "80" numerals bar
      symbol = new THREE.Mesh(
        new THREE.BoxGeometry(0.35, 0.22, 0.02),
        this.matSignBorderBlack
      );
      symbol.position.set(0, 2.15, -0.065);
      group.add(symbol);

    } else if (signType === 'ice') {
      // Blue triangular snowflake warning sign
      plate = new THREE.Mesh(
        new THREE.ConeGeometry(0.55, 0.75, 3),
        this.matSignPlateBlue
      );
      plate.position.set(0, 2.15, -0.04);
      plate.rotation.x = Math.PI;
      group.add(plate);

      // White snowflake center
      symbol = new THREE.Mesh(
        new THREE.BoxGeometry(0.24, 0.24, 0.02),
        this.matSignPlateWhite
      );
      symbol.position.set(0, 2.12, -0.06);
      group.add(symbol);

    } else {
      // Diamond yellow caution sign (industrial, wildlife, rockfall, flood, radiation)
      plate = new THREE.Mesh(
        new THREE.BoxGeometry(0.68, 0.68, 0.03),
        (signType === 'radiation') ? this.matSignPlateYellow : this.matSignPlateYellow
      );
      plate.rotation.z = Math.PI / 4;
      plate.position.set(0, 2.15, -0.04);
      group.add(plate);

      // Black inner hazard border
      const innerBorder = new THREE.Mesh(
        new THREE.BoxGeometry(0.58, 0.58, 0.035),
        this.matSignBorderBlack
      );
      innerBorder.rotation.z = Math.PI / 4;
      innerBorder.position.set(0, 2.15, -0.045);
      group.add(innerBorder);

      // Black symbol glyph
      symbol = new THREE.Mesh(
        new THREE.BoxGeometry(0.32, 0.32, 0.04),
        (signType === 'radiation') ? this.matSignSymbolRed : this.matSignPlateYellow
      );
      symbol.rotation.z = Math.PI / 4;
      symbol.position.set(0, 2.15, -0.05);
      group.add(symbol);
    }

    group.position.set(x, y, z);
    return group;
  }

  createSnowPole(x, y, z) {
    const group = new THREE.Group();
    // 2.4m tall arctic road snow marker stick with alternating red/white stripes
    const height = 2.4;
    const segments = 6;
    const segH = height / segments;

    for (let i = 0; i < segments; i++) {
      const mat = (i % 2 === 0) ? this.matSnowPoleRed : this.matSnowPoleWhite;
      const seg = new THREE.Mesh(
        new THREE.CylinderGeometry(0.035, 0.035, segH, 6),
        mat
      );
      seg.position.y = i * segH + segH * 0.5;
      group.add(seg);
    }

    group.position.set(x, y, z);
    return group;
  }

  createSplitRailFence(x, y, z) {
    const group = new THREE.Group();
    // Weathered rural wooden fence module (length 7m)
    [-3.2, 3.2].forEach((px) => {
      const post = new THREE.Mesh(
        new THREE.BoxGeometry(0.18, 1.35, 0.18),
        this.matFence
      );
      post.position.set(0, 0.65, px);
      post.castShadow = true;
      group.add(post);
    });

    // 2 horizontal cedar rails
    [0.45, 0.95].forEach((ry) => {
      const rail = new THREE.Mesh(
        new THREE.BoxGeometry(0.12, 0.12, 6.8),
        this.matFence
      );
      rail.position.set(0, ry, 0);
      rail.castShadow = true;
      group.add(rail);
    });

    group.position.set(x, y, z);
    return group;
  }

  createJerseyBarrier(x, y, z) {
    const group = new THREE.Group();
    // Highway concrete jersey barrier (trapezoidal profile, length 4m)
    const barrier = new THREE.Mesh(
      new THREE.BoxGeometry(0.45, 0.85, 3.9),
      this.matJersey
    );
    barrier.position.y = 0.42;
    barrier.castShadow = true;
    group.add(barrier);

    // Red-white reflective tape along upper edge
    const tape = new THREE.Mesh(
      new THREE.BoxGeometry(0.47, 0.12, 3.9),
      this.matSnowPoleRed
    );
    tape.position.y = 0.75;
    group.add(tape);

    group.position.set(x, y, z);
    return group;
  }

  // --- COHERENT TERRITORIAL COMPOUNDS ---
  createRefineryCompound(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // 1. Crushed gravel apron base
    const pad = new THREE.Mesh(
      new THREE.BoxGeometry(16, 0.15, 24),
      new THREE.MeshStandardMaterial({ color: 0x332a22, roughness: 0.95 })
    );
    pad.position.set(-4, 0.05, 0);
    pad.receiveShadow = true;
    group.add(pad);

    // 2. Cluster of 3 Cylindrical Fuel Storage Tanks in berm
    [-5, 0, 5].forEach((offsetZ, idx) => {
      const tank = new THREE.Mesh(
        new THREE.CylinderGeometry(3.6, 3.6, 6.5, 12),
        this.matRustedMetal
      );
      tank.position.set(-6 - (idx % 2) * 2, 3.3, offsetZ);
      tank.castShadow = true;
      group.add(tank);

      // Yellow hazard band
      const band = new THREE.Mesh(
        new THREE.CylinderGeometry(3.65, 3.65, 0.4, 12),
        this.matSignPlateYellow
      );
      band.position.set(-6 - (idx % 2) * 2, 4.0, offsetZ);
      group.add(band);
    });

    // 3. Overhead Industrial Pipeline Rack spanning across yard
    const pipe = new THREE.Mesh(
      new THREE.CylinderGeometry(0.3, 0.3, 18, 8),
      this.matRustedMetal
    );
    pipe.position.set(-3, 5.5, 0);
    pipe.rotation.x = Math.PI / 2;
    group.add(pipe);

    // 4. Two Flare Stacks with burning gas flames
    [-9, 9].forEach((flareZ) => {
      const flare = new THREE.Mesh(
        new THREE.CylinderGeometry(0.4, 0.7, 14, 6),
        this.matRustedMetal
      );
      flare.position.set(-10, 7.0, flareZ);
      flare.castShadow = true;
      group.add(flare);

      const flame = new THREE.Mesh(
        new THREE.ConeGeometry(0.8, 2.2, 5),
        new THREE.MeshBasicMaterial({ color: 0xff6600 })
      );
      flame.position.set(-10, 15.1, flareZ);
      group.add(flame);

      const fLight = new THREE.PointLight(0xff6600, 2.0, 24);
      fLight.position.set(-10, 15.1, flareZ);
      group.add(fLight);
    });

    // 5. Chain-link Security Fence along road frontage
    const fence = new THREE.Mesh(
      new THREE.BoxGeometry(0.1, 2.2, 24),
      new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.8, wireframe: true })
    );
    fence.position.set(3.5, 1.1, 0);
    group.add(fence);

    return group;
  }

  createForestStand(x, y, z, side) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // A rich, diverse northern stand of 6-8 conifers and birch trees
    const treeCount = 6 + Math.floor(Math.random() * 3);
    for (let t = 0; t < treeCount; t++) {
      const offsetX = (Math.random() - 0.5) * 9.0 + side * (t * 1.6);
      const offsetZ = (Math.random() - 0.5) * 18.0;
      const heightScale = 0.85 + Math.random() * 0.55;

      // 70% Alaskan Spruce, 30% Paper Birch
      const isBirch = Math.random() < 0.32;
      const tree = isBirch
        ? this.createBirchTree(offsetX, 0, offsetZ)
        : this.createPineTree(offsetX, 0, offsetZ);

      tree.scale.setScalar(heightScale);
      group.add(tree);
    }

    // Natural mossy granite rock outcropping at tree stand base
    const rock = this.createRock(side * 2.5, 0, (Math.random() - 0.5) * 5.0, 1.8);
    group.add(rock);

    // Fallen decaying moss log on forest floor
    const log = new THREE.Mesh(
      new THREE.CylinderGeometry(0.18, 0.22, 3.2, 5),
      this.matTrunk
    );
    log.rotation.z = Math.PI / 2;
    log.rotation.y = Math.random() * Math.PI;
    log.position.set(side * 3.0, 0.18, (Math.random() - 0.5) * 4.0);
    log.castShadow = true;
    group.add(log);

    return group;
  }

  createForesterOutpost(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Gravel clearing
    const clearing = new THREE.Mesh(
      new THREE.CylinderGeometry(14, 15, 0.15, 12),
      new THREE.MeshStandardMaterial({ color: 0x3d3224, roughness: 0.95 })
    );
    clearing.position.y = 0.05;
    group.add(clearing);

    // Wooden Fire Watchtower (16m)
    const tower = this.createForesterTower(0, 0, 0);
    group.add(tower);

    // Log cabin sleeping quarters
    const cabin = this.createLumberCabin(-7, 0, -4);
    group.add(cabin);

    // Stacked firewood logs
    const woodpile = new THREE.Mesh(
      new THREE.BoxGeometry(1.6, 1.2, 3.2),
      this.matWoodLog
    );
    woodpile.position.set(6, 0.6, 4);
    group.add(woodpile);

    return group;
  }

  createStiltVillage(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Wooden boardwalk pier running along water
    const pier = new THREE.Mesh(
      new THREE.BoxGeometry(2.4, 0.4, 26),
      this.matWoodLog
    );
    pier.position.set(0, 1.6, 0);
    group.add(pier);

    // 3 Stilt huts connected to the boardwalk
    [-8, 0, 8].forEach((offZ) => {
      const hut = this.createSwampStiltHut(-5, 0, offZ);
      group.add(hut);
    });

    return group;
  }

  createCrystalCluster(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Cluster of 4-6 crystal needles in a geode formation
    const count = 4 + Math.floor(Math.random() * 3);
    for (let c = 0; c < count; c++) {
      const offX = (Math.random() - 0.5) * 4.5;
      const offZ = (Math.random() - 0.5) * 4.5;
      const spire = this.createCrystalSpire(offX, 0, offZ);
      group.add(spire);
    }

    return group;
  }

  createJunkyardCluster(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Perimeter of stacked cargo containers and derelict trucks
    [-8, 0, 8].forEach((offZ, idx) => {
      const container = new THREE.Mesh(
        new THREE.BoxGeometry(2.6, 2.6, 6.2),
        new THREE.MeshStandardMaterial({
          color: (idx === 0) ? 0xb91c1c : (idx === 1) ? 0x0284c7 : 0x78716c,
          roughness: 0.7,
          metalness: 0.6
        })
      );
      container.position.set(4, 1.3, offZ);
      container.castShadow = true;
      group.add(container);
    });

    const wreck = this.createWreck(-1, 0, 0);
    group.add(wreck);

    return group;
  }

  createStreetlamp(x, y, z, side) {
    const group = new THREE.Group();
    const pole = new THREE.Mesh(this.geoPole, this.matPole);
    pole.position.y = 3.75;
    pole.castShadow = true;
    group.add(pole);

    // Overhanging curved boom arm extending over the road shoulder
    const armReach = 2.4;
    const armOffsetX = side > 0 ? -armReach * 0.5 : armReach * 0.5;
    const arm = new THREE.Mesh(new THREE.BoxGeometry(armReach, 0.16, 0.16), this.matPole);
    arm.position.set(armOffsetX, 7.3, 0);
    group.add(arm);

    // Diagonal support strut
    const strut = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.04, 1.6, 4), this.matPole);
    strut.position.set(side > 0 ? -0.8 : 0.8, 6.7, 0);
    strut.rotation.z = side > 0 ? 0.7 : -0.7;
    group.add(strut);

    // Heavy-duty sodium luminaire head
    const lampHeadX = side > 0 ? -armReach : armReach;
    const lampHead = new THREE.Mesh(
      new THREE.BoxGeometry(0.8, 0.28, 0.45),
      new THREE.MeshStandardMaterial({ color: 0x1f2937, metalness: 0.85, roughness: 0.3 })
    );
    lampHead.position.set(lampHeadX, 7.25, 0);
    group.add(lampHead);

    // Bright amber high-pressure sodium emitter bulb
    const emitter = new THREE.Mesh(
      new THREE.BoxGeometry(0.65, 0.08, 0.35),
      new THREE.MeshBasicMaterial({ color: 0xffb84d })
    );
    emitter.position.set(lampHeadX, 7.1, 0);
    group.add(emitter);

    // Volumetric sodium atmospheric light cone pool
    const coneGeo = new THREE.ConeGeometry(3.6, 7.0, 8, 1, true);
    coneGeo.translate(0, -3.5, 0);
    const coneMat = new THREE.MeshBasicMaterial({
      color: 0xffaa33,
      transparent: true,
      opacity: 0.12,
      blending: THREE.AdditiveBlending,
      side: THREE.DoubleSide,
      depthWrite: false
    });
    const lightCone = new THREE.Mesh(coneGeo, coneMat);
    lightCone.position.set(lampHeadX, 7.1, 0);
    group.add(lightCone);

    // High-Pressure Sodium SpotLight bathing asphalt in amber glow
    const light = new THREE.SpotLight(0xffb347, 4.6, 38, Math.PI / 3.4, 0.65, 1.2);
    light.position.set(lampHeadX, 7.0, 0);
    light.target.position.set(lampHeadX * 0.4, 0, 0);
    light.castShadow = false; // Preserves high framerate
    group.add(light);
    group.add(light.target);

    group.position.set(x, y, z);
    return group;
  }

  createGrassTuft(x, y, z) {
    const group = new THREE.Group();
    const grassMat = new THREE.MeshStandardMaterial({ color: 0x27432b, roughness: 0.9 });
    for (let b = 0; b < 4; b++) {
      const blade = new THREE.Mesh(new THREE.ConeGeometry(0.12, 0.9 + Math.random() * 0.4, 4), grassMat);
      blade.position.set((Math.random() - 0.5) * 0.4, 0.45, (Math.random() - 0.5) * 0.4);
      blade.rotation.z = (Math.random() - 0.5) * 0.4;
      group.add(blade);
    }
    group.position.set(x, y, z);
    return group;
  }

  createPineTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.55;

    const trunk = new THREE.Mesh(this.geoTrunk, this.matTrunk);
    trunk.position.y = 1.9;
    trunk.castShadow = true;
    group.add(trunk);

    // Multi-tier tiered pine foliage
    const tiers = [
      { y: 4.6, s: 1.0, mat: this.matPine1 },
      { y: 6.2, s: 0.82, mat: this.matPine2 },
      { y: 7.6, s: 0.62, mat: this.matPine1 }
    ];

    tiers.forEach((t) => {
      const cone = new THREE.Mesh(this.geoPineCone, t.mat);
      cone.position.y = t.y;
      cone.scale.set(t.s, t.s, t.s);
      cone.castShadow = true;
      group.add(cone);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createBirchTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.45;
    const trunkMat = new THREE.MeshStandardMaterial({ color: 0xdedede, roughness: 0.85 }); // White paper birch bark
    const foliageMat = new THREE.MeshStandardMaterial({ color: 0x82945b, roughness: 0.88 }); // Golden-sage northern foliage

    const trunk = new THREE.Mesh(new THREE.CylinderGeometry(0.16, 0.24, 4.6, 6), trunkMat);
    trunk.position.y = 2.3;
    trunk.castShadow = true;
    group.add(trunk);

    // Multi-cluster rounded birch crown
    for (let c = 0; c < 3; c++) {
      const cluster = new THREE.Mesh(
        new THREE.DodecahedronGeometry(1.35 - c * 0.22, 1),
        foliageMat
      );
      cluster.position.set((Math.random() - 0.5) * 0.7, 4.4 + c * 1.15, (Math.random() - 0.5) * 0.7);
      cluster.castShadow = true;
      group.add(cluster);
    }

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createRock(x, y, z, scaleMultiplier = 1.0) {
    const mesh = new THREE.Mesh(this.geoRock, this.matRock);
    const s = (0.75 + Math.random() * 0.7) * scaleMultiplier;
    mesh.scale.set(s * (0.8 + Math.random() * 0.5), s, s * (0.8 + Math.random() * 0.5));
    mesh.position.set(x, y + s * 0.6, z);
    mesh.rotation.set(Math.random() * 2, Math.random() * 2, Math.random() * 2);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    return mesh;
  }

  createPowerPole(x, y, z, side) {
    const group = new THREE.Group();
    const pole = new THREE.Mesh(this.geoPole, this.matPole);
    pole.position.y = 3.75;
    pole.castShadow = true;
    group.add(pole);

    const crossArm = new THREE.Mesh(this.geoCrossArm, this.matPole);
    crossArm.position.y = 6.6;
    crossArm.castShadow = true;
    group.add(crossArm);

    // Ceramic insulators
    [-1.0, 1.0].forEach((ix) => {
      const ins = new THREE.Mesh(
        new THREE.CylinderGeometry(0.08, 0.08, 0.25, 6),
        new THREE.MeshStandardMaterial({ color: 0x94a3b8, metalness: 0.8 })
      );
      ins.position.set(ix, 6.8, 0);
      group.add(ins);
    });

    // Hanging Power Line Wire connecting to previous pole on same side
    if (this.lastPolePos && this.lastPolePos.side === side && (z - this.lastPolePos.z) < 55) {
      const p1 = new THREE.Vector3(this.lastPolePos.x - x, 6.7, this.lastPolePos.z - z);
      const p2 = new THREE.Vector3(0, 6.7, 0);
      const mid = p1.clone().add(p2).multiplyScalar(0.5);
      mid.y -= 1.8; // Catenary sag

      const curve = new THREE.QuadraticBezierCurve3(p1, mid, p2);
      const wirePoints = curve.getPoints(12);
      const wireGeo = new THREE.BufferGeometry().setFromPoints(wirePoints);
      const wireLine = new THREE.Line(wireGeo, this.matWire);
      group.add(wireLine);
    }

    this.lastPolePos = { x, y, z, side };

    group.position.set(x, y, z);
    return group;
  }

  createBillboard(x, y, z, side) {
    const group = new THREE.Group();
    const pole1 = new THREE.Mesh(this.geoPole, this.matPole);
    pole1.scale.set(1, 0.75, 1);
    pole1.position.set(-2.0, 2.5, 0);
    pole1.castShadow = true;
    group.add(pole1);

    const pole2 = new THREE.Mesh(this.geoPole, this.matPole);
    pole2.scale.set(1, 0.75, 1);
    pole2.position.set(2.0, 2.5, 0);
    pole2.castShadow = true;
    group.add(pole2);

    const board = new THREE.Mesh(new THREE.BoxGeometry(5.2, 2.4, 0.18), this.matBillboard);
    board.position.set(0, 4.4, 0);
    board.castShadow = true;
    group.add(board);

    // Hazard stripe trim on billboard edge
    const trim = new THREE.Mesh(
      new THREE.BoxGeometry(5.3, 0.2, 0.22),
      new THREE.MeshStandardMaterial({ color: 0xf59e0b, roughness: 0.5 })
    );
    trim.position.set(0, 3.2, 0);
    group.add(trim);

    group.position.set(x, y, z);
    group.rotation.y = side > 0 ? -0.28 : 0.28;
    return group;
  }

  createWreck(x, y, z) {
    const group = new THREE.Group();
    const body = new THREE.Mesh(new THREE.BoxGeometry(2.1, 1.0, 4.4), this.matWreck);
    body.position.y = 0.55;
    body.castShadow = true;
    group.add(body);

    const cabin = new THREE.Mesh(new THREE.BoxGeometry(1.75, 0.75, 2.1), this.matWreck);
    cabin.position.set(0, 1.35, -0.4);
    cabin.castShadow = true;
    group.add(cabin);

    group.position.set(x, y, z);
    group.rotation.y = (Math.random() - 0.5) * 1.4;
    group.rotation.z = (Math.random() - 0.5) * 0.2;
    return group;
  }

  // --- RUSTY PERIPHERY STRUCTURES ---
  createFlareStack(x, y, z) {
    const group = new THREE.Group();
    // Tall industrial exhaust stack
    const stack = new THREE.Mesh(
      new THREE.CylinderGeometry(0.5, 0.9, 15, 8),
      this.matRustedMetal
    );
    stack.position.y = 7.5;
    stack.castShadow = true;
    group.add(stack);

    // Tip ring
    const ring = new THREE.Mesh(
      new THREE.CylinderGeometry(0.8, 0.8, 0.4, 8),
      this.matRustedMetal
    );
    ring.position.y = 15;
    group.add(ring);

    // Dynamic flare gas flame
    const flame = new THREE.Mesh(
      new THREE.ConeGeometry(0.9, 2.5, 6),
      new THREE.MeshBasicMaterial({ color: 0xff6600 })
    );
    flame.position.y = 16.5;
    group.add(flame);

    const flareLight = new THREE.PointLight(0xff6600, 2.2, 28);
    flareLight.position.y = 16.5;
    group.add(flareLight);

    group.position.set(x, y, z);
    return group;
  }

  createFuelStorageTank(x, y, z) {
    const group = new THREE.Group();
    // Massive cylindrical fuel silo
    const tank = new THREE.Mesh(
      new THREE.CylinderGeometry(4.2, 4.2, 7.0, 14),
      this.matRustedMetal
    );
    tank.position.y = 3.5;
    tank.castShadow = true;
    group.add(tank);

    // Domed top cap
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(4.2, 14, 8, 0, Math.PI * 2, 0, Math.PI * 0.35),
      this.matRustedMetal
    );
    dome.position.y = 7.0;
    dome.rotation.x = Math.PI;
    group.add(dome);

    // Yellow hazard warning band
    const band = new THREE.Mesh(
      new THREE.CylinderGeometry(4.25, 4.25, 0.5, 14),
      new THREE.MeshStandardMaterial({ color: 0xf59e0b, roughness: 0.6 })
    );
    band.position.y = 4.2;
    group.add(band);

    group.position.set(x, y, z);
    return group;
  }

  // --- BLACK PINE WOODS STRUCTURES ---
  createForesterTower(x, y, z) {
    const group = new THREE.Group();
    // 4 Splayed wooden stilts
    const legGeo = new THREE.CylinderGeometry(0.18, 0.25, 15, 5);
    [-1.6, 1.6].forEach((lx) => {
      [-1.6, 1.6].forEach((lz) => {
        const leg = new THREE.Mesh(legGeo, this.matWoodLog);
        leg.position.set(lx, 7.5, lz);
        leg.castShadow = true;
        group.add(leg);
      });
    });

    // Cabin platform
    const platform = new THREE.Mesh(
      new THREE.BoxGeometry(4.5, 0.4, 4.5),
      this.matWoodLog
    );
    platform.position.y = 15;
    group.add(platform);

    // Cabin house
    const cabin = new THREE.Mesh(
      new THREE.BoxGeometry(3.6, 2.6, 3.6),
      this.matWoodLog
    );
    cabin.position.y = 16.5;
    group.add(cabin);

    // Warm lantern window glowing inside
    const windowGlow = new THREE.Mesh(
      new THREE.BoxGeometry(1.2, 0.9, 3.7),
      this.matAmberGlow
    );
    windowGlow.position.y = 16.6;
    group.add(windowGlow);

    const light = new THREE.PointLight(0xf59e0b, 1.8, 22);
    light.position.y = 16.5;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createAncientPine(x, y, z) {
    const group = new THREE.Group();
    // Gargantuan ancient conifer
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.8, 1.3, 7.0, 7),
      this.matTrunk
    );
    trunk.position.y = 3.5;
    trunk.castShadow = true;
    group.add(trunk);

    const tiers = [
      { y: 8.5, r: 4.8, h: 6.5, mat: this.matPine1 },
      { y: 12.5, r: 3.8, h: 5.5, mat: this.matPine2 },
      { y: 16.0, r: 2.8, h: 4.5, mat: this.matPine1 },
      { y: 19.0, r: 1.8, h: 3.5, mat: this.matPine2 }
    ];

    tiers.forEach((t) => {
      const cone = new THREE.Mesh(new THREE.ConeGeometry(t.r, t.h, 7), t.mat);
      cone.position.y = t.y;
      cone.castShadow = true;
      group.add(cone);
    });

    group.position.set(x, y, z);
    return group;
  }

  createLumberCabin(x, y, z) {
    const group = new THREE.Group();
    const walls = new THREE.Mesh(
      new THREE.BoxGeometry(5.2, 2.8, 4.2),
      this.matWoodLog
    );
    walls.position.y = 1.4;
    walls.castShadow = true;
    group.add(walls);

    // Sloped roof
    const roof = new THREE.Mesh(
      new THREE.ConeGeometry(3.8, 2.2, 4),
      new THREE.MeshStandardMaterial({ color: 0x221a14, roughness: 0.9 })
    );
    roof.position.y = 3.8;
    roof.rotation.y = Math.PI / 4;
    roof.castShadow = true;
    group.add(roof);

    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  // --- FLOODED MARSHLAND STRUCTURES ---
  createSwampStiltHut(x, y, z) {
    const group = new THREE.Group();
    // Elevated stilts over marsh water
    const legGeo = new THREE.CylinderGeometry(0.12, 0.15, 3.2, 5);
    [-1.2, 1.2].forEach((lx) => {
      [-1.2, 1.2].forEach((lz) => {
        const leg = new THREE.Mesh(legGeo, this.matWoodLog);
        leg.position.set(lx, 1.6, lz);
        group.add(leg);
      });
    });

    const hut = new THREE.Mesh(
      new THREE.BoxGeometry(3.0, 2.0, 2.8),
      this.matWoodLog
    );
    hut.position.y = 4.2;
    hut.castShadow = true;
    group.add(hut);

    // Swamp lantern hanging
    const lantern = new THREE.Mesh(
      new THREE.SphereGeometry(0.2, 6, 6),
      this.matAmberGlow
    );
    lantern.position.set(1.6, 3.6, 0);
    group.add(lantern);

    const light = new THREE.PointLight(0xffaa22, 1.5, 16);
    light.position.set(1.6, 3.6, 0);
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createSkeletalCypress(x, y, z) {
    const group = new THREE.Group();
    // Dead twisted cypress
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.35, 0.7, 5.5, 6),
      new THREE.MeshStandardMaterial({ color: 0x282624, roughness: 0.95 })
    );
    trunk.position.y = 2.75;
    trunk.rotation.z = (Math.random() - 0.5) * 0.3;
    trunk.castShadow = true;
    group.add(trunk);

    // Skeletal bare branches
    for (let b = 0; b < 4; b++) {
      const branch = new THREE.Mesh(
        new THREE.CylinderGeometry(0.08, 0.15, 2.4, 4),
        new THREE.MeshStandardMaterial({ color: 0x282624, roughness: 0.95 })
      );
      branch.position.set((Math.random() - 0.5) * 1.2, 4.2 + b * 0.4, (Math.random() - 0.5) * 1.2);
      branch.rotation.z = (Math.random() - 0.5) * 1.2;
      branch.rotation.y = Math.random() * Math.PI * 2;
      group.add(branch);
    }

    group.position.set(x, y, z);
    return group;
  }

  createBioluminescentSpores(x, y, z) {
    const group = new THREE.Group();
    // Cluster of glowing swamp fungal pods
    for (let s = 0; s < 5; s++) {
      const spore = new THREE.Mesh(
        new THREE.SphereGeometry(0.25 + Math.random() * 0.2, 6, 6),
        this.matCrystalCyan
      );
      spore.position.set((Math.random() - 0.5) * 1.5, 0.35 + Math.random() * 0.4, (Math.random() - 0.5) * 1.5);
      group.add(spore);
    }
    const glow = new THREE.PointLight(0x06b6d4, 1.2, 10);
    glow.position.y = 0.8;
    group.add(glow);

    group.position.set(x, y, z);
    return group;
  }

  // --- GLASS CRATER STRUCTURES ---
  createCrystalSpire(x, y, z) {
    const group = new THREE.Group();
    const height = 7.5 + Math.random() * 6.0;
    const isMagenta = Math.random() < 0.5;
    const crystalMat = isMagenta ? this.matCrystalMagenta : this.matCrystalCyan;
    const lightColor = isMagenta ? 0xd946ef : 0x06b6d4;

    // Faceted hexagonal crystal needle
    const spire = new THREE.Mesh(
      new THREE.CylinderGeometry(0.2, 1.2, height, 5),
      crystalMat
    );
    spire.position.y = height * 0.48;
    spire.rotation.x = (Math.random() - 0.5) * 0.25;
    spire.rotation.z = (Math.random() - 0.5) * 0.25;
    spire.castShadow = true;
    group.add(spire);

    // Glowing point light casting vivid colored aura onto surroundings
    const light = new THREE.PointLight(lightColor, 2.0, 20);
    light.position.y = height * 0.65;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createLevitatingAnomalousCore(x, y, z) {
    const group = new THREE.Group();
    // Levitating octahedron core hovering at 3.5m height
    const core = new THREE.Mesh(
      new THREE.OctahedronGeometry(1.2, 0),
      this.matCrystalMagenta
    );
    core.position.y = 3.5;
    group.add(core);

    // Outer metallic containment ring
    const ring = new THREE.Mesh(
      new THREE.TorusGeometry(2.4, 0.12, 6, 16),
      new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.9 })
    );
    ring.position.y = 3.5;
    ring.rotation.x = Math.PI / 3;
    group.add(ring);

    const light = new THREE.PointLight(0xd946ef, 2.2, 22);
    light.position.y = 3.5;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createCraterSpikeField(x, y, z) {
    const group = new THREE.Group();
    for (let i = 0; i < 6; i++) {
      const needle = new THREE.Mesh(
        new THREE.ConeGeometry(0.25, 3.5 + Math.random() * 2.5, 4),
        this.matCrystalCyan
      );
      needle.position.set((Math.random() - 0.5) * 2.2, 1.6, (Math.random() - 0.5) * 2.2);
      needle.rotation.x = (Math.random() - 0.5) * 0.7;
      needle.rotation.z = (Math.random() - 0.5) * 0.7;
      group.add(needle);
    }
    group.position.set(x, y, z);
    return group;
  }

  // --- IRON GORGE STRUCTURES ---
  createCanyonCliff(x, y, z, side) {
    const group = new THREE.Group();
    // Monumental stepped red-rock canyon mesa wall flanking roadway
    const height = 28 + Math.random() * 10;
    const width = 16 + Math.random() * 8;
    const depth = 14;

    const mesa = new THREE.Mesh(
      new THREE.BoxGeometry(width, height, depth),
      this.matRedRock
    );
    mesa.position.y = height * 0.5 - 1.0;
    mesa.castShadow = true;
    mesa.receiveShadow = true;
    group.add(mesa);

    // Top jagged pinnacle
    const pinnacle = new THREE.Mesh(
      new THREE.ConeGeometry(width * 0.35, 8.0, 5),
      this.matRedRock
    );
    pinnacle.position.set((Math.random() - 0.5) * 4, height + 3.0, (Math.random() - 0.5) * 3);
    pinnacle.castShadow = true;
    group.add(pinnacle);

    group.position.set(x, y, z);
    return group;
  }

  createBalancedRockHoodoo(x, y, z) {
    const group = new THREE.Group();
    // Slender pillar
    const pillar = new THREE.Mesh(
      new THREE.CylinderGeometry(0.8, 1.6, 9.5, 6),
      this.matRedRock
    );
    pillar.position.y = 4.75;
    pillar.castShadow = true;
    group.add(pillar);

    // Giant balancing boulder on summit
    const boulder = new THREE.Mesh(
      new THREE.DodecahedronGeometry(2.4, 1),
      this.matRedRock
    );
    boulder.position.y = 10.8;
    boulder.scale.set(1.3, 0.9, 1.1);
    boulder.castShadow = true;
    group.add(boulder);

    group.position.set(x, y, z);
    return group;
  }

  // --- PERMAFROST HIGHLANDS STRUCTURES ---
  createSnowCoveredPines(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    const trunk = new THREE.Mesh(this.geoTrunk, this.matTrunk);
    trunk.position.y = 1.9;
    trunk.castShadow = true;
    group.add(trunk);

    const tiers = [
      { y: 4.6, s: 1.0 },
      { y: 6.2, s: 0.8 },
      { y: 7.6, s: 0.6 }
    ];

    tiers.forEach((t) => {
      // Dark green under foliage
      const cone = new THREE.Mesh(this.geoPineCone, this.matPine1);
      cone.position.y = t.y;
      cone.scale.set(t.s, t.s, t.s);
      cone.castShadow = true;
      group.add(cone);

      // White snow blanket cap on top of cone
      const snowCap = new THREE.Mesh(new THREE.ConeGeometry(2.02, 1.8, 6), this.matSnow);
      snowCap.position.y = t.y + 1.2 * t.s;
      snowCap.scale.set(t.s * 0.95, t.s * 0.95, t.s * 0.95);
      snowCap.castShadow = true;
      group.add(snowCap);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createGlacialIceSpire(x, y, z) {
    const group = new THREE.Group();
    const height = 5.5 + Math.random() * 4.5;
    const spire = new THREE.Mesh(
      new THREE.CylinderGeometry(0.1, 1.4, height, 5),
      this.matIce
    );
    spire.position.y = height * 0.48;
    spire.rotation.x = (Math.random() - 0.5) * 0.2;
    spire.rotation.z = (Math.random() - 0.5) * 0.2;
    spire.castShadow = true;
    group.add(spire);

    const light = new THREE.PointLight(0xa5f3fc, 1.4, 15);
    light.position.y = height * 0.6;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createArcticGeodesicDome(x, y, z) {
    const group = new THREE.Group();
    // Geodesic expedition shelter
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(3.6, 10, 8, 0, Math.PI * 2, 0, Math.PI * 0.5),
      new THREE.MeshStandardMaterial({ color: 0xe2e8f0, roughness: 0.7 })
    );
    dome.position.y = 0;
    dome.castShadow = true;
    group.add(dome);

    // Warm illuminated entry tunnel
    const entry = new THREE.Mesh(
      new THREE.BoxGeometry(1.6, 1.8, 2.2),
      new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.8 })
    );
    entry.position.set(0, 0.9, 3.2);
    group.add(entry);

    // Glowing warm amber portal
    const portal = new THREE.Mesh(
      new THREE.PlaneGeometry(1.2, 1.4),
      this.matAmberGlow
    );
    portal.position.set(0, 0.9, 4.31);
    group.add(portal);

    const light = new THREE.PointLight(0xf59e0b, 1.8, 18);
    light.position.set(0, 1.2, 4.5);
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }
}
