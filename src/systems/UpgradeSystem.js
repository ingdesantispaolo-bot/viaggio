/**
 * THE LONG MERIDIAN - Fleet Progression & Modular Engineering Workshop System
 * Manages Dalton Highway Barn Finds, derelict restorations, vehicle fleet switching,
 * station cargo stashes, and 14 modular engineering upgrades across 4 branches.
 */

import { CONFIG } from '../config.js';

export class UpgradeSystem {
  constructor(vehicle, inventorySystem, audioEngine) {
    this.vehicle = vehicle;
    this.inventorySystem = inventorySystem;
    this.audioEngine = audioEngine;

    // Unlocked Fleet (Panda 4x4 starts unlocked)
    this.unlockedVehicles = [CONFIG.DEFAULT_VEHICLE_ID || 'panda_4x4'];

    // Discovered Derelicts along the corridor (Panda & Volvo start discovered near Livengood)
    this.discoveredDerelicts = [CONFIG.DEFAULT_VEHICLE_ID || 'panda_4x4', 'volvo_245'];

    // Installed upgrades per vehicle model: modelId -> { [upgradeId]: true }
    this.vehicleUpgrades = {
      panda_4x4: {}
    };

    // Staging Station Stash (safely stores excess cargo when swapping to smaller vehicles)
    this.stationStash = [];

    // Mileage & Progression
    this.maxPKReached = 0;
    this.onDerelictDiscovered = null;
  }

  /**
   * Called each frame with active player Z position
   */
  update(currentZ) {
    const pkMeters = Math.max(0, currentZ);
    if (pkMeters > this.maxPKReached) {
      this.maxPKReached = pkMeters;
    }

    // Check if player has reached the location of any new derelict barn find
    Object.values(CONFIG.VEHICLES_CATALOG).forEach((car) => {
      if (car.discoveryPK !== undefined && pkMeters >= car.discoveryPK) {
        if (!this.discoveredDerelicts.includes(car.id)) {
          this.discoveredDerelicts.push(car.id);
          if (this.onDerelictDiscovered) {
            this.onDerelictDiscovered(car);
          }
        }
      }
    });
  }

  isVehicleUnlocked(modelId) {
    return this.unlockedVehicles.includes(modelId);
  }

  isDerelictDiscovered(modelId) {
    return this.discoveredDerelicts.includes(modelId) || this.isVehicleUnlocked(modelId);
  }

  getUnlockedCount() {
    return this.unlockedVehicles.length;
  }

  getTotalCarsCount() {
    return Object.keys(CONFIG.VEHICLES_CATALOG).length;
  }

  unlockAllVehicles() {
    this.unlockedVehicles = Object.keys(CONFIG.VEHICLES_CATALOG);
    this.discoveredDerelicts = Object.keys(CONFIG.VEHICLES_CATALOG);
  }

  /**
   * Check if player has materials in trunk to restore a barn find
   */
  canAffordRestoration(modelId) {
    const car = CONFIG.VEHICLES_CATALOG[modelId];
    if (!car || this.isVehicleUnlocked(modelId)) return false;
    if (!this.isDerelictDiscovered(modelId)) return false;

    const costs = car.restorationCost || {};
    for (const [itemId, needed] of Object.entries(costs)) {
      const item = this.inventorySystem.trunkItems.find((i) => i.id === itemId);
      if (!item || item.count < needed) {
        return false;
      }
    }
    return true;
  }

  /**
   * Restore barn find, deduct materials, add to active fleet
   */
  restoreVehicle(modelId) {
    if (!this.canAffordRestoration(modelId)) return false;
    const car = CONFIG.VEHICLES_CATALOG[modelId];

    // Deduct materials from trunk
    for (const [itemId, needed] of Object.entries(car.restorationCost || {})) {
      const item = this.inventorySystem.trunkItems.find((i) => i.id === itemId);
      if (item) {
        item.count -= needed;
        if (item.count <= 0) {
          const idx = this.inventorySystem.trunkItems.indexOf(item);
          this.inventorySystem.trunkItems.splice(idx, 1);
        }
      }
    }

    if (!this.unlockedVehicles.includes(modelId)) {
      this.unlockedVehicles.push(modelId);
    }
    if (!this.vehicleUpgrades[modelId]) {
      this.vehicleUpgrades[modelId] = {};
    }

    // Audio celebratory feedback
    this.audioEngine.playRepairWrench();
    setTimeout(() => {
      this.audioEngine.playRevChirp();
    }, 450);

    return true;
  }

