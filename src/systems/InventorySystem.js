/**
 * THE LONG MERIDIAN - Inventory & Cargo Management
 * Manages item definitions, weight calculations, vehicle trunk and backpack storage.
 */

export const ITEM_DEFS = {
  // Baseline general supplies
  fuel_canister: { name: 'Tanica Carburante (15L)', weight: 12.0, icon: '⛽', desc: 'Rifornisce 15 litri di benzina al veicolo.', category: 'fuel', fuelVal: 15, baseValue: 20 },
  engine_oil: { name: 'Lattina Olio Motore', weight: 2.5, icon: '🛢️', desc: 'Raffredda e lubrifica il motore.', category: 'car_part', coolingVal: 25, baseValue: 12 },
  scrap_metal: { name: 'Rottami Metallici', weight: 4.0, icon: '🔩', desc: 'Materiale base per riparare il telaio o forgiare upgrade.', category: 'crafting', repairVal: 15, baseValue: 5 },
  toolkit: { name: 'Cassetta degli Attrezzi', weight: 8.0, icon: '🧰', desc: 'Ripara 40% di integrità dello scafo se abbinato a rottami.', category: 'tool', repairVal: 40, baseValue: 30 },
  spare_tire: { name: 'Pneumatico di Scorta', weight: 14.0, icon: '🛞', desc: 'Sostituisce un pneumatico logorato o forato.', category: 'car_part', baseValue: 25 },
  electronics: { name: 'Circuiti Elettronici', weight: 1.5, icon: '💾', desc: 'Componenti hi-tech per fari ausiliari e sensori.', category: 'crafting', baseValue: 18 },
  canned_stew: { name: 'Carne in Scatola', weight: 0.8, icon: '🥫', desc: 'Pasto nutriente ad alto contenuto calorico.', category: 'consumable', baseValue: 8 },
  water_purified: { name: 'Borraccia d\'Acqua Potabile', weight: 1.2, icon: '💧', desc: 'Disseta completamente.', category: 'consumable', baseValue: 10 },
  medkit: { name: 'Kit Medico Tattico', weight: 2.0, icon: '💉', desc: 'Cura ferite gravi e disintossica.', category: 'medical', baseValue: 22 },
  first_aid_bandage: { name: 'Bende Sterili', weight: 0.4, icon: '🩹', desc: 'Arresta emorragie lievi.', category: 'medical', baseValue: 6 },
  ammo_flare: { name: 'Bengala di Segnalazione', weight: 0.6, icon: '🧨', desc: 'Illumina l\'area e disperde minacce notturne.', category: 'tool', baseValue: 8 },
  armor_plate: { name: 'Piastra Balistica Rinforzata', weight: 15.0, icon: '🛡️', desc: 'Blindatura per rinforzare lo scafo del veicolo.', category: 'crafting', repairVal: 35, baseValue: 28 },

  // Sector 0 (Fox & Goldstream Valley) Specialized supplies
  refined_fuel: { name: 'Gasolio Artico Polare (Diesel #1 -45°C)', weight: 10.0, icon: '⚡', desc: 'Gasolio raffinato per climi polari: rifornisce 25L e previene la paraffina.', category: 'fuel', fuelVal: 25, baseValue: 32 },

  // Sector 1 (Yukon River Taiga) Specialized supplies
  cured_timber: { name: 'Travi di Picea Nera dell\'Alaska', weight: 8.0, icon: '🪵', desc: 'Legname ad alta densità per puntelli, carpenteria pesante e barricate.', category: 'crafting', repairVal: 10, baseValue: 14 },
  antiseptic_resin: { name: 'Resina di Picea Nera (Mastice Athabaskan)', weight: 1.5, icon: '🧪', desc: 'Resina balsamica per sigillare radiatori spaccati o disinfettare tagli.', category: 'medical', coolingVal: 20, baseValue: 24 },

  // Sector 2 (Koyukuk Flats & Coldfoot) Specialized supplies
  peat_filter: { name: 'Filtro a Torba di Tundra del Koyukuk', weight: 2.0, icon: '🪨', desc: 'Purifica 5L di acque torbide del muskeg e filtra il circuito radiatore.', category: 'tool', coolingVal: 15, baseValue: 18 },
  waterproofing_wax: { name: 'Cera Idrorepellente per Giunti e Telaio', weight: 1.8, icon: '🕯️', desc: 'Protegge contatti elettrici e semiassi dalla corrosione del fango muskeg.', category: 'crafting', baseValue: 20 },

  // Sector 3 (Arctic Circle & Chandalar) Specialized supplies
  graphene_battery: { name: 'Accumulatore Schermato DEW Line', weight: 3.5, icon: '🔋', desc: 'Accumulatore militare a prova di tempesta geomagnetica dell\'Aurora.', category: 'crafting', baseValue: 45 },
  rad_shield_plate: { name: 'Piastra Balistica al Titanio e Piombo', weight: 6.0, icon: '🧬', desc: 'Schermatura per centralina e serbatoio contro interferenze statiche.', category: 'crafting', baseValue: 38 },

  // Sector 4 (Atigun Pass & Brooks Range) Specialized supplies
  reinforced_coil: { name: 'Molla di Sospensione Heavy-Duty Atigun', weight: 7.0, icon: '🌀', desc: 'Molla forgiata da miniera per sopportare i dislivelli del 12% e i massi.', category: 'car_part', repairVal: 25, baseValue: 35 },
  tungsten_drill_bit: { name: 'Chiodi al Tungsteno & Piastra Paramassi', weight: 5.0, icon: '⚙️', desc: 'Inserto ultra-resistente per rompere ostacoli e blindare il sottoscocca.', category: 'crafting', baseValue: 30 },

  // Sector 5 (Deadhorse & Prudhoe Bay) Specialized supplies
  cryo_coolant: { name: 'Glicole Etilenico Artico al 70% (-55°C)', weight: 3.0, icon: '❄️', desc: 'Liquido di raffreddamento polare: azzera il rischio congelamento radiatore.', category: 'car_part', coolingVal: 50, baseValue: 40 },
  thermal_lining: { name: 'Parka Polare Coibentato in Piumino', weight: 2.5, icon: '🧥', desc: 'Protezione termica estrema contro i -45°C del Mar Glaciale Artico.', category: 'tool', baseValue: 34 }
};

