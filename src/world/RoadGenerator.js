/**
 * THE LONG MERIDIAN - Enhanced Procedural 3D Road Ribbon Generator
 * Generates wide 2-lane crowned highway geometry with distinct gravel shoulders,
 * asphalt markings, drainage ditches, organic rolling terrain, delineator posts and guardrails.
 */

import { CONFIG } from '../config.js';
import { TextureGenerator } from '../engine/TextureGenerator.js';

export class RoadGenerator {
  constructor(scene, biomeManager) {
    this.scene = scene;
    this.biomeManager = biomeManager;

    this.chunks = [];
    this.nextChunkZ = 0;
    this.lastChunkX = 0;
    this.lastChunkAngle = 0;

    // Generated textures
    this.asphaltTexture = TextureGenerator.createAsphaltTexture();
    this.terrainTexture = TextureGenerator.createTerrainTexture('#1c231c');

    // Materials cache for road surfaces
    this.materials = {
      asphalt: new THREE.MeshStandardMaterial({
        map: this.asphaltTexture,
        roughness: 0.78,
        metalness: 0.12
      }),
      dirt: new THREE.MeshStandardMaterial({
        color: 0x3d2b1f,
        roughness: 0.95,
        metalness: 0.05
      }),
      gravel: new THREE.MeshStandardMaterial({
        color: 0x483e36,
        roughness: 0.9,
        metalness: 0.15
      }),
      ice: new THREE.MeshStandardMaterial({
        color: 0x9fb4c2,
        roughness: 0.2,
        metalness: 0.4
      }),
      sludge: new THREE.MeshStandardMaterial({
        color: 0x243a1a,
        roughness: 0.35,
        metalness: 0.2,
        emissive: 0x0c2206,
        emissiveIntensity: 0.4
      }),
      steel: new THREE.MeshStandardMaterial({
        color: 0x555b62,
        roughness: 0.45,
        metalness: 0.75
      }),
      curb: new THREE.MeshStandardMaterial({
        color: 0x1f1c1a,
        roughness: 0.9
      }),
      puddle: new THREE.MeshStandardMaterial({
        color: 0x141a22,
        roughness: 0.04,
        metalness: 0.95,
        transparent: true,
        opacity: 0.85
      }),
      reflectorRed: new THREE.MeshBasicMaterial({
        color: 0xef4444
      }),
      reflectorWhite: new THREE.MeshBasicMaterial({
        color: 0xf8fafc
      }),
      delineatorPost: new THREE.MeshStandardMaterial({
        color: 0xe2e8f0,
        roughness: 0.85
      }),
      terrain: new THREE.MeshStandardMaterial({
        map: this.terrainTexture,
        roughness: 0.95
      })
    };

    // Initialize initial stretch of road ahead
    for (let i = 0; i < CONFIG.WORLD.VISIBLE_CHUNKS; i++) {
      this.generateChunk();
    }
  }

  generateChunk() {
    const chunkLength = CONFIG.WORLD.CHUNK_LENGTH;
    const startZ = this.nextChunkZ;
    const endZ = startZ + chunkLength;
    const segments = CONFIG.WORLD.ROAD_SEGMENTS_PER_CHUNK;
    const stepZ = chunkLength / segments;

    const surface = this.biomeManager.getCurrentSurface(startZ);
    const biome = this.biomeManager.currentBiome;

    // Generous 24m highway width across all biomes (2 wide lanes + emergency shoulders)
    let baseWidth = CONFIG.WORLD.BASE_ROAD_WIDTH || 24.0;
    if (biome.id === 'iron_gorge') baseWidth = 20.0; // Mountain canyon pass
    else if (biome.id === 'black_pine_woods') baseWidth = 24.0;
    else if (biome.id === 'permafrost_highlands') baseWidth = 23.0;

    const points = [];
    let curX = this.lastChunkX;
    let curAngle = this.lastChunkAngle;

    for (let s = 0; s <= segments; s++) {
      const z = startZ + s * stepZ;
      const y = Math.sin(z * 0.018) * 1.1 + Math.cos(z * 0.006) * 1.8;
      const width = baseWidth + Math.sin(z * 0.035) * 0.8;

      points.push({ x: curX, y: y, z: z, width: width });

      if (s < segments) {
        // Gentle, sweeping highway curves typical of real northern corridors
        const curvatureDelta = (Math.sin(z * 0.012) * 0.5 + Math.sin(z * 0.004) * 1.1) * 0.06;
        curAngle += curvatureDelta;
        curX += Math.sin(curAngle) * stepZ * 0.45;
      }
    }

    this.lastChunkX = curX;
    this.lastChunkAngle = curAngle;
    this.nextChunkZ = endZ;

    const chunkMeshGroup = this.buildChunkMesh(points, surface, biome);
    this.scene.add(chunkMeshGroup);

    const chunkData = {
      startZ: startZ,
      endZ: endZ,
      surface: surface,
      points: points,
      meshGroup: chunkMeshGroup
    };

    this.chunks.push(chunkData);
    return chunkData;
  }

