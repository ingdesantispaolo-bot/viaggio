/**
 * THE LONG MERIDIAN - Inventory & Cargo Management Modal
 * Responsive touch UI for managing vehicle trunk cargo and player backpack.
 */

import { ITEM_DEFS } from '../systems/InventorySystem.js';

export class InventoryModal {
  constructor(container, inventorySystem, audioEngine) {
    this.container = container;
    this.inventorySystem = inventorySystem;
    this.audioEngine = audioEngine;

    this.isOpen = false;
    this.element = null;
    this.buildModal();
  }

  buildModal() {
    this.element = document.createElement('div');
    this.element.className = 'game-modal-overlay';
    this.element.style.display = 'none';

    this.element.innerHTML = `
      <div class="game-modal-window">
        <div class="modal-header">
          <div class="modal-title">📦 GESTIONE CARICO & INVENTARIO</div>
          <button class="modal-close-btn" id="btn-close-inventory">✕</button>
        </div>

        <div class="modal-body-split">
          <!-- Left: Vehicle Trunk -->
          <div class="inventory-column">
            <div class="column-header">
              <span class="col-title">🚗 BAGAGLIAIO VEICOLO</span>
              <span class="weight-tag" id="trunk-weight-tag">0.0 / 120.0 KG</span>
            </div>
            <div class="items-list" id="trunk-items-container"></div>
          </div>

          <!-- Right: Player Backpack -->
          <div class="inventory-column">
            <div class="column-header">
              <span class="col-title">🎒 ZAINO PILOTA</span>
              <span class="weight-tag" id="backpack-weight-tag">0.0 / 25.0 KG</span>
            </div>
            <div class="items-list" id="backpack-items-container"></div>
          </div>
        </div>

        <div class="modal-footer">
          <span class="footer-tip">Tocca [TRASFERISCI] per spostare gli oggetti tra bagagliaio e zaino, oppure [USA] per consumarli.</span>
        </div>
      </div>
    `;

    this.container.appendChild(this.element);

    this.element.querySelector('#btn-close-inventory').addEventListener('click', () => {
      this.close();
    });
  }

  open() {
    this.isOpen = true;
    this.element.style.display = 'flex';
    this.renderItems();
    this.audioEngine.playSwitchClick(true);
  }

  close() {
    this.isOpen = false;
    this.element.style.display = 'none';
    this.audioEngine.playSwitchClick(false);
  }

  toggle() {
    if (this.isOpen) this.close();
    else this.open();
  }

  renderItems() {
    const trunkContainer = this.element.querySelector('#trunk-items-container');
    const backpackContainer = this.element.querySelector('#backpack-items-container');
    trunkContainer.innerHTML = '';
    backpackContainer.innerHTML = '';

    // Update weights
    const trunkW = this.inventorySystem.getTrunkWeight().toFixed(1);
    const packW = this.inventorySystem.getBackpackWeight().toFixed(1);
    this.element.querySelector('#trunk-weight-tag').textContent = `${trunkW} / ${this.inventorySystem.trunkMaxWeight} KG`;
    this.element.querySelector('#backpack-weight-tag').textContent = `${packW} / ${this.inventorySystem.backpackMaxWeight} KG`;

    // Render Trunk Items
    this.inventorySystem.trunkItems.forEach((item, index) => {
      const def = ITEM_DEFS[item.id] || { name: item.id, icon: '📦', weight: 1.0, desc: '' };
      const card = document.createElement('div');
      card.className = 'item-card';
      card.innerHTML = `
        <div class="item-icon">${def.icon}</div>
        <div class="item-details">
          <div class="item-name">${def.name} <span class="item-qty">x${item.count}</span></div>
          <div class="item-sub">${(def.weight * item.count).toFixed(1)} KG - ${def.desc}</div>
        </div>
        <div class="item-actions">
          <button class="item-btn btn-use" data-action="use-trunk" data-index="${index}">USA</button>
          <button class="item-btn btn-transfer" data-action="to-pack" data-index="${index}">➡️ ZAINO</button>
        </div>
      `;
      trunkContainer.appendChild(card);
    });

    if (this.inventorySystem.trunkItems.length === 0) {
      trunkContainer.innerHTML = '<div class="empty-state">Bagagliaio vuoto.</div>';
    }

    // Render Backpack Items
    this.inventorySystem.backpackItems.forEach((item, index) => {
      const def = ITEM_DEFS[item.id] || { name: item.id, icon: '📦', weight: 1.0, desc: '' };
      const card = document.createElement('div');
      card.className = 'item-card';
      card.innerHTML = `
        <div class="item-icon">${def.icon}</div>
        <div class="item-details">
          <div class="item-name">${def.name} <span class="item-qty">x${item.count}</span></div>
          <div class="item-sub">${(def.weight * item.count).toFixed(1)} KG - ${def.desc}</div>
        </div>
        <div class="item-actions">
          <button class="item-btn btn-use" data-action="use-pack" data-index="${index}">USA</button>
          <button class="item-btn btn-transfer" data-action="to-trunk" data-index="${index}">⬅️ VEICOLO</button>
        </div>
      `;
      backpackContainer.appendChild(card);
    });

    if (this.inventorySystem.backpackItems.length === 0) {
      backpackContainer.innerHTML = '<div class="empty-state">Zaino vuoto.</div>';
    }

    // Bind action buttons
    this.element.querySelectorAll('.item-btn').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        const action = e.target.dataset.action;
        const idx = parseInt(e.target.dataset.index, 10);

        if (action === 'use-trunk') {
          this.inventorySystem.useItemFromTrunk(idx);
        } else if (action === 'use-pack') {
          this.inventorySystem.useItemFromBackpack(idx);
        } else if (action === 'to-pack') {
          this.inventorySystem.transferToBackpack(idx);
        } else if (action === 'to-trunk') {
          this.inventorySystem.transferToTrunk(idx);
        }
        this.renderItems();
      });
    });
  }
}
