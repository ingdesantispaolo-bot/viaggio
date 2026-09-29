/**
 * THE LONG MERIDIAN - Territorial Settlement & Scavenging Modal
 * Handles lore dossiers, community barter trade, vehicle refuel/repairs, roadside diner, and structured site scavenging.
 */

import { ITEM_DEFS } from '../systems/InventorySystem.js';
import { CONFIG } from '../config.js';

export class ScavengeModal {
  constructor(container, inventorySystem, audioEngine) {
    this.container = container;
    this.inventorySystem = inventorySystem;
    this.audioEngine = audioEngine;

    this.currentPOI = null;
    this.isOpen = false;
    this.activeTab = 'dossier'; // 'dossier' | 'barter' | 'services' | 'diner'
    this.element = null;
    this.buildModal();
  }

  getAvailableScrap() {
    const entry = this.inventorySystem.trunkItems.find((i) => i.id === 'scrap_metal');
    return entry ? entry.count : 0;
  }

  spendScrap(amount) {
    const entry = this.inventorySystem.trunkItems.find((i) => i.id === 'scrap_metal');
    if (!entry || entry.count < amount) return false;
    entry.count -= amount;
    if (entry.count <= 0) {
      const idx = this.inventorySystem.trunkItems.indexOf(entry);
      this.inventorySystem.trunkItems.splice(idx, 1);
    }
    return true;
  }