export class InventorySystem {
  constructor(vehicle, survivalState, audioEngine) {
    this.vehicle = vehicle;
    this.survivalState = survivalState;
    this.audioEngine = audioEngine;

    // Vehicle trunk cargo (capacity: 120 kg)
    this.trunkMaxWeight = 120.0;
    this.trunkItems = [
      { id: 'fuel_canister', count: 2 },
      { id: 'scrap_metal', count: 18 },
      { id: 'toolkit', count: 1 },
      { id: 'canned_stew', count: 3 },
      { id: 'water_purified', count: 2 },
      { id: 'first_aid_bandage', count: 2 }
    ];

    // Player backpack (capacity: 25 kg)
    this.backpackMaxWeight = 25.0;
    this.backpackItems = [
      { id: 'water_purified', count: 1 },
      { id: 'first_aid_bandage', count: 1 }
    ];
  }

  /**
   * Calculates smart regional trade value of an item at a specific settlement/biome
   */
  getItemTradeValue(itemId, settlementConfig, isSellingToSettlement = true) {
    const def = ITEM_DEFS[itemId];
    if (!def) return 0;
    const base = def.baseValue || 10;
    if (!settlementConfig) return base;

    // Check if the item is in high demand (Critical Need)
    const isCriticalNeed = settlementConfig.tradeNeeds && settlementConfig.tradeNeeds.includes(itemId);
    // Check if the settlement produces it in surplus (Primary Export)
    const isPrimaryExport = settlementConfig.tradeOffers && settlementConfig.tradeOffers.includes(itemId);

    if (isSellingToSettlement) {
      // Player selling to settlement
      if (isCriticalNeed) {
        return Math.round(base * (settlementConfig.buysMultiplier || 2.5));
      }
      return base;
    } else {
      // Player buying from settlement
      if (isPrimaryExport) {
        return Math.round(base * (settlementConfig.sellsDiscount || 0.7));
      }
      if (isCriticalNeed) {
        return Math.round(base * 1.8); // They are reluctant to sell what they need!
      }
      return base;
    }
  }

