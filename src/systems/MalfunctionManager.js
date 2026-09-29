/**
 * THE LONG MERIDIAN - Vehicle Malfunction & Breakdown Management System
 * Simulates realistic vehicle failures: tire punctures, radiator leaks, electrical faults, and engine stalls.
 */

export class MalfunctionManager {
  constructor(vehicle, inventorySystem, audioEngine) {
    this.vehicle = vehicle;
    this.inventorySystem = inventorySystem;
    this.audioEngine = audioEngine;

    // Active Malfunctions
    this.faults = {
      flat_tire: false,        // Foratura: car pulls sideways, sparks fly, max speed -45%
      radiator_leak: false,    // Perdita radiatore: steam from hood, temp spikes rapidly
      electrical_short: false, // Guasto elettrico: headlights flicker, battery drains, gauges glitch
      fuel_leak: false         // Perdita carburante: fuel drains 3x faster, leaves trail
    };

    // Severity & Timers
    this.flickerTimer = 0;
    this.steamTimer = 0;
    this.sparkTimer = 0;
    this.warningBeepTimer = 0;

    // Callbacks
    this.onFaultTriggered = null;
    this.onFaultRepaired = null;
  }

  hasAnyFault() {
    return Object.values(this.faults).some((f) => f);
  }

  triggerFault(type) {
    if (this.faults[type]) return; // already active
    this.faults[type] = true;

    // Distinct procedural audio per breakdown type
    if (type === 'flat_tire') {
      this.audioEngine.playTireBlowout();
    } else if (type === 'radiator_leak') {
      this.audioEngine.playRadiatorHiss();
    } else {
      this.audioEngine.playImpact(0.8);
    }
    
    // Master caution audio alert
    setTimeout(() => {
      this.audioEngine.playBreakdownAlarm();
    }, 250);

    if (this.onFaultTriggered) {
      this.onFaultTriggered(type);
    }
    console.warn(`[MALFUNCTION] Allarme Guasto Veicolo: ${type.toUpperCase()}`);
  }

  getActiveFaultSummaries() {
    const list = [];
    if (this.faults.flat_tire) {
      const hasTire = this.inventorySystem.trunkItems.some((i) => i.id === 'spare_tire');
      const hasKit = this.inventorySystem.trunkItems.some((i) => i.id === 'toolkit');
      list.push({
        type: 'flat_tire',
        title: 'FORATURA PNEUMATICO DESTRO',
        effect: 'Sterzo che tira a destra • Velocità limitata a 50 km/h • Scintille cerchione',
        needed: '1x Ruota di Scorta oppure Kit Attrezzi',
        canRepair: hasTire || hasKit,
        lamp: 'TIRE'
      });
    }
    if (this.faults.radiator_leak) {
      const scrap = this.inventorySystem.trunkItems.find((i) => i.id === 'scrap_metal');
      const hasScrap = scrap && scrap.count >= 2;
      list.push({
        type: 'radiator_leak',
        title: 'PERDITA RADIATORE MOTORE',
        effect: 'Fumo denso dal cofano • Surriscaldamento fino a grippaggio e arresto',
        needed: '2x Rottami Metallici per saldatura d\'emergenza',
        canRepair: !!hasScrap,
        lamp: 'LEAK'
      });
    }
    if (this.faults.electrical_short) {
      const elec = this.inventorySystem.trunkItems.find((i) => i.id === 'electronics');
      const hasElec = elec && elec.count >= 1;
      list.push({
        type: 'electrical_short',
        title: 'CORTO CIRCUITO ELETTRICO',
        effect: 'Sfarfallio intermittente fari • Rapido drenaggio batteria di bordo',
        needed: '1x Componenti Elettronici',
        canRepair: !!hasElec,
        lamp: 'ELEC'
      });
    }
    if (this.faults.fuel_leak) {
      const scrap = this.inventorySystem.trunkItems.find((i) => i.id === 'scrap_metal');
      const hasScrap = scrap && scrap.count >= 2;
      list.push({
        type: 'fuel_leak',
        title: 'PERDITA CONDOTTO CARBURANTE',
        effect: 'Svuotamento accelerato serbatoio carburante',
        needed: '2x Rottami Metallici o Nastro Rinforzato',
        canRepair: !!hasScrap,
        lamp: 'FUEL'
      });
    }
    return list;
  }

