/**
 * THE LONG MERIDIAN - Fleet Restoration Hub & Modular Engineering Workshop
 * Manages Dalton Highway Barn Finds, derelict restorations, vehicle fleet switching,
 * cargo stash logistics, and 14 modular engineering upgrades across 4 branches.
 */

import { CONFIG } from '../config.js';

export class UpgradeModal {
  constructor(container, vehicle, upgradeSystem, audioEngine, inventorySystem = null) {
    this.container = container;
    this.vehicle = vehicle;
    this.upgradeSystem = upgradeSystem;
    this.audioEngine = audioEngine;
    this.inventorySystem = inventorySystem;

    this.isOpen = false;
    this.activeTab = 'garage'; // 'garage' or 'upgrades'
    this.activeUpgradeFilter = 'all'; // 'all', 'chassis', 'engine', 'armor', 'avionics'
    this.element = null;
    this.buildModal();
  }

  buildModal() {
    this.element = document.createElement('div');
    this.element.className = 'game-modal-overlay';
    this.element.style.display = 'none';

    this.element.innerHTML = `
      <div class="game-modal-window workshop-window large-garage-window">
        <div class="modal-header">
          <div class="modal-title-wrap">
            <div class="modal-title">🏎️ FLOTTA CLASSICA EUROPEA & OFFICINA TUNING</div>
            <div class="fleet-progress-pill" id="fleet-progress-header">FLOTTA RECUPERATA: 1 / 11</div>
          </div>
          <button class="modal-close-btn" id="btn-close-workshop">✕</button>
        </div>

        <!-- Navigation Tabs -->
        <div class="modal-tabs-bar">
          <button class="modal-tab-btn active" id="tab-btn-garage">🏎️ PARCO VEICOLI & RESTAURI DEL MERIDIANO</button>
          <button class="modal-tab-btn" id="tab-btn-upgrades">🛠️ OFFICINA MODULARE & TUNING (14 UPGRADE)</button>
        </div>

        <div class="workshop-body">
          <!-- Active Vehicle Summary Banner -->
          <div class="active-vehicle-overview" id="active-vehicle-header">
            <!-- Populated dynamically -->
          </div>

          <!-- Tab Content 1: Garage / Fleet & Barn Finds -->
          <div class="tab-pane active" id="pane-garage">
            <div class="garage-fleet-banner" id="garage-fleet-banner">
              <!-- Fleet stats, mileage, stash notification -->
            </div>
            <div class="garage-catalog-grid" id="garage-catalog-container"></div>
          </div>

          <!-- Tab Content 2: Modular Upgrades -->
          <div class="tab-pane" id="pane-upgrades" style="display: none;">
            <div class="upgrade-category-bar" id="upgrade-category-bar">
              <button class="cat-pill active" data-cat="all">🔘 TUTTI (14)</button>
              <button class="cat-pill" data-cat="chassis">🛞 ASSETTO & TRAZIONE (3)</button>
              <button class="cat-pill" data-cat="engine">🔥 MOTORE & TERMO (4)</button>
              <button class="cat-pill" data-cat="armor">🛡️ TELAIO & AUTONOMIA (4)</button>
              <button class="cat-pill" data-cat="avionics">💡 AVIONICA & SENSORI (3)</button>
            </div>
            <div class="upgrade-grid" id="upgrade-items-container"></div>
          </div>
        </div>

        <div class="modal-footer" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
          <span class="footer-tip" id="workshop-footer-tip" style="flex:1;">
            💡 Restaura i relitti storici trovati lungo il Grande Meridiano con i pezzi recuperati nei POI. Puoi cambiare auto in qualsiasi momento: il carico in eccesso viene custodito nel Deposito di Tappa.
          </span>
          <button class="btn-demo-unlock" id="btn-unlock-all-fleet" style="background:#1e293b;border:1px solid #38bdf8;color:#38bdf8;font-size:10px;font-family:var(--font-tech);padding:5px 10px;border-radius:4px;cursor:pointer;white-space:nowrap;">🔓 SBLOCCA TUTTI I MODELLI (COLLAUDO CRUSCOTTI)</button>
        </div>
      </div>
    `;

    this.container.appendChild(this.element);

    const btnUnlockAll = this.element.querySelector('#btn-unlock-all-fleet');
    if (btnUnlockAll) {
      btnUnlockAll.addEventListener('click', () => {
        this.upgradeSystem.unlockAllVehicles();
        this.renderGarage();
        this.audioEngine.playRevChirp();
      });
    }

    // Bind Close & Tab switching
    this.element.querySelector('#btn-close-workshop').addEventListener('click', () => {
      this.close();
    });

    const tabGarage = this.element.querySelector('#tab-btn-garage');
    const tabUpgrades = this.element.querySelector('#tab-btn-upgrades');
    const paneGarage = this.element.querySelector('#pane-garage');
    const paneUpgrades = this.element.querySelector('#pane-upgrades');

    tabGarage.addEventListener('click', () => {
      this.activeTab = 'garage';
      tabGarage.classList.add('active');
      tabUpgrades.classList.remove('active');
      paneGarage.style.display = 'block';
      paneUpgrades.style.display = 'none';
      this.renderGarage();
      this.audioEngine.playSwitchClick(true);
    });

    tabUpgrades.addEventListener('click', () => {
      this.activeTab = 'upgrades';
      tabUpgrades.classList.add('active');
      tabGarage.classList.remove('active');
      paneGarage.style.display = 'none';
      paneUpgrades.style.display = 'block';
      this.renderUpgrades();
      this.audioEngine.playSwitchClick(true);
    });

    // Category filter pills
    this.element.querySelectorAll('.cat-pill').forEach((pill) => {
      pill.addEventListener('click', (e) => {
        this.element.querySelectorAll('.cat-pill').forEach((p) => p.classList.remove('active'));
        e.currentTarget.classList.add('active');
        this.activeUpgradeFilter = e.currentTarget.dataset.cat;
        this.renderUpgrades();
        this.audioEngine.playSwitchClick(true);
      });
    });
  }