  buildChunkMesh(points, surface, biome) {
    const group = new THREE.Group();
    const numPoints = points.length;

    // 1. Crowned 5-Vertex Highway Deck Mesh
    // Points across cross-section:
    // v0: Left Shoulder Edge (u = 0.00, y - 0.03)
    // v1: Left Fog Line / Asphalt Margin (u = 0.122, y + 0.04)
    // v2: Center Crown Crest (u = 0.500, y + 0.08)
    // v3: Right Fog Line / Asphalt Margin (u = 0.878, y + 0.04)
    // v4: Right Shoulder Edge (u = 1.00, y - 0.03)
    const roadGeo = new THREE.BufferGeometry();
    const positions = [];
    const normals = [];
    const uvs = [];
    const indices = [];

    // 2. Multi-tier Undulating Terrain Skirt
    const terrainGeo = new THREE.BufferGeometry();
    const tPositions = [];
    const tNormals = [];
    const tUvs = [];
    const tIndices = [];

    const terrainWidth = 110.0;

    for (let i = 0; i < numPoints; i++) {
      const p = points[i];
      const halfW = p.width * 0.5;
      const pavedHalfW = halfW * 0.78; // Paved carriageway ~10.5m, gravel shoulder ~2.0m each side

      // --- ROAD DECK (5 vertices per step) ---
      const vZ = p.z;
      const vUvY = p.z * 0.06;

      // v0: Left outer gravel shoulder
      positions.push(p.x - halfW, p.y + 0.01, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.0, vUvY);

      // v1: Left white fog line / paved asphalt edge
      positions.push(p.x - pavedHalfW, p.y + 0.045, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.122, vUvY);

      // v2: Center highway crown
      positions.push(p.x, p.y + 0.075, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.5, vUvY);

      // v3: Right white fog line / paved asphalt edge
      positions.push(p.x + pavedHalfW, p.y + 0.045, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.878, vUvY);

      // v4: Right outer gravel shoulder
      positions.push(p.x + halfW, p.y + 0.01, vZ);
      normals.push(0, 1, 0);
      uvs.push(1.0, vUvY);

      // --- TERRAIN SKIRT (6 vertices per step across ditches and rolling hills) ---
      // Left ditch, Left shoulder interface, Right shoulder interface, Right ditch, Outermost terrain hills
      const hillNoiseL = Math.sin(p.z * 0.03) * 2.8 + Math.cos(p.z * 0.01) * 4.5;
      const hillNoiseR = Math.sin(p.z * 0.025 + 1.2) * 3.2 + Math.cos(p.z * 0.008) * 5.0;

      const ditchDepthL = p.y - 0.35 + Math.sin(p.z * 0.08) * 0.15;
      const ditchDepthR = p.y - 0.35 + Math.cos(p.z * 0.08) * 0.15;
      const outerHeightL = p.y + hillNoiseL;
      const outerHeightR = p.y + hillNoiseR;

      // t0: Far Left Wilderness Horizon
      tPositions.push(p.x - halfW - terrainWidth, outerHeightL, vZ);
      // t1: Left Roadside Drainage Ditch Bottom
      tPositions.push(p.x - halfW - 2.8, ditchDepthL, vZ);
      // t2: Left Shoulder Connect
      tPositions.push(p.x - halfW, p.y - 0.02, vZ);
      // t3: Right Shoulder Connect
      tPositions.push(p.x + halfW, p.y - 0.02, vZ);
      // t4: Right Roadside Drainage Ditch Bottom
      tPositions.push(p.x + halfW + 2.8, ditchDepthR, vZ);
      // t5: Far Right Wilderness Horizon
      tPositions.push(p.x + halfW + terrainWidth, outerHeightR, vZ);

      const tUvY = p.z * 0.035;
      tUvs.push(0.0, tUvY, 0.35, tUvY, 0.48, tUvY, 0.52, tUvY, 0.65, tUvY, 1.0, tUvY);
      tNormals.push(0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0);

      // Indices for Quads
      if (i < numPoints - 1) {
        // Road ribbon quads (4 quad columns = 8 triangles)
        const b = i * 5;
        // Col 0: v0 -> v1
        indices.push(b, b + 5, b + 1, b + 1, b + 5, b + 6);
        // Col 1: v1 -> v2
        indices.push(b + 1, b + 6, b + 2, b + 2, b + 6, b + 7);
        // Col 2: v2 -> v3
        indices.push(b + 2, b + 7, b + 3, b + 3, b + 7, b + 8);
        // Col 3: v3 -> v4
        indices.push(b + 3, b + 8, b + 4, b + 4, b + 8, b + 9);

        // Terrain quads (t0->t1, t1->t2, and t3->t4, t4->t5)
        const tb = i * 6;
        // Left outer hill
        tIndices.push(tb, tb + 6, tb + 1, tb + 1, tb + 6, tb + 7);
        // Left ditch to shoulder
        tIndices.push(tb + 1, tb + 7, tb + 2, tb + 2, tb + 7, tb + 8);
        // Right shoulder to ditch
        tIndices.push(tb + 3, tb + 9, tb + 4, tb + 4, tb + 9, tb + 10);
        // Right ditch to outer hill
        tIndices.push(tb + 4, tb + 10, tb + 5, tb + 5, tb + 10, tb + 11);
      }
    }

    roadGeo.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
    roadGeo.setAttribute('normal', new THREE.Float32BufferAttribute(normals, 3));
    roadGeo.setAttribute('uv', new THREE.Float32BufferAttribute(uvs, 2));
    roadGeo.setIndex(indices);
    roadGeo.computeVertexNormals();

    let mat = this.materials.asphalt;
    if (surface.name.includes('Fango')) mat = this.materials.dirt;
    if (surface.name.includes('Ghiaccio')) mat = this.materials.ice;
    if (surface.name.includes('Tossica')) mat = this.materials.sludge;
    if (surface.name.includes('Ghiaia')) mat = this.materials.gravel;
    if (surface.name.includes('Acciaio')) mat = this.materials.steel;

    const roadMesh = new THREE.Mesh(roadGeo, mat);
    roadMesh.receiveShadow = true;
    group.add(roadMesh);

    // 2. Terrain Skirt Mesh
    terrainGeo.setAttribute('position', new THREE.Float32BufferAttribute(tPositions, 3));
    terrainGeo.setAttribute('normal', new THREE.Float32BufferAttribute(tNormals, 3));
    terrainGeo.setAttribute('uv', new THREE.Float32BufferAttribute(tUvs, 2));
    terrainGeo.setIndex(tIndices);
    terrainGeo.computeVertexNormals();

    const tMat = this.materials.terrain.clone();
    tMat.color.setHex(biome.colorGround);
    const terrainMesh = new THREE.Mesh(terrainGeo, tMat);
    terrainMesh.receiveShadow = true;
    group.add(terrainMesh);

    // 3. Highway Delineator Posts (Paline Segnadelimitatrici)
    this.addDelineators(group, points);

    // 4. Smooth Reflective Road Puddles
    if (biome.id !== 'iron_gorge') {
      this.addPuddles(group, points);
    }

    // 5. Continuous W-Beam Highway Guardrails on canyon gorges and deep bridge passes
    if (biome.id === 'iron_gorge' || biome.id === 'flooded_marshland') {
      this.addGuardrails(group, points);
    }

    return group;
  }

