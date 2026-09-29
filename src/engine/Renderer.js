/**
 * THE LONG MERIDIAN - Enhanced Three.js WebGL Rendering Pipeline
 * High-fidelity lighting, volumetric fog, dynamic weather particles, soft shadows and exhaust smoke.
 */

export class Renderer {
  constructor(canvasContainer) {
    this.container = canvasContainer;
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.sunLight = null;
    this.hemiLight = null;
    this.ambientLight = null;
    this.fog = null;

    // Weather particles
    this.particleSystem = null;
    this.particleGeo = null;
    this.particleMat = null;
    this.particleCount = 900;

    // Exhaust smoke particles
    this.exhaustParticles = [];
    this.exhaustGroup = null;

    // Biome & Lightning Atmosphere
    this.currentBiome = null;
    this.audioEngine = null;
    this.lightningTimer = 0;
    this.nextLightningTime = 10 + Math.random() * 15;
    this.lightningFlash = 0; // 0 to 1

    this.init();
  }

  init() {
    // 1. Scene
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x131110);

    // 2. Camera: Perspective calibrated for 3/4 top-down vertical portrait viewing
    const aspect = this.container.clientWidth / this.container.clientHeight;
    this.camera = new THREE.PerspectiveCamera(50, aspect, 0.5, 350);
    this.camera.position.set(0, 19, -15);
    this.camera.lookAt(0, 0, 14);

