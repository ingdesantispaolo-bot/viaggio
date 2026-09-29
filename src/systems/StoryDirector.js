/**
 * THE LONG MERIDIAN - Story Director & Narrative Campaign System
 * Coordinates the 6-chapter arctic expedition, CB radio dispatches, real-time objectives,
 * narrative milestones and vehicle unlock secrets along the Dalton Highway.
 */

export class StoryDirector {
  constructor(vehicle, survivalState, inventorySystem, audioEngine, poiManager = null) {
    this.vehicle = vehicle;
    this.survivalState = survivalState;
    this.inventorySystem = inventorySystem;
    this.audioEngine = audioEngine;
    this.poiManager = poiManager;

    this.activeChapterIndex = 0;
    this.completedChapters = new Set();
    this.completedObjectives = new Set();
    this.claimedRewards = new Set();
    this.receivedDispatches = [];
    this.activeRadioDispatch = null;
    this.radioDispatchTimer = 0;

    // Callbacks for UI updates
    this.onRadioDispatch = null;
    this.onObjectiveUpdate = null;
    this.onObjectiveCompleted = null;
    this.onChapterCompleted = null;

    this.initCampaign();
    this.loadProgress();

    // Trigger opening transmission shortly after start
    setTimeout(() => {
      this.triggerInitialTransmission();
    }, 2500);
  }