  addDelineators(group, points) {
    const postMat = this.materials.delineatorPost;
    const reflRed = this.materials.reflectorRed;
    const reflWhite = this.materials.reflectorWhite;

    // Place delineators every ~20m along chunk
    for (let i = 2; i < points.length; i += 5) {
      const p = points[i];
      const shoulderEdge = p.width * 0.5 + 0.35;

      // 1. Right Delineator Post (with Red Reflector facing approaching car)
      const postGeo = new THREE.BoxGeometry(0.12, 0.95, 0.08);
      const rightPost = new THREE.Mesh(postGeo, postMat);
      rightPost.position.set(p.x + shoulderEdge, p.y + 0.46, p.z);
      rightPost.castShadow = true;
      group.add(rightPost);

      const rightRefl = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.18, 0.02), reflRed);
      rightRefl.position.set(p.x + shoulderEdge, p.y + 0.72, p.z - 0.045);
      group.add(rightRefl);

      // 2. Left Delineator Post (with White/Amber Reflector facing approaching car)
      const leftPost = new THREE.Mesh(postGeo, postMat);
      leftPost.position.set(p.x - shoulderEdge, p.y + 0.46, p.z);
      leftPost.castShadow = true;
      group.add(leftPost);

      const leftRefl = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.18, 0.02), reflWhite);
      leftRefl.position.set(p.x - shoulderEdge, p.y + 0.72, p.z - 0.045);
      group.add(leftRefl);
    }
  }

  addPuddles(group, points) {
    const puddleMat = this.materials.puddle;
    for (let i = 2; i < points.length - 2; i += 8) {
      if (Math.random() < 0.4) {
        const p = points[i];
        // Situate slightly off-center in the tire tracks
        const lateralOffset = (Math.random() > 0.5 ? 1 : -1) * (p.width * 0.22 + Math.random() * 1.2);
        const radiusX = 1.4 + Math.random() * 1.4;
        const radiusZ = 2.6 + Math.random() * 2.2;

        const puddleGeo = new THREE.PlaneGeometry(radiusX * 2, radiusZ * 2);
        const puddle = new THREE.Mesh(puddleGeo, puddleMat);
        puddle.rotation.x = -Math.PI / 2;
        puddle.position.set(p.x + lateralOffset, p.y + 0.052, p.z);
        puddle.receiveShadow = true;
        group.add(puddle);
      }
    }
  }

  addGuardrails(group, points) {
    const railMat = this.materials.steel;
    const postMat = this.materials.steel;
    const reflMat = this.materials.reflectorRed;

    for (let i = 0; i < points.length; i += 3) {
      const p = points[i];
      const railX = p.width * 0.5 + 0.65;

      // Left & Right galvanized C-channel posts
      const postGeo = new THREE.BoxGeometry(0.14, 1.05, 0.14);
      const leftPost = new THREE.Mesh(postGeo, postMat);
      leftPost.position.set(p.x - railX, p.y + 0.5, p.z);
      leftPost.castShadow = true;
      group.add(leftPost);

      const rightPost = new THREE.Mesh(postGeo, postMat);
      rightPost.position.set(p.x + railX, p.y + 0.5, p.z);
      rightPost.castShadow = true;
      group.add(rightPost);

      // Amber Cat's Eye Reflector facing approaching car (+Z)
      const leftRefl = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.14, 0.04), reflMat);
      leftRefl.position.set(p.x - railX + 0.08, p.y + 0.65, p.z - 0.08);
      group.add(leftRefl);

      const rightRefl = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.14, 0.04), reflMat);
      rightRefl.position.set(p.x + railX - 0.08, p.y + 0.65, p.z - 0.08);
      group.add(rightRefl);

      // Double-wave corrugated W-beam horizontal rail with proper curve orientation
      if (i < points.length - 3) {
        const pNext = points[i + 3];
        const spanDist = Math.hypot(pNext.x - p.x, pNext.z - p.z);
        const curveAngle = Math.atan2(pNext.x - p.x, pNext.z - p.z);
        const avgRailX = (p.width + pNext.width) * 0.25 + 0.65;
        const beamGeo = new THREE.BoxGeometry(0.12, 0.32, spanDist);

        const leftBeam = new THREE.Mesh(beamGeo, railMat);
        leftBeam.position.set(
          (p.x + pNext.x) * 0.5 - avgRailX,
          (p.y + pNext.y) * 0.5 + 0.65,
          (p.z + pNext.z) * 0.5
        );
        leftBeam.rotation.y = curveAngle;
        leftBeam.castShadow = true;
        group.add(leftBeam);

        const rightBeam = new THREE.Mesh(beamGeo, railMat);
        rightBeam.position.set(
          (p.x + pNext.x) * 0.5 + avgRailX,
          (p.y + pNext.y) * 0.5 + 0.65,
          (p.z + pNext.z) * 0.5
        );
        rightBeam.rotation.y = curveAngle;
        rightBeam.castShadow = true;
        group.add(rightBeam);
      }
    }
  }

  update(playerZ) {
    while (this.nextChunkZ < playerZ + (CONFIG.WORLD.VISIBLE_CHUNKS * CONFIG.WORLD.CHUNK_LENGTH)) {
      this.generateChunk();
    }

    const despawnZ = playerZ - CONFIG.WORLD.DESPAWN_DISTANCE;
    for (let i = this.chunks.length - 1; i >= 0; i--) {
      const chunk = this.chunks[i];
      if (chunk.endZ < despawnZ) {
        this.scene.remove(chunk.meshGroup);
        chunk.meshGroup.traverse((child) => {
          if (child.isMesh) {
            child.geometry.dispose();
          }
        });
        this.chunks.splice(i, 1);
      }
    }
  }

  getRoadInfoAt(z) {
    for (const chunk of this.chunks) {
      if (z >= chunk.startZ && z <= chunk.endZ) {
        const pts = chunk.points;
        for (let i = 0; i < pts.length - 1; i++) {
          if (z >= pts[i].z && z <= pts[i + 1].z) {
            const t = (z - pts[i].z) / (pts[i + 1].z - pts[i].z);
            const x = pts[i].x + (pts[i + 1].x - pts[i].x) * t;
            const y = pts[i].y + (pts[i + 1].y - pts[i].y) * t;
            const width = pts[i].width + (pts[i + 1].width - pts[i].width) * t;
            const dx = pts[i + 1].x - pts[i].x;
            const dz = pts[i + 1].z - pts[i].z;
            const roadAngle = Math.atan2(dx, dz);
            return { x, y, width, roadAngle, surface: chunk.surface, inBounds: true };
          }
        }
      }
    }

    // Smooth extrapolation if query is slightly ahead or behind active chunks (prevents jump to 0)
    if (this.chunks.length > 0) {
      const lastChunk = this.chunks[this.chunks.length - 1];
      const pts = lastChunk.points;
      const lastPt = pts[pts.length - 1];
      if (z > lastPt.z) {
        const extraZ = z - lastPt.z;
        return {
          x: lastPt.x + Math.sin(this.lastChunkAngle) * extraZ,
          y: lastPt.y,
          width: lastPt.width,
          roadAngle: this.lastChunkAngle,
          surface: lastChunk.surface,
          inBounds: true
        };
      }
      const firstChunk = this.chunks[0];
      const firstPt = firstChunk.points[0];
      if (z < firstPt.z) {
        return {
          x: firstPt.x,
          y: firstPt.y,
          width: firstPt.width,
          roadAngle: 0.0,
          surface: firstChunk.surface,
          inBounds: true
        };
      }
    }

    return { x: 0, y: 0, width: CONFIG.WORLD.BASE_ROAD_WIDTH || 24.0, roadAngle: 0.0, surface: CONFIG.SURFACES.ASPHALT, inBounds: false };
  }
}