  open(initialTab = null) {
    this.isOpen = true;
    this.element.style.display = 'flex';

    if (initialTab) {
      this.activeTab = initialTab;
      const tabGarage = this.element.querySelector('#tab-btn-garage');
      const tabUpgrades = this.element.querySelector('#tab-btn-upgrades');
      const paneGarage = this.element.querySelector('#pane-garage');
      const paneUpgrades = this.element.querySelector('#pane-upgrades');

      if (initialTab === 'garage') {
        tabGarage.classList.add('active');
        tabUpgrades.classList.remove('active');
        paneGarage.style.display = 'block';
        paneUpgrades.style.display = 'none';
      } else {
        tabUpgrades.classList.add('active');
        tabGarage.classList.remove('active');
        paneGarage.style.display = 'none';
        paneUpgrades.style.display = 'block';
      }
    }

    if (this.activeTab === 'garage') {
      this.renderGarage();
    } else {
      this.renderUpgrades();
    }
    this.audioEngine.playSwitchClick(true);
  }

  close() {
    this.isOpen = false;
    this.element.style.display = 'none';
    this.audioEngine.playSwitchClick(false);
  }

  toggle(initialTab = null) {
    if (this.isOpen) {
      this.close();
    } else {
      this.open(initialTab);
    }
  }