  buildModal() {
    this.element = document.createElement('div');
    this.element.className = 'game-modal-overlay';
    this.element.style.display = 'none';

    this.element.innerHTML = `
      <div class="game-modal-window scavenge-window settlement-window">
        <div class="modal-header">
          <div class="modal-title" id="scavenge-title">🏛️ INSEDIAMENTO TERRITORIALE</div>
          <button class="modal-close-btn" id="btn-close-scavenge">✕</button>
        </div>

        <!-- Navigation Tabs (Visible in Settlements) -->
        <div class="settlement-nav-tabs" id="settlement-nav-tabs">
          <button class="tab-btn active" id="tab-btn-dossier">📖 DOSSIER</button>
          <button class="tab-btn" id="tab-btn-barter">🛒 EMPORIO & BARATTO</button>
          <button class="tab-btn" id="tab-btn-services">⛽ RIFORNIMENTO & OFFICINA</button>
          <button class="tab-btn" id="tab-btn-diner">🍲 TAVOLA CALDA & RISTORO</button>
        </div>

        <div class="scavenge-body">
          <!-- Top Identity Card with Live Scrap Counter -->
          <div class="scavenge-banner" id="scavenge-banner-box">
            <span class="scavenge-big-icon" id="scavenge-icon">🏘️</span>
            <div class="scavenge-desc-box">
              <h3 id="scavenge-name">Nome Località</h3>
              <p id="scavenge-subtext">Comunità / Tipologia Struttura</p>
            </div>
            <div class="settlement-wallet-badge" id="settlement-wallet" style="margin-left: auto; background: rgba(245, 158, 11, 0.15); border: 1px solid rgba(245, 158, 11, 0.4); border-radius: 6px; padding: 6px 14px; text-align: right;">
              <span style="font-size: 11px; color: #94a3b8; display: block; font-family: var(--font-tech);">ROTTAMI DISPONIBILI:</span>
              <strong id="wallet-scrap-count" style="font-size: 17px; color: #fbbf24; font-family: var(--font-tech);">0</strong> <span style="font-size: 12px; color: #fbbf24;">UNITÀ</span>
            </div>
          </div>

          <!-- Live Status Feedback Banner -->
          <div class="barter-feedback-banner" id="settlement-feedback" style="margin-bottom: 12px; padding: 8px 14px; border-radius: 6px; font-size: 13px; font-family: var(--font-tech); background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255, 255, 255, 0.1); color: #94a3b8;">
            Benvenuto alla stazione di servizio e insediamento del meridiano.
          </div>

          <!-- TAB 1: DOSSIER & LORE -->
          <div class="settlement-tab-pane" id="pane-dossier">
            <div class="lore-box">
              <div class="lore-section-title">CRONACHE & STORIA DELLA COMUNITÀ</div>
              <p class="lore-text" id="lore-history-text">Caricamento dossier...</p>
            </div>

            <div class="tactical-advice-box">
              <div class="tactical-title">⚠️ AVVISO TECNICO DI ROTTA DELL'INGEGNERE</div>
              <p class="tactical-text" id="lore-tactical-text">Consiglio di viaggio...</p>
            </div>

            <div class="settlement-stats-grid">
              <div class="s-stat"><span class="s-label">FAZIONE:</span> <strong id="s-faction">-</strong></div>
              <div class="s-stat"><span class="s-label">POPOLAZIONE:</span> <strong id="s-pop">-</strong></div>
              <div class="s-stat"><span class="s-label">DOMANDA CRITICA (+250%):</span> <strong id="s-demand" class="highlight-demand">-</strong></div>
              <div class="s-stat"><span class="s-label">SURPLUS EXPORT (-30%):</span> <strong id="s-export" class="highlight-export">-</strong></div>
            </div>
          </div>

          <!-- TAB 2: SMART BARTER TRADING (Buy & Sell) -->
          <div class="settlement-tab-pane" id="pane-barter" style="display: none;">
            <div class="barter-columns-layout">
              <!-- What Settlement is Selling (Export) -->
              <div class="barter-col">
                <div class="col-title">ACQUISTA DALL'EMPORIO LOCALE (ROTTAMI)</div>
                <div class="barter-items-list" id="barter-market-items"></div>
              </div>

              <!-- What Settlement buys from Player Trunk -->
              <div class="barter-col">
                <div class="col-title">VENDI MERCI DEL TUO BAGAGLIAIO (INCASSA ROTTAMI)</div>
                <div class="barter-items-list" id="barter-player-items"></div>
              </div>
            </div>
          </div>

          <!-- TAB 3: SERVICES (Refuel, Repair & Tires) -->
          <div class="settlement-tab-pane" id="pane-services" style="display: none;">
            <div class="services-container">
              <!-- Service 1: Rifornimento Standard -->
              <div class="service-card">
                <div class="service-icon">⛽</div>
                <div class="service-info">
                  <h4>Rifornimento Pompa Standard (+15L)</h4>
                  <p>Eroga 15 litri di carburante pulito nel serbatoio del veicolo.</p>
                </div>
                <button class="item-btn btn-service" id="btn-service-fuel15">BARATTA (8 ROTTAMI)</button>
              </div>

              <!-- Service 2: Pieno Completo -->
              <div class="service-card">
                <div class="service-icon">⚡</div>
                <div class="service-info">
                  <h4>Pieno Completo al Serbatoio (100% Max)</h4>
                  <p>Rifornisce completamente il veicolo fino alla capienza massima.</p>
                </div>
                <button class="item-btn btn-service" id="btn-service-fullfuel">BARATTA (22 ROTTAMI)</button>
              </div>

              <!-- Service 3: Saldatura Scocca Telaio -->
              <div class="service-card">
                <div class="service-icon">🛡️</div>
                <div class="service-info">
                  <h4>Saldatura & Revisione Telaio (+40% Hull)</h4>
                  <p>I carpentieri rinforzano i longheroni e raddrizzano i pannelli danneggiati.</p>
                </div>
                <button class="item-btn btn-service" id="btn-service-repair">BARATTA (16 ROTTAMI)</button>
              </div>

              <!-- Service 4: Gommaio e Sostituzione Pneumatico -->
              <div class="service-card">
                <div class="service-icon">🛞</div>
                <div class="service-info">
                  <h4>Sostituzione & Equilibratura Gomme (Ripara Foratura)</h4>
                  <p>Smonta e ripara qualsiasi pneumatico forato, ripristinando il grip ideale.</p>
                </div>
                <button class="item-btn btn-service" id="btn-service-tire">BARATTA (12 ROTTAMI)</button>
              </div>
            </div>
          </div>

          <!-- TAB 4: DINER & TAVOLA CALDA -->
          <div class="settlement-tab-pane" id="pane-diner" style="display: none;">
            <div class="services-container">
              <div class="service-card">
                <div class="service-icon">🍲</div>
                <div class="service-info">
                  <h4>Stufato Caldo d'Alce & Caffè Nero</h4>
                  <p>Pasto sostanzioso al bancone: azzera la fame, disseta e riscalda a 37.0°C (+25 HP).</p>
                </div>
                <button class="item-btn btn-service" id="btn-diner-meal">ACQUISTA (6 ROTTAMI)</button>
              </div>

              <div class="service-card">
                <div class="service-icon">🛏️</div>
                <div class="service-info">
                  <h4>Notte in Cabina Riscaldata & Ristoro Totale</h4>
                  <p>Riposo completo al sicuro dalle intemperie: rigenera 100% Salute e vitalità.</p>
                </div>
                <button class="item-btn btn-service" id="btn-diner-rest">ACQUISTA (16 ROTTAMI)</button>
              </div>
            </div>
          </div>

          <!-- REUSED FOR PURE SCAVENGE SITES -->
          <div class="scavenge-pure-pane" id="pane-pure-scavenge" style="display: none;">
            <div class="loot-section-title" id="loot-header-title">RISORSE STRUTTURALI RECUPERABILI</div>
            <div class="loot-items-list" id="loot-items-container"></div>
          </div>
        </div>

        <div class="modal-footer" id="scavenge-modal-footer">
          <button class="btn-primary-action" id="btn-take-all-loot">PRENDI TUTTO NEL BAGAGLIAIO</button>
        </div>
      </div>
    `;

    this.container.appendChild(this.element);
    this.bindEvents();
  }