  getItemDef(itemId) {
    return ITEM_DEFS[itemId] || { name: itemId, weight: 1.0, icon: '📦', desc: '', category: 'misc', baseValue: 1 };
  }

  getTrunkWeight() {
    return this.trunkItems.reduce((acc, item) => {
      const def = ITEM_DEFS[item.id];
      return acc + (def ? def.weight * item.count : 0);
    }, 0);
  }

  getTotalTrunkWeight() {
    return this.getTrunkWeight();
  }

  getBackpackWeight() {
    return this.backpackItems.reduce((acc, item) => {
      const def = ITEM_DEFS[item.id];
      return acc + (def ? def.weight * item.count : 0);
    }, 0);
  }

  addItemToTrunk(itemId, count = 1) {
    const def = ITEM_DEFS[itemId];
    if (!def) return false;
    const addedWeight = def.weight * count;
    if (this.getTrunkWeight() + addedWeight > this.trunkMaxWeight) return false;

    const existing = this.trunkItems.find((i) => i.id === itemId);
    if (existing) {
      existing.count += count;
    } else {
      this.trunkItems.push({ id: itemId, count });
    }
    this.audioEngine.playLootPickup();
    return true;
  }

  addItemToBackpack(itemId, count = 1) {
    const def = ITEM_DEFS[itemId];
    if (!def) return false;
    const addedWeight = def.weight * count;
    if (this.getBackpackWeight() + addedWeight > this.backpackMaxWeight) return false;

    const existing = this.backpackItems.find((i) => i.id === itemId);
    if (existing) {
      existing.count += count;
    } else {
      this.backpackItems.push({ id: itemId, count });
    }
    this.audioEngine.playLootPickup();
    return true;
  }

  useItemFromBackpack(index) {
    const item = this.backpackItems[index];
    if (!item) return;
    const def = ITEM_DEFS[item.id];
    if (!def) return;

    if (def.category === 'consumable' || def.category === 'medical') {
      const consumed = this.survivalState.consumeItem(item.id);
      if (consumed) {
        item.count--;
        if (item.count <= 0) this.backpackItems.splice(index, 1);
      }
    } else if (def.category === 'fuel') {
      this.refuelVehicleWithItem(item, index, this.backpackItems);
    } else if (def.coolingVal) {
      this.coolEngineWithItem(item, index, this.backpackItems);
    } else if (item.id === 'graphene_battery') {
      this.rechargeBatteryWithItem(item, index, this.backpackItems);
    } else if (def.repairVal) {
      this.repairVehicleWithItem(item, index, this.backpackItems);
    }
  }

  useItemFromTrunk(index) {
    const item = this.trunkItems[index];
    if (!item) return;
    const def = ITEM_DEFS[item.id];
    if (!def) return;

    if (def.category === 'consumable' || def.category === 'medical') {
      const consumed = this.survivalState.consumeItem(item.id);
      if (consumed) {
        item.count--;
        if (item.count <= 0) this.trunkItems.splice(index, 1);
      }
    } else if (def.category === 'fuel') {
      this.refuelVehicleWithItem(item, index, this.trunkItems);
    } else if (def.coolingVal) {
      this.coolEngineWithItem(item, index, this.trunkItems);
    } else if (item.id === 'graphene_battery') {
      this.rechargeBatteryWithItem(item, index, this.trunkItems);
    } else if (def.repairVal) {
      this.repairVehicleWithItem(item, index, this.trunkItems);
    }
  }

