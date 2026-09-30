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
    this.maxDispatchDuration = 24.0;
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
        title: 'Le Coste del Mediterraneo & Il Porto di San Vito',
        subtitle: 'L\'Avvio della Spedizione Trans-Continentale [PK 0.0 - 0.65 KM]',
        bannerIcon: '🌊',
        speaker: 'SOFIA MARETTI (CAPO SPEDIZIONE)',
        speakerAvatar: '🧭',
        briefing: `Ingegnere Paolo, qui parla Sofia Maretti sul Canale 19. Il blackout satellitare globale ha spento le centraline elettroniche in tutto il mondo: solo i veicoli a cinematica analogica possono viaggiare. La tua Fiat Panda 4x4 Steyr-Puch con motore ad aste e bilancieri è pronta sul molo di San Vito. Fai scorte d'olio, calibra i carburatori Weber e mettiti in marcia verso nord lungo le scogliere prima che cali la nebbia marina!`,
        targetPK: 650,
        rewards: {
          scrap: 35,
          items: [{ id: 'refined_fuel', count: 1 }, { id: 'first_aid_bandage', count: 2 }],
          description: '35 Rottami • 1x Tanica Benzina 20L • 2x Bende Mediche'
        },
        objectives: [
          {
            id: 'ch1_obj_drive',
            text: 'Mettiti in marcia e percorri i primi 200 metri lungo la costiera',
            type: 'distance',
            target: 200,
            unit: 'M',
            check: (ctx) => ctx.z >= 200
          },
          {
            id: 'ch1_obj_visit_san_vito',
            text: 'Raggiungi il Porto di San Vito (PK 0.22 km) e fai scorta al villaggio marinaro',
            type: 'visit_settlement',
            targetKey: 'san_vito_harbor',
            targetPK: 220,
            check: (ctx) => ctx.z >= 220 || ctx.visitedSettlements.has('san_vito_harbor') || ctx.visitedSettlements.has('fox_junction')
          },
          {
            id: 'ch1_obj_scrap',
            text: 'Raccogli o baratta almeno 15 unità di rottami metallici per i rinforzi',
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
        title: 'Il Cuore Verde della Foresta Temperata & Il Mulino di Valbruna',
        subtitle: 'Radici Umide, Querce Secolari & Il Bialbero Italiano [PK 0.65 - 1.30 KM]',
        bannerIcon: '🌲',
        speaker: 'MASTRO JAREK (MECCANICO DEL MULINO)',
        speakerAvatar: '🔧',
        briefing: `Paolo! Ti ricevo forte e chiaro sul CB Midland Alan 48! Sono Jarek, vecchio meccanico del mulino idraulico di Valbruna. Il fondo nel bosco di faggi è morbido e scivoloso. Se mi porti rottami per riparare la turbina idraulica, ti mostrerò il fienile dove riposa una regina del Biscione: un'Alfa Romeo Giulia Super 1.6 Twin Cam pronta per tornare a ruggire!`,
        targetPK: 1300,
        rewards: {
          scrap: 60,
          items: [{ id: 'toolkit', count: 1 }, { id: 'cured_timber', count: 2 }],
          unlockVehicleHint: 'Alfa Romeo Giulia Super (Coordinate Fienile di Valbruna)',
          description: '60 Rottami • 1x Cassetta Attrezzi Completa • Sblocco Relitto Alfa Giulia Super'
        },
        objectives: [
          {
            id: 'ch2_obj_visit_valbruna',
            text: 'Raggiungi il Mulino di Valbruna sul torrente montano (PK 0.87 km)',
            type: 'visit_settlement',
            targetKey: 'valbruna_mill',
            targetPK: 870,
            check: (ctx) => ctx.z >= 870 || ctx.visitedSettlements.has('valbruna_mill') || ctx.visitedSettlements.has('yukon_crossing')
          },
          {
            id: 'ch2_obj_scavenge_lumber',
            text: 'Ispeziona il piazzale boscaioli (PK 1.04 km) per recuperare legname stagionato',
            type: 'distance',
            target: 1040,
            check: (ctx) => ctx.z >= 1040
          },
          {
            id: 'ch2_obj_fuel_reserve',
            text: 'Assicurati di avere almeno 20 litri di carburante nel serbatoio',
            type: 'fuel',
            target: 20,
            check: (ctx) => ctx.fuelLevel >= 20
          },
          {
            id: 'ch2_obj_reach_1250',
            text: 'Avanza oltre il PK 1.25 km penetrando verso la soglia delle grandi terre aride',
            type: 'distance',
            target: 1250,
            check: (ctx) => ctx.z >= 1250
          }
        ]
      },

      {
        id: 'ch_3',
        index: 2,
        number: 'III',
        title: 'La Fornace del Gran Deserto & L\'Oasi di El Kantara',
        subtitle: 'Dune Mobili, 48°C all\'Ombra & Sete del Radiatore [PK 1.30 - 1.95 KM]',
        bannerIcon: '🐪',
        speaker: 'TARIQ IBN-BATTUTA (GUIDA CAROVANIERA)',
        speakerAvatar: '🏜️',
        briefing: `Ingegnere, sei entrato nell'inferno del Gran Deserto. La sabbia finissima si insinua nei filtri aria e l'aria rovente a 48°C fa bollire il liquido di raffreddamento in salita. All'Oasi di El Kantara (PK 1.52 km) puoi riempire le taniche d'acqua potabile e barattare datteri e pezzi d'acciaio. Non accelerare bruscamente o scaverai la tua fossa nella sabbia viva!`,
        targetPK: 1950,
        rewards: {
          scrap: 80,
          items: [{ id: 'water_purified', count: 2 }, { id: 'spare_tire', count: 1 }],
          description: '80 Rottami • 2x Bottiglioni Acqua Purificata • 1x Pneumatico Rinforzato Sabbia'
        },
        objectives: [
          {
            id: 'ch3_obj_reach_oasis',
            text: 'Raggiungi l\'Oasi di El Kantara tra le palme e l\'antico pozzo (PK 1.52 km)',
            type: 'visit_settlement',
            targetKey: 'elkantara_oasis',
            targetPK: 1520,
            check: (ctx) => ctx.z >= 1520 || ctx.visitedSettlements.has('elkantara_oasis') || ctx.visitedSettlements.has('coldfoot_camp')
          },
          {
            id: 'ch3_obj_inspect_wreck',
            text: 'Individua l\'autocarro Berliet sabbiato tra le dune a PK 1.72 km',
            type: 'distance',
            target: 1720,
            check: (ctx) => ctx.z >= 1720
          },
          {
            id: 'ch3_obj_thirst_check',
            text: 'Mantieni l\'idratazione corporea e non farti sopraffare dal caldo del deserto',
            type: 'survival',
            check: (ctx) => ctx.thirst >= 40
          },
          {
            id: 'ch3_obj_reach_1900',
            text: 'Attraversa l\'erg sabbioso e tocca la soglia della savana a quota PK 1.90 km',
            type: 'distance',
            target: 1900,
            check: (ctx) => ctx.z >= 1900
          }
        ]
      },

      {
        id: 'ch_4',
        index: 3,
        number: 'IV',
        title: 'La Savana Infinita & L\'Avamposto del Serengeti',
        subtitle: 'Piste di Laterite Rossa & La Leggenda del Dangel 4x4 [PK 1.95 - 2.60 KM]',
        bannerIcon: '🦁',
        speaker: 'RANGER KIBWE (GUARDAPARCO SERENGETI)',
        speakerAvatar: '🦒',
        briefing: `Jambo Paolo! Qui è il Ranger Kibwe dall'avamposto del Serengeti. La terra rossa lateritica è piena di buche e corrugazioni ondulate che spaccano i braccetti delle sospensioni. Mantieni una traiettoria fluida tra i baobab secolari. Nel nostro hangar c'è un leggendario Peugeot 504 Dangel 4x4: portaci ricambi per il generatore solare e ti consegneremo le coordinate!`,
        targetPK: 2600,
        rewards: {
          scrap: 110,
          items: [{ id: 'reinforced_coil', count: 1 }, { id: 'graphene_battery', count: 1 }],
          unlockVehicleHint: 'Peugeot 504 Dangel 4x4 (Disponibile nel Parco Fuoristrada)',
          description: '110 Rottami • 1x Molla Sospensione Rinforzata • Sblocco Peugeot 504 Dangel'
        },
        objectives: [
          {
            id: 'ch4_obj_reach_serengeti',
            text: 'Raggiungi l\'Avamposto Ranger del Serengeti e rifornisciti alla torre (PK 2.17 km)',
            type: 'visit_settlement',
            targetKey: 'serengeti_outpost',
            targetPK: 2170,
            check: (ctx) => ctx.z >= 2170 || ctx.visitedSettlements.has('serengeti_outpost') || ctx.visitedSettlements.has('chandalar_shelf')
          },
          {
            id: 'ch4_obj_baobab_pass',
            text: 'Oltrepassa il bosco monumentale dei grandi Baobab a PK 2.34 km',
            type: 'distance',
            target: 2340,
            check: (ctx) => ctx.z >= 2340
          },
          {
            id: 'ch4_obj_scrap_stock',
            text: 'Accumula almeno 35 unità di rottami per fortificare i bracci delle ruote',
            type: 'scrap',
            target: 35,
            check: (ctx) => ctx.inventoryScrap >= 35
          },
          {
            id: 'ch4_obj_reach_2550',
            text: 'Supera la steppa dorata e preparati all\'ingresso nella foresta equatoriale (PK 2.55 km)',
            type: 'distance',
            target: 2550,
            check: (ctx) => ctx.z >= 2550
          }
        ]
      },

      {
        id: 'ch_5',
        index: 4,
        number: 'V',
        title: 'L\'Inferno Smeraldo della Foresta Pluviale Equatoriale',
        subtitle: 'Monsoni Torrenziali, Fango Argilloso & Stazione Rio Verde [PK 2.60 - 3.25 KM]',
        bannerIcon: '🌿',
        speaker: 'DOTT.SSA MAYA GOMEZ (STAZIONE RIO VERDE)',
        speakerAvatar: '👩‍🔬',
        briefing: `Paolo! Le piogge monsoniche hanno gonfiato i guadi della giungla equatoriale! Il fango argilloso ha un coefficiente di trazione bassissimo: inserisci la trazione integrale e fai cantare il motore per non allagare lo scarico. La stazione botanica di Rio Verde su palafitte (PK 2.82 km) ha bisogno di medicinali e cinghie di trasmissione. Guida con precisione chirurgica!`,
        targetPK: 3250,
        rewards: {
          scrap: 140,
          items: [{ id: 'waterproofing_wax', count: 2 }, { id: 'armor_plate', count: 2 }],
          unlockVehicleHint: 'BMW Serie 3 E30 Rally (Relitto Esploratori Rio Verde)',
          description: '140 Rottami • 2x Cera Idrorepellente • 2x Piastre Blindatura Fondo'
        },
        objectives: [
          {
            id: 'ch5_obj_reach_rioverde',
            text: 'Raggiungi la Stazione Scientifica di Rio Verde su palafitte (PK 2.82 km)',
            type: 'visit_settlement',
            targetKey: 'rioverde_station',
            targetPK: 2820,
            check: (ctx) => ctx.z >= 2820 || ctx.visitedSettlements.has('rioverde_station') || ctx.visitedSettlements.has('atigun_camp')
          },
          {
            id: 'ch5_obj_cross_canopy',
            text: 'Attraversa il guado alluvionale sotto le chiome dei giganti della giungla (PK 3.02 km)',
            type: 'distance',
            target: 3020,
            check: (ctx) => ctx.z >= 3020
          },
          {
            id: 'ch5_obj_hull_health',
            text: 'Sopravvivi alle correnti e mantieni l\'integrità dello scafo sopra il 50%',
            type: 'distance_hull',
            target: 3120,
            check: (ctx) => ctx.z >= 3120 && ctx.hullPercent >= 50
          },
          {
            id: 'ch5_obj_reach_3200',
            text: 'Sbuca dalla densa coltre pluviale ai piedi della catena montuosa alpina (PK 3.20 km)',
            type: 'distance',
            target: 3200,
            check: (ctx) => ctx.z >= 3200
          }
        ]
      },

      {
        id: 'ch_6',
        index: 5,
        number: 'VI',
        title: 'La Muraglia di Granito delle Cime Alpine',
        subtitle: 'Pendenze al 14%, Tornanti a Gomito & Rifugio Aquile [PK 3.25 - 3.90 KM]',
        bannerIcon: '⛰️',
        speaker: 'GOTTFRIED (SOCCORSO ALPINO VALICHI)',
        speakerAvatar: '🧗',
        briefing: `Grüß Gott, Ingegnere! Qui parla Gottfried dal Rifugio del Valico delle Aquile. Sei a quota 2.600 metri: tornanti a gomito con pendenze al 14%, ghiaioni instabili e falesie di granito a picco. In discesa usa sempre il freno motore e la seconda marcia per non cuocere i tamburi! Al rifugio (PK 3.47 km) c'è la galleria paravalanghe dove troverai riparo dai massi e una Land Rover Defender del soccorso alpino!`,
        targetPK: 3900,
        rewards: {
          scrap: 180,
          items: [{ id: 'toolkit', count: 1 }, { id: 'cryo_coolant', count: 1 }],
          unlockVehicleHint: 'Land Rover Defender 110 Tdi (Veicolo del Soccorso Alpino)',
          description: '180 Rottami • 1x Cassetta Attrezzi da Corsa • Sblocco Defender 110 Tdi'
        },
        objectives: [
          {
            id: 'ch6_obj_reach_aquile',
            text: 'Conquista il Valico delle Aquile e fermati al rifugio alpino (PK 3.47 km)',
            type: 'visit_settlement',
            targetKey: 'valico_aquile',
            targetPK: 3470,
            check: (ctx) => ctx.z >= 3470 || ctx.visitedSettlements.has('valico_aquile') || ctx.visitedSettlements.has('deadhorse_terminal')
          },
          {
            id: 'ch6_obj_avalanche_tunnel',
            text: 'Attraversa la galleria paravalanghe in cemento armato a PK 3.65 km',
            type: 'distance',
            target: 3650,
            check: (ctx) => ctx.z >= 3650
          },
          {
            id: 'ch6_obj_brake_temp',
            text: 'Scendi lungo il versante nord senza far salire eccessivamente la temperatura motore',
            type: 'distance',
            target: 3780,
            check: (ctx) => ctx.z >= 3780
          },
          {
            id: 'ch6_obj_reach_3850',
            text: 'Valica le creste granitiche e scendi verso le immense foreste boreali (PK 3.85 km)',
            type: 'distance',
            target: 3850,
            check: (ctx) => ctx.z >= 3850
          }
        ]
      },

      {
        id: 'ch_7',
        index: 6,
        number: 'VII',
        title: 'La Grande Taiga Boreale & Il Deposito Nord',
        subtitle: 'Abeti Neri, Piste di Tronchi & Il Regno dei Camion Pesanti [PK 3.90 - 4.55 KM]',
        bannerIcon: '🪓',
        speaker: 'JACK MILLER "ORSO POLARE"',
        speakerAvatar: '🐻',
        briefing: `Ingegnere Paolo! Qui è Jack Miller 'Orso Polare'. Siamo nella taiga boreale profonda. 650 metri di piste forestali in mezzo a milioni di abeti e betulle siberiane. Al Deposito Forestale Taiga Nord (PK 4.12 km) c'è la forgia e una cisterna di gasolio artico con punto di scorrimento a -50°C. Rifornisciti e controlla i cuscinetti: il settore successivo è la tundra artica e il ghiaccio vivo!`,
        targetPK: 4550,
        rewards: {
          scrap: 220,
          items: [{ id: 'thermal_lining', count: 2 }, { id: 'refined_fuel', count: 2 }],
          description: '220 Rottami • 2x Isolante Termico Abitacolo • 2x Taniche Carburante Invernale'
        },
        objectives: [
          {
            id: 'ch7_obj_reach_taiga',
            text: 'Raggiungi il Deposito Forestale Taiga Nord tra i carichi di legname (PK 4.12 km)',
            type: 'visit_settlement',
            targetKey: 'taiga_nord',
            targetPK: 4120,
            check: (ctx) => ctx.z >= 4120 || ctx.visitedSettlements.has('taiga_nord')
          },
          {
            id: 'ch7_obj_inspect_logyard',
            text: 'Oltrepassa il cantiere meccanizzato della picea a PK 4.28 km',
            type: 'distance',
            target: 4280,
            check: (ctx) => ctx.z >= 4280
          },
          {
            id: 'ch7_obj_fuel_full',
            text: 'Fai il pieno completo di carburante per affrontare il deserto bianco polare',
            type: 'fuel',
            target: 25,
            check: (ctx) => ctx.fuelLevel >= 25
          },
          {
            id: 'ch7_obj_reach_4500',
            text: 'Oltrepassa il limite della vegetazione arborea verso la tundra glaciale (PK 4.50 km)',
            type: 'distance',
            target: 4500,
            check: (ctx) => ctx.z >= 4500
          }
        ]
      },

      {
        id: 'ch_8',
        index: 7,
        number: 'VIII',
        title: 'L\'Ultima Frontiera: La Tundra Polare & La Base 80',
        subtitle: 'L\'80° Parallelo, Lastroni di Vetrone & Il Traguardo Supremo [PK 4.55 - 5.20+ KM]',
        bannerIcon: '❄️',
        speaker: 'DOTT.SSA ELENA VANCE & IL CONVOGLIO MONDIALE',
        speakerAvatar: '🏆',
        briefing: `PAOLO! TI SENTIAMO LIMPIDISSIMO SUL CANALE 19! Sei all'80° Parallelo Nord! La bufera artica soffia a -46°C e la strada è una lastra di verglas continuo. Segui le paline catarifrangenti rosse e bianche! Alla Base Polare 80 (PK 4.77 km) abbiamo acceso il Faro del Grande Meridiano! Taglia il traguardo: l'ingegneria meccanica analogica italiana ha unito tutti i biomi del mondo!`,
        targetPK: 5200,
        rewards: {
          scrap: 350,
          items: [{ id: 'cryo_coolant', count: 2 }, { id: 'graphene_battery', count: 2 }],
          unlockVehicleHint: 'Lancia Delta HF Integrale Evoluzione (Campione del Mondo)',
          description: '350 Rottami • SBLOCCO SUPREMO DELLA LANCIA DELTA HF INTEGRALE EVOLUZIONE'
        },
        objectives: [
          {
            id: 'ch8_obj_reach_base80',
            text: 'Raggiungi la Base Polare 80 e le sue cupole geodetiche riscaldate (PK 4.77 km)',
            type: 'visit_settlement',
            targetKey: 'polar_base_80',
            targetPK: 4770,
            check: (ctx) => ctx.z >= 4770 || ctx.visitedSettlements.has('polar_base_80')
          },
          {
            id: 'ch8_obj_metar_shelter',
            text: 'Oltrepassa la stazione meteo METAR e i radar polari a PK 4.94 km',
            type: 'distance',
            target: 4940,
            check: (ctx) => ctx.z >= 4940
          },
          {
            id: 'ch8_obj_radio_lighthouse',
            text: 'Raggiungi il Grande Faro Terminale del Meridiano Polare (PK 5.10 km)',
            type: 'distance',
            target: 5100,
            check: (ctx) => ctx.z >= 5100
          },
          {
            id: 'ch8_obj_complete_expedition',
            text: 'Trionfa nella Spedizione Trans-Continentale e consacra la Leggenda del Grande Meridiano!',
            type: 'victory',
            check: (ctx) => ctx.z >= 5180
          }
        ]
      }
    ];

    // Predefined Radio Dispatches Scripted along the 8 Biomes Corridor
    this.scriptedTransmissions = [
      {
        id: 'tx_intro',
        triggerZ: 15,
        speaker: 'SOFIA MARETTI (CAPO SPEDIZIONE)',
        avatar: '🧭',
        callsign: 'CH 19 • TRANS-EARTH DISPATCH',
        text: 'Paolo, mi ricevi sul Canale 19? Qui Sofia Maretti dal molo di San Vito. Il convoglio trans-continentale del Grande Meridiano parte adesso. Tieni gli occhi sulla temperatura acqua e ascolta il motore: 5.200 metri di traversata attraverso tutti i biomi della Terra ci attendono!'
      },
      {
        id: 'tx_san_vito_arrival',
        triggerZ: 215,
        speaker: 'CAPITANO NEREO (PORTO DI SAN VITO)',
        avatar: '⚓',
        callsign: 'CH 19 • HARBOR TRAFFIC',
        text: 'Ehi, Ingegnere! Riconosco l\'inconfondibile sibilo della Fiat Panda 4x4 Steyr-Puch! Fai scorta di bende e carburante qui al porto prima che la strada si inoltri nelle fitte foreste dell\'entroterra!'
      },
      {
        id: 'tx_valbruna_approach',
        triggerZ: 850,
        speaker: 'MASTRO JAREK (MULINO VALBRUNA)',
        avatar: '🔧',
        callsign: 'CH 19 • VALBRUNA MILL',
        text: 'Paolo! Sei nel fitto della foresta temperata! Le querce e i faggi filtrano la luce. Ti ho preparato i ricambi al mulino ad acqua e ti ho aperto il fienile dell\'Alfa Romeo Giulia bialbero!'
      },
      {
        id: 'tx_desert_warning',
        triggerZ: 1480,
        speaker: 'TARIQ IBN-BATTUTA (GUIDA DESERTO)',
        avatar: '🏜️',
        callsign: 'CH 19 • SAHARA CARAVAN',
        text: 'Attenzione Ingegnere! Sei entrato nel grande bacino sabbioso. Temperatura asfalto oltre i 55°C! All\'Oasi di El Kantara puoi rinfrescarti e bere acqua pura: non far bollire il radiatore!'
      },
      {
        id: 'tx_serengeti_arrival',
        triggerZ: 2150,
        speaker: 'RANGER KIBWE (SERENGETI OUTPOST)',
        avatar: '🦒',
        callsign: 'CH 19 • SAVANNA RANGER POST',
        text: 'Karibu Paolo! Sei tra le acacie a ombrello e i baobab del Serengeti! Sulla terra battuta lateritica mantieni il gas costante. La Peugeot 504 Dangel 4x4 da safari ti aspetta all\'avamposto!'
      },
      {
        id: 'tx_rainforest_alert',
        triggerZ: 2800,
        speaker: 'DOTT.SSA MAYA GOMEZ (RIO VERDE)',
        avatar: '🌿',
        callsign: 'CH 19 • TROPICAL LAB POST',
        text: 'Paolo! Sta iniziando il monsone equatoriale! L\'argilla rossa è diventata saponosa: inserisci la trazione integrale e la Primina corta! Ti guideremo con i fari della stazione su palafitte!'
      },
      {
        id: 'tx_alpine_climb',
        triggerZ: 3450,
        speaker: 'GOTTFRIED (VALICO DELLE AQUILE)',
        avatar: '🧗',
        callsign: 'CH 19 • ALPINE RESCUE',
        text: 'Ingegnere, sei sopra quota 2.500 metri! Pendenza 14%, falesie di granito e gallerie paravalanghe. Usa marce basse e fai raffreddare i freni: la vista dal rifugio è maestosa!'
      },
      {
        id: 'tx_taiga_nord',
        triggerZ: 4100,
        speaker: 'JACK MILLER "ORSO POLARE"',
        avatar: '🐻',
        callsign: 'CH 19 • BOREAL CONVOY',
        text: 'Paolo! Benvenuto nella grande taiga boreale! Milioni di abeti neri e betulle ti circondano. Rifornisciti con il nostro gasolio artico a Taiga Nord: il gran balzo verso il polo ha inizio!'
      },
      {
        id: 'tx_polar_beacon',
        triggerZ: 4750,
        speaker: 'DOTT.SSA ELENA VANCE (BASE 80)',
        avatar: '👩‍🔬',
        callsign: 'CH 19 • POLAR BASE 80',
        text: 'PAOLO! TI VEDIAMO DAI RADAR! La Panda 4x4 sta ruggendo sul vetrone a -46°C! Abbiamo acceso il grande faro del Meridiano! Sei a pochi chilometri dal traguardo finale!'
      },
      {
        id: 'tx_victory_meridian',
        triggerZ: 5160,
        speaker: 'CONVOGLIO MONDIALE DEL GRANDE MERIDIANO',
        avatar: '🏆',
        callsign: 'CH 19 • GLOBAL FLEET',
        text: 'VITTORIA! HAI ATTRAVERSATO TUTTI E GLI 8 BIOMI NATURALI DELLA TERRA! Dal Mediterraneo ai ghiacci del polo: la meccanica analogica italiana ha trionfato! Sei la leggenda del Grande Meridiano!'
      }
    ];

    // Paolo's Technical & Engineering Field Notes
    this.engineerNotes = [
      {
        title: 'La Primina della Fiat Panda 4x4 Steyr-Puch',
        category: 'CINEMATICA ANALOGICA',
        text: 'Sviluppata a Graz dalla Steyr-Daimler-Puch nel 1983. Invece di un pesante riduttore a due leve, sfrutta una prima marcia ultra-corta (rapporto 1:3.91) abbinata a un differenziale conico elicoidale con innesto a crabot manuale. Sui fanghi argillosi della giungla equatoriale e sulla neve polare, consente di avanzare a 3.5 km/h senza sfrizionare. Un capolavoro di razionalità ingegneristica.'
      },
      {
        title: 'Galleggiamento & Coefficiente d\'Attrito su Sabbie Sahariane',
        category: 'FISICA DEI TERRENI',
        text: 'Nel bioma desertico, la sabbia quarzosa granulare presenta un attrito dinamico attorno a 0.58. La tentazione è sgasare, ma il momento torcente eccessivo scava buche e fa spanciare il veicolo. Il trucco dell\'ingegnere: mantenere il motore sul regime di coppia (3.000 rpm), pressione pneumatici ridotta a 1.2 bar e traiettorie rotonde senza brusche sterzate.'
      },
      {
        title: 'Dinamica di Guida su Fango Equatoriale & Tole Ondulée',
        category: 'ASSETTO & SOSPENSIONI',
        text: 'Sulle piste africane e nei guadi della foresta pluviale le corrugazioni ad alta frequenza rischiano di distruggere gli steli degli ammortizzatori per cavitazione dell\'olio. Superata la velocità critica di 48 km/h, la frequenza propria della cassa vettura si disaccoppia dal fondo, consentendo di galleggiare sulle creste delle ondulazioni.'
      },
      {
        title: 'Dissipazione Termica sui Tornanti Alpini al 14%',
        category: 'TERMODINAMICA FRENI',
        text: 'Nella discesa dal Valico delle Aquile i tamburi posteriori possono raggiungere i 380°C causando il vapor lock del liquido freni DOT4. Scalare sempre in seconda marcia sfruttando l\'elevato rapporto di compressione del motore per frenare con la contropressione nei collettori di scarico.'
      },
      {
        title: 'Aderenza su Vetrone & Paline Rifrangenti Polari',
        category: 'SUPERFICI ARTICHE',
        text: 'A -46°C nella tundra, il ghiaccio vivo non fonde sotto il battistrada ma forma scaglie vitree con grip inferiore al 35%. L\'unico punto di riferimento in caso di bufera o whiteout sono le paline catarifrangenti bicolore posizionate ogni 22 metri a bordo banchina.'
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
    const speedKmh = this.vehicle.speedKmh !== undefined ? this.vehicle.speedKmh : Math.abs(this.vehicle.forwardSpeed || 0) * 3.6;
    const fuelLevel = this.vehicle ? this.vehicle.fuel : (this.survivalState ? this.survivalState.fuel : 30);
    const hullPercent = this.vehicle ? this.vehicle.hull : (this.survivalState ? this.survivalState.hull : 100);
    const inventoryScrap = this.inventorySystem ? this.inventorySystem.scrapMetal : 0;

    // Build context for checks
    const context = {
      z: z,
      speedKmh: speedKmh,
      fuelLevel: fuelLevel,
      hullPercent: hullPercent,
      inventoryScrap: inventoryScrap,
      visitedSettlements: this.poiManager ? this.poiManager.visitedSettlements || new Set() : new Set(),
      activeVehicleId: this.vehicle.modelId || this.vehicle.currentModelId || 'panda_4x4'
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
    this.maxDispatchDuration = 24.0;
    this.radioDispatchTimer = this.maxDispatchDuration; // 24 seconds generous reading time

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