  /**
   * Switch active vehicle from fleet, safely handling trunk capacity
   */
  switchVehicle(modelId) {
    if (!this.isVehicleUnlocked(modelId)) return { success: false, reason: 'locked' };
    const targetCar = CONFIG.VEHICLES_CATALOG[modelId];
    if (!targetCar) return { success: false, reason: 'not_found' };

    // 1. Calculate target capacity (including roof rack if installed on target)
    const targetUpgrades = this.vehicleUpgrades[modelId] || {};
    let targetCapacity = targetCar.trunkCapacityKg;
    if (targetUpgrades.roof_cargo_rack) {
      targetCapacity += 45;
    }

    // 2. Check current cargo weight
    let excessStashed = 0;
    let currentWeight = this.inventorySystem.getTotalTrunkWeight();

    // If current cargo exceeds target capacity, move excess items to station stash
    if (currentWeight > targetCapacity) {
      for (let i = this.inventorySystem.trunkItems.length - 1; i >= 0; i--) {
        const item = this.inventorySystem.trunkItems[i];
        const def = this.inventorySystem.getItemDef(item.id);
        const unitW = def ? def.weight : 2.0;

        while (item.count > 0 && currentWeight > targetCapacity) {
          item.count--;
          currentWeight -= unitW;
          excessStashed += unitW;

          // Add to station stash
          const stashItem = this.stationStash.find((s) => s.id === item.id);
          if (stashItem) stashItem.count++;
          else this.stationStash.push({ id: item.id, count: 1 });
        }

        if (item.count <= 0) {
          this.inventorySystem.trunkItems.splice(i, 1);
        }
        if (currentWeight <= targetCapacity) break;
      }
    }

    // 3. Switch vehicle model
    const setOk = this.vehicle.setModel(modelId);
    if (!setOk) return { success: false, reason: 'set_model_failed' };

    // 4. Update inventory trunk capacity
    this.inventorySystem.trunkMaxWeight = targetCapacity;

    // 5. Restore installed upgrades onto newly selected vehicle
    this.vehicle.upgrades = Object.assign({
      bullbar: false,
      roof_lights: false,
      offroad_tires: false,
      aux_tank: false,
      turbo_cooler: false,
      armored_hull: false,
      studded_tires: false,
      rally_suspension: false,
      diff_lock_lsd: false,
      block_heater: false,
      copper_radiator: false,
      turbo_boost_kit: false,
      snorkel_intake: false,
      skid_plate: false,
      heavy_bullbar: false,
      aux_fuel_cell: false,
      roof_cargo_rack: false,
      rally_light_bar: false,
      cb_radar_scanner: false,
      agm_dual_battery: false
    }, targetUpgrades);

    // Re-apply physical upgrade modules
    Object.keys(targetUpgrades).forEach((upId) => {
      if (targetUpgrades[upId]) {
        this.vehicle.applyUpgrade(upId);
      }
    });

    this.audioEngine.playSwitchClick(true);
    return {
      success: true,
      vehicle: targetCar,
      excessStashed: excessStashed > 0 ? excessStashed.toFixed(1) : 0
    };
  }

  /**
   * Check if active vehicle has upgrade installed
   */
  hasUpgrade(upgradeId) {
    const curModel = this.vehicle.modelId;
    const modelUps = this.vehicleUpgrades[curModel] || {};
    return !!modelUps[upgradeId] || !!this.vehicle.upgrades[upgradeId];
  }

  /**
   * Check if player can afford upgrade
   */
  canAffordUpgrade(upgradeId) {
    const upDef = this.findUpgradeDef(upgradeId);
    if (!upDef) return false;
    if (this.hasUpgrade(upDef.id)) return false;

    // Check trunk items
    for (const [itemId, needed] of Object.entries(upDef.cost)) {
      const item = this.inventorySystem.trunkItems.find((i) => i.id === itemId);
      if (!item || item.count < needed) {
        return false;
      }
    }
    return true;
  }

  /**
   * Install modular upgrade on active vehicle
   */
  installUpgrade(upgradeId) {
    const upDef = this.findUpgradeDef(upgradeId);
    if (!upDef || !this.canAffordUpgrade(upDef.id)) return false;

    // Deduct items from trunk
    for (const [itemId, needed] of Object.entries(upDef.cost)) {
      const item = this.inventorySystem.trunkItems.find((i) => i.id === itemId);
      if (item) {
        item.count -= needed;
        if (item.count <= 0) {
          const idx = this.inventorySystem.trunkItems.indexOf(item);
          this.inventorySystem.trunkItems.splice(idx, 1);
        }
      }
    }

    // Register in vehicle upgrades map
    const curModel = this.vehicle.modelId;
    if (!this.vehicleUpgrades[curModel]) {
      this.vehicleUpgrades[curModel] = {};
    }
    this.vehicleUpgrades[curModel][upDef.id] = true;

    // Apply upgrade directly to vehicle physics & mesh
    this.vehicle.applyUpgrade(upDef.id);

    // If roof cargo rack: expand active trunk capacity
    if (upDef.id === 'roof_cargo_rack') {
      this.inventorySystem.trunkMaxWeight += 45;
    }

    this.audioEngine.playRepairWrench();
    return true;
  }

  findUpgradeDef(upgradeId) {
    const normalized = upgradeId.toLowerCase();
    for (const up of Object.values(CONFIG.UPGRADES)) {
      if (up.id.toLowerCase() === normalized) {
        return up;
      }
    }
    return CONFIG.UPGRADES[upgradeId.toUpperCase()] || null;
  }

  // Backwards compatibility
  canAfford(upgradeId) {
    return this.canAffordUpgrade(upgradeId);
  }
}
