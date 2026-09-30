/**
 * THE LONG MERIDIAN - Survival State & Vitals Manager
 * Manages player hunger, thirst, body temperature, health and odometer distance.
 */

import { CONFIG } from '../config.js';

export class SurvivalState {
  constructor(audioEngine) {
    this.audioEngine = audioEngine;

    this.health = CONFIG.SURVIVAL.MAX_HEALTH;
    this.stamina = CONFIG.SURVIVAL.MAX_STAMINA;
    this.hunger = 85; // 0 to 100
    this.thirst = 90; // 0 to 100
    this.bodyTemp = 37.0; // Celsius (safe 36-38)
    this.radiation = 0; // 0 to 100

    this.distanceTraveledMeters = 0;
    this.gameTimeSeconds = 0; // Simulated time of day (starts 06:00 AM)
    this.timeOfDay = 8.5; // Decimal hour (8.5 = 08:30)

    this.isDead = false;
  }

  update(delta, currentZ, currentBiome, isInsideVehicle) {
    if (this.isDead) return;

    this.distanceTraveledMeters = Math.max(this.distanceTraveledMeters, currentZ);
    this.gameTimeSeconds += delta;
    this.timeOfDay = (8.0 + (this.gameTimeSeconds * 0.04)) % 24;

    // Vitals decay
    this.hunger = Math.max(0, this.hunger - CONFIG.SURVIVAL.HUNGER_RATE * delta);
    this.thirst = Math.max(0, this.thirst - CONFIG.SURVIVAL.THIRST_RATE * delta);

    // Starvation / Dehydration damage
    if (this.hunger <= 0 || this.thirst <= 0) {
      this.health = Math.max(0, this.health - delta * 1.5);
    }

    // Environmental Exposure (Cold / Heat / Radiation)
    if (!isInsideVehicle) {
      if (currentBiome.coldDanger) {
        this.bodyTemp = Math.max(32.0, this.bodyTemp - delta * 0.15);
        if (this.bodyTemp < 35.0) {
          this.health = Math.max(0, this.health - delta * CONFIG.SURVIVAL.FREEZING_TEMP_DAMAGE);
        }
      } else if (currentBiome.heatDanger) {
        // Desert heat exhaustion: accelerated thirst & hyperthermia
        this.thirst = Math.max(0, this.thirst - CONFIG.SURVIVAL.THIRST_RATE * 2.2 * delta);
        this.bodyTemp = Math.min(41.5, this.bodyTemp + delta * 0.12);
        if (this.bodyTemp > 39.0) {
          this.health = Math.max(0, this.health - delta * 1.6);
        }
      } else {
        // Recover body temp gradually toward normal 37.0°C
        this.bodyTemp = THREE.MathUtils.lerp(this.bodyTemp, 37.0, delta * 0.2);
      }

      if (currentBiome.radiationDanger) {
        this.radiation = Math.min(100, this.radiation + delta * 3.5);
        if (this.radiation > 40) {
          this.health = Math.max(0, this.health - delta * CONFIG.SURVIVAL.TOXIC_DAMAGE);
        }
      }
    } else {
      // Inside vehicle provides shelter, shade & cabin ventilation
      if (currentBiome.heatDanger) {
        this.thirst = Math.max(0, this.thirst - CONFIG.SURVIVAL.THIRST_RATE * 1.35 * delta);
      }
      this.bodyTemp = THREE.MathUtils.lerp(this.bodyTemp, 37.0, delta * 0.4);
    }

    // Death check
    if (this.health <= 0 && !this.isDead) {
      this.isDead = true;
      console.log('Player succumbed to harsh conditions.');
    }
  }

  consumeItem(itemId) {
    if (itemId === 'ration_pack' || itemId === 'canned_stew' || itemId === 'dried_dates') {
      this.hunger = Math.min(CONFIG.SURVIVAL.MAX_HUNGER, this.hunger + (itemId === 'dried_dates' ? 35 : 45));
      this.health = Math.min(CONFIG.SURVIVAL.MAX_HEALTH, this.health + 10);
      this.audioEngine.playLootPickup();
      return true;
    }
    if (itemId === 'water_bottle' || itemId === 'water_purified' || itemId === 'coconut_water' || itemId === 'hot_tea') {
      this.thirst = Math.min(CONFIG.SURVIVAL.MAX_THIRST, this.thirst + 55);
      if (itemId === 'hot_tea') {
        this.bodyTemp = Math.min(38.0, this.bodyTemp + 0.8);
      }
      this.audioEngine.playLootPickup();
      return true;
    }
    if (itemId === 'medkit') {
      this.health = Math.min(CONFIG.SURVIVAL.MAX_HEALTH, this.health + 50);
      this.radiation = Math.max(0, this.radiation - 30);
      this.audioEngine.playLootPickup();
      return true;
    }
    if (itemId === 'first_aid_bandage') {
      this.health = Math.min(CONFIG.SURVIVAL.MAX_HEALTH, this.health + 25);
      this.audioEngine.playLootPickup();
      return true;
    }
    return false;
  }

  getTimePeriod() {
    const t = this.timeOfDay;
    // Mathematically balanced: exactly 12 hours day (06:00 to 18:00) and 12 hours night (18:00 to 06:00)
    if (t >= 6.0 && t < 7.5) return 'dawn';
    if (t >= 7.5 && t < 16.5) return 'day';
    if (t >= 16.5 && t < 18.0) return 'sunset';
    if (t >= 18.0 && t < 19.5) return 'dusk';
    return 'night';
  }

  getFormattedTime() {
    const totalMinutes = Math.floor(this.timeOfDay * 60);
    const hours = Math.floor(totalMinutes / 60) % 24;
    const minutes = totalMinutes % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
  }
}