  initCampaign() {
    this.chapters = [
      {
        id: 'ch_1',
        index: 0,
        number: 'I',
        title: 'La Partenza da Fox & La Valle Dorata',
        subtitle: 'Battesimo del Freddo nel Distretto Minerario [PK 0.0 - 0.65 KM]',
        bannerIcon: '⛏️',
        speaker: 'JACK MILLER "ORSO POLARE"',
        speakerAvatar: '🐻',
        briefing: `Paolo, qui parla Orso Polare sul Canale 19. Il terminale petrolifero e scientifico di Deadhorse (70° Parallelo) è rimasto al buio per un blackout catastrofico. Nessun camion moderno con centraline elettroniche riesce a partire: l'impulso magnetico ha bruciato i semiconduttori. Tu hai una Fiat Panda 4x4 Steyr-Puch con motore aste e bilancieri: completamente analogica e leggera. Raccogli scorte a Fox e muoviti verso nord prima che la notte artica congeli il corridoio!`,
        targetPK: 650,
        rewards: {
          scrap: 35,
          items: [{ id: 'refined_fuel', count: 1 }, { id: 'first_aid_bandage', count: 2 }],
          description: '35 Rottami • 1x Tanica Gasolio 20L • 2x Bende Mediche'
        },
        objectives: [
          {
            id: 'ch1_obj_drive',
            text: 'Mettiti in marcia e supera i primi 200 metri della Dalton Highway',
            type: 'distance',
            target: 200,
            unit: 'M',
            check: (ctx) => ctx.z >= 200
          },
          {
            id: 'ch1_obj_visit_fox',
            text: 'Raggiungi Fox Junction (PK 0.22 km) e ispeziona l\'insediamento minerario',
            type: 'visit_settlement',
            targetKey: 'fox_junction',
            targetPK: 220,
            check: (ctx) => ctx.z >= 220 || ctx.visitedSettlements.has('fox_junction')
          },
          {
            id: 'ch1_obj_scrap',
            text: 'Raccogli o baratta almeno 15 unità di rottami per rinforzi d\'emergenza',
            type: 'scrap',
            target: 15,
            check: (ctx) => ctx.inventoryScrap >= 15
          },
          {
            id: 'ch1_obj_reach_end',
            text: 'Supera il PK 0.60 km mantenendo lo scafo della Panda sopra il 70%',
            type: 'distance_hull',
            target: 600,
            check: (ctx) => ctx.z >= 600 && ctx.hullPercent >= 70
          }
        ]
      },

      {
        id: 'ch_2',
        index: 1,
        number: 'II',
        title: 'Il Gigante d\'Acciaio dello Yukon',
        subtitle: 'Il Ponte E.L. Patton & La Pump Station 6 [PK 0.65 - 1.4 KM]',
        bannerIcon: '🌲',
        speaker: 'MASTRO JAREK (MECCANICO CAPO)',
        speakerAvatar: '🔧',
        briefing: `Ingegnere Paolo! Ti sento gracchiante sul CB. Sono Jarek, vecchio meccanico polacco della Pump Station 6 sul fiume Yukon. Il ponte è ancora in piedi ma la foresta di picea nera sta cedendo per il disgelo dei versanti. La stazione ha bisogno di componenti per le valvole dell'oleodotto. Se mi porti rottami e pezzi di ricambio, ti consegno le coordinate di un vecchio granaio dove riposa una perla italiana: un'Alfa Giulia Super 1.6 Twin Cam abbandonata!`,
        targetPK: 1400,
        rewards: {
          scrap: 60,
          items: [{ id: 'toolkit', count: 1 }, { id: 'cured_timber', count: 2 }],
          unlockVehicleHint: 'Alfa Romeo Giulia Super (Coordinate Granaio Yukon)',
          description: '60 Rottami • 1x Cassetta Attrezzi Completa • Indizio Relitto Alfa Giulia'
        },
        objectives: [
          {
            id: 'ch2_obj_cross_bridge',
            text: 'Attraversa l\'imponente ponte d\'acciaio E.L. Patton sul fiume Yukon (PK 0.87 km)',
            type: 'distance',
            target: 870,
            unit: 'M',
            check: (ctx) => ctx.z >= 870
          },
          {
            id: 'ch2_obj_visit_yukon',
            text: 'Fermati alla Pump Station 6 dello Yukon e contatta Mastro Jarek',
            type: 'visit_settlement',
            targetKey: 'yukon_crossing',
            targetPK: 870,
            check: (ctx) => ctx.z >= 870 || ctx.visitedSettlements.has('yukon_crossing')
          },
          {
            id: 'ch2_obj_scavenge_lumber',
            text: 'Ispeziona il piazzale dei boscaioli (PK 1.04 km) per recuperare mastice e legname',
            type: 'distance',
            target: 1040,
            check: (ctx) => ctx.z >= 1040
          },
          {
            id: 'ch2_obj_reach_1300',
            text: 'Avanza oltre il PK 1.35 km penetrando nella taiga dello Yukon',
            type: 'distance',
            target: 1350,
            check: (ctx) => ctx.z >= 1350
          }
        ]
      },

      {
        id: 'ch_3',
        index: 2,
        number: 'III',
        title: 'Il Pantano di Coldfoot & i Piedi Freddi',
        subtitle: 'La Fossa Alluvionale del Muskeg & Slate Creek [PK 1.4 - 2.1 KM]',
        bannerIcon: '🌧️',
        speaker: 'JACK MILLER "ORSO POLARE"',
        speakerAvatar: '🐻',
        briefing: `Attenzione a tutte le unità lungo il corridoio: le piane del fiume Koyukuk sono una trappola mortale. Il fango muskeg scioglie le banchine. Se corri sopra i 35 all'ora fuori asfalto spacchi il telaio per lo spanciamento! A Coldfoot Truck Stop un convoglio Mack si è impantanato. Portagli aiuto e fai scorta di carburante e pneumatici tassellati prima che il freddo si trasformi in gelo polare.`,
        targetPK: 2100,
        rewards: {
          scrap: 80,
          items: [{ id: 'spare_tire', count: 1 }, { id: 'waterproofing_wax', count: 2 }],
          unlockVehicleHint: 'Peugeot 504 Dangel 4x4 (Disponibile nel Parco Veicoli)',
          description: '80 Rottami • 1x Pneumatico M+S Rinforzato • 2x Cera Impermeabilizzante'
        },
        objectives: [
          {
            id: 'ch3_obj_reach_coldfoot',
            text: 'Raggiungi il celebre Coldfoot Truck Stop a Slate Creek (PK 1.52 km)',
            type: 'visit_settlement',
            targetKey: 'coldfoot_camp',
            targetPK: 1520,
            check: (ctx) => ctx.z >= 1520 || ctx.visitedSettlements.has('coldfoot_camp')
          },
          {
            id: 'ch3_obj_inspect_overturned',
            text: 'Individua l\'autocisterna Mack semi-affondata nel fango a PK 1.82 km',
            type: 'distance',
            target: 1820,
            check: (ctx) => ctx.z >= 1820
          },
          {
            id: 'ch3_obj_fuel_reserve',
            text: 'Assicurati di avere almeno 25 litri di carburante per la salita del Circolo Polare',
            type: 'fuel',
            target: 25,
            check: (ctx) => ctx.fuelLevel >= 25
          },
          {
            id: 'ch3_obj_reach_2050',
            text: 'Valica le piane alluvionali di Koyukuk e tocca il PK 2.05 km',
            type: 'distance',
            target: 2050,
            check: (ctx) => ctx.z >= 2050
          }
        ]
      },

      {
        id: 'ch_4',
        index: 3,
        number: 'IV',
        title: 'L\'Orizzonte Ionico del 66° Parallelo',
        subtitle: 'La Base Radar DEW Line White Alice & Circolo Polare [PK 2.1 - 2.8 KM]',
        bannerIcon: '📡',
        speaker: 'ELENA VANCE (SCIENZIATA DEADHORSE)',
        speakerAvatar: '👩‍🔬',
        briefing: `...crk... Paolo! Ricevo il segnale CB del tuo Alan 48! Qui è Elena Vance dal terminale di Prudhoe Bay. Le aurore solari hanno innescato una tempesta ionica micidiale. Gli alternatori rischiano il sovraccarico e le luci ballano. A Chandalar Shelf (PK 2.17 km) c'è la vecchia parabola troposferica White Alice della Guerra Fredda: riallinea i ripetitori per consentirci di guidarti attraverso il valico montuoso!`,
        targetPK: 2800,
        rewards: {
          scrap: 110,
          items: [{ id: 'graphene_battery', count: 1 }, { id: 'electronics', count: 2 }],
          unlockVehicleHint: 'BMW Serie 3 E30 Rally Spec (Relitto Altopiano)',
          description: '110 Rottami • 1x Batteria al Grafene • 2x Componenti Elettronici Schermati'
        },
        objectives: [
          {
            id: 'ch4_obj_arctic_circle',
            text: 'Vapora il Cancello del Circolo Polare Artico (Latitudine 66° 33\' N, PK 2.17 km)',
            type: 'distance',
            target: 2170,
            check: (ctx) => ctx.z >= 2170
          },
          {
            id: 'ch4_obj_dew_line',
            text: 'Raggiungi la gigantesca Parabola Radar White Alice di Chandalar Shelf (PK 2.32 km)',
            type: 'distance',
            target: 2320,
            check: (ctx) => ctx.z >= 2320
          },
          {
            id: 'ch4_obj_trooper_gate',
            text: 'Supera il posto di blocco Alaska State Troopers del Parallelo 66° (PK 2.48 km)',
            type: 'distance',
            target: 2480,
            check: (ctx) => ctx.z >= 2480
          },
          {
            id: 'ch4_obj_reach_2750',
            text: 'Sopravvivi alle tempeste ioniche e raggiungi i piedi delle montagne Brooks (PK 2.75 km)',
            type: 'distance',
            target: 2750,
            check: (ctx) => ctx.z >= 2750
          }
        ]
      },

      {
        id: 'ch_5',
        index: 4,
        number: 'V',
        title: 'Il Calvario dell\'Atigun Pass (The Shelf)',
        subtitle: '1.444 Metri sul Continental Divide & Falesie di Ardesia [PK 2.8 - 3.4 KM]',
        bannerIcon: '⛰️',
        speaker: 'JACK MILLER "ORSO POLARE"',
        speakerAvatar: '🐻',
        briefing: `Paolo, stai per affrontare 'The Shelf', il passo più alto e feroce dell'Alaska. 12% di pendenza continua, ardesia affilata come rasoi e raffiche a 140 km/h. Se il radiatore sale a 110 gradi fondi la testata prima del tornante. Inserisci la trazione integrale o la marcia corta, evita i massi caduti dalla parete e non fermarti mai sulla pendenza o scivolerai a valle!`,
        targetPK: 3400,
        rewards: {
          scrap: 150,
          items: [{ id: 'reinforced_coil', count: 1 }, { id: 'armor_plate', count: 2 }],
          unlockVehicleHint: 'Land Rover Defender 110 Tdi (Veicolo del Soccorso Alpino DOT)',
          description: '150 Rottami • 1x Balestra da Carico Pesante • 2x Piastre Blindate'
        },
        objectives: [
          {
            id: 'ch5_obj_reach_atigun_camp',
            text: 'Conquista l\'Atigun Pass High Camp incastonato nelle falesie scistose (PK 2.82 km)',
            type: 'visit_settlement',
            targetKey: 'atigun_camp',
            targetPK: 2820,
            check: (ctx) => ctx.z >= 2820 || ctx.visitedSettlements.has('atigun_camp')
          },
          {
            id: 'ch5_obj_inspect_quarry',
            text: 'Oltrepassa la cava frantumatori di ardesia DOT sul valico (PK 2.96 km)',
            type: 'distance',
            target: 2960,
            check: (ctx) => ctx.z >= 2960
          },
          {
            id: 'ch5_obj_climb_summit',
            text: 'Supera il punto più alto del Continental Divide (1.444m, PK 3.12 km) senza distruggere lo scafo',
            type: 'distance_hull',
            target: 3120,
            check: (ctx) => ctx.z >= 3120 && ctx.hullPercent >= 45
          },
          {
            id: 'ch5_obj_reach_3350',
            text: 'Scendi lungo il versante nord del valico toccando quota PK 3.35 km',
            type: 'distance',
            target: 3350,
            check: (ctx) => ctx.z >= 3350
          }
        ]
      },

      {
        id: 'ch_6',
        index: 5,
        number: 'VI',
        title: 'L\'Ultima Corsa sul Mare di Beaufort',
        subtitle: 'Prudhoe Bay, Ghiaccio Nero a -45°C & Vittoria Polare [PK 3.4 - 3.8+ KM]',
        bannerIcon: '❄️',
        speaker: 'ELENA VANCE & L\'INTERO CONVOGLIO',
        speakerAvatar: '🏆',
        briefing: `Paolo! Sei sbucato dalle montagne Brooks! Ti vediamo dai binocoli della torre di Deadhorse! Il termometro segna -46°C e la bufera di neve ha coperto la strada di ghiaccio vivo. Non spegnere il motore per nessun motivo, altrimenti l'olio diventa catrame solido in tre minuti! Porta la macchina all'hangar centrale di Deadhorse: sei a un passo dalla leggenda della Haul Road!`,
        targetPK: 3800,
        rewards: {
          scrap: 250,
          items: [{ id: 'cryo_coolant', count: 2 }, { id: 'thermal_lining', count: 2 }],
          unlockVehicleHint: 'Lancia Delta HF Integrale Evoluzione (Campione del Mondo Rally)',
          description: '250 Rottami • 2x Glicole Criogenico • SBLOCCO SUPREMO LANCIA DELTA INTEGRALE'
        },
        objectives: [
          {
            id: 'ch6_obj_reach_deadhorse',
            text: 'Raggiungi il monumentale Deadhorse Terminal sulle sponde dell\'Oceano Artico (PK 3.47 km)',
            type: 'visit_settlement',
            targetKey: 'deadhorse_terminal',
            targetPK: 3470,
            check: (ctx) => ctx.z >= 3470 || ctx.visitedSettlements.has('deadhorse_terminal')
          },
          {
            id: 'ch6_obj_polar_shelter',
            text: 'Oltrepassa la capsula rifugio spazzaneve Arctic Cat a PK 3.62 km',
            type: 'distance',
            target: 3620,
            check: (ctx) => ctx.z >= 3620
          },
          {
            id: 'ch6_obj_radio_lighthouse',
            text: 'Taglia il traguardo al Faro Radio Terminale del Mar Glaciale Artico (PK 3.78 km)',
            type: 'distance',
            target: 3780,
            check: (ctx) => ctx.z >= 3780
          },
          {
            id: 'ch6_obj_complete_expedition',
            text: 'Consegna la spedizione artica e conquista il titolo supremo di Leggenda della Dalton!',
            type: 'victory',
            check: (ctx) => ctx.z >= 3800
          }
        ]
      }
    ];

    // Predefined Radio Dispatches Scripted along the Highway
    this.scriptedTransmissions = [
      {
        id: 'tx_intro',
        triggerZ: 15,
        speaker: 'JACK MILLER "ORSO POLARE"',
        avatar: '🐻',
        callsign: 'CH 19 • DALTON CONVOY DISPATCH',
        text: 'Attenzione a tutte le unità, qui è Orso Polare sul Canale 19. Paolo, mi ricevi? Il convoglio per Prudhoe Bay conta su di te. Tieni gli occhi sulla temperatura dell\'acqua e non farti ingannare dalla banchina: a nord di Fox la strada non ha pietà!'
      },
      {
        id: 'tx_fox_arrival',
        triggerZ: 215,
        speaker: 'SERAFINO (CAPO MINATORE FOX)',
        avatar: '⛏️',
        callsign: 'CH 19 • FOX JUNCTION MINERS',
        text: 'Ehi, la Panda 4x4 d\'epoca! Sentivo il rombo del 4 cilindri da chilometri. Se ti servono gasolio o rottami d\'acciaio scendi pure all\'officina di Dredge 8. Fai il pieno prima del fiume!'
      },
      {
        id: 'tx_yukon_approach',
        triggerZ: 820,
        speaker: 'MASTRO JAREK (PUMP STATION 6)',
        avatar: '🔧',
        callsign: 'CH 19 • YUKON RIVER CAMP',
        text: 'Paolo! Eccoti sul ponte E.L. Patton! Guarda che colosso di travi d\'acciaio sopra lo Yukon. Vieni alla Pump Station 6, ti ho messo da parte una chiave a cricchetto e la mappa per un relitto Alfa Romeo!'
      },
      {
        id: 'tx_coldfoot_warning',
        triggerZ: 1450,
        speaker: 'JACK MILLER "ORSO POLARE"',
        avatar: '🐻',
        callsign: 'CH 19 • DALTON CONVOY DISPATCH',
        text: 'Ingegnere, sei entrato nelle piane del Koyukuk! Qui è dove i cercatori si presero i piedi freddi ("cold feet") nel 1898. Fango viscoso a destra e sinistra: mantieni il volante dritto e non frenare di colpo!'
      },
      {
        id: 'tx_arctic_circle',
        triggerZ: 2160,
        speaker: 'SGT. O\'CONNOR (ALASKA TROOPERS)',
        avatar: '🛡️',
        callsign: 'CH 19 • ARCTIC CIRCLE CHECKPOINT',
        text: 'Unità in transito, benvenuto nel Circolo Polare Artico (66° 33\' Nord). Da qui in avanti le tempeste ioniche azzerano i cellulari. Affidati solo all\'ago della bussola e al CB!'
      },
      {
        id: 'tx_atigun_alert',
        triggerZ: 2790,
        speaker: 'ELENA VANCE (DEADHORSE TERMINAL)',
        avatar: '👩‍🔬',
        callsign: 'CH 19 • POLAR SCIENCE POST',
        text: 'Paolo... le nostre sonde registrano venti da 120 km/h sull\'Atigun Pass! Il valico è ghiacciato. Se hai la primina inserita usala, e tieni d\'occhio l\'indicatore della temperatura!'
      },
      {
        id: 'tx_victory_deadhorse',
        triggerZ: 3750,
        speaker: 'ELENA VANCE & JACK MILLER',
        avatar: '🏆',
        callsign: 'CH 19 • BEAUFORT SEA FLEET',
        text: 'CE L\'HAI FATTA! La Fiat Panda 4x4 ha battuto la Dalton Highway! I generatori di Prudhoe Bay sono salvi! Hai scritto la storia della Haul Road, Ingegnere!'
      }
    ];

    // Paolo's Technical Notes
    this.engineerNotes = [
      {
        title: 'La Primina della Fiat Panda 4x4 Steyr-Puch',
        category: 'MECCANICA D\'EPOCA',
        text: 'Sviluppata a Graz dalla Steyr-Daimler-Puch nel 1983. Non ha un riduttore a due leve come i fuoristrada pesanti, bensì una prima marcia ultra-corta (rapporto 1:3.91) abbinata a un differenziale conico elicoidale. Sul fango muskeg e sulla neve profonda della Dalton, consente di arrampicarsi a 4 km/h senza bruciare la frizione. Un capolavoro di essenzialità.'
      },
      {
        title: 'Comportamento Termico dell\'Asfalto & Verglas',
        category: 'FISICA STRADALE',
        text: 'Tra il Milepost 56 e il 175 il fondo stradale passa da bitume fessurato a ghiaia mista a cloruro di calcio. A temperature inferiori a -4°C l\'umidità della taiga condensa istantaneamente creando il temibile ghiaccio nero ("black ice"). Il coefficiente di aderenza scende da 0.95 a 0.35. Toccare il pedale del freno con le ruote curvate significa testacoda assicurato.'
      },
      {
        title: 'Il Segreto dell\'Alfa Romeo Giulia Super nella Taiga',
        category: 'RELITTI NASCOSTI',
        text: 'Mastro Jarek mi ha confidato che un geologo italiano della TAPS negli anni \'70 importò una Giulia Super 1.6 Biscione per percorrere i cantieri dello Yukon. Il motore bialbero a due carburatori doppio corpo Weber 40 DCOE necessita di riscaldare bene i condotti d\'aspirazione per non congelare i getti del minimo.'
      },
      {
        title: 'La Battaglia per il Passo Atigun (1.444 Metri)',
        category: 'STRATEGIA DI VALICO',
        text: 'Il Continental Divide separa i bacini idrografici del Pacifico da quelli dell\'Oceano Artico. La salita dal versante sud presenta strapiombi senza guardrail. Il trucco dell\'ingegnere: dosare l\'acceleratore al 60% per evitare slittamenti e non far salire il manometro della temperatura olio oltre i 3.8 bar.'
      }
    ];
  }

