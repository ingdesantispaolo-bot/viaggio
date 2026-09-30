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
    [this.geoTrunk, this.geoPineCone, this.geoRock, this.geoPole, this.geoCrossArm].forEach((g) => {
      if (g) g.userData.isShared = true;
    });

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

    // Mediterranean Coast Materials
    this.matOliveFoliage = new THREE.MeshStandardMaterial({ color: 0x5a6b38, roughness: 0.86 });
    this.matMaritimePineFoliage = new THREE.MeshStandardMaterial({ color: 0x1d3824, roughness: 0.88 });
    this.matStoneWall = new THREE.MeshStandardMaterial({ color: 0x9e9382, roughness: 0.96 });

    // Temperate Forest Materials
    this.matDeciduousOak = new THREE.MeshStandardMaterial({ color: 0x275924, roughness: 0.85 });
    this.matBeechFoliage = new THREE.MeshStandardMaterial({ color: 0x366e2c, roughness: 0.84 });

    // Arid Desert Materials
    this.matDuneSand = new THREE.MeshStandardMaterial({ color: 0xc99452, roughness: 0.96 });
    this.matPalmTrunk = new THREE.MeshStandardMaterial({ color: 0x54402e, roughness: 0.92 });
    this.matPalmFronds = new THREE.MeshStandardMaterial({ color: 0x396324, roughness: 0.82 });
    this.matAdobe = new THREE.MeshStandardMaterial({ color: 0xb3825a, roughness: 0.96 });

    // Savanna & Steppe Materials
    this.matAcaciaCanopy = new THREE.MeshStandardMaterial({ color: 0x526b34, roughness: 0.88 });
    this.matBaobabTrunk = new THREE.MeshStandardMaterial({ color: 0x695747, roughness: 0.92 });
    this.matSavannaGrass = new THREE.MeshStandardMaterial({ color: 0xc2a452, roughness: 0.95 });

    // Tropical Rainforest Materials
    this.matJungleFoliage = new THREE.MeshStandardMaterial({ color: 0x12471f, roughness: 0.82 });
    this.matJungleCanopyDark = new THREE.MeshStandardMaterial({ color: 0x0a3315, roughness: 0.86 });

    // Alpine Peaks Materials
    this.matAlpineGranite = new THREE.MeshStandardMaterial({ color: 0x4a4d53, roughness: 0.92 });
    this.matAlpineScree = new THREE.MeshStandardMaterial({ color: 0x5e636d, roughness: 0.95 });
  }

  setCollider(group, radius, type, isBreakable = false) {
    if (!group) return group;
    group.userData.collider = { radius, type, isBreakable, solid: true };
    return group;
  }

  getNearbyColliders(playerZ, range = 24.0) {
    const minZ = playerZ - 8.0;
    const maxZ = playerZ + range;
    const colliders = [];
    for (let i = 0; i < this.props.length; i++) {
      const prop = this.props[i];
      if (prop.userData && prop.userData.collider && prop.userData.collider.solid) {
        const pz = prop.position.z;
        if (pz >= minZ && pz <= maxZ) {
          colliders.push({
            position: prop.position,
            mesh: prop,
            collider: prop.userData.collider
          });
        }
      }
    }
    return colliders;
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

    // 3. Despawn props left behind with clean WebGL buffer disposal
    const despawnZ = playerZ - 75;
    for (let i = this.props.length - 1; i >= 0; i--) {
      const prop = this.props[i];
      if (prop.position.z < despawnZ) {
        this.scene.remove(prop);
        prop.traverse((child) => {
          if (child.isMesh && child.geometry && !child.geometry.userData?.isShared) {
            child.geometry.dispose();
          }
        });
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
      this.setCollider(post, 0.45, 'milestone', true);
      this.scene.add(post);
      this.props.push(post);
    }

    // 2. Regulatory & Hazard Highway Signs
    const signKey = `sign_${Math.floor(z / 60)}_${biome.id}`;
    if (!this.spawnedMilestones.has(signKey)) {
      let signType = null;
      if (relZ >= 20 && relZ < 30) {
        signType = 'speed_80';
      } else if (biome.id === 'mediterranean_coast' && relZ >= 130 && relZ < 140) {
        signType = 'speed_80';
      } else if (biome.id === 'temperate_forest' && relZ >= 270 && relZ < 280) {
        signType = 'wildlife';
      } else if (biome.id === 'arid_desert' && relZ >= 130 && relZ < 140) {
        signType = 'desert_heat';
      } else if (biome.id === 'savanna_steppe' && relZ >= 270 && relZ < 280) {
        signType = 'wildlife';
      } else if (biome.id === 'tropical_rainforest' && relZ >= 40 && relZ < 50) {
        signType = 'flood';
      } else if (biome.id === 'alpine_peaks' && ((relZ >= 30 && relZ < 40) || (relZ >= 250 && relZ < 260))) {
        signType = 'rockfall';
      } else if (biome.id === 'boreal_taiga' && relZ >= 270 && relZ < 280) {
        signType = 'wildlife';
      } else if (biome.id === 'polar_tundra' && relZ >= 30 && relZ < 40) {
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
        this.setCollider(signMesh, 0.55, 'sign', true);
        this.scene.add(signMesh);
        this.props.push(signMesh);
      }
    }

    // 3. Streetlights - Illuminated settlement hubs (8 real-world sectors, 5200m loop)
    const cycleZ = z % 5200;
    const isStreetlit =
      (cycleZ >= 100 && cycleZ <= 340) ||   // Sector 0: San Vito Harbor
      (cycleZ >= 750 && cycleZ <= 990) ||   // Sector 1: Valbruna Mill
      (cycleZ >= 1400 && cycleZ <= 1640) || // Sector 2: El Kantara Oasis
      (cycleZ >= 2050 && cycleZ <= 2290) || // Sector 3: Serengeti Outpost
      (cycleZ >= 2700 && cycleZ <= 2940) || // Sector 4: Rio Verde Station
      (cycleZ >= 3350 && cycleZ <= 3590) || // Sector 5: Valico Aquile Refuge
      (cycleZ >= 4000 && cycleZ <= 4240) || // Sector 6: Taiga Nord Depot
      (cycleZ >= 4650 && cycleZ <= 4890);   // Sector 7: Base Polare 80

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
        this.setCollider(lamp, 0.65, 'pole', false);
        this.scene.add(lamp);
        this.props.push(lamp);
      }
    }

    // 4. Utility Power Poles - Telecommunication & power lines in civilized/working sectors
    const hasPoles = (
      biome.id === 'mediterranean_coast' ||
      biome.id === 'temperate_forest' ||
      biome.id === 'savanna_steppe' ||
      biome.id === 'boreal_taiga'
    );
    if (hasPoles) {
      const poleSide = (biome.id === 'temperate_forest') ? -1 : 1;
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
        this.setCollider(pole, 0.70, 'pole', false);
        this.scene.add(pole);
        this.props.push(pole);
      }
    }

    // 5. Alpine & Arctic Snow Alignment Poles (Paline da Neve Catarifrangenti)
    if (biome.id === 'alpine_peaks' || biome.id === 'polar_tundra') {
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
          this.setCollider(pole, 0.35, 'snowpole', true);
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

    if (biome.id === 'mediterranean_coast') {
      // Zone 1: Rural dry stone walls & olive terraces
      if (relZ < 150) {
        propsToSpawn.push(this.setCollider(this.createDryStoneWall(roadInfo.x + halfW + 3.8, roadInfo.y, z), 2.2, 'wall', false));
        if (Math.random() < 0.55) {
          propsToSpawn.push(this.setCollider(this.createOliveTree(roadInfo.x - halfW - 4.8, roadInfo.y, z), 1.5, 'tree', false));
        }
      }
      // Zone 2 (180-260m): San Vito Harbor Coastal Fishery & Watchtower
      else if (relZ >= 180 && relZ < 260) {
        const clusterKey = `harbor_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(clusterKey)) {
          this.spawnedMilestones.add(clusterKey);
          propsToSpawn.push(this.setCollider(this.createHarborFishery(roadInfo.x - halfW - 8.5, roadInfo.y, z), 5.5, 'building', false));
        }
      }
      // Zone 3: Maritime umbrella pines & coastal guardrails
      else {
        propsToSpawn.push(this.setCollider(this.createMaritimePine(roadInfo.x + halfW + 6.0, roadInfo.y, z), 1.6, 'tree', false));
        if (Math.random() < 0.45) {
          propsToSpawn.push(this.setCollider(this.createOliveTree(roadInfo.x - halfW - 5.5, roadInfo.y, z), 1.5, 'tree', false));
        }
      }
    } else if (biome.id === 'temperate_forest') {
      // Zone 1: Split-rail fences and clearings
      if (relZ < 140) {
        propsToSpawn.push(this.setCollider(this.createSplitRailFence(roadInfo.x + halfW + 4.2, roadInfo.y, z), 1.4, 'fence', true));
        propsToSpawn.push(this.createGrassTuft(roadInfo.x - halfW - 2.0, roadInfo.y, z));
      }
      // Zone 2 (180-260m): Valbruna Hydraulic Water Mill & Log Yard
      else if (relZ >= 180 && relZ < 260) {
        const millKey = `mill_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(millKey)) {
          this.spawnedMilestones.add(millKey);
          propsToSpawn.push(this.setCollider(this.createWaterMill(roadInfo.x - halfW - 9.0, roadInfo.y, z), 5.5, 'building', false));
        }
      }
      // Zone 3: Lush broadleaf stands of Deciduous Oaks & European Beeches
      else {
        propsToSpawn.push(this.setCollider(this.createDeciduousOak(roadInfo.x - halfW - 6.0, roadInfo.y, z), 1.7, 'tree', false));
        propsToSpawn.push(this.setCollider(this.createEuropeanBeech(roadInfo.x + halfW + 6.5, roadInfo.y, z), 1.6, 'tree', false));
      }
    } else if (biome.id === 'arid_desert') {
      // Zone 1 (180-260m): El Kantara Adobe Caravansary & Palm Oasis
      if (relZ >= 180 && relZ < 260) {
        const oasisKey = `oasis_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(oasisKey)) {
          this.spawnedMilestones.add(oasisKey);
          propsToSpawn.push(this.setCollider(this.createOasisCaravansary(roadInfo.x - halfW - 8.5, roadInfo.y, z), 5.5, 'building', false));
        }
      }
      // Zone 2: Sweeping sand dune ridges, date palms and sun-bleached wrecks
      else {
        propsToSpawn.push(this.createSandDuneRidge(roadInfo.x + halfW + 7.5, roadInfo.y, z, 1));
        if (Math.random() < 0.35) {
          propsToSpawn.push(this.setCollider(this.createDatePalm(roadInfo.x - halfW - 5.5, roadInfo.y, z), 1.4, 'tree', false));
        }
        if (Math.random() < 0.25) {
          propsToSpawn.push(this.setCollider(this.createWreck(roadInfo.x - halfW - 4.0, roadInfo.y, z), 2.4, 'wreck', false));
        }
      }
    } else if (biome.id === 'savanna_steppe') {
      // Zone 1 (180-260m): Serengeti Ranger Station & Watchtower
      if (relZ >= 180 && relZ < 260) {
        const rangerKey = `ranger_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(rangerKey)) {
          this.spawnedMilestones.add(rangerKey);
          propsToSpawn.push(this.setCollider(this.createRangerStation(roadInfo.x + halfW + 8.5, roadInfo.y, z), 5.5, 'building', false));
        }
      }
      // Zone 2: Flat-topped umbrella acacias, monumental baobabs & dry golden straw
      else {
        propsToSpawn.push(this.setCollider(this.createUmbrellaAcacia(roadInfo.x - halfW - 6.5, roadInfo.y, z), 1.6, 'tree', false));
        if (Math.random() < 0.35) {
          propsToSpawn.push(this.setCollider(this.createBaobabTree(roadInfo.x + halfW + 11.0, roadInfo.y, z), 2.8, 'tree', false));
        }
        propsToSpawn.push(this.createGrassTuft(roadInfo.x + halfW + 2.5, roadInfo.y, z));
      }
    } else if (biome.id === 'tropical_rainforest') {
      // Zone 1 (180-260m): Rio Verde Botanical Canopy Lab & Stilt Station
      if (relZ >= 180 && relZ < 260) {
        const labKey = `botanical_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(labKey)) {
          this.spawnedMilestones.add(labKey);
          propsToSpawn.push(this.setCollider(this.createBotanicalLab(roadInfo.x - halfW - 8.5, roadInfo.y, z), 5.5, 'building', false));
        }
      }
      // Zone 2: Gigantic buttressed rainforest trees with multi-layered canopy & lianas
      else {
        propsToSpawn.push(this.setCollider(this.createRainforestGiant(roadInfo.x - halfW - 7.5, roadInfo.y, z), 2.6, 'tree', false));
        propsToSpawn.push(this.setCollider(this.createRainforestGiant(roadInfo.x + halfW + 7.5, roadInfo.y, z), 2.6, 'tree', false));
        propsToSpawn.push(this.createGrassTuft(roadInfo.x - halfW - 2.0, roadInfo.y, z));
      }
    } else if (biome.id === 'alpine_peaks') {
      // Zone 1 (180-260m): Avalanche Defense Gallery & High Pass Shelter
      if (relZ >= 180 && relZ < 260) {
        const passKey = `pass_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(passKey)) {
          this.spawnedMilestones.add(passKey);
          propsToSpawn.push(this.setCollider(this.createAvalancheTunnel(roadInfo.x, roadInfo.y, z), 2.2, 'wall', false));
        }
      }
      // Zone 2: Colossal dark granite canyon walls, jagged peaks & rockfall scree
      else {
        propsToSpawn.push(this.setCollider(this.createAlpineGraniteWall(roadInfo.x - halfW - 4.5, roadInfo.y, z, -1), 5.0, 'cliff', false));
        propsToSpawn.push(this.setCollider(this.createAlpineGraniteWall(roadInfo.x + halfW + 4.5, roadInfo.y, z, 1), 5.0, 'cliff', false));
        if (Math.random() < 0.4) {
          propsToSpawn.push(this.setCollider(this.createRock(roadInfo.x + halfW + 2.5, roadInfo.y, z, 1.8), 2.0, 'rock', false));
        }
      }
    } else if (biome.id === 'boreal_taiga') {
      // Zone 1 (180-260m): Taiga Nord Forestry Station & Watchtower
      if (relZ >= 180 && relZ < 260) {
        const outpostKey = `forester_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(outpostKey)) {
          this.spawnedMilestones.add(outpostKey);
          propsToSpawn.push(this.setCollider(this.createForesterOutpost(roadInfo.x + halfW + 11.0, roadInfo.y, z), 5.5, 'building', false));
        }
      }
      // Zone 2: Dense stands of black spruce and paper birch
      else {
        [-1, 1].forEach((side) => {
          propsToSpawn.push(this.setCollider(this.createForestStand(roadInfo.x + side * (halfW + 5.5), roadInfo.y, z, side), 2.4, 'tree', false));
        });
      }
    } else if (biome.id === 'polar_tundra') {
      // Zone 1 (180-260m): Arctic Geodesic Research Base 80 & METAR radar
      if (relZ >= 180 && relZ < 260) {
        const polarKey = `polar_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(polarKey)) {
          this.spawnedMilestones.add(polarKey);
          propsToSpawn.push(this.setCollider(this.createArcticGeodesicDome(roadInfo.x + halfW + 10.0, roadInfo.y, z), 6.0, 'building', false));
        }
      }
      // Zone 2: Glacial ice spires & snow-blanketed conifers
      else {
        propsToSpawn.push(this.setCollider(this.createSnowCoveredPines(roadInfo.x - halfW - 6.0, roadInfo.y, z), 2.2, 'tree', false));
        propsToSpawn.push(this.setCollider(this.createGlacialIceSpire(roadInfo.x + halfW + 5.5, roadInfo.y, z), 2.0, 'rock', false));
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

  // --- MEDITERRANEAN COAST STRUCTURES & FLORA ---
  createMaritimePine(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.4;

    // Tall slender trunk with slight natural lean
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.32, 0.52, 7.5, 7),
      this.matTrunk
    );
    trunk.position.y = 3.75;
    trunk.rotation.z = (Math.random() - 0.5) * 0.15;
    trunk.castShadow = true;
    group.add(trunk);

    // Splayed upper branches
    for (let b = 0; b < 3; b++) {
      const angle = (b * Math.PI * 2) / 3;
      const branch = new THREE.Mesh(
        new THREE.CylinderGeometry(0.12, 0.22, 2.8, 5),
        this.matTrunk
      );
      branch.position.set(Math.cos(angle) * 0.9, 6.8, Math.sin(angle) * 0.9);
      branch.rotation.z = Math.cos(angle) * 0.55;
      branch.rotation.x = Math.sin(angle) * 0.55;
      group.add(branch);
    }

    // Broad umbrella dome canopy
    const canopy = new THREE.Mesh(
      new THREE.CylinderGeometry(4.2, 2.8, 1.8, 8),
      this.matMaritimePineFoliage
    );
    canopy.position.y = 8.6;
    canopy.castShadow = true;
    group.add(canopy);

    const canopyCap = new THREE.Mesh(
      new THREE.SphereGeometry(3.6, 8, 5, 0, Math.PI * 2, 0, Math.PI * 0.4),
      this.matMaritimePineFoliage
    );
    canopyCap.position.y = 9.4;
    canopyCap.castShadow = true;
    group.add(canopyCap);

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createOliveTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.35;

    // Gnarled twisted trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.35, 0.65, 3.2, 6),
      new THREE.MeshStandardMaterial({ color: 0x42382e, roughness: 0.98 })
    );
    trunk.position.y = 1.6;
    trunk.rotation.z = (Math.random() - 0.5) * 0.25;
    trunk.castShadow = true;
    group.add(trunk);

    // Silvery-olive rounded foliage clouds
    const offsets = [
      { x: -0.8, y: 3.2, z: 0.2, r: 1.6 },
      { x: 0.7, y: 3.5, z: -0.6, r: 1.8 },
      { x: 0.2, y: 3.9, z: 0.7, r: 1.5 }
    ];
    offsets.forEach((off) => {
      const foliage = new THREE.Mesh(
        new THREE.DodecahedronGeometry(off.r, 1),
        this.matOliveFoliage
      );
      foliage.position.set(off.x, off.y, off.z);
      foliage.castShadow = true;
      group.add(foliage);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createDryStoneWall(x, y, z) {
    const group = new THREE.Group();
    // Traditional Mediterranean limestone stone wall module (length 6.8m)
    const wall = new THREE.Mesh(
      new THREE.BoxGeometry(0.55, 0.95, 6.8),
      this.matStoneWall
    );
    wall.position.y = 0.47;
    wall.castShadow = true;
    group.add(wall);

    // Weathered coping stones on top
    const cap = new THREE.Mesh(
      new THREE.BoxGeometry(0.65, 0.12, 6.9),
      this.matStoneWall
    );
    cap.position.y = 0.98;
    group.add(cap);

    group.position.set(x, y, z);
    return group;
  }

  createHarborFishery(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Stone and whitewashed fisherman workshop
    const building = new THREE.Mesh(
      new THREE.BoxGeometry(7.5, 3.8, 9.0),
      this.matStoneWall
    );
    building.position.set(0, 1.9, 0);
    building.castShadow = true;
    group.add(building);

    // Terracotta tiled roof
    const roof = new THREE.Mesh(
      new THREE.ConeGeometry(5.8, 2.4, 4),
      new THREE.MeshStandardMaterial({ color: 0x9a3412, roughness: 0.85 })
    );
    roof.position.set(0, 4.9, 0);
    roof.rotation.y = Math.PI / 4;
    group.add(roof);

    // Wooden boat dock pier extension
    const pier = new THREE.Mesh(
      new THREE.BoxGeometry(3.2, 0.35, 14.0),
      this.matWoodLog
    );
    pier.position.set(-6.5, 0.25, 0);
    group.add(pier);

    // Warm harbor lantern
    const light = new THREE.PointLight(0xffa834, 2.2, 24);
    light.position.set(3.8, 3.2, 0);
    group.add(light);

    return group;
  }

  // --- TEMPERATE FOREST STRUCTURES & FLORA ---
  createDeciduousOak(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Massive hardwood trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.48, 0.85, 4.6, 7),
      this.matTrunk
    );
    trunk.position.y = 2.3;
    trunk.castShadow = true;
    group.add(trunk);

    // 4 Layered rich-green foliage domes
    const crowns = [
      { x: 0, y: 5.6, z: 0, r: 3.2 },
      { x: -1.6, y: 5.0, z: 1.2, r: 2.4 },
      { x: 1.8, y: 5.2, z: -1.0, r: 2.6 },
      { x: 0.3, y: 6.8, z: 0.4, r: 2.2 }
    ];
    crowns.forEach((c) => {
      const dome = new THREE.Mesh(
        new THREE.DodecahedronGeometry(c.r, 1),
        this.matDeciduousOak
      );
      dome.position.set(c.x, c.y, c.z);
      dome.castShadow = true;
      group.add(dome);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createEuropeanBeech(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.4;

    // Slender smooth silver-grey trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.28, 0.45, 6.0, 7),
      new THREE.MeshStandardMaterial({ color: 0x8e8e93, roughness: 0.85 })
    );
    trunk.position.y = 3.0;
    trunk.castShadow = true;
    group.add(trunk);

    // Elegant conical beech crown
    const foliage = new THREE.Mesh(
      new THREE.ConeGeometry(3.2, 6.5, 7),
      this.matBeechFoliage
    );
    foliage.position.y = 6.2;
    foliage.castShadow = true;
    group.add(foliage);

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createWaterMill(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Stone foundation mill building
    const mill = new THREE.Mesh(
      new THREE.BoxGeometry(8.0, 4.2, 7.5),
      this.matWoodLog
    );
    mill.position.set(0, 2.1, 0);
    mill.castShadow = true;
    group.add(mill);

    // Sloped wooden shingle roof
    const roof = new THREE.Mesh(
      new THREE.ConeGeometry(6.2, 2.8, 4),
      new THREE.MeshStandardMaterial({ color: 0x2e2318, roughness: 0.9 })
    );
    roof.position.set(0, 5.5, 0);
    roof.rotation.y = Math.PI / 4;
    group.add(roof);

    // Vertical hydraulic water wheel
    const wheel = new THREE.Mesh(
      new THREE.CylinderGeometry(2.4, 2.4, 0.7, 12),
      new THREE.MeshStandardMaterial({ color: 0x3d2719, roughness: 0.95 })
    );
    wheel.position.set(-4.5, 1.8, 0);
    wheel.rotation.z = Math.PI / 2;
    group.add(wheel);

    // Firewood stacks
    const logs = new THREE.Mesh(
      new THREE.BoxGeometry(2.2, 1.4, 3.8),
      this.matWoodLog
    );
    logs.position.set(4.8, 0.7, 2.0);
    group.add(logs);

    return group;
  }

  // --- ARID DESERT STRUCTURES & FLORA ---
  createDatePalm(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Curved slender palm trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.24, 0.48, 8.5, 7),
      this.matPalmTrunk
    );
    trunk.position.set(0.4, 4.25, 0);
    trunk.rotation.z = 0.12;
    trunk.castShadow = true;
    group.add(trunk);

    // Radiating arching fronds
    for (let f = 0; f < 8; f++) {
      const angle = (f * Math.PI * 2) / 8;
      const frond = new THREE.Mesh(
        new THREE.BoxGeometry(0.35, 0.08, 3.4),
        this.matPalmFronds
      );
      frond.position.set(Math.cos(angle) * 1.5 + 0.8, 8.4, Math.sin(angle) * 1.5);
      frond.rotation.y = -angle;
      frond.rotation.x = 0.45;
      frond.castShadow = true;
      group.add(frond);
    }

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createSandDuneRidge(x, y, z, side) {
    const group = new THREE.Group();
    // Sweeping aerodynamic desert barchan dune ridge
    const dune = new THREE.Mesh(
      new THREE.ConeGeometry(14.0, 5.5, 5),
      this.matDuneSand
    );
    dune.position.y = 2.4;
    dune.scale.set(1.6, 0.9, 2.8);
    dune.rotation.y = side * 0.4;
    dune.receiveShadow = true;
    group.add(dune);

    group.position.set(x, y, z);
    return group;
  }

  createOasisCaravansary(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Thick adobe walled courtyard
    const wall = new THREE.Mesh(
      new THREE.BoxGeometry(12.0, 3.2, 16.0),
      this.matAdobe
    );
    wall.position.set(0, 1.6, 0);
    wall.castShadow = true;
    group.add(wall);

    // Domed central well / cistern
    const wellDome = new THREE.Mesh(
      new THREE.SphereGeometry(2.4, 8, 8, 0, Math.PI * 2, 0, Math.PI * 0.5),
      new THREE.MeshStandardMaterial({ color: 0xf8fafc, roughness: 0.9 })
    );
    wellDome.position.set(-8.0, 0, 0);
    group.add(wellDome);

    // Flanking date palms
    [-5, 5].forEach((pz) => {
      const palm = this.createDatePalm(-7.0, 0, pz);
      group.add(palm);
    });

    const light = new THREE.PointLight(0xffa233, 2.0, 22);
    light.position.set(0, 3.5, 0);
    group.add(light);

    return group;
  }

  // --- SAVANNA & STEPPE STRUCTURES & FLORA ---
  createUmbrellaAcacia(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Dark angled trunk bifurcating upwards
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.3, 0.55, 5.2, 6),
      this.matTrunk
    );
    trunk.position.y = 2.6;
    trunk.rotation.z = (Math.random() - 0.5) * 0.3;
    trunk.castShadow = true;
    group.add(trunk);

    // 3 Splayed high lateral branches
    for (let b = 0; b < 3; b++) {
      const angle = (b * Math.PI * 2) / 3;
      const arm = new THREE.Mesh(
        new THREE.CylinderGeometry(0.14, 0.22, 3.2, 5),
        this.matTrunk
      );
      arm.position.set(Math.cos(angle) * 1.2, 5.0, Math.sin(angle) * 1.2);
      arm.rotation.z = Math.cos(angle) * 0.7;
      arm.rotation.x = Math.sin(angle) * 0.7;
      group.add(arm);
    }

    // Wide horizontal flat-topped umbrella foliage canopy
    const flatCanopy = new THREE.Mesh(
      new THREE.CylinderGeometry(5.2, 4.2, 0.8, 8),
      this.matAcaciaCanopy
    );
    flatCanopy.position.y = 6.4;
    flatCanopy.castShadow = true;
    group.add(flatCanopy);

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createBaobabTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.3;

    // Colossal swollen bottle trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(2.4, 3.4, 8.5, 9),
      this.matBaobabTrunk
    );
    trunk.position.y = 4.25;
    trunk.castShadow = true;
    group.add(trunk);

    // Root-like top branch clusters
    for (let i = 0; i < 5; i++) {
      const angle = (i * Math.PI * 2) / 5;
      const branch = new THREE.Mesh(
        new THREE.CylinderGeometry(0.4, 0.8, 3.5, 5),
        this.matBaobabTrunk
      );
      branch.position.set(Math.cos(angle) * 1.8, 9.2, Math.sin(angle) * 1.8);
      branch.rotation.z = Math.cos(angle) * 0.6;
      branch.rotation.x = Math.sin(angle) * 0.6;
      group.add(branch);

      // Foliage tuft at branch tip
      const tuft = new THREE.Mesh(
        new THREE.DodecahedronGeometry(1.6, 1),
        this.matAcaciaCanopy
      );
      tuft.position.set(Math.cos(angle) * 3.2, 10.5, Math.sin(angle) * 3.2);
      group.add(tuft);
    }

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createRangerStation(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Elevated timber ranger outpost
    const legGeo = new THREE.CylinderGeometry(0.2, 0.25, 4.5, 5);
    [-2.2, 2.2].forEach((lx) => {
      [-2.2, 2.2].forEach((lz) => {
        const leg = new THREE.Mesh(legGeo, this.matWoodLog);
        leg.position.set(lx, 2.25, lz);
        leg.castShadow = true;
        group.add(leg);
      });
    });

    const cabin = new THREE.Mesh(
      new THREE.BoxGeometry(5.2, 2.6, 5.2),
      this.matWoodLog
    );
    cabin.position.y = 5.6;
    cabin.castShadow = true;
    group.add(cabin);

    // Shaded corrugated tin roof overhang
    const roof = new THREE.Mesh(
      new THREE.BoxGeometry(6.4, 0.2, 6.4),
      new THREE.MeshStandardMaterial({ color: 0x94a3b8, metalness: 0.8, roughness: 0.3 })
    );
    roof.position.y = 7.0;
    group.add(roof);

    // Radio antenna mast
    const mast = new THREE.Mesh(
      new THREE.CylinderGeometry(0.05, 0.05, 6.5, 4),
      new THREE.MeshStandardMaterial({ color: 0xcbd5e1, metalness: 0.9 })
    );
    mast.position.set(2.4, 9.8, 2.4);
    group.add(mast);

    return group;
  }

  // --- TROPICAL RAINFOREST STRUCTURES & FLORA ---
  createRainforestGiant(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Immense straight trunk reaching into the canopy
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.65, 1.3, 14.0, 8),
      new THREE.MeshStandardMaterial({ color: 0x36271c, roughness: 0.95 })
    );
    trunk.position.y = 7.0;
    trunk.castShadow = true;
    group.add(trunk);

    // Buttress roots flanking the base
    for (let r = 0; r < 4; r++) {
      const angle = (r * Math.PI * 2) / 4;
      const buttress = new THREE.Mesh(
        new THREE.BoxGeometry(0.35, 3.8, 2.4),
        this.matTrunk
      );
      buttress.position.set(Math.cos(angle) * 1.5, 1.9, Math.sin(angle) * 1.5);
      buttress.rotation.y = -angle;
      group.add(buttress);
    }

    // Dense tiered jungle emerald canopy
    const canopies = [
      { y: 13.5, r: 5.8, mat: this.matJungleFoliage },
      { y: 15.8, r: 4.6, mat: this.matJungleCanopyDark },
      { y: 17.6, r: 3.2, mat: this.matJungleFoliage }
    ];
    canopies.forEach((c) => {
      const dome = new THREE.Mesh(
        new THREE.DodecahedronGeometry(c.r, 1),
        c.mat
      );
      dome.position.y = c.y;
      dome.scale.set(1.2, 0.65, 1.2);
      dome.castShadow = true;
      group.add(dome);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createBotanicalLab(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Stilt research module elevated above flood level
    const stilts = new THREE.Mesh(
      new THREE.BoxGeometry(8.5, 0.4, 12.0),
      this.matWoodLog
    );
    stilts.position.y = 2.4;
    group.add(stilts);

    const labCabin = new THREE.Mesh(
      new THREE.BoxGeometry(7.2, 3.2, 10.0),
      new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.8 })
    );
    labCabin.position.y = 4.2;
    group.add(labCabin);

    // Green weather monitoring beacon
    const beacon = new THREE.PointLight(0x10b981, 2.2, 22);
    beacon.position.set(0, 6.5, 0);
    group.add(beacon);

    return group;
  }

  // --- ALPINE PEAKS STRUCTURES & CRAGS ---
  createAlpineGraniteWall(x, y, z, side) {
    const group = new THREE.Group();
    const height = 30 + Math.random() * 12;
    const width = 18 + Math.random() * 8;
    const depth = 16;

    // Dark granite precipice wall
    const cliff = new THREE.Mesh(
      new THREE.BoxGeometry(width, height, depth),
      this.matAlpineGranite
    );
    cliff.position.y = height * 0.5 - 1.0;
    cliff.castShadow = true;
    cliff.receiveShadow = true;
    group.add(cliff);

    // Jagged snowy summit horn
    const horn = new THREE.Mesh(
      new THREE.ConeGeometry(width * 0.4, 9.0, 5),
      this.matSnow
    );
    horn.position.set((Math.random() - 0.5) * 4, height + 3.5, (Math.random() - 0.5) * 3);
    horn.castShadow = true;
    group.add(horn);

    group.position.set(x, y, z);
    return group;
  }

  createAvalancheTunnel(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Concrete avalanche deflection gallery over the road
    const roof = new THREE.Mesh(
      new THREE.BoxGeometry(22, 0.8, 16),
      this.matAlpineGranite
    );
    roof.position.set(0, 6.2, 0);
    roof.rotation.z = 0.15; // Sloped to dump snow down valley
    group.add(roof);

    // Massive reinforced concrete pillars on mountain side
    [-6, 0, 6].forEach((pz) => {
      const col = new THREE.Mesh(
        new THREE.BoxGeometry(1.2, 6.2, 1.2),
        this.matAlpineGranite
      );
      col.position.set(-9.5, 3.1, pz);
      group.add(col);
    });

    return group;
  }
}