  renderActiveVehicleHeader() {
    const header = this.element.querySelector('#active-vehicle-header');
    const curId = this.vehicle.modelId;
    const cfg = this.vehicle.getCurrentModelConfig() || CONFIG.VEHICLES_CATALOG[curId];
    if (!cfg) return;

    const ups = this.vehicle.upgrades;
    const trunkCap = cfg.trunkCapacityKg + (ups.roof_cargo_rack ? 45 : 0);
    const fuelCap = cfg.fuelTankL + (ups.aux_fuel_cell || ups.aux_tank ? 40 : 0);
    const isTurbo = cfg.hasTurbo;

    header.innerHTML = `
      <div class="active-car-badge-line">
        <span class="flag-icon">${cfg.flag}</span>
        <div class="active-car-titles">
          <div class="sub-maker">${cfg.maker} (${cfg.year}) — VEICOLO ATTIVO</div>
          <div class="main-model-name">${cfg.name.toUpperCase()}</div>
        </div>
        <div class="drivetrain-tag">${cfg.drivetrainBadge}</div>
      </div>

      <div class="active-car-stat-chips">
        <div class="stat-chip">
          <span class="chip-label">SCAFO / INTEGRITÀ:</span>
          <span class="chip-val ${this.vehicle.hull < 40 ? 'val-danger' : 'val-ok'}">${Math.round(this.vehicle.hull)} / 100 HP ${ups.heavy_bullbar || ups.skid_plate ? '🛡️' : ''}</span>
        </div>
        <div class="stat-chip">
          <span class="chip-label">SERBATOIO:</span>
          <span class="chip-val highlight-val">${Math.round(this.vehicle.fuel)} / ${fuelCap} L ${ups.aux_fuel_cell ? '(+40L BLINDATO)' : ''}</span>
        </div>
        <div class="stat-chip">
          <span class="chip-label">BAGAGLIAIO:</span>
          <span class="chip-val highlight-cargo">${this.inventorySystem ? this.inventorySystem.getTotalTrunkWeight().toFixed(1) : 0} / ${trunkCap} kg ${ups.roof_cargo_rack ? '(+45kg TETTO)' : ''}</span>
        </div>
        <div class="stat-chip">
          <span class="chip-label">GRIP / ADERENZA:</span>
          <span class="chip-val">${cfg.drivetrain} ${ups.studded_tires ? '❄️ CHIODATO' : ''} ${ups.diff_lock_lsd ? '⚙️ LSD' : ''}</span>
        </div>
        <div class="stat-chip">
          <span class="chip-label">TERMICA MOTORE:</span>
          <span class="chip-val">${Math.round(this.vehicle.engineTemp)}°C ${ups.copper_radiator ? '❄️ RAME' : ''} ${ups.block_heater ? '🔥 WEBASTO' : ''}</span>
        </div>
        ${
          isTurbo
            ? `<div class="stat-chip turbo-chip">
                 <span class="chip-label">TURBO BOOST:</span>
                 <span class="chip-val">${cfg.turboBoostMaxBar.toFixed(2)} Bar ${ups.turbo_boost_kit ? '💨 COMPETIZIONE' : ''}</span>
               </div>`
            : ''
        }
      </div>
    `;
  }