  bindEvents() {
    this.element.querySelector('#btn-close-scavenge').addEventListener('click', () => {
      this.close();
    });

    this.element.querySelector('#btn-take-all-loot').addEventListener('click', () => {
      this.takeAllLoot();
    });

    // Tab buttons
    const btnDossier = this.element.querySelector('#tab-btn-dossier');
    const btnBarter = this.element.querySelector('#tab-btn-barter');
    const btnServices = this.element.querySelector('#tab-btn-services');
    const btnDiner = this.element.querySelector('#tab-btn-diner');

    btnDossier.addEventListener('click', () => this.switchTab('dossier'));
    btnBarter.addEventListener('click', () => this.switchTab('barter'));
    btnServices.addEventListener('click', () => this.switchTab('services'));
    btnDiner.addEventListener('click', () => this.switchTab('diner'));

    // Service buttons
    this.element.querySelector('#btn-service-fuel15').addEventListener('click', () => {
      this.executeServiceFuel(15, 8);
    });
    this.element.querySelector('#btn-service-fullfuel').addEventListener('click', () => {
      this.executeServiceFullFuel(22);
    });
    this.element.querySelector('#btn-service-repair').addEventListener('click', () => {
      this.executeServiceRepair(40, 16);
    });
    this.element.querySelector('#btn-service-tire').addEventListener('click', () => {
      this.executeServiceTire(12);
    });

    // Diner buttons
    this.element.querySelector('#btn-diner-meal').addEventListener('click', () => {
      this.executeDinerMeal(6);
    });
    this.element.querySelector('#btn-diner-rest').addEventListener('click', () => {
      this.executeDinerRest(16);
    });
  }

  showFeedback(text, isSuccess = true) {
    const fb = this.element.querySelector('#settlement-feedback');
    if (!fb) return;
    fb.textContent = text;
    fb.style.color = isSuccess ? '#34d399' : '#f87171';
    fb.style.borderColor = isSuccess ? 'rgba(52, 211, 153, 0.4)' : 'rgba(248, 113, 113, 0.4)';
    fb.style.background = isSuccess ? 'rgba(6, 78, 59, 0.4)' : 'rgba(127, 29, 29, 0.4)';
  }

  updateWalletDisplay() {
    const scrapCount = this.getAvailableScrap();
    const walletEl = this.element.querySelector('#wallet-scrap-count');
    if (walletEl) walletEl.textContent = scrapCount;
  }

  switchTab(tabKey) {
    this.activeTab = tabKey;
    const tabs = ['dossier', 'barter', 'services', 'diner'];

    tabs.forEach((t) => {
      const btn = this.element.querySelector(`#tab-btn-${t}`);
      const pane = this.element.querySelector(`#pane-${t}`);
      if (btn) btn.classList.toggle('active', t === tabKey);
      if (pane) pane.style.display = t === tabKey ? 'block' : 'none';
    });

    this.updateWalletDisplay();

    if (tabKey === 'barter') {
      this.renderBarterPanels();
    }
    this.audioEngine.playSwitchClick(true);
  }