  loadProgress() {
    try {
      const saved = localStorage.getItem('meridian_story_save');
      if (saved) {
        const data = JSON.parse(saved);
        if (typeof data.activeChapterIndex === 'number') this.activeChapterIndex = data.activeChapterIndex;
        if (Array.isArray(data.completedChapters)) this.completedChapters = new Set(data.completedChapters);
        if (Array.isArray(data.completedObjectives)) this.completedObjectives = new Set(data.completedObjectives);
        if (Array.isArray(data.claimedRewards)) this.claimedRewards = new Set(data.claimedRewards);
      }
    } catch (e) {
      console.warn('Impossibile caricare salvataggio storia:', e);
    }
  }

  saveProgress() {
    try {
      const data = {
        activeChapterIndex: this.activeChapterIndex,
        completedChapters: Array.from(this.completedChapters),
        completedObjectives: Array.from(this.completedObjectives),
        claimedRewards: Array.from(this.claimedRewards)
      };
      localStorage.setItem('meridian_story_save', JSON.stringify(data));
    } catch (e) {
      console.warn('Errore salvataggio progresso storia:', e);
    }
  }

  triggerInitialTransmission() {
    if (this.receivedDispatches.length === 0) {
      const intro = this.scriptedTransmissions.find((t) => t.id === 'tx_intro');
      if (intro) this.dispatchRadioMessage(intro);
    }
  }