  renderGarage() {
    this.renderActiveVehicleHeader();
    const container = this.element.querySelector('#garage-catalog-container');
    const banner = this.element.querySelector('#garage-fleet-banner');
    container.innerHTML = '';

    const currentId = this.vehicle.modelId;
    const unlockedCount = this.upgradeSystem.getUnlockedCount();
    const totalCount = this.upgradeSystem.getTotalCarsCount();

    // Update fleet header progress
    const fleetHeader = this.element.querySelector('#fleet-progress-header');
    if (fleetHeader) {
      fleetHeader.textContent = `FLOTTA RECUPERATA: ${unlockedCount} / ${totalCount} (${Math.round((unlockedCount / totalCount) * 100)}%)`;
    }

    // Station stash check
    const stashCount = this.upgradeSystem.stationStash.reduce((acc, s) => acc + s.count, 0);
    banner.innerHTML = `
      <div class="fleet-overview-card">
        <div class="fleet-stat-box">
          <span class="stat-big">${unlockedCount} / ${totalCount}</span>
          <span class="stat-sub">Vetture Sbloccate</span>
        </div>
        <div class="fleet-stat-box">
          <span class="stat-big">${(this.upgradeSystem.maxPKReached / 1000).toFixed(1)} km</span>
          <span class="stat-sub">Record Chilometrico Spedizione</span>
        </div>
        <div class="fleet-stat-box">
          <span class="stat-big">${stashCount > 0 ? `📦 ${stashCount} Oggetti` : 'Nessuno'}</span>
          <span class="stat-sub">Deposito di Tappa Stash</span>
        </div>
      </div>
      ${
        stashCount > 0
          ? `<div class="stash-notice-bar">
               <span>📦 Nel Deposito di Tappa sono custoditi materiali in eccesso: ${this.upgradeSystem.stationStash.map(s => `${s.count}x ${s.id}`).join(', ')}.</span>
               <button class="btn-retrieve-stash" id="btn-retrieve-stash">RECUPERA NEL BAGAGLIAIO</button>
             </div>`
          : ''
      }
    `;

    if (stashCount > 0) {
      const retrieveBtn = banner.querySelector('#btn-retrieve-stash');
      if (retrieveBtn) {
        retrieveBtn.addEventListener('click', () => {
          this.retrieveStashItems();
        });
      }
    }

    // Sort cars: Active first, then Unlocked, then Discovered Derelicts, then Undiscovered
    const cars = Object.values(CONFIG.VEHICLES_CATALOG).slice().sort((a, b) => {
      const aCurrent = a.id === currentId ? 1 : 0;
      const bCurrent = b.id === currentId ? 1 : 0;
      if (aCurrent !== bCurrent) return bCurrent - aCurrent;

      const aUnlocked = this.upgradeSystem.isVehicleUnlocked(a.id) ? 1 : 0;
      const bUnlocked = this.upgradeSystem.isVehicleUnlocked(b.id) ? 1 : 0;
      if (aUnlocked !== bUnlocked) return bUnlocked - aUnlocked;

      const aDisc = this.upgradeSystem.isDerelictDiscovered(a.id) ? 1 : 0;
      const bDisc = this.upgradeSystem.isDerelictDiscovered(b.id) ? 1 : 0;
      if (aDisc !== bDisc) return bDisc - aDisc;

      return (a.discoveryPK || 0) - (b.discoveryPK || 0);
    });

    cars.forEach((car) => {
      const isCurrent = car.id === currentId;
      const isUnlocked = this.upgradeSystem.isVehicleUnlocked(car.id);
      const isDiscovered = this.upgradeSystem.isDerelictDiscovered(car.id);
      const canAfford = !isUnlocked && isDiscovered && this.upgradeSystem.canAffordRestoration(car.id);

      const card = document.createElement('div');
      card.className = `garage-car-card ${isCurrent ? 'car-selected' : ''} ${!isUnlocked && isDiscovered ? 'car-derelict' : ''} ${!isDiscovered ? 'car-locked' : ''}`;

      // Status Badge
      let statusBadgeHtml = '';
      if (isCurrent) {
        statusBadgeHtml = '<span class="status-badge badge-active">✓ ATTIVO IN MISSIONE</span>';
      } else if (isUnlocked) {
        statusBadgeHtml = '<span class="status-badge badge-unlocked">✓ DISPONIBILE NELLA FLOTTA</span>';
      } else if (isDiscovered) {
        statusBadgeHtml = '<span class="status-badge badge-derelict">🛠️ PROGETTO DI RESTAURO</span>';
      } else {
        statusBadgeHtml = '<span class="status-badge badge-locked">🔒 NON ANCORA LOCALIZZATO</span>';
      }

      // Restoration Requirements HTML
      let restorationHtml = '';
      if (!isUnlocked && isDiscovered) {
        const costEntries = Object.entries(car.restorationCost || {});
        const reqChips = costEntries.map(([itemId, needed]) => {
          const item = this.inventorySystem.trunkItems.find((i) => i.id === itemId);
          const hasCount = item ? item.count : 0;
          const isMet = hasCount >= needed;
          const def = this.inventorySystem.getItemDef(itemId);
          const icon = def ? def.icon : '🔩';
          const name = def ? def.name : itemId;
          return `
            <div class="req-chip ${isMet ? 'req-met' : 'req-missing'}">
              <span>${icon} ${name}:</span>
              <strong>${hasCount} / ${needed}</strong>
            </div>
          `;
        }).join('');

        restorationHtml = `
          <div class="derelict-recovery-box">
            <div class="derelict-location-tag">📍 RITROVAMENTO: <strong>${car.discoveryLocation}</strong> (PK ${(car.discoveryPK / 1000).toFixed(1)} km)</div>
            <p class="derelict-story-text">"${car.restorationStory}"</p>
            <div class="derelict-reqs-label">COMPONENTI NECESSARI PER IL RESTAURO:</div>
            <div class="derelict-reqs-grid">${reqChips}</div>
          </div>
        `;
      } else if (!isUnlocked && !isDiscovered) {
        restorationHtml = `
          <div class="locked-discovery-box">
            <div class="radio-hint-header">📻 SEGNALE RADIO CB ASSENTE</div>
            <p class="radio-hint-text">Il relitto di questa icona europea non è ancora stato avvistato lungo il corridoio. Esplora oltre il <strong>PK ${(car.discoveryPK / 1000).toFixed(1)} km</strong> in direzione di <strong>${car.discoveryLocation}</strong> per intercettarne le coordinate.</p>
          </div>
        `;
      }

      card.innerHTML = `
        <div class="car-card-header">
          <div class="car-title-block">
            <span class="car-flag">${car.flag}</span>
            <div>
              <div class="car-maker">${car.maker} (${car.year}) — TIER ${car.tier || 1}</div>
              <h3 class="car-name">${car.name}</h3>
            </div>
          </div>
          <div class="header-badges">
            <span class="car-badge-category">${car.category}</span>
            ${statusBadgeHtml}
          </div>
        </div>

        <div class="car-specs-grid">
          <div class="spec-cell">
            <span class="cell-label">MOTORE:</span>
            <span class="cell-val">${car.engine}</span>
          </div>
          <div class="spec-cell">
            <span class="cell-label">POTENZA:</span>
            <span class="cell-val highlight-stat">${car.powerHp} CV @ ${car.redlineRpm - 500} rpm</span>
          </div>
          <div class="spec-cell">
            <span class="cell-label">COPPIA:</span>
            <span class="cell-val">${car.torqueNm} Nm</span>
          </div>
          <div class="spec-cell">
            <span class="cell-label">TRAZIONE:</span>
            <span class="cell-val ${car.drivetrain.includes('AWD') || car.drivetrain.includes('4WD') ? 'awd-badge' : 'rwd-badge'}">${car.drivetrainBadge}</span>
          </div>
          <div class="spec-cell">
            <span class="cell-label">PESO & TELAIO:</span>
            <span class="cell-val">${car.weightKg} kg</span>
          </div>
          <div class="spec-cell">
            <span class="cell-label">SERBATOIO:</span>
            <span class="cell-val">${car.fuelTankL} L (${car.fuelType.toUpperCase()})</span>
          </div>
          <div class="spec-cell">
            <span class="cell-label">VELOCITÀ MAX:</span>
            <span class="cell-val">${car.topSpeedKmh} km/h</span>
          </div>
          <div class="spec-cell">
            <span class="cell-label">BAGAGLIAIO:</span>
            <span class="cell-val highlight-cargo">${car.trunkCapacityKg} kg max</span>
          </div>
        </div>

        <div class="car-notes-box">
          <p class="car-history-note"><strong>STORIA:</strong> ${car.description}</p>
          <p class="car-dalton-note"><strong>DINAMICA DI GUIDA & BIOMI:</strong> ${car.tacticalDaltonAdvice}</p>
        </div>

        ${restorationHtml}

        <div class="car-card-actions">
          ${
            isCurrent
              ? '<button class="garage-action-btn btn-current-active" disabled>✓ VEICOLO ATTIVO SUL CORRIDOIO</button>'
              : (isUnlocked
                  ? `<button class="garage-action-btn btn-choose-car" data-id="${car.id}">GUIDA ${car.name.toUpperCase()}</button>`
                  : (isDiscovered
                      ? `<button class="garage-action-btn btn-restore-car ${canAfford ? 'btn-can-restore' : 'btn-missing-parts'}" data-id="${car.id}" ${canAfford ? '' : 'disabled'}>
                          ${canAfford ? `🛠️ RESTAURA E AGGIUNGI ALLA FLOTTA` : '🔒 MANCANO RISORSE PER IL RESTAURO'}
                        </button>`
                      : '<button class="garage-action-btn btn-locked-car" disabled>🔒 ESPLORA IL CORRIDOIO PER LOCALIZZARE IL RELITTO</button>'
                    )
                )
          }
        </div>
      `;
      container.appendChild(card);
    });

    // Bind choose buttons
    container.querySelectorAll('.btn-choose-car').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        const id = e.currentTarget.dataset.id;
        this.selectVehicle(id);
      });
    });

    // Bind restore buttons
    container.querySelectorAll('.btn-restore-car').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        const id = e.currentTarget.dataset.id;
        this.restoreVehicle(id);
      });
    });
  }

  selectVehicle(modelId) {
    const res = this.upgradeSystem.switchVehicle(modelId);
    if (res.success) {
      this.renderGarage();
      this.showToast(`🚗 ALLA GUIDA: ${res.vehicle.maker} ${res.vehicle.name} (${res.vehicle.year})`);

      if (res.excessStashed > 0) {
        setTimeout(() => {
          this.showToast(`📦 CAPACITÀ SUPERATA: ${res.excessStashed} kg di carico trasferiti nel Deposito di Tappa.`);
        }, 1200);
      }
    }
  }

  restoreVehicle(modelId) {
    const success = this.upgradeSystem.restoreVehicle(modelId);
    if (success) {
      const car = CONFIG.VEHICLES_CATALOG[modelId];
      this.renderGarage();
      this.showToast(`🎉 RESTAURO COMPLETATO: ${car.maker} ${car.name} aggiunto alla tua Flotta!`);
    }
  }

  retrieveStashItems() {
    if (!this.inventorySystem) return;
    let movedAny = false;
    let curWeight = this.inventorySystem.getTotalTrunkWeight();
    const maxWeight = this.inventorySystem.trunkMaxWeight;

    for (let i = this.upgradeSystem.stationStash.length - 1; i >= 0; i--) {
      const stash = this.upgradeSystem.stationStash[i];
      const def = this.inventorySystem.getItemDef(stash.id);
      const unitW = def ? def.weight : 2.0;

      while (stash.count > 0 && curWeight + unitW <= maxWeight) {
        stash.count--;
        curWeight += unitW;
        this.inventorySystem.addItem(stash.id, 1);
        movedAny = true;
      }

      if (stash.count <= 0) {
        this.upgradeSystem.stationStash.splice(i, 1);
      }
      if (curWeight + unitW > maxWeight) break;
    }

    if (movedAny) {
      this.audioEngine.playLootPickup();
      this.renderGarage();
      this.showToast('📦 Materiali del Deposito recuperati nel bagagliaio!');
    } else {
      this.showToast('⚠️ Spazio insufficiente nel bagagliaio per prelevare dal Deposito.');
    }
  }

  renderUpgrades() {
    this.renderActiveVehicleHeader();
    const container = this.element.querySelector('#upgrade-items-container');
    container.innerHTML = '';

    const filter = this.activeUpgradeFilter;

    // Filter upgrades (omit legacy aliases)
    const upgrades = Object.values(CONFIG.UPGRADES).filter((up) => {
      if (!up.category) return false; // skip duplicates/aliases
      if (filter === 'all') return true;
      return up.category === filter;
    });

    upgrades.forEach((up) => {
      const isInstalled = this.upgradeSystem.hasUpgrade(up.id);
      const canAfford = this.upgradeSystem.canAffordUpgrade(up.id);

      // Cost chips with trunk count
      const costChips = Object.entries(up.cost).map(([itemId, needed]) => {
        const item = this.inventorySystem.trunkItems.find((i) => i.id === itemId);
        const count = item ? item.count : 0;
        const isOk = count >= needed;
        const def = this.inventorySystem.getItemDef(itemId);
        const icon = def ? def.icon : '🔩';
        const name = def ? def.name : itemId;
        return `
          <span class="up-cost-chip ${isOk ? 'chip-ok' : 'chip-missing'}">
            ${icon} ${name}: <strong>${count}/${needed}</strong>
          </span>
        `;
      }).join(' ');

      const card = document.createElement('div');
      card.className = `upgrade-card ${isInstalled ? 'installed' : ''}`;
      card.innerHTML = `
        <div class="up-header">
          <div class="up-title-wrap">
            <span class="up-icon">${up.icon || '⚙️'}</span>
            <div>
              <span class="up-category-badge">${up.categoryName || 'Tuning'}</span>
              <h4 class="up-title">${up.name}</h4>
            </div>
          </div>
          <span class="up-stat-benefit">${up.statLabel || ''}</span>
        </div>

        <p class="up-desc">${up.desc}</p>

        <div class="up-cost-row">
          <span class="cost-label">COMPONENTI:</span>
          <div class="cost-chips-wrap">${costChips}</div>
        </div>

        <div class="up-footer">
          ${
            isInstalled
              ? '<button class="item-btn btn-installed" disabled>✓ INSTALLATO SUL VEICOLO</button>'
              : `<button class="item-btn btn-install ${canAfford ? 'btn-can-install' : ''}" data-id="${up.id}" ${canAfford ? '' : 'disabled'}>
                  ${canAfford ? '🛠️ INSTALLA UPGRADE' : '🔒 RISORSE INSUFFICIENTI'}
                </button>`
          }
        </div>
      `;
      container.appendChild(card);
    });

    container.querySelectorAll('.btn-install').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        const id = e.currentTarget.dataset.id;
        const success = this.upgradeSystem.installUpgrade(id);
        if (success) {
          const upDef = this.upgradeSystem.findUpgradeDef(id);
          this.renderUpgrades();
          this.showToast(`🛠️ UPGRADE INSTALLATO: ${upDef.name}`);
        }
      });
    });
  }

  showToast(text) {
    const toast = document.createElement('div');
    toast.className = 'hud-quick-toast';
    toast.textContent = text;
    this.container.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translate(-50%, -15px)';
      setTimeout(() => toast.remove(), 400);
    }, 3200);
  }
}