  repairFault(type) {
    if (!this.faults[type]) return { success: false, reason: 'Nessun guasto di questo tipo attivo.' };

    let canRepair = false;
    let missingMsg = '';

    if (type === 'flat_tire') {
      const hasTire = this.inventorySystem.trunkItems.some((i) => i.id === 'spare_tire');
      const hasKit = this.inventorySystem.trunkItems.some((i) => i.id === 'toolkit');
      if (hasTire) {
        this.consumeItem('spare_tire');
        canRepair = true;
      } else if (hasKit) {
        canRepair = true;
      } else {
        missingMsg = 'Richiede: 1x Ruota di Scorta oppure Kit Attrezzi nel bagagliaio!';
      }
    } else if (type === 'radiator_leak') {
      if (this.consumeItem('scrap_metal', 2)) {
        canRepair = true;
      } else {
        missingMsg = 'Richiede: 2x Rottami Metallici nel bagagliaio per tappare la perdita!';
      }
    } else if (type === 'electrical_short') {
      if (this.consumeItem('electronics', 1)) {
        canRepair = true;
      } else {
        missingMsg = 'Richiede: 1x Componenti Elettronici nel bagagliaio!';
      }
    } else if (type === 'fuel_leak') {
      if (this.consumeItem('scrap_metal', 2)) {
        canRepair = true;
      } else {
        missingMsg = 'Richiede: 2x Rottami Metallici nel bagagliaio!';
      }
    }

    if (canRepair) {
      this.faults[type] = false;
      this.audioEngine.playRepairWrench();
      if (this.onFaultRepaired) {
        this.onFaultRepaired(type);
      }
      return { success: true, message: `Riparazione completata con successo: ${type.toUpperCase()}` };
    }
    return { success: false, reason: missingMsg };
  }

  consumeItem(itemId, count = 1) {
    const item = this.inventorySystem.trunkItems.find((i) => i.id === itemId);
    if (!item || item.count < count) return false;
    item.count -= count;
    if (item.count <= 0) {
      const idx = this.inventorySystem.trunkItems.indexOf(item);
      this.inventorySystem.trunkItems.splice(idx, 1);
    }
    return true;
  }

  update(delta, input, renderer) {
    if (!this.vehicle.isEngineOn && !this.hasAnyFault()) return;

    // 1. Check environmental breakdown triggers
    // Severe overheating blows radiator gasket
    if (this.vehicle.engineTemp > 118 && !this.faults.radiator_leak && Math.random() < 0.08) {
      this.triggerFault('radiator_leak');
    }

    // 2. Handle Flat Tire
    this.vehicle.hasFlatTire = !!this.faults.flat_tire;
    if (this.faults.flat_tire) {
      // Cap maximum speed while riding on a flat rim
      this.vehicle.forwardSpeed = Math.min(13.8, this.vehicle.forwardSpeed);

      // Emit sparks from wheel
      this.sparkTimer += delta;
      if (this.sparkTimer > 0.08 && this.vehicle.speedKmh > 10) {
        this.sparkTimer = 0;
        if (Math.random() < 0.4) {
          this.audioEngine.playTireScreech();
        }
      }
    }

    // 3. Handle Radiator Leak
    if (this.faults.radiator_leak) {
      // Temperature surges rapidly
      this.vehicle.engineTemp = Math.min(130, this.vehicle.engineTemp + delta * 3.5);
      
      // Emit white steam particles from front hood
      if (renderer) {
        const hoodPos = this.vehicle.position.clone();
        hoodPos.y += 1.3;
        hoodPos.z += 1.2;
        renderer.emitExhaust(hoodPos, true);
      }

      // If at max temp, engine stalls
      if (this.vehicle.engineTemp >= 128 && this.vehicle.isEngineOn) {
        this.vehicle.isEngineOn = false;
        this.audioEngine.stopEngine();
      }
    }

    // 4. Handle Electrical Short
    if (this.faults.electrical_short) {
      this.flickerTimer += delta;
      this.vehicle.battery = Math.max(0, this.vehicle.battery - delta * 2.5);

      // Randomly flicker headlights
      if (Math.random() < 0.15) {
        this.vehicle.headlights.forEach((h) => {
          h.intensity = Math.random() < 0.5 ? 0.3 : 3.5;
        });
      }
    }

    // 5. Handle Fuel Leak
    if (this.faults.fuel_leak) {
      this.vehicle.fuel = Math.max(0, this.vehicle.fuel - delta * 0.12);
    }

    // 6. Audio Warning Beep for active alarms
    if (this.hasAnyFault() && this.vehicle.isEngineOn) {
      this.warningBeepTimer += delta;
      if (this.warningBeepTimer > 3.2) {
        this.warningBeepTimer = 0;
        this.audioEngine.playBreakdownAlarm();
      }
    }
  }
}
