/**
 * THE LONG MERIDIAN - Intelligent Points of Interest (POI) & Settlement Manager
 * Spawns geographically coherent settlements, regional outposts and narrative salvage sites.
 */

import { CONFIG } from '../config.js';

export class POIManager {
  constructor(scene, roadGenerator) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;

    this.pois = [];
    this.activeNearbyPOI = null; // POI currently within interaction radius (<= 10m)

    // Master Geocentric Plan for Sites along the Trans-Earth 8-Biomes Expedition (5200m Loop)
    this.plannedSites = [
      // SECTOR 0: Mediterranean Coast (PK 0.0 - 0.65 KM)
      {
        z: 220,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'san_vito_harbor',
        side: 1, // Right
        name: 'Porto di San Vito & Molo Pescatori'
      },
      {
        z: 380,
        type: 'COASTAL_FISHERY_RUIN',
        side: -1, // Left
        name: 'Faro Costiero & Rudere Vecchia Tonnara'
      },
      {
        z: 520,
        type: 'OVERTURNED_CONVOY',
        side: 1,
        name: 'Furgone Merci Ribaltato sui Tornanti Costieri'
      },

      // SECTOR 1: Temperate Forest (PK 0.65 - 1.30 KM)
      {
        z: 870,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'valbruna_mill',
        side: -1,
        name: 'Mulino di Valbruna & Segheria Idraulica'
      },
      {
        z: 1040,
        type: 'FORESTRY_LUMBER_YARD',
        side: 1,
        name: 'Piazzale Carico Tronchi di Querce e Faggi'
      },
      {
        z: 1180,
        type: 'MILITARY_CHECKPOINT',
        side: -1,
        name: 'Posto di Blocco Guardia Forestale di Valbruna'
      },

      // SECTOR 2: Arid Desert (PK 1.30 - 1.95 KM)
      {
        z: 1520,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'elkantara_oasis',
        side: 1,
        name: 'Oasi di El Kantara & Carovanserraglio'
      },
      {
        z: 1680,
        type: 'DESERT_CARAVAN_POST',
        side: -1,
        name: 'Pozzo Sahariano & Cisterna Idrica del Deserto'
      },
      {
        z: 1820,
        type: 'OVERTURNED_CONVOY',
        side: 1,
        name: 'Autocarro Berliet Sabbiato tra le Dune'
      },

      // SECTOR 3: Savanna Steppe (PK 1.95 - 2.60 KM)
      {
        z: 2170,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'serengeti_outpost',
        side: -1,
        name: 'Avamposto Ranger del Serengeti'
      },
      {
        z: 2320,
        type: 'SAVANNA_RANGER_STATION',
        side: 1,
        name: 'Torretta Avvistamento & Ripetitore Radio Savana'
      },
      {
        z: 2480,
        type: 'MILITARY_CHECKPOINT',
        side: -1,
        name: 'Cancello Parco Nazionale & Pista Laterite'
      },

      // SECTOR 4: Tropical Rainforest (PK 2.60 - 3.25 KM)
      {
        z: 2820,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'rioverde_station',
        side: 1,
        name: 'Stazione Scientifica Botanica Rio Verde'
      },
      {
        z: 2960,
        type: 'JUNGLE_BOTANICAL_LAB',
        side: -1,
        name: 'Laboratorio Palafitta sulle Chiome Equatoriali'
      },
      {
        z: 3120,
        type: 'OVERTURNED_CONVOY',
        side: 1,
        name: 'Convoglio da Spedizione Sommerso nel Guado Monsonico'
      },

      // SECTOR 5: Alpine Peaks (PK 3.25 - 3.90 KM)
      {
        z: 3470,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'valico_aquile',
        side: -1,
        name: 'Rifugio Alpino Valico delle Aquile'
      },
      {
        z: 3620,
        type: 'ALPINE_TUNNEL_SHELTER',
        side: 1,
        name: 'Galleria Paravalanghe e Deposito Frane'
      },
      {
        z: 3780,
        type: 'QUARRY_CRUSHER_SITE',
        side: -1,
        name: 'Cava di Granito e Falesie del Passo Alpino'
      },

      // SECTOR 6: Boreal Taiga (PK 3.90 - 4.55 KM)
      {
        z: 4120,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'taiga_nord',
        side: 1,
        name: 'Deposito Forestale Taiga Nord'
      },
      {
        z: 4280,
        type: 'TAIGA_LOGGING_DEPOT',
        side: -1,
        name: 'Segheria Meccanizzata Picea e Betulla'
      },
      {
        z: 4420,
        type: 'MILITARY_CHECKPOINT',
        side: 1,
        name: 'Posto di Frontiera Nordico'
      },

      // SECTOR 7: Polar Tundra (PK 4.55 - 5.20+ KM)
      {
        z: 4770,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'polar_base_80',
        side: -1,
        name: 'Base Scientifica Polare 80'
      },
      {
        z: 4940,
        type: 'POLAR_METAR_SHELTER',
        side: 1,
        name: 'Cupola Radar Geodetica & Stazione Meteo METAR'
      },
      {
        z: 5100,
        type: 'MILITARY_CHECKPOINT',
        side: -1,
        name: 'Faro Terminale del Grande Meridiano & Traguardo'
      }
    ];