    // 3. WebGL Renderer with High Dynamic Range Tone Mapping
    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
      powerPreference: 'high-performance',
      stencil: false,
      depth: true
    });
    this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.15;

    this.container.appendChild(this.renderer.domElement);

    // 4. Fog
    this.fog = new THREE.FogExp2(0x181412, 0.016);
    this.scene.fog = this.fog;

    // 5. Multi-tiered Lighting
    // Ambient light
    this.ambientLight = new THREE.AmbientLight(0xffeedd, 0.5);
    this.scene.add(this.ambientLight);

    // Hemisphere light: subtle blue sky vs warm ground bounce
    this.hemiLight = new THREE.HemisphereLight(0x7ba3cc, 0x3d3228, 0.6);
    this.scene.add(this.hemiLight);

    // Directional Sun/Moon with crisp soft shadow frustum
    this.sunLight = new THREE.DirectionalLight(0xffdfb8, 1.1);
    this.sunLight.position.set(22, 45, 15);
    this.sunLight.castShadow = true;
    this.sunLight.shadow.mapSize.width = 2048;
    this.sunLight.shadow.mapSize.height = 2048;
    this.sunLight.shadow.camera.near = 1;
    this.sunLight.shadow.camera.far = 160;
    const shadowD = 32;
    this.sunLight.shadow.camera.left = -shadowD;
    this.sunLight.shadow.camera.right = shadowD;
    this.sunLight.shadow.camera.top = shadowD;
    this.sunLight.shadow.camera.bottom = -shadowD;
    this.sunLight.shadow.bias = -0.0008;
    this.sunLight.shadow.radius = 2.5;
    this.scene.add(this.sunLight);
    this.scene.add(this.sunLight.target);

    // 6. Weather & Exhaust Particles
    this.initWeatherParticles();
    this.initExhaustSystem();
    this.initTireSpraySystem();

    // 7. Event listeners
    window.addEventListener('resize', () => this.onWindowResize());
  }

  initWeatherParticles() {
    this.particleGeo = new THREE.BufferGeometry();
    const positions = new Float32Array(this.particleCount * 3);
    const velocities = new Float32Array(this.particleCount);

    for (let i = 0; i < this.particleCount; i++) {
      positions[i * 3 + 0] = (Math.random() - 0.5) * 55;
      positions[i * 3 + 1] = Math.random() * 28;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 75;
      velocities[i] = 14 + Math.random() * 10;
    }

    this.particleGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    this.particleGeo.setAttribute('velocity', new THREE.BufferAttribute(velocities, 1));

    this.particleMat = new THREE.PointsMaterial({
      color: 0x99ccff,
      size: 0.22,
      transparent: true,
      opacity: 0.7,
      blending: THREE.AdditiveBlending
    });

    this.particleSystem = new THREE.Points(this.particleGeo, this.particleMat);
    this.scene.add(this.particleSystem);
  }

  initExhaustSystem() {
    this.exhaustGroup = new THREE.Group();
    this.scene.add(this.exhaustGroup);
    this.exhaustMat = new THREE.MeshBasicMaterial({
      color: 0x555555,
      transparent: true,
      opacity: 0.35,
      depthWrite: false
    });
    this.exhaustGeo = new THREE.SphereGeometry(0.2, 5, 5);
  }

  initTireSpraySystem() {
    this.sprayGroup = new THREE.Group();
    this.scene.add(this.sprayGroup);
    this.sprayParticles = [];
    this.sprayGeo = new THREE.SphereGeometry(0.22, 5, 5);
    this.gravelSprayMat = new THREE.MeshBasicMaterial({
      color: 0x8a735a,
      transparent: true,
      opacity: 0.45,
      depthWrite: false
    });
    this.wetSprayMat = new THREE.MeshBasicMaterial({
      color: 0xc8dcf0,
      transparent: true,
      opacity: 0.28,
      depthWrite: false,
      blending: THREE.AdditiveBlending
    });
  }

  emitExhaust(pos, isThrottle) {
    if (!this.exhaustGroup || (!isThrottle && Math.random() > 0.3)) return;
    const smoke = new THREE.Mesh(this.exhaustGeo, this.exhaustMat.clone());
    smoke.position.copy(pos);
    smoke.position.x += (Math.random() - 0.5) * 0.15;
    smoke.position.y += (Math.random() - 0.5) * 0.1;
    smoke.scale.setScalar(0.4 + Math.random() * 0.3);
    smoke.userData = {
      life: 0.0,
      maxLife: 0.8 + Math.random() * 0.4,
      vy: 0.8 + Math.random() * 0.8,
      vx: (Math.random() - 0.5) * 0.4,
      vz: -1.0 - Math.random() * 1.5
    };
    this.exhaustGroup.add(smoke);
    this.exhaustParticles.push(smoke);

    // Limit pool
    if (this.exhaustParticles.length > 40) {
      const old = this.exhaustParticles.shift();
      this.exhaustGroup.remove(old);
      if (old.material) old.material.dispose();
    }
  }

  emitBackfire(pos) {
    if (!this.exhaustGroup) return;
    const flameMat = new THREE.MeshBasicMaterial({
      color: 0xffaa22,
      transparent: true,
      opacity: 0.95,
      blending: THREE.AdditiveBlending,
      depthWrite: false
    });
    const flameGeo = new THREE.ConeGeometry(0.24, 0.65, 6);
    flameGeo.rotateX(-Math.PI / 2);
    const flame = new THREE.Mesh(flameGeo, flameMat);
    flame.position.copy(pos);
    flame.position.z -= 0.3;
    flame.userData = {
      life: 0.0,
      maxLife: 0.12,
      isFlame: true
    };
    this.exhaustGroup.add(flame);
    this.exhaustParticles.push(flame);
  }

  emitTireSpray(posLeft, posRight, surface, speedRatio, onShoulder) {
    if (!this.sprayGroup || speedRatio < 0.12) return;
    if (Math.random() > 0.6) return;

    const isGravel = onShoulder || (surface && (surface.id === 'gravel' || surface.id === 'dirt'));
    const mat = isGravel ? this.gravelSprayMat : this.wetSprayMat;
    const baseOpacity = isGravel ? 0.45 : 0.28;

    [posLeft, posRight].forEach((p) => {
      if (!p) return;
      const spray = new THREE.Mesh(this.sprayGeo, mat.clone());
      spray.position.copy(p);
      spray.position.y += 0.06;
      spray.position.x += (Math.random() - 0.5) * 0.25;
      spray.position.z -= 0.15;
      spray.scale.setScalar(0.35 + speedRatio * 0.35);
      spray.userData = {
        life: 0.0,
        maxLife: isGravel ? 0.65 : 0.45,
        baseOpacity: baseOpacity,
        vy: 0.3 + Math.random() * 0.6 * speedRatio,
        vx: (Math.random() - 0.5) * 0.6,
        vz: -0.6 - Math.random() * 1.5 * speedRatio
      };
      this.sprayGroup.add(spray);
      this.sprayParticles.push(spray);
    });

    if (this.sprayParticles.length > 45) {
      const old = this.sprayParticles.shift();
      this.sprayGroup.remove(old);
      if (old.material) old.material.dispose();
    }
  }

  updateTireSpray(delta) {
    if (!this.sprayGroup) return;
    for (let i = this.sprayParticles.length - 1; i >= 0; i--) {
      const p = this.sprayParticles[i];
      p.userData.life += delta;
      const progress = p.userData.life / p.userData.maxLife;
      if (progress >= 1.0) {
        this.sprayGroup.remove(p);
        if (p.material) p.material.dispose();
        if (p.geometry && p.geometry !== this.sprayGeo) p.geometry.dispose();
        this.sprayParticles.splice(i, 1);
      } else {
        if (p.userData.gravity) {
          p.userData.vy -= p.userData.gravity * delta;
        }
        if (p.userData.rotSpeed) {
          p.rotation.x += p.userData.rotSpeed.x * delta;
          p.rotation.y += p.userData.rotSpeed.y * delta;
          p.rotation.z += p.userData.rotSpeed.z * delta;
        }
        p.position.y += p.userData.vy * delta;
        p.position.x += p.userData.vx * delta;
        p.position.z += p.userData.vz * delta;

        if (p.userData.scaleGrowth) {
          p.scale.setScalar(p.userData.initialScale * (1.0 + progress * p.userData.scaleGrowth));
        } else {
          p.scale.setScalar(p.userData.initialScale ? p.userData.initialScale * (1.0 - progress * 0.4) : (0.4 + progress * 2.5));
        }
        p.material.opacity = (1.0 - progress) * p.userData.baseOpacity;
      }
    }
  }

  emitImpactSparks(pos, count = 8) {
    if (!this.sprayGroup) return;
    const sparkMat = new THREE.MeshBasicMaterial({
      color: 0xffea78,
      transparent: true,
      opacity: 0.9,
      blending: THREE.AdditiveBlending,
      depthWrite: false
    });
    const sparkGeo = new THREE.BoxGeometry(0.08, 0.08, 0.08);

    for (let i = 0; i < count; i++) {
      const spark = new THREE.Mesh(sparkGeo, sparkMat);
      spark.position.copy(pos);
      spark.userData = {
        life: 0.0,
        maxLife: 0.22 + Math.random() * 0.22,
        baseOpacity: 0.9,
        vx: (Math.random() - 0.5) * 6.0,
        vy: 1.5 + Math.random() * 3.5,
        vz: (Math.random() - 0.5) * 6.0,
        gravity: 9.81
      };
      this.sprayGroup.add(spark);
      this.sprayParticles.push(spark);
    }
  }

  emitImpactDebris(pos, type = 'wood', count = 12) {
    if (!this.sprayGroup) return;

    let mat, geo, scaleBase = 0.14, gravity = 11.0;

    if (type === 'wood') {
      mat = new THREE.MeshStandardMaterial({
        color: 0x855428,
        roughness: 0.9,
        metalness: 0.05
      });
      geo = new THREE.BoxGeometry(0.14, 0.07, 0.26);
      scaleBase = 0.18;
    } else if (type === 'rock') {
      mat = new THREE.MeshStandardMaterial({
        color: 0x5a544e,
        roughness: 0.95,
        metalness: 0.1
      });
      geo = new THREE.DodecahedronGeometry(0.11, 0);
      scaleBase = 0.22;
      gravity = 14.0;
    } else if (type === 'barrel') {
      mat = new THREE.MeshStandardMaterial({
        color: 0xf97316,
        roughness: 0.45,
        metalness: 0.2
      });
      geo = new THREE.BoxGeometry(0.18, 0.12, 0.06);
      scaleBase = 0.24;
    } else if (type === 'rubber') {
      mat = new THREE.MeshStandardMaterial({
        color: 0x1f242d,
        roughness: 0.95
      });
      geo = new THREE.BoxGeometry(0.15, 0.06, 0.22);
      scaleBase = 0.18;
    } else if (type === 'steam') {
      mat = new THREE.MeshBasicMaterial({
        color: 0xf8fafc,
        transparent: true,
        opacity: 0.65,
        depthWrite: false
      });
      geo = new THREE.SphereGeometry(0.24, 6, 6);
      scaleBase = 0.32;
      gravity = -2.5; // rises gently
    } else {
      this.emitImpactSparks(pos, count);
      return;
    }

    for (let i = 0; i < count; i++) {
      const debris = new THREE.Mesh(geo, mat.clone());
      debris.position.copy(pos);
      debris.position.x += (Math.random() - 0.5) * 0.35;
      debris.position.y += 0.15 + Math.random() * 0.25;
      debris.position.z += (Math.random() - 0.5) * 0.35;

      const spreadX = (Math.random() - 0.5) * 8.5;
      const spreadY = type === 'steam' ? 1.5 + Math.random() * 2.2 : 2.5 + Math.random() * 4.5;
      const spreadZ = (Math.random() - 0.5) * 8.5;

      const initialScale = scaleBase * (0.6 + Math.random() * 0.8);
      debris.scale.setScalar(initialScale);
      debris.userData = {
        life: 0.0,
        maxLife: type === 'steam' ? 0.9 + Math.random() * 0.5 : 0.55 + Math.random() * 0.35,
        baseOpacity: mat.opacity !== undefined ? mat.opacity : 1.0,
        vx: spreadX,
        vy: spreadY,
        vz: spreadZ,
        gravity: gravity,
        rotSpeed: {
          x: (Math.random() - 0.5) * 14.0,
          y: (Math.random() - 0.5) * 14.0,
          z: (Math.random() - 0.5) * 14.0
        },
        initialScale: initialScale,
        scaleGrowth: type === 'steam' ? 2.5 : 0.0
      };

      this.sprayGroup.add(debris);
      this.sprayParticles.push(debris);
    }

    // Pool limit
    while (this.sprayParticles.length > 75) {
      const old = this.sprayParticles.shift();
      this.sprayGroup.remove(old);
      if (old.material) old.material.dispose();
      if (old.geometry && old.geometry !== this.sprayGeo) old.geometry.dispose();
    }
  }

  updateExhaust(delta) {
    for (let i = this.exhaustParticles.length - 1; i >= 0; i--) {
      const p = this.exhaustParticles[i];
      p.userData.life += delta;
      const progress = p.userData.life / p.userData.maxLife;
      if (progress >= 1.0) {
        this.exhaustGroup.remove(p);
        if (p.material) p.material.dispose();
        this.exhaustParticles.splice(i, 1);
      } else {
        if (p.userData.isFlame) {
          p.scale.setScalar(1.0 - progress);
          p.material.opacity = 1.0 - progress;
        } else {
          p.position.y += p.userData.vy * delta;
          p.position.x += p.userData.vx * delta;
          p.position.z += p.userData.vz * delta;
          p.scale.setScalar(0.5 + progress * 2.2);
          p.material.opacity = (1.0 - progress) * 0.3;
        }
      }
    }
    this.updateTireSpray(delta);
  }

  updateWeatherParticles(delta, centerZ, weatherType) {
    if (!this.particleSystem) return;
    const positions = this.particleGeo.attributes.position.array;

    let fallSpeed = 26.0;
    let slantX = -1.8;
    let slantZ = 3.5;

    if (weatherType === 'snow' || weatherType === 'blizzard') {
      fallSpeed = 7.0;
      this.particleMat.color.setHex(0xe8f0ff);
      this.particleMat.size = 0.32;
      this.particleMat.opacity = 0.85;
    } else if (weatherType === 'ion_storm') {
      fallSpeed = 20.0;
      this.particleMat.color.setHex(0xc084fc);
      this.particleMat.size = 0.28;
      this.particleMat.opacity = 0.8;
    } else {
      fallSpeed = 34.0;
      this.particleMat.color.setHex(0x93c5fd);
      this.particleMat.size = 0.18;
      this.particleMat.opacity = 0.65;
    }

    for (let i = 0; i < this.particleCount; i++) {
      const idx = i * 3;
      positions[idx + 1] -= fallSpeed * delta;
      positions[idx + 0] += slantX * delta;
      positions[idx + 2] += slantZ * delta;

      if (positions[idx + 1] < 0) {
        positions[idx + 1] = 24 + Math.random() * 6;
        positions[idx + 0] = (Math.random() - 0.5) * 55;
        positions[idx + 2] = centerZ + (Math.random() - 0.25) * 75;
      }
    }
    this.particleGeo.attributes.position.needsUpdate = true;
    this.updateLightning(delta, weatherType);
  }

  setAudioEngine(audioEngine) {
    this.audioEngine = audioEngine;
  }

  triggerLightningStrike() {
    this.lightningFlash = 1.0;
    if (this.audioEngine) {
      this.audioEngine.playLightningThunder();
    }
  }

  updateLightning(delta, weatherType) {
    const isStormy = weatherType === 'ion_storm' || (this.currentBiome && this.currentBiome.id === 'glass_crater') || weatherType === 'blizzard';
    if (!isStormy) {
      if (this.lightningFlash > 0) {
        this.lightningFlash = Math.max(0, this.lightningFlash - delta * 4.0);
        this.applyAtmosphereLighting();
      }
      return;
    }

    this.lightningTimer += delta;
    if (this.lightningTimer >= this.nextLightningTime) {
      this.lightningTimer = 0;
      this.nextLightningTime = 8 + Math.random() * 14;
      this.triggerLightningStrike();
    }

    if (this.lightningFlash > 0) {
      // Rapid decay with realistic flicker
      this.lightningFlash = Math.max(0, this.lightningFlash - delta * 3.2);
      this.applyAtmosphereLighting();
    }
  }

  updateDayNightLighting(timeOfDay = 8.5, weatherType = 'clear', currentBiome = null, headlightsOn = true) {
    if (currentBiome) this.currentBiome = currentBiome;
    if (!this.currentBiome) return;

    this.lastTimeOfDay = timeOfDay;
    this.lastWeatherType = weatherType;

    // Time periods:
    // 05:00 - 07:30 : Dawn / Aurora Sunrise
    // 07:30 - 16:30 : Full Daylight
    // 16:30 - 19:30 : Golden Hour Sunset
    // 19:30 - 22:00 : Twilight / Dusk
    // 22:00 - 05:00 : Arctic Night (Moonlight, Aurora, Stars)
    const t = timeOfDay;
    let dayProgress = 1.0; // 0 = midnight, 1 = midday
    let skyColor = new THREE.Color(this.currentBiome.colorSky || 0x111620);
    let fogColor = new THREE.Color(this.currentBiome.colorFog || 0x151b26);
    let sunColor = new THREE.Color(this.currentBiome.sunColor || 0xffeedd);
    let ambientIntensity = this.currentBiome.ambientIntensity || 0.5;
    let sunIntensity = this.currentBiome.sunIntensity || 1.1;
    let fogDensity = this.currentBiome.fogDensity || 0.016;

    // Equal Duration Day/Night Cycle:
    // Exactly 12.0 Hours Daytime (06:00 to 18:00)
    // Exactly 12.0 Hours Nighttime (18:00 to 06:00)
    if (t >= 7.5 && t < 16.5) {
      // Full Daylight (9.0 hours)
      dayProgress = 1.0;
      sunColor.setHex(0xfff7e6);
      ambientIntensity = 0.54;
      sunIntensity = 1.18;
    } else if (t >= 6.0 && t < 7.5) {
      // Dawn / Sunrise (1.5 hours: 06:00 - 07:30)
      const blend = (t - 6.0) / 1.5;
      dayProgress = blend;
      const dawnSky = new THREE.Color(0xb45309).lerp(new THREE.Color(0x38bdf8), blend * 0.7);
      skyColor.copy(dawnSky);
      fogColor = new THREE.Color(0x78350f).lerp(fogColor, blend);
      sunColor = new THREE.Color(0xff9800).lerp(new THREE.Color(0xfff7e6), blend);
      ambientIntensity = THREE.MathUtils.lerp(0.24, 0.54, blend);
      sunIntensity = THREE.MathUtils.lerp(0.35, 1.18, blend);
    } else if (t >= 16.5 && t < 18.0) {
      // Golden Hour Sunset (1.5 hours: 16:30 - 18:00)
      const blend = (t - 16.5) / 1.5;
      dayProgress = 1.0 - blend;
      const sunsetSky = new THREE.Color(0xd97706).lerp(new THREE.Color(0x991b1b), blend * 0.7);
      skyColor = skyColor.lerp(sunsetSky, 0.85);
      fogColor = fogColor.lerp(new THREE.Color(0x7c2d12), 0.75);
      sunColor = new THREE.Color(0xf97316).lerp(new THREE.Color(0xdc2626), blend * 0.6);
      ambientIntensity = THREE.MathUtils.lerp(0.54, 0.26, blend);
      sunIntensity = THREE.MathUtils.lerp(1.18, 0.45, blend);
    } else if (t >= 18.0 && t < 19.5) {
      // Twilight / Dusk (1.5 hours: 18:00 - 19:30)
      const blend = (t - 18.0) / 1.5;
      dayProgress = 0.25 * (1.0 - blend);
      skyColor = new THREE.Color(0x1e1b4b).lerp(new THREE.Color(0x020617), blend);
      fogColor = new THREE.Color(0x0f172a).lerp(new THREE.Color(0x060911), blend);
      sunColor = new THREE.Color(0x93c5fd); // Transitioning to moonlight
      ambientIntensity = THREE.MathUtils.lerp(0.26, 0.16, blend);
      sunIntensity = THREE.MathUtils.lerp(0.45, 0.24, blend);
    } else if (t >= 4.5 && t < 6.0) {
      // Pre-Dawn Celestial Awakening (1.5 hours: 04:30 - 06:00)
      const blend = (t - 4.5) / 1.5;
      dayProgress = blend * 0.25;
      skyColor = new THREE.Color(0x020617).lerp(new THREE.Color(0x1e1b4b), blend);
      fogColor = new THREE.Color(0x060911).lerp(new THREE.Color(0x0f172a), blend);
      sunColor = new THREE.Color(0x94b4d6);
      ambientIntensity = THREE.MathUtils.lerp(0.16, 0.24, blend);
      sunIntensity = THREE.MathUtils.lerp(0.24, 0.35, blend);
    } else {
      // Deep Arctic Night (19:30 to 04:30 = 9.0 hours)
      dayProgress = 0.0;
      skyColor.setHex(0x020617);
      fogColor.setHex(0x060911);
      sunColor.setHex(0xa5c4e8); // Silvery moonlight
      ambientIntensity = 0.18;
      sunIntensity = 0.28;
      fogDensity = 0.013;
    }

    // Weather impact on sky, fog, and light
    if (weatherType === 'acid_drizzle' || weatherType === 'rain') {
      skyColor.multiplyScalar(0.75);
      fogColor.multiplyScalar(0.8);
      ambientIntensity *= 0.82;
      sunIntensity *= 0.65;
      fogDensity = Math.max(fogDensity, 0.022);
    } else if (weatherType === 'torrential_rain') {
      skyColor.multiplyScalar(0.55);
      fogColor.multiplyScalar(0.65);
      ambientIntensity *= 0.7;
      sunIntensity *= 0.4;
      fogDensity = Math.max(fogDensity, 0.032);
    } else if (weatherType === 'freezing_rain' || weatherType === 'blizzard') {
      skyColor.lerp(new THREE.Color(0x94a3b8), 0.5);
      fogColor.lerp(new THREE.Color(0x64748b), 0.6);
      ambientIntensity *= 0.85;
      sunIntensity *= 0.45;
      fogDensity = Math.max(fogDensity, 0.038);
    } else if (weatherType === 'heavy_mist' || weatherType === 'dense_fog') {
      fogDensity = Math.max(fogDensity, 0.045);
      ambientIntensity *= 0.85;
      sunIntensity *= 0.55;
    }

    // Substantial forward visibility boost when vehicle headlights are on at night
    if (headlightsOn && dayProgress < 0.35) {
      ambientIntensity += 0.18;
    }

    // Lightning strike overlay
    const flash = this.lightningFlash || 0;
    if (flash > 0.01) {
      const flashSky = new THREE.Color(0xc084fc).lerp(new THREE.Color(0xe0e7ff), 0.5);
      skyColor.lerp(flashSky, Math.min(1.0, flash * 0.9));
      fogColor.lerp(flashSky, Math.min(1.0, flash * 0.75));
      ambientIntensity += flash * 2.0;
      sunIntensity += flash * 3.5;
    }

    this.scene.background.copy(skyColor);
    this.fog.color.copy(fogColor);
    this.fog.density = fogDensity;
    this.ambientLight.intensity = ambientIntensity;
    this.sunLight.intensity = sunIntensity;
    this.sunLight.color.copy(sunColor);
  }

  applyAtmosphereLighting() {
    this.updateDayNightLighting(this.lastTimeOfDay || 8.5, this.lastWeatherType || 'clear', this.currentBiome);
  }

  setBiomeAtmosphere(biomeConfig) {
    if (!biomeConfig) return;
    this.currentBiome = biomeConfig;
    this.applyAtmosphereLighting();
  }

  updateLightFollow(targetPos) {
    if (!this.sunLight) return;
    const t = this.lastTimeOfDay || 8.5;
    const sunAngle = ((t - 6.0) / 24.0) * Math.PI * 2;
    const isNight = t < 5.5 || t > 19.5;

    let sunX = Math.cos(sunAngle) * 32;
    let sunY = Math.max(16, Math.sin(sunAngle) * 48);

    if (isNight) {
      // Moon positioned in the northeast sky
      sunX = -26;
      sunY = 38;
    }

    this.sunLight.position.set(targetPos.x + sunX, targetPos.y + sunY, targetPos.z + 16);
    this.sunLight.target.position.set(targetPos.x, targetPos.y, targetPos.z + 8);
  }

  onWindowResize() {
    if (!this.container || !this.renderer || !this.camera) return;
    const width = this.container.clientWidth;
    const height = this.container.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  render() {
    if (this.renderer && this.scene && this.camera) {
      this.renderer.render(this.scene, this.camera);
    }
  }
}