  refuelVehicleWithItem(item, index, container) {
    if (this.vehicle.fuel >= this.vehicle.maxFuel) return;
    const def = ITEM_DEFS[item.id];
    this.vehicle.fuel = Math.min(this.vehicle.maxFuel, this.vehicle.fuel + (def.fuelVal || 15));
    this.audioEngine.playLootPickup();
    item.count--;
    if (item.count <= 0) container.splice(index, 1);
  }

  coolEngineWithItem(item, index, container) {
    const def = ITEM_DEFS[item.id];
    this.vehicle.engineTemp = Math.max(70, this.vehicle.engineTemp - (def.coolingVal || 25));
    this.audioEngine.playSwitchClick(true);
    item.count--;
    if (item.count <= 0) container.splice(index, 1);
  }

  rechargeBatteryWithItem(item, index, container) {
    this.vehicle.battery = 100.0;
    this.audioEngine.playSwitchClick(true);
    item.count--;
    if (item.count <= 0) container.splice(index, 1);
  }

  repairVehicleWithItem(item, index, container) {
    if (this.vehicle.hull >= 100) return;
    const def = ITEM_DEFS[item.id];
    this.vehicle.hull = Math.min(100, this.vehicle.hull + (def.repairVal || 20));
    this.audioEngine.playImpact(0.4);
    item.count--;
    if (item.count <= 0) container.splice(index, 1);
  }

  /**
   * Performs an asymmetric barter exchange at a settlement
   */
  barterExchange(giveItemId, takeItemId, settlementConfig) {
    // Check if player has giveItemId in trunk
    const giveEntry = this.trunkItems.find((i) => i.id === giveItemId && i.count > 0);
    if (!giveEntry) return { success: false, reason: 'Articolo non presente nel bagagliaio.' };

    const giveVal = this.getItemTradeValue(giveItemId, settlementConfig, true);
    const takeVal = this.getItemTradeValue(takeItemId, settlementConfig, false);

    // Calculate how many giveItems are needed or if 1:1 with surplus credit
    const neededGiveCount = Math.max(1, Math.ceil(takeVal / giveVal));
    if (giveEntry.count < neededGiveCount) {
      return { 
        success: false, 
        reason: `Valore insufficiente: servono ${neededGiveCount}x ${ITEM_DEFS[giveItemId].name} per ottenere 1x ${ITEM_DEFS[takeItemId].name}.` 
      };
    }

    // Try adding takeItem to trunk
    const takeDef = ITEM_DEFS[takeItemId];
    const weightCheck = this.getTrunkWeight() - (ITEM_DEFS[giveItemId].weight * neededGiveCount) + takeDef.weight;
    if (weightCheck > this.trunkMaxWeight) {
      return { success: false, reason: 'Carico massimo del bagagliaio superato!' };
    }

    // Deduct given items
    giveEntry.count -= neededGiveCount;
    if (giveEntry.count <= 0) {
      const idx = this.trunkItems.indexOf(giveEntry);
      this.trunkItems.splice(idx, 1);
    }

    // Add purchased item
    this.addItemToTrunk(takeItemId, 1);
    this.audioEngine.playLootPickup();
    return { 
      success: true, 
      message: `Scambio riuscito: -${neededGiveCount}x ${ITEM_DEFS[giveItemId].name} ➔ +1x ${takeDef.name}!` 
    };
  }

  transferToBackpack(index) {
    const item = this.trunkItems[index];
    if (!item) return;
    const success = this.addItemToBackpack(item.id, 1);
    if (success) {
      item.count--;
      if (item.count <= 0) this.trunkItems.splice(index, 1);
    }
  }

  transferToTrunk(index) {
    const item = this.backpackItems[index];
    if (!item) return;
    const success = this.addItemToTrunk(item.id, 1);
    if (success) {
      item.count--;
      if (item.count <= 0) this.backpackItems.splice(index, 1);
    }
  }
}