    this.spawnedZSet = new Set();
    this.initMaterials();
  }

  initMaterials() {
    this.matCanopy = new THREE.MeshStandardMaterial({ color: 0x444850, roughness: 0.6, metalness: 0.5 });
    this.matPump = new THREE.MeshStandardMaterial({ color: 0xaa2211, roughness: 0.7 });
    this.matConcrete = new THREE.MeshStandardMaterial({ color: 0x5a5855, roughness: 0.9 });
    this.matCargo = new THREE.MeshStandardMaterial({ color: 0x224466, roughness: 0.8, metalness: 0.3 });
    this.matWood = new THREE.MeshStandardMaterial({ color: 0x5a3e26, roughness: 0.9 });
    this.matFence = new THREE.MeshStandardMaterial({ color: 0x777777, wireframe: true });
    this.matWarning = new THREE.MeshStandardMaterial({ color: 0xe6a110, roughness: 0.4 });
    this.matBeacon = new THREE.MeshBasicMaterial({ color: 0xffaa33 });
    this.matSettlementLight = new THREE.MeshBasicMaterial({ color: 0x55ffaa });
    this.matLitWindow = new THREE.MeshBasicMaterial({ color: 0xffd166 });
    this.matNeonGreen = new THREE.MeshBasicMaterial({ color: 0x10b981 });
    this.matNeonRed = new THREE.MeshBasicMaterial({ color: 0xef4444 });
    this.matNeonBlue = new THREE.MeshBasicMaterial({ color: 0x38bdf8 });
    this.matFireGlow = new THREE.MeshBasicMaterial({ color: 0xff7722 });
    this.matMetalDark = new THREE.MeshStandardMaterial({ color: 0x1e242d, roughness: 0.5, metalness: 0.75 });
    this.matRoofShingle = new THREE.MeshStandardMaterial({ color: 0x2b3038, roughness: 0.9 });
    this.matSnowTop = new THREE.MeshStandardMaterial({ color: 0xf1f5f9, roughness: 0.95 });
  }

  update(playerPos) {
    const horizonZ = playerPos.z + 240;

    // Check pre-planned geographic sites ahead
    for (const siteDef of this.plannedSites) {
      if (siteDef.z <= horizonZ && !this.spawnedZSet.has(siteDef.z)) {
        this.spawnStructuredSite(siteDef);
        this.spawnedZSet.add(siteDef.z);
      }
    }

    // Check for loop extension if player travels past 5200m
    if (horizonZ > 5200) {
      const cycleOffset = Math.floor(horizonZ / 5200) * 5200;
      for (const siteDef of this.plannedSites) {
        const projectedZ = siteDef.z + cycleOffset;
        if (projectedZ <= horizonZ && !this.spawnedZSet.has(projectedZ)) {
          this.spawnStructuredSite({
            ...siteDef,
            z: projectedZ,
            name: `${siteDef.name} (Giro ${Math.floor(cycleOffset / 5200) + 1})`
          });
          this.spawnedZSet.add(projectedZ);
        }
      }
    }

    // Proximity check: is player within interaction range (10 meters)?
    this.activeNearbyPOI = null;
    let closestDist = 999;

    for (const poi of this.pois) {
      const dist = poi.position.distanceTo(playerPos);
      if (dist < 11.0 && dist < closestDist) {
        closestDist = dist;
        this.activeNearbyPOI = poi;
      }
    }

    // Recycle POIs that are far behind player
    const despawnZ = playerPos.z - 75;
    for (let i = this.pois.length - 1; i >= 0; i--) {
      const poi = this.pois[i];
      if (poi.position.z < despawnZ) {
        this.scene.remove(poi.meshGroup);
        this.pois.splice(i, 1);
      }
    }
  }

  spawnStructuredSite(siteDef) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(siteDef.z);
    const side = siteDef.side || 1;
    const offsetFromCenter = side * (roadInfo.width * 0.5 + 8.5);
    const x = roadInfo.x + offsetFromCenter;
    const y = roadInfo.y;
    const z = siteDef.z;

    const group = new THREE.Group();
    group.position.set(x, y, z);
    group.rotation.y = side > 0 ? -Math.PI / 2 : Math.PI / 2;

    let isSettlement = false;
    let settlementConfig = null;
    let poiConfig = null;

    if (siteDef.type === 'SETTLEMENT_HUB') {
      isSettlement = true;
      settlementConfig = CONFIG.SETTLEMENTS[siteDef.settlementKey];
      poiConfig = {
        name: siteDef.name,
        icon: settlementConfig ? settlementConfig.icon : '🏘️',
        isSettlement: true,
        dangerLevel: 0.02
      };
      this.buildSettlementHub(group, siteDef.settlementKey);
    } else {
      poiConfig = CONFIG.POI_TYPES[siteDef.type] || CONFIG.POI_TYPES.OVERTURNED_CONVOY;
      poiConfig = {
        ...poiConfig,
        name: siteDef.name || poiConfig.name
      };

      if (siteDef.type === 'COASTAL_FISHERY_RUIN') {
        this.buildFisheryRuin(group);
      } else if (siteDef.type === 'DESERT_CARAVAN_POST') {
        this.buildCaravanPost(group);
      } else if (siteDef.type === 'SAVANNA_RANGER_STATION') {
        this.buildSavannaRangerSite(group);
      } else if (siteDef.type === 'JUNGLE_BOTANICAL_LAB') {
        this.buildJungleBotanicalLab(group);
      } else if (siteDef.type === 'ALPINE_TUNNEL_SHELTER') {
        this.buildAlpineShelter(group);
      } else if (siteDef.type === 'TAIGA_LOGGING_DEPOT' || siteDef.type === 'FORESTRY_LUMBER_YARD') {
        this.buildLumberYard(group);
      } else if (siteDef.type === 'REFINERY_DEPOT') {
        this.buildRefinerySite(group);
      } else if (siteDef.type === 'HYDRO_PUMP_STATION') {
        this.buildHydroStation(group);
      } else if (siteDef.type === 'IONIC_RADAR_ARRAY') {
        this.buildRadarSite(group);
      } else if (siteDef.type === 'QUARRY_CRUSHER_SITE') {
        this.buildQuarryCrusher(group);
      } else if (siteDef.type === 'POLAR_METAR_SHELTER') {
        this.buildPolarShelter(group);
      } else if (siteDef.type === 'MILITARY_CHECKPOINT') {
        this.buildCheckpoint(group);
      } else {
        this.buildConvoy(group);
      }
    }

    // Glowing Signpost / Beacon on the shoulder
    const beaconLight = new THREE.PointLight(isSettlement ? 0x44ffaa : 0xffaa22, isSettlement ? 2.0 : 1.4, 22);
    beaconLight.position.set(0, 4.5, 0);
    group.add(beaconLight);

    const beaconGeo = new THREE.SphereGeometry(0.35, 8, 8);
    const beaconMesh = new THREE.Mesh(beaconGeo, isSettlement ? this.matSettlementLight : this.matBeacon);
    beaconMesh.position.set(0, 4.5, 0);
    group.add(beaconMesh);

    this.scene.add(group);

    const poiData = {
      siteDef: siteDef,
      typeKey: siteDef.type,
      config: poiConfig,
      isSettlement: isSettlement,
      settlementKey: siteDef.settlementKey,
      settlementConfig: settlementConfig,
      position: new THREE.Vector3(x, y, z),
      meshGroup: group,
      scavenged: false,
      loot: poiConfig.lootTable ? [...poiConfig.lootTable] : []
    };

    this.pois.push(poiData);
  }

  // --- 3D ARCHITECTURAL BUILDERS ---

  buildSettlementHub(group, key) {
    // 1. Heavy reinforced concrete foundation apron
    const pad = new THREE.Mesh(new THREE.BoxGeometry(22, 0.4, 26), this.matConcrete);
    pad.position.set(0, 0.2, 0);
    pad.receiveShadow = true;
    group.add(pad);

    // Hazard-striped entrance curb on the roadside edge
    const curb = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.45, 26), this.matWarning);
    curb.position.set(10.8, 0.22, 0);
    group.add(curb);

    // ==========================================
    // 2. ARCTIC SERVICE STATION / CANOPY & PUMPS
    // ==========================================
    // Elevated Canopy Roof (spanning over fueling lane)
    const canopyRoof = new THREE.Mesh(new THREE.BoxGeometry(9.0, 0.6, 12.0), this.matMetalDark);
    canopyRoof.position.set(5.5, 4.8, 0);
    group.add(canopyRoof);

    // Canopy Fascia Signboard (Illuminated perimeter band)
    const fascia = new THREE.Mesh(new THREE.BoxGeometry(9.1, 0.35, 12.1), this.matNeonGreen);
    fascia.position.set(5.5, 4.8, 0);
    group.add(fascia);

    // 4 Heavy Steel Canopy Columns
    [[-1.8, -4.5], [-1.8, 4.5], [1.8, -4.5], [1.8, 4.5]].forEach(([cx, cz]) => {
      const col = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.22, 4.6, 8), this.matCanopy);
      col.position.set(5.5 + cx, 2.3, cz);
      group.add(col);
    });

    // Dual Fuel Pump Concrete Island (Raised curb)
    const pumpIsland = new THREE.Mesh(new THREE.BoxGeometry(1.6, 0.35, 7.5), this.matConcrete);
    pumpIsland.position.set(5.5, 0.35, 0);
    group.add(pumpIsland);

    // Dual Gas & Diesel Fuel Dispensers
    [-2.2, 2.2].forEach((pz, i) => {
      const pumpBody = new THREE.Mesh(new THREE.BoxGeometry(0.85, 1.8, 0.95), this.matPump);
      pumpBody.position.set(5.5, 1.25, pz);
      group.add(pumpBody);

      // Lighted Digital Gallon/Price Display Meter
      const meterFace = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.4, 0.4), this.matLitWindow);
      meterFace.position.set(5.5, 1.65, pz);
      group.add(meterFace);

      // Yellow/Black Impact Protection Bollards
      [-0.7, 0.7].forEach((bx) => {
        const bollard = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 1.0, 6), this.matWarning);
        bollard.position.set(5.5 + bx, 0.7, pz + (bx > 0 ? 0.7 : -0.7));
        group.add(bollard);
      });
    });

    // Warm Under-Canopy Lighting (Illuminates vehicle while refueling)
    const canopyLight = new THREE.SpotLight(0xfff7ed, 3.8, 20, Math.PI / 3, 0.5, 1.2);
    canopyLight.position.set(5.5, 4.6, 0);
    canopyLight.target.position.set(5.5, 0, 0);
    canopyLight.castShadow = false;
    group.add(canopyLight);
    group.add(canopyLight.target);

    // ==========================================
    // 3. ROADSIDE NEON PYLON BILLBOARD (TOTEM)
    // ==========================================
    // Visible from hundreds of meters along highway
    const pylonGroup = new THREE.Group();
    pylonGroup.position.set(10.5, 0, 9.5);

    // Twin High-mast steel pylons
    [-0.6, 0.6].forEach((px) => {
      const mast = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.16, 9.2, 6), this.matCanopy);
      mast.position.set(px, 4.6, 0);
      pylonGroup.add(mast);
    });

    // Large Lightbox Billboard ("ARCTIC 24/7 DIESEL • MOTEL • CB 19")
    const signBox = new THREE.Mesh(new THREE.BoxGeometry(2.4, 3.2, 0.3), this.matMetalDark);
    signBox.position.set(0, 6.8, 0);
    pylonGroup.add(signBox);

    // Glowing Neon panels on the totem
    const neonTop = new THREE.Mesh(new THREE.BoxGeometry(2.1, 0.7, 0.35), this.matNeonGreen); // 24/7 DIESEL
    neonTop.position.set(0, 7.6, 0);
    pylonGroup.add(neonTop);

    const neonMid = new THREE.Mesh(new THREE.BoxGeometry(2.1, 0.6, 0.35), this.matNeonRed); // HOT FOOD / DINER
    neonMid.position.set(0, 6.7, 0);
    pylonGroup.add(neonMid);

    const neonBtm = new THREE.Mesh(new THREE.BoxGeometry(2.1, 0.5, 0.35), this.matNeonBlue); // MOTEL / CB 19
    neonBtm.position.set(0, 5.8, 0);
    pylonGroup.add(neonBtm);

    // Neon Pylon Beacon Light
    const pylonLight = new THREE.PointLight(0x10b981, 2.4, 28);
    pylonLight.position.set(0, 7.2, 0.8);
    pylonGroup.add(pylonLight);
    group.add(pylonGroup);

    // ==========================================
    // 4. MAIN GENERAL STORE & DINER CABIN
    // ==========================================
    const cabinGroup = new THREE.Group();
    cabinGroup.position.set(-4.5, 0, -2.0);

    // Main Log Walls
    const cabinBody = new THREE.Mesh(new THREE.BoxGeometry(8.5, 4.2, 11.5), this.matWood);
    cabinBody.position.set(0, 2.1, 0);
    cabinBody.castShadow = true;
    cabinGroup.add(cabinBody);

    // Dark Shingle Pitched Roof
    const roof = new THREE.Mesh(new THREE.ConeGeometry(7.5, 2.4, 4), this.matRoofShingle);
    roof.position.set(0, 5.2, 0);
    roof.rotation.y = Math.PI / 4;
    cabinGroup.add(roof);

    // Snow Cap on Roof Top
    const snowCap = new THREE.Mesh(new THREE.BoxGeometry(6.5, 0.25, 9.5), this.matSnowTop);
    snowCap.position.set(0, 4.8, 0);
    cabinGroup.add(snowCap);

    // Glowing Warm Windows (Interior light escaping to exterior)
    // Front windows facing player approach
    [[-3.2, 2.0, 5.8], [1.2, 2.0, 5.8], [3.2, 2.0, 5.8]].forEach(([wx, wy, wz]) => {
      const win = new THREE.Mesh(new THREE.BoxGeometry(1.4, 1.2, 0.2), this.matLitWindow);
      win.position.set(wx, wy, wz);
      cabinGroup.add(win);
    });

    // Side windows
    [[-2.5, 2.0, 0], [2.5, 2.0, 0]].forEach(([wz, wy, wx]) => {
      const win = new THREE.Mesh(new THREE.BoxGeometry(0.2, 1.2, 1.4), this.matLitWindow);
      win.position.set(4.3, wy, wz);
      cabinGroup.add(win);
    });

    // Cozy Interior Glow escaping through windows
    const windowGlow = new THREE.PointLight(0xffd166, 2.8, 22);
    windowGlow.position.set(0, 2.2, 3.5);
    cabinGroup.add(windowGlow);

    // Entrance Porch & Overhang
    const porchRoof = new THREE.Mesh(new THREE.BoxGeometry(4.0, 0.25, 2.8), this.matRoofShingle);
    porchRoof.position.set(-1.0, 3.2, 6.8);
    cabinGroup.add(porchRoof);

    // Porch wooden pillars
    [-2.6, 0.6].forEach((px) => {
      const col = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 3.0, 6), this.matWood);
      col.position.set(px, 1.5, 7.8);
      cabinGroup.add(col);
    });

    // Porch Lantern (Warm Amber)
    const lantern = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.4, 0.3), this.matLitWindow);
    lantern.position.set(-1.0, 2.8, 6.6);
    cabinGroup.add(lantern);

    // Stone Chimney with smoke stack
    const chimney = new THREE.Mesh(new THREE.BoxGeometry(0.9, 5.8, 0.9), this.matConcrete);
    chimney.position.set(-3.8, 3.0, -4.2);
    cabinGroup.add(chimney);

    group.add(cabinGroup);

    // ==========================================
    // 5. MECHANICAL WORKSHOP & STORAGE COMPOUND
    // ==========================================
    const workshop = new THREE.Mesh(new THREE.BoxGeometry(6.5, 3.4, 7.0), this.matCargo);
    workshop.position.set(-5.5, 1.7, 8.5);
    group.add(workshop);

    // Roll-up industrial garage door
    const shutter = new THREE.Mesh(new THREE.BoxGeometry(3.2, 2.8, 0.15), this.matWarning);
    shutter.position.set(-5.5, 1.4, 12.05);
    group.add(shutter);

    // Stacked Heavy All-Terrain Tires
    [-1.2, 1.2].forEach((tx, i) => {
      for (let t = 0; t < 3; t++) {
        const tire = new THREE.Mesh(new THREE.CylinderGeometry(0.52, 0.52, 0.38, 12), this.matMetalDark);
        tire.position.set(-1.5 + tx * 0.5, 0.2 + t * 0.38, 10.5);
        group.add(tire);
      }
    });

    // ==========================================
    // 6. SURVIVOR FIRE BARREL (WARM FLICKER)
    // ==========================================
    const fireBarrel = new THREE.Mesh(new THREE.CylinderGeometry(0.42, 0.42, 1.0, 8), this.matMetalDark);
    fireBarrel.position.set(1.5, 0.5, 5.5);
    group.add(fireBarrel);

    const flames = new THREE.Mesh(new THREE.ConeGeometry(0.35, 0.75, 6), this.matFireGlow);
    flames.position.set(1.5, 1.2, 5.5);
    group.add(flames);

    const fireLight = new THREE.PointLight(0xff6b2b, 2.6, 16);
    fireLight.position.set(1.5, 1.3, 5.5);
    group.add(fireLight);

    // Benches / Wooden Crate seating around fire
    const crate = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.65, 0.9), this.matWood);
    crate.position.set(2.8, 0.35, 5.5);
    group.add(crate);

    // ==========================================
    // 7. GUARD PERIMETER TOWER
    // ==========================================
    const tower = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.28, 8.5, 6), this.matCanopy);
    tower.position.set(-9.5, 4.25, -9.5);
    group.add(tower);

    const towerCab = new THREE.Mesh(new THREE.BoxGeometry(2.2, 1.6, 2.2), this.matMetalDark);
    towerCab.position.set(-9.5, 8.0, -9.5);
    group.add(towerCab);

    const floodLight = new THREE.SpotLight(0xfffaed, 3.2, 32, Math.PI / 3.5, 0.4);
    floodLight.position.set(-9.5, 8.5, -9.5);
    floodLight.target.position.set(2.0, 0, 0);
    floodLight.castShadow = false;
    group.add(floodLight);
    group.add(floodLight.target);
  }

  buildRefinerySite(group) {
    // 2 Cylindrical Fuel Tanks
    [-3.0, 3.0].forEach((pz) => {
      const tank = new THREE.Mesh(new THREE.CylinderGeometry(2.2, 2.2, 4.5, 12), this.matCargo);
      tank.position.set(0, 2.25, pz);
      tank.castShadow = true;
      group.add(tank);
    });

    // Overhead pipe connecting tanks
    const pipe = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.18, 6.0, 6), this.matCanopy);
    pipe.rotation.x = Math.PI / 2;
    pipe.position.set(0, 4.0, 0);
    group.add(pipe);

    // Manometer & valve station
    const valveBox = new THREE.Mesh(new THREE.BoxGeometry(1.4, 1.6, 1.8), this.matWarning);
    valveBox.position.set(2.8, 0.8, 0);
    group.add(valveBox);
  }

  buildLumberYard(group) {
    // Stack of massive treated logs
    for (let row = 0; row < 3; row++) {
      const count = 4 - row;
      for (let i = 0; i < count; i++) {
        const log = new THREE.Mesh(new THREE.CylinderGeometry(0.35, 0.35, 7.5, 8), this.matWood);
        log.rotation.x = Math.PI / 2;
        log.position.set((i - count / 2 + 0.5) * 0.75, 0.35 + row * 0.6, 0);
        log.castShadow = true;
        group.add(log);
      }
    }

    // Rustic open shed
    const shed = new THREE.Mesh(new THREE.BoxGeometry(6, 0.3, 4), this.matWood);
    shed.position.set(0, 3.2, -4);
    group.add(shed);
  }

  buildHydroStation(group) {
    // Concrete canal head & gate
    const gate = new THREE.Mesh(new THREE.BoxGeometry(1.2, 3.5, 6.0), this.matConcrete);
    gate.position.set(0, 1.75, 0);
    group.add(gate);

    // Large water wheel or impeller hub
    const impeller = new THREE.Mesh(new THREE.CylinderGeometry(1.6, 1.6, 0.8, 8), this.matCanopy);
    impeller.rotation.z = Math.PI / 2;
    impeller.position.set(1.5, 1.6, 0);
    group.add(impeller);

    // Retention basin railing
    const rail = new THREE.Mesh(new THREE.BoxGeometry(4.0, 1.0, 0.2), this.matWarning);
    rail.position.set(2.0, 0.5, 2.5);
    group.add(rail);
  }

  buildRadarSite(group) {
    // Concrete base pedestal
    const pedestal = new THREE.Mesh(new THREE.CylinderGeometry(2.0, 2.5, 1.5, 8), this.matConcrete);
    pedestal.position.y = 0.75;
    group.add(pedestal);

    // Parabolic dish structure
    const dish = new THREE.Mesh(new THREE.CylinderGeometry(3.0, 0.8, 0.6, 12), this.matCanopy);
    dish.position.set(0, 3.2, 0);
    dish.rotation.x = 0.6;
    dish.castShadow = true;
    group.add(dish);

    // Central feed horn probe
    const horn = new THREE.Mesh(new THREE.ConeGeometry(0.3, 1.8, 6), this.matWarning);
    horn.position.set(0, 3.8, 0.8);
    horn.rotation.x = 0.6;
    group.add(horn);
  }

  buildQuarryCrusher(group) {
    // Heavy rock crusher hopper
    const hopper = new THREE.Mesh(new THREE.CylinderGeometry(2.4, 1.2, 3.0, 4), this.matCargo);
    hopper.position.set(0, 2.8, 0);
    hopper.castShadow = true;
    group.add(hopper);

    // Heavy support struts
    [-1.8, 1.8].forEach((px) => {
      [-1.8, 1.8].forEach((pz) => {
        const strut = new THREE.Mesh(new THREE.BoxGeometry(0.3, 2.8, 0.3), this.matCanopy);
        strut.position.set(px, 1.4, pz);
        group.add(strut);
      });
    });

    // Pile of crushed iron ore
    const orePile = new THREE.Mesh(new THREE.ConeGeometry(2.2, 1.4, 7), this.matConcrete);
    orePile.position.set(3.5, 0.7, 0);
    group.add(orePile);
  }

  buildPolarShelter(group) {
    // Geodesic / Insulated Arctic Quonset pod
    const pod = new THREE.Mesh(new THREE.CylinderGeometry(2.2, 2.2, 5.0, 10), this.matWarning);
    pod.rotation.x = Math.PI / 2;
    pod.position.set(0, 1.6, 0);
    pod.castShadow = true;
    group.add(pod);

    // Insulated airlock door
    const door = new THREE.Mesh(new THREE.BoxGeometry(1.2, 1.8, 0.4), this.matCanopy);
    door.position.set(0, 0.9, 2.6);
    group.add(door);
  }

  buildCheckpoint(group) {
    // Concrete bunker guard post
    const bunker = new THREE.Mesh(new THREE.BoxGeometry(4.0, 2.8, 4.0), this.matConcrete);
    bunker.position.set(0, 1.4, 0);
    bunker.castShadow = true;
    group.add(bunker);

    // Slit visor aperture
    const visor = new THREE.Mesh(new THREE.BoxGeometry(2.5, 0.3, 0.2), this.matCanopy);
    visor.position.set(0, 1.8, 2.05);
    group.add(visor);

    // Striped barrier boom arm
    const barrier = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 5.5, 6), this.matWarning);
    barrier.rotation.z = Math.PI / 2;
    barrier.position.set(2.8, 1.1, 1.5);
    group.add(barrier);
  }

  buildConvoy(group) {
    // Overturned tractor-trailer cab
    const cab = new THREE.Mesh(new THREE.BoxGeometry(2.6, 2.8, 4.8), this.matCargo);
    cab.position.set(0, 1.4, -2.5);
    cab.rotation.y = 0.35;
    cab.castShadow = true;
    group.add(cab);

    // Overturned shipping container
    const container = new THREE.Mesh(new THREE.BoxGeometry(2.6, 2.6, 9.0), this.matCanopy);
    container.position.set(0.8, 1.3, 3.5);
    container.rotation.z = Math.PI / 2.3;
    container.castShadow = true;
    group.add(container);

    // Spilled crates
    for (let i = 0; i < 3; i++) {
      const crate = new THREE.Mesh(new THREE.BoxGeometry(1.0, 0.9, 1.0), this.matWood);
      crate.position.set(1.5 + (i - 1) * 1.2, 0.45, 1.5 + i * 1.2);
      crate.castShadow = true;
      group.add(crate);
    }
  }

  buildFisheryRuin(group) {
    // Coastal stone watchtower & old fishery storehouse
    const tower = new THREE.Mesh(new THREE.CylinderGeometry(2.4, 3.0, 8.5, 8), this.matConcrete);
    tower.position.set(-2, 4.25, 0);
    tower.castShadow = true;
    group.add(tower);

    // Stone workshop ruin
    const shed = new THREE.Mesh(new THREE.BoxGeometry(5.5, 2.8, 6.0), this.matConcrete);
    shed.position.set(4, 1.4, -1);
    shed.castShadow = true;
    group.add(shed);

    // Weathered timber pier
    const dock = new THREE.Mesh(new THREE.BoxGeometry(3.0, 0.35, 10.0), this.matWood);
    dock.position.set(1, 0.2, 6.5);
    group.add(dock);

    // Amber harbor beacon light
    const lantern = new THREE.PointLight(0xffaa33, 2.2, 22);
    lantern.position.set(-2, 8.8, 0);
    group.add(lantern);
  }

  buildCaravanPost(group) {
    // Adobe mudbrick cistern and oasis outpost
    const adobeWall = new THREE.Mesh(new THREE.BoxGeometry(8.0, 2.8, 10.0), this.matWarning);
    adobeWall.position.set(0, 1.4, 0);
    adobeWall.castShadow = true;
    group.add(adobeWall);

    // Water reservoir dome
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(2.2, 8, 8, 0, Math.PI * 2, 0, Math.PI * 0.5),
      this.matConcrete
    );
    dome.position.set(-5, 0, -2);
    group.add(dome);

    // Desert canopy fabric shelter
    const cloth = new THREE.Mesh(new THREE.BoxGeometry(4.5, 0.1, 5.0), this.matCargo);
    cloth.position.set(4, 2.6, 2);
    group.add(cloth);

    const oasisLight = new THREE.PointLight(0xf59e0b, 1.8, 18);
    oasisLight.position.set(0, 3.2, 0);
    group.add(oasisLight);
  }

  buildSavannaRangerSite(group) {
    // Elevated safari ranger watchtower
    const towerPad = new THREE.Mesh(new THREE.BoxGeometry(5.0, 0.3, 5.0), this.matWood);
    towerPad.position.set(0, 4.8, 0);
    group.add(towerPad);

    // 4 Splayed timber stilts
    [-1.8, 1.8].forEach((lx) => {
      [-1.8, 1.8].forEach((lz) => {
        const post = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.22, 5.0, 5), this.matWood);
        post.position.set(lx, 2.5, lz);
        post.castShadow = true;
        group.add(post);
      });
    });

    const cabin = new THREE.Mesh(new THREE.BoxGeometry(4.2, 2.4, 4.2), this.matCanopy);
    cabin.position.set(0, 6.1, 0);
    cabin.castShadow = true;
    group.add(cabin);

    // Radio transmitter mast
    const antenna = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.04, 5.5, 4), this.matMetalDark);
    antenna.position.set(1.8, 9.8, 1.8);
    group.add(antenna);
  }

  buildJungleBotanicalLab(group) {
    // Equatorial stilt research station
    const platform = new THREE.Mesh(new THREE.BoxGeometry(9.0, 0.4, 11.0), this.matWood);
    platform.position.set(0, 2.2, 0);
    group.add(platform);

    // Stilts
    [-3.5, 3.5].forEach((px) => {
      [-4.5, 4.5].forEach((pz) => {
        const stilt = new THREE.Mesh(new THREE.CylinderGeometry(0.2, 0.25, 2.4, 5), this.matWood);
        stilt.position.set(px, 1.1, pz);
        group.add(stilt);
      });
    });

    const lab = new THREE.Mesh(new THREE.BoxGeometry(7.5, 3.0, 8.5), this.matCanopy);
    lab.position.set(0, 3.8, 0);
    lab.castShadow = true;
    group.add(lab);

    // Green botanical biolab beacon
    const bioLight = new THREE.PointLight(0x10b981, 2.0, 20);
    bioLight.position.set(0, 5.8, 0);
    group.add(bioLight);
  }

  buildAlpineShelter(group) {
    // Concrete avalanche gallery shelter with sloping deflection roof
    const roof = new THREE.Mesh(new THREE.BoxGeometry(16, 0.7, 14), this.matConcrete);
    roof.position.set(0, 5.4, 0);
    roof.rotation.z = 0.18;
    group.add(roof);

    // Reinforced concrete support pillars
    [-5, 0, 5].forEach((pz) => {
      const col = new THREE.Mesh(new THREE.BoxGeometry(1.2, 5.4, 1.2), this.matConcrete);
      col.position.set(-6.5, 2.7, pz);
      col.castShadow = true;
      group.add(col);
    });

    // Emergency rescue refuge pod
    const cabin = new THREE.Mesh(new THREE.BoxGeometry(4.5, 2.6, 5.0), this.matMetalDark);
    cabin.position.set(4.5, 1.3, 0);
    cabin.castShadow = true;
    group.add(cabin);

    const rescueLight = new THREE.PointLight(0x38bdf8, 2.2, 22);
    rescueLight.position.set(4.5, 3.2, 0);
    group.add(rescueLight);
  }
}