  getActiveChapter() {
    return this.chapters[this.activeChapterIndex] || this.chapters[this.chapters.length - 1];
  }

  getActiveObjective() {
    const ch = this.getActiveChapter();
    if (!ch) return null;
    return ch.objectives.find((obj) => !this.completedObjectives.has(obj.id)) || ch.objectives[ch.objectives.length - 1];
  }

  update(delta) {
    if (!this.vehicle) return;

    const z = this.vehicle.position ? this.vehicle.position.z : 0;
    const speedKmh = Math.abs(this.vehicle.speed || 0) * 3.6;
    const fuelLevel = this.survivalState ? this.survivalState.fuel : 30;
    const hullPercent = this.survivalState ? this.survivalState.hull : 100;
    const inventoryScrap = this.inventorySystem ? this.inventorySystem.scrapMetal : 0;

    // Build context for checks
    const context = {
      z: z,
      speedKmh: speedKmh,
      fuelLevel: fuelLevel,
      hullPercent: hullPercent,
      inventoryScrap: inventoryScrap,
      visitedSettlements: this.poiManager ? this.poiManager.visitedSettlements || new Set() : new Set(),
      activeVehicleId: this.vehicle.currentModelId || 'panda_4x4'
    };

    // 1. Check scripted radio triggers based on Z
    this.checkRadioTriggers(z);

    // 2. Check active chapter objectives
    const chapter = this.getActiveChapter();
    if (chapter) {
      let allCompleted = true;

      chapter.objectives.forEach((obj) => {
        if (!this.completedObjectives.has(obj.id)) {
          if (obj.check && obj.check(context)) {
            this.completeObjective(obj, chapter);
          } else {
            allCompleted = false;
          }
        }
      });

      if (allCompleted && !this.completedChapters.has(chapter.id)) {
        this.completeChapter(chapter);
      }
    }

    // 3. Handle active radio message display timer
    if (this.activeRadioDispatch) {
      this.radioDispatchTimer -= delta;
      if (this.radioDispatchTimer <= 0) {
        this.dismissRadioMessage();
      }
    }
  }

