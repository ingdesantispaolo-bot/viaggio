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
      case 'sea_breeze':
      case 'smog':
        frictionMultiplier = 1.0;
        roughness = 0.78;
        metalness = 0.12;
        statusLabel = 'FONDO ASCIUTTO OTTIMALE';
        statusBadge = 'GRIP 100%';
        statusColor = '#22c55e';
        break;

      case 'heatwave':
        frictionMultiplier = 0.94;
        roughness = 0.85;
        metalness = 0.08;
        statusLabel = 'CALDO ESTREMO / ASFALTO ROVENTE';
        statusBadge = 'GRIP 94% 🔥';
        statusColor = '#f97316';
        break;

      case 'sandstorm':
      case 'dust_devil':
        frictionMultiplier = 0.74;
        roughness = 0.92;
        metalness = 0.05;
        statusLabel = 'SABBIA IN SOSPENSIONE / SCIVOLOSO';
        statusBadge = 'GRIP 74% ⚠️';
        statusColor = '#d97706';
        break;

      case 'dry_gale':
      case 'gale_winds':
      case 'mountain_gale':
      case 'rock_dust':
        frictionMultiplier = 0.82;
        roughness = 0.86;
        metalness = 0.08;
        statusLabel = 'RAFFICHE & DETRITI ROCCIOSI';
        statusBadge = 'GRIP 82%';
        statusColor = '#eab308';
        break;

      case 'overcast':
      case 'aurora_static':
      case 'ion_storm':
        frictionMultiplier = 0.96;
        roughness = 0.72;
        metalness = 0.18;
        statusLabel = 'FONDO FREDDO / STABILE';
        statusBadge = 'GRIP 96%';
        statusColor = '#38bdf8';
        break;

      case 'heavy_mist':
      case 'dense_fog':
        frictionMultiplier = 0.88;
        roughness = 0.42;
        metalness = 0.38;
        statusLabel = 'NEBBIA FITTA / ASFALTO UMIDO';
        statusBadge = 'GRIP 88%';
        statusColor = '#38bdf8';
        isWet = true;
        break;

      case 'rain':
      case 'light_rain':
      case 'cold_drizzle':
      case 'acid_drizzle':
        frictionMultiplier = 0.74;
        roughness = 0.16;
        metalness = 0.80;
        statusLabel = 'ASFALTO BAGNATO';
        statusBadge = 'GRIP 74%';
        statusColor = '#eab308';
        isWet = true;
        break;

      case 'tropical_monsoon':
      case 'torrential_rain':
        frictionMultiplier = 0.52;
        roughness = 0.05;
        metalness = 0.96;
        statusLabel = 'MONSONE / ACQUAPLANING & FANGO';
        statusBadge = 'GRIP 52% ⚠️';
        statusColor = '#f97316';
        isWet = true;
        break;

      case 'light_snow':
        frictionMultiplier = 0.65;
        roughness = 0.50;
        metalness = 0.40;
        statusLabel = 'NEVE FRESCA COMPATTA';
        statusBadge = 'GRIP 65% ❄️';
        statusColor = '#38bdf8';
        isIcy = true;
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
        statusLabel = 'BUFERA DI NEVE / POLARE';
        statusBadge = 'GRIP 42% ⚠️';
        statusColor = '#ef4444';
        isIcy = true;
        break;

      case 'whiteout':
        frictionMultiplier = 0.30;
        roughness = 0.40;
        metalness = 0.50;
        statusLabel = 'WHITEOUT / VISIBILITÀ ZERO';
        statusBadge = 'GRIP 30% ⚠️';
        statusColor = '#ef4444';
        isIcy = true;
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