  openWithPOI(poi) {
    this.currentPOI = poi;
    this.isOpen = true;
    this.element.style.display = 'flex';

    const isSettlement = poi.isSettlement;
    const navTabs = this.element.querySelector('#settlement-nav-tabs');
    const footer = this.element.querySelector('#scavenge-modal-footer');
    const pureScavenge = this.element.querySelector('#pane-pure-scavenge');
    const wallet = this.element.querySelector('#settlement-wallet');
    const fb = this.element.querySelector('#settlement-feedback');

    this.element.querySelector('#scavenge-icon').textContent = poi.config.icon || '📍';
    this.element.querySelector('#scavenge-name').textContent = poi.config.name;

    this.updateWalletDisplay();

    if (isSettlement) {
      // SETTLEMENT / SERVICE AREA MODE
      this.element.querySelector('#scavenge-title').textContent = '🏛️ AREA DI SERVIZIO & INSEDIAMENTO';
      navTabs.style.display = 'flex';
      pureScavenge.style.display = 'none';
      footer.style.display = 'none';
      if (wallet) wallet.style.display = 'block';
      if (fb) fb.style.display = 'block';

      const sConf = poi.settlementConfig || CONFIG.SETTLEMENTS[poi.settlementKey] || {};
      const biomeDef = Object.values(CONFIG.BIOMES).find((b) => b.id === sConf.biomeId) || {};

      this.element.querySelector('#scavenge-subtext').textContent =
        `${sConf.faction || 'Comunità di Frontiera'} — Settore PK ${(poi.position.z / 1000).toFixed(1)} KM`;

      this.element.querySelector('#lore-history-text').textContent =
        sConf.description || biomeDef.history || 'Insediamento fortificato con rifornimenti e officina meccanica.';

      this.element.querySelector('#lore-tactical-text').textContent =
        sConf.tacticalAdvice || biomeDef.environmentalThreat || 'Fai scorta di carburante e verifica le condizioni del veicolo.';

      this.element.querySelector('#s-faction').textContent = sConf.faction || 'Sopravvissuti';
      this.element.querySelector('#s-pop').textContent = `${sConf.population || 40} Abitanti`;

      const demandNames = (biomeDef.criticalNeed || []).map((id) => ITEM_DEFS[id]?.name || id).join(', ');
      const exportNames = (biomeDef.primaryExport || []).map((id) => ITEM_DEFS[id]?.name || id).join(', ');

      this.element.querySelector('#s-demand').textContent = demandNames || 'Nessuna';
      this.element.querySelector('#s-export').textContent = exportNames || 'Nessuna';

      this.showFeedback(`Benvenuto a ${poi.config.name}. Servizi di rifornimento e commercio attivi.`);
      this.switchTab('dossier');
    } else {
      // PURE EXPLORATION / SCAVENGE SITE MODE
      this.element.querySelector('#scavenge-title').textContent = '🔍 ISPEZIONE SITO STRUTTURALE';
      navTabs.style.display = 'none';
      this.element.querySelector('#pane-dossier').style.display = 'none';
      this.element.querySelector('#pane-barter').style.display = 'none';
      this.element.querySelector('#pane-services').style.display = 'none';
      this.element.querySelector('#pane-diner').style.display = 'none';
      if (wallet) wallet.style.display = 'none';
      if (fb) fb.style.display = 'none';
      pureScavenge.style.display = 'block';
      footer.style.display = 'flex';

      const note = poi.config.loreNote || 'Installazione industriale dismessa lungo il meridiano.';
      const dangerPct = Math.round((poi.config.dangerLevel || 0.2) * 100);
      this.element.querySelector('#scavenge-subtext').textContent =
        `Rischio Ambientale: ${dangerPct}% — ${note}`;

      this.renderLootList();
    }

    this.audioEngine.playSwitchClick(true);
  }

  close() {
    this.isOpen = false;
    this.element.style.display = 'none';
    this.audioEngine.playSwitchClick(false);
  }