  checkRadioTriggers(z) {
    for (const tx of this.scriptedTransmissions) {
      if (z >= tx.triggerZ && !this.receivedDispatches.some((d) => d.id === tx.id)) {
        this.dispatchRadioMessage(tx);
        break;
      }
    }
  }

  dispatchRadioMessage(tx) {
    this.receivedDispatches.push({
      ...tx,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      receivedAtZ: Math.round(this.vehicle ? this.vehicle.position.z : 0)
    });

    this.activeRadioDispatch = tx;
    this.radioDispatchTimer = 9.0; // 9 seconds visible

    // Play authentic CB audio squelch & roger-beep
    if (this.audioEngine && typeof this.audioEngine.playRadioStatic === 'function') {
      this.audioEngine.playRadioStatic();
    }

    if (typeof this.onRadioDispatch === 'function') {
      this.onRadioDispatch(tx);
    }
  }

  dismissRadioMessage() {
    this.activeRadioDispatch = null;
    this.radioDispatchTimer = 0;
    if (typeof this.onRadioDispatch === 'function') {
      this.onRadioDispatch(null);
    }
  }

  completeObjective(obj, chapter) {
    if (this.completedObjectives.has(obj.id)) return;
    this.completedObjectives.add(obj.id);
    this.saveProgress();

    // Play celebratory ding
    if (this.audioEngine && typeof this.audioEngine.playObjectiveDing === 'function') {
      this.audioEngine.playObjectiveDing();
    }

    if (typeof this.onObjectiveCompleted === 'function') {
      this.onObjectiveCompleted(obj, chapter);
    }
  }

