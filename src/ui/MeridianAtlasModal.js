/**
 * THE LONG MERIDIAN - Tactical Route Atlas & Regional Lore Gazetteer
 * Interactive navigation encyclopedia mapping biomes, settlements, lore histories, and economic matrices.
 */

import { CONFIG } from '../config.js';
import { ITEM_DEFS } from '../systems/InventorySystem.js';

export class MeridianAtlasModal {
  constructor(container, audioEngine) {
    this.container = container;
    this.audioEngine = audioEngine;

    this.isOpen = false;
    this.selectedBiomeId = 'mediterranean_coast';
    this.element = null;

    this.buildModal();
  }

  buildModal() {
    this.element = document.createElement('div');
    this.element.className = 'game-modal-overlay';
    this.element.style.display = 'none';

    this.element.innerHTML = `
      <div class="game-modal-window atlas-window">
        <div class="modal-header">
          <div class="modal-title">🗺️ ATLANTE DELLA SPEDIZIONE IL GRANDE MERIDIANO (TRANS-EARTH CORRIDOR)</div>
          <button class="modal-close-btn" id="btn-close-atlas">✕</button>
        </div>

        <div class="atlas-body">
          <!-- Left Sidebar: List of Biome Sectors -->
          <div class="atlas-sectors-sidebar" id="atlas-sectors-list"></div>

          <!-- Right Content: Detailed Intelligence Dossier -->
          <div class="atlas-dossier-panel">
            <div class="dossier-header-strip">
              <div class="dossier-titles">
                <h2 id="dossier-biome-name">COSTA MEDITERRANEA</h2>
                <div class="dossier-sub" id="dossier-biome-sub">Settore 0 — [PK 0.0 - 0.65 KM]</div>
              </div>
              <div class="dossier-badge" id="dossier-settlement-badge">PORTO DI SAN VITO</div>
            </div>

            <div class="dossier-scroll-content">
              <div class="dossier-block">
                <div class="block-title">ARCHIVIO STORICO & PROFILO TERRITORIALE</div>
                <p class="block-text" id="dossier-history-text">-</p>
              </div>

              <div class="dossier-block threat-block">
                <div class="block-title">⚠️ ANALISI PERICOLI & STRESS MECCANICO DEL VEICOLO</div>
                <p class="block-text" id="dossier-threat-text">-</p>
                <div class="recommended-gear-row">
                  <span class="gear-tag">CONSIGLIO D'OFFICINA:</span>
                  <strong id="dossier-gear-text">-</strong>
                </div>
              </div>

              <div class="dossier-block economics-block">
                <div class="block-title">⚖️ MATRICE ECONOMICA & COMMERCIO REGIONALE</div>
                
                <div class="econ-two-cols">
                  <div class="econ-box export-box">
                    <div class="econ-title">SURPLUS ESPORTATO (Offerto a -30%)</div>
                    <ul class="econ-list" id="dossier-export-list"></ul>
                  </div>

                  <div class="econ-box demand-box">
                    <div class="econ-title">SCARSITÀ CRITICA (Pagato a +250%)</div>
                    <ul class="econ-list" id="dossier-demand-list"></ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <div class="atlas-status-note">IL GRANDE MERIDIANO — SPEDIZIONE ATTRAVERSO GLI 8 BIOMI NATURALI DELLA TERRA (5.200M)</div>
          <button class="btn-primary-action" id="btn-close-atlas-bottom">TORNA AL COCKPIT</button>
        </div>
      </div>
    `;

    this.container.appendChild(this.element);
    this.bindEvents();
    this.renderSidebar();
  }

  bindEvents() {
    this.element.querySelector('#btn-close-atlas').addEventListener('click', () => {
      this.close();
    });
    this.element.querySelector('#btn-close-atlas-bottom').addEventListener('click', () => {
      this.close();
    });
  }

  renderSidebar() {
    const list = this.element.querySelector('#atlas-sectors-list');
    list.innerHTML = '';

    const biomes = Object.values(CONFIG.BIOMES);
    biomes.forEach((b) => {
      const item = document.createElement('div');
      item.className = `atlas-sector-item ${b.id === this.selectedBiomeId ? 'active' : ''}`;
      item.dataset.id = b.id;

      const pkStart = ((b.sectorIndex * 650) / 1000).toFixed(1);
      const pkEnd = (((b.sectorIndex + 1) * 650) / 1000).toFixed(1);

      item.innerHTML = `
        <div class="sector-badge">SETTORE ${b.sectorIndex}</div>
        <div class="sector-title">${b.name}</div>
        <div class="sector-pk">PK ${pkStart} - ${pkEnd} KM</div>
        <div class="sector-settlement">📍 ${b.settlementName}</div>
      `;

      item.addEventListener('click', () => {
        this.selectBiome(b.id);
      });

      list.appendChild(item);
    });
  }

  selectBiome(biomeId) {
    this.selectedBiomeId = biomeId;

    this.element.querySelectorAll('.atlas-sector-item').forEach((it) => {
      it.classList.toggle('active', it.dataset.id === biomeId);
    });

    const biome = Object.values(CONFIG.BIOMES).find((b) => b.id === biomeId);
    if (!biome) return;

    const pkStart = ((biome.sectorIndex * 650) / 1000).toFixed(1);
    const pkEnd = (((biome.sectorIndex + 1) * 650) / 1000).toFixed(1);

    this.element.querySelector('#dossier-biome-name').textContent = biome.name.toUpperCase();
    this.element.querySelector('#dossier-biome-sub').textContent =
      `${biome.subname} — Settore ${biome.sectorIndex} [PK ${pkStart} - ${pkEnd} KM]`;

    this.element.querySelector('#dossier-settlement-badge').textContent = `HUB: ${biome.settlementName}`;
    this.element.querySelector('#dossier-history-text').textContent = biome.history;
    this.element.querySelector('#dossier-threat-text').textContent = biome.environmentalThreat;
    this.element.querySelector('#dossier-gear-text').textContent = biome.recommendedGear || 'Nessuna specifica.';

    // Populate Export items
    const exportList = this.element.querySelector('#dossier-export-list');
    exportList.innerHTML = '';
    (biome.primaryExport || []).forEach((itemId) => {
      const def = ITEM_DEFS[itemId] || { name: itemId, icon: '📦' };
      const li = document.createElement('li');
      li.innerHTML = `<span class="icon">${def.icon}</span> <strong>${def.name}</strong> <span class="discount">-30%</span>`;
      exportList.appendChild(li);
    });

    // Populate Demand items
    const demandList = this.element.querySelector('#dossier-demand-list');
    demandList.innerHTML = '';
    (biome.criticalNeed || []).forEach((itemId) => {
      const def = ITEM_DEFS[itemId] || { name: itemId, icon: '📦' };
      const li = document.createElement('li');
      li.innerHTML = `<span class="icon">${def.icon}</span> <strong>${def.name}</strong> <span class="surge">+250%</span>`;
      demandList.appendChild(li);
    });

    this.audioEngine.playSwitchClick(true);
  }

  toggle(currentBiomeId) {
    if (this.isOpen) {
      this.close();
    } else {
      this.open(currentBiomeId);
    }
  }

  open(currentBiomeId) {
    this.isOpen = true;
    this.element.style.display = 'flex';
    if (currentBiomeId) {
      this.selectBiome(currentBiomeId);
    } else {
      this.selectBiome(this.selectedBiomeId);
    }
    this.audioEngine.playSwitchClick(true);
  }

  close() {
    this.isOpen = false;
    this.element.style.display = 'none';
    this.audioEngine.playSwitchClick(false);
  }
}