  renderLootList() {
    const container = this.element.querySelector('#loot-items-container');
    container.innerHTML = '';

    if (!this.currentPOI || !this.currentPOI.loot || this.currentPOI.loot.length === 0) {
      container.innerHTML = '<div class="empty-state">Tutte le risorse sono state recuperate da quest\'area.</div>';
      return;
    }

    this.currentPOI.loot.forEach((itemId, index) => {
      const def = ITEM_DEFS[itemId] || { name: itemId, icon: '📦', weight: 1.0, desc: '' };
      const card = document.createElement('div');
      card.className = 'item-card';
      card.innerHTML = `
        <div class="item-icon">${def.icon}</div>
        <div class="item-details">
          <div class="item-name">${def.name}</div>
          <div class="item-sub">${def.weight} KG - ${def.desc}</div>
        </div>
        <div class="item-actions">
          <button class="item-btn btn-use" data-index="${index}">PRENDI</button>
        </div>
      `;
      container.appendChild(card);
    });

    container.querySelectorAll('.btn-use').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        const idx = parseInt(e.target.dataset.index, 10);
        this.takeSingleItem(idx);
      });
    });
  }

  takeSingleItem(index) {
    if (!this.currentPOI || !this.currentPOI.loot[index]) return;
    const itemId = this.currentPOI.loot[index];

    const added = this.inventorySystem.addItemToTrunk(itemId, 1) || this.inventorySystem.addItemToBackpack(itemId, 1);
    if (added) {
      this.currentPOI.loot.splice(index, 1);
      if (this.currentPOI.loot.length === 0) {
        this.currentPOI.scavenged = true;
      }
      this.renderLootList();
    }
  }

  takeAllLoot() {
    if (!this.currentPOI || !this.currentPOI.loot) return;
    for (let i = this.currentPOI.loot.length - 1; i >= 0; i--) {
      const itemId = this.currentPOI.loot[i];
      const added = this.inventorySystem.addItemToTrunk(itemId, 1) || this.inventorySystem.addItemToBackpack(itemId, 1);
      if (added) {
        this.currentPOI.loot.splice(i, 1);
      }
    }
    this.currentPOI.scavenged = true;
    this.renderLootList();
    setTimeout(() => this.close(), 400);
  }

  // --- SMART BARTER TRADING RENDERER ---

  renderBarterPanels() {
    const sConf = this.currentPOI ? this.currentPOI.settlementConfig : null;
    const biomeDef = sConf ? Object.values(CONFIG.BIOMES).find((b) => b.id === sConf.biomeId) : null;
    const marketContainer = this.element.querySelector('#barter-market-items');
    const playerContainer = this.element.querySelector('#barter-player-items');

    marketContainer.innerHTML = '';
    playerContainer.innerHTML = '';

    if (!sConf || !biomeDef) {
      marketContainer.innerHTML = '<div class="empty-state">Nessun mercato attivo in quest\'area.</div>';
      return;
    }

    // 1. Items available for purchase from Settlement (surplus exports + essential goods)
    const marketItems = [
      ...(biomeDef.primaryExport || []),
      'fuel_canister',
      'engine_oil',
      'water_purified',
      'canned_stew',
      'spare_tire',
      'medkit'
    ];
    const uniqueMarketItems = [...new Set(marketItems)].filter((id) => id !== 'scrap_metal');

    uniqueMarketItems.forEach((itemId) => {
      const def = ITEM_DEFS[itemId];
      if (!def) return;
      const isExport = (biomeDef.primaryExport || []).includes(itemId);
      const buyCost = Math.max(3, Math.round((def.baseValue || 10) * (isExport ? (sConf.sellsDiscount || 0.7) : 1.0) / 2));

      const card = document.createElement('div');
      card.className = `barter-item-card ${isExport ? 'export-card' : ''}`;
      card.innerHTML = `
        <div class="b-icon">${def.icon}</div>
        <div class="b-details">
          <div class="b-name">${def.name} ${isExport ? '<span class="badge-surplus">SURPLUS -30%</span>' : ''}</div>
          <div class="b-cost">Prezzo: <strong>${buyCost} Rottami</strong></div>
        </div>
        <button class="b-action-btn btn-buy-item" data-id="${itemId}" data-cost="${buyCost}">COMPRA</button>
      `;
      marketContainer.appendChild(card);
    });

    // 2. Items in Player Trunk that can be sold for Scrap
    const criticalNeeds = biomeDef.criticalNeed || [];
    const eligibleTrunkItems = this.inventorySystem.trunkItems.filter((i) => i.id !== 'scrap_metal' && i.count > 0);

    if (eligibleTrunkItems.length === 0) {
      playerContainer.innerHTML = '<div class="empty-state">Nessun oggetto vendibile nel bagagliaio. Saccheggia siti o conserva rifornimenti.</div>';
    } else {
      eligibleTrunkItems.forEach((entry) => {
        const def = ITEM_DEFS[entry.id];
        if (!def) return;
        const isNeeded = criticalNeeds.includes(entry.id);
        const sellVal = Math.max(2, Math.round((def.baseValue || 10) * (isNeeded ? (sConf.buysMultiplier || 2.5) : 1.0) / 3));

        const card = document.createElement('div');
        card.className = `barter-item-card ${isNeeded ? 'needed-card' : ''}`;
        card.innerHTML = `
          <div class="b-icon">${def.icon}</div>
          <div class="b-details">
            <div class="b-name">${def.name} (x${entry.count}) ${isNeeded ? '<span class="badge-need">DOMANDA +250%</span>' : ''}</div>
            <div class="b-cost">Valore vendita: <strong>+${sellVal} Rottami</strong></div>
          </div>
          <button class="b-action-btn btn-sell-item" data-id="${entry.id}" data-val="${sellVal}">VENDI (x1)</button>
        `;
        playerContainer.appendChild(card);
      });
    }

    // Attach barter listeners
    marketContainer.querySelectorAll('.btn-buy-item').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        const targetId = e.currentTarget.dataset.id;
        const cost = parseInt(e.currentTarget.dataset.cost, 10);
        this.buyItemWithScrap(targetId, cost);
      });
    });

    playerContainer.querySelectorAll('.btn-sell-item').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        const giveId = e.currentTarget.dataset.id;
        const val = parseInt(e.currentTarget.dataset.val, 10);
        this.sellItemForScrap(giveId, val);
      });
    });
  }

  buyItemWithScrap(itemId, cost) {
    const scrapAvailable = this.getAvailableScrap();
    if (scrapAvailable < cost) {
      this.showFeedback(`Rottami insufficienti! Richiesti ${cost} rottami, ne possiedi ${scrapAvailable}.`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }

    const added = this.inventorySystem.addItemToTrunk(itemId, 1);
    if (!added) {
      this.showFeedback(`Spazio insufficiente nel bagagliaio del veicolo!`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }

    this.spendScrap(cost);
    const def = ITEM_DEFS[itemId] || { name: itemId };
    this.showFeedback(`Acquistato con successo: 1x ${def.name} per ${cost} rottami!`, true);
    this.audioEngine.playLootPickup();
    this.updateWalletDisplay();
    this.renderBarterPanels();
  }

  sellItemForScrap(giveItemId, scrapEarned) {
    const giveEntry = this.inventorySystem.trunkItems.find((i) => i.id === giveItemId && i.count > 0);
    if (!giveEntry) return;

    giveEntry.count--;
    if (giveEntry.count <= 0) {
      const idx = this.inventorySystem.trunkItems.indexOf(giveEntry);
      this.inventorySystem.trunkItems.splice(idx, 1);
    }

    this.inventorySystem.addItemToTrunk('scrap_metal', scrapEarned);
    const def = ITEM_DEFS[giveItemId] || { name: giveItemId };
    this.showFeedback(`Venduto 1x ${def.name} ➔ Incassati +${scrapEarned} Rottami Metallici!`, true);
    this.audioEngine.playLootPickup();
    this.updateWalletDisplay();
    this.renderBarterPanels();
  }

  // --- SERVICE ACTIONS ---

  executeServiceFuel(liters, cost) {
    if (this.inventorySystem.vehicle.fuel >= this.inventorySystem.vehicle.maxFuel) {
      this.showFeedback(`Serbatoio già al massimo della capienza (${this.inventorySystem.vehicle.maxFuel}L)!`, false);
      return;
    }
    if (!this.spendScrap(cost)) {
      this.showFeedback(`Rottami insufficienti per il rifornimento (richiesti ${cost} rottami).`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }
    this.inventorySystem.vehicle.fuel = Math.min(this.inventorySystem.vehicle.maxFuel, this.inventorySystem.vehicle.fuel + liters);
    this.showFeedback(`Rifornimento erogato: +${liters}L aggiunti al serbatoio (Attuale: ${Math.round(this.inventorySystem.vehicle.fuel)}L)!`, true);
    this.audioEngine.playLootPickup();
    this.updateWalletDisplay();
  }

  executeServiceFullFuel(cost) {
    if (this.inventorySystem.vehicle.fuel >= this.inventorySystem.vehicle.maxFuel) {
      this.showFeedback(`Serbatoio già completamente pieno!`, false);
      return;
    }
    if (!this.spendScrap(cost)) {
      this.showFeedback(`Rottami insufficienti per il pieno completo (richiesti ${cost} rottami).`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }
    const addedLiters = Math.round(this.inventorySystem.vehicle.maxFuel - this.inventorySystem.vehicle.fuel);
    this.inventorySystem.vehicle.fuel = this.inventorySystem.vehicle.maxFuel;
    this.showFeedback(`Pieno completo eseguito! +${addedLiters}L erogati al serbatoio.`, true);
    this.audioEngine.playLootPickup();
    this.updateWalletDisplay();
  }

  executeServiceRepair(hullPercent, cost) {
    if (this.inventorySystem.vehicle.hull >= 100) {
      this.showFeedback(`Telaio e scocca sono già in condizioni perfette (100%)!`, false);
      return;
    }
    if (!this.spendScrap(cost)) {
      this.showFeedback(`Rottami insufficienti per la riparazione (richiesti ${cost} rottami).`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }
    this.inventorySystem.vehicle.hull = Math.min(100, this.inventorySystem.vehicle.hull + hullPercent);
    this.showFeedback(`Saldatura completata: +${hullPercent}% integrità telaio ripristinata (Attuale: ${Math.round(this.inventorySystem.vehicle.hull)}%)!`, true);
    this.audioEngine.playImpact(0.5);
    this.updateWalletDisplay();
  }

  executeServiceTire(cost) {
    const v = this.inventorySystem.vehicle;
    if (!v.hasFlatTire && (v.tireCondition === undefined || v.tireCondition >= 95)) {
      this.showFeedback(`Gli pneumatici sono in ottime condizioni, nessuna riparazione necessaria.`, false);
      return;
    }
    if (!this.spendScrap(cost)) {
      this.showFeedback(`Rottami insufficienti per il cambio pneumatici (richiesti ${cost} rottami).`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }
    v.hasFlatTire = false;
    v.tireCondition = 100;
    this.showFeedback(`Pneumatico sostituito ed equilibrato con successo! Tenuta di strada ripristinata al 100%.`, true);
    this.audioEngine.playImpact(0.4);
    this.updateWalletDisplay();
  }

  // --- DINER & REST ACTIONS ---

  executeDinerMeal(cost) {
    const s = this.inventorySystem.survivalState;
    if (!this.spendScrap(cost)) {
      this.showFeedback(`Rottami insufficienti per la tavola calda (richiesti ${cost} rottami).`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }
    s.hunger = Math.max(0, s.hunger - 50);
    s.thirst = Math.max(0, s.thirst - 60);
    s.health = Math.min(CONFIG.SURVIVAL.MAX_HEALTH, s.health + 25);
    s.bodyTemp = 37.0;
    this.showFeedback(`Pasto caldo consumato: fame e sete saziate, temperatura normalizzata a 37.0°C!`, true);
    this.audioEngine.playLootPickup();
    this.updateWalletDisplay();
  }

  executeDinerRest(cost) {
    const s = this.inventorySystem.survivalState;
    if (!this.spendScrap(cost)) {
      this.showFeedback(`Rottami insufficienti per la camera del motel (richiesti ${cost} rottami).`, false);
      this.audioEngine.playImpact(0.2);
      return;
    }
    s.health = CONFIG.SURVIVAL.MAX_HEALTH;
    s.hunger = 0;
    s.thirst = 0;
    s.bodyTemp = 37.0;
    this.showFeedback(`Riposo completato al calduccio: salute al 100% e tutte le vitalità ripristinate!`, true);
    this.audioEngine.playLootPickup();
    this.updateWalletDisplay();
  }
}