  completeChapter(chapter) {
    if (this.completedChapters.has(chapter.id)) return;
    this.completedChapters.add(chapter.id);

    // Auto-advance active chapter if there's a next one
    if (this.activeChapterIndex < this.chapters.length - 1) {
      this.activeChapterIndex += 1;
    }
    this.saveProgress();

    // Play triumphant chapter victory fanfare!
    if (this.audioEngine && typeof this.audioEngine.playMissionSuccess === 'function') {
      this.audioEngine.playMissionSuccess();
    }

    if (typeof this.onChapterCompleted === 'function') {
      this.onChapterCompleted(chapter);
    }
  }

  claimChapterRewards(chapterId) {
    if (this.claimedRewards.has(chapterId)) return { success: false, reason: 'Ricompensa già riscossa.' };
    const chapter = this.chapters.find((c) => c.id === chapterId);
    if (!chapter) return { success: false, reason: 'Capitolo inesistente.' };
    if (!this.completedChapters.has(chapterId)) return { success: false, reason: 'Capitolo non ancora completato.' };

    this.claimedRewards.add(chapterId);

    // Give scrap
    if (chapter.rewards.scrap && this.inventorySystem) {
      this.inventorySystem.scrapMetal += chapter.rewards.scrap;
    }

    // Give items
    if (Array.isArray(chapter.rewards.items) && this.inventorySystem) {
      chapter.rewards.items.forEach((it) => {
        this.inventorySystem.addItem(it.id, it.count || 1);
      });
    }

    this.saveProgress();

    if (this.audioEngine && typeof this.audioEngine.playMissionSuccess === 'function') {
      this.audioEngine.playMissionSuccess();
    }

    return {
      success: true,
      message: `Hai riscosso: +${chapter.rewards.scrap} Rottami e scorte strategiche!`,
      rewards: chapter.rewards
    };
  }
}
