/**
 * THE LONG MERIDIAN - Story & Mission Diary Modal ("Diario di Bordo & Logbook")
 * Fullscreen tactical journal tracking the 6 expedition chapters, CB radio transcripts,
 * real-time objectives checklist, rewards claiming, and Paolo's engineering notes.
 */

export class StoryDiaryModal {
  constructor(container, storyDirector, audioEngine) {
    this.container = container;
    this.storyDirector = storyDirector;
    this.audioEngine = audioEngine;

    this.isOpen = false;
    this.activeTab = 'chapters'; // 'chapters' | 'radio' | 'notes'
    this.selectedChapterIndex = this.storyDirector ? this.storyDirector.activeChapterIndex : 0;
    this.element = null;

    this.buildModal();
  }

  buildModal() {
    this.element = document.createElement('div');
    this.element.className = 'game-modal-overlay story-diary-overlay';
    this.element.style.display = 'none';

    this.element.innerHTML = `
      <div class="game-modal-window diary-window">
        <div class="modal-header diary-header">
          <div class="modal-title">
            <span class="diary-title-icon">📖</span>
            <span class="diary-title-text">DIARIO DI BORDO & SPEDIZIONE DEL 70° PARALLELO</span>
          </div>
          <button class="modal-close-btn" id="btn-close-diary">✕</button>
        </div>

        <!-- Navigation Tabs -->
        <div class="diary-nav-tabs">
          <button class="diary-tab-btn active" id="tab-diary-chapters">⭐ CAPITOLI & MISSIONI</button>
          <button class="diary-tab-btn" id="tab-diary-radio">📻 ARCHIVIO CB (CH 19)</button>
          <button class="diary-tab-btn" id="tab-diary-notes">📐 TACCUINO DELL'INGEGNERE</button>
        </div>

        <div class="diary-body">
          <!-- TAB 1: CHAPTERS & OBJECTIVES -->
          <div class="diary-tab-pane" id="pane-diary-chapters">
            <div class="diary-two-columns">
              <!-- Left Sidebar: Chapters Timeline List -->
              <div class="chapters-timeline-sidebar" id="chapters-timeline-list"></div>

              <!-- Right Pane: Active Chapter Dossier -->
              <div class="chapter-dossier-panel" id="chapter-dossier-panel"></div>
            </div>
          </div>

          <!-- TAB 2: RADIO TRANSCRIPTS -->
          <div class="diary-tab-pane" id="pane-diary-radio" style="display: none;">
            <div class="radio-log-header">
              <span class="radio-log-title">FREQUENZA EMERGENZA CONVOGLI NORD — 27.185 MHz (CANALE 19)</span>
              <span class="radio-log-count" id="radio-log-count">0 Trasmissioni Salvate</span>
            </div>
            <div class="radio-transcripts-list" id="radio-transcripts-list"></div>
          </div>

          <!-- TAB 3: PAOLO'S TECHNICAL NOTES -->
          <div class="diary-tab-pane" id="pane-diary-notes" style="display: none;">
            <div class="notes-intro-banner">
              <span class="engineer-stamp">APPUNTI DI VIAGGIO • ING. PAOLO</span>
              <p>Osservazioni tecniche su metallurgia sottozero, cicli termici dei motori d'epoca e segreti dei relitti lungo la Dalton Highway.</p>
            </div>
            <div class="engineer-notes-grid" id="engineer-notes-grid"></div>
          </div>
        </div>

        <div class="modal-footer diary-footer">
          <div class="diary-status-motto">HAUL ROAD EXPEDITION LOG • TRANS-ALASKA PIPELINE SYSTEM</div>
          <button class="btn-primary-action" id="btn-close-diary-bottom">TORNA AL COCKPIT</button>
        </div>
      </div>
    `;

    this.container.appendChild(this.element);
    this.bindEvents();
  }

  bindEvents() {
    this.element.querySelector('#btn-close-diary').addEventListener('click', () => this.close());
    this.element.querySelector('#btn-close-diary-bottom').addEventListener('click', () => this.close());

    this.element.querySelector('#tab-diary-chapters').addEventListener('click', () => this.switchTab('chapters'));
    this.element.querySelector('#tab-diary-radio').addEventListener('click', () => this.switchTab('radio'));
    this.element.querySelector('#tab-diary-notes').addEventListener('click', () => this.switchTab('notes'));
  }

