/**
 * THE LONG MERIDIAN - Dynamic Weather Director
 * Manages atmospheric conditions, storm fronts, and visibility effects.
 */

export class WeatherDirector {
  constructor(renderer, audioEngine, biomeManager) {
    this.renderer = renderer;
    this.audioEngine = audioEngine;
    this.biomeManager = biomeManager;

    this.currentWeather = 'clear';
    this.timer = 0;
    this.weatherDuration = 55; // seconds per weather state
    this.roadImpact = this.calculateRoadImpact('clear');
  }

  getRoadImpact() {
    return this.roadImpact;
  }

  calculateRoadImpact(weather) {
    let frictionMultiplier = 1.0;
    let roughness = 0.78;
    let metalness = 0.12;
    let statusLabel = 'ASFALTO ASCIUTTO';
    let statusBadge = 'GRIP 100%';
    let statusColor = '#22c55e';
    let isWet = false;
    let isIcy = false;

    switch (weather) {
      case 'clear':
      case 'smog':
        frictionMultiplier = 1.0;
        roughness = 0.78;
        metalness = 0.12;
        statusLabel = 'ASFALTO ASCIUTTO';
        statusBadge = 'GRIP 100%';
        statusColor = '#22c55e';
        break;

      case 'overcast':
      case 'aurora_static':
        frictionMultiplier = 0.98;
        roughness = 0.72;
        metalness = 0.15;
        statusLabel = 'ASFALTO FREDDO';
        statusBadge = 'GRIP 98%';
        statusColor = '#38bdf8';
        break;

      case 'heavy_mist':
      case 'dense_fog':
        frictionMultiplier = 0.90;
        roughness = 0.45;
        metalness = 0.35;
        statusLabel = 'ASFALTO UMIDO';
        statusBadge = 'GRIP 90%';
        statusColor = '#38bdf8';
        isWet = true;
        break;

      case 'acid_drizzle':
      case 'rain':
        frictionMultiplier = 0.72;
        roughness = 0.14;
        metalness = 0.82;
        statusLabel = 'ASFALTO BAGNATO';
        statusBadge = 'GRIP 72%';
        statusColor = '#eab308';
        isWet = true;
        break;

      case 'torrential_rain':
        frictionMultiplier = 0.58;
        roughness = 0.08;
        metalness = 0.92;
        statusLabel = 'ACQUAPLANING SEVERO';
        statusBadge = 'GRIP 58%';
        statusColor = '#f97316';
        isWet = true;
        break;

      case 'freezing_rain':
        frictionMultiplier = 0.36;
        roughness = 0.22;
        metalness = 0.55;
        statusLabel = 'VETRONE / GHIACCIO VIVO';
        statusBadge = 'GRIP 36% ⚠️';
        statusColor = '#ef4444';
        isIcy = true;
        break;

      case 'blizzard':
        frictionMultiplier = 0.42;
        roughness = 0.38;
        metalness = 0.45;
        statusLabel = 'NEVE COMPATTA / BUFERA';
        statusBadge = 'GRIP 42% ⚠️';
        statusColor = '#ef4444';
        isIcy = true;
        break;

      case 'gale_winds':
      case 'rock_dust':
        frictionMultiplier = 0.82;
        roughness = 0.85;
        metalness = 0.08;
        statusLabel = 'GHIAIETTO & RAFFICHE';
        statusBadge = 'GRIP 82%';
        statusColor = '#eab308';
        break;

      case 'ion_storm':
        frictionMultiplier = 0.88;
        roughness = 0.65;
        metalness = 0.25;
        statusLabel = 'CARICA STATICA IONICA';
        statusBadge = 'GRIP 88%';
        statusColor = '#a855f7';
        break;

      default:
        frictionMultiplier = 1.0;
        break;
    }

    return {
      weather,
      frictionMultiplier,
      roughness,
      metalness,
      statusLabel,
      statusBadge,
      statusColor,
      isWet,
      isIcy
    };
  }

  update(delta, playerZ, roadGenerator = null) {
    this.timer += delta;
    if (this.timer > this.weatherDuration) {
      this.timer = 0;
      this.pickNextWeather();
    }

    // Apply specular wet sheen or frost directly to road asphalt material
    if (roadGenerator && roadGenerator.materials && roadGenerator.materials.asphalt) {
      const mat = roadGenerator.materials.asphalt;
      mat.roughness = THREE.MathUtils.lerp(mat.roughness, this.roadImpact.roughness, delta * 1.5);
      mat.metalness = THREE.MathUtils.lerp(mat.metalness, this.roadImpact.metalness, delta * 1.5);
      if (this.roadImpact.isIcy) {
        mat.color.lerp(new THREE.Color(0xb5c9db), delta * 0.8);
      } else {
        mat.color.lerp(new THREE.Color(0xffffff), delta * 0.8);
      }
    }

    // Update particles in renderer
    this.renderer.updateWeatherParticles(delta, playerZ, this.currentWeather);
  }

  pickNextWeather() {
    const biome = this.biomeManager.currentBiome;
    const possibleWeathers = biome.weatherTypes || ['clear', 'rain'];
    const next = possibleWeathers[Math.floor(Math.random() * possibleWeathers.length)];
    this.currentWeather = next;
    this.roadImpact = this.calculateRoadImpact(next);
    console.log(`[WEATHER] Atmospheric front shifted to: ${next} (Road Grip: ${(this.roadImpact.frictionMultiplier * 100).toFixed(0)}%)`);
  }
}