  switchTab(tabKey) {
    this.activeTab = tabKey;
    const tabs = ['chapters', 'radio', 'notes'];

    tabs.forEach((t) => {
      const btn = this.element.querySelector(`#tab-diary-${t}`);
      const pane = this.element.querySelector(`#pane-diary-${t}`);
      if (btn) btn.classList.toggle('active', t === tabKey);
      if (pane) pane.style.display = t === tabKey ? 'block' : 'none';
    });

    if (tabKey === 'chapters') this.renderChaptersView();
    if (tabKey === 'radio') this.renderRadioView();
    if (tabKey === 'notes') this.renderNotesView();

    if (this.audioEngine && typeof this.audioEngine.playSwitchClick === 'function') {
      this.audioEngine.playSwitchClick(true);
    }
  }

  open() {
    this.isOpen = true;
    this.element.style.display = 'flex';
    this.selectedChapterIndex = this.storyDirector.activeChapterIndex;
    this.switchTab(this.activeTab);

    if (this.audioEngine && typeof this.audioEngine.playSwitchClick === 'function') {
      this.audioEngine.playSwitchClick(true);
    }
  }

  close() {
    this.isOpen = false;
    this.element.style.display = 'none';

    if (this.audioEngine && typeof this.audioEngine.playSwitchClick === 'function') {
      this.audioEngine.playSwitchClick(false);
    }
  }

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  renderChaptersView() {
    const list = this.element.querySelector('#chapters-timeline-list');
    list.innerHTML = '';

    const chapters = this.storyDirector.chapters;
    const activeIdx = this.storyDirector.activeChapterIndex;

    chapters.forEach((ch, idx) => {
      const isCompleted = this.storyDirector.completedChapters.has(ch.id);
      const isCurrent = idx === activeIdx;
      const isLocked = idx > activeIdx;
      const isSelected = idx === this.selectedChapterIndex;

      let statusBadge = '<span class="ch-badge locked">BLOCCATO</span>';
      if (isCompleted) {
        statusBadge = '<span class="ch-badge completed">COMPLETATO ✓</span>';
      } else if (isCurrent) {
        statusBadge = '<span class="ch-badge current">IN CORSO ⚡</span>';
      }

      const item = document.createElement('div');
      item.className = `chapter-sidebar-item ${isSelected ? 'selected' : ''} ${isLocked ? 'locked' : ''}`;
      item.innerHTML = `
        <div class="ch-sidebar-num">CAPITOLO ${ch.number}</div>
        <div class="ch-sidebar-title">${ch.bannerIcon} ${ch.title}</div>
        <div class="ch-sidebar-status">${statusBadge}</div>
      `;

      item.addEventListener('click', () => {
        this.selectedChapterIndex = idx;
        this.renderChaptersView();
      });

      list.appendChild(item);
    });

    this.renderChapterDetail(this.selectedChapterIndex);
  }

  renderChapterDetail(chapterIdx) {
    const panel = this.element.querySelector('#chapter-dossier-panel');
    const ch = this.storyDirector.chapters[chapterIdx];
    if (!ch) return;

    const isCompleted = this.storyDirector.completedChapters.has(ch.id);
    const isCurrent = chapterIdx === this.storyDirector.activeChapterIndex;
    const isLocked = chapterIdx > this.storyDirector.activeChapterIndex;
    const isClaimed = this.storyDirector.claimedRewards.has(ch.id);

    // Build objectives markup
    let objectivesMarkup = '';
    ch.objectives.forEach((obj) => {
      const isDone = this.storyDirector.completedObjectives.has(obj.id);
      objectivesMarkup += `
        <div class="obj-checklist-item ${isDone ? 'done' : ''}">
          <div class="obj-check-box">${isDone ? '✓' : '○'}</div>
          <div class="obj-info">
            <div class="obj-text">${obj.text}</div>
            <div class="obj-status-sub">${isDone ? '<span class="text-success">RAGGIUNTO</span>' : '<span class="text-pending">IN ATTESA</span>'}</div>
          </div>
        </div>
      `;
    });

    // Build reward button
    let rewardBtnMarkup = '';
    if (isCompleted) {
      if (isClaimed) {
        rewardBtnMarkup = `<button class="btn-reward-claimed" disabled>RICOMPENSA GIÀ RISCOSSA ✓</button>`;
      } else {
        rewardBtnMarkup = `<button class="btn-claim-rewards" id="btn-claim-${ch.id}">RISCUOTI RICOMPENSA SPEDIZIONE 🎁</button>`;
      }
    } else {
      rewardBtnMarkup = `<div class="reward-locked-note">Completa tutti gli obiettivi per sbloccare le scorte e i potenziamenti.</div>`;
    }

    panel.innerHTML = `
      <div class="chapter-dossier-header">
        <div class="dossier-tag-row">
          <span class="dossier-ch-badge">CAPITOLO ${ch.number}</span>
          <span class="dossier-status-pill ${isCompleted ? 'completed' : isCurrent ? 'current' : 'locked'}">
            ${isCompleted ? 'COMPLETATO' : isCurrent ? 'ATTIVO SULLA DALTON' : 'NON ANCORA RAGGIUNTO'}
          </span>
        </div>
        <h2 class="dossier-ch-title">${ch.bannerIcon} ${ch.title}</h2>
        <div class="dossier-ch-subtitle">${ch.subtitle}</div>
      </div>

      <div class="dossier-briefing-box">
        <div class="briefing-speaker-header">
          <span class="speaker-avatar">${ch.speakerAvatar}</span>
          <span class="speaker-name">${ch.speaker}</span>
          <span class="speaker-freq">[ CB CH 19 • 27.185 MHz ]</span>
        </div>
        <p class="briefing-body-text">"${ch.briefing}"</p>
      </div>

      <div class="dossier-section-title">OBIETTIVI TATTICI DELLA TAPPA</div>
      <div class="dossier-objectives-list">
        ${objectivesMarkup}
      </div>

      <div class="dossier-rewards-card">
        <div class="rewards-card-header">
          <span class="rewards-icon">📦</span>
          <div class="rewards-title-box">
            <strong>RICOMPENSE STRATEGICHE</strong>
            <span>${ch.rewards.description}</span>
          </div>
        </div>
        ${ch.rewards.unlockVehicleHint ? `<div class="vehicle-unlock-hint">🏎️ <strong>INFORMAZIONE VEICOLO:</strong> ${ch.rewards.unlockVehicleHint}</div>` : ''}
        <div class="rewards-action-row">
          ${rewardBtnMarkup}
        </div>
      </div>
    `;

    // Bind claim button if present
    const claimBtn = panel.querySelector(`#btn-claim-${ch.id}`);
    if (claimBtn) {
      claimBtn.addEventListener('click', () => {
        const res = this.storyDirector.claimChapterRewards(ch.id);
        if (res.success) {
          alert(`🏆 ${res.message}`);
          this.renderChaptersView();
        } else {
          alert(res.reason);
        }
      });
    }
  }

  renderRadioView() {
    const list = this.element.querySelector('#radio-transcripts-list');
    const count = this.element.querySelector('#radio-log-count');
    list.innerHTML = '';

    const dispatches = this.storyDirector.receivedDispatches || [];
    count.textContent = `${dispatches.length} Trasmissioni Registrate`;

    if (dispatches.length === 0) {
      list.innerHTML = `
        <div class="empty-radio-box">
          <div class="empty-icon">📻</div>
          <div class="empty-text">Nessuna trasmissione ricevuta. Accendi il motore e mettiti in marcia lungo la Dalton per captare i segnali sul Canale 19!</div>
        </div>
      `;
      return;
    }

    // Render in reverse chronological order
    dispatches.slice().reverse().forEach((tx) => {
      const card = document.createElement('div');
      card.className = 'radio-transcript-card';
      card.innerHTML = `
        <div class="transcript-header">
          <div class="tx-speaker-badge">
            <span class="tx-avatar">${tx.avatar || '📻'}</span>
            <strong>${tx.speaker}</strong>
          </div>
          <div class="tx-meta-info">
            <span class="tx-callsign">${tx.callsign}</span>
            <span class="tx-pk">PK ${(tx.receivedAtZ / 1000).toFixed(1)} KM</span>
            <span class="tx-time">${tx.timestamp || '--:--'}</span>
          </div>
        </div>
        <div class="transcript-content">
          <p>"${tx.text}"</p>
        </div>
      `;
      list.appendChild(card);
    });
  }

  renderNotesView() {
    const grid = this.element.querySelector('#engineer-notes-grid');
    grid.innerHTML = '';

    const notes = this.storyDirector.engineerNotes || [];
    notes.forEach((n) => {
      const card = document.createElement('div');
      card.className = 'engineer-note-card';
      card.innerHTML = `
        <div class="note-cat-badge">${n.category}</div>
        <h3 class="note-title">${n.title}</h3>
        <p class="note-text">${n.text}</p>
      `;
      grid.appendChild(card);
    });
  }
}
