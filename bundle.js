(function() {
'use strict';

// --- FILE: src/config.js ---
/**
 * THE LONG MERIDIAN - Configuration & Game Constants
 */

const CONFIG = {
  VERSION: '1.0.0',
  GAME_TITLE: 'THE LONG MERIDIAN',
  SUBTITLE: 'Northern Survival Corridor',

  // World & Generation
  WORLD: {
    CHUNK_LENGTH: 80,          // Length of each procedural road chunk (meters)
    VISIBLE_CHUNKS: 5,         // Number of chunks rendered ahead/behind
    ROAD_SEGMENTS_PER_CHUNK: 20,
    BASE_ROAD_WIDTH: 24.0,     // Generous 24m highway (2 wide travel lanes + emergency shoulders)
    DESPAWN_DISTANCE: 70,      // Distance behind player to recycle chunks
    ROAD_Y: 0,
  },

  // Real-World Natural Biomes of Planet Earth: The Grand Trans-Earth Meridian Expedition
  BIOMES: {
    MEDITERRANEAN_COAST: {
      id: 'mediterranean_coast',
      sectorIndex: 0,
      name: 'Riviera dei Pini & Coste Rocciose',
      subname: 'Costa Mediterranea & Macchia Aromatica [PK 0.0 - 0.65 KM]',
      loreTitle: 'Falesie Calcaree, Pini Marittimi & Asfalto sul Mare',
      history: 'Punto di partenza della Spedizione Planetaria del Grande Meridiano. La strada costiera si snoda a picco sul mare azzurro cobalto, tra pinete marittime profumate di resina, ulivi saraceni e muretti a secco in pietra viva. La brezza salmastra rinfresca i motori, ma il calcare polveroso si deposita sui filtri dell\'aria.',
      settlementName: 'Porto San Vito & Vecchia Tonnara',
      settlementPK: 220,
      colorSky: 0x38bdf8,
      colorFog: 0x7dd3fc,
      colorGround: 0x854d0e,
      colorRoad: 0x334155,
      fogDensity: 0.012,
      ambientIntensity: 0.62,
      sunIntensity: 1.25,
      sunColor: 0xfffbeb,
      roadRoughness: 0.35,
      tractionFactor: 1.0,
      weatherTypes: ['clear', 'sea_breeze', 'heatwave'],
      hazardFrequency: 0.3,
      musicMood: 'mediterranean_breeze',
      environmentalThreat: 'Banchine strette a strapiombo sulle scogliere e polvere calcarea bianca scivolosa nelle curve veloci.',
      primaryExport: ['refined_fuel', 'water_purified', 'toolkit'],
      criticalNeed: ['spare_tire', 'scrap_metal', 'engine_oil'],
      recommendedGear: 'Assetto stradale preciso, filtro aria a bagno d\'olio per la polvere calcarea'
    },
    TEMPERATE_FOREST: {
      id: 'temperate_forest',
      sectorIndex: 1,
      name: 'Valli Appenniniche & Querce Frondose',
      subname: 'Foresta Temperata di Latifoglie & Fiumi [PK 0.65 - 1.30 KM]',
      loreTitle: 'Boschi di Querce e Faggi, Ponti in Pietra & Valli Nebbiose',
      history: 'Il convoglio penetra nella grande foresta temperata di fondovalle. Querce secolari e faggi creano una galleria verde d\'ombra screziata dal sole. I corsi d\'acqua sono scavalcati da storici ponti ad arco in pietra d\'arenaria. Al mattino la nebbia fluviale ristagna nei fondovalle rendendo l\'asfalto umido e viscido.',
      settlementName: 'Mulino di Valbruna & Segheria Idraulica',
      settlementPK: 870,
      colorSky: 0x0f172a,
      colorFog: 0x164e63,
      colorGround: 0x14532d,
      colorRoad: 0x1e293b,
      fogDensity: 0.022,
      ambientIntensity: 0.48,
      sunIntensity: 0.95,
      sunColor: 0xfef08a,
      roadRoughness: 0.5,
      tractionFactor: 0.88,
      weatherTypes: ['heavy_mist', 'rain', 'overcast'],
      hazardFrequency: 0.4,
      musicMood: 'dark_forest',
      environmentalThreat: 'Fogliame fradicio sul manto stradale che riduce l\'aderenza in frenata; fitti banchi di nebbia fluviale.',
      primaryExport: ['cured_timber', 'first_aid_bandage', 'water_purified'],
      criticalNeed: ['fuel_canister', 'spark_plugs', 'scrap_metal'],
      recommendedGear: 'Tergicristalli efficienti, fari fendinebbia gialli vintage'
    },
    ARID_DESERT: {
      id: 'arid_desert',
      sectorIndex: 2,
      name: 'Grande Erg Sahariano & Oasi di Fuoco',
      subname: 'Deserto Arido, Dune Ondulate & Piste Reg [PK 1.30 - 1.95 KM]',
      loreTitle: 'Oceano di Sabbia Dorata, Tempeste di Polvere & Calore +45°C',
      history: 'La transizione nel deserto più vasto e implacabile del pianeta. Una distesa infinita di dune di sabbia finissima, lastroni di roccia erosa dal vento (reg) e specchi d\'acqua salmastra nelle oasi carovaniere. Il termometro tocca i 46°C: la temperatura dell\'acqua motore schizza alle stelle se non si modula il gas.',
      settlementName: 'Oasi di El-Kantara & Forte Carovaniero',
      settlementPK: 1520,
      colorSky: 0x78350f,
      colorFog: 0xb45309,
      colorGround: 0xd97706,
      colorRoad: 0x92400e,
      fogDensity: 0.015,
      ambientIntensity: 0.75,
      sunIntensity: 1.45,
      sunColor: 0xffedd5,
      roadRoughness: 0.65,
      tractionFactor: 0.72,
      weatherTypes: ['heatwave', 'sandstorm', 'clear'],
      hazardFrequency: 0.5,
      heatDanger: true,
      musicMood: 'desert_wind',
      environmentalThreat: 'Calore estremo che minaccia di far bollire il radiatore; dune ventate mobili che possono insabbiare le ruote.',
      primaryExport: ['waterproofing_wax', 'refined_fuel', 'engine_oil'],
      criticalNeed: ['water_bottle', 'water_purified', 'spare_tire'],
      recommendedGear: '4WD o marcia corta Primina per disincagliarsi dalla sabbia, ventola radiatore sempre attiva'
    },
    SAVANNA_STEPPE: {
      id: 'savanna_steppe',
      sectorIndex: 3,
      name: 'Savana del Serengeti & Terra Rossa',
      subname: 'Prateria dell\'Acacia & Piste Lateritiche [PK 1.95 - 2.60 KM]',
      loreTitle: 'Piste di Terra Rossa, Baobab Millenari & Vaste Praterie Dorate',
      history: 'L\'altopiano della savana africana: distese d\'erba bionda punteggiate da acacie ad ombrello e imponenti baobab che sfidano i secoli. La carreggiata è una pista di terra battuta rossa lateritica, con corrugazioni e canaloni d\'acqua asciutti scavati dalle piogge passate.',
      settlementName: 'Stazione Ranger della Piana d\'Oro',
      settlementPK: 2170,
      colorSky: 0x451a03,
      colorFog: 0x9a3412,
      colorGround: 0xb91c1c,
      colorRoad: 0x7f1d1d,
      fogDensity: 0.016,
      ambientIntensity: 0.65,
      sunIntensity: 1.25,
      sunColor: 0xfed7aa,
      roadRoughness: 0.6,
      tractionFactor: 0.84,
      weatherTypes: ['clear', 'overcast', 'sandstorm'],
      hazardFrequency: 0.45,
      musicMood: 'industrial_drone',
      environmentalThreat: 'Fondo stradale a lamiera ondulata che martella le boccole delle sospensioni e buche di fango secco a sorpresa.',
      primaryExport: ['reinforced_coil', 'armor_plate', 'canned_stew'],
      criticalNeed: ['first_aid_bandage', 'toolkit', 'refined_fuel'],
      recommendedGear: 'Ammortizzatori a doppio effetto per assorbire le ondulazioni della pista rossa'
    },
    TROPICAL_RAINFOREST: {
      id: 'tropical_rainforest',
      sectorIndex: 4,
      name: 'Giungla di Rio Verde & Monsoni Equatoriali',
      subname: 'Foresta Pluviale Equatoriale & Fango Viscido [PK 2.60 - 3.25 KM]',
      loreTitle: 'Vegetazione Monumentale, Diluvi Monsonici & Argilla Liquida',
      history: 'La fitta volta della foresta pluviale equatoriale, dove la luce solare filtra appena attraverso le chiome di ficus giganti e felci arboree. L\'umidità sfiora il 98% e acquazzoni monsonici torrenziali trasformano la pista in un letto di argilla liquida e pozze d\'acqua che mettono a dura prova l\'impianto elettrico.',
      settlementName: 'Avamposto Botanico Rio Verde & Scalo Fluviale',
      settlementPK: 2820,
      colorSky: 0x064e3b,
      colorFog: 0x022c22,
      colorGround: 0x052e16,
      colorRoad: 0x14532d,
      fogDensity: 0.028,
      ambientIntensity: 0.4,
      sunIntensity: 0.8,
      sunColor: 0x6ee7b7,
      roadRoughness: 0.75,
      tractionFactor: 0.62,
      weatherTypes: ['tropical_monsoon', 'torrential_rain', 'dense_fog'],
      hazardFrequency: 0.55,
      musicMood: 'aquatic_melancholy',
      environmentalThreat: 'Aquaplaning severo e fanghiglia argillosa a bassissima trazione; rischio di bagnare spinterogeno e candele nei guadi.',
      primaryExport: ['antiseptic_resin', 'waterproofing_wax', 'peat_filter'],
      criticalNeed: ['electronics', 'spare_tire', 'engine_oil'],
      recommendedGear: 'Snorkel per la presa d\'aria motore, trazione integrale 4WD inserita, cera siliconica sui cavi'
    },
    ALPINE_PEAKS: {
      id: 'alpine_peaks',
      sectorIndex: 5,
      name: 'Valico delle Aquile & Vette Alpine',
      subname: 'Massiccio di Granito & Tornanti a 2.450m [PK 3.25 - 3.90 KM]',
      loreTitle: 'Falesie di Roccia Nuda, Tornanti a Gomito & Pendenze del 14%',
      history: 'La scalata del tetto del mondo continentale. Il tracciato si inerpica su tornanti scavati nella viva roccia di granito, con cascate di disgelo e strapiombi vertiginosi. L\'aria rarefatta d\'alta quota toglie fiato e potenza ai carburatori, mentre le discese prolungate surriscaldano i freni a tamburo.',
      settlementName: 'Rifugio Valico delle Aquile (Passo Alpino 2.450m)',
      settlementPK: 3470,
      colorSky: 0x1e293b,
      colorFog: 0x334155,
      colorGround: 0x475569,
      colorRoad: 0x1e293b,
      fogDensity: 0.016,
      ambientIntensity: 0.55,
      sunIntensity: 1.3,
      sunColor: 0xfff7ed,
      roadRoughness: 0.85,
      tractionFactor: 0.82,
      weatherTypes: ['mountain_gale', 'freezing_rain', 'clear'],
      hazardFrequency: 0.5,
      musicMood: 'anomalous_pulse',
      environmentalThreat: 'Pietrisco di franamento tagliente in curva e fading termico dei freni nelle discese prolungate.',
      primaryExport: ['tungsten_drill_bit', 'reinforced_coil', 'armor_plate'],
      criticalNeed: ['fuel_canister', 'refined_fuel', 'canned_stew'],
      recommendedGear: 'Freno motore in marcia bassa, pastiglie e ganasce freno rinforzate, paramassi sottoscocca'
    },
    BOREAL_TAIGA: {
      id: 'boreal_taiga',
      sectorIndex: 6,
      name: 'Taiga Siberiana & Foreste di Conifere',
      subname: 'Abeti Innevati, Ponti di Tronchi & Permafrost [PK 3.90 - 4.55 KM]',
      loreTitle: 'L\'Immenso Mare Verde delle Conifere Subartiche & Fiumi Gelati',
      history: 'La sterminata taiga boreale: milioni di abeti e picea che si estendono a perdita d\'occhio sotto cieli di piombo freddo. La strada attraversa fiumi ghiacciati con passerelle e cordoni di tronchi. Il suolo nasconde il permafrost e a motore spento la temperatura scende rapidamente sottozero.',
      settlementName: 'Stazione Forestale Taiga Nord & Scalo Zattere',
      settlementPK: 4120,
      colorSky: 0x0f172a,
      colorFog: 0x1e293b,
      colorGround: 0x1e293b,
      colorRoad: 0x334155,
      fogDensity: 0.024,
      ambientIntensity: 0.42,
      sunIntensity: 0.65,
      sunColor: 0xbfdbfe,
      roadRoughness: 0.65,
      tractionFactor: 0.68,
      weatherTypes: ['heavy_mist', 'blizzard', 'overcast'],
      hazardFrequency: 0.55,
      coldDanger: true,
      musicMood: 'cold_isolation',
      environmentalThreat: 'Freddo rigido a -10°C che congela l\'umidità nei condotti carburante; lastroni di ghiaccio nascosti sotto aghi di pino.',
      primaryExport: ['cured_timber', 'cryo_coolant', 'toolkit'],
      criticalNeed: ['graphene_battery', 'refined_fuel', 'water_purified'],
      recommendedGear: 'Candele calde per basse temperature, additivo anticongelante nel serbatoio'
    },
    POLAR_TUNDRA: {
      id: 'polar_tundra',
      sectorIndex: 7,
      name: 'Calotta Polare & Oceano Artico',
      subname: 'Banchisa Glaciale, Aurore Boreali & 80° Parallelo [PK 4.55 - 5.20+ KM]',
      loreTitle: 'Il Traguardo della Notte Polare, Vetrone Vivo & Aurore Cosmiche',
      history: 'Il punto più a nord dell\'intero globo terrestre: la banchisa polare affacciata sull\'Oceano Artico all\'80° Parallelo. Sotto il cielo nero illuminato da aurore boreali smeraldo e violette, la strada è una lastra di verglas e ghiaccio compatto. Il termometro tocca -46°C: solo chi possiede coraggio e un veicolo leggendario può raggiungere la base scientifica finale.',
      settlementName: 'Base Scientifica Globale 80° Parallelo',
      settlementPK: 4770,
      colorSky: 0x020617,
      colorFog: 0x0f172a,
      colorGround: 0x1e293b,
      colorRoad: 0x38bdf8,
      fogDensity: 0.025,
      ambientIntensity: 0.35,
      sunIntensity: 0.45,
      sunColor: 0xa5f3fc,
      roadRoughness: 0.5,
      tractionFactor: 0.38,
      weatherTypes: ['blizzard', 'aurora_static', 'freezing_rain'],
      hazardFrequency: 0.65,
      coldDanger: true,
      musicMood: 'cold_isolation',
      environmentalThreat: 'Gelo polare estremo (-45°C) e lastroni di ghiaccio vivo: trazione ridotta al 38% e rischio di congelamento blocco motore.',
      primaryExport: ['cryo_coolant', 'thermal_lining', 'electronics'],
      criticalNeed: ['spare_tire', 'fuel_canister', 'engine_oil'],
      recommendedGear: 'Glicole criogenico antigelo, gomme chiodate, fari ausiliari di profondità per la notte polare'
    }
  },

  // Major Settlements and Trade Hubs along the Trans-Earth Meridian
  SETTLEMENTS: {
    san_vito_harbor: {
      id: 'san_vito_harbor',
      biomeId: 'mediterranean_coast',
      pk: 220,
      name: 'Porto San Vito & Vecchia Tonnara',
      faction: 'Consorzio Marinaro e Meccanici della Riviera',
      population: 140,
      icon: '⚓',
      description: 'Borgo marinaro fortificato incastonato tra le scogliere calcaree e le pinete costiere. I pescatori e i mastri d\'ascia scambiano carburante filtrato, acqua di sorgente e arnesi d\'officina in cambio di ricambi metallici.',
      tacticalAdvice: 'Fai il pieno di carburante e acquista chiavi inglesi: lungo la costa l\'asfalto è scorrevole, ma l\'avvicinamento all\'entroterra richiederà attrezzi solidi.',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },
    valbruna_mill: {
      id: 'valbruna_mill',
      biomeId: 'temperate_forest',
      pk: 870,
      name: 'Mulino di Valbruna & Segheria Idraulica',
      faction: 'Gilda Forestale & Guardiacaccia Appenninici',
      population: 95,
      icon: '🪵',
      description: 'Storico insediamento sul fiume azionato da due grandi ruote idrauliche. I boscaioli stagionano legname duro di faggio e quercia ed estraggono resine lenitive per le bende mediche.',
      tacticalAdvice: 'Acquista travi di legno stagionato per rinforzare il pianale: ti serviranno per affrontare il deserto e la savana.',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },
    elkantara_oasis: {
      id: 'elkantara_oasis',
      biomeId: 'arid_desert',
      pk: 1520,
      name: 'Oasi di El-Kantara & Forte Carovaniero',
      faction: 'Carovanieri Nomadi Tuareg & Meccanici del Deserto',
      population: 120,
      icon: '🌴',
      description: 'Un\'oasi millenaria circondata da palme da dattero e mura d\'argilla rinforzata. I meccanici locali sono leggendari per la capacità di riparare qualsiasi radiatore con paste sigillanti idrorepellenti.',
      tacticalAdvice: 'Nel deserto l\'acqua pura vale oro. Compra cera protettiva e taniche d\'acqua prima di affrontare le tempeste di sabbia.',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },
    serengeti_outpost: {
      id: 'serengeti_outpost',
      biomeId: 'savanna_steppe',
      pk: 2170,
      name: 'Stazione Ranger della Piana d\'Oro',
      faction: 'Ranger della Riserva Naturale & Trasportatori del Bush',
      population: 75,
      icon: '🦁',
      description: 'Bivacco fortificato sotto un gigantesco baobab centenario. I guardaparco forgiano piastre corazzate e balestre rinforzate in grado di resistere ai colpi delle corrugazioni della pista lateritica.',
      tacticalAdvice: 'Installa balestre da carico pesanti per non spanciare sui dislivelli della savana. I ranger pagheranno caro bende e medicinali.',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },
    rioverde_station: {
      id: 'rioverde_station',
      biomeId: 'tropical_rainforest',
      pk: 2820,
      name: 'Avamposto Botanico Rio Verde & Scalo Fluviale',
      faction: 'Esploratori Idrologi & Comunità Indigena Fluviale',
      population: 68,
      icon: '🌿',
      description: 'Villaggio su palafitte di teak affacciato sul grande fiume equatoriale. I biologi distillano cere idrofobiche per isolare gli spinterogeni ed estraggono filtri a torba ad altissima capacità.',
      tacticalAdvice: 'I monsoni equatoriali allagano la carreggiata. Assicurati di avere la trazione integrale funzionante e pneumatici a tasselli profondi.',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },
    valico_aquile: {
      id: 'valico_aquile',
      biomeId: 'alpine_peaks',
      pk: 3470,
      name: 'Rifugio Valico delle Aquile (Passo Alpino 2.450m)',
      faction: 'Soccorso Alpino & Cantonieri dell\'Alta Quota',
      population: 52,
      icon: '🏔️',
      description: 'Rifugio in pietra granitica incastonato sulla forcella a 2.450 metri di quota. I cantonieri gestiscono frese sgombraneve e forgiano punte al tungsteno e balestre rinforzate per arrampicarsi sui ripidi tornanti.',
      tacticalAdvice: 'Le pendenze del 14% richiedono una prima marcia corta. Non surriscaldare i freni: usa sempre il freno motore nelle discese.',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },
    taiga_nord: {
      id: 'taiga_nord',
      biomeId: 'boreal_taiga',
      pk: 4120,
      name: 'Stazione Forestale Taiga Nord & Scalo Zattere',
      faction: 'Taglialegna Siberiani & Tecnici della Transcontinentale',
      population: 80,
      icon: '🌲',
      description: 'Avamposto tra le conifere innevate della taiga siberiana. Forniscono fluido criogenico antigelo e pannelli termoisolanti per impedire che l\'olio motore diventi solido durante le soste.',
      tacticalAdvice: 'Il freddo umido a -10°C gela i carburatori. Monta isolamento termico nel vano motore e fai scorta di antigelo.',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },
    polar_base_80: {
      id: 'polar_base_80',
      biomeId: 'polar_tundra',
      pk: 4770,
      name: 'Base Scientifica Globale 80° Parallelo',
      faction: 'Consorzio Scientifico Internazionale dell\'Oceano Polare',
      population: 45,
      icon: '❄️',
      description: 'Il capolinea assoluto del Grande Meridiano sulle sponde ghiacciate dell\'Oceano Glaciale Artico. Costruito su piloni idraulici riscaldati, è il cuore della ricerca sismica e planetaria.',
      tacticalAdvice: 'A -45°C il ghiaccio vivo offre aderenza minima. Guida con delicatezza estrema e goditi lo spettacolo dell\'aurora boreale sul traguardo!',
      buysMultiplier: 2.5,
      sellsDiscount: 0.7
    },

    // Legacy Aliases for backwards-compatibility
    fox_junction: { id: 'fox_junction', biomeId: 'mediterranean_coast', pk: 220, name: 'Porto San Vito (Ex Fox)', icon: '⚓', buysMultiplier: 2.5, sellsDiscount: 0.7 },
    yukon_crossing: { id: 'yukon_crossing', biomeId: 'temperate_forest', pk: 870, name: 'Mulino di Valbruna (Ex Yukon)', icon: '🪵', buysMultiplier: 2.5, sellsDiscount: 0.7 },
    coldfoot_camp: { id: 'coldfoot_camp', biomeId: 'arid_desert', pk: 1520, name: 'Oasi di El-Kantara (Ex Coldfoot)', icon: '🌴', buysMultiplier: 2.5, sellsDiscount: 0.7 },
    chandalar_shelf: { id: 'chandalar_shelf', biomeId: 'savanna_steppe', pk: 2170, name: 'Piana d\'Oro (Ex Chandalar)', icon: '🦁', buysMultiplier: 2.5, sellsDiscount: 0.7 },
    atigun_camp: { id: 'atigun_camp', biomeId: 'alpine_peaks', pk: 3470, name: 'Valico delle Aquile (Ex Atigun)', icon: '🏔️', buysMultiplier: 2.5, sellsDiscount: 0.7 },
    deadhorse_terminal: { id: 'deadhorse_terminal', biomeId: 'polar_tundra', pk: 4770, name: 'Base 80° Parallelo (Ex Deadhorse)', icon: '❄️', buysMultiplier: 2.5, sellsDiscount: 0.7 }
  },

  // Surface materials details
  SURFACES: {
    ASPHALT: { name: 'Asfalto Panoramico', friction: 1.0, wearMultiplier: 1.0, sound: 'asphalt' },
    DIRT: { name: 'Fango Argilloso Temperato', friction: 0.75, wearMultiplier: 1.4, sound: 'dirt' },
    GRAVEL: { name: 'Ghiaia e Detriti', friction: 0.8, wearMultiplier: 1.3, sound: 'gravel' },
    ICE: { name: 'Ghiaccio Vivo & Verglas', friction: 0.35, wearMultiplier: 0.8, sound: 'ice' },
    SLUDGE: { name: 'Argilla Liquida Equatoriale', friction: 0.52, wearMultiplier: 2.0, sound: 'sludge' },
    STEEL_BRIDGE: { name: 'Grigliato d\'Acciaio & Ponti', friction: 0.9, wearMultiplier: 1.1, sound: 'metal' },
    SAND: { name: 'Sabbia Cedevole delle Dune', friction: 0.58, wearMultiplier: 1.8, sound: 'dirt' },
    RED_DIRT: { name: 'Terra Rossa di Savana (Laterite)', friction: 0.82, wearMultiplier: 1.2, sound: 'dirt' },
    ALPINE_ROCK: { name: 'Pietrisco e Granito Alpino', friction: 0.75, wearMultiplier: 1.5, sound: 'gravel' }
  },

  // Real European Classic Vehicles Catalog (1960s - 2000s)
  DEFAULT_VEHICLE_ID: 'panda_4x4',

  VEHICLES_CATALOG: {
    panda_4x4: {
      id: 'panda_4x4',
      name: 'Panda 4x4 Steyr-Puch',
      maker: 'Fiat',
      year: 1983,
      country: 'Italia / Austria',
      flag: '🇮🇹',
      category: 'Utilitaria Integrale Leggera',
      engine: '965cc A112 Asta e Bilancieri',
      cylinders: 4,
      displacementCc: 965,
      powerHp: 48,
      torqueNm: 74,
      redlineRpm: 6000,
      idleRpm: 850,
      topSpeedKmh: 135,
      weightKg: 780,
      drivetrain: '4WD_MANUAL',
      drivetrainBadge: '4WD STEYR INSERIBILE',
      hasTurbo: false,
      turboBoostMaxBar: 0,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 35,
      fuelConsumptionRate: 0.024,
      trunkCapacityKg: 85,
      tractionBonus: 1.15,
      handling: {
        agility: 1.25,
        oversteerTendency: 0.1,
        stability: 0.85,
        brakeForce: 30.0,
        groundClearance: 0.19,
        bodyRollFactor: 0.28
      },
      dashTheme: {
        style: 'veglia_minimal',
        speedoMax: 160,
        redlineRpm: 6000,
        clusterName: 'VEGLIA BORLETTI PANDA',
        dialBg: '#12161a',
        tickColor: '#94a3b8',
        needleColor: '#f97316',
        accentColor: '#22c55e',
        hasGlowPlug: false,
        hasTurboGauge: false
      },
      soundProfile: {
        baseFreq: 42,
        timbre: 'raspy_4cyl',
        cylinders: 4,
        turboWhistle: 0.0,
        dieselKnock: 0.0
      },
      description: 'Progettata da Giorgetto Giugiaro con trazione integrale sviluppata da Steyr-Puch a Graz. Pesa appena 780 kg e dispone della leggendaria "primina" ultra-corta che le permette di arrampicarsi su pendenze del 50%.',
      tacticalDaltonAdvice: 'La leggerezza eccezionale le impedisce di sprofondare nel fango muskeg del Koyukuk e sulla neve fresca. Manca di potenza sulla salita dell\'Atigun Pass a pieno carico.',
      tier: 1,
      unlockType: 'default',
      discoveryPK: 0,
      discoveryLocation: 'Livengood Staging Post [MP 0]',
      restorationCost: {},
      restorationStory: 'La tua fidata compagna di partenza: leggera, agile e dotata della leggendaria primina Steyr-Puch.'
    },

    delta_integrale: {
      id: 'delta_integrale',
      name: 'Delta HF Integrale Evoluzione',
      maker: 'Lancia',
      year: 1991,
      country: 'Italia',
      flag: '🇮🇹',
      category: 'Rally Special Gr.A WRC',
      engine: '2.0L 16V Turbo Garrett T3 Intercooler',
      cylinders: 4,
      displacementCc: 1995,
      powerHp: 210,
      torqueNm: 300,
      redlineRpm: 6800,
      idleRpm: 950,
      topSpeedKmh: 220,
      weightKg: 1300,
      drivetrain: 'AWD_TORSEN',
      drivetrainBadge: 'TORSEN AWD 47:53',
      hasTurbo: true,
      turboBoostMaxBar: 1.4,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 57,
      fuelConsumptionRate: 0.048,
      trunkCapacityKg: 95,
      tractionBonus: 1.35,
      handling: {
        agility: 1.2,
        oversteerTendency: 0.25,
        stability: 1.15,
        brakeForce: 38.0,
        groundClearance: 0.14,
        bodyRollFactor: 0.16
      },
      dashTheme: {
        style: 'veglia_rally_yellow',
        speedoMax: 260,
        redlineRpm: 6800,
        clusterName: 'VEGLIA COMPETIZIONE CORSE',
        dialBg: '#0f1115',
        tickColor: '#eab308',
        needleColor: '#ef4444',
        accentColor: '#eab308',
        hasGlowPlug: false,
        hasTurboGauge: true
      },
      soundProfile: {
        baseFreq: 39,
        timbre: 'rally_turbo_4cyl',
        cylinders: 4,
        turboWhistle: 0.85,
        dieselKnock: 0.0
      },
      description: 'Regina incontrastata di 6 titoli mondiali rally costruttori consecutivi. Trazione integrale permanente con differenziale epicicloidale e giunto Ferguson centrale abbinato al differenziale Torsen posteriore.',
      tacticalDaltonAdvice: 'Velocità e tenuta laterale devastanti sui tratti veloci di ghiaia battuta. Fai attenzione al consumo carburante elevato e all\'entrata repentina della turbina Garrett sui fondi ghiacciati.',
      tier: 4,
      unlockType: 'barn_find',
      discoveryPK: 6500,
      discoveryLocation: 'Hangar Spedizione Polare Deadhorse [MP 414]',
      restorationCost: { scrap_metal: 85, electronics: 30, armor_plate: 1, graphene_battery: 1 },
      restorationStory: 'La leggenda dei 6 titoli mondiali rally costruttori consecutivi. Nascosta nell\'hangar terminale di Deadhorse sul Mar Glaciale Artico. Trasferisce 210 CV alle 4 ruote con un equilibrio sovrannaturale.'
    },

    mercedes_w123: {
      id: 'mercedes_w123',
      name: 'W123 300TD Turbodiesel Wagon',
      maker: 'Mercedes-Benz',
      year: 1980,
      country: 'Germania',
      flag: '🇩🇪',
      category: 'Station Wagon Indistruttibile',
      engine: '3.0L OM617 5 Cilindri Turbodiesel',
      cylinders: 5,
      displacementCc: 2998,
      powerHp: 125,
      torqueNm: 250,
      redlineRpm: 4600,
      idleRpm: 750,
      topSpeedKmh: 170,
      weightKg: 1620,
      drivetrain: 'RWD',
      drivetrainBadge: 'RWD DIFFERENZIALE POST.',
      hasTurbo: true,
      turboBoostMaxBar: 0.8,
      isDiesel: true,
      fuelType: 'gasolio',
      fuelTankL: 72,
      fuelConsumptionRate: 0.032,
      trunkCapacityKg: 165,
      tractionBonus: 0.88,
      handling: {
        agility: 0.85,
        oversteerTendency: 0.45,
        stability: 1.1,
        brakeForce: 34.0,
        groundClearance: 0.17,
        bodyRollFactor: 0.32
      },
      dashTheme: {
        style: 'vdo_mercedes_classic',
        speedoMax: 200,
        redlineRpm: 4600,
        clusterName: 'VDO STUTTGART CLASSIC',
        dialBg: '#131518',
        tickColor: '#e2e8f0',
        needleColor: '#fb923c',
        accentColor: '#f59e0b',
        hasGlowPlug: true,
        hasTurboGauge: true
      },
      soundProfile: {
        baseFreq: 33,
        timbre: 'om617_diesel_5cyl',
        cylinders: 5,
        turboWhistle: 0.4,
        dieselKnock: 0.75
      },
      description: 'L\'apice della longevità ingegneristica tedesca: il 5 cilindri OM617 turbodiesel con pompa iniezione Bosch meccanica è capace di superare un milione di chilometri senza revisioni anche con carburanti impuri.',
      tacticalDaltonAdvice: 'Il bagagliaio immenso (165 kg) e il grande serbatoio consentono lunghissime tratte senza rifornimenti. Trazione posteriore: richiede cautela sulle salite innevate dell\'Atigun Pass.',
      tier: 2,
      unlockType: 'barn_find',
      discoveryPK: 850,
      discoveryLocation: 'Scalo Chiatte del Fiume Yukon [MP 56]',
      restorationCost: { scrap_metal: 35, engine_oil: 1, cured_timber: 2 },
      restorationStory: 'Portata in Alaska da un appaltatore della Alyeska Pipeline nel 1980. Il 5 cilindri turbodiesel OM617 da un milione di chilometri è intorpidito dal gelo; con olio fresco e puntelli in legno torna a marciare.'
    },

    mercedes_gwagen: {
      id: 'mercedes_gwagen',
      name: 'G-Klasse W460 280 GE',
      maker: 'Mercedes-Benz',
      year: 1979,
      country: 'Germania / Austria',
      flag: '🇩🇪',
      category: 'Fuoristrada Militare Longheroni',
      engine: '2.8L M110 DOHC 6 Cilindri in linea',
      cylinders: 6,
      displacementCc: 2746,
      powerHp: 156,
      torqueNm: 226,
      redlineRpm: 6000,
      idleRpm: 800,
      topSpeedKmh: 155,
      weightKg: 1980,
      drivetrain: '4WD_MANUAL',
      drivetrainBadge: '3x DIFF LOCK MECCANICO',
      hasTurbo: false,
      turboBoostMaxBar: 0,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 68,
      fuelConsumptionRate: 0.042,
      trunkCapacityKg: 150,
      tractionBonus: 1.3,
      handling: {
        agility: 0.78,
        oversteerTendency: 0.2,
        stability: 1.05,
        brakeForce: 33.0,
        groundClearance: 0.23,
        bodyRollFactor: 0.35
      },
      dashTheme: {
        style: 'vdo_mercedes_military',
        speedoMax: 200,
        redlineRpm: 6000,
        clusterName: 'VDO OFF-ROAD INSTRUMENTS',
        dialBg: '#111417',
        tickColor: '#cbd5e1',
        needleColor: '#ef4444',
        accentColor: '#3b82f6',
        hasGlowPlug: false,
        hasTurboGauge: false
      },
      soundProfile: {
        baseFreq: 36,
        timbre: 'm110_inline6',
        cylinders: 6,
        turboWhistle: 0.0,
        dieselKnock: 0.0
      },
      description: 'Sviluppato per specifiche militari con telaio a longheroni e ponti rigidi guidati da bracci longitudinali. Equipaggiato con tre blocchi meccanici al 100% per i differenziali anteriore, centrale e posteriore.',
      tacticalDaltonAdvice: 'Arrampica su pietraie franose e tronchi con disinvoltura assoluta. Il peso di quasi due tonnellate penalizza i consumi e richiede frenate anticipate nelle discese viscide.',
      tier: 3,
      unlockType: 'barn_find',
      discoveryPK: 5000,
      discoveryLocation: 'Cava Frantumatori di Atigun Pass [MP 290]',
      restorationCost: { scrap_metal: 65, electronics: 20, reinforced_coil: 1 },
      restorationStory: 'Veicolo di soccorso alpino del Dipartimento Trasporti dell\'Alaska. I tre blocchi meccanici al 100% permettono di scalare le rampe del 12% dell\'Atigun Pass non appena montata una molla rinforzata.'
    },

    defender_110: {
      id: 'defender_110',
      name: 'Defender 110 200Tdi',
      maker: 'Land Rover',
      year: 1990,
      country: 'Regno Unito',
      flag: '🇬🇧',
      category: 'Spedizione Overland Artica',
      engine: '2.5L 200Tdi Turbodiesel Iniezione Diretta',
      cylinders: 4,
      displacementCc: 2495,
      powerHp: 111,
      torqueNm: 264,
      redlineRpm: 4400,
      idleRpm: 750,
      topSpeedKmh: 130,
      weightKg: 2050,
      drivetrain: '4WD_MANUAL',
      drivetrainBadge: 'PERMANENT 4WD + DIFF-LOCK',
      hasTurbo: true,
      turboBoostMaxBar: 0.9,
      isDiesel: true,
      fuelType: 'gasolio',
      fuelTankL: 80,
      fuelConsumptionRate: 0.034,
      trunkCapacityKg: 180,
      tractionBonus: 1.32,
      handling: {
        agility: 0.72,
        oversteerTendency: 0.15,
        stability: 1.0,
        brakeForce: 32.0,
        groundClearance: 0.25,
        bodyRollFactor: 0.38
      },
      dashTheme: {
        style: 'lucas_smiths_offroad',
        speedoMax: 150,
        redlineRpm: 4500,
        clusterName: 'SMITHS EXPEDITION GAUGES',
        dialBg: '#151914',
        tickColor: '#86efac',
        needleColor: '#22c55e',
        accentColor: '#16a34a',
        hasGlowPlug: true,
        hasTurboGauge: true
      },
      soundProfile: {
        baseFreq: 31,
        timbre: 'landrover_diesel_tdi',
        cylinders: 4,
        turboWhistle: 0.45,
        dieselKnock: 0.8
      },
      description: 'Icona dell\'esplorazione globale: carrozzeria in alluminio Birmabright resistente alla ruggine, snorkel di aspirazione montato sul montante A e riduttore transfer case LT230 con blocco centrale.',
      tacticalDaltonAdvice: 'Massima capacità di carico del corridoio (180 kg) e resistenza insuperabile all\'acqua e ai guadi. Sterzo pesante e andatura lenta ma inarrestabile.',
      tier: 3,
      unlockType: 'barn_find',
      discoveryPK: 4200,
      discoveryLocation: 'Staging Depot Minatori di Wiseman [MP 265]',
      restorationCost: { scrap_metal: 60, cured_timber: 3, toolkit: 1, spare_tire: 1 },
      restorationStory: 'Veterana della Royal Geographical Society abbandonata dopo un crollo sulla pista. La carrozzeria in alluminio Birmabright non ha un filo di ruggine; 180 kg di portata e riduttore con blocco differenziale.'
    },

    volvo_245: {
      id: 'volvo_245',
      name: '245 Polar Estate B230',
      maker: 'Volvo',
      year: 1988,
      country: 'Svezia',
      flag: '🇸🇪',
      category: 'Wagon Artica di Sicurezza',
      engine: '2.3L B230 "Redblock" Iniezione LH-Jetronic',
      cylinders: 4,
      displacementCc: 2316,
      powerHp: 115,
      torqueNm: 185,
      redlineRpm: 6000,
      idleRpm: 800,
      topSpeedKmh: 175,
      weightKg: 1390,
      drivetrain: 'RWD',
      drivetrainBadge: 'RWD PONTE RIGIDO DANA 30',
      hasTurbo: false,
      turboBoostMaxBar: 0,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 60,
      fuelConsumptionRate: 0.031,
      trunkCapacityKg: 150,
      tractionBonus: 0.94,
      handling: {
        agility: 0.95,
        oversteerTendency: 0.4,
        stability: 1.2,
        brakeForce: 36.0,
        groundClearance: 0.17,
        bodyRollFactor: 0.22
      },
      dashTheme: {
        style: 'yazaki_volvo_nordic',
        speedoMax: 200,
        redlineRpm: 6000,
        clusterName: 'YAZAKI GÖTEBORG INSTRUMENTS',
        dialBg: '#12171c',
        tickColor: '#93c5fd',
        needleColor: '#38bdf8',
        accentColor: '#0284c7',
        hasGlowPlug: false,
        hasTurboGauge: false
      },
      soundProfile: {
        baseFreq: 37,
        timbre: 'volvo_redblock_4cyl',
        cylinders: 4,
        turboWhistle: 0.0,
        dieselKnock: 0.0
      },
      description: 'Il celebre "carro armato svedese" progettato per sopravvivere agli inverni scandinavi. Dotato di paraurti telescopici assorbitori, riscaldamento abitacolo ad alta efficienza e motore Redblock con tolleranze eterne.',
      tacticalDaltonAdvice: 'Eccellente stabilità su permafrost e fondo ghiacciato grazie al bilanciamento 50:50. Telaio robustissimo contro gli impatti da animali selvatici e detriti montani.',
      tier: 1,
      unlockType: 'barn_find',
      discoveryPK: 350,
      discoveryLocation: 'Miniera e Draga d\'Oro di Livengood [MP 14]',
      restorationCost: { scrap_metal: 25, spare_tire: 1 },
      restorationStory: 'Appartenuta a un geologo svedese nel 1988. Il celebre motore Redblock B230 è intatto sotto un telo incerato; servono una gomma di scorta e rottami per fissare i manicotti.'
    },

    audi_quattro: {
      id: 'audi_quattro',
      name: 'Ur-Quattro 20V Turbo',
      maker: 'Audi',
      year: 1989,
      country: 'Germania',
      flag: '🇩🇪',
      category: 'Coupé Gran Turismo Integrale',
      engine: '2.2L 5 Cilindri 20V Turbo KKK K24',
      cylinders: 5,
      displacementCc: 2226,
      powerHp: 220,
      torqueNm: 309,
      redlineRpm: 7200,
      idleRpm: 900,
      topSpeedKmh: 230,
      weightKg: 1380,
      drivetrain: 'AWD_TORSEN',
      drivetrainBadge: 'QUATTRO TORSEN + DIFF-LOCK',
      hasTurbo: true,
      turboBoostMaxBar: 1.6,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 70,
      fuelConsumptionRate: 0.046,
      trunkCapacityKg: 100,
      tractionBonus: 1.34,
      handling: {
        agility: 1.1,
        oversteerTendency: 0.2,
        stability: 1.25,
        brakeForce: 38.0,
        groundClearance: 0.15,
        bodyRollFactor: 0.18
      },
      dashTheme: {
        style: 'audi_sport_orange',
        speedoMax: 260,
        redlineRpm: 7200,
        clusterName: 'AUDI SPORT INGOLSTADT',
        dialBg: '#101014',
        tickColor: '#fb923c',
        needleColor: '#f97316',
        accentColor: '#ef4444',
        hasGlowPlug: false,
        hasTurboGauge: true
      },
      soundProfile: {
        baseFreq: 40,
        timbre: 'audi_5cyl_turbo',
        cylinders: 5,
        turboWhistle: 0.8,
        dieselKnock: 0.0
      },
      description: 'La vettura che ha rivoluzionato il motorsport introducendo la trazione integrale permanente nelle competizioni. Motore 5 cilindri turbo dal sound inconfondibile, passaruota bombati e trazione totale permanente Torsen.',
      tacticalDaltonAdvice: 'Velocità impressionante e tenuta sui curvoni del Chandalar Shelf. Richiede attenzione al sottosterzo iniziale all\'ingresso delle curve strette.',
      tier: 4,
      unlockType: 'barn_find',
      discoveryPK: 5800,
      discoveryLocation: 'Continental Divide High Camp - Valico 1.444m [MP 310]',
      restorationCost: { scrap_metal: 75, electronics: 25, cryo_coolant: 1 },
      restorationStory: 'Monumento del rallysmo Group B, collaudata dalla divisione Audi Sport sui ghiacci artici nel 1989. Il 5 cilindri 20V turbo KKK K24 è intatto; con liquido antigelo polare e rottami domina le bufere.'
    },

    bmw_e30_ix: {
      id: 'bmw_e30_ix',
      name: '325iX Touring E30',
      maker: 'BMW',
      year: 1988,
      country: 'Germania',
      flag: '🇩🇪',
      category: 'Sport Wagon Trazione Integrale',
      engine: '2.5L M20B25 6 Cilindri in linea SOHC',
      cylinders: 6,
      displacementCc: 2494,
      powerHp: 170,
      torqueNm: 222,
      redlineRpm: 6600,
      idleRpm: 850,
      topSpeedKmh: 210,
      weightKg: 1310,
      drivetrain: 'AWD_VISCOUS',
      drivetrainBadge: 'ALLRAD 37:63 VISCOUS',
      hasTurbo: false,
      turboBoostMaxBar: 0,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 55,
      fuelConsumptionRate: 0.038,
      trunkCapacityKg: 110,
      tractionBonus: 1.18,
      handling: {
        agility: 1.22,
        oversteerTendency: 0.35,
        stability: 1.15,
        brakeForce: 36.0,
        groundClearance: 0.15,
        bodyRollFactor: 0.2
      },
      dashTheme: {
        style: 'bmw_amber_classic',
        speedoMax: 240,
        redlineRpm: 6600,
        clusterName: 'BMW MOTORENWERKE MÜNCHEN',
        dialBg: '#131110',
        tickColor: '#fdba74',
        needleColor: '#ea580c',
        accentColor: '#f97316',
        hasGlowPlug: false,
        hasTurboGauge: false
      },
      soundProfile: {
        baseFreq: 38,
        timbre: 'bmw_m20_inline6',
        cylinders: 6,
        turboWhistle: 0.0,
        dieselKnock: 0.0
      },
      description: 'La prima serie 3 a quattro ruote motrici con ripartizione della coppia al 37% anteriore e 63% posteriore tramite giunto viscoso epicicloidale. Preserva l\'agilità dinamica tipica BMW su neve e fango.',
      tacticalDaltonAdvice: 'Dinamica di guida esaltante sui fondi a bassa aderenza con sovrasterzo facilmente gestibile. Il telaio touring offre un buon compromesso tra sportività e capacità di carico.',
      tier: 3,
      unlockType: 'barn_find',
      discoveryPK: 2800,
      discoveryLocation: 'Base Radar White Alice - Circolo Polare [MP 200]',
      restorationCost: { scrap_metal: 50, electronics: 18, graphene_battery: 1 },
      restorationStory: 'Utilizzata dagli ufficiali di collegamento della stazione radar durante la Guerra Fredda. La trazione Allrad viscosa 37:63 è pronta a ruggire appena collegata a un accumulatore al grafene.'
    },

    alfa_giulia: {
      id: 'alfa_giulia',
      name: 'Giulia Super 1.6 "Biscione"',
      maker: 'Alfa Romeo',
      year: 1967,
      country: 'Italia',
      flag: '🇮🇹',
      category: 'Berlina Sportiva d\'Epoca',
      engine: '1.6L Bialbero Twin-Cam 2x Weber 40 DCOE',
      cylinders: 4,
      displacementCc: 1570,
      powerHp: 112,
      torqueNm: 150,
      redlineRpm: 6800,
      idleRpm: 900,
      topSpeedKmh: 178,
      weightKg: 1020,
      drivetrain: 'RWD',
      drivetrainBadge: 'RWD BIALBERO SPORT',
      hasTurbo: false,
      turboBoostMaxBar: 0,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 46,
      fuelConsumptionRate: 0.029,
      trunkCapacityKg: 85,
      tractionBonus: 0.82,
      handling: {
        agility: 1.3,
        oversteerTendency: 0.65,
        stability: 0.9,
        brakeForce: 32.0,
        groundClearance: 0.15,
        bodyRollFactor: 0.26
      },
      dashTheme: {
        style: 'veglia_biscione_vintage',
        speedoMax: 200,
        redlineRpm: 7000,
        clusterName: 'VEGLIA BORLETTI MILANO 1967',
        dialBg: '#0e1114',
        tickColor: '#f1f5f9',
        needleColor: '#ffffff',
        accentColor: '#10b981',
        hasGlowPlug: false,
        hasTurboGauge: false
      },
      soundProfile: {
        baseFreq: 44,
        timbre: 'bialbero_carb_4cyl',
        cylinders: 4,
        turboWhistle: 0.0,
        dieselKnock: 0.0
      },
      description: '"Disegnata dal vento": carrozzeria aerodinamica a coda tronca (Kamm tail) con motore interamente in alluminio a doppio albero a camme in testa e cambio a 5 rapporti sincronizzati.',
      tacticalDaltonAdvice: 'Sensibilità di sterzo ed accelerazione brillanti grazie al peso di una tonnellata. Trazione posteriore pura con tendenza al sovrasterzo: richiede rispetto sui ponti di ghiaccio.',
      tier: 3,
      unlockType: 'barn_find',
      discoveryPK: 3500,
      discoveryLocation: 'Bivacco Cava di Sukakpak Mountain [MP 240]',
      restorationCost: { scrap_metal: 50, electronics: 15, engine_oil: 2 },
      restorationStory: 'L\'auto personale di un ingegnere italo-americano della Fluor Corp. I due carburatori Weber doppio corpo del bialbero necessitano di pulizia e olio fresco per cantare a 7.000 giri sulle serpentine montane.'
    },

    peugeot_504_dangel: {
      id: 'peugeot_504_dangel',
      name: '504 Dangel 4x4 Break',
      maker: 'Peugeot / Dangel',
      year: 1980,
      country: 'Francia',
      flag: '🇫🇷',
      category: 'Rally-Raid Safari Station Wagon',
      engine: '2.0L XN1 Inclinato a Carburatore',
      cylinders: 4,
      displacementCc: 1971,
      powerHp: 96,
      torqueNm: 160,
      redlineRpm: 5500,
      idleRpm: 800,
      topSpeedKmh: 145,
      weightKg: 1480,
      drivetrain: '4WD_MANUAL',
      drivetrainBadge: '4WD DANGEL HEAVY-DUTY',
      hasTurbo: false,
      turboBoostMaxBar: 0,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 60,
      fuelConsumptionRate: 0.033,
      trunkCapacityKg: 145,
      tractionBonus: 1.25,
      handling: {
        agility: 0.9,
        oversteerTendency: 0.2,
        stability: 1.1,
        brakeForce: 33.0,
        groundClearance: 0.22,
        bodyRollFactor: 0.32
      },
      dashTheme: {
        style: 'jaeger_french_safari',
        speedoMax: 180,
        redlineRpm: 6000,
        clusterName: 'JAEGER FRANCE OFF-ROAD',
        dialBg: '#131416',
        tickColor: '#e2e8f0',
        needleColor: '#f59e0b',
        accentColor: '#eab308',
        hasGlowPlug: false,
        hasTurboGauge: false
      },
      soundProfile: {
        baseFreq: 35,
        timbre: 'peugeot_xn1_4cyl',
        cylinders: 4,
        turboWhistle: 0.0,
        dieselKnock: 0.0
      },
      description: 'Elaborata da Henry Dangel a Sentheim: telaio rialzato di 22 cm, scatola di rinvio a due velocità con bloccaggio differenziale centrale e sospensioni a lunga escursione nate per i safari africani.',
      tacticalDaltonAdvice: 'Assorbe buche, ciottoli e solchi profondi senza alcuna fatica. Geometria eccellente per superare la pietraia dell\'Atigun Pass e le banchine dissestate dello Yukon.',
      tier: 2,
      unlockType: 'barn_find',
      discoveryPK: 2200,
      discoveryLocation: 'Stazione Idrovore Koyukuk TAPS [MP 145]',
      restorationCost: { scrap_metal: 45, waterproofing_wax: 1, toolkit: 1 },
      restorationStory: 'Ex vettura di supporto della Parigi-Dakar 1980 importata per collaudi polari estremi. La straordinaria luce a terra di 22 cm la rende invincibile sul muskeg una volta sigillati i giunti con cera.'
    },

    golf_country: {
      id: 'golf_country',
      name: 'Golf II Country Syncro',
      maker: 'Volkswagen',
      year: 1990,
      country: 'Germania / Austria',
      flag: '🇩🇪',
      category: 'Crossover Rallye Syncro',
      engine: '1.8L Digifant 8V Iniezione Elettronica',
      cylinders: 4,
      displacementCc: 1781,
      powerHp: 98,
      torqueNm: 143,
      redlineRpm: 6200,
      idleRpm: 850,
      topSpeedKmh: 162,
      weightKg: 1245,
      drivetrain: 'AWD_VISCOUS',
      drivetrainBadge: 'SYNCRO VISCOUS AWD',
      hasTurbo: false,
      turboBoostMaxBar: 0,
      isDiesel: false,
      fuelType: 'benzina',
      fuelTankL: 55,
      fuelConsumptionRate: 0.029,
      trunkCapacityKg: 105,
      tractionBonus: 1.16,
      handling: {
        agility: 1.15,
        oversteerTendency: 0.15,
        stability: 1.05,
        brakeForce: 34.0,
        groundClearance: 0.21,
        bodyRollFactor: 0.26
      },
      dashTheme: {
        style: 'vdo_golf_syncro',
        speedoMax: 220,
        redlineRpm: 6200,
        clusterName: 'VDO WOLFSBURG DIGIFANT',
        dialBg: '#0f1316',
        tickColor: '#4ade80',
        needleColor: '#22c55e',
        accentColor: '#16a34a',
        hasGlowPlug: false,
        hasTurboGauge: false
      },
      soundProfile: {
        baseFreq: 41,
        timbre: 'vw_digifant_4cyl',
        cylinders: 4,
        turboWhistle: 0.0,
        dieselKnock: 0.0
      },
      description: 'Prodotta in collaborazione con Steyr-Daimler-Puch a Graz: scocca di Golf II montata su un controtelaio tubolare con altezza da terra di 21 cm, piastre paramotore e ruota di scorta esterna basculante.',
      tacticalDaltonAdvice: 'Il giunto viscoso trasferisce istantaneamente la trazione al posteriore quando le ruote anteriori perdono aderenza sul fango o sulla fanghiglia mista a neve.',
      tier: 2,
      unlockType: 'barn_find',
      discoveryPK: 1500,
      discoveryLocation: 'Officina Camionisti di Coldfoot Camp [MP 115]',
      restorationCost: { scrap_metal: 40, electronics: 12, spare_tire: 1 },
      restorationStory: 'Acquistata da un pilota di bush-plane austriaco per raggiungere le piste isolate. Il telaio tubolare rialzato Syncro è in condizioni impeccabili; bastano pochi cablaggi e una gomma nuova.'
    }
  },

  // Vehicle Parameters (Dynamic default mapped to default vehicle)
  VEHICLE: {
    ACCELERATION: 18.0,
    BRAKE_FORCE: 32.0,
    MAX_SPEED_KMH: 140,
    REVERSE_MAX_SPEED: 35,
    TURN_SPEED: 2.2,
    DRIFT_RECOVERY: 4.5,
    FUEL_CONSUMPTION_RATE: 0.035, // L/sec at full throttle
    IDLE_FUEL_RATE: 0.005,
    OVERHEAT_RATE: 0.08,
    COOLING_RATE: 0.05,
    BATTERY_DRAIN_LIGHTS: 0.02,
    BATTERY_CHARGE_RATE: 0.04,
  },

  // Player On Foot
  PLAYER_FOOT: {
    WALK_SPEED: 4.5,
    SPRINT_SPEED: 8.5,
    STAMINA_DRAIN: 15.0,
    STAMINA_RECOVERY: 20.0,
    INTERACT_RADIUS: 4.0,
  },

  // Survival baseline
  SURVIVAL: {
    MAX_HEALTH: 100,
    MAX_STAMINA: 100,
    MAX_HUNGER: 100,
    MAX_THIRST: 100,
    MAX_HEAT: 100,
    HUNGER_RATE: 0.04,   // per sec
    THIRST_RATE: 0.08,
    FREEZING_TEMP_DAMAGE: 1.5,
    TOXIC_DAMAGE: 2.0,
  },

  // Points of Interest (POIs) - Structured by real-world Dalton Highway infrastructure
  POI_TYPES: {
    SETTLEMENT_HUB: {
      name: 'Insediamento e Stazione di Scambio',
      icon: '🏘️',
      isSettlement: true,
      lootTable: [], // Trade hub, not simple scavenge
      dangerLevel: 0.05
    },
    COASTAL_FISHERY_RUIN: {
      name: 'Vecchia Tonnara & Rimessa Motoscafi Costiera',
      icon: '⚓',
      biomeId: 'mediterranean_coast',
      lootTable: ['refined_fuel', 'engine_oil', 'scrap_metal', 'water_purified'],
      dangerLevel: 0.2,
      loreNote: 'Antico magazzino marinaro affacciato sulle scogliere. Tra le reti da pesca ci sono taniche di benzina marina e filtri decantatori intatti.'
    },
    FORESTRY_LUMBER_YARD: {
      name: 'Segheria Idraulica & Deposito Faggi',
      icon: '🪵',
      biomeId: 'temperate_forest',
      lootTable: ['cured_timber', 'antiseptic_resin', 'first_aid_bandage', 'toolkit'],
      dangerLevel: 0.2,
      loreNote: 'Accatastamento di travi di quercia e faggio stagionato. Sotto la tettoia i mastri boscaioli hanno lasciato casse di attrezzi e resine sigillanti.'
    },
    DESERT_CARAVAN_POST: {
      name: 'Forte Carovaniero & Cisterna delle Dune',
      icon: '🌴',
      biomeId: 'arid_desert',
      lootTable: ['water_purified', 'waterproofing_wax', 'fuel_canister', 'spare_tire'],
      dangerLevel: 0.35,
      loreNote: 'Antico presidio carovaniero tra le sabbie del Sahara. La cisterna sotterranea protegge preziose taniche d\'acqua e teli termoriflettenti.'
    },
    SAVANNA_RANGER_STATION: {
      name: 'Torretta di Vedetta & Deposito Ranger del Bush',
      icon: '🦁',
      biomeId: 'savanna_steppe',
      lootTable: ['reinforced_coil', 'armor_plate', 'toolkit', 'canned_stew'],
      dangerLevel: 0.3,
      loreNote: 'Stazione dei guardaparco della savana. Nell\'armeria e nell\'officina si trovano balestre rinforzate e lamiere d\'acciaio per rinforzare il pianale.'
    },
    JUNGLE_BOTANICAL_LAB: {
      name: 'Stazione Idrologica & Scalo Rio Verde',
      icon: '🌿',
      biomeId: 'tropical_rainforest',
      lootTable: ['peat_filter', 'waterproofing_wax', 'antiseptic_resin', 'spare_tire'],
      dangerLevel: 0.4,
      loreNote: 'Laboratorio palafittato di ricerca idrologica. I filtri a torba e le cere impermeabilizzanti per i circuiti elettrici sono ancora sigillati.'
    },
    ALPINE_TUNNEL_SHELTER: {
      name: 'Galleria Paravalanghe & Cava del Valico',
      icon: '🏔️',
      biomeId: 'alpine_peaks',
      lootTable: ['tungsten_drill_bit', 'reinforced_coil', 'armor_plate', 'scrap_metal'],
      dangerLevel: 0.45,
      loreNote: 'Riparo scavato nella parete granitica per i cantonieri del passo. Si possono recuperare inserti al tungsteno e balestre speciali da salita.'
    },
    TAIGA_LOGGING_DEPOT: {
      name: 'Scalo Zattere & Deposito Conifere della Taiga',
      icon: '🌲',
      biomeId: 'boreal_taiga',
      lootTable: ['cured_timber', 'cryo_coolant', 'thermal_lining', 'toolkit'],
      dangerLevel: 0.35,
      loreNote: 'Piazzale di smistamento tronchi lungo il fiume gelato. Nelle casse stagne ci sono flaconi di glicole criogenico e coperte termiche.'
    },
    POLAR_METAR_SHELTER: {
      name: 'Capsula Rifugio Polare 80° Parallelo',
      icon: '❄️',
      biomeId: 'polar_tundra',
      lootTable: ['cryo_coolant', 'thermal_lining', 'electronics', 'water_purified'],
      dangerLevel: 0.5,
      loreNote: 'Modulo geodetico del consorzio polare. Custodisce sensori satellitari schermati e fluido antigelo artico in grado di reggere a -55°C.'
    },
    OVERTURNED_CONVOY: {
      name: 'Autocarro da Spedizione Ribaltato',
      icon: '🚛',
      lootTable: ['fuel_canister', 'spare_tire', 'toolkit', 'scrap_metal'],
      dangerLevel: 0.4,
      loreNote: 'Un camion del convoglio precedente è uscito di carreggiata. Nel vano di carico ci sono carburante di riserva e ruote di scorta ancora gonfie.'
    },
    MILITARY_CHECKPOINT: {
      name: 'Posto di Blocco & Stazione Radio Transcontinentale',
      icon: '🚧',
      lootTable: ['ammo_flare', 'armor_plate', 'medkit', 'canned_stew'],
      dangerLevel: 0.45,
      loreNote: 'Barriera di confine con antenna ricetrasmittente d\'emergenza. All\'interno si trovano razzi di segnalazione e razioni alimentari.'
    }
  },

  // Modular Engineering Upgrades (4 Branches: Chassis, Powertrain, Armor, Avionics)
  UPGRADES: {
    // 1. ASSETTO & TRAZIONE (Chassis & Grip)
    STUDDED_TIRES: {
      id: 'studded_tires',
      category: 'chassis',
      categoryName: 'Assetto & Trazione',
      icon: '🛞',
      name: 'Pneumatici Chiodati Nokian Hakkapeliitta',
      cost: { scrap_metal: 25, spare_tire: 1 },
      desc: '+35% aderenza su ghiaccio e permafrost; riduce del 25% la distanza di arresto su fondo scivoloso.',
      statLabel: '+35% Grip Ghiaccio & Neve'
    },
    RALLY_SUSPENSION: {
      id: 'rally_suspension',
      category: 'chassis',
      categoryName: 'Assetto & Trazione',
      icon: '🌀',
      name: 'Assetto Rialzato Bilstein & Molle Heavy-Duty',
      cost: { scrap_metal: 35, toolkit: 1 },
      desc: '+5 cm luce libera a terra; assorbe il 65% dei danni da buche e dossi ed elimina l\'affossamento sulla ghiaia.',
      statLabel: '+5cm Luce / -65% Danni Buche'
    },
    DIFF_LOCK_LSD: {
      id: 'diff_lock_lsd',
      category: 'chassis',
      categoryName: 'Assetto & Trazione',
      icon: '⚙️',
      name: 'Differenziale Autobloccante Meccanico LSD',
      cost: { scrap_metal: 45, electronics: 15, engine_oil: 1 },
      desc: 'Elimina lo slittamento della ruota scarica sui fondi misti asfalto/neve/fango; +20% spinta e tenuta in accelerazione.',
      statLabel: '+20% Trazione Coppia Mista'
    },

    // 2. MOTORE & TERMO (Powertrain & Cold Weather)
    BLOCK_HEATER: {
      id: 'block_heater',
      category: 'engine',
      categoryName: 'Motore & Termo',
      icon: '🔥',
      name: 'Preriscaldatore Ausiliario Webasto Polare',
      cost: { scrap_metal: 30, fuel_canister: 1, electronics: 10 },
      desc: 'Mantiene il blocco motore a 45°C anche a -40°C esterni; azzera l\'usura delle partenze a freddo e il consumo batteria.',
      statLabel: 'Partenza Istantanea a -40°C'
    },
    COPPER_RADIATOR: {
      id: 'copper_radiator',
      category: 'engine',
      categoryName: 'Motore & Termo',
      icon: '❄️',
      name: 'Radiatore Maggiorato in Rame a 3 Fila',
      cost: { scrap_metal: 35, engine_oil: 1 },
      desc: 'Dimezza il surriscaldamento sotto sforzo continuo; impedisce il congelamento del liquido antigelo nei valichi montani.',
      statLabel: 'Raffreddamento Rame Stabile 80°C'
    },
    TURBO_BOOST_KIT: {
      id: 'turbo_boost_kit',
      category: 'engine',
      categoryName: 'Motore & Termo',
      icon: '💨',
      name: 'Kit Intercooler & Wastegate da Gara',
      cost: { scrap_metal: 50, electronics: 20 },
      desc: '+0.35 Bar di pressione di sovralimentazione massima (+18% spinta e accelerazione); scarico pop-off e fischio turbo amplificati.',
      statLabel: '+0.35 Bar Boost Turbo & +18% Spinta'
    },
    SNORKEL_INTAKE: {
      id: 'snorkel_intake',
      category: 'engine',
      categoryName: 'Motore & Termo',
      icon: '🤿',
      name: 'Snorkel con Prefiltro Polveri Ciclonico',
      cost: { scrap_metal: 25, toolkit: 1 },
      desc: 'Aspirazione alta sul montante del tetto: consente di guadare acquitrini e fiumi allagati proteggendo il motore da fango e sabbia.',
      statLabel: 'Guado Acqua & Protezione Filtri'
    },

    // 3. TELAIO & AUTONOMIA (Armor & Range)
    SKID_PLATE: {
      id: 'skid_plate',
      category: 'armor',
      categoryName: 'Telaio & Autonomia',
      icon: '🛡️',
      name: 'Slitta Paracoppa in Duralluminio Forgiato',
      cost: { scrap_metal: 35, armor_plate: 1 },
      desc: 'Protegge coppa dell\'olio, campana frizione e scarico; dimezza i danni da impatto con sassi, massi caduti e cunette.',
      statLabel: '-50% Danno da Pietrisco & Massi'
    },
    HEAVY_BULLBAR: {
      id: 'heavy_bullbar',
      category: 'armor',
      categoryName: 'Telaio & Autonomia',
      icon: '🦬',
      name: 'Rostro Frontale Corazzato Spingitutto',
      cost: { scrap_metal: 45, toolkit: 1 },
      desc: 'Riduce del 70% i danni da impatto frontale; demolisce fusti di cantiere e tronchi leggeri senza arrestare la marcia.',
      statLabel: '-70% Danno Frontale / Spinta Ostacoli'
    },
    AUX_FUEL_CELL: {
      id: 'aux_fuel_cell',
      category: 'armor',
      categoryName: 'Telaio & Autonomia',
      icon: '⛽',
      name: 'Serbatoio Ausiliario Coibentato (+40L)',
      cost: { scrap_metal: 40, fuel_canister: 2 },
      desc: 'Aggiunge un serbatoio ausiliario blindato da 40 litri, raddoppiando l\'autonomia nei lunghi tratti deserti della Haul Road.',
      statLabel: '+40 Litri Serbatoio Carburante'
    },
    ROOF_CARGO_RACK: {
      id: 'roof_cargo_rack',
      category: 'armor',
      categoryName: 'Telaio & Autonomia',
      icon: '📦',
      name: 'Portapacchi da Tetto Expedition Heavy-Duty',
      cost: { scrap_metal: 30, cured_timber: 2 },
      desc: 'Struttura tubolare aerodinamica sul padiglione: aumenta la portata massima di carico del bagagliaio di +45 kg su qualsiasi vettura.',
      statLabel: '+45 kg Capacità Bagagliaio'
    },

    // 4. AVIONICA & VISIONE (Avionics & Optics)
    RALLY_LIGHT_BAR: {
      id: 'rally_light_bar',
      category: 'avionics',
      categoryName: 'Avionica & Visione',
      icon: '💡',
      name: 'Barra 4 Fari di Profondità Hella Rally 2000',
      cost: { scrap_metal: 30, electronics: 20 },
      desc: 'Raddoppia la gittata dei fari fino a 70 metri con fascio allargato; fende la nebbia fitta, le bufere di neve e la notte polare.',
      statLabel: 'Gittata Fari 70m Fascio Largo'
    },
    CB_RADAR_SCANNER: {
      id: 'cb_radar_scanner',
      category: 'avionics',
      categoryName: 'Avionica & Visione',
      icon: '📡',
      name: 'Radio CB Dalton Convoy & Georadar Ostacoli',
      cost: { scrap_metal: 35, electronics: 25 },
      desc: 'Scansiona la carreggiata e notifica con segnale acustico e allarme visivo sulla plancia gli ostacoli e le buche con 120m di anticipo.',
      statLabel: 'Radar Ostacoli & Allarme CB 120m'
    },
    AGM_DUAL_BATTERY: {
      id: 'agm_dual_battery',
      category: 'avionics',
      categoryName: 'Avionica & Visione',
      icon: '🔋',
      name: 'Doppia Batteria AGM al Gel Deep-Cycle',
      cost: { scrap_metal: 25, electronics: 15 },
      desc: 'Capacità elettrica raddoppiata e ricarica ultra-rapida; immunità totale ai cali di tensione e blackout delle tempeste ioniche.',
      statLabel: 'Immunità Elettrica & 2x Ricarica'
    },

    // Backwards compatibility aliases
    BULLBAR: { id: 'heavy_bullbar', name: 'Rostro Frontale Corazzato', cost: { scrap_metal: 45, toolkit: 1 }, desc: 'Riduce del 70% i danni frontali al veicolo e demolisce ostacoli leggeri.', statLabel: '-70% Danno Frontale' },
    ROOF_LIGHTS: { id: 'rally_light_bar', name: 'Barra Fari Ausiliari a LED', cost: { scrap_metal: 30, electronics: 20 }, desc: 'Raddoppia il raggio e l\'ampiezza del fascio luminoso nella nebbia.', statLabel: 'Gittata Fari 70m' },
    OFFROAD_TIRES: { id: 'studded_tires', name: 'Pneumatici Chiodati M+S', cost: { scrap_metal: 25, spare_tire: 1 }, desc: 'Aumenta la trazione su fango (+40%) e ghiaccio (+70%).', statLabel: '+35% Grip Ghiaccio' },
    AUX_TANK: { id: 'aux_fuel_cell', name: 'Serbatoio Ausiliario Blindato', cost: { scrap_metal: 40, fuel_canister: 2 }, desc: 'Aumenta la capienza del carburante da 50L a 90L.', statLabel: '+40L Serbatoio' },
    TURBO_COOLER: { id: 'copper_radiator', name: 'Radiatore Maggiorato ad Aria', cost: { scrap_metal: 35, engine_oil: 1 }, desc: 'Dimezza il surriscaldamento del motore a velocità sostenute.', statLabel: 'Raffreddamento Rame' },
    ARMORED_HULL: { id: 'skid_plate', name: 'Pannelli di Blindatura Composita', cost: { scrap_metal: 35, armor_plate: 1 }, desc: 'Aumenta l\'integrità strutturale del veicolo del 50%.', statLabel: '-50% Danno Sassi' }
  }
};


// --- FILE: src/engine/TextureGenerator.js ---
/**
 * THE LONG MERIDIAN - Procedural Canvas Texture Generator
 * Generates crisp, realistic textures at runtime without external image files.
 */

class TextureGenerator {
  static createAsphaltTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 1024;
    canvas.height = 1024;
    const ctx = canvas.getContext('2d');

    // 1. Base dark bituminous tarmac
    ctx.fillStyle = '#23262a';
    ctx.fillRect(0, 0, 1024, 1024);

    // 2. Graded aggregate mineral grain & micro-noise
    const imgData = ctx.getImageData(0, 0, 1024, 1024);
    const data = imgData.data;
    for (let i = 0; i < data.length; i += 4) {
      // Natural mineral aggregate variation (quartz, basalt, silica)
      const noise = (Math.random() - 0.5) * 32;
      data[i] = Math.min(255, Math.max(0, data[i] + noise));
      data[i + 1] = Math.min(255, Math.max(0, data[i + 1] + noise * 0.95));
      data[i + 2] = Math.min(255, Math.max(0, data[i + 2] + noise * 0.9));
    }
    ctx.putImageData(imgData, 0, 0);

    // 3. Compacted Gravel Shoulders (outer 12% on left and right)
    // Left gravel shoulder (X: 0 to 110)
    const leftGravelGrad = ctx.createLinearGradient(0, 0, 120, 0);
    leftGravelGrad.addColorStop(0, 'rgba(55, 49, 42, 0.95)');
    leftGravelGrad.addColorStop(0.7, 'rgba(50, 44, 38, 0.85)');
    leftGravelGrad.addColorStop(1, 'rgba(40, 36, 32, 0.0)');
    ctx.fillStyle = leftGravelGrad;
    ctx.fillRect(0, 0, 125, 1024);

    // Right gravel shoulder (X: 900 to 1024)
    const rightGravelGrad = ctx.createLinearGradient(900, 0, 1024, 0);
    rightGravelGrad.addColorStop(0, 'rgba(40, 36, 32, 0.0)');
    rightGravelGrad.addColorStop(0.3, 'rgba(50, 44, 38, 0.85)');
    rightGravelGrad.addColorStop(1, 'rgba(55, 49, 42, 0.95)');
    ctx.fillStyle = rightGravelGrad;
    ctx.fillRect(899, 0, 125, 1024);

    // 4. Heavy Vehicle Wheel-Rut Wear Paths (Darker polished bituminous tracks)
    // Left lane wheel ruts (centered around X ~ 240 and X ~ 410)
    // Right lane wheel ruts (centered around X ~ 614 and X ~ 784)
    const rutPositions = [240, 410, 614, 784];
    rutPositions.forEach((rx) => {
      const rutGrad = ctx.createLinearGradient(rx - 45, 0, rx + 45, 0);
      rutGrad.addColorStop(0, 'rgba(16, 18, 20, 0)');
      rutGrad.addColorStop(0.5, 'rgba(14, 16, 18, 0.38)');
      rutGrad.addColorStop(1, 'rgba(16, 18, 20, 0)');
      ctx.fillStyle = rutGrad;
      ctx.fillRect(rx - 45, 0, 90, 1024);
    });

    // 5. Solid White Outer Highway Fog Lines (Strisce continue di margine)
    // Placed at boundary between paved asphalt and gravel shoulder
    ctx.fillStyle = '#f1f5f9';
    ctx.shadowColor = 'rgba(255, 255, 255, 0.35)';
    ctx.shadowBlur = 3;

    // Left continuous edge stripe (X = 126, width 12px)
    ctx.fillRect(124, 0, 14, 1024);
    // Right continuous edge stripe (X = 886, width 12px)
    ctx.fillRect(886, 0, 14, 1024);

    // 6. Vivid Yellow Highway Centerline (Striscia tratteggiata di mezzeria)
    // Centered at X = 506 (width 14px, dash 130px, gap 90px)
    ctx.fillStyle = '#f59e0b';
    ctx.shadowColor = '#d97706';
    ctx.shadowBlur = 5;
    const dashLength = 130;
    const gapLength = 90;
    for (let y = 10; y < 1024; y += dashLength + gapLength) {
      ctx.fillRect(505, y, 14, dashLength);

      // Embedded glass-bead retroreflector dot at head of stripe
      ctx.fillStyle = '#fef08a';
      ctx.beginPath();
      ctx.arc(512, y + 6, 3, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#f59e0b';
    }
    ctx.shadowBlur = 0;

    // 7. Highway Bituminous Tar Crack Repairs (Snake lines of black rubberized sealant)
    ctx.strokeStyle = 'rgba(12, 14, 16, 0.75)';
    ctx.lineWidth = 2.2;
    for (let k = 0; k < 6; k++) {
      ctx.beginPath();
      let startX = 160 + Math.random() * 700;
      let startY = Math.random() * 1024;
      ctx.moveTo(startX, startY);
      for (let s = 0; s < 5; s++) {
        startX += (Math.random() - 0.5) * 45;
        startY += (Math.random() - 0.2) * 35;
        ctx.lineTo(startX, startY);
      }
      ctx.stroke();
    }

    // 8. Occasional Rectangular Asphalt Maintenance Patch
    ctx.fillStyle = 'rgba(28, 31, 35, 0.7)';
    ctx.fillRect(290, 320, 140, 95);
    ctx.strokeStyle = 'rgba(10, 12, 14, 0.85)';
    ctx.lineWidth = 2.0;
    ctx.strokeRect(290, 320, 140, 95);

    // 9. Subtle Faint Oil Drips in Lane Centers
    const dripGrad = ctx.createRadialGradient(325, 680, 4, 325, 680, 35);
    dripGrad.addColorStop(0, 'rgba(10, 12, 14, 0.65)');
    dripGrad.addColorStop(1, 'rgba(10, 12, 14, 0)');
    ctx.fillStyle = dripGrad;
    ctx.fillRect(285, 640, 80, 80);

    const texture = new THREE.CanvasTexture(canvas);
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(1, 4);
    return texture;
  }

  static createTerrainTexture(baseColorHex = '#1a221b') {
    const canvas = document.createElement('canvas');
    canvas.width = 512;
    canvas.height = 512;
    const ctx = canvas.getContext('2d');

    ctx.fillStyle = baseColorHex;
    ctx.fillRect(0, 0, 512, 512);

    const imgData = ctx.getImageData(0, 0, 512, 512);
    const data = imgData.data;
    for (let i = 0; i < data.length; i += 4) {
      // Natural soil, lichen, and moss variation
      const noise = (Math.random() - 0.5) * 40;
      data[i] = Math.min(255, Math.max(0, data[i] + noise * 0.85));
      data[i + 1] = Math.min(255, Math.max(0, data[i + 1] + noise));
      data[i + 2] = Math.min(255, Math.max(0, data[i + 2] + noise * 0.75));
    }
    ctx.putImageData(imgData, 0, 0);

    // Subtle organic moss & heather speckling
    ctx.fillStyle = 'rgba(40, 60, 35, 0.35)';
    for (let j = 0; j < 30; j++) {
      const rx = Math.random() * 512;
      const ry = Math.random() * 512;
      const rad = 8 + Math.random() * 22;
      ctx.beginPath();
      ctx.arc(rx, ry, rad, 0, Math.PI * 2);
      ctx.fill();
    }

    const texture = new THREE.CanvasTexture(canvas);
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(12, 12);
    return texture;
  }

  static createVolumetricBeamTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 128;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');

    const grad = ctx.createLinearGradient(0, 0, 0, 256);
    grad.addColorStop(0, 'rgba(255, 245, 220, 0.45)');
    grad.addColorStop(0.3, 'rgba(255, 240, 200, 0.25)');
    grad.addColorStop(0.8, 'rgba(255, 230, 180, 0.08)');
    grad.addColorStop(1, 'rgba(255, 230, 180, 0)');

    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, 128, 256);

    const texture = new THREE.CanvasTexture(canvas);
    return texture;
  }

  static createMetalTreadTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 64;
    canvas.height = 64;
    const ctx = canvas.getContext('2d');

    ctx.fillStyle = '#2a323d';
    ctx.fillRect(0, 0, 64, 64);

    ctx.fillStyle = '#3f4c5c';
    for (let x = 0; x < 64; x += 16) {
      for (let y = 0; y < 64; y += 16) {
        ctx.fillRect(x + 2, y + 2, 6, 12);
        ctx.fillRect(x + 8, y + 8, 6, 6);
      }
    }

    const texture = new THREE.CanvasTexture(canvas);
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    return texture;
  }
}


// --- FILE: src/engine/WebAudioEngine.js ---
/**
 * THE LONG MERIDIAN - High-Fidelity Procedural Web Audio Synthesizer Engine
 * 100% self-contained sound effects, multi-oscillator internal combustion synthesis,
 * turbo blow-off flutter, surface tire rolling/gravel crunch, exhaust overrun backfires,
 * and dynamic weather soundscapes via the Web Audio API.
 */

function makeDistortionCurve(amount = 25) {
  const n = 2048;
  const curve = new Float32Array(n);
  const deg = Math.PI / 180;
  for (let i = 0; i < n; ++i) {
    const x = (i * 2) / n - 1;
    curve[i] = ((3 + amount) * x * 20 * deg) / (Math.PI + amount * Math.abs(x));
  }
  return curve;
}

class WebAudioEngine {
  constructor() {
    this.ctx = null;
    this.masterGain = null;
    this.isMuted = false;
    this.isInitialized = false;

    // Engine sound nodes & cluster
    this.engineOsc = null;
    this.engineSubOsc = null;
    this.engineHarmonicOsc = null;
    this.engineIntakeGain = null;
    this.engineFilter = null;
    this.engineDistortion = null;
    this.engineGain = null;
    this.turboOsc = null;
    this.turboGain = null;
    this.isEngineRunning = false;

    this.currentProfile = {
      baseFreq: 38,
      timbre: 'raspy_4cyl',
      cylinders: 4,
      turboWhistle: 0.0,
      dieselKnock: 0.0
    };

    // Surface / road rolling sound
    this.surfaceRollNode = null;
    this.surfaceRollFilter = null;
    this.surfaceRollGain = null;
    this.gravelCrunchNode = null;
    this.gravelCrunchFilter = null;
    this.gravelCrunchGain = null;

    // Brake squeal node
    this.brakeSquealOsc = null;
    this.brakeSquealGain = null;

    // Ambient nodes
    this.windNode = null;
    this.windGain = null;
    this.rainNode = null;
    this.rainGain = null;
    this.geigerInterval = null;

    // Music drone
    this.droneOsc1 = null;
    this.droneOsc2 = null;
    this.droneGain = null;
  }

  init() {
    if (this.isInitialized) return;
    try {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.setValueAtTime(0.58, this.ctx.currentTime);
      this.masterGain.connect(this.ctx.destination);

      this.setupEngineSound();
      this.setupSurfaceSound();
      this.setupBrakeSound();
      this.setupAmbientSound();
      this.setupDroneAtmosphere();

      this.isInitialized = true;
    } catch (e) {
      console.warn('WebAudio initialization delayed until user gesture:', e);
    }
  }

  ensureContext() {
    if (!this.isInitialized) this.init();
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  setEngineProfile(profile) {
    if (!profile) return;
    this.currentProfile = Object.assign(this.currentProfile, profile);
  }

  setupEngineSound() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Primary cylinder firing oscillator (sawtooth)
    this.engineOsc = this.ctx.createOscillator();
    this.engineOsc.type = 'sawtooth';
    this.engineOsc.frequency.setValueAtTime(38, now);

    // 2. Sub-octave crankshaft bass thud (triangle, 0.5x freq)
    this.engineSubOsc = this.ctx.createOscillator();
    this.engineSubOsc.type = 'triangle';
    this.engineSubOsc.frequency.setValueAtTime(19, now);

    // 3. Cylinder valve/cam harmonic rasp (square/pulse, 1.5x freq)
    this.engineHarmonicOsc = this.ctx.createOscillator();
    this.engineHarmonicOsc.type = 'square';
    this.engineHarmonicOsc.frequency.setValueAtTime(57, now);
    const harmonicGain = this.ctx.createGain();
    harmonicGain.gain.setValueAtTime(0.22, now);
    this.engineHarmonicOsc.connect(harmonicGain);

    // 4. Air intake rushing noise buffer (adds authentic throatiness on throttle)
    const intakeBufSize = this.ctx.sampleRate * 2;
    const intakeBuf = this.ctx.createBuffer(1, intakeBufSize, this.ctx.sampleRate);
    const intakeData = intakeBuf.getChannelData(0);
    for (let i = 0; i < intakeBufSize; i++) {
      intakeData[i] = (Math.random() * 2 - 1) * 0.4;
    }
    const intakeSource = this.ctx.createBufferSource();
    intakeSource.buffer = intakeBuf;
    intakeSource.loop = true;
    const intakeFilter = this.ctx.createBiquadFilter();
    intakeFilter.type = 'bandpass';
    intakeFilter.frequency.setValueAtTime(450, now);
    intakeFilter.Q.setValueAtTime(2.2, now);
    this.engineIntakeGain = this.ctx.createGain();
    this.engineIntakeGain.gain.setValueAtTime(0.0, now);
    intakeSource.connect(intakeFilter);
    intakeFilter.connect(this.engineIntakeGain);
    intakeSource.start();

    // 5. Engine Pre-Mix Bus
    const preMix = this.ctx.createGain();
    preMix.gain.setValueAtTime(0.65, now);
    this.engineOsc.connect(preMix);
    this.engineSubOsc.connect(preMix);
    harmonicGain.connect(preMix);
    this.engineIntakeGain.connect(preMix);

    // 6. Warm Analog Waveshaper Distortion (turns harsh synth into authentic combustion rumble)
    this.engineDistortion = this.ctx.createWaveShaper();
    this.engineDistortion.curve = makeDistortionCurve(18);
    this.engineDistortion.oversample = '2x';
    preMix.connect(this.engineDistortion);

    // 7. Dynamic Resonant Lowpass Filter (opens up as throttle & RPM increase)
    this.engineFilter = this.ctx.createBiquadFilter();
    this.engineFilter.type = 'lowpass';
    this.engineFilter.frequency.setValueAtTime(160, now);
    this.engineFilter.Q.setValueAtTime(4.2, now);
    this.engineDistortion.connect(this.engineFilter);

    // 8. Main Engine Gain
    this.engineGain = this.ctx.createGain();
    this.engineGain.gain.setValueAtTime(0, now);
    this.engineFilter.connect(this.engineGain);
    this.engineGain.connect(this.masterGain);

    // 9. Turbocharger High-Pitch Spool Whistle
    this.turboOsc = this.ctx.createOscillator();
    this.turboGain = this.ctx.createGain();
    this.turboOsc.type = 'sine';
    this.turboOsc.frequency.setValueAtTime(1400, now);
    this.turboGain.gain.setValueAtTime(0, now);

    const turboFilter = this.ctx.createBiquadFilter();
    turboFilter.type = 'bandpass';
    turboFilter.frequency.setValueAtTime(2400, now);
    turboFilter.Q.setValueAtTime(7.5, now);

    this.turboOsc.connect(turboFilter);
    turboFilter.connect(this.turboGain);
    this.turboGain.connect(this.masterGain);

    this.engineOsc.start();
    this.engineSubOsc.start();
    this.engineHarmonicOsc.start();
    this.turboOsc.start();
  }

  setupSurfaceSound() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Continuous tire rolling noise (Pink/Brown noise approximation)
    const rollBufSize = this.ctx.sampleRate * 2;
    const rollBuf = this.ctx.createBuffer(1, rollBufSize, this.ctx.sampleRate);
    const rollData = rollBuf.getChannelData(0);
    let lastOut = 0.0;
    for (let i = 0; i < rollBufSize; i++) {
      const white = Math.random() * 2 - 1;
      rollData[i] = (lastOut + 0.04 * white) / 1.04;
      lastOut = rollData[i];
      rollData[i] *= 2.5;
    }
    this.surfaceRollNode = this.ctx.createBufferSource();
    this.surfaceRollNode.buffer = rollBuf;
    this.surfaceRollNode.loop = true;

    this.surfaceRollFilter = this.ctx.createBiquadFilter();
    this.surfaceRollFilter.type = 'lowpass';
    this.surfaceRollFilter.frequency.setValueAtTime(180, now);

    this.surfaceRollGain = this.ctx.createGain();
    this.surfaceRollGain.gain.setValueAtTime(0.0, now);

    this.surfaceRollNode.connect(this.surfaceRollFilter);
    this.surfaceRollFilter.connect(this.surfaceRollGain);
    this.surfaceRollGain.connect(this.masterGain);
    this.surfaceRollNode.start();

    // 2. Gravel / dirt shoulder scattering texture (textured crackle buffer)
    const gravelBuf = this.ctx.createBuffer(1, rollBufSize, this.ctx.sampleRate);
    const gravelData = gravelBuf.getChannelData(0);
    for (let i = 0; i < rollBufSize; i++) {
      // Intermittent sharp pebble pings and crunch
      gravelData[i] = Math.random() < 0.04 ? (Math.random() * 2 - 1) * 0.9 : (Math.random() * 2 - 1) * 0.08;
    }
    this.gravelCrunchNode = this.ctx.createBufferSource();
    this.gravelCrunchNode.buffer = gravelBuf;
    this.gravelCrunchNode.loop = true;

    this.gravelCrunchFilter = this.ctx.createBiquadFilter();
    this.gravelCrunchFilter.type = 'bandpass';
    this.gravelCrunchFilter.frequency.setValueAtTime(1400, now);
    this.gravelCrunchFilter.Q.setValueAtTime(2.0, now);

    this.gravelCrunchGain = this.ctx.createGain();
    this.gravelCrunchGain.gain.setValueAtTime(0.0, now);

    this.gravelCrunchNode.connect(this.gravelCrunchFilter);
    this.gravelCrunchFilter.connect(this.gravelCrunchGain);
    this.gravelCrunchGain.connect(this.masterGain);
    this.gravelCrunchNode.start();
  }

  setupBrakeSound() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    this.brakeSquealOsc = this.ctx.createOscillator();
    this.brakeSquealGain = this.ctx.createGain();

    this.brakeSquealOsc.type = 'sine';
    this.brakeSquealOsc.frequency.setValueAtTime(3200, now);
    this.brakeSquealGain.gain.setValueAtTime(0.0, now);

    const brakeFilter = this.ctx.createBiquadFilter();
    brakeFilter.type = 'bandpass';
    brakeFilter.frequency.setValueAtTime(3200, now);
    brakeFilter.Q.setValueAtTime(12.0, now);

    this.brakeSquealOsc.connect(brakeFilter);
    brakeFilter.connect(this.brakeSquealGain);
    this.brakeSquealGain.connect(this.masterGain);
    this.brakeSquealOsc.start();
  }

  setEngineRPM(normalizedRPM, isAccelerating = false, boostBar = 0, gear = 1, forwardSpeed = 0) {
    if (!this.ctx || !this.isEngineRunning) return;
    const now = this.ctx.currentTime;

    const p = this.currentProfile;
    const base = p.baseFreq || 38;
    const cylMultiplier = (p.cylinders || 4) / 4.0;

    // Pitch scales authentic to engine cylinder pulses
    const freq = (base + Math.pow(normalizedRPM, 1.35) * 145) * cylMultiplier;
    this.engineOsc.frequency.setTargetAtTime(freq, now, 0.06);
    this.engineSubOsc.frequency.setTargetAtTime(freq * 0.5, now, 0.06);
    this.engineHarmonicOsc.frequency.setTargetAtTime(freq * 1.5, now, 0.06);

    // Resonant lowpass filter opens with throttle and RPM
    const filterFreq = 120 + normalizedRPM * 540 + (isAccelerating ? 320 : 0);
    this.engineFilter.frequency.setTargetAtTime(filterFreq, now, 0.07);

    // Air intake throatiness gain on throttle
    if (this.engineIntakeGain) {
      const intakeVol = isAccelerating ? (0.08 + normalizedRPM * 0.16) : 0.01;
      this.engineIntakeGain.gain.setTargetAtTime(intakeVol, now, 0.08);
    }

    // Engine master volume
    const vol = 0.22 + normalizedRPM * 0.26 + (isAccelerating ? 0.09 : 0);
    this.engineGain.gain.setTargetAtTime(vol, now, 0.07);

    // Turbo whistle modulation proportional to active boost pressure
    if (this.turboGain && p.turboWhistle > 0) {
      if (boostBar > 0.05 || (isAccelerating && normalizedRPM > 0.25)) {
        const boostRatio = Math.min(1.2, (boostBar / 1.2) + (normalizedRPM * 0.3));
        const turboFreq = 1400 + boostRatio * 2200;
        this.turboOsc.frequency.setTargetAtTime(turboFreq, now, 0.08);
        const turboVol = p.turboWhistle * (0.04 + boostRatio * 0.12);
        this.turboGain.gain.setTargetAtTime(turboVol, now, 0.1);
      } else {
        this.turboGain.gain.setTargetAtTime(0, now, 0.15);
      }
    } else if (this.turboGain) {
      this.turboGain.gain.setTargetAtTime(0, now, 0.1);
    }
  }

  playTurboBlowOff(boostLevel = 1.0) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const intensity = Math.min(1.0, Math.max(0.3, boostLevel));

    // Layer 1: High-pressure air dump whoosh
    const whooshDuration = 0.35 + intensity * 0.2;
    const noise = this.createNoiseBurst(whooshDuration, 4200, 0.26 * intensity);
    if (noise) noise.start(now);

    // Layer 2: Compressor surge flutter chirp (tsu-tsu-tsu-tsu)
    for (let i = 0; i < 4; i++) {
      const t = now + 0.05 + i * 0.055;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(1850 - i * 180, t);
      osc.frequency.exponentialRampToValueAtTime(700, t + 0.04);

      g.gain.setValueAtTime(0.18 * (1.0 - i * 0.2) * intensity, t);
      g.gain.exponentialRampToValueAtTime(0.005, t + 0.045);

      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.05);
    }
  }

  playBackfire(intensity = 1.0) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const mag = Math.min(1.0, intensity);

    // 1. High frequency explosive bang / whip crack
    const crack = this.createNoiseBurst(0.09, 5200, 0.42 * mag);
    if (crack) crack.start(now);

    // 2. Deep sub-frequency tailpipe thump
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(110, now);
    osc.frequency.exponentialRampToValueAtTime(24, now + 0.18);

    g.gain.setValueAtTime(0.55 * mag, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.18);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.19);
  }

  setSurface(surface, normalizedSpeed, onShoulder) {
    if (!this.ctx || !this.surfaceRollGain) return;
    const now = this.ctx.currentTime;
    const speed = Math.max(0, Math.min(1.5, normalizedSpeed));

    if (speed < 0.02) {
      this.surfaceRollGain.gain.setTargetAtTime(0, now, 0.15);
      if (this.gravelCrunchGain) this.gravelCrunchGain.gain.setTargetAtTime(0, now, 0.15);
      return;
    }

    // Rolling tire hum on pavement
    const rollVol = Math.min(0.25, speed * 0.18);
    const filterFreq = 160 + speed * 320;
    this.surfaceRollGain.gain.setTargetAtTime(rollVol, now, 0.1);
    this.surfaceRollFilter.frequency.setTargetAtTime(filterFreq, now, 0.1);

    // Shoulder gravel rattle and scattering
    if (this.gravelCrunchGain) {
      if (onShoulder || (surface && (surface.id === 'gravel' || surface.id === 'dirt'))) {
        const gravelVol = Math.min(0.35, 0.08 + speed * 0.28);
        this.gravelCrunchGain.gain.setTargetAtTime(gravelVol, now, 0.08);
      } else {
        this.gravelCrunchGain.gain.setTargetAtTime(0, now, 0.18);
      }
    }
  }

  setBrakeSound(isBraking, speedRatio) {
    if (!this.ctx || !this.brakeSquealGain) return;
    const now = this.ctx.currentTime;
    if (isBraking && speedRatio > 0.15 && speedRatio < 0.85) {
      this.brakeSquealGain.gain.setTargetAtTime(0.045, now, 0.08);
    } else {
      this.brakeSquealGain.gain.setTargetAtTime(0, now, 0.1);
    }
  }

  playSuspensionThump(severity = 0.5) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const mag = Math.min(1.0, Math.max(0.1, severity));

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(85, now);
    osc.frequency.exponentialRampToValueAtTime(22, now + 0.14);

    g.gain.setValueAtTime(0.35 * mag, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.14);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.15);
  }

  startEngine() {
    this.ensureContext();
    if (!this.ctx) return;
    this.isEngineRunning = true;

    // Cranking sound burst
    this.playCrankEffect(() => {
      if (this.engineGain) {
        this.engineGain.gain.setTargetAtTime(0.25, this.ctx.currentTime, 0.2);
      }
    });
  }

  stopEngine() {
    if (!this.ctx || !this.isEngineRunning) return;
    this.isEngineRunning = false;
    if (this.engineGain) {
      this.engineGain.gain.setTargetAtTime(0, this.ctx.currentTime, 0.35);
    }
    if (this.surfaceRollGain) {
      this.surfaceRollGain.gain.setTargetAtTime(0, this.ctx.currentTime, 0.2);
    }
    if (this.gravelCrunchGain) {
      this.gravelCrunchGain.gain.setTargetAtTime(0, this.ctx.currentTime, 0.2);
    }
    this.playSwitchClick(false);
  }

  playCrankEffect(onStartCallback) {
    const now = this.ctx.currentTime;
    for (let i = 0; i < 3; i++) {
      const t = now + i * 0.12;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'square';
      osc.frequency.setValueAtTime(45 + i * 5, t);
      g.gain.setValueAtTime(0.3, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.08);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.09);
    }
    setTimeout(() => {
      if (onStartCallback) onStartCallback();
      this.playRevChirp();
    }, 400);
  }

  playRevChirp() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(90, now);
    osc.frequency.exponentialRampToValueAtTime(180, now + 0.25);
    osc.frequency.exponentialRampToValueAtTime(55, now + 0.55);
    g.gain.setValueAtTime(0.25, now);
    g.gain.linearRampToValueAtTime(0.01, now + 0.55);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.56);
  }

  setupAmbientSound() {
    if (!this.ctx) return;

    // Procedural Wind (Pink/Brownian Noise buffer)
    const bufferSize = this.ctx.sampleRate * 2;
    const noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const output = noiseBuffer.getChannelData(0);
    let lastOut = 0.0;
    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;
      output[i] = (lastOut + 0.02 * white) / 1.02;
      lastOut = output[i];
      output[i] *= 3.5;
    }

    this.windNode = this.ctx.createBufferSource();
    this.windNode.buffer = noiseBuffer;
    this.windNode.loop = true;

    const windFilter = this.ctx.createBiquadFilter();
    windFilter.type = 'bandpass';
    windFilter.frequency.setValueAtTime(260, this.ctx.currentTime);
    windFilter.Q.setValueAtTime(1.5, this.ctx.currentTime);

    this.windGain = this.ctx.createGain();
    this.windGain.gain.setValueAtTime(0.08, this.ctx.currentTime);

    this.windNode.connect(windFilter);
    windFilter.connect(this.windGain);
    this.windGain.connect(this.masterGain);

    this.windNode.start();
  }

  setSpeedWind(normalizedSpeed) {
    if (!this.ctx || !this.windGain) return;
    const targetVol = 0.05 + normalizedSpeed * 0.28;
    this.windGain.gain.setTargetAtTime(targetVol, this.ctx.currentTime, 0.2);
  }

  setupDroneAtmosphere() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    this.droneOsc1 = this.ctx.createOscillator();
    this.droneOsc2 = this.ctx.createOscillator();
    this.droneGain = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();

    this.droneOsc1.type = 'sine';
    this.droneOsc2.type = 'triangle';

    this.droneOsc1.frequency.setValueAtTime(55, now);     // A1
    this.droneOsc2.frequency.setValueAtTime(82.41, now);  // E2 (dark 5th)

    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(180, now);

    this.droneGain.gain.setValueAtTime(0.09, now);

    this.droneOsc1.connect(filter);
    this.droneOsc2.connect(filter);
    filter.connect(this.droneGain);
    this.droneGain.connect(this.masterGain);

    this.droneOsc1.start();
    this.droneOsc2.start();
  }

  playImpact(strength = 1.0) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(110 * strength, now);
    osc.frequency.exponentialRampToValueAtTime(20, now + 0.35);

    g.gain.setValueAtTime(Math.min(0.6 * strength, 0.8), now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.35);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.36);

    const noise = this.createNoiseBurst(0.2, 800, 0.35 * strength);
    if (noise) noise.start(now);
  }

  playTireScreech() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(650 + Math.random() * 80, now);
    osc.frequency.linearRampToValueAtTime(520, now + 0.22);

    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(750, now);
    filter.Q.setValueAtTime(8.0, now);

    g.gain.setValueAtTime(0.12, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.22);

    osc.connect(filter);
    filter.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.23);
  }

  playSwitchClick(isOn = true) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(isOn ? 980 : 720, now);
    osc.frequency.exponentialRampToValueAtTime(150, now + 0.035);

    g.gain.setValueAtTime(0.25, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.035);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.04);
  }

  playHorn() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc1 = this.ctx.createOscillator();
    const osc2 = this.ctx.createOscillator();
    const g = this.ctx.createGain();

    osc1.type = 'sawtooth';
    osc2.type = 'sawtooth';
    osc1.frequency.setValueAtTime(340, now); // F4
    osc2.frequency.setValueAtTime(425, now); // G#4

    g.gain.setValueAtTime(0.3, now);
    g.gain.linearRampToValueAtTime(0.28, now + 0.35);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.45);

    osc1.connect(g);
    osc2.connect(g);
    g.connect(this.masterGain);
    osc1.start(now);
    osc2.start(now);
    osc1.stop(now + 0.46);
    osc2.stop(now + 0.46);
  }

  playGeigerClick() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();

    osc.type = 'square';
    osc.frequency.setValueAtTime(2400 + Math.random() * 800, now);
    g.gain.setValueAtTime(0.2, now);
    g.gain.exponentialRampToValueAtTime(0.005, now + 0.012);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.015);
  }

  playLootPickup() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const notes = [440, 554, 659]; // A major arpeggio
    notes.forEach((freq, idx) => {
      const t = now + idx * 0.06;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, t);
      g.gain.setValueAtTime(0.18, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.12);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.13);
    });
  }

  playBreakdownAlarm() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    for (let i = 0; i < 2; i++) {
      const t = now + i * 0.12;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(i === 0 ? 1050 : 790, t);
      g.gain.setValueAtTime(0.25, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.09);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.1);
    }
  }

  playRadiatorHiss() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const duration = 1.2;
    const noise = this.createNoiseBurst(duration, 3800, 0.22);
    if (noise) {
      noise.start(now);
    }
  }

  playTireBlowout() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(140, now);
    osc.frequency.exponentialRampToValueAtTime(32, now + 0.3);
    g.gain.setValueAtTime(0.45, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.3);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.32);

    const noise = this.createNoiseBurst(0.35, 1200, 0.4);
    if (noise) noise.start(now);
  }

  playRepairWrench() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    for (let i = 0; i < 3; i++) {
      const t = now + i * 0.08;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'square';
      osc.frequency.setValueAtTime(1450 + i * 150, t);
      osc.frequency.exponentialRampToValueAtTime(300, t + 0.03);
      g.gain.setValueAtTime(0.28, t);
      g.gain.exponentialRampToValueAtTime(0.01, t + 0.035);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.04);
    }
  }

  playLightningThunder() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const crackle = this.createNoiseBurst(0.18, 5500, 0.35);
    if (crackle) crackle.start(now);

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(65, now + 0.15);
    osc.frequency.linearRampToValueAtTime(28, now + 2.2);

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(160, now + 0.15);

    g.gain.setValueAtTime(0.01, now);
    g.gain.linearRampToValueAtTime(0.35, now + 0.25);
    g.gain.exponentialRampToValueAtTime(0.01, now + 2.2);

    osc.connect(filter);
    filter.connect(g);
    g.connect(this.masterGain);
    osc.start(now + 0.15);
    osc.stop(now + 2.3);
  }

  createNoiseBurst(duration, cutoffFreq, gainVal) {
    if (!this.ctx) return null;
    const bufferSize = Math.max(1, Math.floor(this.ctx.sampleRate * duration));
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = Math.random() * 2 - 1;
    }
    const noise = this.ctx.createBufferSource();
    noise.buffer = buffer;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(cutoffFreq, this.ctx.currentTime);

    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(gainVal, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(this.masterGain);
    return noise;
  }

  playChassisScrape() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const scrapeNoise = this.createNoiseBurst(0.32, 900, 0.42);
    if (scrapeNoise) scrapeNoise.start(now);

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(75, now);
    osc.frequency.exponentialRampToValueAtTime(32, now + 0.28);
    g.gain.setValueAtTime(0.35, now);
    g.gain.exponentialRampToValueAtTime(0.01, now + 0.28);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.29);
  }

  playRadioStatic() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Squelch noise burst (radio gate open)
    const squelch = this.createNoiseBurst(0.08, 3800, 0.28);
    if (squelch) squelch.start(now);

    // 2. Vintage CB Roger Beep (Two-tone high chirp)
    const osc1 = this.ctx.createOscillator();
    const g1 = this.ctx.createGain();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(1180, now + 0.08);
    g1.gain.setValueAtTime(0.18, now + 0.08);
    g1.gain.exponentialRampToValueAtTime(0.001, now + 0.14);
    osc1.connect(g1);
    g1.connect(this.masterGain);
    osc1.start(now + 0.08);
    osc1.stop(now + 0.15);

    const osc2 = this.ctx.createOscillator();
    const g2 = this.ctx.createGain();
    osc2.type = 'sine';
    osc2.frequency.setValueAtTime(1760, now + 0.14);
    g2.gain.setValueAtTime(0.22, now + 0.14);
    g2.gain.exponentialRampToValueAtTime(0.001, now + 0.22);
    osc2.connect(g2);
    g2.connect(this.masterGain);
    osc2.start(now + 0.14);
    osc2.stop(now + 0.23);
  }

  playMissionSuccess() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // Triumphant orchestral chord: C5 -> E5 -> G5 -> C6
    const freqs = [523.25, 659.25, 783.99, 1046.50];
    freqs.forEach((freq, idx) => {
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = idx === 3 ? 'sine' : 'triangle';
      osc.frequency.setValueAtTime(freq, now + idx * 0.07);
      
      const startTime = now + idx * 0.07;
      g.gain.setValueAtTime(0.01, startTime);
      g.gain.linearRampToValueAtTime(0.28 / (idx + 1), startTime + 0.04);
      g.gain.exponentialRampToValueAtTime(0.001, startTime + 1.2);

      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(startTime);
      osc.stop(startTime + 1.25);
    });
  }

  playObjectiveDing() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(987.77, now); // B5
    osc.frequency.exponentialRampToValueAtTime(1318.51, now + 0.08); // E6

    g.gain.setValueAtTime(0.25, now);
    g.gain.exponentialRampToValueAtTime(0.001, now + 0.55);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.6);
  }

  playHorn(modelId = 'panda_4x4') {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // Frequencies tailored to vehicle origin & era:
    // Italian: Fiamm high-pitch dual trumpet (420Hz & 510Hz)
    // German: Bosch authoritative dual tone (340Hz & 415Hz)
    // British/Truck: Lucas heavy tone (290Hz & 370Hz)
    let f1 = 420;
    let f2 = 510;
    if (modelId === 'mercedes_w123' || modelId === 'mercedes_gwagen' || modelId === 'bmw_e30_ix' || modelId === 'audi_quattro') {
      f1 = 340;
      f2 = 415;
    } else if (modelId === 'defender_110' || modelId === 'volvo_245') {
      f1 = 295;
      f2 = 370;
    }

    [f1, f2].forEach((freq) => {
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(freq, now);
      // Slight pitch droop on attack
      osc.frequency.setValueAtTime(freq + 15, now);
      osc.frequency.exponentialRampToValueAtTime(freq, now + 0.04);

      const filter = this.ctx.createBiquadFilter();
      filter.type = 'bandpass';
      filter.frequency.setValueAtTime(freq, now);
      filter.Q.setValueAtTime(3.5, now);

      g.gain.setValueAtTime(0.01, now);
      g.gain.linearRampToValueAtTime(0.22, now + 0.02);
      g.gain.setValueAtTime(0.22, now + 0.35);
      g.gain.exponentialRampToValueAtTime(0.001, now + 0.45);

      osc.connect(filter);
      filter.connect(g);
      g.connect(this.masterGain);
      osc.start(now);
      osc.stop(now + 0.46);
    });
  }

  play4WDEngage(engaged = true) {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // Steyr-Puch mechanical dog-clutch engage clunk
    const thud = this.createNoiseBurst(0.06, 600, 0.4);
    if (thud) thud.start(now);

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(engaged ? 180 : 120, now);
    osc.frequency.exponentialRampToValueAtTime(engaged ? 90 : 60, now + 0.09);

    g.gain.setValueAtTime(0.35, now);
    g.gain.exponentialRampToValueAtTime(0.001, now + 0.1);

    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.11);
  }

  playGlowPlugChime() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, now); // A5
    g.gain.setValueAtTime(0.2, now);
    g.gain.exponentialRampToValueAtTime(0.001, now + 0.8);
    osc.connect(g);
    g.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.85);
  }

  playRadioStatic() {
    this.ensureContext();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;

    // 1. Initial RF squelch burst (white noise through bandpass)
    const noise = this.createNoiseBurst(0.18, 1800, 0.28);
    if (noise) noise.start(now);

    // 2. Midland Alan 48 classic dual-tone Roger-Beep
    const beepTime = now + 0.2;
    [1046.5, 1318.5].forEach((freq, idx) => {
      const t = beepTime + idx * 0.08;
      const osc = this.ctx.createOscillator();
      const g = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, t);
      g.gain.setValueAtTime(0.18, t);
      g.gain.exponentialRampToValueAtTime(0.001, t + 0.075);
      osc.connect(g);
      g.connect(this.masterGain);
      osc.start(t);
      osc.stop(t + 0.08);
    });
  }
}




// --- FILE: src/engine/Renderer.js ---
/**
 * THE LONG MERIDIAN - Enhanced Three.js WebGL Rendering Pipeline
 * High-fidelity lighting, volumetric fog, dynamic weather particles, soft shadows and exhaust smoke.
 */

class Renderer {
  constructor(canvasContainer) {
    this.container = canvasContainer;
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.sunLight = null;
    this.hemiLight = null;
    this.ambientLight = null;
    this.fog = null;

    // Weather particles
    this.particleSystem = null;
    this.particleGeo = null;
    this.particleMat = null;
    this.particleCount = 900;

    // Exhaust smoke particles
    this.exhaustParticles = [];
    this.exhaustGroup = null;

    // Biome & Lightning Atmosphere
    this.currentBiome = null;
    this.audioEngine = null;
    this.lightningTimer = 0;
    this.nextLightningTime = 10 + Math.random() * 15;
    this.lightningFlash = 0; // 0 to 1

    this.init();
  }

  init() {
    // 1. Scene
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x131110);

    // 2. Camera: Perspective calibrated for 3/4 top-down vertical portrait viewing
    const aspect = this.container.clientWidth / this.container.clientHeight;
    this.camera = new THREE.PerspectiveCamera(50, aspect, 0.5, 350);
    this.camera.position.set(0, 19, -15);
    this.camera.lookAt(0, 0, 14);

    // 3. WebGL Renderer with High Dynamic Range Tone Mapping
    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
      powerPreference: 'high-performance',
      stencil: false,
      depth: true
    });
    this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.15;

    this.container.appendChild(this.renderer.domElement);

    // 4. Fog
    this.fog = new THREE.FogExp2(0x181412, 0.016);
    this.scene.fog = this.fog;

    // 5. Multi-tiered Lighting
    // Ambient light
    this.ambientLight = new THREE.AmbientLight(0xffeedd, 0.5);
    this.scene.add(this.ambientLight);

    // Hemisphere light: subtle blue sky vs warm ground bounce
    this.hemiLight = new THREE.HemisphereLight(0x7ba3cc, 0x3d3228, 0.6);
    this.scene.add(this.hemiLight);

    // Directional Sun/Moon with crisp soft shadow frustum
    this.sunLight = new THREE.DirectionalLight(0xffdfb8, 1.1);
    this.sunLight.position.set(22, 45, 15);
    this.sunLight.castShadow = true;
    this.sunLight.shadow.mapSize.width = 2048;
    this.sunLight.shadow.mapSize.height = 2048;
    this.sunLight.shadow.camera.near = 1;
    this.sunLight.shadow.camera.far = 160;
    const shadowD = 32;
    this.sunLight.shadow.camera.left = -shadowD;
    this.sunLight.shadow.camera.right = shadowD;
    this.sunLight.shadow.camera.top = shadowD;
    this.sunLight.shadow.camera.bottom = -shadowD;
    this.sunLight.shadow.bias = -0.0008;
    this.sunLight.shadow.radius = 2.5;
    this.scene.add(this.sunLight);
    this.scene.add(this.sunLight.target);

    // 6. Weather & Exhaust Particles
    this.initWeatherParticles();
    this.initExhaustSystem();
    this.initTireSpraySystem();
    this.initStarfield();
    this.initAuroraBorealis();

    // 7. Event listeners
    window.addEventListener('resize', () => this.onWindowResize());
  }

  initWeatherParticles() {
    this.particleGeo = new THREE.BufferGeometry();
    const positions = new Float32Array(this.particleCount * 3);
    const velocities = new Float32Array(this.particleCount);

    for (let i = 0; i < this.particleCount; i++) {
      positions[i * 3 + 0] = (Math.random() - 0.5) * 55;
      positions[i * 3 + 1] = Math.random() * 28;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 75;
      velocities[i] = 14 + Math.random() * 10;
    }

    this.particleGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    this.particleGeo.setAttribute('velocity', new THREE.BufferAttribute(velocities, 1));

    this.particleMat = new THREE.PointsMaterial({
      color: 0x99ccff,
      size: 0.22,
      transparent: true,
      opacity: 0.7,
      blending: THREE.AdditiveBlending
    });

    this.particleSystem = new THREE.Points(this.particleGeo, this.particleMat);
    this.scene.add(this.particleSystem);
  }

  initStarfield() {
    const starGeo = new THREE.BufferGeometry();
    const starCount = 380;
    const starPos = new Float32Array(starCount * 3);
    for (let i = 0; i < starCount; i++) {
      starPos[i * 3 + 0] = (Math.random() - 0.5) * 320;
      starPos[i * 3 + 1] = 22 + Math.random() * 55;
      starPos[i * 3 + 2] = (Math.random() - 0.5) * 320;
    }
    starGeo.setAttribute('position', new THREE.BufferAttribute(starPos, 3));
    this.starMat = new THREE.PointsMaterial({
      color: 0xe0f2fe,
      size: 0.75,
      transparent: true,
      opacity: 0.0,
      blending: THREE.AdditiveBlending
    });
    this.starfield = new THREE.Points(starGeo, this.starMat);
    this.scene.add(this.starfield);
  }

  initAuroraBorealis() {
    this.auroraGroup = new THREE.Group();
    this.auroraRibbons = [];
    this.auroraTime = 0.0;

    const ribbonConfigs = [
      { color: 0x10b981, y: 48, zOffset: 140, opacity: 0.32, width: 280, height: 26 },
      { color: 0x06b6d4, y: 54, zOffset: 175, opacity: 0.28, width: 310, height: 28 },
      { color: 0xa855f7, y: 60, zOffset: 215, opacity: 0.24, width: 330, height: 30 }
    ];

    ribbonConfigs.forEach((rc, idx) => {
      const geo = new THREE.PlaneGeometry(rc.width, rc.height, 42, 6);
      const mat = new THREE.MeshBasicMaterial({
        color: rc.color,
        transparent: true,
        opacity: 0.0,
        blending: THREE.AdditiveBlending,
        side: THREE.DoubleSide,
        depthWrite: false
      });
      const mesh = new THREE.Mesh(geo, mat);
      mesh.position.set(0, rc.y, rc.zOffset);
      mesh.rotation.x = Math.PI * 0.12;
      this.auroraGroup.add(mesh);
      this.auroraRibbons.push({ mesh, mat, config: rc, basePos: geo.attributes.position.clone() });
    });

    this.scene.add(this.auroraGroup);
  }

  initExhaustSystem() {
    this.exhaustGroup = new THREE.Group();
    this.scene.add(this.exhaustGroup);
    this.exhaustMat = new THREE.MeshBasicMaterial({
      color: 0x555555,
      transparent: true,
      opacity: 0.35,
      depthWrite: false
    });
    this.exhaustGeo = new THREE.SphereGeometry(0.2, 5, 5);
  }

  initTireSpraySystem() {
    this.sprayGroup = new THREE.Group();
    this.scene.add(this.sprayGroup);
    this.sprayParticles = [];
    this.sprayGeo = new THREE.SphereGeometry(0.22, 5, 5);
    this.gravelSprayMat = new THREE.MeshBasicMaterial({
      color: 0x8a735a,
      transparent: true,
      opacity: 0.45,
      depthWrite: false
    });
    this.wetSprayMat = new THREE.MeshBasicMaterial({
      color: 0xc8dcf0,
      transparent: true,
      opacity: 0.28,
      depthWrite: false,
      blending: THREE.AdditiveBlending
    });
  }

  emitExhaust(pos, isThrottle) {
    if (!this.exhaustGroup || (!isThrottle && Math.random() > 0.3)) return;
    const smoke = new THREE.Mesh(this.exhaustGeo, this.exhaustMat.clone());
    smoke.position.copy(pos);
    smoke.position.x += (Math.random() - 0.5) * 0.15;
    smoke.position.y += (Math.random() - 0.5) * 0.1;
    smoke.scale.setScalar(0.4 + Math.random() * 0.3);
    smoke.userData = {
      life: 0.0,
      maxLife: 0.8 + Math.random() * 0.4,
      vy: 0.8 + Math.random() * 0.8,
      vx: (Math.random() - 0.5) * 0.4,
      vz: -1.0 - Math.random() * 1.5
    };
    this.exhaustGroup.add(smoke);
    this.exhaustParticles.push(smoke);

    // Limit pool
    if (this.exhaustParticles.length > 40) {
      const old = this.exhaustParticles.shift();
      this.exhaustGroup.remove(old);
      if (old.material) old.material.dispose();
    }
  }

  emitBackfire(pos) {
    if (!this.exhaustGroup) return;
    const flameMat = new THREE.MeshBasicMaterial({
      color: 0xffaa22,
      transparent: true,
      opacity: 0.95,
      blending: THREE.AdditiveBlending,
      depthWrite: false
    });
    const flameGeo = new THREE.ConeGeometry(0.24, 0.65, 6);
    flameGeo.rotateX(-Math.PI / 2);
    const flame = new THREE.Mesh(flameGeo, flameMat);
    flame.position.copy(pos);
    flame.position.z -= 0.3;
    flame.userData = {
      life: 0.0,
      maxLife: 0.12,
      isFlame: true
    };
    this.exhaustGroup.add(flame);
    this.exhaustParticles.push(flame);
  }

  emitTireSpray(posLeft, posRight, surface, speedRatio, onShoulder) {
    if (!this.sprayGroup || speedRatio < 0.12) return;
    if (Math.random() > 0.6) return;

    const isGravel = onShoulder || (surface && (surface.id === 'gravel' || surface.id === 'dirt'));
    const mat = isGravel ? this.gravelSprayMat : this.wetSprayMat;
    const baseOpacity = isGravel ? 0.45 : 0.28;

    [posLeft, posRight].forEach((p) => {
      if (!p) return;
      const spray = new THREE.Mesh(this.sprayGeo, mat.clone());
      spray.position.copy(p);
      spray.position.y += 0.06;
      spray.position.x += (Math.random() - 0.5) * 0.25;
      spray.position.z -= 0.15;
      spray.scale.setScalar(0.35 + speedRatio * 0.35);
      spray.userData = {
        life: 0.0,
        maxLife: isGravel ? 0.65 : 0.45,
        baseOpacity: baseOpacity,
        vy: 0.3 + Math.random() * 0.6 * speedRatio,
        vx: (Math.random() - 0.5) * 0.6,
        vz: -0.6 - Math.random() * 1.5 * speedRatio
      };
      this.sprayGroup.add(spray);
      this.sprayParticles.push(spray);
    });

    if (this.sprayParticles.length > 45) {
      const old = this.sprayParticles.shift();
      this.sprayGroup.remove(old);
      if (old.material) old.material.dispose();
    }
  }

  updateTireSpray(delta) {
    if (!this.sprayGroup) return;
    for (let i = this.sprayParticles.length - 1; i >= 0; i--) {
      const p = this.sprayParticles[i];
      p.userData.life += delta;
      const progress = p.userData.life / p.userData.maxLife;
      if (progress >= 1.0) {
        this.sprayGroup.remove(p);
        if (p.material) p.material.dispose();
        if (p.geometry && p.geometry !== this.sprayGeo) p.geometry.dispose();
        this.sprayParticles.splice(i, 1);
      } else {
        if (p.userData.gravity) {
          p.userData.vy -= p.userData.gravity * delta;
        }
        if (p.userData.rotSpeed) {
          p.rotation.x += p.userData.rotSpeed.x * delta;
          p.rotation.y += p.userData.rotSpeed.y * delta;
          p.rotation.z += p.userData.rotSpeed.z * delta;
        }
        p.position.y += p.userData.vy * delta;
        p.position.x += p.userData.vx * delta;
        p.position.z += p.userData.vz * delta;

        if (p.userData.scaleGrowth) {
          p.scale.setScalar(p.userData.initialScale * (1.0 + progress * p.userData.scaleGrowth));
        } else {
          p.scale.setScalar(p.userData.initialScale ? p.userData.initialScale * (1.0 - progress * 0.4) : (0.4 + progress * 2.5));
        }
        p.material.opacity = (1.0 - progress) * p.userData.baseOpacity;
      }
    }
  }

  emitImpactSparks(pos, count = 8) {
    if (!this.sprayGroup) return;
    const sparkMat = new THREE.MeshBasicMaterial({
      color: 0xffea78,
      transparent: true,
      opacity: 0.9,
      blending: THREE.AdditiveBlending,
      depthWrite: false
    });
    const sparkGeo = new THREE.BoxGeometry(0.08, 0.08, 0.08);

    for (let i = 0; i < count; i++) {
      const spark = new THREE.Mesh(sparkGeo, sparkMat);
      spark.position.copy(pos);
      spark.userData = {
        life: 0.0,
        maxLife: 0.22 + Math.random() * 0.22,
        baseOpacity: 0.9,
        vx: (Math.random() - 0.5) * 6.0,
        vy: 1.5 + Math.random() * 3.5,
        vz: (Math.random() - 0.5) * 6.0,
        gravity: 9.81
      };
      this.sprayGroup.add(spark);
      this.sprayParticles.push(spark);
    }
  }

  emitImpactDebris(pos, type = 'wood', count = 12) {
    if (!this.sprayGroup) return;

    let mat, geo, scaleBase = 0.14, gravity = 11.0;

    if (type === 'wood') {
      mat = new THREE.MeshStandardMaterial({
        color: 0x855428,
        roughness: 0.9,
        metalness: 0.05
      });
      geo = new THREE.BoxGeometry(0.14, 0.07, 0.26);
      scaleBase = 0.18;
    } else if (type === 'rock') {
      mat = new THREE.MeshStandardMaterial({
        color: 0x5a544e,
        roughness: 0.95,
        metalness: 0.1
      });
      geo = new THREE.DodecahedronGeometry(0.11, 0);
      scaleBase = 0.22;
      gravity = 14.0;
    } else if (type === 'barrel') {
      mat = new THREE.MeshStandardMaterial({
        color: 0xf97316,
        roughness: 0.45,
        metalness: 0.2
      });
      geo = new THREE.BoxGeometry(0.18, 0.12, 0.06);
      scaleBase = 0.24;
    } else if (type === 'rubber') {
      mat = new THREE.MeshStandardMaterial({
        color: 0x1f242d,
        roughness: 0.95
      });
      geo = new THREE.BoxGeometry(0.15, 0.06, 0.22);
      scaleBase = 0.18;
    } else if (type === 'steam') {
      mat = new THREE.MeshBasicMaterial({
        color: 0xf8fafc,
        transparent: true,
        opacity: 0.65,
        depthWrite: false
      });
      geo = new THREE.SphereGeometry(0.24, 6, 6);
      scaleBase = 0.32;
      gravity = -2.5; // rises gently
    } else {
      this.emitImpactSparks(pos, count);
      return;
    }

    for (let i = 0; i < count; i++) {
      const debris = new THREE.Mesh(geo, mat.clone());
      debris.position.copy(pos);
      debris.position.x += (Math.random() - 0.5) * 0.35;
      debris.position.y += 0.15 + Math.random() * 0.25;
      debris.position.z += (Math.random() - 0.5) * 0.35;

      const spreadX = (Math.random() - 0.5) * 8.5;
      const spreadY = type === 'steam' ? 1.5 + Math.random() * 2.2 : 2.5 + Math.random() * 4.5;
      const spreadZ = (Math.random() - 0.5) * 8.5;

      const initialScale = scaleBase * (0.6 + Math.random() * 0.8);
      debris.scale.setScalar(initialScale);
      debris.userData = {
        life: 0.0,
        maxLife: type === 'steam' ? 0.9 + Math.random() * 0.5 : 0.55 + Math.random() * 0.35,
        baseOpacity: mat.opacity !== undefined ? mat.opacity : 1.0,
        vx: spreadX,
        vy: spreadY,
        vz: spreadZ,
        gravity: gravity,
        rotSpeed: {
          x: (Math.random() - 0.5) * 14.0,
          y: (Math.random() - 0.5) * 14.0,
          z: (Math.random() - 0.5) * 14.0
        },
        initialScale: initialScale,
        scaleGrowth: type === 'steam' ? 2.5 : 0.0
      };

      this.sprayGroup.add(debris);
      this.sprayParticles.push(debris);
    }

    // Pool limit
    while (this.sprayParticles.length > 75) {
      const old = this.sprayParticles.shift();
      this.sprayGroup.remove(old);
      if (old.material) old.material.dispose();
      if (old.geometry && old.geometry !== this.sprayGeo) old.geometry.dispose();
    }
  }

  updateExhaust(delta) {
    for (let i = this.exhaustParticles.length - 1; i >= 0; i--) {
      const p = this.exhaustParticles[i];
      p.userData.life += delta;
      const progress = p.userData.life / p.userData.maxLife;
      if (progress >= 1.0) {
        this.exhaustGroup.remove(p);
        if (p.material) p.material.dispose();
        this.exhaustParticles.splice(i, 1);
      } else {
        if (p.userData.isFlame) {
          p.scale.setScalar(1.0 - progress);
          p.material.opacity = 1.0 - progress;
        } else {
          p.position.y += p.userData.vy * delta;
          p.position.x += p.userData.vx * delta;
          p.position.z += p.userData.vz * delta;
          p.scale.setScalar(0.5 + progress * 2.2);
          p.material.opacity = (1.0 - progress) * 0.3;
        }
      }
    }
    this.updateTireSpray(delta);
  }

  updateWeatherParticles(delta, centerZ, weatherType) {
    if (!this.particleSystem) return;
    const positions = this.particleGeo.attributes.position.array;

    let fallSpeed = 26.0;
    let slantX = -1.8;
    let slantZ = 3.5;

    if (weatherType === 'snow' || weatherType === 'blizzard') {
      fallSpeed = 7.0;
      this.particleMat.color.setHex(0xe8f0ff);
      this.particleMat.size = 0.32;
      this.particleMat.opacity = 0.85;
    } else if (weatherType === 'ion_storm') {
      fallSpeed = 20.0;
      this.particleMat.color.setHex(0xc084fc);
      this.particleMat.size = 0.28;
      this.particleMat.opacity = 0.8;
    } else {
      fallSpeed = 34.0;
      this.particleMat.color.setHex(0x93c5fd);
      this.particleMat.size = 0.18;
      this.particleMat.opacity = 0.65;
    }

    for (let i = 0; i < this.particleCount; i++) {
      const idx = i * 3;
      positions[idx + 1] -= fallSpeed * delta;
      positions[idx + 0] += slantX * delta;
      positions[idx + 2] += slantZ * delta;

      if (positions[idx + 1] < 0) {
        positions[idx + 1] = 24 + Math.random() * 6;
        positions[idx + 0] = (Math.random() - 0.5) * 55;
        positions[idx + 2] = centerZ + (Math.random() - 0.25) * 75;
      }
    }
    this.particleGeo.attributes.position.needsUpdate = true;
    this.updateLightning(delta, weatherType);
  }

  setAudioEngine(audioEngine) {
    this.audioEngine = audioEngine;
  }

  triggerLightningStrike() {
    this.lightningFlash = 1.0;
    if (this.audioEngine) {
      this.audioEngine.playLightningThunder();
    }
  }

  updateLightning(delta, weatherType) {
    const isStormy = weatherType === 'ion_storm' || (this.currentBiome && this.currentBiome.id === 'glass_crater') || weatherType === 'blizzard';
    if (!isStormy) {
      if (this.lightningFlash > 0) {
        this.lightningFlash = Math.max(0, this.lightningFlash - delta * 4.0);
        this.applyAtmosphereLighting();
      }
      return;
    }

    this.lightningTimer += delta;
    if (this.lightningTimer >= this.nextLightningTime) {
      this.lightningTimer = 0;
      this.nextLightningTime = 8 + Math.random() * 14;
      this.triggerLightningStrike();
    }

    if (this.lightningFlash > 0) {
      // Rapid decay with realistic flicker
      this.lightningFlash = Math.max(0, this.lightningFlash - delta * 3.2);
      this.applyAtmosphereLighting();
    }
  }

  updateDayNightLighting(timeOfDay = 8.5, weatherType = 'clear', currentBiome = null, headlightsOn = true, delta = 0.016) {
    if (currentBiome) this.currentBiome = currentBiome;
    if (!this.currentBiome) return;

    this.lastTimeOfDay = timeOfDay;
    this.lastWeatherType = weatherType;

    // Time periods:
    // 05:00 - 07:30 : Dawn / Aurora Sunrise
    // 07:30 - 16:30 : Full Daylight
    // 16:30 - 19:30 : Golden Hour Sunset
    // 19:30 - 22:00 : Twilight / Dusk
    // 22:00 - 05:00 : Arctic Night (Moonlight, Aurora, Stars)
    const t = timeOfDay;
    let dayProgress = 1.0; // 0 = midnight, 1 = midday
    let skyColor = new THREE.Color(this.currentBiome.colorSky || 0x111620);
    let fogColor = new THREE.Color(this.currentBiome.colorFog || 0x151b26);
    let sunColor = new THREE.Color(this.currentBiome.sunColor || 0xffeedd);
    let ambientIntensity = this.currentBiome.ambientIntensity || 0.5;
    let sunIntensity = this.currentBiome.sunIntensity || 1.1;
    let fogDensity = this.currentBiome.fogDensity || 0.016;

    // Equal Duration Day/Night Cycle:
    // Exactly 12.0 Hours Daytime (06:00 to 18:00)
    // Exactly 12.0 Hours Nighttime (18:00 to 06:00)
    if (t >= 7.5 && t < 16.5) {
      // Full Daylight (9.0 hours)
      dayProgress = 1.0;
      sunColor.setHex(0xfff7e6);
      ambientIntensity = 0.54;
      sunIntensity = 1.18;
    } else if (t >= 6.0 && t < 7.5) {
      // Dawn / Sunrise (1.5 hours: 06:00 - 07:30)
      const blend = (t - 6.0) / 1.5;
      dayProgress = blend;
      const dawnSky = new THREE.Color(0xb45309).lerp(new THREE.Color(0x38bdf8), blend * 0.7);
      skyColor.copy(dawnSky);
      fogColor = new THREE.Color(0x78350f).lerp(fogColor, blend);
      sunColor = new THREE.Color(0xff9800).lerp(new THREE.Color(0xfff7e6), blend);
      ambientIntensity = THREE.MathUtils.lerp(0.24, 0.54, blend);
      sunIntensity = THREE.MathUtils.lerp(0.35, 1.18, blend);
    } else if (t >= 16.5 && t < 18.0) {
      // Golden Hour Sunset (1.5 hours: 16:30 - 18:00)
      const blend = (t - 16.5) / 1.5;
      dayProgress = 1.0 - blend;
      const sunsetSky = new THREE.Color(0xd97706).lerp(new THREE.Color(0x991b1b), blend * 0.7);
      skyColor = skyColor.lerp(sunsetSky, 0.85);
      fogColor = fogColor.lerp(new THREE.Color(0x7c2d12), 0.75);
      sunColor = new THREE.Color(0xf97316).lerp(new THREE.Color(0xdc2626), blend * 0.6);
      ambientIntensity = THREE.MathUtils.lerp(0.54, 0.26, blend);
      sunIntensity = THREE.MathUtils.lerp(1.18, 0.45, blend);
    } else if (t >= 18.0 && t < 19.5) {
      // Twilight / Dusk (1.5 hours: 18:00 - 19:30)
      const blend = (t - 18.0) / 1.5;
      dayProgress = 0.25 * (1.0 - blend);
      skyColor = new THREE.Color(0x1e1b4b).lerp(new THREE.Color(0x020617), blend);
      fogColor = new THREE.Color(0x0f172a).lerp(new THREE.Color(0x060911), blend);
      sunColor = new THREE.Color(0x93c5fd); // Transitioning to moonlight
      ambientIntensity = THREE.MathUtils.lerp(0.26, 0.16, blend);
      sunIntensity = THREE.MathUtils.lerp(0.45, 0.24, blend);
    } else if (t >= 4.5 && t < 6.0) {
      // Pre-Dawn Celestial Awakening (1.5 hours: 04:30 - 06:00)
      const blend = (t - 4.5) / 1.5;
      dayProgress = blend * 0.25;
      skyColor = new THREE.Color(0x020617).lerp(new THREE.Color(0x1e1b4b), blend);
      fogColor = new THREE.Color(0x060911).lerp(new THREE.Color(0x0f172a), blend);
      sunColor = new THREE.Color(0x94b4d6);
      ambientIntensity = THREE.MathUtils.lerp(0.16, 0.24, blend);
      sunIntensity = THREE.MathUtils.lerp(0.24, 0.35, blend);
    } else {
      // Deep Arctic Night (19:30 to 04:30 = 9.0 hours)
      dayProgress = 0.0;
      skyColor.setHex(0x020617);
      fogColor.setHex(0x060911);
      sunColor.setHex(0xa5c4e8); // Silvery moonlight
      ambientIntensity = 0.18;
      sunIntensity = 0.28;
      fogDensity = 0.013;
    }

    // Weather impact on sky, fog, and light
    if (weatherType === 'acid_drizzle' || weatherType === 'rain') {
      skyColor.multiplyScalar(0.75);
      fogColor.multiplyScalar(0.8);
      ambientIntensity *= 0.82;
      sunIntensity *= 0.65;
      fogDensity = Math.max(fogDensity, 0.022);
    } else if (weatherType === 'torrential_rain') {
      skyColor.multiplyScalar(0.55);
      fogColor.multiplyScalar(0.65);
      ambientIntensity *= 0.7;
      sunIntensity *= 0.4;
      fogDensity = Math.max(fogDensity, 0.032);
    } else if (weatherType === 'freezing_rain' || weatherType === 'blizzard') {
      skyColor.lerp(new THREE.Color(0x94a3b8), 0.5);
      fogColor.lerp(new THREE.Color(0x64748b), 0.6);
      ambientIntensity *= 0.85;
      sunIntensity *= 0.45;
      fogDensity = Math.max(fogDensity, 0.038);
    } else if (weatherType === 'heavy_mist' || weatherType === 'dense_fog') {
      fogDensity = Math.max(fogDensity, 0.045);
      ambientIntensity *= 0.85;
      sunIntensity *= 0.55;
    }

    // Substantial forward visibility boost when vehicle headlights are on at night
    if (headlightsOn && dayProgress < 0.35) {
      ambientIntensity += 0.18;
    }

    // Lightning strike overlay
    const flash = this.lightningFlash || 0;
    if (flash > 0.01) {
      const flashSky = new THREE.Color(0xc084fc).lerp(new THREE.Color(0xe0e7ff), 0.5);
      skyColor.lerp(flashSky, Math.min(1.0, flash * 0.9));
      fogColor.lerp(flashSky, Math.min(1.0, flash * 0.75));
      ambientIntensity += flash * 2.0;
      sunIntensity += flash * 3.5;
    }

    this.scene.background.copy(skyColor);
    this.fog.color.copy(fogColor);
    this.fog.density = fogDensity;
    this.ambientLight.intensity = ambientIntensity;
    this.sunLight.intensity = sunIntensity;
    this.sunLight.color.copy(sunColor);

    this.updateAuroraAndStars(delta, timeOfDay, weatherType);
  }

  updateAuroraAndStars(delta = 0.016, timeOfDay = 8.5, weatherType = 'clear') {
    const t = timeOfDay;
    // Calculate night intensity factor: 0.0 (daylight) to 1.0 (deep night)
    let nightFactor = 0.0;
    if (t < 5.0 || t >= 19.5) {
      nightFactor = 1.0;
    } else if (t >= 5.0 && t < 7.0) {
      nightFactor = (7.0 - t) / 2.0;
    } else if (t >= 17.5 && t < 19.5) {
      nightFactor = (t - 17.5) / 2.0;
    }

    // Weather impact on celestial visibility
    let weatherFactor = 1.0;
    if (weatherType === 'torrential_rain' || weatherType === 'blizzard') {
      weatherFactor = 0.1;
    } else if (weatherType === 'rain' || weatherType === 'freezing_rain') {
      weatherFactor = 0.4;
    } else if (weatherType === 'heavy_mist' || weatherType === 'dense_fog') {
      weatherFactor = 0.3;
    }

    // Starfield twinkle and fade
    if (this.starMat) {
      this.starMat.opacity = Math.max(0.0, nightFactor * 0.85 * weatherFactor);
    }

    // Aurora ribbons undulation and opacity
    if (this.auroraRibbons && this.auroraRibbons.length > 0) {
      this.auroraTime += delta * 0.65;
      const aTime = this.auroraTime;

      this.auroraRibbons.forEach((ribbon, rIdx) => {
        const targetOpacity = ribbon.config.opacity * nightFactor * weatherFactor;
        ribbon.mat.opacity = targetOpacity;

        if (targetOpacity > 0.01) {
          const posAttr = ribbon.mesh.geometry.attributes.position;
          const basePos = ribbon.basePos;
          const count = posAttr.count;

          for (let i = 0; i < count; i++) {
            const bx = basePos.getX(i);
            const by = basePos.getY(i);
            const bz = basePos.getZ(i);

            // Composite sinusoidal displacement for flowing curtains of light
            const wave1 = Math.sin(bx * 0.03 + aTime * 1.1 + rIdx * 1.8) * 5.0;
            const wave2 = Math.cos(bx * 0.015 - aTime * 0.7 + rIdx) * 3.0;
            const vertWave = Math.sin(bx * 0.025 + aTime * 0.8) * 3.5;

            posAttr.setXYZ(i, bx, by + vertWave, bz + wave1 + wave2);
          }
          posAttr.needsUpdate = true;
        }
      });
    }
  }

  applyAtmosphereLighting() {
    this.updateDayNightLighting(this.lastTimeOfDay || 8.5, this.lastWeatherType || 'clear', this.currentBiome);
  }

  setBiomeAtmosphere(biomeConfig) {
    if (!biomeConfig) return;
    this.currentBiome = biomeConfig;
    this.applyAtmosphereLighting();
  }

  updateLightFollow(targetPos) {
    if (!this.sunLight) return;
    const t = this.lastTimeOfDay || 8.5;
    const sunAngle = ((t - 6.0) / 24.0) * Math.PI * 2;
    const isNight = t < 5.5 || t > 19.5;

    let sunX = Math.cos(sunAngle) * 32;
    let sunY = Math.max(16, Math.sin(sunAngle) * 48);

    if (isNight) {
      // Moon positioned in the northeast sky
      sunX = -26;
      sunY = 38;
    }

    this.sunLight.position.set(targetPos.x + sunX, targetPos.y + sunY, targetPos.z + 16);
    this.sunLight.target.position.set(targetPos.x, targetPos.y, targetPos.z + 8);

    if (this.starfield) {
      this.starfield.position.set(targetPos.x, targetPos.y, targetPos.z);
    }
    if (this.auroraGroup) {
      this.auroraGroup.position.set(targetPos.x, targetPos.y, targetPos.z);
    }
  }

  onWindowResize() {
    if (!this.container || !this.renderer || !this.camera) return;
    const width = this.container.clientWidth;
    const height = this.container.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  render() {
    if (this.renderer && this.scene && this.camera) {
      this.renderer.render(this.scene, this.camera);
    }
  }
}


// --- FILE: src/engine/CameraController.js ---
/**
 * THE LONG MERIDIAN - Adaptive Dynamic Follow & Highway Sweeping Camera Controller
 * Smoothly follows vehicle/player along highway curves, prevents camera from lagging or losing vehicle,
 * applies speed-based lookahead and trauma screen shake.
 */

class CameraController {
  constructor(camera) {
    this.camera = camera;
    this.currentLookAt = new THREE.Vector3(0, 0, 0);
    this.currentPos = new THREE.Vector3(0, 22.0, -18.0);
    this.currentHeading = 0.0;
    this.initialized = false;

    // Baseline offsets calibrated for wide 24m highway
    this.offset = new THREE.Vector3(0, 22.5, -18.0);
    this.lookAheadDistance = 22.0;

    // Dynamic camera damping factors
    this.posDamping = 6.0;
    this.rotDamping = 4.2;

    // Screen shake / trauma system
    this.trauma = 0; // 0 to 1
    this.shakeOffset = new THREE.Vector3(0, 0, 0);
  }

  addTrauma(amount) {
    this.trauma = Math.min(1.0, this.trauma + amount);
  }

  update(delta, targetPos, forwardVelocity = 0, targetHeading = 0, roadHeading = 0) {
    if (!targetPos) return;

    // If first frame, snap camera immediately behind target
    if (!this.initialized) {
      this.currentHeading = (roadHeading !== undefined) ? roadHeading : (targetHeading || 0);
      const initDist = Math.abs(this.offset.z);
      const initH = this.offset.y;
      const sH = Math.sin(this.currentHeading);
      const cH = Math.cos(this.currentHeading);

      this.currentPos.set(
        targetPos.x - sH * initDist,
        targetPos.y + initH,
        targetPos.z - cH * initDist
      );
      this.currentLookAt.set(
        targetPos.x + sH * this.lookAheadDistance,
        targetPos.y + 1.2,
        targetPos.z + cH * this.lookAheadDistance
      );
      this.camera.position.copy(this.currentPos);
      this.camera.lookAt(this.currentLookAt);
      this.initialized = true;
      return;
    }

    // Blend road heading (72%) and vehicle yaw (28%) so camera anticipates highway turns
    // smoothly without whipping violently during sudden countersteers or micro-adjustments
    const effectiveTargetAngle = (roadHeading !== undefined && roadHeading !== null)
      ? roadHeading * 0.72 + (targetHeading || 0) * 0.28
      : (targetHeading || 0);

    // Shortest-arc angular interpolation
    let angleDiff = effectiveTargetAngle - this.currentHeading;
    angleDiff = Math.atan2(Math.sin(angleDiff), Math.cos(angleDiff));
    this.currentHeading += angleDiff * Math.min(1.0, delta * this.rotDamping);

    // Dynamic distance & lookahead scaling with forward speed
    const normalizedSpeed = Math.max(0, Math.min(1.6, Math.abs(forwardVelocity) / 35.0));
    const dynamicLookAhead = this.lookAheadDistance + normalizedSpeed * 11.0;
    const dynamicHeight = this.offset.y + normalizedSpeed * 3.2;
    const dynamicDistance = Math.abs(this.offset.z) + normalizedSpeed * 4.0;

    const sinH = Math.sin(this.currentHeading);
    const cosH = Math.cos(this.currentHeading);

    // Calculate desired camera position: placed behind vehicle along smoothed heading
    const desiredPos = new THREE.Vector3(
      targetPos.x - sinH * dynamicDistance,
      targetPos.y + dynamicHeight,
      targetPos.z - cosH * dynamicDistance
    );

    // Calculate desired look-at point: placed ahead of vehicle along smoothed heading
    // CRITICAL FIX: LookAt X now tracks targetPos.x directly along heading tangent, never * 0.5!
    const desiredLookAt = new THREE.Vector3(
      targetPos.x + sinH * dynamicLookAhead,
      targetPos.y + 1.2,
      targetPos.z + cosH * dynamicLookAhead
    );

    // Apply trauma decay and shake calculation
    if (this.trauma > 0) {
      const shakeMag = Math.pow(this.trauma, 2) * 1.5;
      this.shakeOffset.set(
        (Math.random() * 2 - 1) * shakeMag,
        (Math.random() * 2 - 1) * shakeMag * 0.5,
        (Math.random() * 2 - 1) * shakeMag
      );
      this.trauma = Math.max(0, this.trauma - delta * 1.8);
    } else {
      this.shakeOffset.set(0, 0, 0);
    }

    // Smooth position and look-at interpolation
    const lerpFactor = Math.min(1.0, delta * this.posDamping);
    this.currentPos.lerp(desiredPos, lerpFactor);
    this.currentLookAt.lerp(desiredLookAt, lerpFactor * 1.2);

    // Safety safeguard: never let camera be more than 40m away horizontally from player
    const distToTarget = Math.hypot(this.currentPos.x - targetPos.x, this.currentPos.z - targetPos.z);
    if (distToTarget > 45.0) {
      this.currentPos.copy(desiredPos);
      this.currentLookAt.copy(desiredLookAt);
    }

    this.camera.position.copy(this.currentPos).add(this.shakeOffset);
    this.camera.lookAt(this.currentLookAt);
  }
}


// --- FILE: src/engine/TouchInput.js ---
/**
 * THE LONG MERIDIAN - Touch & Keyboard Input Manager
 * Non-latching, reliable input mapping for both tablet multitouch and keyboard.
 * Keyboard inputs reset instantaneously on keyup; touch inputs take precedence when actively held.
 */

class TouchInput {
  constructor() {
    // Current resolved input state
    this.steer = 0.0;       // -1.0 (left) to +1.0 (right)
    this.throttle = 0.0;    // 0.0 to 1.0
    this.brake = 0.0;       // 0.0 to 1.0
    this.handbrake = false; // boolean
    this.interact = false;  // boolean
    this.lights = false;    // toggle
    this.horn = false;      // boolean
    this.footMoveX = 0.0;   // for player on foot
    this.footMoveZ = 0.0;   // for player on foot

    // Active touch gesture flags
    this.touchSteerActive = false;
    this.touchSteerVal = 0.0;

    this.touchThrottleActive = false;
    this.touchThrottleVal = 0.0;

    this.touchBrakeActive = false;
    this.touchBrakeVal = 0.0;

    this.touchHandbrakeActive = false;
    this.touchHandbrakeVal = false;

    this.onToggleIgnition = null;
    this.onOpenJournal = null;
    this.onHonkHorn = null;
    this.onToggle4WD = null;
    this.onTogglePrimina = null;

    // Keyboard state tracking
    this.keys = {};

    this.initKeyboard();
  }

  initKeyboard() {
    window.addEventListener('keydown', (e) => {
      this.keys[e.code] = true;
      if (e.code === 'KeyE') this.interact = true;
      if (e.code === 'KeyL') this.lights = !this.lights;
      if (e.code === 'KeyH') {
        this.horn = true;
        if (this.onHonkHorn) this.onHonkHorn();
      }
      if (e.code === 'KeyX' && this.onToggle4WD) this.onToggle4WD();
      if (e.code === 'KeyP' && this.onTogglePrimina) this.onTogglePrimina();
      if (e.code === 'KeyI' && this.onToggleIgnition) this.onToggleIgnition();
      if ((e.code === 'KeyJ' || e.code === 'KeyM') && this.onOpenJournal) this.onOpenJournal();
    });

    window.addEventListener('keyup', (e) => {
      this.keys[e.code] = false;
      if (e.code === 'KeyE') this.interact = false;
      if (e.code === 'KeyH') this.horn = false;
    });

    // Reset all inputs if window loses focus
    window.addEventListener('blur', () => {
      this.keys = {};
      this.steer = 0.0;
      this.throttle = 0.0;
      this.brake = 0.0;
      this.handbrake = false;
    });
  }

  update() {
    // 1. Keyboard readings (zero if not pressed)
    let kSteer = 0.0;
    if (this.keys['KeyA'] || this.keys['ArrowLeft']) kSteer -= 1.0;
    if (this.keys['KeyD'] || this.keys['ArrowRight']) kSteer += 1.0;

    const kThrottle = (this.keys['KeyW'] || this.keys['ArrowUp']) ? 1.0 : 0.0;
    const kBrake = (this.keys['KeyS'] || this.keys['ArrowDown']) ? 1.0 : 0.0;
    const kHandbrake = !!this.keys['Space'];

    // 2. Resolve: Touch controls take precedence if actively engaged, otherwise keyboard
    this.steer = this.touchSteerActive ? this.touchSteerVal : kSteer;
    this.throttle = this.touchThrottleActive ? this.touchThrottleVal : kThrottle;
    this.brake = this.touchBrakeActive ? this.touchBrakeVal : kBrake;
    this.handbrake = this.touchHandbrakeActive ? this.touchHandbrakeVal : kHandbrake;

    // 3. Foot movement mapping (screen left is +X, screen right is -X)
    this.footMoveX = -this.steer;
    this.footMoveZ = this.throttle > 0 ? this.throttle : (this.brake > 0 ? -this.brake : 0);
  }

  setTouchSteer(value, active = true) {
    this.touchSteerActive = active;
    this.touchSteerVal = Math.max(-1.0, Math.min(1.0, value));
    if (!active) this.touchSteerVal = 0.0;
  }

  setTouchThrottle(value, active = true) {
    this.touchThrottleActive = active;
    this.touchThrottleVal = Math.max(0.0, Math.min(1.0, value));
    if (!active) this.touchThrottleVal = 0.0;
  }

  setTouchBrake(value, active = true) {
    this.touchBrakeActive = active;
    this.touchBrakeVal = Math.max(0.0, Math.min(1.0, value));
    if (!active) this.touchBrakeVal = 0.0;
  }

  setTouchHandbrake(state) {
    this.touchHandbrakeActive = state;
    this.touchHandbrakeVal = state;
  }
}


// --- FILE: src/world/BiomeManager.js ---
/**
 * THE LONG MERIDIAN - Biome Progression Manager
 * Handles procedural biome shifts, environment parameters, and atmospheric transitions.
 */

class BiomeManager {
  constructor(renderer, audioEngine) {
    this.renderer = renderer;
    this.audioEngine = audioEngine;

    this.biomeList = [
      CONFIG.BIOMES.MEDITERRANEAN_COAST,
      CONFIG.BIOMES.TEMPERATE_FOREST,
      CONFIG.BIOMES.ARID_DESERT,
      CONFIG.BIOMES.SAVANNA_STEPPE,
      CONFIG.BIOMES.TROPICAL_RAINFOREST,
      CONFIG.BIOMES.ALPINE_PEAKS,
      CONFIG.BIOMES.BOREAL_TAIGA,
      CONFIG.BIOMES.POLAR_TUNDRA
    ];

    this.biomeLength = 650; // Distance in meters per biome
    this.currentBiomeIndex = 0;
    this.currentBiome = this.biomeList[0];
    this.transitionProgress = 0; // 0 to 1 between current and next biome

    this.onBiomeChangeCallback = null;
  }

  update(currentZ) {
    const totalDist = Math.max(0, currentZ);
    const rawIndex = Math.floor(totalDist / this.biomeLength);
    const newIndex = rawIndex % this.biomeList.length;

    // Check if new biome milestone reached
    if (newIndex !== this.currentBiomeIndex) {
      this.currentBiomeIndex = newIndex;
      this.currentBiome = this.biomeList[newIndex];
      this.renderer.setBiomeAtmosphere(this.currentBiome);

      if (this.onBiomeChangeCallback) {
        this.onBiomeChangeCallback(this.currentBiome);
      }
    }

    // Sub-progress within current biome
    this.transitionProgress = (totalDist % this.biomeLength) / this.biomeLength;
  }

  getCurrentSurface(chunkZ) {
    const biome = this.currentBiome;
    switch (biome.id) {
      case 'mediterranean_coast':
        return Math.random() < 0.25 ? CONFIG.SURFACES.GRAVEL : CONFIG.SURFACES.ASPHALT;
      case 'temperate_forest':
        return Math.random() < 0.4 ? CONFIG.SURFACES.DIRT : CONFIG.SURFACES.ASPHALT;
      case 'arid_desert':
        return Math.random() < 0.65 ? CONFIG.SURFACES.SAND : CONFIG.SURFACES.ASPHALT;
      case 'savanna_steppe':
        return Math.random() < 0.7 ? CONFIG.SURFACES.RED_DIRT : CONFIG.SURFACES.GRAVEL;
      case 'tropical_rainforest':
        return Math.random() < 0.6 ? CONFIG.SURFACES.SLUDGE : (Math.random() < 0.3 ? CONFIG.SURFACES.STEEL_BRIDGE : CONFIG.SURFACES.DIRT);
      case 'alpine_peaks':
        return Math.random() < 0.45 ? CONFIG.SURFACES.ALPINE_ROCK : CONFIG.SURFACES.ASPHALT;
      case 'boreal_taiga':
        return Math.random() < 0.5 ? CONFIG.SURFACES.GRAVEL : (Math.random() < 0.3 ? CONFIG.SURFACES.ICE : CONFIG.SURFACES.STEEL_BRIDGE);
      case 'polar_tundra':
        return Math.random() < 0.75 ? CONFIG.SURFACES.ICE : CONFIG.SURFACES.ASPHALT;
      default:
        return CONFIG.SURFACES.ASPHALT;
    }
  }
}


// --- FILE: src/world/RoadGenerator.js ---
/**
 * THE LONG MERIDIAN - Enhanced Procedural 3D Road Ribbon Generator
 * Generates wide 2-lane crowned highway geometry with distinct gravel shoulders,
 * asphalt markings, drainage ditches, organic rolling terrain, delineator posts and guardrails.
 */

class RoadGenerator {
  constructor(scene, biomeManager) {
    this.scene = scene;
    this.biomeManager = biomeManager;

    this.chunks = [];
    this.nextChunkZ = 0;
    this.lastChunkX = 0;
    this.lastChunkAngle = 0;

    // Generated textures
    this.asphaltTexture = TextureGenerator.createAsphaltTexture();
    this.terrainTexture = TextureGenerator.createTerrainTexture('#1c231c');

    // Materials cache for road surfaces
    this.materials = {
      asphalt: new THREE.MeshStandardMaterial({
        map: this.asphaltTexture,
        roughness: 0.78,
        metalness: 0.12
      }),
      dirt: new THREE.MeshStandardMaterial({
        color: 0x3d2b1f,
        roughness: 0.95,
        metalness: 0.05
      }),
      gravel: new THREE.MeshStandardMaterial({
        color: 0x483e36,
        roughness: 0.9,
        metalness: 0.15
      }),
      ice: new THREE.MeshStandardMaterial({
        color: 0x9fb4c2,
        roughness: 0.2,
        metalness: 0.4
      }),
      sludge: new THREE.MeshStandardMaterial({
        color: 0x243a1a,
        roughness: 0.35,
        metalness: 0.2,
        emissive: 0x0c2206,
        emissiveIntensity: 0.4
      }),
      steel: new THREE.MeshStandardMaterial({
        color: 0x555b62,
        roughness: 0.45,
        metalness: 0.75
      }),
      curb: new THREE.MeshStandardMaterial({
        color: 0x1f1c1a,
        roughness: 0.9
      }),
      puddle: new THREE.MeshStandardMaterial({
        color: 0x141a22,
        roughness: 0.04,
        metalness: 0.95,
        transparent: true,
        opacity: 0.85
      }),
      reflectorRed: new THREE.MeshBasicMaterial({
        color: 0xef4444
      }),
      reflectorWhite: new THREE.MeshBasicMaterial({
        color: 0xf8fafc
      }),
      delineatorPost: new THREE.MeshStandardMaterial({
        color: 0xe2e8f0,
        roughness: 0.85
      }),
      terrain: new THREE.MeshStandardMaterial({
        map: this.terrainTexture,
        roughness: 0.95
      })
    };

    // Initialize initial stretch of road ahead
    for (let i = 0; i < CONFIG.WORLD.VISIBLE_CHUNKS; i++) {
      this.generateChunk();
    }
  }

  generateChunk() {
    const chunkLength = CONFIG.WORLD.CHUNK_LENGTH;
    const startZ = this.nextChunkZ;
    const endZ = startZ + chunkLength;
    const segments = CONFIG.WORLD.ROAD_SEGMENTS_PER_CHUNK;
    const stepZ = chunkLength / segments;

    const surface = this.biomeManager.getCurrentSurface(startZ);
    const biome = this.biomeManager.currentBiome;

    // Calibrated highway width & elevation profiles across all 8 natural biomes
    let baseWidth = CONFIG.WORLD.BASE_ROAD_WIDTH || 24.0;
    let hillAmplitude = 1.8;
    let curveIntensity = 0.06;

    switch (biome.id) {
      case 'mediterranean_coast':
        baseWidth = 23.0;
        hillAmplitude = 1.6;
        curveIntensity = 0.07; // Scenic coastal bends
        break;
      case 'temperate_forest':
        baseWidth = 24.0;
        hillAmplitude = 2.4; // Rolling deciduous hills
        curveIntensity = 0.055;
        break;
      case 'arid_desert':
        baseWidth = 26.0; // Wide open desert corridor
        hillAmplitude = 1.4; // Soft rolling dunes
        curveIntensity = 0.04; // Long high-speed straights
        break;
      case 'savanna_steppe':
        baseWidth = 25.0;
        hillAmplitude = 1.5;
        curveIntensity = 0.045;
        break;
      case 'tropical_rainforest':
        baseWidth = 21.0; // Dense jungle channel
        hillAmplitude = 2.0;
        curveIntensity = 0.08; // Twisting river valley bends
        break;
      case 'alpine_peaks':
        baseWidth = 19.5; // Mountain pass ledge
        hillAmplitude = 4.2; // Steep alpine grade & passes
        curveIntensity = 0.095; // Winding hairpins
        break;
      case 'boreal_taiga':
        baseWidth = 24.0;
        hillAmplitude = 1.8;
        curveIntensity = 0.05;
        break;
      case 'polar_tundra':
        baseWidth = 23.0; // Raised permafrost embankment
        hillAmplitude = 1.2;
        curveIntensity = 0.045;
        break;
      default:
        baseWidth = 24.0;
        break;
    }

    const points = [];
    let curX = this.lastChunkX;
    let curAngle = this.lastChunkAngle;

    for (let s = 0; s <= segments; s++) {
      const z = startZ + s * stepZ;
      const y = Math.sin(z * 0.016) * hillAmplitude + Math.cos(z * 0.005) * (hillAmplitude * 0.6);
      const width = baseWidth + Math.sin(z * 0.035) * 0.8;

      points.push({ x: curX, y: y, z: z, width: width });

      if (s < segments) {
        const curvatureDelta = (Math.sin(z * 0.012) * 0.5 + Math.sin(z * 0.004) * 1.1) * curveIntensity;
        curAngle += curvatureDelta;
        curX += Math.sin(curAngle) * stepZ * 0.45;
      }
    }

    this.lastChunkX = curX;
    this.lastChunkAngle = curAngle;
    this.nextChunkZ = endZ;

    const chunkMeshGroup = this.buildChunkMesh(points, surface, biome);
    this.scene.add(chunkMeshGroup);

    const chunkData = {
      startZ: startZ,
      endZ: endZ,
      surface: surface,
      points: points,
      meshGroup: chunkMeshGroup
    };

    this.chunks.push(chunkData);
    return chunkData;
  }

  buildChunkMesh(points, surface, biome) {
    const group = new THREE.Group();
    const numPoints = points.length;

    // 1. Crowned 5-Vertex Highway Deck Mesh
    // Points across cross-section:
    // v0: Left Shoulder Edge (u = 0.00, y - 0.03)
    // v1: Left Fog Line / Asphalt Margin (u = 0.122, y + 0.04)
    // v2: Center Crown Crest (u = 0.500, y + 0.08)
    // v3: Right Fog Line / Asphalt Margin (u = 0.878, y + 0.04)
    // v4: Right Shoulder Edge (u = 1.00, y - 0.03)
    const roadGeo = new THREE.BufferGeometry();
    const positions = [];
    const normals = [];
    const uvs = [];
    const indices = [];

    // 2. Multi-tier Undulating Terrain Skirt
    const terrainGeo = new THREE.BufferGeometry();
    const tPositions = [];
    const tNormals = [];
    const tUvs = [];
    const tIndices = [];

    const terrainWidth = 110.0;

    for (let i = 0; i < numPoints; i++) {
      const p = points[i];
      const halfW = p.width * 0.5;
      const pavedHalfW = halfW * 0.78; // Paved carriageway ~10.5m, gravel shoulder ~2.0m each side

      // --- ROAD DECK (5 vertices per step) ---
      const vZ = p.z;
      const vUvY = p.z * 0.06;

      // v0: Left outer gravel shoulder
      positions.push(p.x - halfW, p.y + 0.01, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.0, vUvY);

      // v1: Left white fog line / paved asphalt edge
      positions.push(p.x - pavedHalfW, p.y + 0.045, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.122, vUvY);

      // v2: Center highway crown
      positions.push(p.x, p.y + 0.075, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.5, vUvY);

      // v3: Right white fog line / paved asphalt edge
      positions.push(p.x + pavedHalfW, p.y + 0.045, vZ);
      normals.push(0, 1, 0);
      uvs.push(0.878, vUvY);

      // v4: Right outer gravel shoulder
      positions.push(p.x + halfW, p.y + 0.01, vZ);
      normals.push(0, 1, 0);
      uvs.push(1.0, vUvY);

      // --- TERRAIN SKIRT (6 vertices per step across ditches and rolling hills) ---
      // Left ditch, Left shoulder interface, Right shoulder interface, Right ditch, Outermost terrain hills
      const hillNoiseL = Math.sin(p.z * 0.03) * 2.8 + Math.cos(p.z * 0.01) * 4.5;
      const hillNoiseR = Math.sin(p.z * 0.025 + 1.2) * 3.2 + Math.cos(p.z * 0.008) * 5.0;

      const ditchDepthL = p.y - 0.35 + Math.sin(p.z * 0.08) * 0.15;
      const ditchDepthR = p.y - 0.35 + Math.cos(p.z * 0.08) * 0.15;
      const outerHeightL = p.y + hillNoiseL;
      const outerHeightR = p.y + hillNoiseR;

      // t0: Far Left Wilderness Horizon
      tPositions.push(p.x - halfW - terrainWidth, outerHeightL, vZ);
      // t1: Left Roadside Drainage Ditch Bottom
      tPositions.push(p.x - halfW - 2.8, ditchDepthL, vZ);
      // t2: Left Shoulder Connect
      tPositions.push(p.x - halfW, p.y - 0.02, vZ);
      // t3: Right Shoulder Connect
      tPositions.push(p.x + halfW, p.y - 0.02, vZ);
      // t4: Right Roadside Drainage Ditch Bottom
      tPositions.push(p.x + halfW + 2.8, ditchDepthR, vZ);
      // t5: Far Right Wilderness Horizon
      tPositions.push(p.x + halfW + terrainWidth, outerHeightR, vZ);

      const tUvY = p.z * 0.035;
      tUvs.push(0.0, tUvY, 0.35, tUvY, 0.48, tUvY, 0.52, tUvY, 0.65, tUvY, 1.0, tUvY);
      tNormals.push(0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0);

      // Indices for Quads
      if (i < numPoints - 1) {
        // Road ribbon quads (4 quad columns = 8 triangles)
        const b = i * 5;
        // Col 0: v0 -> v1
        indices.push(b, b + 5, b + 1, b + 1, b + 5, b + 6);
        // Col 1: v1 -> v2
        indices.push(b + 1, b + 6, b + 2, b + 2, b + 6, b + 7);
        // Col 2: v2 -> v3
        indices.push(b + 2, b + 7, b + 3, b + 3, b + 7, b + 8);
        // Col 3: v3 -> v4
        indices.push(b + 3, b + 8, b + 4, b + 4, b + 8, b + 9);

        // Terrain quads (t0->t1, t1->t2, and t3->t4, t4->t5)
        const tb = i * 6;
        // Left outer hill
        tIndices.push(tb, tb + 6, tb + 1, tb + 1, tb + 6, tb + 7);
        // Left ditch to shoulder
        tIndices.push(tb + 1, tb + 7, tb + 2, tb + 2, tb + 7, tb + 8);
        // Right shoulder to ditch
        tIndices.push(tb + 3, tb + 9, tb + 4, tb + 4, tb + 9, tb + 10);
        // Right ditch to outer hill
        tIndices.push(tb + 4, tb + 10, tb + 5, tb + 5, tb + 10, tb + 11);
      }
    }

    roadGeo.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
    roadGeo.setAttribute('normal', new THREE.Float32BufferAttribute(normals, 3));
    roadGeo.setAttribute('uv', new THREE.Float32BufferAttribute(uvs, 2));
    roadGeo.setIndex(indices);
    roadGeo.computeVertexNormals();

    let mat = this.materials.asphalt;
    if (surface.name.includes('Fango')) mat = this.materials.dirt;
    if (surface.name.includes('Ghiaccio')) mat = this.materials.ice;
    if (surface.name.includes('Tossica')) mat = this.materials.sludge;
    if (surface.name.includes('Ghiaia')) mat = this.materials.gravel;
    if (surface.name.includes('Acciaio')) mat = this.materials.steel;

    const roadMesh = new THREE.Mesh(roadGeo, mat);
    roadMesh.receiveShadow = true;
    group.add(roadMesh);

    // 2. Terrain Skirt Mesh
    terrainGeo.setAttribute('position', new THREE.Float32BufferAttribute(tPositions, 3));
    terrainGeo.setAttribute('normal', new THREE.Float32BufferAttribute(tNormals, 3));
    terrainGeo.setAttribute('uv', new THREE.Float32BufferAttribute(tUvs, 2));
    terrainGeo.setIndex(tIndices);
    terrainGeo.computeVertexNormals();

    const tMat = this.materials.terrain.clone();
    tMat.color.setHex(biome.colorGround);
    const terrainMesh = new THREE.Mesh(terrainGeo, tMat);
    terrainMesh.receiveShadow = true;
    group.add(terrainMesh);

    // 3. Highway Delineator Posts (Paline Segnadelimitatrici)
    this.addDelineators(group, points);

    // 4. Smooth Reflective Road Puddles
    if (biome.id !== 'iron_gorge') {
      this.addPuddles(group, points);
    }

    // 5. Continuous W-Beam Highway Guardrails on canyon gorges and deep bridge passes
    if (biome.id === 'iron_gorge' || biome.id === 'flooded_marshland') {
      this.addGuardrails(group, points);
    }

    return group;
  }

  addDelineators(group, points) {
    const postMat = this.materials.delineatorPost;
    const reflRed = this.materials.reflectorRed;
    const reflWhite = this.materials.reflectorWhite;

    // Place delineators every ~20m along chunk
    for (let i = 2; i < points.length; i += 5) {
      const p = points[i];
      const shoulderEdge = p.width * 0.5 + 0.35;

      // 1. Right Delineator Post (with Red Reflector facing approaching car)
      const postGeo = new THREE.BoxGeometry(0.12, 0.95, 0.08);
      const rightPost = new THREE.Mesh(postGeo, postMat);
      rightPost.position.set(p.x + shoulderEdge, p.y + 0.46, p.z);
      rightPost.castShadow = true;
      group.add(rightPost);

      const rightRefl = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.18, 0.02), reflRed);
      rightRefl.position.set(p.x + shoulderEdge, p.y + 0.72, p.z - 0.045);
      group.add(rightRefl);

      // 2. Left Delineator Post (with White/Amber Reflector facing approaching car)
      const leftPost = new THREE.Mesh(postGeo, postMat);
      leftPost.position.set(p.x - shoulderEdge, p.y + 0.46, p.z);
      leftPost.castShadow = true;
      group.add(leftPost);

      const leftRefl = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.18, 0.02), reflWhite);
      leftRefl.position.set(p.x - shoulderEdge, p.y + 0.72, p.z - 0.045);
      group.add(leftRefl);
    }
  }

  addPuddles(group, points) {
    const puddleMat = this.materials.puddle;
    for (let i = 2; i < points.length - 2; i += 8) {
      if (Math.random() < 0.4) {
        const p = points[i];
        // Situate slightly off-center in the tire tracks
        const lateralOffset = (Math.random() > 0.5 ? 1 : -1) * (p.width * 0.22 + Math.random() * 1.2);
        const radiusX = 1.4 + Math.random() * 1.4;
        const radiusZ = 2.6 + Math.random() * 2.2;

        const puddleGeo = new THREE.PlaneGeometry(radiusX * 2, radiusZ * 2);
        const puddle = new THREE.Mesh(puddleGeo, puddleMat);
        puddle.rotation.x = -Math.PI / 2;
        puddle.position.set(p.x + lateralOffset, p.y + 0.052, p.z);
        puddle.receiveShadow = true;
        group.add(puddle);
      }
    }
  }

  addGuardrails(group, points) {
    const railMat = this.materials.steel;
    const postMat = this.materials.steel;
    const reflMat = this.materials.reflectorRed;

    for (let i = 0; i < points.length; i += 3) {
      const p = points[i];
      const railX = p.width * 0.5 + 0.65;

      // Left & Right galvanized C-channel posts
      const postGeo = new THREE.BoxGeometry(0.14, 1.05, 0.14);
      const leftPost = new THREE.Mesh(postGeo, postMat);
      leftPost.position.set(p.x - railX, p.y + 0.5, p.z);
      leftPost.castShadow = true;
      group.add(leftPost);

      const rightPost = new THREE.Mesh(postGeo, postMat);
      rightPost.position.set(p.x + railX, p.y + 0.5, p.z);
      rightPost.castShadow = true;
      group.add(rightPost);

      // Amber Cat's Eye Reflector facing approaching car (+Z)
      const leftRefl = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.14, 0.04), reflMat);
      leftRefl.position.set(p.x - railX + 0.08, p.y + 0.65, p.z - 0.08);
      group.add(leftRefl);

      const rightRefl = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.14, 0.04), reflMat);
      rightRefl.position.set(p.x + railX - 0.08, p.y + 0.65, p.z - 0.08);
      group.add(rightRefl);

      // Double-wave corrugated W-beam horizontal rail with proper curve orientation
      if (i < points.length - 3) {
        const pNext = points[i + 3];
        const spanDist = Math.hypot(pNext.x - p.x, pNext.z - p.z);
        const curveAngle = Math.atan2(pNext.x - p.x, pNext.z - p.z);
        const avgRailX = (p.width + pNext.width) * 0.25 + 0.65;
        const beamGeo = new THREE.BoxGeometry(0.12, 0.32, spanDist);

        const leftBeam = new THREE.Mesh(beamGeo, railMat);
        leftBeam.position.set(
          (p.x + pNext.x) * 0.5 - avgRailX,
          (p.y + pNext.y) * 0.5 + 0.65,
          (p.z + pNext.z) * 0.5
        );
        leftBeam.rotation.y = curveAngle;
        leftBeam.castShadow = true;
        group.add(leftBeam);

        const rightBeam = new THREE.Mesh(beamGeo, railMat);
        rightBeam.position.set(
          (p.x + pNext.x) * 0.5 + avgRailX,
          (p.y + pNext.y) * 0.5 + 0.65,
          (p.z + pNext.z) * 0.5
        );
        rightBeam.rotation.y = curveAngle;
        rightBeam.castShadow = true;
        group.add(rightBeam);
      }
    }
  }

  update(playerZ) {
    while (this.nextChunkZ < playerZ + (CONFIG.WORLD.VISIBLE_CHUNKS * CONFIG.WORLD.CHUNK_LENGTH)) {
      this.generateChunk();
    }

    const despawnZ = playerZ - CONFIG.WORLD.DESPAWN_DISTANCE;
    for (let i = this.chunks.length - 1; i >= 0; i--) {
      const chunk = this.chunks[i];
      if (chunk.endZ < despawnZ) {
        this.scene.remove(chunk.meshGroup);
        chunk.meshGroup.traverse((child) => {
          if (child.isMesh) {
            child.geometry.dispose();
          }
        });
        this.chunks.splice(i, 1);
      }
    }
  }

  getRoadInfoAt(z) {
    for (const chunk of this.chunks) {
      if (z >= chunk.startZ && z <= chunk.endZ) {
        const pts = chunk.points;
        for (let i = 0; i < pts.length - 1; i++) {
          if (z >= pts[i].z && z <= pts[i + 1].z) {
            const t = (z - pts[i].z) / (pts[i + 1].z - pts[i].z);
            const x = pts[i].x + (pts[i + 1].x - pts[i].x) * t;
            const y = pts[i].y + (pts[i + 1].y - pts[i].y) * t;
            const width = pts[i].width + (pts[i + 1].width - pts[i].width) * t;
            const dx = pts[i + 1].x - pts[i].x;
            const dz = pts[i + 1].z - pts[i].z;
            const roadAngle = Math.atan2(dx, dz);
            return { x, y, width, roadAngle, surface: chunk.surface, inBounds: true };
          }
        }
      }
    }

    // Smooth extrapolation if query is slightly ahead or behind active chunks (prevents jump to 0)
    if (this.chunks.length > 0) {
      const lastChunk = this.chunks[this.chunks.length - 1];
      const pts = lastChunk.points;
      const lastPt = pts[pts.length - 1];
      if (z > lastPt.z) {
        const extraZ = z - lastPt.z;
        return {
          x: lastPt.x + Math.sin(this.lastChunkAngle) * extraZ,
          y: lastPt.y,
          width: lastPt.width,
          roadAngle: this.lastChunkAngle,
          surface: lastChunk.surface,
          inBounds: true
        };
      }
      const firstChunk = this.chunks[0];
      const firstPt = firstChunk.points[0];
      if (z < firstPt.z) {
        return {
          x: firstPt.x,
          y: firstPt.y,
          width: firstPt.width,
          roadAngle: 0.0,
          surface: firstChunk.surface,
          inBounds: true
        };
      }
    }

    return { x: 0, y: 0, width: CONFIG.WORLD.BASE_ROAD_WIDTH || 24.0, roadAngle: 0.0, surface: CONFIG.SURFACES.ASPHALT, inBounds: false };
  }
}


// --- FILE: src/world/ScenerySpawner.js ---
/**
 * THE LONG MERIDIAN - Enhanced Scenery & Roadside Environment Spawner
 * Spawns lush multi-layered pine trees, weathered boulders, utility poles with hanging sagged power lines, and wrecks.
 */

class ScenerySpawner {
  constructor(scene, roadGenerator, biomeManager) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;
    this.biomeManager = biomeManager;

    this.props = [];
    this.nextSpawnZ = 12;
    this.spawnInterval = 7.0;

    this.lastPolePos = null;

    this.initSharedAssets();
  }

  initSharedAssets() {
    this.geoTrunk = new THREE.CylinderGeometry(0.28, 0.45, 3.8, 6);
    this.geoPineCone = new THREE.ConeGeometry(2.0, 4.5, 6);
    this.geoRock = new THREE.DodecahedronGeometry(1.3, 1);
    this.geoPole = new THREE.CylinderGeometry(0.14, 0.18, 7.5, 6);
    this.geoCrossArm = new THREE.BoxGeometry(2.6, 0.2, 0.2);

    this.matTrunk = new THREE.MeshStandardMaterial({ color: 0x332219, roughness: 0.95 });
    this.matPine1 = new THREE.MeshStandardMaterial({ color: 0x16261b, roughness: 0.85 });
    this.matPine2 = new THREE.MeshStandardMaterial({ color: 0x1d3324, roughness: 0.85 });
    this.matRock = new THREE.MeshStandardMaterial({ color: 0x48423d, roughness: 0.9 });
    this.matPole = new THREE.MeshStandardMaterial({ color: 0x2b2724, roughness: 0.85 });
    this.matWire = new THREE.LineBasicMaterial({ color: 0x111111, linewidth: 2 });
    this.matWreck = new THREE.MeshStandardMaterial({ color: 0x543228, roughness: 0.7, metalness: 0.4 });
    this.matBillboard = new THREE.MeshStandardMaterial({ color: 0x181a1c, roughness: 0.8 });

    // Highway Signage & Infrastructure Materials
    this.matMilestone = new THREE.MeshStandardMaterial({ color: 0xe2e8f0, roughness: 0.9 });
    this.matMilestoneCap = new THREE.MeshStandardMaterial({ color: 0xb91c1c, roughness: 0.6 });
    this.matSignPost = new THREE.MeshStandardMaterial({ color: 0x64748b, metalness: 0.8, roughness: 0.4 });
    this.matSignPlateYellow = new THREE.MeshStandardMaterial({ color: 0xf59e0b, roughness: 0.4 });
    this.matSignPlateWhite = new THREE.MeshStandardMaterial({ color: 0xf8fafc, roughness: 0.4 });
    this.matSignPlateBlue = new THREE.MeshStandardMaterial({ color: 0x0284c7, roughness: 0.4 });
    this.matSignBorderBlack = new THREE.MeshBasicMaterial({ color: 0x0f172a });
    this.matSignSymbolRed = new THREE.MeshBasicMaterial({ color: 0xdc2626 });
    this.matSnowPoleRed = new THREE.MeshBasicMaterial({ color: 0xdc2626 });
    this.matSnowPoleWhite = new THREE.MeshBasicMaterial({ color: 0xf8fafc });
    this.matFence = new THREE.MeshStandardMaterial({ color: 0x4a3728, roughness: 0.95 });
    this.matJersey = new THREE.MeshStandardMaterial({ color: 0x78716c, roughness: 0.9 });

    // Specialized biome materials
    this.matCrystalCyan = new THREE.MeshStandardMaterial({
      color: 0x06b6d4,
      emissive: 0x0891b2,
      emissiveIntensity: 0.85,
      roughness: 0.1,
      metalness: 0.9
    });
    this.matCrystalMagenta = new THREE.MeshStandardMaterial({
      color: 0xd946ef,
      emissive: 0xa21caf,
      emissiveIntensity: 0.9,
      roughness: 0.1,
      metalness: 0.9
    });
    this.matSnow = new THREE.MeshStandardMaterial({ color: 0xf1f5f9, roughness: 0.92 });
    this.matIce = new THREE.MeshStandardMaterial({ color: 0xa5f3fc, roughness: 0.15, metalness: 0.6, transparent: true, opacity: 0.85 });
    this.matRedRock = new THREE.MeshStandardMaterial({ color: 0x853a25, roughness: 0.92 });
    this.matRustedMetal = new THREE.MeshStandardMaterial({ color: 0x7c2d12, roughness: 0.8, metalness: 0.6 });
    this.matWoodLog = new THREE.MeshStandardMaterial({ color: 0x452a1c, roughness: 0.95 });
    this.matAmberGlow = new THREE.MeshBasicMaterial({ color: 0xf59e0b });
    this.matCyanGlow = new THREE.MeshBasicMaterial({ color: 0x06b6d4 });

    // Mediterranean Coast Materials
    this.matOliveFoliage = new THREE.MeshStandardMaterial({ color: 0x5a6b38, roughness: 0.86 });
    this.matMaritimePineFoliage = new THREE.MeshStandardMaterial({ color: 0x1d3824, roughness: 0.88 });
    this.matStoneWall = new THREE.MeshStandardMaterial({ color: 0x9e9382, roughness: 0.96 });

    // Temperate Forest Materials
    this.matDeciduousOak = new THREE.MeshStandardMaterial({ color: 0x275924, roughness: 0.85 });
    this.matBeechFoliage = new THREE.MeshStandardMaterial({ color: 0x366e2c, roughness: 0.84 });

    // Arid Desert Materials
    this.matDuneSand = new THREE.MeshStandardMaterial({ color: 0xc99452, roughness: 0.96 });
    this.matPalmTrunk = new THREE.MeshStandardMaterial({ color: 0x54402e, roughness: 0.92 });
    this.matPalmFronds = new THREE.MeshStandardMaterial({ color: 0x396324, roughness: 0.82 });
    this.matAdobe = new THREE.MeshStandardMaterial({ color: 0xb3825a, roughness: 0.96 });

    // Savanna & Steppe Materials
    this.matAcaciaCanopy = new THREE.MeshStandardMaterial({ color: 0x526b34, roughness: 0.88 });
    this.matBaobabTrunk = new THREE.MeshStandardMaterial({ color: 0x695747, roughness: 0.92 });
    this.matSavannaGrass = new THREE.MeshStandardMaterial({ color: 0xc2a452, roughness: 0.95 });

    // Tropical Rainforest Materials
    this.matJungleFoliage = new THREE.MeshStandardMaterial({ color: 0x12471f, roughness: 0.82 });
    this.matJungleCanopyDark = new THREE.MeshStandardMaterial({ color: 0x0a3315, roughness: 0.86 });

    // Alpine Peaks Materials
    this.matAlpineGranite = new THREE.MeshStandardMaterial({ color: 0x4a4d53, roughness: 0.92 });
    this.matAlpineScree = new THREE.MeshStandardMaterial({ color: 0x5e636d, roughness: 0.95 });
  }

  update(playerZ) {
    const maxZ = playerZ + 230;

    // 1. Advance Linear Infrastructure (milestones, utility poles, streetlights, signs, snow poles)
    // Evaluated at fixed engineering intervals of 10m
    if (!this.nextInfrastructureZ) this.nextInfrastructureZ = 10;
    while (this.nextInfrastructureZ < maxZ) {
      this.spawnLinearInfrastructureAt(this.nextInfrastructureZ);
      this.nextInfrastructureZ += 10.0;
    }

    // 2. Advance Territorial Compounds & Natural Formations (groves, compounds, canyon cliffs)
    // Evaluated at regular spatial steps of 24m
    if (!this.nextClusterZ) this.nextClusterZ = 16;
    while (this.nextClusterZ < maxZ) {
      this.spawnTerritorialClusterAt(this.nextClusterZ);
      this.nextClusterZ += 24.0;
    }

    // 3. Despawn props left behind
    const despawnZ = playerZ - 75;
    for (let i = this.props.length - 1; i >= 0; i--) {
      const prop = this.props[i];
      if (prop.position.z < despawnZ) {
        this.scene.remove(prop);
        this.props.splice(i, 1);
      }
    }
  }

  spawnLinearInfrastructureAt(z) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(z);
    const biome = this.biomeManager.currentBiome;
    const relZ = ((z % 650) + 650) % 650;
    const halfW = roadInfo.width * 0.5;
    if (!this.spawnedMilestones) this.spawnedMilestones = new Set();

    // 1. Milestone Marker Posts (Cippi Chilometrici) - Exactly every 100m on Right Shoulder
    const mileIndex = Math.floor(z / 100);
    const mileKey = `mile_${mileIndex}`;
    if (!this.spawnedMilestones.has(mileKey) && (z % 100) < 10) {
      this.spawnedMilestones.add(mileKey);
      const km = (z / 1000).toFixed(1);
      const post = this.createMilestonePost(
        roadInfo.x + halfW + 0.85,
        roadInfo.y,
        z,
        `PK ${km}`
      );
      this.scene.add(post);
      this.props.push(post);
    }

    // 2. Regulatory & Hazard Highway Signs
    const signKey = `sign_${Math.floor(z / 60)}_${biome.id}`;
    if (!this.spawnedMilestones.has(signKey)) {
      let signType = null;
      if (relZ >= 20 && relZ < 30) {
        signType = 'speed_80';
      } else if (biome.id === 'mediterranean_coast' && relZ >= 130 && relZ < 140) {
        signType = 'speed_80';
      } else if (biome.id === 'temperate_forest' && relZ >= 270 && relZ < 280) {
        signType = 'wildlife';
      } else if (biome.id === 'arid_desert' && relZ >= 130 && relZ < 140) {
        signType = 'desert_heat';
      } else if (biome.id === 'savanna_steppe' && relZ >= 270 && relZ < 280) {
        signType = 'wildlife';
      } else if (biome.id === 'tropical_rainforest' && relZ >= 40 && relZ < 50) {
        signType = 'flood';
      } else if (biome.id === 'alpine_peaks' && ((relZ >= 30 && relZ < 40) || (relZ >= 250 && relZ < 260))) {
        signType = 'rockfall';
      } else if (biome.id === 'boreal_taiga' && relZ >= 270 && relZ < 280) {
        signType = 'wildlife';
      } else if (biome.id === 'polar_tundra' && relZ >= 30 && relZ < 40) {
        signType = 'ice';
      }

      if (signType) {
        this.spawnedMilestones.add(signKey);
        const signMesh = this.createRoadSign(
          roadInfo.x + halfW + 1.25,
          roadInfo.y,
          z,
          signType
        );
        this.scene.add(signMesh);
        this.props.push(signMesh);
      }
    }

    // 3. Streetlights - Illuminated settlement hubs (8 real-world sectors, 5200m loop)
    const cycleZ = z % 5200;
    const isStreetlit =
      (cycleZ >= 100 && cycleZ <= 340) ||   // Sector 0: San Vito Harbor
      (cycleZ >= 750 && cycleZ <= 990) ||   // Sector 1: Valbruna Mill
      (cycleZ >= 1400 && cycleZ <= 1640) || // Sector 2: El Kantara Oasis
      (cycleZ >= 2050 && cycleZ <= 2290) || // Sector 3: Serengeti Outpost
      (cycleZ >= 2700 && cycleZ <= 2940) || // Sector 4: Rio Verde Station
      (cycleZ >= 3350 && cycleZ <= 3590) || // Sector 5: Valico Aquile Refuge
      (cycleZ >= 4000 && cycleZ <= 4240) || // Sector 6: Taiga Nord Depot
      (cycleZ >= 4650 && cycleZ <= 4890);   // Sector 7: Base Polare 80

    if (isStreetlit) {
      const lampInterval = 32;
      const lampIndex = Math.floor(z / lampInterval);
      const lampKey = `lamp_${lampIndex}`;
      if (!this.spawnedMilestones.has(lampKey) && (z % lampInterval) < 10) {
        this.spawnedMilestones.add(lampKey);
        // Alternate lamp side along highway to create realistic illuminated avenue
        const lampSide = (lampIndex % 2 === 0) ? -1 : 1;
        const lampX = roadInfo.x + lampSide * (halfW + 1.6);
        const lamp = this.createStreetlamp(
          lampX,
          roadInfo.y,
          z,
          lampSide
        );
        this.scene.add(lamp);
        this.props.push(lamp);
      }
    }

    // 4. Utility Power Poles - Telecommunication & power lines in civilized/working sectors
    const hasPoles = (
      biome.id === 'mediterranean_coast' ||
      biome.id === 'temperate_forest' ||
      biome.id === 'savanna_steppe' ||
      biome.id === 'boreal_taiga'
    );
    if (hasPoles) {
      const poleSide = (biome.id === 'temperate_forest') ? -1 : 1;
      const poleIndex = Math.floor(z / 36);
      const poleKey = `pole_${poleIndex}`;
      if (!this.spawnedMilestones.has(poleKey) && (z % 36) < 10) {
        this.spawnedMilestones.add(poleKey);
        const pole = this.createPowerPole(
          roadInfo.x + poleSide * (halfW + 3.2),
          roadInfo.y,
          z,
          poleSide
        );
        this.scene.add(pole);
        this.props.push(pole);
      }
    }

    // 5. Alpine & Arctic Snow Alignment Poles (Paline da Neve Catarifrangenti)
    if (biome.id === 'alpine_peaks' || biome.id === 'polar_tundra') {
      const snowIndex = Math.floor(z / 22);
      const snowKey = `snow_${snowIndex}`;
      if (!this.spawnedMilestones.has(snowKey) && (z % 22) < 10) {
        this.spawnedMilestones.add(snowKey);
        // Left & Right pair flanking asphalt edges
        [-1, 1].forEach((side) => {
          const pole = this.createSnowPole(
            roadInfo.x + side * (halfW + 0.35),
            roadInfo.y,
            z
          );
          this.scene.add(pole);
          this.props.push(pole);
        });
      }
    }
  }

  spawnTerritorialClusterAt(z) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(z);
    const biome = this.biomeManager.currentBiome;
    const relZ = ((z % 650) + 650) % 650;
    const halfW = roadInfo.width * 0.5;
    if (!this.spawnedMilestones) this.spawnedMilestones = new Set();

    let propsToSpawn = [];

    if (biome.id === 'mediterranean_coast') {
      // Zone 1: Rural dry stone walls & olive terraces
      if (relZ < 150) {
        propsToSpawn.push(this.createDryStoneWall(roadInfo.x + halfW + 3.8, roadInfo.y, z));
        if (Math.random() < 0.55) {
          propsToSpawn.push(this.createOliveTree(roadInfo.x - halfW - 4.8, roadInfo.y, z));
        }
      }
      // Zone 2 (180-260m): San Vito Harbor Coastal Fishery & Watchtower
      else if (relZ >= 180 && relZ < 260) {
        const clusterKey = `harbor_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(clusterKey)) {
          this.spawnedMilestones.add(clusterKey);
          propsToSpawn.push(this.createHarborFishery(roadInfo.x - halfW - 8.5, roadInfo.y, z));
        }
      }
      // Zone 3: Maritime umbrella pines & coastal guardrails
      else {
        propsToSpawn.push(this.createMaritimePine(roadInfo.x + halfW + 6.0, roadInfo.y, z));
        if (Math.random() < 0.45) {
          propsToSpawn.push(this.createOliveTree(roadInfo.x - halfW - 5.5, roadInfo.y, z));
        }
      }
    } else if (biome.id === 'temperate_forest') {
      // Zone 1: Split-rail fences and clearings
      if (relZ < 140) {
        propsToSpawn.push(this.createSplitRailFence(roadInfo.x + halfW + 4.2, roadInfo.y, z));
        propsToSpawn.push(this.createGrassTuft(roadInfo.x - halfW - 2.0, roadInfo.y, z));
      }
      // Zone 2 (180-260m): Valbruna Hydraulic Water Mill & Log Yard
      else if (relZ >= 180 && relZ < 260) {
        const millKey = `mill_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(millKey)) {
          this.spawnedMilestones.add(millKey);
          propsToSpawn.push(this.createWaterMill(roadInfo.x - halfW - 9.0, roadInfo.y, z));
        }
      }
      // Zone 3: Lush broadleaf stands of Deciduous Oaks & European Beeches
      else {
        propsToSpawn.push(this.createDeciduousOak(roadInfo.x - halfW - 6.0, roadInfo.y, z));
        propsToSpawn.push(this.createEuropeanBeech(roadInfo.x + halfW + 6.5, roadInfo.y, z));
      }
    } else if (biome.id === 'arid_desert') {
      // Zone 1 (180-260m): El Kantara Adobe Caravansary & Palm Oasis
      if (relZ >= 180 && relZ < 260) {
        const oasisKey = `oasis_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(oasisKey)) {
          this.spawnedMilestones.add(oasisKey);
          propsToSpawn.push(this.createOasisCaravansary(roadInfo.x - halfW - 8.5, roadInfo.y, z));
        }
      }
      // Zone 2: Sweeping sand dune ridges, date palms and sun-bleached wrecks
      else {
        propsToSpawn.push(this.createSandDuneRidge(roadInfo.x + halfW + 7.5, roadInfo.y, z, 1));
        if (Math.random() < 0.35) {
          propsToSpawn.push(this.createDatePalm(roadInfo.x - halfW - 5.5, roadInfo.y, z));
        }
        if (Math.random() < 0.25) {
          propsToSpawn.push(this.createWreck(roadInfo.x - halfW - 4.0, roadInfo.y, z));
        }
      }
    } else if (biome.id === 'savanna_steppe') {
      // Zone 1 (180-260m): Serengeti Ranger Station & Watchtower
      if (relZ >= 180 && relZ < 260) {
        const rangerKey = `ranger_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(rangerKey)) {
          this.spawnedMilestones.add(rangerKey);
          propsToSpawn.push(this.createRangerStation(roadInfo.x + halfW + 8.5, roadInfo.y, z));
        }
      }
      // Zone 2: Flat-topped umbrella acacias, monumental baobabs & dry golden straw
      else {
        propsToSpawn.push(this.createUmbrellaAcacia(roadInfo.x - halfW - 6.5, roadInfo.y, z));
        if (Math.random() < 0.35) {
          propsToSpawn.push(this.createBaobabTree(roadInfo.x + halfW + 11.0, roadInfo.y, z));
        }
        propsToSpawn.push(this.createGrassTuft(roadInfo.x + halfW + 2.5, roadInfo.y, z));
      }
    } else if (biome.id === 'tropical_rainforest') {
      // Zone 1 (180-260m): Rio Verde Botanical Canopy Lab & Stilt Station
      if (relZ >= 180 && relZ < 260) {
        const labKey = `botanical_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(labKey)) {
          this.spawnedMilestones.add(labKey);
          propsToSpawn.push(this.createBotanicalLab(roadInfo.x - halfW - 8.5, roadInfo.y, z));
        }
      }
      // Zone 2: Gigantic buttressed rainforest trees with multi-layered canopy & lianas
      else {
        propsToSpawn.push(this.createRainforestGiant(roadInfo.x - halfW - 7.5, roadInfo.y, z));
        propsToSpawn.push(this.createRainforestGiant(roadInfo.x + halfW + 7.5, roadInfo.y, z));
        propsToSpawn.push(this.createGrassTuft(roadInfo.x - halfW - 2.0, roadInfo.y, z));
      }
    } else if (biome.id === 'alpine_peaks') {
      // Zone 1 (180-260m): Avalanche Defense Gallery & High Pass Shelter
      if (relZ >= 180 && relZ < 260) {
        const passKey = `pass_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(passKey)) {
          this.spawnedMilestones.add(passKey);
          propsToSpawn.push(this.createAvalancheTunnel(roadInfo.x, roadInfo.y, z));
        }
      }
      // Zone 2: Colossal dark granite canyon walls, jagged peaks & rockfall scree
      else {
        propsToSpawn.push(this.createAlpineGraniteWall(roadInfo.x - halfW - 4.5, roadInfo.y, z, -1));
        propsToSpawn.push(this.createAlpineGraniteWall(roadInfo.x + halfW + 4.5, roadInfo.y, z, 1));
        if (Math.random() < 0.4) {
          propsToSpawn.push(this.createRock(roadInfo.x + halfW + 2.5, roadInfo.y, z, 1.8));
        }
      }
    } else if (biome.id === 'boreal_taiga') {
      // Zone 1 (180-260m): Taiga Nord Forestry Station & Watchtower
      if (relZ >= 180 && relZ < 260) {
        const outpostKey = `forester_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(outpostKey)) {
          this.spawnedMilestones.add(outpostKey);
          propsToSpawn.push(this.createForesterOutpost(roadInfo.x + halfW + 11.0, roadInfo.y, z));
        }
      }
      // Zone 2: Dense stands of black spruce and paper birch
      else {
        [-1, 1].forEach((side) => {
          propsToSpawn.push(this.createForestStand(roadInfo.x + side * (halfW + 5.5), roadInfo.y, z, side));
        });
      }
    } else if (biome.id === 'polar_tundra') {
      // Zone 1 (180-260m): Arctic Geodesic Research Base 80 & METAR radar
      if (relZ >= 180 && relZ < 260) {
        const polarKey = `polar_${Math.floor(z / 650)}`;
        if (!this.spawnedMilestones.has(polarKey)) {
          this.spawnedMilestones.add(polarKey);
          propsToSpawn.push(this.createArcticGeodesicDome(roadInfo.x + halfW + 10.0, roadInfo.y, z));
        }
      }
      // Zone 2: Glacial ice spires & snow-blanketed conifers
      else {
        propsToSpawn.push(this.createSnowCoveredPines(roadInfo.x - halfW - 6.0, roadInfo.y, z));
        propsToSpawn.push(this.createGlacialIceSpire(roadInfo.x + halfW + 5.5, roadInfo.y, z));
      }
    }

    propsToSpawn.forEach((p) => {
      if (p) {
        this.scene.add(p);
        this.props.push(p);
      }
    });
  }

  // --- HIGHWAY INFRASTRUCTURE: MILESTONES & REGULATORY SIGNAGE ---
  createMilestonePost(x, y, z, text) {
    const group = new THREE.Group();
    // Concrete pillar
    const post = new THREE.Mesh(
      new THREE.BoxGeometry(0.32, 0.85, 0.22),
      this.matMilestone
    );
    post.position.y = 0.42;
    post.castShadow = true;
    group.add(post);

    // Red highway jurisdiction top cap
    const cap = new THREE.Mesh(
      new THREE.BoxGeometry(0.34, 0.16, 0.24),
      this.matMilestoneCap
    );
    cap.position.y = 0.9;
    group.add(cap);

    // Black text plaque facing driver (+Z)
    const plaque = new THREE.Mesh(
      new THREE.BoxGeometry(0.24, 0.28, 0.02),
      this.matSignBorderBlack
    );
    plaque.position.set(0, 0.52, -0.115);
    group.add(plaque);

    group.position.set(x, y, z);
    return group;
  }

  createRoadSign(x, y, z, signType) {
    const group = new THREE.Group();
    // Galvanized steel post
    const post = new THREE.Mesh(
      new THREE.CylinderGeometry(0.04, 0.04, 2.4, 6),
      this.matSignPost
    );
    post.position.y = 1.2;
    post.castShadow = true;
    group.add(post);

    let plate = null;
    let symbol = null;

    if (signType === 'speed_80') {
      // Circular European/International speed limit sign
      plate = new THREE.Mesh(
        new THREE.CylinderGeometry(0.48, 0.48, 0.04, 16),
        this.matSignPlateWhite
      );
      plate.rotation.x = Math.PI / 2;
      plate.position.set(0, 2.15, -0.04);
      group.add(plate);

      // Red border ring
      const ring = new THREE.Mesh(
        new THREE.TorusGeometry(0.44, 0.05, 4, 16),
        this.matSignSymbolRed
      );
      ring.position.set(0, 2.15, -0.06);
      group.add(ring);

      // Black "80" numerals bar
      symbol = new THREE.Mesh(
        new THREE.BoxGeometry(0.35, 0.22, 0.02),
        this.matSignBorderBlack
      );
      symbol.position.set(0, 2.15, -0.065);
      group.add(symbol);

    } else if (signType === 'ice') {
      // Blue triangular snowflake warning sign
      plate = new THREE.Mesh(
        new THREE.ConeGeometry(0.55, 0.75, 3),
        this.matSignPlateBlue
      );
      plate.position.set(0, 2.15, -0.04);
      plate.rotation.x = Math.PI;
      group.add(plate);

      // White snowflake center
      symbol = new THREE.Mesh(
        new THREE.BoxGeometry(0.24, 0.24, 0.02),
        this.matSignPlateWhite
      );
      symbol.position.set(0, 2.12, -0.06);
      group.add(symbol);

    } else {
      // Diamond yellow caution sign (industrial, wildlife, rockfall, flood, radiation)
      plate = new THREE.Mesh(
        new THREE.BoxGeometry(0.68, 0.68, 0.03),
        (signType === 'radiation') ? this.matSignPlateYellow : this.matSignPlateYellow
      );
      plate.rotation.z = Math.PI / 4;
      plate.position.set(0, 2.15, -0.04);
      group.add(plate);

      // Black inner hazard border
      const innerBorder = new THREE.Mesh(
        new THREE.BoxGeometry(0.58, 0.58, 0.035),
        this.matSignBorderBlack
      );
      innerBorder.rotation.z = Math.PI / 4;
      innerBorder.position.set(0, 2.15, -0.045);
      group.add(innerBorder);

      // Black symbol glyph
      symbol = new THREE.Mesh(
        new THREE.BoxGeometry(0.32, 0.32, 0.04),
        (signType === 'radiation') ? this.matSignSymbolRed : this.matSignPlateYellow
      );
      symbol.rotation.z = Math.PI / 4;
      symbol.position.set(0, 2.15, -0.05);
      group.add(symbol);
    }

    group.position.set(x, y, z);
    return group;
  }

  createSnowPole(x, y, z) {
    const group = new THREE.Group();
    // 2.4m tall arctic road snow marker stick with alternating red/white stripes
    const height = 2.4;
    const segments = 6;
    const segH = height / segments;

    for (let i = 0; i < segments; i++) {
      const mat = (i % 2 === 0) ? this.matSnowPoleRed : this.matSnowPoleWhite;
      const seg = new THREE.Mesh(
        new THREE.CylinderGeometry(0.035, 0.035, segH, 6),
        mat
      );
      seg.position.y = i * segH + segH * 0.5;
      group.add(seg);
    }

    group.position.set(x, y, z);
    return group;
  }

  createSplitRailFence(x, y, z) {
    const group = new THREE.Group();
    // Weathered rural wooden fence module (length 7m)
    [-3.2, 3.2].forEach((px) => {
      const post = new THREE.Mesh(
        new THREE.BoxGeometry(0.18, 1.35, 0.18),
        this.matFence
      );
      post.position.set(0, 0.65, px);
      post.castShadow = true;
      group.add(post);
    });

    // 2 horizontal cedar rails
    [0.45, 0.95].forEach((ry) => {
      const rail = new THREE.Mesh(
        new THREE.BoxGeometry(0.12, 0.12, 6.8),
        this.matFence
      );
      rail.position.set(0, ry, 0);
      rail.castShadow = true;
      group.add(rail);
    });

    group.position.set(x, y, z);
    return group;
  }

  createJerseyBarrier(x, y, z) {
    const group = new THREE.Group();
    // Highway concrete jersey barrier (trapezoidal profile, length 4m)
    const barrier = new THREE.Mesh(
      new THREE.BoxGeometry(0.45, 0.85, 3.9),
      this.matJersey
    );
    barrier.position.y = 0.42;
    barrier.castShadow = true;
    group.add(barrier);

    // Red-white reflective tape along upper edge
    const tape = new THREE.Mesh(
      new THREE.BoxGeometry(0.47, 0.12, 3.9),
      this.matSnowPoleRed
    );
    tape.position.y = 0.75;
    group.add(tape);

    group.position.set(x, y, z);
    return group;
  }

  // --- COHERENT TERRITORIAL COMPOUNDS ---
  createRefineryCompound(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // 1. Crushed gravel apron base
    const pad = new THREE.Mesh(
      new THREE.BoxGeometry(16, 0.15, 24),
      new THREE.MeshStandardMaterial({ color: 0x332a22, roughness: 0.95 })
    );
    pad.position.set(-4, 0.05, 0);
    pad.receiveShadow = true;
    group.add(pad);

    // 2. Cluster of 3 Cylindrical Fuel Storage Tanks in berm
    [-5, 0, 5].forEach((offsetZ, idx) => {
      const tank = new THREE.Mesh(
        new THREE.CylinderGeometry(3.6, 3.6, 6.5, 12),
        this.matRustedMetal
      );
      tank.position.set(-6 - (idx % 2) * 2, 3.3, offsetZ);
      tank.castShadow = true;
      group.add(tank);

      // Yellow hazard band
      const band = new THREE.Mesh(
        new THREE.CylinderGeometry(3.65, 3.65, 0.4, 12),
        this.matSignPlateYellow
      );
      band.position.set(-6 - (idx % 2) * 2, 4.0, offsetZ);
      group.add(band);
    });

    // 3. Overhead Industrial Pipeline Rack spanning across yard
    const pipe = new THREE.Mesh(
      new THREE.CylinderGeometry(0.3, 0.3, 18, 8),
      this.matRustedMetal
    );
    pipe.position.set(-3, 5.5, 0);
    pipe.rotation.x = Math.PI / 2;
    group.add(pipe);

    // 4. Two Flare Stacks with burning gas flames
    [-9, 9].forEach((flareZ) => {
      const flare = new THREE.Mesh(
        new THREE.CylinderGeometry(0.4, 0.7, 14, 6),
        this.matRustedMetal
      );
      flare.position.set(-10, 7.0, flareZ);
      flare.castShadow = true;
      group.add(flare);

      const flame = new THREE.Mesh(
        new THREE.ConeGeometry(0.8, 2.2, 5),
        new THREE.MeshBasicMaterial({ color: 0xff6600 })
      );
      flame.position.set(-10, 15.1, flareZ);
      group.add(flame);

      const fLight = new THREE.PointLight(0xff6600, 2.0, 24);
      fLight.position.set(-10, 15.1, flareZ);
      group.add(fLight);
    });

    // 5. Chain-link Security Fence along road frontage
    const fence = new THREE.Mesh(
      new THREE.BoxGeometry(0.1, 2.2, 24),
      new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.8, wireframe: true })
    );
    fence.position.set(3.5, 1.1, 0);
    group.add(fence);

    return group;
  }

  createForestStand(x, y, z, side) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // A rich, diverse northern stand of 6-8 conifers and birch trees
    const treeCount = 6 + Math.floor(Math.random() * 3);
    for (let t = 0; t < treeCount; t++) {
      const offsetX = (Math.random() - 0.5) * 9.0 + side * (t * 1.6);
      const offsetZ = (Math.random() - 0.5) * 18.0;
      const heightScale = 0.85 + Math.random() * 0.55;

      // 70% Alaskan Spruce, 30% Paper Birch
      const isBirch = Math.random() < 0.32;
      const tree = isBirch
        ? this.createBirchTree(offsetX, 0, offsetZ)
        : this.createPineTree(offsetX, 0, offsetZ);

      tree.scale.setScalar(heightScale);
      group.add(tree);
    }

    // Natural mossy granite rock outcropping at tree stand base
    const rock = this.createRock(side * 2.5, 0, (Math.random() - 0.5) * 5.0, 1.8);
    group.add(rock);

    // Fallen decaying moss log on forest floor
    const log = new THREE.Mesh(
      new THREE.CylinderGeometry(0.18, 0.22, 3.2, 5),
      this.matTrunk
    );
    log.rotation.z = Math.PI / 2;
    log.rotation.y = Math.random() * Math.PI;
    log.position.set(side * 3.0, 0.18, (Math.random() - 0.5) * 4.0);
    log.castShadow = true;
    group.add(log);

    return group;
  }

  createForesterOutpost(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Gravel clearing
    const clearing = new THREE.Mesh(
      new THREE.CylinderGeometry(14, 15, 0.15, 12),
      new THREE.MeshStandardMaterial({ color: 0x3d3224, roughness: 0.95 })
    );
    clearing.position.y = 0.05;
    group.add(clearing);

    // Wooden Fire Watchtower (16m)
    const tower = this.createForesterTower(0, 0, 0);
    group.add(tower);

    // Log cabin sleeping quarters
    const cabin = this.createLumberCabin(-7, 0, -4);
    group.add(cabin);

    // Stacked firewood logs
    const woodpile = new THREE.Mesh(
      new THREE.BoxGeometry(1.6, 1.2, 3.2),
      this.matWoodLog
    );
    woodpile.position.set(6, 0.6, 4);
    group.add(woodpile);

    return group;
  }

  createStiltVillage(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Wooden boardwalk pier running along water
    const pier = new THREE.Mesh(
      new THREE.BoxGeometry(2.4, 0.4, 26),
      this.matWoodLog
    );
    pier.position.set(0, 1.6, 0);
    group.add(pier);

    // 3 Stilt huts connected to the boardwalk
    [-8, 0, 8].forEach((offZ) => {
      const hut = this.createSwampStiltHut(-5, 0, offZ);
      group.add(hut);
    });

    return group;
  }

  createCrystalCluster(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Cluster of 4-6 crystal needles in a geode formation
    const count = 4 + Math.floor(Math.random() * 3);
    for (let c = 0; c < count; c++) {
      const offX = (Math.random() - 0.5) * 4.5;
      const offZ = (Math.random() - 0.5) * 4.5;
      const spire = this.createCrystalSpire(offX, 0, offZ);
      group.add(spire);
    }

    return group;
  }

  createJunkyardCluster(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Perimeter of stacked cargo containers and derelict trucks
    [-8, 0, 8].forEach((offZ, idx) => {
      const container = new THREE.Mesh(
        new THREE.BoxGeometry(2.6, 2.6, 6.2),
        new THREE.MeshStandardMaterial({
          color: (idx === 0) ? 0xb91c1c : (idx === 1) ? 0x0284c7 : 0x78716c,
          roughness: 0.7,
          metalness: 0.6
        })
      );
      container.position.set(4, 1.3, offZ);
      container.castShadow = true;
      group.add(container);
    });

    const wreck = this.createWreck(-1, 0, 0);
    group.add(wreck);

    return group;
  }

  createStreetlamp(x, y, z, side) {
    const group = new THREE.Group();
    const pole = new THREE.Mesh(this.geoPole, this.matPole);
    pole.position.y = 3.75;
    pole.castShadow = true;
    group.add(pole);

    // Overhanging curved boom arm extending over the road shoulder
    const armReach = 2.4;
    const armOffsetX = side > 0 ? -armReach * 0.5 : armReach * 0.5;
    const arm = new THREE.Mesh(new THREE.BoxGeometry(armReach, 0.16, 0.16), this.matPole);
    arm.position.set(armOffsetX, 7.3, 0);
    group.add(arm);

    // Diagonal support strut
    const strut = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.04, 1.6, 4), this.matPole);
    strut.position.set(side > 0 ? -0.8 : 0.8, 6.7, 0);
    strut.rotation.z = side > 0 ? 0.7 : -0.7;
    group.add(strut);

    // Heavy-duty sodium luminaire head
    const lampHeadX = side > 0 ? -armReach : armReach;
    const lampHead = new THREE.Mesh(
      new THREE.BoxGeometry(0.8, 0.28, 0.45),
      new THREE.MeshStandardMaterial({ color: 0x1f2937, metalness: 0.85, roughness: 0.3 })
    );
    lampHead.position.set(lampHeadX, 7.25, 0);
    group.add(lampHead);

    // Bright amber high-pressure sodium emitter bulb
    const emitter = new THREE.Mesh(
      new THREE.BoxGeometry(0.65, 0.08, 0.35),
      new THREE.MeshBasicMaterial({ color: 0xffb84d })
    );
    emitter.position.set(lampHeadX, 7.1, 0);
    group.add(emitter);

    // Volumetric sodium atmospheric light cone pool
    const coneGeo = new THREE.ConeGeometry(3.6, 7.0, 8, 1, true);
    coneGeo.translate(0, -3.5, 0);
    const coneMat = new THREE.MeshBasicMaterial({
      color: 0xffaa33,
      transparent: true,
      opacity: 0.12,
      blending: THREE.AdditiveBlending,
      side: THREE.DoubleSide,
      depthWrite: false
    });
    const lightCone = new THREE.Mesh(coneGeo, coneMat);
    lightCone.position.set(lampHeadX, 7.1, 0);
    group.add(lightCone);

    // High-Pressure Sodium SpotLight bathing asphalt in amber glow
    const light = new THREE.SpotLight(0xffb347, 4.6, 38, Math.PI / 3.4, 0.65, 1.2);
    light.position.set(lampHeadX, 7.0, 0);
    light.target.position.set(lampHeadX * 0.4, 0, 0);
    light.castShadow = false; // Preserves high framerate
    group.add(light);
    group.add(light.target);

    group.position.set(x, y, z);
    return group;
  }

  createGrassTuft(x, y, z) {
    const group = new THREE.Group();
    const grassMat = new THREE.MeshStandardMaterial({ color: 0x27432b, roughness: 0.9 });
    for (let b = 0; b < 4; b++) {
      const blade = new THREE.Mesh(new THREE.ConeGeometry(0.12, 0.9 + Math.random() * 0.4, 4), grassMat);
      blade.position.set((Math.random() - 0.5) * 0.4, 0.45, (Math.random() - 0.5) * 0.4);
      blade.rotation.z = (Math.random() - 0.5) * 0.4;
      group.add(blade);
    }
    group.position.set(x, y, z);
    return group;
  }

  createPineTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.55;

    const trunk = new THREE.Mesh(this.geoTrunk, this.matTrunk);
    trunk.position.y = 1.9;
    trunk.castShadow = true;
    group.add(trunk);

    // Multi-tier tiered pine foliage
    const tiers = [
      { y: 4.6, s: 1.0, mat: this.matPine1 },
      { y: 6.2, s: 0.82, mat: this.matPine2 },
      { y: 7.6, s: 0.62, mat: this.matPine1 }
    ];

    tiers.forEach((t) => {
      const cone = new THREE.Mesh(this.geoPineCone, t.mat);
      cone.position.y = t.y;
      cone.scale.set(t.s, t.s, t.s);
      cone.castShadow = true;
      group.add(cone);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createBirchTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.45;
    const trunkMat = new THREE.MeshStandardMaterial({ color: 0xdedede, roughness: 0.85 }); // White paper birch bark
    const foliageMat = new THREE.MeshStandardMaterial({ color: 0x82945b, roughness: 0.88 }); // Golden-sage northern foliage

    const trunk = new THREE.Mesh(new THREE.CylinderGeometry(0.16, 0.24, 4.6, 6), trunkMat);
    trunk.position.y = 2.3;
    trunk.castShadow = true;
    group.add(trunk);

    // Multi-cluster rounded birch crown
    for (let c = 0; c < 3; c++) {
      const cluster = new THREE.Mesh(
        new THREE.DodecahedronGeometry(1.35 - c * 0.22, 1),
        foliageMat
      );
      cluster.position.set((Math.random() - 0.5) * 0.7, 4.4 + c * 1.15, (Math.random() - 0.5) * 0.7);
      cluster.castShadow = true;
      group.add(cluster);
    }

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createRock(x, y, z, scaleMultiplier = 1.0) {
    const mesh = new THREE.Mesh(this.geoRock, this.matRock);
    const s = (0.75 + Math.random() * 0.7) * scaleMultiplier;
    mesh.scale.set(s * (0.8 + Math.random() * 0.5), s, s * (0.8 + Math.random() * 0.5));
    mesh.position.set(x, y + s * 0.6, z);
    mesh.rotation.set(Math.random() * 2, Math.random() * 2, Math.random() * 2);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    return mesh;
  }

  createPowerPole(x, y, z, side) {
    const group = new THREE.Group();
    const pole = new THREE.Mesh(this.geoPole, this.matPole);
    pole.position.y = 3.75;
    pole.castShadow = true;
    group.add(pole);

    const crossArm = new THREE.Mesh(this.geoCrossArm, this.matPole);
    crossArm.position.y = 6.6;
    crossArm.castShadow = true;
    group.add(crossArm);

    // Ceramic insulators
    [-1.0, 1.0].forEach((ix) => {
      const ins = new THREE.Mesh(
        new THREE.CylinderGeometry(0.08, 0.08, 0.25, 6),
        new THREE.MeshStandardMaterial({ color: 0x94a3b8, metalness: 0.8 })
      );
      ins.position.set(ix, 6.8, 0);
      group.add(ins);
    });

    // Hanging Power Line Wire connecting to previous pole on same side
    if (this.lastPolePos && this.lastPolePos.side === side && (z - this.lastPolePos.z) < 55) {
      const p1 = new THREE.Vector3(this.lastPolePos.x - x, 6.7, this.lastPolePos.z - z);
      const p2 = new THREE.Vector3(0, 6.7, 0);
      const mid = p1.clone().add(p2).multiplyScalar(0.5);
      mid.y -= 1.8; // Catenary sag

      const curve = new THREE.QuadraticBezierCurve3(p1, mid, p2);
      const wirePoints = curve.getPoints(12);
      const wireGeo = new THREE.BufferGeometry().setFromPoints(wirePoints);
      const wireLine = new THREE.Line(wireGeo, this.matWire);
      group.add(wireLine);
    }

    this.lastPolePos = { x, y, z, side };

    group.position.set(x, y, z);
    return group;
  }

  createBillboard(x, y, z, side) {
    const group = new THREE.Group();
    const pole1 = new THREE.Mesh(this.geoPole, this.matPole);
    pole1.scale.set(1, 0.75, 1);
    pole1.position.set(-2.0, 2.5, 0);
    pole1.castShadow = true;
    group.add(pole1);

    const pole2 = new THREE.Mesh(this.geoPole, this.matPole);
    pole2.scale.set(1, 0.75, 1);
    pole2.position.set(2.0, 2.5, 0);
    pole2.castShadow = true;
    group.add(pole2);

    const board = new THREE.Mesh(new THREE.BoxGeometry(5.2, 2.4, 0.18), this.matBillboard);
    board.position.set(0, 4.4, 0);
    board.castShadow = true;
    group.add(board);

    // Hazard stripe trim on billboard edge
    const trim = new THREE.Mesh(
      new THREE.BoxGeometry(5.3, 0.2, 0.22),
      new THREE.MeshStandardMaterial({ color: 0xf59e0b, roughness: 0.5 })
    );
    trim.position.set(0, 3.2, 0);
    group.add(trim);

    group.position.set(x, y, z);
    group.rotation.y = side > 0 ? -0.28 : 0.28;
    return group;
  }

  createWreck(x, y, z) {
    const group = new THREE.Group();
    const body = new THREE.Mesh(new THREE.BoxGeometry(2.1, 1.0, 4.4), this.matWreck);
    body.position.y = 0.55;
    body.castShadow = true;
    group.add(body);

    const cabin = new THREE.Mesh(new THREE.BoxGeometry(1.75, 0.75, 2.1), this.matWreck);
    cabin.position.set(0, 1.35, -0.4);
    cabin.castShadow = true;
    group.add(cabin);

    group.position.set(x, y, z);
    group.rotation.y = (Math.random() - 0.5) * 1.4;
    group.rotation.z = (Math.random() - 0.5) * 0.2;
    return group;
  }

  // --- RUSTY PERIPHERY STRUCTURES ---
  createFlareStack(x, y, z) {
    const group = new THREE.Group();
    // Tall industrial exhaust stack
    const stack = new THREE.Mesh(
      new THREE.CylinderGeometry(0.5, 0.9, 15, 8),
      this.matRustedMetal
    );
    stack.position.y = 7.5;
    stack.castShadow = true;
    group.add(stack);

    // Tip ring
    const ring = new THREE.Mesh(
      new THREE.CylinderGeometry(0.8, 0.8, 0.4, 8),
      this.matRustedMetal
    );
    ring.position.y = 15;
    group.add(ring);

    // Dynamic flare gas flame
    const flame = new THREE.Mesh(
      new THREE.ConeGeometry(0.9, 2.5, 6),
      new THREE.MeshBasicMaterial({ color: 0xff6600 })
    );
    flame.position.y = 16.5;
    group.add(flame);

    const flareLight = new THREE.PointLight(0xff6600, 2.2, 28);
    flareLight.position.y = 16.5;
    group.add(flareLight);

    group.position.set(x, y, z);
    return group;
  }

  createFuelStorageTank(x, y, z) {
    const group = new THREE.Group();
    // Massive cylindrical fuel silo
    const tank = new THREE.Mesh(
      new THREE.CylinderGeometry(4.2, 4.2, 7.0, 14),
      this.matRustedMetal
    );
    tank.position.y = 3.5;
    tank.castShadow = true;
    group.add(tank);

    // Domed top cap
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(4.2, 14, 8, 0, Math.PI * 2, 0, Math.PI * 0.35),
      this.matRustedMetal
    );
    dome.position.y = 7.0;
    dome.rotation.x = Math.PI;
    group.add(dome);

    // Yellow hazard warning band
    const band = new THREE.Mesh(
      new THREE.CylinderGeometry(4.25, 4.25, 0.5, 14),
      new THREE.MeshStandardMaterial({ color: 0xf59e0b, roughness: 0.6 })
    );
    band.position.y = 4.2;
    group.add(band);

    group.position.set(x, y, z);
    return group;
  }

  // --- BLACK PINE WOODS STRUCTURES ---
  createForesterTower(x, y, z) {
    const group = new THREE.Group();
    // 4 Splayed wooden stilts
    const legGeo = new THREE.CylinderGeometry(0.18, 0.25, 15, 5);
    [-1.6, 1.6].forEach((lx) => {
      [-1.6, 1.6].forEach((lz) => {
        const leg = new THREE.Mesh(legGeo, this.matWoodLog);
        leg.position.set(lx, 7.5, lz);
        leg.castShadow = true;
        group.add(leg);
      });
    });

    // Cabin platform
    const platform = new THREE.Mesh(
      new THREE.BoxGeometry(4.5, 0.4, 4.5),
      this.matWoodLog
    );
    platform.position.y = 15;
    group.add(platform);

    // Cabin house
    const cabin = new THREE.Mesh(
      new THREE.BoxGeometry(3.6, 2.6, 3.6),
      this.matWoodLog
    );
    cabin.position.y = 16.5;
    group.add(cabin);

    // Warm lantern window glowing inside
    const windowGlow = new THREE.Mesh(
      new THREE.BoxGeometry(1.2, 0.9, 3.7),
      this.matAmberGlow
    );
    windowGlow.position.y = 16.6;
    group.add(windowGlow);

    const light = new THREE.PointLight(0xf59e0b, 1.8, 22);
    light.position.y = 16.5;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createAncientPine(x, y, z) {
    const group = new THREE.Group();
    // Gargantuan ancient conifer
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.8, 1.3, 7.0, 7),
      this.matTrunk
    );
    trunk.position.y = 3.5;
    trunk.castShadow = true;
    group.add(trunk);

    const tiers = [
      { y: 8.5, r: 4.8, h: 6.5, mat: this.matPine1 },
      { y: 12.5, r: 3.8, h: 5.5, mat: this.matPine2 },
      { y: 16.0, r: 2.8, h: 4.5, mat: this.matPine1 },
      { y: 19.0, r: 1.8, h: 3.5, mat: this.matPine2 }
    ];

    tiers.forEach((t) => {
      const cone = new THREE.Mesh(new THREE.ConeGeometry(t.r, t.h, 7), t.mat);
      cone.position.y = t.y;
      cone.castShadow = true;
      group.add(cone);
    });

    group.position.set(x, y, z);
    return group;
  }

  createLumberCabin(x, y, z) {
    const group = new THREE.Group();
    const walls = new THREE.Mesh(
      new THREE.BoxGeometry(5.2, 2.8, 4.2),
      this.matWoodLog
    );
    walls.position.y = 1.4;
    walls.castShadow = true;
    group.add(walls);

    // Sloped roof
    const roof = new THREE.Mesh(
      new THREE.ConeGeometry(3.8, 2.2, 4),
      new THREE.MeshStandardMaterial({ color: 0x221a14, roughness: 0.9 })
    );
    roof.position.y = 3.8;
    roof.rotation.y = Math.PI / 4;
    roof.castShadow = true;
    group.add(roof);

    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  // --- FLOODED MARSHLAND STRUCTURES ---
  createSwampStiltHut(x, y, z) {
    const group = new THREE.Group();
    // Elevated stilts over marsh water
    const legGeo = new THREE.CylinderGeometry(0.12, 0.15, 3.2, 5);
    [-1.2, 1.2].forEach((lx) => {
      [-1.2, 1.2].forEach((lz) => {
        const leg = new THREE.Mesh(legGeo, this.matWoodLog);
        leg.position.set(lx, 1.6, lz);
        group.add(leg);
      });
    });

    const hut = new THREE.Mesh(
      new THREE.BoxGeometry(3.0, 2.0, 2.8),
      this.matWoodLog
    );
    hut.position.y = 4.2;
    hut.castShadow = true;
    group.add(hut);

    // Swamp lantern hanging
    const lantern = new THREE.Mesh(
      new THREE.SphereGeometry(0.2, 6, 6),
      this.matAmberGlow
    );
    lantern.position.set(1.6, 3.6, 0);
    group.add(lantern);

    const light = new THREE.PointLight(0xffaa22, 1.5, 16);
    light.position.set(1.6, 3.6, 0);
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createSkeletalCypress(x, y, z) {
    const group = new THREE.Group();
    // Dead twisted cypress
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.35, 0.7, 5.5, 6),
      new THREE.MeshStandardMaterial({ color: 0x282624, roughness: 0.95 })
    );
    trunk.position.y = 2.75;
    trunk.rotation.z = (Math.random() - 0.5) * 0.3;
    trunk.castShadow = true;
    group.add(trunk);

    // Skeletal bare branches
    for (let b = 0; b < 4; b++) {
      const branch = new THREE.Mesh(
        new THREE.CylinderGeometry(0.08, 0.15, 2.4, 4),
        new THREE.MeshStandardMaterial({ color: 0x282624, roughness: 0.95 })
      );
      branch.position.set((Math.random() - 0.5) * 1.2, 4.2 + b * 0.4, (Math.random() - 0.5) * 1.2);
      branch.rotation.z = (Math.random() - 0.5) * 1.2;
      branch.rotation.y = Math.random() * Math.PI * 2;
      group.add(branch);
    }

    group.position.set(x, y, z);
    return group;
  }

  createBioluminescentSpores(x, y, z) {
    const group = new THREE.Group();
    // Cluster of glowing swamp fungal pods
    for (let s = 0; s < 5; s++) {
      const spore = new THREE.Mesh(
        new THREE.SphereGeometry(0.25 + Math.random() * 0.2, 6, 6),
        this.matCrystalCyan
      );
      spore.position.set((Math.random() - 0.5) * 1.5, 0.35 + Math.random() * 0.4, (Math.random() - 0.5) * 1.5);
      group.add(spore);
    }
    const glow = new THREE.PointLight(0x06b6d4, 1.2, 10);
    glow.position.y = 0.8;
    group.add(glow);

    group.position.set(x, y, z);
    return group;
  }

  // --- GLASS CRATER STRUCTURES ---
  createCrystalSpire(x, y, z) {
    const group = new THREE.Group();
    const height = 7.5 + Math.random() * 6.0;
    const isMagenta = Math.random() < 0.5;
    const crystalMat = isMagenta ? this.matCrystalMagenta : this.matCrystalCyan;
    const lightColor = isMagenta ? 0xd946ef : 0x06b6d4;

    // Faceted hexagonal crystal needle
    const spire = new THREE.Mesh(
      new THREE.CylinderGeometry(0.2, 1.2, height, 5),
      crystalMat
    );
    spire.position.y = height * 0.48;
    spire.rotation.x = (Math.random() - 0.5) * 0.25;
    spire.rotation.z = (Math.random() - 0.5) * 0.25;
    spire.castShadow = true;
    group.add(spire);

    // Glowing point light casting vivid colored aura onto surroundings
    const light = new THREE.PointLight(lightColor, 2.0, 20);
    light.position.y = height * 0.65;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createLevitatingAnomalousCore(x, y, z) {
    const group = new THREE.Group();
    // Levitating octahedron core hovering at 3.5m height
    const core = new THREE.Mesh(
      new THREE.OctahedronGeometry(1.2, 0),
      this.matCrystalMagenta
    );
    core.position.y = 3.5;
    group.add(core);

    // Outer metallic containment ring
    const ring = new THREE.Mesh(
      new THREE.TorusGeometry(2.4, 0.12, 6, 16),
      new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.9 })
    );
    ring.position.y = 3.5;
    ring.rotation.x = Math.PI / 3;
    group.add(ring);

    const light = new THREE.PointLight(0xd946ef, 2.2, 22);
    light.position.y = 3.5;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createCraterSpikeField(x, y, z) {
    const group = new THREE.Group();
    for (let i = 0; i < 6; i++) {
      const needle = new THREE.Mesh(
        new THREE.ConeGeometry(0.25, 3.5 + Math.random() * 2.5, 4),
        this.matCrystalCyan
      );
      needle.position.set((Math.random() - 0.5) * 2.2, 1.6, (Math.random() - 0.5) * 2.2);
      needle.rotation.x = (Math.random() - 0.5) * 0.7;
      needle.rotation.z = (Math.random() - 0.5) * 0.7;
      group.add(needle);
    }
    group.position.set(x, y, z);
    return group;
  }

  // --- IRON GORGE STRUCTURES ---
  createCanyonCliff(x, y, z, side) {
    const group = new THREE.Group();
    // Monumental stepped red-rock canyon mesa wall flanking roadway
    const height = 28 + Math.random() * 10;
    const width = 16 + Math.random() * 8;
    const depth = 14;

    const mesa = new THREE.Mesh(
      new THREE.BoxGeometry(width, height, depth),
      this.matRedRock
    );
    mesa.position.y = height * 0.5 - 1.0;
    mesa.castShadow = true;
    mesa.receiveShadow = true;
    group.add(mesa);

    // Top jagged pinnacle
    const pinnacle = new THREE.Mesh(
      new THREE.ConeGeometry(width * 0.35, 8.0, 5),
      this.matRedRock
    );
    pinnacle.position.set((Math.random() - 0.5) * 4, height + 3.0, (Math.random() - 0.5) * 3);
    pinnacle.castShadow = true;
    group.add(pinnacle);

    group.position.set(x, y, z);
    return group;
  }

  createBalancedRockHoodoo(x, y, z) {
    const group = new THREE.Group();
    // Slender pillar
    const pillar = new THREE.Mesh(
      new THREE.CylinderGeometry(0.8, 1.6, 9.5, 6),
      this.matRedRock
    );
    pillar.position.y = 4.75;
    pillar.castShadow = true;
    group.add(pillar);

    // Giant balancing boulder on summit
    const boulder = new THREE.Mesh(
      new THREE.DodecahedronGeometry(2.4, 1),
      this.matRedRock
    );
    boulder.position.y = 10.8;
    boulder.scale.set(1.3, 0.9, 1.1);
    boulder.castShadow = true;
    group.add(boulder);

    group.position.set(x, y, z);
    return group;
  }

  // --- PERMAFROST HIGHLANDS STRUCTURES ---
  createSnowCoveredPines(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    const trunk = new THREE.Mesh(this.geoTrunk, this.matTrunk);
    trunk.position.y = 1.9;
    trunk.castShadow = true;
    group.add(trunk);

    const tiers = [
      { y: 4.6, s: 1.0 },
      { y: 6.2, s: 0.8 },
      { y: 7.6, s: 0.6 }
    ];

    tiers.forEach((t) => {
      // Dark green under foliage
      const cone = new THREE.Mesh(this.geoPineCone, this.matPine1);
      cone.position.y = t.y;
      cone.scale.set(t.s, t.s, t.s);
      cone.castShadow = true;
      group.add(cone);

      // White snow blanket cap on top of cone
      const snowCap = new THREE.Mesh(new THREE.ConeGeometry(2.02, 1.8, 6), this.matSnow);
      snowCap.position.y = t.y + 1.2 * t.s;
      snowCap.scale.set(t.s * 0.95, t.s * 0.95, t.s * 0.95);
      snowCap.castShadow = true;
      group.add(snowCap);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createGlacialIceSpire(x, y, z) {
    const group = new THREE.Group();
    const height = 5.5 + Math.random() * 4.5;
    const spire = new THREE.Mesh(
      new THREE.CylinderGeometry(0.1, 1.4, height, 5),
      this.matIce
    );
    spire.position.y = height * 0.48;
    spire.rotation.x = (Math.random() - 0.5) * 0.2;
    spire.rotation.z = (Math.random() - 0.5) * 0.2;
    spire.castShadow = true;
    group.add(spire);

    const light = new THREE.PointLight(0xa5f3fc, 1.4, 15);
    light.position.y = height * 0.6;
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  createArcticGeodesicDome(x, y, z) {
    const group = new THREE.Group();
    // Geodesic expedition shelter
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(3.6, 10, 8, 0, Math.PI * 2, 0, Math.PI * 0.5),
      new THREE.MeshStandardMaterial({ color: 0xe2e8f0, roughness: 0.7 })
    );
    dome.position.y = 0;
    dome.castShadow = true;
    group.add(dome);

    // Warm illuminated entry tunnel
    const entry = new THREE.Mesh(
      new THREE.BoxGeometry(1.6, 1.8, 2.2),
      new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.8 })
    );
    entry.position.set(0, 0.9, 3.2);
    group.add(entry);

    // Glowing warm amber portal
    const portal = new THREE.Mesh(
      new THREE.PlaneGeometry(1.2, 1.4),
      this.matAmberGlow
    );
    portal.position.set(0, 0.9, 4.31);
    group.add(portal);

    const light = new THREE.PointLight(0xf59e0b, 1.8, 18);
    light.position.set(0, 1.2, 4.5);
    group.add(light);

    group.position.set(x, y, z);
    return group;
  }

  // --- MEDITERRANEAN COAST STRUCTURES & FLORA ---
  createMaritimePine(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.4;

    // Tall slender trunk with slight natural lean
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.32, 0.52, 7.5, 7),
      this.matTrunk
    );
    trunk.position.y = 3.75;
    trunk.rotation.z = (Math.random() - 0.5) * 0.15;
    trunk.castShadow = true;
    group.add(trunk);

    // Splayed upper branches
    for (let b = 0; b < 3; b++) {
      const angle = (b * Math.PI * 2) / 3;
      const branch = new THREE.Mesh(
        new THREE.CylinderGeometry(0.12, 0.22, 2.8, 5),
        this.matTrunk
      );
      branch.position.set(Math.cos(angle) * 0.9, 6.8, Math.sin(angle) * 0.9);
      branch.rotation.z = Math.cos(angle) * 0.55;
      branch.rotation.x = Math.sin(angle) * 0.55;
      group.add(branch);
    }

    // Broad umbrella dome canopy
    const canopy = new THREE.Mesh(
      new THREE.CylinderGeometry(4.2, 2.8, 1.8, 8),
      this.matMaritimePineFoliage
    );
    canopy.position.y = 8.6;
    canopy.castShadow = true;
    group.add(canopy);

    const canopyCap = new THREE.Mesh(
      new THREE.SphereGeometry(3.6, 8, 5, 0, Math.PI * 2, 0, Math.PI * 0.4),
      this.matMaritimePineFoliage
    );
    canopyCap.position.y = 9.4;
    canopyCap.castShadow = true;
    group.add(canopyCap);

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createOliveTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.35;

    // Gnarled twisted trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.35, 0.65, 3.2, 6),
      new THREE.MeshStandardMaterial({ color: 0x42382e, roughness: 0.98 })
    );
    trunk.position.y = 1.6;
    trunk.rotation.z = (Math.random() - 0.5) * 0.25;
    trunk.castShadow = true;
    group.add(trunk);

    // Silvery-olive rounded foliage clouds
    const offsets = [
      { x: -0.8, y: 3.2, z: 0.2, r: 1.6 },
      { x: 0.7, y: 3.5, z: -0.6, r: 1.8 },
      { x: 0.2, y: 3.9, z: 0.7, r: 1.5 }
    ];
    offsets.forEach((off) => {
      const foliage = new THREE.Mesh(
        new THREE.DodecahedronGeometry(off.r, 1),
        this.matOliveFoliage
      );
      foliage.position.set(off.x, off.y, off.z);
      foliage.castShadow = true;
      group.add(foliage);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createDryStoneWall(x, y, z) {
    const group = new THREE.Group();
    // Traditional Mediterranean limestone stone wall module (length 6.8m)
    const wall = new THREE.Mesh(
      new THREE.BoxGeometry(0.55, 0.95, 6.8),
      this.matStoneWall
    );
    wall.position.y = 0.47;
    wall.castShadow = true;
    group.add(wall);

    // Weathered coping stones on top
    const cap = new THREE.Mesh(
      new THREE.BoxGeometry(0.65, 0.12, 6.9),
      this.matStoneWall
    );
    cap.position.y = 0.98;
    group.add(cap);

    group.position.set(x, y, z);
    return group;
  }

  createHarborFishery(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Stone and whitewashed fisherman workshop
    const building = new THREE.Mesh(
      new THREE.BoxGeometry(7.5, 3.8, 9.0),
      this.matStoneWall
    );
    building.position.set(0, 1.9, 0);
    building.castShadow = true;
    group.add(building);

    // Terracotta tiled roof
    const roof = new THREE.Mesh(
      new THREE.ConeGeometry(5.8, 2.4, 4),
      new THREE.MeshStandardMaterial({ color: 0x9a3412, roughness: 0.85 })
    );
    roof.position.set(0, 4.9, 0);
    roof.rotation.y = Math.PI / 4;
    group.add(roof);

    // Wooden boat dock pier extension
    const pier = new THREE.Mesh(
      new THREE.BoxGeometry(3.2, 0.35, 14.0),
      this.matWoodLog
    );
    pier.position.set(-6.5, 0.25, 0);
    group.add(pier);

    // Warm harbor lantern
    const light = new THREE.PointLight(0xffa834, 2.2, 24);
    light.position.set(3.8, 3.2, 0);
    group.add(light);

    return group;
  }

  // --- TEMPERATE FOREST STRUCTURES & FLORA ---
  createDeciduousOak(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Massive hardwood trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.48, 0.85, 4.6, 7),
      this.matTrunk
    );
    trunk.position.y = 2.3;
    trunk.castShadow = true;
    group.add(trunk);

    // 4 Layered rich-green foliage domes
    const crowns = [
      { x: 0, y: 5.6, z: 0, r: 3.2 },
      { x: -1.6, y: 5.0, z: 1.2, r: 2.4 },
      { x: 1.8, y: 5.2, z: -1.0, r: 2.6 },
      { x: 0.3, y: 6.8, z: 0.4, r: 2.2 }
    ];
    crowns.forEach((c) => {
      const dome = new THREE.Mesh(
        new THREE.DodecahedronGeometry(c.r, 1),
        this.matDeciduousOak
      );
      dome.position.set(c.x, c.y, c.z);
      dome.castShadow = true;
      group.add(dome);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createEuropeanBeech(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.85 + Math.random() * 0.4;

    // Slender smooth silver-grey trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.28, 0.45, 6.0, 7),
      new THREE.MeshStandardMaterial({ color: 0x8e8e93, roughness: 0.85 })
    );
    trunk.position.y = 3.0;
    trunk.castShadow = true;
    group.add(trunk);

    // Elegant conical beech crown
    const foliage = new THREE.Mesh(
      new THREE.ConeGeometry(3.2, 6.5, 7),
      this.matBeechFoliage
    );
    foliage.position.y = 6.2;
    foliage.castShadow = true;
    group.add(foliage);

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createWaterMill(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Stone foundation mill building
    const mill = new THREE.Mesh(
      new THREE.BoxGeometry(8.0, 4.2, 7.5),
      this.matWoodLog
    );
    mill.position.set(0, 2.1, 0);
    mill.castShadow = true;
    group.add(mill);

    // Sloped wooden shingle roof
    const roof = new THREE.Mesh(
      new THREE.ConeGeometry(6.2, 2.8, 4),
      new THREE.MeshStandardMaterial({ color: 0x2e2318, roughness: 0.9 })
    );
    roof.position.set(0, 5.5, 0);
    roof.rotation.y = Math.PI / 4;
    group.add(roof);

    // Vertical hydraulic water wheel
    const wheel = new THREE.Mesh(
      new THREE.CylinderGeometry(2.4, 2.4, 0.7, 12),
      new THREE.MeshStandardMaterial({ color: 0x3d2719, roughness: 0.95 })
    );
    wheel.position.set(-4.5, 1.8, 0);
    wheel.rotation.z = Math.PI / 2;
    group.add(wheel);

    // Firewood stacks
    const logs = new THREE.Mesh(
      new THREE.BoxGeometry(2.2, 1.4, 3.8),
      this.matWoodLog
    );
    logs.position.set(4.8, 0.7, 2.0);
    group.add(logs);

    return group;
  }

  // --- ARID DESERT STRUCTURES & FLORA ---
  createDatePalm(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Curved slender palm trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.24, 0.48, 8.5, 7),
      this.matPalmTrunk
    );
    trunk.position.set(0.4, 4.25, 0);
    trunk.rotation.z = 0.12;
    trunk.castShadow = true;
    group.add(trunk);

    // Radiating arching fronds
    for (let f = 0; f < 8; f++) {
      const angle = (f * Math.PI * 2) / 8;
      const frond = new THREE.Mesh(
        new THREE.BoxGeometry(0.35, 0.08, 3.4),
        this.matPalmFronds
      );
      frond.position.set(Math.cos(angle) * 1.5 + 0.8, 8.4, Math.sin(angle) * 1.5);
      frond.rotation.y = -angle;
      frond.rotation.x = 0.45;
      frond.castShadow = true;
      group.add(frond);
    }

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createSandDuneRidge(x, y, z, side) {
    const group = new THREE.Group();
    // Sweeping aerodynamic desert barchan dune ridge
    const dune = new THREE.Mesh(
      new THREE.ConeGeometry(14.0, 5.5, 5),
      this.matDuneSand
    );
    dune.position.y = 2.4;
    dune.scale.set(1.6, 0.9, 2.8);
    dune.rotation.y = side * 0.4;
    dune.receiveShadow = true;
    group.add(dune);

    group.position.set(x, y, z);
    return group;
  }

  createOasisCaravansary(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Thick adobe walled courtyard
    const wall = new THREE.Mesh(
      new THREE.BoxGeometry(12.0, 3.2, 16.0),
      this.matAdobe
    );
    wall.position.set(0, 1.6, 0);
    wall.castShadow = true;
    group.add(wall);

    // Domed central well / cistern
    const wellDome = new THREE.Mesh(
      new THREE.SphereGeometry(2.4, 8, 8, 0, Math.PI * 2, 0, Math.PI * 0.5),
      new THREE.MeshStandardMaterial({ color: 0xf8fafc, roughness: 0.9 })
    );
    wellDome.position.set(-8.0, 0, 0);
    group.add(wellDome);

    // Flanking date palms
    [-5, 5].forEach((pz) => {
      const palm = this.createDatePalm(-7.0, 0, pz);
      group.add(palm);
    });

    const light = new THREE.PointLight(0xffa233, 2.0, 22);
    light.position.set(0, 3.5, 0);
    group.add(light);

    return group;
  }

  // --- SAVANNA & STEPPE STRUCTURES & FLORA ---
  createUmbrellaAcacia(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Dark angled trunk bifurcating upwards
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.3, 0.55, 5.2, 6),
      this.matTrunk
    );
    trunk.position.y = 2.6;
    trunk.rotation.z = (Math.random() - 0.5) * 0.3;
    trunk.castShadow = true;
    group.add(trunk);

    // 3 Splayed high lateral branches
    for (let b = 0; b < 3; b++) {
      const angle = (b * Math.PI * 2) / 3;
      const arm = new THREE.Mesh(
        new THREE.CylinderGeometry(0.14, 0.22, 3.2, 5),
        this.matTrunk
      );
      arm.position.set(Math.cos(angle) * 1.2, 5.0, Math.sin(angle) * 1.2);
      arm.rotation.z = Math.cos(angle) * 0.7;
      arm.rotation.x = Math.sin(angle) * 0.7;
      group.add(arm);
    }

    // Wide horizontal flat-topped umbrella foliage canopy
    const flatCanopy = new THREE.Mesh(
      new THREE.CylinderGeometry(5.2, 4.2, 0.8, 8),
      this.matAcaciaCanopy
    );
    flatCanopy.position.y = 6.4;
    flatCanopy.castShadow = true;
    group.add(flatCanopy);

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    group.rotation.y = Math.random() * Math.PI * 2;
    return group;
  }

  createBaobabTree(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.3;

    // Colossal swollen bottle trunk
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(2.4, 3.4, 8.5, 9),
      this.matBaobabTrunk
    );
    trunk.position.y = 4.25;
    trunk.castShadow = true;
    group.add(trunk);

    // Root-like top branch clusters
    for (let i = 0; i < 5; i++) {
      const angle = (i * Math.PI * 2) / 5;
      const branch = new THREE.Mesh(
        new THREE.CylinderGeometry(0.4, 0.8, 3.5, 5),
        this.matBaobabTrunk
      );
      branch.position.set(Math.cos(angle) * 1.8, 9.2, Math.sin(angle) * 1.8);
      branch.rotation.z = Math.cos(angle) * 0.6;
      branch.rotation.x = Math.sin(angle) * 0.6;
      group.add(branch);

      // Foliage tuft at branch tip
      const tuft = new THREE.Mesh(
        new THREE.DodecahedronGeometry(1.6, 1),
        this.matAcaciaCanopy
      );
      tuft.position.set(Math.cos(angle) * 3.2, 10.5, Math.sin(angle) * 3.2);
      group.add(tuft);
    }

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createRangerStation(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Elevated timber ranger outpost
    const legGeo = new THREE.CylinderGeometry(0.2, 0.25, 4.5, 5);
    [-2.2, 2.2].forEach((lx) => {
      [-2.2, 2.2].forEach((lz) => {
        const leg = new THREE.Mesh(legGeo, this.matWoodLog);
        leg.position.set(lx, 2.25, lz);
        leg.castShadow = true;
        group.add(leg);
      });
    });

    const cabin = new THREE.Mesh(
      new THREE.BoxGeometry(5.2, 2.6, 5.2),
      this.matWoodLog
    );
    cabin.position.y = 5.6;
    cabin.castShadow = true;
    group.add(cabin);

    // Shaded corrugated tin roof overhang
    const roof = new THREE.Mesh(
      new THREE.BoxGeometry(6.4, 0.2, 6.4),
      new THREE.MeshStandardMaterial({ color: 0x94a3b8, metalness: 0.8, roughness: 0.3 })
    );
    roof.position.y = 7.0;
    group.add(roof);

    // Radio antenna mast
    const mast = new THREE.Mesh(
      new THREE.CylinderGeometry(0.05, 0.05, 6.5, 4),
      new THREE.MeshStandardMaterial({ color: 0xcbd5e1, metalness: 0.9 })
    );
    mast.position.set(2.4, 9.8, 2.4);
    group.add(mast);

    return group;
  }

  // --- TROPICAL RAINFOREST STRUCTURES & FLORA ---
  createRainforestGiant(x, y, z) {
    const group = new THREE.Group();
    const scale = 0.9 + Math.random() * 0.45;

    // Immense straight trunk reaching into the canopy
    const trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.65, 1.3, 14.0, 8),
      new THREE.MeshStandardMaterial({ color: 0x36271c, roughness: 0.95 })
    );
    trunk.position.y = 7.0;
    trunk.castShadow = true;
    group.add(trunk);

    // Buttress roots flanking the base
    for (let r = 0; r < 4; r++) {
      const angle = (r * Math.PI * 2) / 4;
      const buttress = new THREE.Mesh(
        new THREE.BoxGeometry(0.35, 3.8, 2.4),
        this.matTrunk
      );
      buttress.position.set(Math.cos(angle) * 1.5, 1.9, Math.sin(angle) * 1.5);
      buttress.rotation.y = -angle;
      group.add(buttress);
    }

    // Dense tiered jungle emerald canopy
    const canopies = [
      { y: 13.5, r: 5.8, mat: this.matJungleFoliage },
      { y: 15.8, r: 4.6, mat: this.matJungleCanopyDark },
      { y: 17.6, r: 3.2, mat: this.matJungleFoliage }
    ];
    canopies.forEach((c) => {
      const dome = new THREE.Mesh(
        new THREE.DodecahedronGeometry(c.r, 1),
        c.mat
      );
      dome.position.y = c.y;
      dome.scale.set(1.2, 0.65, 1.2);
      dome.castShadow = true;
      group.add(dome);
    });

    group.scale.set(scale, scale, scale);
    group.position.set(x, y, z);
    return group;
  }

  createBotanicalLab(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Stilt research module elevated above flood level
    const stilts = new THREE.Mesh(
      new THREE.BoxGeometry(8.5, 0.4, 12.0),
      this.matWoodLog
    );
    stilts.position.y = 2.4;
    group.add(stilts);

    const labCabin = new THREE.Mesh(
      new THREE.BoxGeometry(7.2, 3.2, 10.0),
      new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.8 })
    );
    labCabin.position.y = 4.2;
    group.add(labCabin);

    // Green weather monitoring beacon
    const beacon = new THREE.PointLight(0x10b981, 2.2, 22);
    beacon.position.set(0, 6.5, 0);
    group.add(beacon);

    return group;
  }

  // --- ALPINE PEAKS STRUCTURES & CRAGS ---
  createAlpineGraniteWall(x, y, z, side) {
    const group = new THREE.Group();
    const height = 30 + Math.random() * 12;
    const width = 18 + Math.random() * 8;
    const depth = 16;

    // Dark granite precipice wall
    const cliff = new THREE.Mesh(
      new THREE.BoxGeometry(width, height, depth),
      this.matAlpineGranite
    );
    cliff.position.y = height * 0.5 - 1.0;
    cliff.castShadow = true;
    cliff.receiveShadow = true;
    group.add(cliff);

    // Jagged snowy summit horn
    const horn = new THREE.Mesh(
      new THREE.ConeGeometry(width * 0.4, 9.0, 5),
      this.matSnow
    );
    horn.position.set((Math.random() - 0.5) * 4, height + 3.5, (Math.random() - 0.5) * 3);
    horn.castShadow = true;
    group.add(horn);

    group.position.set(x, y, z);
    return group;
  }

  createAvalancheTunnel(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    // Concrete avalanche deflection gallery over the road
    const roof = new THREE.Mesh(
      new THREE.BoxGeometry(22, 0.8, 16),
      this.matAlpineGranite
    );
    roof.position.set(0, 6.2, 0);
    roof.rotation.z = 0.15; // Sloped to dump snow down valley
    group.add(roof);

    // Massive reinforced concrete pillars on mountain side
    [-6, 0, 6].forEach((pz) => {
      const col = new THREE.Mesh(
        new THREE.BoxGeometry(1.2, 6.2, 1.2),
        this.matAlpineGranite
      );
      col.position.set(-9.5, 3.1, pz);
      group.add(col);
    });

    return group;
  }
}



// --- FILE: src/world/POIManager.js ---
/**
 * THE LONG MERIDIAN - Intelligent Points of Interest (POI) & Settlement Manager
 * Spawns geographically coherent settlements, regional outposts and narrative salvage sites.
 */

class POIManager {
  constructor(scene, roadGenerator) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;

    this.pois = [];
    this.activeNearbyPOI = null; // POI currently within interaction radius (<= 10m)

    // Master Geocentric Plan for Sites along the Trans-Earth 8-Biomes Expedition (5200m Loop)
    this.plannedSites = [
      // SECTOR 0: Mediterranean Coast (PK 0.0 - 0.65 KM)
      {
        z: 220,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'san_vito_harbor',
        side: 1, // Right
        name: 'Porto di San Vito & Molo Pescatori'
      },
      {
        z: 380,
        type: 'COASTAL_FISHERY_RUIN',
        side: -1, // Left
        name: 'Faro Costiero & Rudere Vecchia Tonnara'
      },
      {
        z: 520,
        type: 'OVERTURNED_CONVOY',
        side: 1,
        name: 'Furgone Merci Ribaltato sui Tornanti Costieri'
      },

      // SECTOR 1: Temperate Forest (PK 0.65 - 1.30 KM)
      {
        z: 870,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'valbruna_mill',
        side: -1,
        name: 'Mulino di Valbruna & Segheria Idraulica'
      },
      {
        z: 1040,
        type: 'FORESTRY_LUMBER_YARD',
        side: 1,
        name: 'Piazzale Carico Tronchi di Querce e Faggi'
      },
      {
        z: 1180,
        type: 'MILITARY_CHECKPOINT',
        side: -1,
        name: 'Posto di Blocco Guardia Forestale di Valbruna'
      },

      // SECTOR 2: Arid Desert (PK 1.30 - 1.95 KM)
      {
        z: 1520,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'elkantara_oasis',
        side: 1,
        name: 'Oasi di El Kantara & Carovanserraglio'
      },
      {
        z: 1680,
        type: 'DESERT_CARAVAN_POST',
        side: -1,
        name: 'Pozzo Sahariano & Cisterna Idrica del Deserto'
      },
      {
        z: 1820,
        type: 'OVERTURNED_CONVOY',
        side: 1,
        name: 'Autocarro Berliet Sabbiato tra le Dune'
      },

      // SECTOR 3: Savanna Steppe (PK 1.95 - 2.60 KM)
      {
        z: 2170,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'serengeti_outpost',
        side: -1,
        name: 'Avamposto Ranger del Serengeti'
      },
      {
        z: 2320,
        type: 'SAVANNA_RANGER_STATION',
        side: 1,
        name: 'Torretta Avvistamento & Ripetitore Radio Savana'
      },
      {
        z: 2480,
        type: 'MILITARY_CHECKPOINT',
        side: -1,
        name: 'Cancello Parco Nazionale & Pista Laterite'
      },

      // SECTOR 4: Tropical Rainforest (PK 2.60 - 3.25 KM)
      {
        z: 2820,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'rioverde_station',
        side: 1,
        name: 'Stazione Scientifica Botanica Rio Verde'
      },
      {
        z: 2960,
        type: 'JUNGLE_BOTANICAL_LAB',
        side: -1,
        name: 'Laboratorio Palafitta sulle Chiome Equatoriali'
      },
      {
        z: 3120,
        type: 'OVERTURNED_CONVOY',
        side: 1,
        name: 'Convoglio da Spedizione Sommerso nel Guado Monsonico'
      },

      // SECTOR 5: Alpine Peaks (PK 3.25 - 3.90 KM)
      {
        z: 3470,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'valico_aquile',
        side: -1,
        name: 'Rifugio Alpino Valico delle Aquile'
      },
      {
        z: 3620,
        type: 'ALPINE_TUNNEL_SHELTER',
        side: 1,
        name: 'Galleria Paravalanghe e Deposito Frane'
      },
      {
        z: 3780,
        type: 'QUARRY_CRUSHER_SITE',
        side: -1,
        name: 'Cava di Granito e Falesie del Passo Alpino'
      },

      // SECTOR 6: Boreal Taiga (PK 3.90 - 4.55 KM)
      {
        z: 4120,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'taiga_nord',
        side: 1,
        name: 'Deposito Forestale Taiga Nord'
      },
      {
        z: 4280,
        type: 'TAIGA_LOGGING_DEPOT',
        side: -1,
        name: 'Segheria Meccanizzata Picea e Betulla'
      },
      {
        z: 4420,
        type: 'MILITARY_CHECKPOINT',
        side: 1,
        name: 'Posto di Frontiera Nordico'
      },

      // SECTOR 7: Polar Tundra (PK 4.55 - 5.20+ KM)
      {
        z: 4770,
        type: 'SETTLEMENT_HUB',
        settlementKey: 'polar_base_80',
        side: -1,
        name: 'Base Scientifica Polare 80'
      },
      {
        z: 4940,
        type: 'POLAR_METAR_SHELTER',
        side: 1,
        name: 'Cupola Radar Geodetica & Stazione Meteo METAR'
      },
      {
        z: 5100,
        type: 'MILITARY_CHECKPOINT',
        side: -1,
        name: 'Faro Terminale del Grande Meridiano & Traguardo'
      }
    ];

    this.spawnedZSet = new Set();
    this.initMaterials();
  }

  initMaterials() {
    this.matCanopy = new THREE.MeshStandardMaterial({ color: 0x444850, roughness: 0.6, metalness: 0.5 });
    this.matPump = new THREE.MeshStandardMaterial({ color: 0xaa2211, roughness: 0.7 });
    this.matConcrete = new THREE.MeshStandardMaterial({ color: 0x5a5855, roughness: 0.9 });
    this.matCargo = new THREE.MeshStandardMaterial({ color: 0x224466, roughness: 0.8, metalness: 0.3 });
    this.matWood = new THREE.MeshStandardMaterial({ color: 0x5a3e26, roughness: 0.9 });
    this.matFence = new THREE.MeshStandardMaterial({ color: 0x777777, wireframe: true });
    this.matWarning = new THREE.MeshStandardMaterial({ color: 0xe6a110, roughness: 0.4 });
    this.matBeacon = new THREE.MeshBasicMaterial({ color: 0xffaa33 });
    this.matSettlementLight = new THREE.MeshBasicMaterial({ color: 0x55ffaa });
    this.matLitWindow = new THREE.MeshBasicMaterial({ color: 0xffd166 });
    this.matNeonGreen = new THREE.MeshBasicMaterial({ color: 0x10b981 });
    this.matNeonRed = new THREE.MeshBasicMaterial({ color: 0xef4444 });
    this.matNeonBlue = new THREE.MeshBasicMaterial({ color: 0x38bdf8 });
    this.matFireGlow = new THREE.MeshBasicMaterial({ color: 0xff7722 });
    this.matMetalDark = new THREE.MeshStandardMaterial({ color: 0x1e242d, roughness: 0.5, metalness: 0.75 });
    this.matRoofShingle = new THREE.MeshStandardMaterial({ color: 0x2b3038, roughness: 0.9 });
    this.matSnowTop = new THREE.MeshStandardMaterial({ color: 0xf1f5f9, roughness: 0.95 });
  }

  update(playerPos) {
    const horizonZ = playerPos.z + 240;

    // Check pre-planned geographic sites ahead
    for (const siteDef of this.plannedSites) {
      if (siteDef.z <= horizonZ && !this.spawnedZSet.has(siteDef.z)) {
        this.spawnStructuredSite(siteDef);
        this.spawnedZSet.add(siteDef.z);
      }
    }

    // Check for loop extension if player travels past 5200m
    if (horizonZ > 5200) {
      const cycleOffset = Math.floor(horizonZ / 5200) * 5200;
      for (const siteDef of this.plannedSites) {
        const projectedZ = siteDef.z + cycleOffset;
        if (projectedZ <= horizonZ && !this.spawnedZSet.has(projectedZ)) {
          this.spawnStructuredSite({
            ...siteDef,
            z: projectedZ,
            name: `${siteDef.name} (Giro ${Math.floor(cycleOffset / 5200) + 1})`
          });
          this.spawnedZSet.add(projectedZ);
        }
      }
    }

    // Proximity check: is player within interaction range (10 meters)?
    this.activeNearbyPOI = null;
    let closestDist = 999;

    for (const poi of this.pois) {
      const dist = poi.position.distanceTo(playerPos);
      if (dist < 11.0 && dist < closestDist) {
        closestDist = dist;
        this.activeNearbyPOI = poi;
      }
    }

    // Recycle POIs that are far behind player
    const despawnZ = playerPos.z - 75;
    for (let i = this.pois.length - 1; i >= 0; i--) {
      const poi = this.pois[i];
      if (poi.position.z < despawnZ) {
        this.scene.remove(poi.meshGroup);
        this.pois.splice(i, 1);
      }
    }
  }

  spawnStructuredSite(siteDef) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(siteDef.z);
    const side = siteDef.side || 1;
    const offsetFromCenter = side * (roadInfo.width * 0.5 + 8.5);
    const x = roadInfo.x + offsetFromCenter;
    const y = roadInfo.y;
    const z = siteDef.z;

    const group = new THREE.Group();
    group.position.set(x, y, z);
    group.rotation.y = side > 0 ? -Math.PI / 2 : Math.PI / 2;

    let isSettlement = false;
    let settlementConfig = null;
    let poiConfig = null;

    if (siteDef.type === 'SETTLEMENT_HUB') {
      isSettlement = true;
      settlementConfig = CONFIG.SETTLEMENTS[siteDef.settlementKey];
      poiConfig = {
        name: siteDef.name,
        icon: settlementConfig ? settlementConfig.icon : '🏘️',
        isSettlement: true,
        dangerLevel: 0.02
      };
      this.buildSettlementHub(group, siteDef.settlementKey);
    } else {
      poiConfig = CONFIG.POI_TYPES[siteDef.type] || CONFIG.POI_TYPES.OVERTURNED_CONVOY;
      poiConfig = {
        ...poiConfig,
        name: siteDef.name || poiConfig.name
      };

      if (siteDef.type === 'COASTAL_FISHERY_RUIN') {
        this.buildFisheryRuin(group);
      } else if (siteDef.type === 'DESERT_CARAVAN_POST') {
        this.buildCaravanPost(group);
      } else if (siteDef.type === 'SAVANNA_RANGER_STATION') {
        this.buildSavannaRangerSite(group);
      } else if (siteDef.type === 'JUNGLE_BOTANICAL_LAB') {
        this.buildJungleBotanicalLab(group);
      } else if (siteDef.type === 'ALPINE_TUNNEL_SHELTER') {
        this.buildAlpineShelter(group);
      } else if (siteDef.type === 'TAIGA_LOGGING_DEPOT' || siteDef.type === 'FORESTRY_LUMBER_YARD') {
        this.buildLumberYard(group);
      } else if (siteDef.type === 'REFINERY_DEPOT') {
        this.buildRefinerySite(group);
      } else if (siteDef.type === 'HYDRO_PUMP_STATION') {
        this.buildHydroStation(group);
      } else if (siteDef.type === 'IONIC_RADAR_ARRAY') {
        this.buildRadarSite(group);
      } else if (siteDef.type === 'QUARRY_CRUSHER_SITE') {
        this.buildQuarryCrusher(group);
      } else if (siteDef.type === 'POLAR_METAR_SHELTER') {
        this.buildPolarShelter(group);
      } else if (siteDef.type === 'MILITARY_CHECKPOINT') {
        this.buildCheckpoint(group);
      } else {
        this.buildConvoy(group);
      }
    }

    // Glowing Signpost / Beacon on the shoulder
    const beaconLight = new THREE.PointLight(isSettlement ? 0x44ffaa : 0xffaa22, isSettlement ? 2.0 : 1.4, 22);
    beaconLight.position.set(0, 4.5, 0);
    group.add(beaconLight);

    const beaconGeo = new THREE.SphereGeometry(0.35, 8, 8);
    const beaconMesh = new THREE.Mesh(beaconGeo, isSettlement ? this.matSettlementLight : this.matBeacon);
    beaconMesh.position.set(0, 4.5, 0);
    group.add(beaconMesh);

    this.scene.add(group);

    const poiData = {
      siteDef: siteDef,
      typeKey: siteDef.type,
      config: poiConfig,
      isSettlement: isSettlement,
      settlementKey: siteDef.settlementKey,
      settlementConfig: settlementConfig,
      position: new THREE.Vector3(x, y, z),
      meshGroup: group,
      scavenged: false,
      loot: poiConfig.lootTable ? [...poiConfig.lootTable] : []
    };

    this.pois.push(poiData);
  }

  // --- 3D ARCHITECTURAL BUILDERS ---

  buildSettlementHub(group, key) {
    // 1. Heavy reinforced concrete foundation apron
    const pad = new THREE.Mesh(new THREE.BoxGeometry(22, 0.4, 26), this.matConcrete);
    pad.position.set(0, 0.2, 0);
    pad.receiveShadow = true;
    group.add(pad);

    // Hazard-striped entrance curb on the roadside edge
    const curb = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.45, 26), this.matWarning);
    curb.position.set(10.8, 0.22, 0);
    group.add(curb);

    // ==========================================
    // 2. ARCTIC SERVICE STATION / CANOPY & PUMPS
    // ==========================================
    // Elevated Canopy Roof (spanning over fueling lane)
    const canopyRoof = new THREE.Mesh(new THREE.BoxGeometry(9.0, 0.6, 12.0), this.matMetalDark);
    canopyRoof.position.set(5.5, 4.8, 0);
    group.add(canopyRoof);

    // Canopy Fascia Signboard (Illuminated perimeter band)
    const fascia = new THREE.Mesh(new THREE.BoxGeometry(9.1, 0.35, 12.1), this.matNeonGreen);
    fascia.position.set(5.5, 4.8, 0);
    group.add(fascia);

    // 4 Heavy Steel Canopy Columns
    [[-1.8, -4.5], [-1.8, 4.5], [1.8, -4.5], [1.8, 4.5]].forEach(([cx, cz]) => {
      const col = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.22, 4.6, 8), this.matCanopy);
      col.position.set(5.5 + cx, 2.3, cz);
      group.add(col);
    });

    // Dual Fuel Pump Concrete Island (Raised curb)
    const pumpIsland = new THREE.Mesh(new THREE.BoxGeometry(1.6, 0.35, 7.5), this.matConcrete);
    pumpIsland.position.set(5.5, 0.35, 0);
    group.add(pumpIsland);

    // Dual Gas & Diesel Fuel Dispensers
    [-2.2, 2.2].forEach((pz, i) => {
      const pumpBody = new THREE.Mesh(new THREE.BoxGeometry(0.85, 1.8, 0.95), this.matPump);
      pumpBody.position.set(5.5, 1.25, pz);
      group.add(pumpBody);

      // Lighted Digital Gallon/Price Display Meter
      const meterFace = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.4, 0.4), this.matLitWindow);
      meterFace.position.set(5.5, 1.65, pz);
      group.add(meterFace);

      // Yellow/Black Impact Protection Bollards
      [-0.7, 0.7].forEach((bx) => {
        const bollard = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 1.0, 6), this.matWarning);
        bollard.position.set(5.5 + bx, 0.7, pz + (bx > 0 ? 0.7 : -0.7));
        group.add(bollard);
      });
    });

    // Warm Under-Canopy Lighting (Illuminates vehicle while refueling)
    const canopyLight = new THREE.SpotLight(0xfff7ed, 3.8, 20, Math.PI / 3, 0.5, 1.2);
    canopyLight.position.set(5.5, 4.6, 0);
    canopyLight.target.position.set(5.5, 0, 0);
    canopyLight.castShadow = false;
    group.add(canopyLight);
    group.add(canopyLight.target);

    // ==========================================
    // 3. ROADSIDE NEON PYLON BILLBOARD (TOTEM)
    // ==========================================
    // Visible from hundreds of meters along highway
    const pylonGroup = new THREE.Group();
    pylonGroup.position.set(10.5, 0, 9.5);

    // Twin High-mast steel pylons
    [-0.6, 0.6].forEach((px) => {
      const mast = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.16, 9.2, 6), this.matCanopy);
      mast.position.set(px, 4.6, 0);
      pylonGroup.add(mast);
    });

    // Large Lightbox Billboard ("ARCTIC 24/7 DIESEL • MOTEL • CB 19")
    const signBox = new THREE.Mesh(new THREE.BoxGeometry(2.4, 3.2, 0.3), this.matMetalDark);
    signBox.position.set(0, 6.8, 0);
    pylonGroup.add(signBox);

    // Glowing Neon panels on the totem
    const neonTop = new THREE.Mesh(new THREE.BoxGeometry(2.1, 0.7, 0.35), this.matNeonGreen); // 24/7 DIESEL
    neonTop.position.set(0, 7.6, 0);
    pylonGroup.add(neonTop);

    const neonMid = new THREE.Mesh(new THREE.BoxGeometry(2.1, 0.6, 0.35), this.matNeonRed); // HOT FOOD / DINER
    neonMid.position.set(0, 6.7, 0);
    pylonGroup.add(neonMid);

    const neonBtm = new THREE.Mesh(new THREE.BoxGeometry(2.1, 0.5, 0.35), this.matNeonBlue); // MOTEL / CB 19
    neonBtm.position.set(0, 5.8, 0);
    pylonGroup.add(neonBtm);

    // Neon Pylon Beacon Light
    const pylonLight = new THREE.PointLight(0x10b981, 2.4, 28);
    pylonLight.position.set(0, 7.2, 0.8);
    pylonGroup.add(pylonLight);
    group.add(pylonGroup);

    // ==========================================
    // 4. MAIN GENERAL STORE & DINER CABIN
    // ==========================================
    const cabinGroup = new THREE.Group();
    cabinGroup.position.set(-4.5, 0, -2.0);

    // Main Log Walls
    const cabinBody = new THREE.Mesh(new THREE.BoxGeometry(8.5, 4.2, 11.5), this.matWood);
    cabinBody.position.set(0, 2.1, 0);
    cabinBody.castShadow = true;
    cabinGroup.add(cabinBody);

    // Dark Shingle Pitched Roof
    const roof = new THREE.Mesh(new THREE.ConeGeometry(7.5, 2.4, 4), this.matRoofShingle);
    roof.position.set(0, 5.2, 0);
    roof.rotation.y = Math.PI / 4;
    cabinGroup.add(roof);

    // Snow Cap on Roof Top
    const snowCap = new THREE.Mesh(new THREE.BoxGeometry(6.5, 0.25, 9.5), this.matSnowTop);
    snowCap.position.set(0, 4.8, 0);
    cabinGroup.add(snowCap);

    // Glowing Warm Windows (Interior light escaping to exterior)
    // Front windows facing player approach
    [[-3.2, 2.0, 5.8], [1.2, 2.0, 5.8], [3.2, 2.0, 5.8]].forEach(([wx, wy, wz]) => {
      const win = new THREE.Mesh(new THREE.BoxGeometry(1.4, 1.2, 0.2), this.matLitWindow);
      win.position.set(wx, wy, wz);
      cabinGroup.add(win);
    });

    // Side windows
    [[-2.5, 2.0, 0], [2.5, 2.0, 0]].forEach(([wz, wy, wx]) => {
      const win = new THREE.Mesh(new THREE.BoxGeometry(0.2, 1.2, 1.4), this.matLitWindow);
      win.position.set(4.3, wy, wz);
      cabinGroup.add(win);
    });

    // Cozy Interior Glow escaping through windows
    const windowGlow = new THREE.PointLight(0xffd166, 2.8, 22);
    windowGlow.position.set(0, 2.2, 3.5);
    cabinGroup.add(windowGlow);

    // Entrance Porch & Overhang
    const porchRoof = new THREE.Mesh(new THREE.BoxGeometry(4.0, 0.25, 2.8), this.matRoofShingle);
    porchRoof.position.set(-1.0, 3.2, 6.8);
    cabinGroup.add(porchRoof);

    // Porch wooden pillars
    [-2.6, 0.6].forEach((px) => {
      const col = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 3.0, 6), this.matWood);
      col.position.set(px, 1.5, 7.8);
      cabinGroup.add(col);
    });

    // Porch Lantern (Warm Amber)
    const lantern = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.4, 0.3), this.matLitWindow);
    lantern.position.set(-1.0, 2.8, 6.6);
    cabinGroup.add(lantern);

    // Stone Chimney with smoke stack
    const chimney = new THREE.Mesh(new THREE.BoxGeometry(0.9, 5.8, 0.9), this.matConcrete);
    chimney.position.set(-3.8, 3.0, -4.2);
    cabinGroup.add(chimney);

    group.add(cabinGroup);

    // ==========================================
    // 5. MECHANICAL WORKSHOP & STORAGE COMPOUND
    // ==========================================
    const workshop = new THREE.Mesh(new THREE.BoxGeometry(6.5, 3.4, 7.0), this.matCargo);
    workshop.position.set(-5.5, 1.7, 8.5);
    group.add(workshop);

    // Roll-up industrial garage door
    const shutter = new THREE.Mesh(new THREE.BoxGeometry(3.2, 2.8, 0.15), this.matWarning);
    shutter.position.set(-5.5, 1.4, 12.05);
    group.add(shutter);

    // Stacked Heavy All-Terrain Tires
    [-1.2, 1.2].forEach((tx, i) => {
      for (let t = 0; t < 3; t++) {
        const tire = new THREE.Mesh(new THREE.CylinderGeometry(0.52, 0.52, 0.38, 12), this.matMetalDark);
        tire.position.set(-1.5 + tx * 0.5, 0.2 + t * 0.38, 10.5);
        group.add(tire);
      }
    });

    // ==========================================
    // 6. SURVIVOR FIRE BARREL (WARM FLICKER)
    // ==========================================
    const fireBarrel = new THREE.Mesh(new THREE.CylinderGeometry(0.42, 0.42, 1.0, 8), this.matMetalDark);
    fireBarrel.position.set(1.5, 0.5, 5.5);
    group.add(fireBarrel);

    const flames = new THREE.Mesh(new THREE.ConeGeometry(0.35, 0.75, 6), this.matFireGlow);
    flames.position.set(1.5, 1.2, 5.5);
    group.add(flames);

    const fireLight = new THREE.PointLight(0xff6b2b, 2.6, 16);
    fireLight.position.set(1.5, 1.3, 5.5);
    group.add(fireLight);

    // Benches / Wooden Crate seating around fire
    const crate = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.65, 0.9), this.matWood);
    crate.position.set(2.8, 0.35, 5.5);
    group.add(crate);

    // ==========================================
    // 7. GUARD PERIMETER TOWER
    // ==========================================
    const tower = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.28, 8.5, 6), this.matCanopy);
    tower.position.set(-9.5, 4.25, -9.5);
    group.add(tower);

    const towerCab = new THREE.Mesh(new THREE.BoxGeometry(2.2, 1.6, 2.2), this.matMetalDark);
    towerCab.position.set(-9.5, 8.0, -9.5);
    group.add(towerCab);

    const floodLight = new THREE.SpotLight(0xfffaed, 3.2, 32, Math.PI / 3.5, 0.4);
    floodLight.position.set(-9.5, 8.5, -9.5);
    floodLight.target.position.set(2.0, 0, 0);
    floodLight.castShadow = false;
    group.add(floodLight);
    group.add(floodLight.target);
  }

  buildRefinerySite(group) {
    // 2 Cylindrical Fuel Tanks
    [-3.0, 3.0].forEach((pz) => {
      const tank = new THREE.Mesh(new THREE.CylinderGeometry(2.2, 2.2, 4.5, 12), this.matCargo);
      tank.position.set(0, 2.25, pz);
      tank.castShadow = true;
      group.add(tank);
    });

    // Overhead pipe connecting tanks
    const pipe = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.18, 6.0, 6), this.matCanopy);
    pipe.rotation.x = Math.PI / 2;
    pipe.position.set(0, 4.0, 0);
    group.add(pipe);

    // Manometer & valve station
    const valveBox = new THREE.Mesh(new THREE.BoxGeometry(1.4, 1.6, 1.8), this.matWarning);
    valveBox.position.set(2.8, 0.8, 0);
    group.add(valveBox);
  }

  buildLumberYard(group) {
    // Stack of massive treated logs
    for (let row = 0; row < 3; row++) {
      const count = 4 - row;
      for (let i = 0; i < count; i++) {
        const log = new THREE.Mesh(new THREE.CylinderGeometry(0.35, 0.35, 7.5, 8), this.matWood);
        log.rotation.x = Math.PI / 2;
        log.position.set((i - count / 2 + 0.5) * 0.75, 0.35 + row * 0.6, 0);
        log.castShadow = true;
        group.add(log);
      }
    }

    // Rustic open shed
    const shed = new THREE.Mesh(new THREE.BoxGeometry(6, 0.3, 4), this.matWood);
    shed.position.set(0, 3.2, -4);
    group.add(shed);
  }

  buildHydroStation(group) {
    // Concrete canal head & gate
    const gate = new THREE.Mesh(new THREE.BoxGeometry(1.2, 3.5, 6.0), this.matConcrete);
    gate.position.set(0, 1.75, 0);
    group.add(gate);

    // Large water wheel or impeller hub
    const impeller = new THREE.Mesh(new THREE.CylinderGeometry(1.6, 1.6, 0.8, 8), this.matCanopy);
    impeller.rotation.z = Math.PI / 2;
    impeller.position.set(1.5, 1.6, 0);
    group.add(impeller);

    // Retention basin railing
    const rail = new THREE.Mesh(new THREE.BoxGeometry(4.0, 1.0, 0.2), this.matWarning);
    rail.position.set(2.0, 0.5, 2.5);
    group.add(rail);
  }

  buildRadarSite(group) {
    // Concrete base pedestal
    const pedestal = new THREE.Mesh(new THREE.CylinderGeometry(2.0, 2.5, 1.5, 8), this.matConcrete);
    pedestal.position.y = 0.75;
    group.add(pedestal);

    // Parabolic dish structure
    const dish = new THREE.Mesh(new THREE.CylinderGeometry(3.0, 0.8, 0.6, 12), this.matCanopy);
    dish.position.set(0, 3.2, 0);
    dish.rotation.x = 0.6;
    dish.castShadow = true;
    group.add(dish);

    // Central feed horn probe
    const horn = new THREE.Mesh(new THREE.ConeGeometry(0.3, 1.8, 6), this.matWarning);
    horn.position.set(0, 3.8, 0.8);
    horn.rotation.x = 0.6;
    group.add(horn);
  }

  buildQuarryCrusher(group) {
    // Heavy rock crusher hopper
    const hopper = new THREE.Mesh(new THREE.CylinderGeometry(2.4, 1.2, 3.0, 4), this.matCargo);
    hopper.position.set(0, 2.8, 0);
    hopper.castShadow = true;
    group.add(hopper);

    // Heavy support struts
    [-1.8, 1.8].forEach((px) => {
      [-1.8, 1.8].forEach((pz) => {
        const strut = new THREE.Mesh(new THREE.BoxGeometry(0.3, 2.8, 0.3), this.matCanopy);
        strut.position.set(px, 1.4, pz);
        group.add(strut);
      });
    });

    // Pile of crushed iron ore
    const orePile = new THREE.Mesh(new THREE.ConeGeometry(2.2, 1.4, 7), this.matConcrete);
    orePile.position.set(3.5, 0.7, 0);
    group.add(orePile);
  }

  buildPolarShelter(group) {
    // Geodesic / Insulated Arctic Quonset pod
    const pod = new THREE.Mesh(new THREE.CylinderGeometry(2.2, 2.2, 5.0, 10), this.matWarning);
    pod.rotation.x = Math.PI / 2;
    pod.position.set(0, 1.6, 0);
    pod.castShadow = true;
    group.add(pod);

    // Insulated airlock door
    const door = new THREE.Mesh(new THREE.BoxGeometry(1.2, 1.8, 0.4), this.matCanopy);
    door.position.set(0, 0.9, 2.6);
    group.add(door);
  }

  buildCheckpoint(group) {
    // Concrete bunker guard post
    const bunker = new THREE.Mesh(new THREE.BoxGeometry(4.0, 2.8, 4.0), this.matConcrete);
    bunker.position.set(0, 1.4, 0);
    bunker.castShadow = true;
    group.add(bunker);

    // Slit visor aperture
    const visor = new THREE.Mesh(new THREE.BoxGeometry(2.5, 0.3, 0.2), this.matCanopy);
    visor.position.set(0, 1.8, 2.05);
    group.add(visor);

    // Striped barrier boom arm
    const barrier = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 5.5, 6), this.matWarning);
    barrier.rotation.z = Math.PI / 2;
    barrier.position.set(2.8, 1.1, 1.5);
    group.add(barrier);
  }

  buildConvoy(group) {
    // Overturned tractor-trailer cab
    const cab = new THREE.Mesh(new THREE.BoxGeometry(2.6, 2.8, 4.8), this.matCargo);
    cab.position.set(0, 1.4, -2.5);
    cab.rotation.y = 0.35;
    cab.castShadow = true;
    group.add(cab);

    // Overturned shipping container
    const container = new THREE.Mesh(new THREE.BoxGeometry(2.6, 2.6, 9.0), this.matCanopy);
    container.position.set(0.8, 1.3, 3.5);
    container.rotation.z = Math.PI / 2.3;
    container.castShadow = true;
    group.add(container);

    // Spilled crates
    for (let i = 0; i < 3; i++) {
      const crate = new THREE.Mesh(new THREE.BoxGeometry(1.0, 0.9, 1.0), this.matWood);
      crate.position.set(1.5 + (i - 1) * 1.2, 0.45, 1.5 + i * 1.2);
      crate.castShadow = true;
      group.add(crate);
    }
  }

  buildFisheryRuin(group) {
    // Coastal stone watchtower & old fishery storehouse
    const tower = new THREE.Mesh(new THREE.CylinderGeometry(2.4, 3.0, 8.5, 8), this.matConcrete);
    tower.position.set(-2, 4.25, 0);
    tower.castShadow = true;
    group.add(tower);

    // Stone workshop ruin
    const shed = new THREE.Mesh(new THREE.BoxGeometry(5.5, 2.8, 6.0), this.matConcrete);
    shed.position.set(4, 1.4, -1);
    shed.castShadow = true;
    group.add(shed);

    // Weathered timber pier
    const dock = new THREE.Mesh(new THREE.BoxGeometry(3.0, 0.35, 10.0), this.matWood);
    dock.position.set(1, 0.2, 6.5);
    group.add(dock);

    // Amber harbor beacon light
    const lantern = new THREE.PointLight(0xffaa33, 2.2, 22);
    lantern.position.set(-2, 8.8, 0);
    group.add(lantern);
  }

  buildCaravanPost(group) {
    // Adobe mudbrick cistern and oasis outpost
    const adobeWall = new THREE.Mesh(new THREE.BoxGeometry(8.0, 2.8, 10.0), this.matWarning);
    adobeWall.position.set(0, 1.4, 0);
    adobeWall.castShadow = true;
    group.add(adobeWall);

    // Water reservoir dome
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(2.2, 8, 8, 0, Math.PI * 2, 0, Math.PI * 0.5),
      this.matConcrete
    );
    dome.position.set(-5, 0, -2);
    group.add(dome);

    // Desert canopy fabric shelter
    const cloth = new THREE.Mesh(new THREE.BoxGeometry(4.5, 0.1, 5.0), this.matCargo);
    cloth.position.set(4, 2.6, 2);
    group.add(cloth);

    const oasisLight = new THREE.PointLight(0xf59e0b, 1.8, 18);
    oasisLight.position.set(0, 3.2, 0);
    group.add(oasisLight);
  }

  buildSavannaRangerSite(group) {
    // Elevated safari ranger watchtower
    const towerPad = new THREE.Mesh(new THREE.BoxGeometry(5.0, 0.3, 5.0), this.matWood);
    towerPad.position.set(0, 4.8, 0);
    group.add(towerPad);

    // 4 Splayed timber stilts
    [-1.8, 1.8].forEach((lx) => {
      [-1.8, 1.8].forEach((lz) => {
        const post = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.22, 5.0, 5), this.matWood);
        post.position.set(lx, 2.5, lz);
        post.castShadow = true;
        group.add(post);
      });
    });

    const cabin = new THREE.Mesh(new THREE.BoxGeometry(4.2, 2.4, 4.2), this.matCanopy);
    cabin.position.set(0, 6.1, 0);
    cabin.castShadow = true;
    group.add(cabin);

    // Radio transmitter mast
    const antenna = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.04, 5.5, 4), this.matMetalDark);
    antenna.position.set(1.8, 9.8, 1.8);
    group.add(antenna);
  }

  buildJungleBotanicalLab(group) {
    // Equatorial stilt research station
    const platform = new THREE.Mesh(new THREE.BoxGeometry(9.0, 0.4, 11.0), this.matWood);
    platform.position.set(0, 2.2, 0);
    group.add(platform);

    // Stilts
    [-3.5, 3.5].forEach((px) => {
      [-4.5, 4.5].forEach((pz) => {
        const stilt = new THREE.Mesh(new THREE.CylinderGeometry(0.2, 0.25, 2.4, 5), this.matWood);
        stilt.position.set(px, 1.1, pz);
        group.add(stilt);
      });
    });

    const lab = new THREE.Mesh(new THREE.BoxGeometry(7.5, 3.0, 8.5), this.matCanopy);
    lab.position.set(0, 3.8, 0);
    lab.castShadow = true;
    group.add(lab);

    // Green botanical biolab beacon
    const bioLight = new THREE.PointLight(0x10b981, 2.0, 20);
    bioLight.position.set(0, 5.8, 0);
    group.add(bioLight);
  }

  buildAlpineShelter(group) {
    // Concrete avalanche gallery shelter with sloping deflection roof
    const roof = new THREE.Mesh(new THREE.BoxGeometry(16, 0.7, 14), this.matConcrete);
    roof.position.set(0, 5.4, 0);
    roof.rotation.z = 0.18;
    group.add(roof);

    // Reinforced concrete support pillars
    [-5, 0, 5].forEach((pz) => {
      const col = new THREE.Mesh(new THREE.BoxGeometry(1.2, 5.4, 1.2), this.matConcrete);
      col.position.set(-6.5, 2.7, pz);
      col.castShadow = true;
      group.add(col);
    });

    // Emergency rescue refuge pod
    const cabin = new THREE.Mesh(new THREE.BoxGeometry(4.5, 2.6, 5.0), this.matMetalDark);
    cabin.position.set(4.5, 1.3, 0);
    cabin.castShadow = true;
    group.add(cabin);

    const rescueLight = new THREE.PointLight(0x38bdf8, 2.2, 22);
    rescueLight.position.set(4.5, 3.2, 0);
    group.add(rescueLight);
  }
}


// --- FILE: src/world/LandscapeManager.js ---
/**
 * THE LONG MERIDIAN - Breathtaking Landscapes, Celestial Sky & Landmark Megastructures
 * Renders distant mountain horizons, glowing Aurora Borealis ribbons, starfields, suspension bridges and neon motels.
 */

class LandscapeManager {
  constructor(scene, roadGenerator = null) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;

    this.group = new THREE.Group();
    this.scene.add(this.group);

    // Dynamic components
    this.auroraMesh = null;
    this.auroraTime = 0;
    this.distantMountains = [];
    this.landmarks = [];
    this.spawnedMilestones = new Set();

    this.initSkyAndMountains();
  }

  getRoadInfo(z) {
    if (this.roadGenerator && typeof this.roadGenerator.getRoadInfoAt === 'function') {
      return this.roadGenerator.getRoadInfoAt(z);
    }
    return { x: 0, y: 0, roadAngle: 0 };
  }

  initSkyAndMountains() {
    // 1. Starfield Dome
    const starCount = 600;
    const starGeo = new THREE.BufferGeometry();
    const starPositions = new Float32Array(starCount * 3);
    for (let i = 0; i < starCount; i++) {
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(Math.random() * 0.8 + 0.2);
      const r = 240;
      starPositions[i * 3 + 0] = r * Math.sin(phi) * Math.cos(theta);
      starPositions[i * 3 + 1] = r * Math.cos(phi) + 10;
      starPositions[i * 3 + 2] = r * Math.sin(phi) * Math.sin(theta);
    }
    starGeo.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
    const starMat = new THREE.PointsMaterial({
      color: 0xffffff,
      size: 1.2,
      transparent: true,
      opacity: 0.85
    });
    this.starPoints = new THREE.Points(starGeo, starMat);
    this.group.add(this.starPoints);

    // 2. Giant Low-Hanging Celestial Moon
    const moonGeo = new THREE.SphereGeometry(18, 16, 16);
    const moonMat = new THREE.MeshBasicMaterial({
      color: 0xffeed8,
      transparent: true,
      opacity: 0.88
    });
    this.moon = new THREE.Mesh(moonGeo, moonMat);
    this.moon.position.set(65, 80, 200);
    this.group.add(this.moon);

    // Moon Glow Halo
    const haloGeo = new THREE.PlaneGeometry(65, 65);
    const haloMat = new THREE.MeshBasicMaterial({
      color: 0xffc488,
      transparent: true,
      opacity: 0.22,
      blending: THREE.AdditiveBlending,
      side: THREE.DoubleSide
    });
    const halo = new THREE.Mesh(haloGeo, haloMat);
    halo.position.copy(this.moon.position);
    halo.position.z -= 1;
    this.group.add(halo);

    // 3. Shimmering Aurora Borealis Ribbon Shader
    this.initAuroraBorealis();

    // 4. Distant Mountain Ranges (Left and Right Horizons)
    this.initDistantMountains();
  }

  initAuroraBorealis() {
    // Ribbon mesh with waving sinusoidal deformation
    const width = 180;
    const height = 45;
    const segmentsW = 32;
    const segmentsH = 8;
    this.auroraGeo = new THREE.PlaneGeometry(width, height, segmentsW, segmentsH);

    // Create vibrant gradient canvas for Aurora ribbon
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 64;
    const ctx = canvas.getContext('2d');
    const grad = ctx.createLinearGradient(0, 64, 0, 0);
    grad.addColorStop(0, 'rgba(0, 0, 0, 0)');
    grad.addColorStop(0.3, 'rgba(16, 185, 129, 0.45)');  // Emerald green
    grad.addColorStop(0.7, 'rgba(6, 182, 212, 0.55)');   // Cyan
    grad.addColorStop(0.9, 'rgba(168, 85, 247, 0.35)');  // Violet
    grad.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, 256, 64);

    const auroraTex = new THREE.CanvasTexture(canvas);
    this.auroraMat = new THREE.MeshBasicMaterial({
      map: auroraTex,
      transparent: true,
      opacity: 0.75,
      blending: THREE.AdditiveBlending,
      side: THREE.DoubleSide,
      depthWrite: false
    });

    this.auroraMesh = new THREE.Mesh(this.auroraGeo, this.auroraMat);
    this.auroraMesh.position.set(0, 68, 140);
    this.auroraMesh.rotation.x = 0.35;
    this.group.add(this.auroraMesh);
  }

  initDistantMountains() {
    const mountainMat = new THREE.MeshStandardMaterial({
      color: 0x1b2028,
      roughness: 0.95,
      metalness: 0.08
    });

    const snowCapMat = new THREE.MeshStandardMaterial({
      color: 0xf1f5f9,
      roughness: 0.9,
      metalness: 0.05
    });

    // Create continuous jagged snow-capped mountain ridge modules on Left (-X) and Right (+X)
    [-1, 1].forEach((side) => {
      for (let i = 0; i < 6; i++) {
        const mGroup = new THREE.Group();
        const baseZ = i * 95;
        const xPos = side * (135 + Math.random() * 30);

        // Multiple overlapping jagged mountain cones with alpine snow peaks
        for (let j = 0; j < 4; j++) {
          const height = 45 + Math.random() * 40;
          const radius = 30 + Math.random() * 25;
          const cone = new THREE.Mesh(
            new THREE.ConeGeometry(radius, height, 6),
            mountainMat
          );
          const cx = (Math.random() - 0.5) * 30;
          const cz = (Math.random() - 0.5) * 45;
          cone.position.set(cx, height * 0.45, cz);
          cone.rotation.y = Math.random() * Math.PI;
          mGroup.add(cone);

          // Realistic Alaskan snow cap
          const capHeight = height * 0.38;
          const capRadius = radius * 0.38;
          const snowCap = new THREE.Mesh(
            new THREE.ConeGeometry(capRadius, capHeight, 6),
            snowCapMat
          );
          snowCap.position.set(cx, height * 0.81, cz);
          snowCap.rotation.y = cone.rotation.y;
          mGroup.add(snowCap);
        }

        mGroup.position.set(xPos, -2, baseZ);
        this.group.add(mGroup);
        this.distantMountains.push({ group: mGroup, side: side, z: baseZ });
      }
    });
  }

  update(playerZ, delta, biome) {
    // 1. Shift Stars, Moon and Aurora to follow player forward movement
    this.starPoints.position.z = playerZ;
    this.moon.position.z = playerZ + 200;

    // 2. Animate Aurora Borealis ribbon wave
    if (this.auroraMesh) {
      this.auroraTime += delta * 1.2;
      this.auroraMesh.position.z = playerZ + 140;

      const pos = this.auroraGeo.attributes.position.array;
      for (let i = 0; i < pos.length; i += 3) {
        const u = pos[i]; // X
        pos[i + 1] = 68 + Math.sin(u * 0.04 + this.auroraTime) * 6 + Math.cos(u * 0.08 + this.auroraTime * 0.7) * 3;
      }
      this.auroraGeo.attributes.position.needsUpdate = true;
    }

    // 3. Recycle Distant Mountains
    this.distantMountains.forEach((m) => {
      if (m.group.position.z < playerZ - 90) {
        m.group.position.z += 90 * 6;
      }
    });

    // 4. Deterministic Sector Milestone Landmarks
    // Each sector (650m) has:
    // - Boundary Gantry at sectorStart + 16m
    // - Contextual Thematic Megastructure at sectorStart + 350m
    const minSector = Math.floor(Math.max(0, playerZ - 60) / 650);
    const maxSector = Math.floor((playerZ + 240) / 650);

    for (let s = minSector; s <= maxSector; s++) {
      const sectorStart = s * 650;

      // 4a. Sector Boundary Highway Gantry Arch
      const gantryKey = `gantry_${s}`;
      const gantryZ = sectorStart + 16;
      if (!this.spawnedMilestones.has(gantryKey) && gantryZ > playerZ - 60) {
        this.spawnedMilestones.add(gantryKey);
        const group = this.createHighwayGantryLandmark(gantryZ, s);
        if (group) {
          this.scene.add(group);
          this.landmarks.push({ meshGroup: group, z: gantryZ });
        }
      }

      // 4b. Biome-Specific Narrative Megastructure at midpoint (sectorStart + 350m)
      const megaKey = `mega_${s}`;
      const megaZ = sectorStart + 350;
      if (!this.spawnedMilestones.has(megaKey) && megaZ > playerZ - 60) {
        this.spawnedMilestones.add(megaKey);
        const biomeIndex = s % 6;
        let res = null;

        if (biomeIndex === 0) {
          // Sector 0 (Rusty Periphery): Overgrown Collapsed Highway Flyover
          res = { group: this.createOverheadFlyover(megaZ) };
        } else if (biomeIndex === 1) {
          // Sector 1 (Black Pine Woods): The "NORTH STAR" Neon Diner & Motel oasis
          res = { group: this.createNeonDinerLandmark(megaZ) };
        } else if (biomeIndex === 2) {
          // Sector 2 (Flooded Marshland): Monumental Red Suspension Bridge Tower
          res = { group: this.createSuspensionBridgeTower(megaZ) };
        } else if (biomeIndex === 3) {
          // Sector 3 (The Glass Crater): Monolithic Parabolic Satellite Radar Dish
          res = { group: this.createSatelliteDish(megaZ) };
        } else if (biomeIndex === 4) {
          // Sector 4 (Iron Gorge): Canyon High-Wire Suspension Crossing
          res = { group: this.createSuspensionBridgeTower(megaZ) };
        } else {
          // Sector 5 (Permafrost Highlands): Wind Farm of 3 Staggered Turbines
          res = this.createWindTurbineLandmark(megaZ);
        }

        if (res && res.group) {
          this.scene.add(res.group);
          this.landmarks.push({
            meshGroup: res.group,
            rotor: res.rotor || null,
            z: megaZ
          });
        }
      }
    }

    // 5. Clean up landmarks behind
    for (let i = this.landmarks.length - 1; i >= 0; i--) {
      const lm = this.landmarks[i];
      if (lm.meshGroup.position.z < playerZ - 80) {
        this.scene.remove(lm.meshGroup);
        this.landmarks.splice(i, 1);
      }
    }

    // 6. Animate rotating landmarks (e.g. wind turbine blades)
    for (let i = 0; i < this.landmarks.length; i++) {
      const lm = this.landmarks[i];
      if (lm.rotor) {
        lm.rotor.rotation.z += delta * 0.45;
      }
    }
  }

  createSuspensionBridgeTower(z) {
    const group = new THREE.Group();
    const roadInfo = this.getRoadInfo(z);
    group.position.set(roadInfo.x, roadInfo.y, z);
    group.rotation.y = roadInfo.roadAngle || 0;

    const steelMat = new THREE.MeshStandardMaterial({
      color: 0x8a2b20, // International orange/red bridge steel
      roughness: 0.6,
      metalness: 0.7
    });
    const cableMat = new THREE.LineBasicMaterial({ color: 0x333333, linewidth: 2 });
    const lightMat = new THREE.MeshBasicMaterial({ color: 0xff2222 });

    // Dual Giant Pylons (Left & Right of 24m road + shoulders)
    [-14.5, 14.5].forEach((px) => {
      const pylon = new THREE.Mesh(new THREE.BoxGeometry(1.8, 38, 2.2), steelMat);
      pylon.position.set(px, 19, 0);
      pylon.castShadow = true;
      group.add(pylon);

      // Red aircraft warning beacon at summit
      const beacon = new THREE.Mesh(new THREE.SphereGeometry(0.5, 8, 8), lightMat);
      beacon.position.set(px, 38.3, 0);
      group.add(beacon);

      const beaconLight = new THREE.PointLight(0xff2222, 1.5, 25);
      beaconLight.position.set(px, 38.3, 0);
      group.add(beaconLight);
    });

    // Horizontal Portal Crossbeam
    const crossbeam = new THREE.Mesh(new THREE.BoxGeometry(31, 1.8, 2.0), steelMat);
    crossbeam.position.set(0, 32, 0);
    crossbeam.castShadow = true;
    group.add(crossbeam);

    // Suspension Main Cables arching down to the road deck
    [-14.5, 14.5].forEach((px) => {
      const curve = new THREE.QuadraticBezierCurve3(
        new THREE.Vector3(px, 37, 0),
        new THREE.Vector3(px * 0.9, 12, 45),
        new THREE.Vector3(px * 0.85, 1, 90)
      );
      const points = curve.getPoints(20);
      const cableGeo = new THREE.BufferGeometry().setFromPoints(points);
      const cableLine = new THREE.Line(cableGeo, cableMat);
      group.add(cableLine);
    });

    return group;
  }

  createNeonDinerLandmark(z) {
    const group = new THREE.Group();
    // Placed off to the right shoulder
    group.position.set(16, 0, z);

    const darkWallMat = new THREE.MeshStandardMaterial({ color: 0x242830, roughness: 0.8 });
    const neonCyan = new THREE.MeshBasicMaterial({ color: 0x06b6d4 });
    const neonPink = new THREE.MeshBasicMaterial({ color: 0xf43f5e });

    // Diner Building Shell
    const building = new THREE.Mesh(new THREE.BoxGeometry(14, 4.2, 18), darkWallMat);
    building.position.set(0, 2.1, 0);
    building.castShadow = true;
    group.add(building);

    // Glowing Neon Roof Sign ("NORTH STAR - LAST STOP")
    const signBox = new THREE.Mesh(new THREE.BoxGeometry(8.5, 2.2, 0.4), darkWallMat);
    signBox.position.set(0, 5.4, 6);
    group.add(signBox);

    const neonBar1 = new THREE.Mesh(new THREE.BoxGeometry(7.5, 0.25, 0.5), neonPink);
    neonBar1.position.set(0, 5.8, 6.1);
    group.add(neonBar1);

    const neonBar2 = new THREE.Mesh(new THREE.BoxGeometry(6.0, 0.25, 0.5), neonCyan);
    neonBar2.position.set(0, 5.0, 6.1);
    group.add(neonBar2);

    // Pink / Cyan Ambient Neon Glow onto the asphalt
    const neonLight = new THREE.PointLight(0xf43f5e, 2.5, 35);
    neonLight.position.set(0, 5.5, 6);
    group.add(neonLight);

    const cyanGlow = new THREE.PointLight(0x06b6d4, 1.8, 28);
    cyanGlow.position.set(0, 2.5, 9);
    group.add(cyanGlow);

    return group;
  }

  createOverheadFlyover(z) {
    const group = new THREE.Group();
    const roadInfo = this.getRoadInfo(z);
    group.position.set(roadInfo.x, roadInfo.y, z);
    group.rotation.y = (roadInfo.roadAngle || 0) + 0.25;

    const concMat = new THREE.MeshStandardMaterial({ color: 0x474c52, roughness: 0.9 });
    const steelMat = new THREE.MeshStandardMaterial({ color: 0x282c30, metalness: 0.6 });

    // Overhead highway deck crossing at 7m height
    const deck = new THREE.Mesh(new THREE.BoxGeometry(52, 1.4, 9), concMat);
    deck.position.set(0, 7.5, 0);
    deck.rotation.y = 0.25; // angled crossing
    deck.castShadow = true;
    group.add(deck);

    // Broken collapsed section with exposed rebar
    const rebarMat = new THREE.MeshStandardMaterial({ color: 0x7c2d12, metalness: 0.8 });
    for (let r = 0; r < 5; r++) {
      const rebar = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.04, 2.5, 4), rebarMat);
      rebar.position.set(10 + r * 0.8, 6.8, (Math.random() - 0.5) * 3);
      rebar.rotation.z = Math.PI / 4;
      group.add(rebar);
    }

    // Heavy concrete bridge piers set back beyond 24m gravel shoulders
    [-14.2, 14.2].forEach((px) => {
      const pier = new THREE.Mesh(new THREE.CylinderGeometry(1.2, 1.4, 7.5, 8), concMat);
      pier.position.set(px, 3.75, 0);
      pier.castShadow = true;
      group.add(pier);
    });

    return group;
  }

  createSatelliteDish(z) {
    const group = new THREE.Group();
    group.position.set(-32, 0, z);

    const dishMat = new THREE.MeshStandardMaterial({ color: 0xcfd8dc, roughness: 0.5, metalness: 0.6 });
    const mastMat = new THREE.MeshStandardMaterial({ color: 0x37474f, roughness: 0.8 });

    // Tower base
    const mast = new THREE.Mesh(new THREE.CylinderGeometry(1.5, 3.5, 18, 6), mastMat);
    mast.position.y = 9;
    mast.castShadow = true;
    group.add(mast);

    // Giant Parabolic Dish (18m diameter)
    const dish = new THREE.Mesh(
      new THREE.SphereGeometry(9, 16, 8, 0, Math.PI * 2, 0, Math.PI * 0.35),
      dishMat
    );
    dish.position.set(0, 18, 0);
    dish.rotation.x = -Math.PI / 3;
    dish.castShadow = true;
    group.add(dish);

    // Central receiver antenna
    const subAntenna = new THREE.Mesh(new THREE.CylinderGeometry(0.15, 0.2, 7.0, 5), mastMat);
    subAntenna.position.set(0, 20.5, 3.5);
    subAntenna.rotation.x = -Math.PI / 3;
    group.add(subAntenna);

    return group;
  }

  createWindTurbineLandmark(z) {
    const group = new THREE.Group();
    // Placed far on left or right rolling hills
    const side = Math.random() < 0.5 ? -1 : 1;
    group.position.set(side * 42, 0, z);

    const whiteMat = new THREE.MeshStandardMaterial({ color: 0xecf0f1, roughness: 0.4 });
    const darkMat = new THREE.MeshStandardMaterial({ color: 0x2c3e50, roughness: 0.8 });

    // 1. Tapered wind turbine mast (32m tall)
    const mast = new THREE.Mesh(new THREE.CylinderGeometry(0.8, 2.2, 32, 10), whiteMat);
    mast.position.y = 16;
    mast.castShadow = true;
    group.add(mast);

    // 2. Nacelle housing on top
    const nacelle = new THREE.Mesh(new THREE.BoxGeometry(2.4, 2.2, 6.0), whiteMat);
    nacelle.position.set(0, 32, 0);
    nacelle.castShadow = true;
    group.add(nacelle);

    // Red flashing hazard beacon on nacelle
    const beacon = new THREE.Mesh(
      new THREE.SphereGeometry(0.35, 6, 6),
      new THREE.MeshBasicMaterial({ color: 0xff0000 })
    );
    beacon.position.set(0, 33.3, -2.5);
    group.add(beacon);

    const beaconLight = new THREE.PointLight(0xff0000, 1.2, 20);
    beaconLight.position.set(0, 33.3, -2.5);
    group.add(beaconLight);

    // 3. 3-Blade Rotor Hub (attached at front of nacelle, facing road)
    const rotorGroup = new THREE.Group();
    rotorGroup.position.set(0, 32, 3.2);

    const hub = new THREE.Mesh(new THREE.SphereGeometry(1.2, 8, 8), darkMat);
    rotorGroup.add(hub);

    // 3 long aerodynamic blades (16m long each)
    for (let b = 0; b < 3; b++) {
      const angle = (b * Math.PI * 2) / 3;
      const blade = new THREE.Mesh(new THREE.BoxGeometry(0.65, 16, 0.15), whiteMat);
      blade.position.set(Math.sin(angle) * 8.0, Math.cos(angle) * 8.0, 0);
      blade.rotation.z = -angle;
      blade.castShadow = true;
      rotorGroup.add(blade);
    }

    group.add(rotorGroup);

    return { group: group, rotor: rotorGroup };
  }

  createHighwayGantryLandmark(z, sectorIndex = 0) {
    const group = new THREE.Group();
    const roadInfo = this.getRoadInfo(z);
    group.position.set(roadInfo.x, roadInfo.y, z);
    group.rotation.y = roadInfo.roadAngle || 0;

    const steelMat = new THREE.MeshStandardMaterial({ color: 0x3e444c, roughness: 0.6, metalness: 0.7 });
    const signMat = new THREE.MeshStandardMaterial({ color: 0x0f172a, roughness: 0.8 });

    // Dual vertical lattice support legs straddling the 24m road deck + shoulders
    [-13.8, 13.8].forEach((lx) => {
      const leg = new THREE.Mesh(new THREE.BoxGeometry(0.8, 10.0, 0.8), steelMat);
      leg.position.set(lx, 5.0, 0);
      leg.castShadow = true;
      group.add(leg);
    });

    // Horizontal truss span over roadway
    const span = new THREE.Mesh(new THREE.BoxGeometry(29.5, 1.4, 1.4), steelMat);
    span.position.set(0, 9.5, 0);
    span.castShadow = true;
    group.add(span);

    // Overhead Digital Electronic Matrix Signs (Facing approaching driver)
    const signBoard = new THREE.Mesh(new THREE.BoxGeometry(23.0, 2.3, 0.25), signMat);
    signBoard.position.set(0, 9.3, -0.7);
    group.add(signBoard);

    // Dynamic High-Visibility LED Matrix Canvas
    const canvas = document.createElement('canvas');
    canvas.width = 512;
    canvas.height = 128;
    const ctx = canvas.getContext('2d');

    // Matrix amber background
    ctx.fillStyle = '#05070a';
    ctx.fillRect(0, 0, 512, 128);

    // Border
    ctx.strokeStyle = '#f59e0b';
    ctx.lineWidth = 4;
    ctx.strokeRect(4, 4, 504, 120);

    const destMessages = [
      { top: 'FOX & GOLDSTREAM DREDGE 8 [MP 11]', sub: 'DALTON HWY 11 - FAIRBANKS MINING BELT / SLOW VEHICLES' },
      { top: 'YUKON RIVER - E.L. PATTON BRIDGE [MP 56]', sub: 'BLACK SPRUCE TAIGA - CAUTION ICE FOG & PIPELINE CREWS' },
      { top: 'COLDFOOT TRUCK STOP - SLATE CREEK [MP 175]', sub: 'KOYUKUK FLATS - SEVERE MUSKEG MUD / REDUCE SPEED' },
      { top: 'ARCTIC CIRCLE LAT 66° 33\' N [MP 244]', sub: 'CHANDALAR DEW LINE - GEOMAGNETIC STATIC RISK' },
      { top: 'ATIGUN PASS ELEV 4739 FT [MP 290]', sub: 'BROOKS RANGE DIVIDE - 12% STEEP GRADE / ROCKFALL HAZARD' },
      { top: 'DEADHORSE & PRUDHOE BAY [MP 414]', sub: 'BEAUFORT SEA - CONTINUOUS PERMAFROST / EXTREME BLIZZARD' }
    ];

    const idx = (sectorIndex || 0) % destMessages.length;
    const msg = destMessages[idx];

    // Primary Text (Amber LED)
    ctx.fillStyle = '#f59e0b';
    ctx.font = 'bold 22px monospace';
    ctx.textAlign = 'center';
    ctx.fillText(msg.top, 256, 48);

    // Hazard Subtitle (Yellow-Red)
    ctx.fillStyle = '#ef4444';
    ctx.font = 'bold 15px monospace';
    ctx.fillText(msg.sub, 256, 88);

    const signTexture = new THREE.CanvasTexture(canvas);
    const ledSignMat = new THREE.MeshBasicMaterial({ map: signTexture });
    const signScreen = new THREE.Mesh(new THREE.PlaneGeometry(13.2, 1.8), ledSignMat);
    signScreen.position.set(0, 8.8, -0.84);
    group.add(signScreen);

    // Lane control green arrows
    [-3.2, 3.2].forEach((ax) => {
      const laneSignal = new THREE.Mesh(
        new THREE.BoxGeometry(0.5, 0.5, 0.3),
        new THREE.MeshBasicMaterial({ color: 0x10b981 }) // Green check
      );
      laneSignal.position.set(ax, 7.6, -0.7);
      group.add(laneSignal);
    });

    // Downward illumination floodlights on roadway
    const flood = new THREE.SpotLight(0xffeedd, 2.5, 20, Math.PI / 4, 0.4, 1.5);
    flood.position.set(0, 8.8, 0);
    flood.target.position.set(0, 0, 0);
    group.add(flood);
    group.add(flood.target);

    return group;
  }
}


// --- FILE: src/entities/Vehicle.js ---
/**
 * THE LONG MERIDIAN - High-Fidelity 3D Multi-Model European Classic Survivor Vehicles
 * Features 11 authentic European real-world models (1960s-1990s) with authentic physics,
 * distinct silhouettes, specialized drivetrain handling, turbo lag, and suspension dynamics.
 */

class Vehicle {
  constructor(scene, audioEngine) {
    this.scene = scene;
    this.audioEngine = audioEngine;

    // Active model ID and specs from catalog
    this.modelId = CONFIG.DEFAULT_VEHICLE_ID || 'panda_4x4';
    this.modelConfig = CONFIG.VEHICLES_CATALOG[this.modelId] || CONFIG.VEHICLES_CATALOG.panda_4x4;

    // Transform & Motion
    this.position = new THREE.Vector3(0, 0, 5);
    this.velocity = new THREE.Vector3(0, 0, 0);
    this.rotation = new THREE.Euler(0, 0, 0, 'YXZ');
    this.forwardSpeed = 0.0;
    this.lateralSpeed = 0.0;
    this.steerAngle = 0.0;
    this.isEngineOn = true;
    this.isLightsOn = true;
    this.isBraking = false;
    this.wasThrottling = false;

    // Transmission & Reverse Interlock
    this.gearState = 'DRIVE'; // 'DRIVE' or 'REVERSE'
    this.standstillTimer = 0.0;
    this.wasBraking = false;
    this.reverseArmed = false;
    this.is4WDEngaged = true; // Steyr-Puch 4WD engaged by default
    this.priminaCrawlerActive = false; // Primina crawler 1st gear for Panda 4x4

    // Engine & Drivetrain Live Telemetry
    this.speedKmh = 0;
    this.rpm = 0.0;             // Normalized 0..1
    this.engineRpmActual = 850; // Actual RPM (e.g. 850 - 7000)
    this.boostBar = 0.0;        // Live turbo boost pressure (Bar)
    this.gear = 1;
    this.hull = 100;
    this.fuel = this.modelConfig.fuelTankL * 0.85;
    this.maxFuel = this.modelConfig.fuelTankL;
    this.engineTemp = 75;
    this.battery = 100;
    this.tireWear = 0;
    this.oversteerSlip = 0.0;

    // Dynamic Physical Dimensions & 2-DOF Vehicle Dynamics State
    this.modelDims = this.getModelDimensions(this.modelId);
    this.currentRoll = 0.0;
    this.currentPitch = 0.0;
    this.lastSpeed = 0.0;
    this.actualTurnRate = 0.0;
    this.yawRate = 0.0;
    this.lateralSpeed = 0.0;
    this.slipAngle = 0.0;
    this.weightTransferLong = 0.0;
    this.hasFlatTire = false;
    this.chassisScrapeTimer = 0.0;
    this.terrainZone = 'PAVED';
    this.terrainStatusText = 'ASFALTO (CARREGGIATA)';
    this.terrainStatusColor = '#22c55e';

    // Progressive Non-Linear Steering & Impact Shock State
    this.filteredSteer = 0.0;
    this.impactShockPitch = 0.0;
    this.impactShockRoll = 0.0;

    // Installed Modular Upgrades
    this.upgrades = {
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
    };
    this.radarAlert = null;
    this.radarAlertTimer = 0;

    // 3D Meshes & Lights Group
    this.group = new THREE.Group();
    this.wheels = [];
    this.frontWheels = [];
    this.headlights = [];
    this.lightCones = [];
    this.taillights = [];
    this.upgradeMeshes = {};
    this.exhaustTip = new THREE.Vector3();
    this.antenna = null;

    this.buildCurrentVehicleMesh();
    this.scene.add(this.group);
  }

  /**
   * Switch the active vehicle to any model in the catalog
   */
  setModel(newModelId) {
    if (!CONFIG.VEHICLES_CATALOG[newModelId]) {
      console.warn(`Model ${newModelId} not found in catalog!`);
      return false;
    }

    this.modelId = newModelId;
    this.modelConfig = CONFIG.VEHICLES_CATALOG[newModelId];
    this.modelDims = this.getModelDimensions(newModelId);

    // Reset dynamic suspension angles & 2-DOF physics state
    this.currentRoll = 0.0;
    this.currentPitch = 0.0;
    this.steerAngle = 0.0;
    this.actualTurnRate = 0.0;
    this.yawRate = 0.0;
    this.lateralSpeed = 0.0;
    this.slipAngle = 0.0;
    this.weightTransferLong = 0.0;
    this.filteredSteer = 0.0;
    this.impactShockPitch = 0.0;
    this.impactShockRoll = 0.0;
    this.oversteerSlip = 0.0;

    // Adapt fuel capacity and adjust fuel proportionally
    const fuelRatio = this.maxFuel > 0 ? this.fuel / this.maxFuel : 0.8;
    this.maxFuel = this.modelConfig.fuelTankL + (this.upgrades.aux_tank ? 40 : 0);
    this.fuel = Math.min(this.maxFuel, Math.max(10, fuelRatio * this.maxFuel));

    // Reset turbo boost
    this.boostBar = 0.0;

    // Rebuild 3D mesh
    this.buildCurrentVehicleMesh();

    // Inform audio engine of new engine acoustic profile
    if (this.audioEngine && this.audioEngine.setEngineProfile) {
      this.audioEngine.setEngineProfile(this.modelConfig.soundProfile);
    }

    return true;
  }

  getCurrentModelConfig() {
    return this.modelConfig;
  }

  /**
   * Cleans and rebuilds the 3D meshes for the active car model
   */
  buildCurrentVehicleMesh() {
    // 1. Remove all old children from group
    while (this.group.children.length > 0) {
      const obj = this.group.children[0];
      this.group.remove(obj);
      if (obj.geometry) obj.geometry.dispose();
      if (obj.material) {
        if (Array.isArray(obj.material)) obj.material.forEach((m) => m.dispose());
        else obj.material.dispose();
      }
    }

    this.wheels = [];
    this.frontWheels = [];
    this.headlights = [];
    this.lightCones = [];
    this.taillights = [];
    this.upgradeMeshes = {};

    const cfg = this.modelConfig;

    // 2. Curated Model Palettes & Materials
    const palette = this.getModelPalette(cfg.id);

    const bodyMat = new THREE.MeshStandardMaterial({
      color: palette.bodyColor,
      roughness: palette.roughness || 0.45,
      metalness: palette.metalness || 0.55
    });

    const trimMat = new THREE.MeshStandardMaterial({
      color: palette.trimColor || 0x1f2326,
      roughness: 0.8,
      metalness: 0.3
    });

    const chromeMat = new THREE.MeshStandardMaterial({
      color: 0xdde3ea,
      roughness: 0.18,
      metalness: 0.95
    });

    const glassMat = new THREE.MeshStandardMaterial({
      color: 0x111a22,
      roughness: 0.1,
      metalness: 0.9,
      transparent: true,
      opacity: 0.85
    });

    const tireMat = new THREE.MeshStandardMaterial({
      color: 0x141517,
      roughness: 0.95
    });

    const rimMat = new THREE.MeshStandardMaterial({
      color: palette.rimColor || 0x6e7882,
      roughness: 0.3,
      metalness: 0.85
    });

    // 3. Dimensional Scaling based on car type
    const dims = this.getModelDimensions(cfg.id);

    // Main lower chassis
    const chassisGeo = new THREE.BoxGeometry(dims.width * 0.96, dims.chassisHeight, dims.length * 0.98);
    const chassis = new THREE.Mesh(chassisGeo, trimMat);
    chassis.position.y = dims.groundY + dims.chassisHeight * 0.5;
    chassis.castShadow = true;
    chassis.receiveShadow = true;
    this.group.add(chassis);

    // Main lower body shell (fenders, doors, rocker panels)
    const bodyGeo = new THREE.BoxGeometry(dims.width, dims.bodyHeight, dims.length);
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = chassis.position.y + dims.chassisHeight * 0.5 + dims.bodyHeight * 0.5;
    body.castShadow = true;
    body.receiveShadow = true;
    this.group.add(body);

    // Model-Specific Hood, Grille & Front Fascia
    this.buildFrontFascia(cfg.id, dims, body.position.y, bodyMat, trimMat, chromeMat);

    // Model-Specific Cabin Greenhouse (roof, pillars, windshield, side windows)
    this.buildCabinGreenhouse(cfg.id, dims, body.position.y, bodyMat, trimMat, glassMat, chromeMat);

    // Model-Specific Rear Fascia & Tailgate
    this.buildRearFascia(cfg.id, dims, body.position.y, bodyMat, trimMat, chromeMat);

    // 4. Wheels & Suspension Setup
    this.buildWheels(dims, tireMat, rimMat, chromeMat, trimMat);

    // 5. Headlights & Volumetric Fog Light Cones
    this.buildLighting(dims, body.position.y, chromeMat);

    // 6. Model-Specific Exterior Details (Spoilers, Snorkel, Spare Wheels, Roof Rails)
    this.buildModelSpecificAccoutrements(cfg.id, dims, body.position.y, bodyMat, trimMat, chromeMat);

    // 7. Radio Antenna
    const antX = -dims.width * 0.44;
    const antZ = -dims.length * 0.38;
    const antBaseY = body.position.y + dims.bodyHeight * 0.5 + dims.cabinHeight;

    const antBase = new THREE.Mesh(new THREE.CylinderGeometry(0.03, 0.05, 0.15, 6), trimMat);
    antBase.position.set(antX, antBaseY, antZ);
    this.group.add(antBase);

    this.antenna = new THREE.Mesh(
      new THREE.CylinderGeometry(0.012, 0.018, 1.8, 4),
      new THREE.MeshStandardMaterial({ color: 0xa0aec0, metalness: 0.9 })
    );
    this.antenna.position.set(antX, antBaseY + 0.9, antZ);
    this.group.add(this.antenna);

    // 8. Re-apply any installed modular upgrades (bullbar, roof lights, etc.)
    this.buildUpgradeModules(dims, body.position.y, trimMat);
  }

  /**
   * Period-correct color palettes for the 11 European models
   */
  getModelPalette(modelId) {
    switch (modelId) {
      case 'panda_4x4':
        return { bodyColor: 0x4a5d4e, trimColor: 0x1f2322, rimColor: 0xd1d5db, roughness: 0.65, metalness: 0.25 }; // Forest Green
      case 'delta_integrale':
        return { bodyColor: 0xb91c1c, trimColor: 0x111315, rimColor: 0xe2e8f0, roughness: 0.35, metalness: 0.65 }; // Rosso Monza WRC
      case 'mercedes_w123':
        return { bodyColor: 0xc4cad2, trimColor: 0x24282c, rimColor: 0xe2e8f0, roughness: 0.3, metalness: 0.8 }; // Classic Silbermetallic
      case 'mercedes_gwagen':
        return { bodyColor: 0x3d433b, trimColor: 0x181a18, rimColor: 0x475569, roughness: 0.7, metalness: 0.3 }; // NATO Olivgrün
      case 'defender_110':
        return { bodyColor: 0x38483e, trimColor: 0x181b19, rimColor: 0xf8fafc, roughness: 0.75, metalness: 0.2 }; // Keswick Green + Limestone wheels
      case 'volvo_245':
        return { bodyColor: 0x273b4d, trimColor: 0x15181b, rimColor: 0xcfd8dc, roughness: 0.45, metalness: 0.5 }; // Swedish Dark Blue
      case 'audi_quattro':
        return { bodyColor: 0x991b1b, trimColor: 0x151618, rimColor: 0xe2e8f0, roughness: 0.32, metalness: 0.7 }; // Tornado Red / Audi Sport
      case 'bmw_e30_ix':
        return { bodyColor: 0x22262c, trimColor: 0x121417, rimColor: 0xd8e0e8, roughness: 0.35, metalness: 0.75 }; // Diamantschwarz Metallic
      case 'alfa_giulia':
        return { bodyColor: 0x881313, trimColor: 0x1a1c1e, rimColor: 0xe2e8f0, roughness: 0.3, metalness: 0.8 }; // Rosso Alfa 501
      case 'peugeot_504_dangel':
        return { bodyColor: 0xb48235, trimColor: 0x1c1e1d, rimColor: 0xd1d5db, roughness: 0.6, metalness: 0.35 }; // Sahara Safari Ochre
      case 'golf_country':
        return { bodyColor: 0x214d3b, trimColor: 0x181e1a, rimColor: 0x94a3b8, roughness: 0.5, metalness: 0.45 }; // Montana Waldgrün
      default:
        return { bodyColor: 0x3e4843, trimColor: 0x1f2326, rimColor: 0x64707a, roughness: 0.5, metalness: 0.5 };
    }
  }

  /**
   * Silhouette bounding parameters for each car
   */
  getModelDimensions(modelId) {
    switch (modelId) {
      case 'panda_4x4':
        return { width: 1.55, length: 3.40, groundY: 0.40, chassisHeight: 0.36, bodyHeight: 0.54, cabinHeight: 0.70, cabinLength: 2.1, wheelRadius: 0.36, wheelWidth: 0.24, wheelBase: 2.15, trackWidth: 1.38, isHatch: true };
      case 'delta_integrale':
        return { width: 1.74, length: 3.90, groundY: 0.33, chassisHeight: 0.32, bodyHeight: 0.48, cabinHeight: 0.64, cabinLength: 2.2, wheelRadius: 0.36, wheelWidth: 0.28, wheelBase: 2.48, trackWidth: 1.52, isRallyWide: true };
      case 'mercedes_w123':
        return { width: 1.78, length: 4.72, groundY: 0.36, chassisHeight: 0.34, bodyHeight: 0.50, cabinHeight: 0.66, cabinLength: 3.0, wheelRadius: 0.38, wheelWidth: 0.26, wheelBase: 2.80, trackWidth: 1.50, isWagon: true };
      case 'mercedes_gwagen':
        return { width: 1.82, length: 4.25, groundY: 0.50, chassisHeight: 0.44, bodyHeight: 0.62, cabinHeight: 0.82, cabinLength: 2.6, wheelRadius: 0.44, wheelWidth: 0.30, wheelBase: 2.85, trackWidth: 1.54, isBoxy4x4: true };
      case 'defender_110':
        return { width: 1.84, length: 4.60, groundY: 0.52, chassisHeight: 0.46, bodyHeight: 0.66, cabinHeight: 0.86, cabinLength: 3.0, wheelRadius: 0.46, wheelWidth: 0.30, wheelBase: 2.98, trackWidth: 1.56, isSafari: true };
      case 'volvo_245':
        return { width: 1.74, length: 4.78, groundY: 0.36, chassisHeight: 0.34, bodyHeight: 0.52, cabinHeight: 0.68, cabinLength: 3.1, wheelRadius: 0.38, wheelWidth: 0.26, wheelBase: 2.78, trackWidth: 1.48, isBrickWagon: true };
      case 'audi_quattro':
        return { width: 1.72, length: 4.40, groundY: 0.34, chassisHeight: 0.34, bodyHeight: 0.48, cabinHeight: 0.62, cabinLength: 2.4, wheelRadius: 0.38, wheelWidth: 0.28, wheelBase: 2.54, trackWidth: 1.52, isCoupeFlared: true };
      case 'bmw_e30_ix':
        return { width: 1.68, length: 4.32, groundY: 0.35, chassisHeight: 0.33, bodyHeight: 0.46, cabinHeight: 0.64, cabinLength: 2.6, wheelRadius: 0.37, wheelWidth: 0.26, wheelBase: 2.56, trackWidth: 1.46, isSportTouring: true };
      case 'alfa_giulia':
        return { width: 1.62, length: 4.14, groundY: 0.35, chassisHeight: 0.32, bodyHeight: 0.48, cabinHeight: 0.64, cabinLength: 2.3, wheelRadius: 0.36, wheelWidth: 0.24, wheelBase: 2.51, trackWidth: 1.42, isClassicSaloon: true };
      case 'peugeot_504_dangel':
        return { width: 1.72, length: 4.60, groundY: 0.48, chassisHeight: 0.40, bodyHeight: 0.54, cabinHeight: 0.70, cabinLength: 2.9, wheelRadius: 0.42, wheelWidth: 0.28, wheelBase: 2.86, trackWidth: 1.50, isSafariWagon: true };
      case 'golf_country':
        return { width: 1.68, length: 3.98, groundY: 0.46, chassisHeight: 0.38, bodyHeight: 0.52, cabinHeight: 0.68, cabinLength: 2.3, wheelRadius: 0.40, wheelWidth: 0.26, wheelBase: 2.46, trackWidth: 1.46, isRaisedSyncro: true };
      default:
        return { width: 1.75, length: 4.20, groundY: 0.42, chassisHeight: 0.38, bodyHeight: 0.56, cabinHeight: 0.70, cabinLength: 2.5, wheelRadius: 0.40, wheelWidth: 0.28, wheelBase: 2.60, trackWidth: 1.50 };
    }
  }

  /**
   * Front Fascia: Grille, Radiator, Bumper, and Brand Identification
   */
  buildFrontFascia(modelId, dims, bodyCenterY, bodyMat, trimMat, chromeMat) {
    const frontZ = dims.length * 0.5;

    // Heavy Front Bumper
    const bumperMat = (modelId === 'mercedes_w123' || modelId === 'alfa_giulia') ? chromeMat : trimMat;
    const bumperWidth = dims.width * (dims.isRallyWide ? 1.08 : 1.04);
    const bumperDepth = modelId === 'volvo_245' ? 0.42 : 0.28; // Massive 5-mph bumper on Volvo
    const fvBumper = new THREE.Mesh(new THREE.BoxGeometry(bumperWidth, 0.32, bumperDepth), bumperMat);
    fvBumper.position.set(0, dims.groundY + dims.chassisHeight * 0.7, frontZ + bumperDepth * 0.5);
    fvBumper.castShadow = true;
    this.group.add(fvBumper);

    // Radiator Grille & Brand Elements
    if (modelId === 'mercedes_w123') {
      // Classic Vertical Chrome Grille with 3-Pointed Star
      const grille = new THREE.Mesh(new THREE.BoxGeometry(0.75, 0.50, 0.12), chromeMat);
      grille.position.set(0, bodyCenterY + 0.05, frontZ + 0.02);
      this.group.add(grille);

      // Star mascot on top of hood
      const starStem = new THREE.Mesh(new THREE.CylinderGeometry(0.015, 0.015, 0.12, 6), chromeMat);
      starStem.position.set(0, bodyCenterY + 0.36, frontZ - 0.02);
      const starRing = new THREE.Mesh(new THREE.TorusGeometry(0.055, 0.01, 8, 12), chromeMat);
      starRing.position.set(0, bodyCenterY + 0.42, frontZ - 0.02);
      this.group.add(starStem);
      this.group.add(starRing);
    } else if (modelId === 'bmw_e30_ix') {
      // Iconic BMW Twin Kidney Grille
      [-0.14, 0.14].forEach((kx) => {
        const kidney = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.38, 0.1), chromeMat);
        kidney.position.set(kx, bodyCenterY, frontZ + 0.02);
        this.group.add(kidney);
      });
      // Outer black slats
      [-0.6, 0.6].forEach((gx) => {
        const slats = new THREE.Mesh(new THREE.BoxGeometry(0.55, 0.35, 0.08), trimMat);
        slats.position.set(gx, bodyCenterY, frontZ + 0.01);
        this.group.add(slats);
      });
    } else if (modelId === 'alfa_giulia') {
      // Classic Alfa Romeo Trilobo Heart Grille
      const heart = new THREE.Mesh(new THREE.ConeGeometry(0.18, 0.42, 3), chromeMat);
      heart.rotation.x = Math.PI;
      heart.position.set(0, bodyCenterY - 0.02, frontZ + 0.02);
      this.group.add(heart);
      // Horizontal chrome mustache whiskers
      [-0.5, 0.5].forEach((wx) => {
        const whisker = new THREE.Mesh(new THREE.BoxGeometry(0.65, 0.06, 0.06), chromeMat);
        whisker.position.set(wx, bodyCenterY, frontZ + 0.01);
        this.group.add(whisker);
      });
    } else if (modelId === 'delta_integrale') {
      // Rally aggressive black mesh grille with HF badge
      const grille = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, 0.32, 0.08), trimMat);
      grille.position.set(0, bodyCenterY, frontZ + 0.02);
      this.group.add(grille);

      // Hood cooling louvers
      [-0.35, 0.35].forEach((hx) => {
        const vent = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.06, 0.45), trimMat);
        vent.position.set(hx, bodyCenterY + dims.bodyHeight * 0.52, frontZ - 0.55);
        this.group.add(vent);
      });
    } else {
      // Standard robust mesh grille
      const grille = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.8, 0.38, 0.1), trimMat);
      grille.position.set(0, bodyCenterY, frontZ + 0.02);
      this.group.add(grille);
    }
  }

  /**
   * Cabin Greenhouse: Roof, Pillars, Windshield and Windows
   */
  buildCabinGreenhouse(modelId, dims, bodyCenterY, bodyMat, trimMat, glassMat, chromeMat) {
    const cabinY = bodyCenterY + dims.bodyHeight * 0.5 + dims.cabinHeight * 0.5;
    const cabinZ = -dims.length * 0.08;

    // Main roof shell
    const cabinGeo = new THREE.BoxGeometry(dims.width * 0.90, dims.cabinHeight, dims.cabinLength);
    const cabin = new THREE.Mesh(cabinGeo, bodyMat);
    cabin.position.set(0, cabinY, cabinZ);
    cabin.castShadow = true;
    this.group.add(cabin);

    // Front Windshield (sloped)
    const wsZ = cabinZ + dims.cabinLength * 0.5 + 0.04;
    const wsSlope = (modelId === 'mercedes_gwagen' || modelId === 'defender_110') ? -0.15 : -0.38;
    const ws = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.86, dims.cabinHeight * 0.85, 0.08), glassMat);
    ws.position.set(0, cabinY, wsZ);
    ws.rotation.x = wsSlope;
    this.group.add(ws);

    // Side Windows
    [-dims.width * 0.46, dims.width * 0.46].forEach((sx) => {
      const sideGlass = new THREE.Mesh(new THREE.BoxGeometry(0.06, dims.cabinHeight * 0.75, dims.cabinLength * 0.92), glassMat);
      sideGlass.position.set(sx, cabinY, cabinZ);
      this.group.add(sideGlass);

      // Side rearview mirrors
      const mirror = new THREE.Mesh(new THREE.BoxGeometry(0.24, 0.16, 0.1), trimMat);
      mirror.position.set(sx * 1.14, cabinY - 0.1, wsZ);
      this.group.add(mirror);
    });

    // Rear Window
    const rwZ = cabinZ - dims.cabinLength * 0.5 - 0.03;
    const rwSlope = dims.isCoupeFlared ? 0.55 : 0.08; // Audi Quattro fastback slant vs upright wagon
    const rw = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, dims.cabinHeight * 0.75, 0.08), glassMat);
    rw.position.set(0, cabinY, rwZ);
    rw.rotation.x = rwSlope;
    this.group.add(rw);

    // Roof Ribs on Panda 4x4
    if (modelId === 'panda_4x4') {
      [-0.45, -0.15, 0.15, 0.45].forEach((rx) => {
        const rib = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.04, dims.cabinLength * 0.9), trimMat);
        rib.position.set(rx, cabinY + dims.cabinHeight * 0.5 + 0.02, cabinZ);
        this.group.add(rib);
      });
    }

    // Roof Luggage Rails on Wagons (W123, Volvo 245, BMW Touring)
    if (dims.isWagon || dims.isBrickWagon || dims.isSportTouring) {
      [-dims.width * 0.40, dims.width * 0.40].forEach((rx) => {
        const rail = new THREE.Mesh(new THREE.BoxGeometry(0.05, 0.08, dims.cabinLength * 0.95), chromeMat);
        rail.position.set(rx, cabinY + dims.cabinHeight * 0.5 + 0.06, cabinZ);
        this.group.add(rail);
      });
    }
  }

  /**
   * Rear Fascia: Taillights, Bumper, and Model Tailgate
   */
  buildRearFascia(modelId, dims, bodyCenterY, bodyMat, trimMat, chromeMat) {
    const rearZ = -dims.length * 0.5;

    // Rear Bumper
    const bumperMat = (modelId === 'mercedes_w123' || modelId === 'alfa_giulia') ? chromeMat : trimMat;
    const bumperWidth = dims.width * (dims.isRallyWide ? 1.08 : 1.04);
    const rvBumper = new THREE.Mesh(new THREE.BoxGeometry(bumperWidth, 0.32, 0.28), bumperMat);
    rvBumper.position.set(0, dims.groundY + dims.chassisHeight * 0.7, rearZ - 0.14);
    rvBumper.castShadow = true;
    this.group.add(rvBumper);

    // Dual Taillights
    const tailY = bodyCenterY + 0.05;
    [-dims.width * 0.38, dims.width * 0.38].forEach((tx) => {
      const tail = new THREE.Mesh(
        new THREE.BoxGeometry(0.32, 0.18, 0.1),
        new THREE.MeshStandardMaterial({
          color: 0x990000,
          emissive: 0xdd1111,
          emissiveIntensity: 0.6,
          roughness: 0.3
        })
      );
      tail.position.set(tx, tailY, rearZ - 0.02);
      this.group.add(tail);
      this.taillights.push(tail);
    });

    // Rear Exhaust Tip
    const exhaustX = dims.width * 0.34;
    const exhaustY = dims.groundY + dims.chassisHeight * 0.5;
    const exhaustZ = rearZ - 0.22;
    this.exhaustTip.set(exhaustX, exhaustY, exhaustZ);

    const exhaust = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.07, 0.35, 8), trimMat);
    exhaust.rotation.x = Math.PI / 2;
    exhaust.position.set(exhaustX, exhaustY, exhaustZ);
    this.group.add(exhaust);

    // Dual Rally Exhaust for Delta Integrale
    if (modelId === 'delta_integrale') {
      const ex2 = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.07, 0.35, 8), chromeMat);
      ex2.rotation.x = Math.PI / 2;
      ex2.position.set(exhaustX - 0.18, exhaustY, exhaustZ);
      this.group.add(ex2);
    }
  }

  /**
   * Wheels & Suspension Layout based on track and wheelbase
   */
  buildWheels(dims, tireMat, rimMat, chromeMat, trimMat) {
    const halfBase = dims.wheelBase * 0.5;
    const halfTrack = dims.trackWidth * 0.5;
    const wheelY = dims.groundY;

    const wheelPositions = [
      { x: -halfTrack, y: wheelY, z: halfBase, isFront: true },
      { x: halfTrack, y: wheelY, z: halfBase, isFront: true },
      { x: -halfTrack, y: wheelY, z: -halfBase, isFront: false },
      { x: halfTrack, y: wheelY, z: -halfBase, isFront: false }
    ];

    wheelPositions.forEach((wp) => {
      const wheelGroup = new THREE.Group();
      wheelGroup.position.set(wp.x, wp.y, wp.z);

      // Outer Tire
      const tire = new THREE.Mesh(new THREE.CylinderGeometry(dims.wheelRadius, dims.wheelRadius, dims.wheelWidth, 16), tireMat);
      tire.rotation.z = Math.PI / 2;
      tire.castShadow = true;
      wheelGroup.add(tire);

      // Inner Rim
      const rimRadius = dims.wheelRadius * 0.65;
      const rim = new THREE.Mesh(new THREE.CylinderGeometry(rimRadius, rimRadius, dims.wheelWidth + 0.02, 10), rimMat);
      rim.rotation.z = Math.PI / 2;
      wheelGroup.add(rim);

      // Center Hub
      const hub = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.1, dims.wheelWidth + 0.04, 6), chromeMat);
      hub.rotation.z = Math.PI / 2;
      wheelGroup.add(hub);

      // Wheel Arch Flares (Paracolpi / Parafanghi allargati)
      const flareWidth = dims.isRallyWide || dims.isCoupeFlared ? 0.36 : 0.22;
      const flare = new THREE.Mesh(new THREE.BoxGeometry(flareWidth, 0.18, dims.wheelRadius * 2.3), trimMat);
      flare.position.set(wp.x * 0.94, wheelY + dims.wheelRadius * 0.85, wp.z);
      this.group.add(flare);

      this.group.add(wheelGroup);
      this.wheels.push(wheelGroup);
      if (wp.isFront) this.frontWheels.push(wheelGroup);
    });
  }

  /**
   * Headlights & Volumetric Light Cones
   */
  buildLighting(dims, bodyCenterY, chromeMat) {
    const beamTexture = TextureGenerator.createVolumetricBeamTexture();
    const frontZ = dims.length * 0.5 + 0.05;
    const lightY = bodyCenterY + 0.04;
    const lightSpread = dims.width * 0.34;

    [-lightSpread, lightSpread].forEach((hx) => {
      // Light Bezel
      const bezel = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.18, 0.14, 12), chromeMat);
      bezel.rotation.x = Math.PI / 2;
      bezel.position.set(hx, lightY, frontZ);
      this.group.add(bezel);

      // High-Intensity Long-Range SpotLight (Reaching 125m ahead!)
      const spot = new THREE.SpotLight(0xfff6e8, 8.5, 125, Math.PI / 4.0, 0.42, 0.85);
      spot.position.set(hx, lightY, frontZ + 0.05);
      spot.target.position.set(hx * 0.3, 0.1, frontZ + 75);
      spot.castShadow = true;
      spot.shadow.mapSize.width = 1024;
      spot.shadow.mapSize.height = 1024;
      spot.shadow.camera.near = 0.5;
      spot.shadow.camera.far = 125;
      this.group.add(spot);
      this.group.add(spot.target);
      this.headlights.push(spot);

      // Extended Volumetric Light Beam Cone (65m long!)
      const coneGeo = new THREE.ConeGeometry(5.8, 65, 16, 1, true);
      coneGeo.translate(0, -32.5, 0);
      coneGeo.rotateX(-Math.PI / 2);
      const coneMat = new THREE.MeshBasicMaterial({
        map: beamTexture,
        transparent: true,
        opacity: 0.38,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        side: THREE.DoubleSide
      });
      const coneMesh = new THREE.Mesh(coneGeo, coneMat);
      coneMesh.position.set(hx, lightY, frontZ + 0.05);
      this.group.add(coneMesh);
      this.lightCones.push(coneMesh);
    });

    // Broad Forward Road-Washing Fill Light (illuminates asphalt markings and hazards ahead)
    const fillLight = new THREE.SpotLight(0xffeedd, 5.5, 110, Math.PI / 3.0, 0.6, 0.8);
    fillLight.position.set(0, lightY + 0.15, frontZ);
    fillLight.target.position.set(0, 0.1, frontZ + 55);
    this.group.add(fillLight);
    this.group.add(fillLight.target);
    this.headlights.push(fillLight);
  }

  /**
   * Unique Model Accoutrements (Snorkel, Spoilers, Spare Tire on Hatch, Roof Racks)
   */
  buildModelSpecificAccoutrements(modelId, dims, bodyCenterY, bodyMat, trimMat, chromeMat) {
    const rearZ = -dims.length * 0.5;
    const roofY = bodyCenterY + dims.bodyHeight * 0.5 + dims.cabinHeight;

    // 1. Defender 110: Raised Snorkel on Passenger A-Pillar
    if (modelId === 'defender_110') {
      const snorkelPipe = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.05, 1.3, 8), trimMat);
      snorkelPipe.position.set(dims.width * 0.48, bodyCenterY + 0.65, dims.length * 0.22);
      const snorkelTop = new THREE.Mesh(new THREE.BoxGeometry(0.18, 0.14, 0.22), trimMat);
      snorkelTop.position.set(dims.width * 0.48, bodyCenterY + 1.32, dims.length * 0.22);
      this.group.add(snorkelPipe);
      this.group.add(snorkelTop);
    }

    // 2. G-Klasse W460 & Golf Country: External Door-Mounted Spare Wheel
    if (modelId === 'mercedes_gwagen' || modelId === 'golf_country') {
      const spareTire = new THREE.Mesh(
        new THREE.CylinderGeometry(dims.wheelRadius * 0.95, dims.wheelRadius * 0.95, dims.wheelWidth, 14),
        trimMat
      );
      spareTire.rotation.x = Math.PI / 2;
      spareTire.position.set(0.15, bodyCenterY + 0.15, rearZ - dims.wheelWidth * 0.5 - 0.08);
      spareTire.castShadow = true;
      this.group.add(spareTire);
    }

    // 3. G-Klasse W460: Fender-Top Turn Signal Pods
    if (modelId === 'mercedes_gwagen') {
      [-dims.width * 0.44, dims.width * 0.44].forEach((fx) => {
        const pod = new THREE.Mesh(
          new THREE.BoxGeometry(0.12, 0.1, 0.18),
          new THREE.MeshStandardMaterial({ color: 0xf59e0b, emissive: 0xf59e0b, emissiveIntensity: 0.4 })
        );
        pod.position.set(fx, bodyCenterY + dims.bodyHeight * 0.52, dims.length * 0.42);
        this.group.add(pod);
      });
    }

    // 4. Lancia Delta HF Integrale: Adjustable Rear Roof Spoiler
    if (modelId === 'delta_integrale') {
      const spoilerWing = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.88, 0.06, 0.32), trimMat);
      spoilerWing.position.set(0, roofY + 0.15, -dims.length * 0.32);
      spoilerWing.rotation.x = 0.32; // aggressive downforce pitch

      [-dims.width * 0.36, dims.width * 0.36].forEach((sx) => {
        const upright = new THREE.Mesh(new THREE.BoxGeometry(0.04, 0.18, 0.18), trimMat);
        upright.position.set(sx, roofY + 0.07, -dims.length * 0.32);
        this.group.add(upright);
      });
      this.group.add(spoilerWing);
    }

    // 5. Audi Ur-Quattro: Integrated Rear Trunk Spoiler
    if (modelId === 'audi_quattro') {
      const lip = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, 0.08, 0.22), trimMat);
      lip.position.set(0, bodyCenterY + dims.bodyHeight * 0.48, rearZ + 0.15);
      this.group.add(lip);
    }

    // 6. Golf Country & Peugeot 504 Dangel: Front Offroad Tubular Nudge Bar
    if (modelId === 'golf_country' || modelId === 'peugeot_504_dangel') {
      const nudge = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.65, 0.55, 0.12), trimMat);
      nudge.position.set(0, dims.groundY + dims.chassisHeight * 0.85, dims.length * 0.5 + 0.25);
      this.group.add(nudge);
    }

    // 7. Standard Survivor Expedition Cargo (Jerrycans & Pelican Case on Wagons / Offroaders)
    if (dims.isSafari || dims.isBoxy4x4 || dims.isWagon || dims.isBrickWagon) {
      const cargoCase = new THREE.Mesh(
        new THREE.BoxGeometry(0.55, 0.28, 0.45),
        new THREE.MeshStandardMaterial({ color: 0xd97706, roughness: 0.7 })
      );
      cargoCase.position.set(0.35, roofY + 0.16, -dims.length * 0.15);
      this.group.add(cargoCase);

      const redCan = new THREE.Mesh(
        new THREE.BoxGeometry(0.28, 0.38, 0.22),
        new THREE.MeshStandardMaterial({ color: 0xb91c1c, roughness: 0.5, metalness: 0.3 })
      );
      redCan.position.set(-0.35, roofY + 0.20, -dims.length * 0.15);
      this.group.add(redCan);
    }
  }

  /**
   * Modular Upgrades attached to dynamic dimensions
   */
  buildUpgradeModules(dims, bodyCenterY, trimMat) {
    const frontZ = dims.length * 0.5;
    const roofY = bodyCenterY + dims.bodyHeight * 0.5 + dims.cabinHeight;

    // 1. Heavy Bullbar Upgrade
    const bullbarGroup = new THREE.Group();
    const bullbarFrame = new THREE.Mesh(
      new THREE.BoxGeometry(dims.width * 1.05, 0.65, 0.35),
      new THREE.MeshStandardMaterial({ color: 0x111315, roughness: 0.4, metalness: 0.8 })
    );
    bullbarFrame.position.set(0, dims.groundY + dims.chassisHeight * 0.9, frontZ + 0.32);
    bullbarGroup.add(bullbarFrame);

    // Winch
    const winch = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 0.55, 8), trimMat);
    winch.rotation.z = Math.PI / 2;
    winch.position.set(0, dims.groundY + dims.chassisHeight * 0.85, frontZ + 0.42);
    bullbarGroup.add(winch);

    bullbarGroup.visible = !!this.upgrades.bullbar;
    this.group.add(bullbarGroup);
    this.upgradeMeshes.bullbar = bullbarGroup;

    // 2. Roof LED Lightbar Upgrade
    const lightbarGroup = new THREE.Group();
    const barFrame = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.82, 0.12, 0.14), trimMat);
    barFrame.position.set(0, roofY + 0.1, dims.length * 0.18);
    lightbarGroup.add(barFrame);

    for (let lx = -dims.width * 0.35; lx <= dims.width * 0.35; lx += 0.22) {
      const led = new THREE.Mesh(
        new THREE.BoxGeometry(0.12, 0.08, 0.08),
        new THREE.MeshStandardMaterial({ color: 0xffffff, emissive: 0xffffff, emissiveIntensity: 1.5 })
      );
      led.position.set(lx, roofY + 0.1, dims.length * 0.18 + 0.08);
      lightbarGroup.add(led);
    }

    lightbarGroup.visible = !!(this.upgrades.roof_lights || this.upgrades.rally_light_bar);
    this.group.add(lightbarGroup);
    this.upgradeMeshes.roof_lights = lightbarGroup;

    // 3. Roof Expedition Cargo Rack Upgrade
    const rackGroup = new THREE.Group();
    const rackMat = new THREE.MeshStandardMaterial({ color: 0x1f2428, roughness: 0.6, metalness: 0.8 });
    const rackFrame = new THREE.Mesh(new THREE.BoxGeometry(dims.width * 0.78, 0.14, dims.length * 0.45), rackMat);
    rackFrame.position.set(0, roofY + 0.12, -dims.length * 0.12);
    rackGroup.add(rackFrame);

    const case1 = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.22, 0.4), new THREE.MeshStandardMaterial({ color: 0xb45309, roughness: 0.7 }));
    case1.position.set(-0.18, roofY + 0.22, -dims.length * 0.12);
    rackGroup.add(case1);

    const spareCan = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.35, 0.22), new THREE.MeshStandardMaterial({ color: 0x15803d, roughness: 0.6 }));
    spareCan.position.set(0.22, roofY + 0.24, -dims.length * 0.12);
    rackGroup.add(spareCan);

    rackGroup.visible = !!(this.upgrades.roof_cargo_rack);
    this.group.add(rackGroup);
    this.upgradeMeshes.roof_cargo_rack = rackGroup;
  }

  applyUpgrade(upgradeId) {
    this.upgrades[upgradeId] = true;

    // Bullbar
    if ((upgradeId === 'heavy_bullbar' || upgradeId === 'bullbar') && this.upgradeMeshes.bullbar) {
      this.upgradeMeshes.bullbar.visible = true;
      this.upgrades.heavy_bullbar = true;
      this.upgrades.bullbar = true;
    }

    // Roof Lightbar
    if ((upgradeId === 'rally_light_bar' || upgradeId === 'roof_lights') && this.upgradeMeshes.roof_lights) {
      this.upgradeMeshes.roof_lights.visible = true;
      this.upgrades.rally_light_bar = true;
      this.upgrades.roof_lights = true;
      this.headlights.forEach((h) => {
        h.intensity = 5.8;
        h.distance = 70;
        h.angle = Math.PI / 3.8;
      });
      this.lightCones.forEach((cone) => {
        cone.scale.set(1.5, 1.5, 1.5);
        cone.material.opacity = 0.45;
      });
    }

    // Roof Cargo Rack
    if (upgradeId === 'roof_cargo_rack' && this.upgradeMeshes.roof_cargo_rack) {
      this.upgradeMeshes.roof_cargo_rack.visible = true;
    }

    // Aux Fuel Tank
    if (upgradeId === 'aux_fuel_cell' || upgradeId === 'aux_tank') {
      this.upgrades.aux_fuel_cell = true;
      this.upgrades.aux_tank = true;
      this.maxFuel = this.modelConfig.fuelTankL + 40;
      this.fuel = Math.min(this.fuel + 40, this.maxFuel);
    }

    // Turbo Boost Kit
    if (upgradeId === 'turbo_boost_kit') {
      if (this.modelConfig.hasTurbo) {
        this.modelConfig.turboBoostMaxBar = (this.modelConfig.turboBoostMaxBar || 1.0) + 0.35;
      }
    }

    // Aliases
    if (upgradeId === 'copper_radiator' || upgradeId === 'turbo_cooler') {
      this.upgrades.copper_radiator = true;
      this.upgrades.turbo_cooler = true;
    }
    if (upgradeId === 'studded_tires' || upgradeId === 'offroad_tires') {
      this.upgrades.studded_tires = true;
      this.upgrades.offroad_tires = true;
    }
    if (upgradeId === 'skid_plate' || upgradeId === 'armored_hull') {
      this.upgrades.skid_plate = true;
      this.upgrades.armored_hull = true;
    }
  }

  toggleLights() {
    this.isLightsOn = !this.isLightsOn;
    this.headlights.forEach((light) => {
      const isFill = light.angle > Math.PI / 3.5;
      if (isFill) {
        light.intensity = this.isLightsOn ? 5.5 : 0;
      } else {
        light.intensity = this.isLightsOn ? (this.upgrades.roof_lights ? 14.5 : 8.5) : 0;
      }
    });
    this.lightCones.forEach((cone) => {
      cone.visible = this.isLightsOn;
    });
    this.audioEngine.playSwitchClick(this.isLightsOn);
  }

  honkHorn() {
    if (this.audioEngine && this.audioEngine.playHorn) {
      this.audioEngine.playHorn(this.modelId);
    }
    this.impactShockPitch = 0.025;
  }

  toggle4WD() {
    this.is4WDEngaged = !this.is4WDEngaged;
    if (this.audioEngine && this.audioEngine.play4WDEngage) {
      this.audioEngine.play4WDEngage(this.is4WDEngaged);
    }
  }

  togglePrimina() {
    if (this.modelId !== 'panda_4x4') return;
    this.priminaCrawlerActive = !this.priminaCrawlerActive;
    if (this.audioEngine && this.audioEngine.playSwitchClick) {
      this.audioEngine.playSwitchClick(this.priminaCrawlerActive);
    }
  }

  getExhaustPosition() {
    const worldPos = this.exhaustTip.clone();
    worldPos.applyEuler(this.rotation);
    worldPos.add(this.position);
    return worldPos;
  }

  getRearWheelPositions() {
    const dims = this.modelDims || { width: 1.65, length: 3.8 };
    const halfTrack = dims.width * 0.44;
    const rearZ = -dims.length * 0.36;
    const cosY = Math.cos(this.rotation.y);
    const sinY = Math.sin(this.rotation.y);

    const left = new THREE.Vector3(
      this.position.x - halfTrack * cosY + rearZ * sinY,
      this.position.y + 0.1,
      this.position.z + halfTrack * sinY + rearZ * cosY
    );
    const right = new THREE.Vector3(
      this.position.x + halfTrack * cosY + rearZ * sinY,
      this.position.y + 0.1,
      this.position.z - halfTrack * sinY + rearZ * cosY
    );
    return { left, right };
  }

  /**
   * Main Physics, Powertrain, Turbo, and Handling Simulation Loop
   */
  update(delta, input, roadInfo, renderer = null, weatherImpact = null) {
    const cfg = this.modelConfig;

    if (!this.isEngineOn) {
      if (input.throttle > 0 && this.fuel > 0) {
        this.isEngineOn = true;
        if (this.audioEngine && this.audioEngine.startEngine) {
          this.audioEngine.startEngine();
        }
      } else {
        if (this.forwardSpeed > 0) {
          this.forwardSpeed = Math.max(0, this.forwardSpeed - delta * 12.0);
        } else if (this.forwardSpeed < 0) {
          this.forwardSpeed = Math.min(0, this.forwardSpeed + delta * 12.0);
        }
        if (Math.abs(this.forwardSpeed) < 0.05) this.forwardSpeed = 0.0;
        this.speedKmh = Math.round(this.forwardSpeed * 3.6);
        this.rpm = Math.max(0, this.rpm - delta * 2.0);
        this.boostBar = Math.max(0, this.boostBar - delta * 3.0);
        this.steerAngle = THREE.MathUtils.lerp(this.steerAngle, 0, delta * 8.0);
        this.currentRoll = THREE.MathUtils.lerp(this.currentRoll, 0, delta * 12.0);
        this.currentPitch = THREE.MathUtils.lerp(this.currentPitch, 0, delta * 12.0);
        this.actualTurnRate = 0.0;
        this.audioEngine.setEngineRPM(0, false);
        this.updateMeshTransforms(delta);
        return;
      }
    }

    // ==========================================
    // 1. PHYSICAL CONSTANTS & MASS GEOMETRY
    // ==========================================
    const mass = cfg.weightKg || 1200;
    const g = 9.81;
    const totalWeight = mass * g;
    const wheelbase = (this.modelDims ? this.modelDims.length : 3.8) * 0.62; // Wheelbase L = a + b (~2.3 to 2.8m)
    const weightDistFront = 0.52; // 52% front, 48% rear static balance
    const distA = wheelbase * (1.0 - weightDistFront); // distance CG -> front axle
    const distB = wheelbase * weightDistFront;       // distance CG -> rear axle
    const cgHeight = 0.52; // Center of Gravity height in meters
    const yawInertia = mass * (distA * distB * 1.15); // Mass moment of inertia Iz

    // ==========================================
    // INTELLIGENT OFF-ROAD & WEATHER SURFACE FRICTION
    // ==========================================
    const weatherFriction = (weatherImpact && weatherImpact.frictionMultiplier !== undefined) ? weatherImpact.frictionMultiplier : 1.0;
    const baseSurfaceFriction = (roadInfo.surface ? roadInfo.surface.friction : 1.0) * weatherFriction;
    const roadHalfW = (roadInfo.width || 24.0) * 0.5;
    const pavedHalfW = roadHalfW * 0.78;
    const distFromCenter = this.position.x - roadInfo.x;
    const absDist = Math.abs(distFromCenter);

    const isRuggedOffroader = (
      cfg.id === 'panda_4x4' ||
      cfg.id === 'defender_110' ||
      cfg.id === 'mercedes_gwagen' ||
      cfg.id === 'peugeot_504_dangel' ||
      cfg.id === 'golf_country' ||
      cfg.drivetrain === '4WD_LOCK' ||
      this.upgrades.rally_suspension ||
      this.upgrades.offroad_tires
    );

    let rollCoeff = 0.015;
    let surfaceGripMult = 1.0;
    const currentSpeedKmh = Math.abs(this.forwardSpeed * 3.6);

    if (absDist <= pavedHalfW) {
      // Zone 1: Paved Carriageway
      this.terrainZone = 'PAVED';
      this.terrainStatusText = 'ASFALTO (CARREGGIATA)';
      this.terrainStatusColor = '#22c55e';
      rollCoeff = 0.015;
      surfaceGripMult = 1.0;
      this.chassisScrapeTimer = 0.0;
    } else if (absDist <= roadHalfW) {
      // Zone 2: Gravel Shoulder - "Non deve essere un problema"
      this.terrainZone = 'SHOULDER';
      this.terrainStatusText = 'BANCHINA GHIAIA [ OK ]';
      this.terrainStatusColor = '#38bdf8';
      const shoulderDamp = this.upgrades.rally_suspension ? 0.55 : 1.0;
      rollCoeff = 0.015 + 0.022 * shoulderDamp;
      surfaceGripMult = 0.88;
      this.chassisScrapeTimer = 0.0;
    } else {
      // Zone 3: Off-road Wilderness / Roadside Ditch
      // "A volte deve essere un problema a volte no"
      if (isRuggedOffroader) {
        // Rugged 4x4 or Off-Road Package: NOT A PROBLEM!
        this.terrainZone = 'OFFROAD_SAFE';
        this.terrainStatusText = 'TERRENO NATURALE [ 4x4 ATTIVA ✓ ]';
        this.terrainStatusColor = '#10b981';
        rollCoeff = 0.038;
        surfaceGripMult = 0.78;
        this.chassisScrapeTimer = 0.0;
      } else {
        // Low Street Car (Alfa Giulia, BMW E30, Mercedes W123, Volvo 245):
        if (currentSpeedKmh <= 35.0) {
          // Crawling slow: NOT A PROBLEM!
          this.terrainZone = 'OFFROAD_CRAWL';
          this.terrainStatusText = 'FUORISTRADA [ CRAWL LENTO OK ]';
          this.terrainStatusColor = '#f59e0b';
          rollCoeff = 0.052;
          surfaceGripMult = 0.68;
          this.chassisScrapeTimer = 0.0;
        } else {
          // Fast off-road in low street car: IT IS A PROBLEM!
          this.terrainZone = 'OFFROAD_HAZARD';
          this.terrainStatusText = '⚠️ FUORISTRADA: RISCHIO FONDO!';
          this.terrainStatusColor = '#ef4444';
          rollCoeff = 0.11;
          surfaceGripMult = 0.52;

          this.chassisScrapeTimer += delta;
          if (this.chassisScrapeTimer >= 1.2) {
            this.chassisScrapeTimer = 0.0;
            if (!this.upgrades.skid_plate && !this.upgrades.armored_hull) {
              this.hull = Math.max(0, this.hull - 2);
              this.impactShockPitch = 0.06 * (Math.random() - 0.5);
              this.impactShockRoll = 0.06 * (Math.random() - 0.5);
              if (this.audioEngine && this.audioEngine.playChassisScrape) {
                this.audioEngine.playChassisScrape();
              }
            }
          }
        }
      }
    }

    let tireGrip = (cfg.tractionBonus || 1.0) * surfaceGripMult;
    if (this.upgrades.studded_tires || this.upgrades.offroad_tires) {
      tireGrip *= (baseSurfaceFriction < 0.7 ? 1.35 : 1.15);
    }
    if (this.upgrades.diff_lock_lsd) {
      tireGrip *= 1.12;
    }
    const mu = baseSurfaceFriction * tireGrip;
    this.currentRollCoeff = rollCoeff;

    // ==========================================
    // 2. POWERTRAIN, THROTTLE & BRAKE FORCES
    // ==========================================
    const isThrottle = input.throttle > 0 && this.fuel > 0;
    this.isBraking = input.brake > 0;

    // Progressive Turbo Spool & Liftoff Sound FX
    const liftoff = this.wasThrottling && !isThrottle;
    if (liftoff) {
      if (cfg.hasTurbo && this.boostBar > 0.28) {
        this.audioEngine.playTurboBlowOff(this.boostBar);
      } else if (this.rpm > 0.62 && Math.random() < 0.65) {
        this.audioEngine.playBackfire(Math.min(1.0, this.rpm));
        if (renderer) renderer.emitBackfire(this.getExhaustPosition());
      }
    }
    this.wasThrottling = isThrottle;

    if (cfg.hasTurbo) {
      if (isThrottle) {
        this.boostBar = THREE.MathUtils.lerp(this.boostBar, cfg.turboBoostMaxBar, delta * 2.2);
      } else {
        this.boostBar = Math.max(0, this.boostBar - delta * 4.2);
      }
    } else {
      this.boostBar = 0.0;
    }

    // Engine Drive Force F_drive
    let F_drive = 0.0;
    let F_brake = 0.0;
    const maxSpeedMs = cfg.topSpeedKmh / 3.6;
    const speedAbs = Math.abs(this.forwardSpeed);

    // ==========================================
    // REVERSE TRANSMISSION INTERLOCK (PAOLO'S RULES)
    // 1. Car must come to a stop before reverse can be engaged.
    // 2. Must remain stopped for at least 1.0 second.
    // 3. To engage reverse, player must re-press the reverse/brake key (distinct press).
    // 4. Holding brake while stopping will NEVER engage reverse; keeps car stationary!
    // ==========================================
    const isStationary = speedAbs <= 0.15;

    if (this.gearState === 'DRIVE') {
      if (isStationary) {
        this.standstillTimer += delta;
        // Arm reverse after 1.0s standstill once brake is released or if stationary >= 1.0s
        if (!this.isBraking && this.standstillTimer >= 1.0) {
          this.reverseArmed = true;
        }
        // If 1 second standstill has elapsed and player presses brake again:
        if (this.isBraking && !this.wasBraking && (this.standstillTimer >= 1.0 || this.reverseArmed)) {
          this.gearState = 'REVERSE';
          this.standstillTimer = 0.0;
          this.reverseArmed = false;
          if (this.audioEngine && this.audioEngine.playSwitchClick) {
            this.audioEngine.playSwitchClick(true);
          }
        }
      } else {
        this.standstillTimer = 0.0;
        this.reverseArmed = false;
      }

      // DRIVE GEAR POWERTRAIN
      if (isThrottle) {
        const hpPerTon = cfg.powerHp / (mass / 1000.0);
        const baseAccel = (hpPerTon / 100.0) * 2.6;
        const aeroDrag = Math.max(0.20, 1.0 - Math.pow(speedAbs / Math.max(1.0, maxSpeedMs * 1.05), 1.6) * 0.75);
        const boostMult = this.upgrades.turbo_boost_kit ? 0.55 : 0.35;
        const turboBoost = cfg.hasTurbo ? (1.0 + (this.boostBar / Math.max(0.1, cfg.turboBoostMaxBar)) * boostMult) : 1.0;
        const accelTarget = baseAccel * aeroDrag * input.throttle * turboBoost;
        F_drive = accelTarget * mass;

        const baseFuelRate = cfg.fuelConsumptionRate || 0.032;
        const fuelBurn = baseFuelRate * delta * input.throttle * (1.0 + speedAbs / 35.0);
        this.fuel = Math.max(0, this.fuel - fuelBurn);
        const heatRate = (this.upgrades.copper_radiator || this.upgrades.turbo_cooler) ? 0.022 : 0.065;
        this.engineTemp = Math.min(130, this.engineTemp + heatRate * input.throttle * delta * 12.0);

        if (renderer) renderer.emitExhaust(this.getExhaustPosition(), true);
      } else {
        this.engineTemp = Math.max(70, this.engineTemp - delta * 0.05 * 15.0);
        if (renderer && Math.random() < 0.18) renderer.emitExhaust(this.getExhaustPosition(), false);
      }

      // DRIVE BRAKING: brings car to stop and locks it at 0 (NEVER reverses while in DRIVE)
      if (this.isBraking) {
        if (this.forwardSpeed > 0.25) {
          const brakeDecel = (cfg.handling.brakeForce || 28.0) * 0.28 * input.brake;
          F_brake = brakeDecel * mass;
          if (this.forwardSpeed > 16.0 && Math.random() < 0.12) {
            this.audioEngine.playTireScreech();
          }
        } else {
          this.forwardSpeed = 0.0;
          F_brake = 14.0 * mass;
        }
      }
    } else if (this.gearState === 'REVERSE') {
      // REVERSE GEAR POWERTRAIN
      // Brake pedal acts as reverse throttle!
      if (this.isBraking) {
        const revMax = 22.0 / 3.6; // ~22 km/h
        this.forwardSpeed = Math.max(-revMax, this.forwardSpeed - 4.8 * delta * input.brake);
        if (renderer) renderer.emitExhaust(this.getExhaustPosition(), true);
      } else if (!isThrottle) {
        // Coasting reverse decelerates back to 0
        if (this.forwardSpeed < 0) {
          this.forwardSpeed = Math.min(0, this.forwardSpeed + 8.0 * delta);
        }
      }

      // Throttle (W) acts as brake in reverse and shifts back to DRIVE!
      if (isThrottle) {
        if (this.forwardSpeed < -0.2) {
          this.forwardSpeed = Math.min(0, this.forwardSpeed + 14.0 * delta * input.throttle);
        } else {
          this.gearState = 'DRIVE';
          this.forwardSpeed = 0.0;
          this.standstillTimer = 0.0;
          this.reverseArmed = false;
          if (this.audioEngine && this.audioEngine.playSwitchClick) {
            this.audioEngine.playSwitchClick(false);
          }
        }
      }
    }

    // Emergency Handbrake
    if (input.handbrake && speedAbs > 0.1) {
      F_brake += 22.0 * mass;
      this.audioEngine.playTireScreech();
    }

    // Anti-Wedge Unstuck Breakaway Assist
    if (speedAbs < 1.6) {
      if (isThrottle && this.gearState === 'DRIVE') F_drive += 4.5 * mass;
      else if (this.isBraking && this.gearState === 'REVERSE') this.forwardSpeed -= 2.0 * delta;
    }

    // Rolling Resistance
    const F_rolling = (this.currentRollCoeff || 0.015) * totalWeight * Math.sign(this.forwardSpeed || 1);

    // ==========================================
    // 3. LONGITUDINAL WEIGHT TRANSFER & WHEEL LOADS
    // ==========================================
    const F_net_long = F_drive - (this.forwardSpeed >= 0 ? F_brake : -F_brake) - F_rolling;
    const accel_x = F_net_long / mass;

    // Weight transfer delta: Delta Fz = m * ax * (h / L)
    const weightTransfer = THREE.MathUtils.clamp(mass * accel_x * (cgHeight / wheelbase), -totalWeight * 0.38, totalWeight * 0.38);
    this.weightTransferLong = weightTransfer;

    // Dynamic vertical load per axle:
    // Braking (accel_x < 0, weightTransfer < 0): Front axle loads up, rear axle lightens!
    // Accelerating (accel_x > 0, weightTransfer > 0): Rear axle squats, front axle lightens!
    const Fz_front = Math.max(totalWeight * 0.18, totalWeight * weightDistFront - weightTransfer);
    const Fz_rear = Math.max(totalWeight * 0.18, totalWeight * (1.0 - weightDistFront) + weightTransfer);

    // Friction capacity per axle (Kamm circle limits)
    const F_cap_front = mu * Fz_front;
    const F_cap_rear = mu * Fz_rear;

    // Longitudinal forces per axle based on Drivetrain layout
    let Fx_front = 0.0;
    let Fx_rear = 0.0;

    if (F_drive > 0) {
      // Model-specific powertrain physics overrides
      if (this.modelId === 'panda_4x4') {
        const isCrawler = this.priminaCrawlerActive || (speedKmh < 24.0 && (input.throttle > 0.45 || absDist > pavedHalfW));
        if (isCrawler) {
          F_drive *= 1.85; // Primina Crawler massive mechanical reduction ratio
        }
        if (this.is4WDEngaged) {
          Fx_front = F_drive * 0.50;
          Fx_rear = F_drive * 0.50;
        } else {
          Fx_front = F_drive * 1.0;
          Fx_rear = 0.0;
        }
      } else if (cfg.id === 'delta_integrale' || cfg.id === 'audi_quattro') {
        // Rally Turbo boost surge at medium-high RPM
        const turboSurge = (this.rpm > 0.40 && isThrottle) ? (1.0 + (this.boostBar || 0.5) * 0.42) : 1.0;
        F_drive *= turboSurge;
        Fx_front = F_drive * 0.47;
        Fx_rear = F_drive * 0.53;
      } else if (cfg.id === 'defender_110') {
        // High torque diesel 200Tdi in low gears
        const lowEndGrunt = (speedKmh < 35.0 && isThrottle) ? 1.45 : 1.0;
        F_drive *= lowEndGrunt;
        Fx_front = F_drive * 0.50;
        Fx_rear = F_drive * 0.50;
      } else if (cfg.drivetrain === 'RWD') {
        Fx_rear = F_drive;
        Fx_front = 0.0;
      } else if (cfg.drivetrain === 'FWD') {
        Fx_front = F_drive;
        Fx_rear = 0.0;
      } else if (cfg.drivetrain === 'AWD_TORSEN') {
        Fx_front = F_drive * 0.47;
        Fx_rear = F_drive * 0.53;
      } else if (cfg.drivetrain === 'AWD_VISCOUS') {
        Fx_front = F_drive * 0.37;
        Fx_rear = F_drive * 0.63;
      } else {
        Fx_front = F_drive * 0.50;
        Fx_rear = F_drive * 0.50;
      }
    } else if (F_brake > 0) {
      // Natural front-biased brake distribution (68% front, 32% rear)
      Fx_front = -F_brake * 0.68;
      Fx_rear = -F_brake * 0.32;
    }

    // ==========================================
    // 4. NON-LINEAR STEERING & TIRE SLIP ANGLES
    // ==========================================
    const rawSteerTarget = -input.steer;
    let slewRate = 4.2;
    if (Math.abs(rawSteerTarget) < 0.01) slewRate = 8.5;
    else if (Math.sign(rawSteerTarget) !== Math.sign(this.filteredSteer) && Math.abs(this.filteredSteer) > 0.08) slewRate = 6.8;
    this.filteredSteer = THREE.MathUtils.damp(this.filteredSteer, rawSteerTarget, slewRate, delta);

    const absFiltered = Math.abs(this.filteredSteer);
    let shapedSteer = 0.0;
    if (absFiltered > 0.015) {
      const nonLin = 0.20 * absFiltered + 0.80 * Math.pow(absFiltered, 2.4);
      shapedSteer = Math.sign(this.filteredSteer) * Math.min(1.0, nonLin);
    }
    const flatTireBias = (this.hasFlatTire && speedAbs > 1.2) ? 0.035 : 0.0;
    const steerCmd = Math.max(-1.0, Math.min(1.0, shapedSteer + flatTireBias));

    const speedKmh = speedAbs * 3.6;
    const speedFactor = 1.0 / (1.0 + Math.pow(speedKmh / 38.0, 1.35));
    const modelAgility = cfg.handling.agility || 1.0;
    const maxSteerAngleRad = THREE.MathUtils.lerp(0.12, 0.44, speedFactor) * modelAgility;
    // POSITIVE steerCmd (D / Right) produces POSITIVE steerAngle (turns right towards +X)
    this.steerAngle = steerCmd * maxSteerAngleRad;

    // Kinematic Ackermann geometry for low-speed maneuvering and parking (avoids / u singularities)
    const tanSteer = Math.tan(this.steerAngle);
    const r_kin = (this.forwardSpeed / Math.max(0.1, wheelbase)) * tanSteer;
    const v_kin = this.forwardSpeed * (distB / Math.max(0.1, wheelbase)) * tanSteer;

    // Dynamic slip angles of front and rear tires
    // alpha_f = delta - atan2(v + a*r, |u|)
    // alpha_r = -atan2(v - b*r, |u|)
    const regSpeed = Math.max(1.5, speedAbs);
    const alpha_f = this.steerAngle - Math.atan2(this.lateralSpeed + distA * this.yawRate, regSpeed);
    const alpha_r = -Math.atan2(this.lateralSpeed - distB * this.yawRate, regSpeed);
    this.slipAngle = Math.atan2(this.lateralSpeed, regSpeed);

    // ==========================================
    // 5. KAMM FRICTION CIRCLE & LATERAL TIRE FORCES
    // ==========================================
    Fx_front = THREE.MathUtils.clamp(Fx_front, -F_cap_front, F_cap_front);
    Fx_rear = THREE.MathUtils.clamp(Fx_rear, -F_cap_rear, F_cap_rear);

    // Remaining lateral grip in Kamm's friction circle:
    // Fy_max = sqrt(max(0.04 * F_cap^2, F_cap^2 - Fx^2))
    // PHYSICAL COUPLING:
    // - RWD on throttle: Fx_rear -> F_cap_rear => Fy_max_rear collapses => POWER OVERSTEER!
    // - Hard braking: Fx_front -> F_cap_front => Fy_max_front collapses => BRAKE LOCKUP UNDERSTEER!
    // - Trail-braking: Front loaded, rear lightened => rear rotates smoothly around front apex!
    const Fy_max_front = Math.sqrt(Math.max(0.04 * F_cap_front * F_cap_front, F_cap_front * F_cap_front - Fx_front * Fx_front));
    const Fy_max_rear = Math.sqrt(Math.max(0.04 * F_cap_rear * F_cap_rear, F_cap_rear * F_cap_rear - Fx_rear * Fx_rear));

    // Cornering stiffness (scaled with dynamic vertical axle loads)
    const C_alpha_front = 24.0 * Fz_front;
    const C_alpha_rear = 26.0 * Fz_rear;

    const Fy_f_raw = C_alpha_front * alpha_f;
    const Fy_r_raw = C_alpha_rear * alpha_r;

    const Fy_front = THREE.MathUtils.clamp(Fy_f_raw, -Fy_max_front, Fy_max_front);
    const Fy_rear = THREE.MathUtils.clamp(Fy_r_raw, -Fy_max_rear, Fy_max_rear);

    // ==========================================
    // 6. 2-DOF EQUATIONS OF MOTION (LATERAL, LONGITUDINAL & YAW)
    // ==========================================
    const cosDelta = Math.cos(this.steerAngle);
    const sinDelta = Math.sin(this.steerAngle);
    const Fy_total = Fy_front * cosDelta + Fy_rear + Fx_front * sinDelta;

    // Net yaw moment Mz = a * (Fy_front*cosDelta + Fx_front*sinDelta) - b * Fy_rear
    let Mz_total = distA * (Fy_front * cosDelta + Fx_front * sinDelta) - distB * Fy_rear;

    // Oversteer / Understeer tendency tuning per car model
    const oversteerBias = (cfg.handling.oversteerTendency || 0.0);
    Mz_total += oversteerBias * Math.sign(this.steerAngle || this.yawRate) * Math.abs(Fx_rear) * 0.18;

    // Accelerations in vehicle body frame:
    // dv/dt = (Fy_total / m) - u * r
    // dr/dt = Mz_total / Iz
    const dv_dt = (Fy_total / mass) - this.forwardSpeed * this.yawRate;
    const dr_dt = Mz_total / yawInertia;

    const v_dyn = THREE.MathUtils.clamp(this.lateralSpeed + dv_dt * delta, -12.0, 12.0);
    const r_dyn = this.yawRate + dr_dt * delta;

    // Smooth blending between low-speed Kinematic Ackermann and high-speed Dynamic 2-DOF
    const blendDyn = THREE.MathUtils.clamp((speedAbs - 0.4) / 1.8, 0.0, 1.0);
    this.yawRate = THREE.MathUtils.lerp(r_kin, r_dyn, blendDyn);
    this.lateralSpeed = THREE.MathUtils.lerp(v_kin, v_dyn, blendDyn);

    const maxRotSpeed = THREE.MathUtils.lerp(1.65, 0.72, Math.min(1.0, speedKmh / 120.0));
    this.yawRate = THREE.MathUtils.clamp(this.yawRate, -maxRotSpeed, maxRotSpeed);
    this.actualTurnRate = this.yawRate;

    // Natural caster self-centering torque: returns rack to straight-ahead when hands off
    if (Math.abs(rawSteerTarget) < 0.02) {
      this.yawRate *= Math.max(0.65, 1.0 - delta * 4.0);
      this.lateralSpeed *= Math.max(0.65, 1.0 - delta * 4.5);
    }

    // Longitudinal acceleration update (ALWAYS integrated across all speed regimes)
    const du_dt = (Fx_front * cosDelta + Fx_rear - Fy_front * sinDelta - F_rolling) / mass + this.lateralSpeed * this.yawRate;
    this.forwardSpeed += du_dt * delta;

    // Standstill static friction deadband: if stopped and no input, lock to 0
    if (speedAbs < 0.08 && !isThrottle && !this.isBraking && !input.handbrake) {
      this.forwardSpeed = 0.0;
      this.lateralSpeed = 0.0;
      this.yawRate = 0.0;
      this.actualTurnRate = 0.0;
      this.oversteerSlip = 0.0;
    }

    this.forwardSpeed = THREE.MathUtils.clamp(this.forwardSpeed, -maxSpeedMs * 0.22, maxSpeedMs);
    this.speedKmh = Math.round(this.forwardSpeed * 3.6);

    this.oversteerSlip = Math.abs(this.slipAngle);
    if (this.oversteerSlip > 0.18 && speedAbs > 6.0) {
      if (Math.random() < 0.25) this.audioEngine.playTireScreech();
    }

    // ==========================================
    // 7. TRUE PHYSICAL WORLD TRAJECTORY INTEGRATION
    // ==========================================
    // Update heading angle: psi += yawRate * delta
    this.rotation.y += this.yawRate * delta;

    // Transform vehicle local velocities (u, v) into global world velocities (Vx, Vz)
    // Vx = u * sin(psi) + v * cos(psi)
    // Vz = u * cos(psi) - v * sin(psi)
    const sinPsi = Math.sin(this.rotation.y);
    const cosPsi = Math.cos(this.rotation.y);

    const worldVx = this.forwardSpeed * sinPsi + this.lateralSpeed * cosPsi;
    const worldVz = this.forwardSpeed * cosPsi - this.lateralSpeed * sinPsi;

    this.position.x += worldVx * delta;
    this.position.z += worldVz * delta;

    // Natural terrain boundary banking at outer wilderness (> 30m from highway centerline)
    const maxWilderness = roadHalfW + 30.0;
    if (absDist > maxWilderness) {
      const excess = absDist - maxWilderness;
      const pushDir = Math.sign(roadInfo.x - this.position.x);
      this.position.x += pushDir * excess * delta * 5.0;
      this.yawRate += pushDir * 0.45 * delta;
    }

    this.position.y = roadInfo.y;

    // 7. Engine Audio Telemetry & Environmental Road Sound
    const rpmFraction = Math.min(1.0, 0.15 + (Math.abs(this.speedKmh) / cfg.topSpeedKmh) * 0.85);
    this.rpm = rpmFraction;
    this.engineRpmActual = Math.round(cfg.idleRpm + rpmFraction * (cfg.redlineRpm - cfg.idleRpm));

    this.audioEngine.setEngineRPM(this.rpm, isThrottle, this.boostBar, this.gear, speedAbs);
    this.audioEngine.setSpeedWind(Math.abs(this.forwardSpeed) / maxSpeedMs);

    // Surface acoustics & dynamic brake squeal
    const isNowOnShoulder = Math.abs(this.position.x - roadInfo.x) > pavedHalfW;
    this.audioEngine.setSurface(roadInfo.surface, speedAbs / maxSpeedMs, isNowOnShoulder);
    this.audioEngine.setBrakeSound(this.isBraking, speedAbs / maxSpeedMs);

    // Dynamic Tire Spray & Gravel Dust
    if (renderer && speedAbs > 2.0) {
      const wheels = this.getRearWheelPositions();
      renderer.emitTireSpray(wheels.left, wheels.right, roadInfo.surface, speedAbs / maxSpeedMs, isNowOnShoulder);
    }

    // 8. Visual transforms, roll & pitch
    this.updateMeshTransforms(delta);

    // 9. Brake lights intensity
    this.taillights.forEach((t) => {
      t.material.emissiveIntensity = this.isBraking ? 2.8 : 0.6;
    });

    // 10. Out of fuel check
    if (this.fuel <= 0 && this.isEngineOn) {
      this.isEngineOn = false;
      this.audioEngine.stopEngine();
    }

    // Record previous brake input for reverse double-tap detection
    this.wasBraking = this.isBraking;
  }

  updateMeshTransforms(delta) {
    this.group.position.copy(this.position);
    this.group.rotation.y = this.rotation.y;

    const speedAbs = Math.abs(this.forwardSpeed);

    if (speedAbs < 0.15) {
      // WHEN STATIONARY: Roll and pitch are STRICTLY ZERO!
      // The car CANNOT roll over, flip or tilt when standing still!
      this.currentRoll = THREE.MathUtils.lerp(this.currentRoll, 0.0, delta * 14.0);
      this.currentPitch = THREE.MathUtils.lerp(this.currentPitch, 0.0, delta * 14.0);
      this.group.rotation.z = 0.0;
      this.group.rotation.x = 0.0;
    } else {
      // 1. Suspension Roll: Strictly a function of actual centrifugal lateral acceleration + impact shock
      // Outward roll: turning right (+latAccel) lifts right side and compresses left side (+roll)
      const latAccel = this.forwardSpeed * this.yawRate; // a_lat in m/s^2
      const rollFactor = this.modelConfig.handling.bodyRollFactor || 0.25;
      // Maximum lean angle clamped realistically to +- 0.065 rad (~3.7 degrees)
      const maxRoll = 0.065;
      const targetRoll = Math.max(-maxRoll, Math.min(maxRoll, (latAccel / 9.81) * rollFactor * 0.32));
      this.currentRoll = THREE.MathUtils.lerp(this.currentRoll, targetRoll, delta * 10.0);
      this.group.rotation.z = this.currentRoll + this.impactShockRoll;

      // 2. Pitch: Function of longitudinal acceleration (dv/dt) + impact shock dive
      const currentAccel = (this.forwardSpeed - this.lastSpeed) / Math.max(0.001, delta);
      this.lastSpeed = this.forwardSpeed;
      const maxPitch = 0.04; // ~2.3 degrees max dive/squat
      const targetPitch = Math.max(-maxPitch, Math.min(maxPitch, -(currentAccel / 9.81) * 0.04));
      this.currentPitch = THREE.MathUtils.lerp(this.currentPitch, targetPitch, delta * 8.0);
      this.group.rotation.x = this.currentPitch + this.impactShockPitch;
    }

    // Damped decay of impact shocks
    if (Math.abs(this.impactShockPitch) > 0.001) {
      this.impactShockPitch = THREE.MathUtils.lerp(this.impactShockPitch, 0.0, delta * 10.0);
    } else {
      this.impactShockPitch = 0.0;
    }
    if (Math.abs(this.impactShockRoll) > 0.001) {
      this.impactShockRoll = THREE.MathUtils.lerp(this.impactShockRoll, 0.0, delta * 10.0);
    } else {
      this.impactShockRoll = 0.0;
    }

    // Front wheel visual steering angle (realistic wheel turn)
    this.frontWheels.forEach((w) => {
      w.rotation.y = this.steerAngle;
    });

    // Wheel spin (only when car is moving)
    if (speedAbs > 0.05) {
      const wheelR = this.modelDims ? this.modelDims.wheelRadius : 0.42;
      const spinDelta = (this.forwardSpeed / wheelR) * delta;
      this.wheels.forEach((w) => {
        if (w.children.length > 0) w.children[0].rotation.x += spinDelta;
        if (w.children.length > 1) w.children[1].rotation.x += spinDelta;
      });
    }

    // Antenna whip sway
    if (this.antenna) {
      if (speedAbs < 0.15) {
        this.antenna.rotation.z = Math.sin(Date.now() * 0.003) * 0.02;
        this.antenna.rotation.x = 0;
      } else {
        this.antenna.rotation.z = this.steerAngle * 0.2 + Math.sin(Date.now() * 0.01) * 0.03;
        this.antenna.rotation.x = -(speedAbs / 35.0) * 0.25;
      }
    }
  }

  /**
   * Applies visceral physical impulse to suspension and yaw on obstacle collision
   */
  applyImpactImpulse(normalX, normalZ, impactSpeedMs = 15.0) {
    const intensity = Math.min(1.0, impactSpeedMs / 25.0);
    // Dynamic front nose dive
    this.impactShockPitch = -0.065 * intensity;
    // Dynamic lateral chassis tilt away from obstacle
    this.impactShockRoll = -Math.sign(normalX) * 0.055 * intensity;
    // Dynamic yaw deflection kick
    this.actualTurnRate += Math.sign(normalX) * 0.22 * intensity;
  }

  takeDamage(amount) {
    let reducedAmount = amount;
    if (this.upgrades.heavy_bullbar || this.upgrades.bullbar) {
      reducedAmount *= 0.35;
    }
    if (this.upgrades.skid_plate || this.upgrades.armored_hull) {
      reducedAmount *= 0.50;
    }
    this.hull = Math.max(0, this.hull - reducedAmount);
    this.audioEngine.playImpact(Math.min(1.0, amount / 25.0));
  }
}


// --- FILE: src/entities/PlayerCharacter.js ---
/**
 * THE LONG MERIDIAN - Player Character (On-Foot Scavenging Mode)
 * Controls player avatar when dismounting vehicle, with flashlight spotlight, stamina and interaction.
 */

class PlayerCharacter {
  constructor(scene, audioEngine) {
    this.scene = scene;
    this.audioEngine = audioEngine;

    this.position = new THREE.Vector3(0, 0, 0);
    this.rotationY = 0;
    this.isActive = false;

    // Stats
    this.health = CONFIG.SURVIVAL.MAX_HEALTH;
    this.stamina = CONFIG.SURVIVAL.MAX_STAMINA;
    this.walkSpeed = CONFIG.PLAYER_FOOT.WALK_SPEED;
    this.isSprinting = false;

    // Visual Mesh & Flashlight
    this.group = new THREE.Group();
    this.buildCharacterMesh();
    this.scene.add(this.group);
    this.group.visible = false;
  }

  buildCharacterMesh() {
    const coatMat = new THREE.MeshStandardMaterial({ color: 0x2e3532, roughness: 0.8 });
    const skinMat = new THREE.MeshStandardMaterial({ color: 0xc49a75, roughness: 0.7 });
    const backpackMat = new THREE.MeshStandardMaterial({ color: 0x5a4838, roughness: 0.9 });

    // Torso / Coat
    const torso = new THREE.Mesh(new THREE.CylinderGeometry(0.35, 0.45, 1.1, 7), coatMat);
    torso.position.y = 1.05;
    torso.castShadow = true;
    this.group.add(torso);

    // Head / Hood
    const head = new THREE.Mesh(new THREE.SphereGeometry(0.24, 7, 7), skinMat);
    head.position.y = 1.75;
    head.castShadow = true;
    this.group.add(head);

    // Backpack
    const backpack = new THREE.Mesh(new THREE.BoxGeometry(0.48, 0.65, 0.32), backpackMat);
    backpack.position.set(0, 1.15, -0.32);
    backpack.castShadow = true;
    this.group.add(backpack);

    // Legs
    this.leftLeg = new THREE.Mesh(new THREE.BoxGeometry(0.2, 0.65, 0.2), coatMat);
    this.leftLeg.position.set(-0.2, 0.35, 0);
    this.leftLeg.castShadow = true;
    this.group.add(this.leftLeg);

    this.rightLeg = new THREE.Mesh(new THREE.BoxGeometry(0.2, 0.65, 0.2), coatMat);
    this.rightLeg.position.set(0.2, 0.35, 0);
    this.rightLeg.castShadow = true;
    this.group.add(this.rightLeg);

    // Flashlight held in hand
    this.flashlight = new THREE.SpotLight(0xfffaed, 3.2, 28, Math.PI / 4, 0.5, 1.2);
    this.flashlight.position.set(0.35, 1.1, 0.3);
    this.flashlight.target.position.set(0.35, 0.5, 12);
    this.flashlight.castShadow = true;
    this.group.add(this.flashlight);
    this.group.add(this.flashlight.target);

    this.walkAnimTime = 0;
  }

  spawnAt(pos) {
    this.position.copy(pos);
    this.group.position.copy(pos);
    this.group.visible = true;
    this.isActive = true;
    this.audioEngine.playSwitchClick(true);
  }

  despawn() {
    this.group.visible = false;
    this.isActive = false;
    this.audioEngine.playSwitchClick(false);
  }

  update(delta, input, roadInfo) {
    if (!this.isActive) return;

    // Movement vectors
    const moveX = input.footMoveX;
    const moveZ = input.footMoveZ;
    const isMoving = Math.abs(moveX) > 0.05 || Math.abs(moveZ) > 0.05;

    let speed = this.walkSpeed;
    if (this.isSprinting && this.stamina > 10) {
      speed = CONFIG.PLAYER_FOOT.SPRINT_SPEED;
      this.stamina = Math.max(0, this.stamina - CONFIG.PLAYER_FOOT.STAMINA_DRAIN * delta);
    } else {
      this.stamina = Math.min(CONFIG.SURVIVAL.MAX_STAMINA, this.stamina + CONFIG.PLAYER_FOOT.STAMINA_RECOVERY * delta);
    }

    if (isMoving) {
      const angle = Math.atan2(moveX, moveZ);
      this.rotationY = THREE.MathUtils.lerp(this.rotationY, angle, delta * 12.0);

      this.position.x += Math.sin(angle) * speed * delta;
      this.position.z += Math.cos(angle) * speed * delta;
      this.position.y = roadInfo.y;

      // Leg swing animation
      this.walkAnimTime += delta * speed * 2.2;
      this.leftLeg.rotation.x = Math.sin(this.walkAnimTime) * 0.6;
      this.rightLeg.rotation.x = -Math.sin(this.walkAnimTime) * 0.6;
    } else {
      this.leftLeg.rotation.x = 0;
      this.rightLeg.rotation.x = 0;
    }

    this.group.position.copy(this.position);
    this.group.rotation.y = this.rotationY;
  }
}


// --- FILE: src/entities/Hazards.js ---
/**
 * THE LONG MERIDIAN - Realistic Highway Hazards & Road Obstacle System
 * 100% Proportioned, authentic road obstacles (fallen timber, blown truck tire treads,
 * rockfall boulders, dropped freight crates, frost-heave buckles, safety barrels).
 * All obstacles strictly occupy at most one lane, guaranteeing clear clearance to pass.
 */

class Hazards {
  constructor(scene, roadGenerator, audioEngine, cameraController) {
    this.scene = scene;
    this.roadGenerator = roadGenerator;
    this.audioEngine = audioEngine;
    this.cameraController = cameraController;

    this.hazardList = [];
    this.nextHazardZ = 60;
    this.spawnInterval = 45; // Generous highway spacing (every 40-70m)

    this.initAssets();
  }

  initAssets() {
    // Realistic materials for authentic highway debris
    this.matWoodBark = new THREE.MeshStandardMaterial({
      color: 0x3d2719,
      roughness: 0.95,
      metalness: 0.05
    });
    this.matWoodCut = new THREE.MeshStandardMaterial({
      color: 0xc8a46e,
      roughness: 0.85,
      metalness: 0.0
    });
    this.matTireRubber = new THREE.MeshStandardMaterial({
      color: 0x18191b,
      roughness: 0.95,
      metalness: 0.1
    });
    this.matGraniteRock = new THREE.MeshStandardMaterial({
      color: 0x5a544d,
      roughness: 0.92,
      metalness: 0.08
    });
    this.matCargoWood = new THREE.MeshStandardMaterial({
      color: 0x6e5239,
      roughness: 0.85,
      metalness: 0.1
    });
    this.matSteelDrum = new THREE.MeshStandardMaterial({
      color: 0x1e3a5f, // Industrial blue steel drum
      roughness: 0.45,
      metalness: 0.75
    });
    this.matRustedMetal = new THREE.MeshStandardMaterial({
      color: 0x7c2d12,
      roughness: 0.85,
      metalness: 0.4
    });
    this.matBarrelOrange = new THREE.MeshStandardMaterial({
      color: 0xea580c, // Safety orange
      roughness: 0.5,
      metalness: 0.1
    });
    this.matReflectiveWhite = new THREE.MeshStandardMaterial({
      color: 0xf8fafc,
      roughness: 0.3,
      emissive: 0x94a3b8,
      emissiveIntensity: 0.3
    });
    this.matPotholeAsphalt = new THREE.MeshStandardMaterial({
      color: 0x15171a,
      roughness: 0.98
    });
    this.matPotholeWater = new THREE.MeshStandardMaterial({
      color: 0x11161d,
      roughness: 0.08,
      metalness: 0.9,
      transparent: true,
      opacity: 0.88
    });
  }

  update(playerZ, vehicle, playerFoot, delta, malfunctionManager = null, renderer = null) {
    // 1. Spawning
    const maxZ = playerZ + 220;
    while (this.nextHazardZ < maxZ) {
      this.spawnHazardAt(this.nextHazardZ);
      this.nextHazardZ += this.spawnInterval + (Math.random() * 30 - 10);
    }

    // 2. Collision Detection & Physics Resolution
    for (let i = this.hazardList.length - 1; i >= 0; i--) {
      const h = this.hazardList[i];

      // Decrement hit cooldown
      if (h.hitCooldown > 0) {
        h.hitCooldown -= delta;
      }

      // Check collision with Vehicle
      if (!h.destroyed) {
        const dx = vehicle.position.x - h.position.x;
        const dz = vehicle.position.z - h.position.z;
        const dist = Math.hypot(dx, dz);
        const carHalfWidth = vehicle.modelDims ? (vehicle.modelDims.width * 0.48) : 0.82;
        const contactRadius = h.radius + carHalfWidth;

        if (dist < contactRadius) {
          this.resolveVehicleCollision(h, vehicle, dist, contactRadius, dx, dz, malfunctionManager, renderer);
        }
      }

      // Check Scavenge proximity on foot
      if (playerFoot && playerFoot.active && (h.type === 'dropped_crate' || h.type === 'dropped_drum') && !h.scavenged) {
        const footDist = playerFoot.position.distanceTo(h.position);
        h.canScavenge = (footDist < 2.5);
      }

      // Despawn
      if (h.position.z < playerZ - 60) {
        this.scene.remove(h.mesh);
        this.hazardList.splice(i, 1);
      }
    }
  }

  spawnHazardAt(z) {
    const roadInfo = this.roadGenerator.getRoadInfoAt(z);
    const halfW = roadInfo.width * 0.5;

    // Pick lane: strictly place either in LEFT lane (-3.4m) or RIGHT lane (+3.4m)
    // with subtle jitter, guaranteeing the other lane has > 6.0m of clear clearance!
    const side = Math.random() < 0.5 ? -1 : 1;
    const laneOffset = side * (halfW * 0.45 + (Math.random() - 0.5) * 1.2);
    const x = roadInfo.x + laneOffset;
    const y = roadInfo.y;

    const roll = Math.random();
    let type = 'blown_tire';

    if (roll < 0.22) type = 'fallen_timber';
    else if (roll < 0.45) type = 'blown_tire';
    else if (roll < 0.65) type = 'rockfall_debris';
    else if (roll < 0.80) type = 'dropped_crate';
    else if (roll < 0.92) type = 'frost_heave';
    else type = 'construction_drum';

    let mesh = null;
    let radius = 1.1;

    switch (type) {
      case 'fallen_timber': {
        // Realistic fallen pine log with branch stubs across part of one lane
        mesh = new THREE.Group();
        const trunkLen = 4.8;
        const trunkR = 0.26;
        const trunkGeo = new THREE.CylinderGeometry(trunkR * 0.8, trunkR, trunkLen, 7);
        const trunkMesh = new THREE.Mesh(trunkGeo, this.matWoodBark);
        trunkMesh.rotation.z = Math.PI / 2;
        trunkMesh.castShadow = true;
        trunkMesh.receiveShadow = true;
        mesh.add(trunkMesh);

        // Cut wood end rings
        const cutGeo = new THREE.CircleGeometry(trunkR * 0.8, 7);
        const cutMesh = new THREE.Mesh(cutGeo, this.matWoodCut);
        cutMesh.position.set(-trunkLen * 0.5, 0, 0);
        cutMesh.rotation.y = -Math.PI / 2;
        mesh.add(cutMesh);

        // 2 Branch nubs
        const branchGeo = new THREE.CylinderGeometry(0.08, 0.12, 0.9, 5);
        const b1 = new THREE.Mesh(branchGeo, this.matWoodBark);
        b1.position.set(-1.0, 0.35, 0.1);
        b1.rotation.x = 0.6;
        mesh.add(b1);

        const b2 = new THREE.Mesh(branchGeo, this.matWoodBark);
        b2.position.set(1.2, 0.3, -0.15);
        b2.rotation.x = -0.5;
        mesh.add(b2);

        // Angle naturally across the lane
        mesh.rotation.y = (Math.random() - 0.5) * 0.55;
        mesh.position.set(x, y + trunkR, z);
        radius = 2.1;
        break;
      }

      case 'blown_tire': {
        // "Alligatore" - Shredded semi-truck radial tire tread dropped on highway
        mesh = new THREE.Group();
        const treadGeo = new THREE.BoxGeometry(0.95, 0.12, 0.36);
        const tread = new THREE.Mesh(treadGeo, this.matTireRubber);
        tread.castShadow = true;
        tread.receiveShadow = true;
        mesh.add(tread);

        // Frayed steel cord whiskers
        const cordGeo = new THREE.BoxGeometry(0.35, 0.04, 0.08);
        const cord = new THREE.Mesh(cordGeo, this.matRustedMetal);
        cord.position.set(0.5, 0.04, 0.1);
        mesh.add(cord);

        mesh.rotation.y = (Math.random() - 0.5) * 1.2;
        mesh.position.set(x, y + 0.06, z);
        radius = 0.85;
        break;
      }

      case 'rockfall_debris': {
        // Cluster of 2-3 tumbled jagged granite boulders
        mesh = new THREE.Group();
        const count = 2 + Math.floor(Math.random() * 2);
        for (let k = 0; k < count; k++) {
          const rSize = 0.45 + Math.random() * 0.45;
          const rockGeo = new THREE.DodecahedronGeometry(rSize, 0);
          const rock = new THREE.Mesh(rockGeo, this.matGraniteRock);
          rock.position.set(
            (Math.random() - 0.5) * 1.4,
            rSize * 0.7,
            (Math.random() - 0.5) * 1.4
          );
          rock.rotation.set(Math.random() * 3, Math.random() * 3, Math.random() * 3);
          rock.castShadow = true;
          rock.receiveShadow = true;
          mesh.add(rock);
        }
        mesh.position.set(x, y, z);
        radius = 1.35;
        break;
      }

      case 'dropped_crate': {
        // Heavy wooden freight crate with steel corner reinforcements
        mesh = new THREE.Group();
        const crateGeo = new THREE.BoxGeometry(1.2, 0.95, 0.9);
        const crate = new THREE.Mesh(crateGeo, this.matCargoWood);
        crate.castShadow = true;
        crate.receiveShadow = true;
        mesh.add(crate);

        // Corner metal strapping
        const strapGeo = new THREE.BoxGeometry(1.22, 0.97, 0.06);
        const strap = new THREE.Mesh(strapGeo, this.matRustedMetal);
        mesh.add(strap);

        mesh.rotation.y = (Math.random() - 0.5) * 0.6;
        mesh.position.set(x, y + 0.48, z);
        radius = 1.15;
        break;
      }

      case 'frost_heave': {
        // Permafrost road buckle / asphalt pothole with water puddle
        mesh = new THREE.Group();
        const rimGeo = new THREE.CylinderGeometry(1.4, 1.6, 0.08, 10);
        const rim = new THREE.Mesh(rimGeo, this.matPotholeAsphalt);
        rim.receiveShadow = true;
        mesh.add(rim);

        const waterGeo = new THREE.CylinderGeometry(1.2, 1.2, 0.09, 10);
        const water = new THREE.Mesh(waterGeo, this.matPotholeWater);
        water.receiveShadow = true;
        mesh.add(water);

        mesh.position.set(x, y + 0.04, z);
        radius = 1.4;
        break;
      }

      case 'construction_drum': {
        // Highway safety traffic drum with retroreflective stripes
        mesh = new THREE.Group();
        // Weighted black rubber base
        const baseGeo = new THREE.CylinderGeometry(0.42, 0.45, 0.12, 12);
        const base = new THREE.Mesh(baseGeo, this.matTireRubber);
        base.position.y = 0.06;
        base.castShadow = true;
        mesh.add(base);

        // Orange barrel body
        const drumGeo = new THREE.CylinderGeometry(0.3, 0.35, 1.05, 12);
        const drum = new THREE.Mesh(drumGeo, this.matBarrelOrange);
        drum.position.y = 0.6;
        drum.castShadow = true;
        mesh.add(drum);

        // 2 Retroreflective white stripes
        const stripe1 = new THREE.Mesh(new THREE.CylinderGeometry(0.32, 0.33, 0.18, 12), this.matReflectiveWhite);
        stripe1.position.y = 0.52;
        mesh.add(stripe1);

        const stripe2 = new THREE.Mesh(new THREE.CylinderGeometry(0.31, 0.32, 0.18, 12), this.matReflectiveWhite);
        stripe2.position.y = 0.82;
        mesh.add(stripe2);

        mesh.position.set(x, y, z);
        radius = 0.9;
        break;
      }
    }

    if (mesh) {
      this.scene.add(mesh);
      this.hazardList.push({
        type: type,
        position: new THREE.Vector3(x, y, z),
        mesh: mesh,
        radius: radius,
        destroyed: false,
        scavenged: false,
        canScavenge: false,
        hitCooldown: 0.0
      });
    }
  }

  resolveVehicleCollision(hazard, vehicle, dist, contactRadius, dx, dz, malfunctionManager = null, renderer = null) {
    // 1. Cooldown Guard & Gentle Separation:
    // If obstacle is already on cooldown, prevent multi-frame damage and velocity freeze,
    // but gently push the car outward so it never gets wedged or stuck.
    if (hazard.hitCooldown > 0) {
      const overlap = contactRadius - dist;
      if (overlap > 0) {
        const nx = dist > 0.01 ? (dx / dist) : (dx >= 0 ? 1 : -1);
        vehicle.position.x += nx * overlap * 0.35;
      }
      return;
    }

    // Activate collision cooldown (prevents rapid-fire damage and stuck physics)
    hazard.hitCooldown = 0.85;

    const speedMs = Math.abs(vehicle.forwardSpeed);
    const speedKmh = speedMs * 3.6;
    const speedRatio = Math.min(1.0, speedKmh / 90.0);

    const nx = dist > 0.01 ? (dx / dist) : (dx >= 0 ? 1 : -1);
    const nz = dist > 0.01 ? (dz / dist) : 1;
    const overlap = Math.max(0, contactRadius - dist);

    const contactPoint = new THREE.Vector3(
      (vehicle.position.x + hazard.position.x) * 0.5,
      vehicle.position.y + 0.35,
      (vehicle.position.z + hazard.position.z) * 0.5
    );

    // 2. Immediate Dispenetration: Push vehicle out of hazard volume
    vehicle.position.x += nx * (overlap + 0.14);
    vehicle.position.z += nz * (overlap + 0.14);

    // 3. Dynamic Suspension & Chassis Shock Impulse
    if (vehicle.applyImpactImpulse) {
      vehicle.applyImpactImpulse(nx, nz, speedMs);
    }

    // 4. Type-Specific Impact Mechanics
    // ----------------------------------------------------
    // Type A: Pothole / Frost Heave (Suspension shock, never stops car dead)
    if (hazard.type === 'frost_heave') {
      if (speedKmh > 30) {
        this.cameraController.addTrauma(0.35 * speedRatio);
        this.audioEngine.playSuspensionThump(0.4 + speedRatio * 0.5);
        vehicle.forwardSpeed *= 0.91;
        if (renderer) {
          renderer.emitImpactDebris(contactPoint, 'rock', 8);
        }
        if (malfunctionManager && speedKmh > 70 && !vehicle.upgrades.rally_suspension && Math.random() < 0.22) {
          malfunctionManager.triggerFault('flat_tire');
        }
      }
      return;
    }

    // Type B: Blown Truck Tire Tread (Light rubber debris explodes and scatters)
    if (hazard.type === 'blown_tire') {
      this.audioEngine.playImpact(0.35);
      this.cameraController.addTrauma(0.25);
      vehicle.forwardSpeed *= 0.94;
      vehicle.takeDamage(Math.round(2 + speedRatio * 4));
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) {
        renderer.emitImpactDebris(contactPoint, 'rubber', 14);
      }
      if (malfunctionManager && !vehicle.upgrades.studded_tires && Math.random() < 0.12) {
        malfunctionManager.triggerFault('flat_tire');
      }
      return;
    }

    // Type C: Construction Drum (Orange plastic barrel knocked flying with sparks)
    if (hazard.type === 'construction_drum') {
      this.audioEngine.playImpact(0.4);
      this.cameraController.addTrauma(0.2);
      vehicle.forwardSpeed *= 0.96;
      vehicle.takeDamage(Math.round(1 + speedRatio * 3));
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) {
        renderer.emitImpactDebris(contactPoint, 'barrel', 16);
        renderer.emitImpactSparks(contactPoint, 10);
      }
      return;
    }

    // Type D: Dropped Freight Crate (Wooden crate shatters with splinters)
    if (hazard.type === 'dropped_crate') {
      const damage = Math.round(5 + speedRatio * 11);
      vehicle.takeDamage(damage);
      // Glancing speed reduction: preserves momentum, NEVER stops dead!
      vehicle.forwardSpeed = Math.max(3.8, vehicle.forwardSpeed * 0.82);
      this.cameraController.addTrauma(Math.min(0.8, 0.25 + speedRatio * 0.5));
      this.audioEngine.playImpact(0.65);
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
      if (renderer) {
        renderer.emitImpactDebris(contactPoint, 'wood', 20);
        renderer.emitImpactSparks(contactPoint, 8);
      }
      return;
    }

    // Type E: Rigid Heavy Obstacles (Fallen Timber & Granite Rockfall)
    const isRock = hazard.type === 'rockfall_debris';
    const baseDmg = isRock ? 15 : 10;
    const damage = Math.round(baseDmg + speedRatio * (isRock ? 26 : 20));
    vehicle.takeDamage(damage);

    this.cameraController.addTrauma(Math.min(1.0, 0.4 + speedRatio * 0.65));
    this.audioEngine.playImpact(Math.min(1.0, 0.65 + speedRatio * 0.35));
    this.audioEngine.playSuspensionThump(0.5 + speedRatio * 0.5);

    if (renderer) {
      renderer.emitImpactDebris(contactPoint, isRock ? 'rock' : 'wood', 24);
      renderer.emitImpactSparks(contactPoint, 16);
    }

    // Lateral Glancing Deflection:
    // Real vehicles deflect sideways rather than coming to a dead halt!
    const deflectDir = Math.sign(nx) || (Math.random() < 0.5 ? 1 : -1);
    vehicle.position.x += deflectDir * (0.45 + speedRatio * 0.55);

    // Momentum Retention:
    // Retains at least 3.5 m/s (~12.6 km/h) of rolling speed so the car never stalls or gets locked in place!
    const massFactor = 1200 / (vehicle.modelConfig.weightKg || 1200);
    const retention = Math.max(0.52, 0.72 - speedRatio * 0.20 * massFactor);
    vehicle.forwardSpeed = Math.max(3.5, vehicle.forwardSpeed * retention);

    // Mechanical Fault Risk
    if (malfunctionManager) {
      if (isRock && !vehicle.upgrades.skid_plate && Math.random() < 0.40) {
        malfunctionManager.triggerFault('flat_tire');
      }
      if (speedRatio > 0.60 && !(vehicle.upgrades.heavy_bullbar || vehicle.upgrades.bullbar) && Math.random() < 0.30) {
        malfunctionManager.triggerFault('radiator_leak');
        if (renderer) {
          renderer.emitImpactDebris(vehicle.position, 'steam', 18);
        }
      }
    }

    // Obstacle Dynamic Displacement:
    // If car has Bullbar OR is moving fast (> 55 km/h), the obstacle is smashed / cleared from the road!
    const hasBullbar = !!(vehicle.upgrades.heavy_bullbar || vehicle.upgrades.bullbar);
    if (hasBullbar || speedRatio > 0.62) {
      hazard.destroyed = true;
      this.scene.remove(hazard.mesh);
    } else {
      // Shove the obstacle aside toward the nearest shoulder so it doesn't block repeat travel
      const shoveDir = -deflectDir;
      hazard.position.x += shoveDir * 1.8;
      hazard.mesh.position.x = hazard.position.x;
      hazard.mesh.rotation.y += 0.4;
    }
  }
}


// --- FILE: src/systems/SurvivalState.js ---
/**
 * THE LONG MERIDIAN - Survival State & Vitals Manager
 * Manages player hunger, thirst, body temperature, health and odometer distance.
 */

class SurvivalState {
  constructor(audioEngine) {
    this.audioEngine = audioEngine;

    this.health = CONFIG.SURVIVAL.MAX_HEALTH;
    this.stamina = CONFIG.SURVIVAL.MAX_STAMINA;
    this.hunger = 85; // 0 to 100
    this.thirst = 90; // 0 to 100
    this.bodyTemp = 37.0; // Celsius (safe 36-38)
    this.radiation = 0; // 0 to 100

    this.distanceTraveledMeters = 0;
    this.gameTimeSeconds = 0; // Simulated time of day (starts 06:00 AM)
    this.timeOfDay = 8.5; // Decimal hour (8.5 = 08:30)

    this.isDead = false;
  }

  update(delta, currentZ, currentBiome, isInsideVehicle) {
    if (this.isDead) return;

    this.distanceTraveledMeters = Math.max(this.distanceTraveledMeters, currentZ);
    this.gameTimeSeconds += delta;
    this.timeOfDay = (8.0 + (this.gameTimeSeconds * 0.04)) % 24;

    // Vitals decay
    this.hunger = Math.max(0, this.hunger - CONFIG.SURVIVAL.HUNGER_RATE * delta);
    this.thirst = Math.max(0, this.thirst - CONFIG.SURVIVAL.THIRST_RATE * delta);

    // Starvation / Dehydration damage
    if (this.hunger <= 0 || this.thirst <= 0) {
      this.health = Math.max(0, this.health - delta * 1.5);
    }

    // Environmental Exposure (Cold / Heat / Radiation)
    if (!isInsideVehicle) {
      if (currentBiome.coldDanger) {
        this.bodyTemp = Math.max(32.0, this.bodyTemp - delta * 0.15);
        if (this.bodyTemp < 35.0) {
          this.health = Math.max(0, this.health - delta * CONFIG.SURVIVAL.FREEZING_TEMP_DAMAGE);
        }
      } else if (currentBiome.heatDanger) {
        // Desert heat exhaustion: accelerated thirst & hyperthermia
        this.thirst = Math.max(0, this.thirst - CONFIG.SURVIVAL.THIRST_RATE * 2.2 * delta);
        this.bodyTemp = Math.min(41.5, this.bodyTemp + delta * 0.12);
        if (this.bodyTemp > 39.0) {
          this.health = Math.max(0, this.health - delta * 1.6);
        }
      } else {
        // Recover body temp gradually toward normal 37.0°C
        this.bodyTemp = THREE.MathUtils.lerp(this.bodyTemp, 37.0, delta * 0.2);
      }

      if (currentBiome.radiationDanger) {
        this.radiation = Math.min(100, this.radiation + delta * 3.5);
        if (this.radiation > 40) {
          this.health = Math.max(0, this.health - delta * CONFIG.SURVIVAL.TOXIC_DAMAGE);
        }
      }
    } else {
      // Inside vehicle provides shelter, shade & cabin ventilation
      if (currentBiome.heatDanger) {
        this.thirst = Math.max(0, this.thirst - CONFIG.SURVIVAL.THIRST_RATE * 1.35 * delta);
      }
      this.bodyTemp = THREE.MathUtils.lerp(this.bodyTemp, 37.0, delta * 0.4);
    }

    // Death check
    if (this.health <= 0 && !this.isDead) {
      this.isDead = true;
      console.log('Player succumbed to harsh conditions.');
    }
  }

  consumeItem(itemId) {
    if (itemId === 'ration_pack' || itemId === 'canned_stew' || itemId === 'dried_dates') {
      this.hunger = Math.min(CONFIG.SURVIVAL.MAX_HUNGER, this.hunger + (itemId === 'dried_dates' ? 35 : 45));
      this.health = Math.min(CONFIG.SURVIVAL.MAX_HEALTH, this.health + 10);
      this.audioEngine.playLootPickup();
      return true;
    }
    if (itemId === 'water_bottle' || itemId === 'water_purified' || itemId === 'coconut_water' || itemId === 'hot_tea') {
      this.thirst = Math.min(CONFIG.SURVIVAL.MAX_THIRST, this.thirst + 55);
      if (itemId === 'hot_tea') {
        this.bodyTemp = Math.min(38.0, this.bodyTemp + 0.8);
      }
      this.audioEngine.playLootPickup();
      return true;
    }
    if (itemId === 'medkit') {
      this.health = Math.min(CONFIG.SURVIVAL.MAX_HEALTH, this.health + 50);
      this.radiation = Math.max(0, this.radiation - 30);
      this.audioEngine.playLootPickup();
      return true;
    }
    if (itemId === 'first_aid_bandage') {
      this.health = Math.min(CONFIG.SURVIVAL.MAX_HEALTH, this.health + 25);
      this.audioEngine.playLootPickup();
      return true;
    }
    return false;
  }

  getTimePeriod() {
    const t = this.timeOfDay;
    // Mathematically balanced: exactly 12 hours day (06:00 to 18:00) and 12 hours night (18:00 to 06:00)
    if (t >= 6.0 && t < 7.5) return 'dawn';
    if (t >= 7.5 && t < 16.5) return 'day';
    if (t >= 16.5 && t < 18.0) return 'sunset';
    if (t >= 18.0 && t < 19.5) return 'dusk';
    return 'night';
  }

  getFormattedTime() {
    const totalMinutes = Math.floor(this.timeOfDay * 60);
    const hours = Math.floor(totalMinutes / 60) % 24;
    const minutes = totalMinutes % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
  }
}


// --- FILE: src/systems/InventorySystem.js ---
/**
 * THE LONG MERIDIAN - Inventory & Cargo Management
 * Manages item definitions, weight calculations, vehicle trunk and backpack storage.
 */

const ITEM_DEFS = {
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

class InventorySystem {
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


// --- FILE: src/systems/WeatherDirector.js ---
/**
 * THE LONG MERIDIAN - Dynamic Weather Director
 * Manages atmospheric conditions, storm fronts, and visibility effects.
 */

class WeatherDirector {
  constructor(renderer, audioEngine, biomeManager) {
    this.renderer = renderer;
    this.audioEngine = audioEngine;
    this.biomeManager = biomeManager;

    this.currentWeather = 'clear';
    this.timer = 0;
    this.weatherDuration = 55; // seconds per weather state
    this.roadImpact = this.calculateRoadImpact('clear');
  }

  getRoadImpact() {
    return this.roadImpact;
  }

  calculateRoadImpact(weather) {
    let frictionMultiplier = 1.0;
    let roughness = 0.78;
    let metalness = 0.12;
    let statusLabel = 'ASFALTO ASCIUTTO';
    let statusBadge = 'GRIP 100%';
    let statusColor = '#22c55e';
    let isWet = false;
    let isIcy = false;

    switch (weather) {
      case 'clear':
      case 'sea_breeze':
      case 'smog':
        frictionMultiplier = 1.0;
        roughness = 0.78;
        metalness = 0.12;
        statusLabel = 'FONDO ASCIUTTO OTTIMALE';
        statusBadge = 'GRIP 100%';
        statusColor = '#22c55e';
        break;

      case 'heatwave':
        frictionMultiplier = 0.94;
        roughness = 0.85;
        metalness = 0.08;
        statusLabel = 'CALDO ESTREMO / ASFALTO ROVENTE';
        statusBadge = 'GRIP 94% 🔥';
        statusColor = '#f97316';
        break;

      case 'sandstorm':
      case 'dust_devil':
        frictionMultiplier = 0.74;
        roughness = 0.92;
        metalness = 0.05;
        statusLabel = 'SABBIA IN SOSPENSIONE / SCIVOLOSO';
        statusBadge = 'GRIP 74% ⚠️';
        statusColor = '#d97706';
        break;

      case 'dry_gale':
      case 'gale_winds':
      case 'mountain_gale':
      case 'rock_dust':
        frictionMultiplier = 0.82;
        roughness = 0.86;
        metalness = 0.08;
        statusLabel = 'RAFFICHE & DETRITI ROCCIOSI';
        statusBadge = 'GRIP 82%';
        statusColor = '#eab308';
        break;

      case 'overcast':
      case 'aurora_static':
      case 'ion_storm':
        frictionMultiplier = 0.96;
        roughness = 0.72;
        metalness = 0.18;
        statusLabel = 'FONDO FREDDO / STABILE';
        statusBadge = 'GRIP 96%';
        statusColor = '#38bdf8';
        break;

      case 'heavy_mist':
      case 'dense_fog':
        frictionMultiplier = 0.88;
        roughness = 0.42;
        metalness = 0.38;
        statusLabel = 'NEBBIA FITTA / ASFALTO UMIDO';
        statusBadge = 'GRIP 88%';
        statusColor = '#38bdf8';
        isWet = true;
        break;

      case 'rain':
      case 'light_rain':
      case 'cold_drizzle':
      case 'acid_drizzle':
        frictionMultiplier = 0.74;
        roughness = 0.16;
        metalness = 0.80;
        statusLabel = 'ASFALTO BAGNATO';
        statusBadge = 'GRIP 74%';
        statusColor = '#eab308';
        isWet = true;
        break;

      case 'tropical_monsoon':
      case 'torrential_rain':
        frictionMultiplier = 0.52;
        roughness = 0.05;
        metalness = 0.96;
        statusLabel = 'MONSONE / ACQUAPLANING & FANGO';
        statusBadge = 'GRIP 52% ⚠️';
        statusColor = '#f97316';
        isWet = true;
        break;

      case 'light_snow':
        frictionMultiplier = 0.65;
        roughness = 0.50;
        metalness = 0.40;
        statusLabel = 'NEVE FRESCA COMPATTA';
        statusBadge = 'GRIP 65% ❄️';
        statusColor = '#38bdf8';
        isIcy = true;
        break;

      case 'freezing_rain':
        frictionMultiplier = 0.36;
        roughness = 0.22;
        metalness = 0.55;
        statusLabel = 'VETRONE / GHIACCIO VIVO';
        statusBadge = 'GRIP 36% ⚠️';
        statusColor = '#ef4444';
        isIcy = true;
        break;

      case 'blizzard':
        frictionMultiplier = 0.42;
        roughness = 0.38;
        metalness = 0.45;
        statusLabel = 'BUFERA DI NEVE / POLARE';
        statusBadge = 'GRIP 42% ⚠️';
        statusColor = '#ef4444';
        isIcy = true;
        break;

      case 'whiteout':
        frictionMultiplier = 0.30;
        roughness = 0.40;
        metalness = 0.50;
        statusLabel = 'WHITEOUT / VISIBILITÀ ZERO';
        statusBadge = 'GRIP 30% ⚠️';
        statusColor = '#ef4444';
        isIcy = true;
        break;

      default:
        frictionMultiplier = 1.0;
        break;
    }

    return {
      weather,
      frictionMultiplier,
      roughness,
      metalness,
      statusLabel,
      statusBadge,
      statusColor,
      isWet,
      isIcy
    };
  }

  update(delta, playerZ, roadGenerator = null) {
    this.timer += delta;
    if (this.timer > this.weatherDuration) {
      this.timer = 0;
      this.pickNextWeather();
    }

    // Apply specular wet sheen or frost directly to road asphalt material
    if (roadGenerator && roadGenerator.materials && roadGenerator.materials.asphalt) {
      const mat = roadGenerator.materials.asphalt;
      mat.roughness = THREE.MathUtils.lerp(mat.roughness, this.roadImpact.roughness, delta * 1.5);
      mat.metalness = THREE.MathUtils.lerp(mat.metalness, this.roadImpact.metalness, delta * 1.5);
      if (this.roadImpact.isIcy) {
        mat.color.lerp(new THREE.Color(0xb5c9db), delta * 0.8);
      } else {
        mat.color.lerp(new THREE.Color(0xffffff), delta * 0.8);
      }
    }

    // Update particles in renderer
    this.renderer.updateWeatherParticles(delta, playerZ, this.currentWeather);
  }

  pickNextWeather() {
    const biome = this.biomeManager.currentBiome;
    const possibleWeathers = biome.weatherTypes || ['clear', 'rain'];
    const next = possibleWeathers[Math.floor(Math.random() * possibleWeathers.length)];
    this.currentWeather = next;
    this.roadImpact = this.calculateRoadImpact(next);
    console.log(`[WEATHER] Atmospheric front shifted to: ${next} (Road Grip: ${(this.roadImpact.frictionMultiplier * 100).toFixed(0)}%)`);
  }
}


// --- FILE: src/systems/UpgradeSystem.js ---
/**
 * THE LONG MERIDIAN - Fleet Progression & Modular Engineering Workshop System
 * Manages Dalton Highway Barn Finds, derelict restorations, vehicle fleet switching,
 * station cargo stashes, and 14 modular engineering upgrades across 4 branches.
 */

class UpgradeSystem {
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


// --- FILE: src/systems/MalfunctionManager.js ---
/**
 * THE LONG MERIDIAN - Vehicle Malfunction & Breakdown Management System
 * Simulates realistic vehicle failures: tire punctures, radiator leaks, electrical faults, and engine stalls.
 */

class MalfunctionManager {
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


// --- FILE: src/systems/StoryDirector.js ---
/**
 * THE LONG MERIDIAN - Story Director & Narrative Campaign System
 * Coordinates the 6-chapter arctic expedition, CB radio dispatches, real-time objectives,
 * narrative milestones and vehicle unlock secrets along the Dalton Highway.
 */

class StoryDirector {
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


// --- FILE: src/ui/DashboardHUD.js ---
/**
 * THE LONG MERIDIAN - Enhanced Survival Cockpit Dashboard HUD
 * Premium industrial aesthetic, large analog dials with tick markings, textured tactile controls.
 */

class DashboardHUD {
  constructor(container, vehicle, survivalState, touchInput, audioEngine, malfunctionManager = null) {
    this.container = container;
    this.vehicle = vehicle;
    this.survivalState = survivalState;
    this.touchInput = touchInput;
    this.audioEngine = audioEngine;
    this.malfunctionManager = malfunctionManager;

    this.onToggleMode = null;
    this.onOpenInventory = null;
    this.onOpenWorkshop = null;
    this.onOpenGarage = null;
    this.onOpenAtlas = null;
    this.onOpenStoryDiary = null;
    this.onScavenge = null;
    this.storyDirector = null;

    this.currentModelId = null;
    this.element = null;
    this.buildHUD();
  }

  buildHUD() {
    this.element = document.createElement('div');
    this.element.id = 'cockpit-dashboard';
    this.element.innerHTML = `
      <!-- Top Status Header Ticker -->
      <div class="cockpit-top-bar">
        <div class="top-bar-inner">
          <div class="biome-badge" id="hud-biome-badge">
            <span class="biome-dot"></span>
            <span class="biome-label">SETTORE:</span>
            <span id="hud-biome-name">THE RUSTY PERIPHERY</span>
          </div>

          <div class="telemetry-readout">
            <span class="tele-item"><span class="tele-lbl">GPS:</span> <strong id="hud-gps">LAT 64°12'N</strong></span>
            <span class="tele-item"><span class="tele-lbl">ELEV:</span> <strong id="hud-elev">380 M</strong></span>
            <span class="tele-item"><span class="tele-lbl">RAD:</span> <strong id="hud-rad-val" class="rad-safe">0.02 mSv</strong></span>
          </div>

          <div class="odometer-display">
            <span class="odo-label">CORRIDOIO NORD</span>
            <span id="hud-odometer">0000.0</span> <span class="odo-unit">KM</span>
          </div>

          <div class="time-display" id="hud-time">08:30</div>
        </div>
      </div>

      <!-- Story Objective Pinned Tracker -->
      <div class="story-objective-banner" id="story-objective-banner" title="Clicca per aprire il Diario di Bordo e Missioni">
        <div class="story-ch-badge" id="story-ch-badge">CAPITOLO I</div>
        <div class="story-obj-body">
          <span class="story-target-icon">🎯</span>
          <span class="story-obj-desc" id="story-obj-text">Mettiti in marcia e percorri i primi 200 metri lungo la costiera</span>
        </div>
        <div class="story-badge-action">DIARIO 📖</div>
      </div>

      <!-- Main Cockpit Console Container (Full-Width Vintage Industrial Cockpit) -->
      <div class="cockpit-console-frame">
        <!-- 1. Left Pod: Driver Steering Controls & Telemetry -->
        <div class="console-pod pod-left">
          <div class="pod-header">SISTEMA DI STERZO</div>
          
          <div class="turn-signals-bar">
            <div class="blinker-lamp" id="blinker-l" title="Indicatore di Direzione Sinistro">◀</div>
            <button class="hazard-button" id="btn-hazard" title="Luci di Emergenza (4 Frecce)">
              <span class="hazard-icon">⚠️</span>
              <span class="hazard-text">HAZARD</span>
            </button>
            <div class="blinker-lamp" id="blinker-r" title="Indicatore di Direzione Destro">▶</div>
          </div>

          <div class="steering-assembly">
            <div class="steering-wheel-graphic" id="steering-wheel">
              <div class="wheel-rim">
                <div class="wheel-spoke spoke-left"></div>
                <div class="wheel-spoke spoke-right"></div>
                <div class="wheel-spoke spoke-bottom"></div>
                <div class="wheel-hub" id="wheel-hub" title="Clacson • Premi per suonare (oppure premi H)">
                  <span class="hub-logo">MERIDIAN</span>
                </div>
              </div>
            </div>

            <div class="rack-telemetry-badge">
              <span class="rack-lbl">ANGOLO RACK:</span>
              <strong id="rack-angle-val">0.0°</strong>
            </div>

            <!-- Touch Steering Slider / Buttons -->
            <div class="steering-touch-track" id="steering-track">
              <span class="steer-arrow arrow-left">◀</span>
              <div class="steering-knob" id="steering-knob">
                <div class="knob-marker"></div>
              </div>
              <span class="steer-arrow arrow-right">▶</span>
            </div>
            <div class="control-label">TRASCINA O USA A / D</div>
          </div>
        </div>

        <!-- 2. Center Pod: Upper Aux Deck + Main Gauges + Switches -->
        <div class="console-pod pod-center">
          <div class="cluster-sub-header">
            <span class="cluster-brand-name" id="hud-cluster-brand">VEGLIA BORLETTI PANDA</span>
            <span class="cluster-gear-badge gear-drive" id="hud-gear-badge">▶ DRIVE</span>
            <span class="cluster-drivetrain-tag" id="hud-drivetrain-badge">4WD STEYR INSERIBILE</span>
          </div>

          <!-- Upper Vintage Auxiliary Equipment Console (Fills upper space authentically) -->
          <div class="vintage-aux-deck">
            <!-- 1. Climate & Air Louvers Unit -->
            <div class="aux-module aux-climate" title="Impianto Climatizzazione e Bocchette Abitacolo">
              <div class="aux-title-tiny">CLIMA & AERAZIONE</div>
              <div class="climate-louvers">
                <div class="air-vent-grill"><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slider"></div></div>
                <div class="air-vent-grill"><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slat"></div><div class="vent-slider"></div></div>
              </div>
              <div class="climate-controls">
                <span class="climate-icon">❄️</span>
                <div class="climate-slider-bar"><div class="climate-thumb" id="climate-thumb"></div></div>
                <span class="climate-icon">🔥</span>
                <div class="fan-knob-badge" id="fan-knob">FAN II</div>
              </div>
            </div>

            <!-- 2. Alaska Dalton CB Radio Transceiver -->
            <div class="aux-module aux-cb-radio" title="Ricetrasmettitore CB Midland Alan 48 - Canale Emergenza 19">
              <div class="aux-title-tiny">CB TRANSCEIVER • 27 MHz</div>
              <div class="cb-faceplate">
                <div class="cb-screen">
                  <span class="cb-ch">CH 19</span>
                  <span class="cb-status" id="cb-channel-name">MERIDIAN CONVOY • EMGCY</span>
                </div>
                <div class="cb-smeter">
                  <span class="smeter-lbl">SIGNAL</span>
                  <div class="smeter-bar-strip">
                    <span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot active"></span><span class="s-dot"></span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 3. Triple VDO Auxiliary Gauges (Battery Volts, Oil Press/Temp, Road Status & Ambient Temp) -->
            <div class="aux-module aux-triple-gauges">
              <div class="mini-vdo-gauge" title="Tensione Alternatore / Batteria">
                <div class="vdo-label">VOLT</div>
                <div class="vdo-val" id="vdo-volts">14.2V</div>
                <div class="vdo-bar"><div class="vdo-bar-fill" id="vdo-volts-fill" style="width: 82%"></div></div>
              </div>
              <div class="mini-vdo-gauge" title="Pressione Olio Motore">
                <div class="vdo-label">PRESS OLIO</div>
                <div class="vdo-val" id="vdo-oil">3.6 BAR</div>
                <div class="vdo-bar"><div class="vdo-bar-fill" id="vdo-oil-fill" style="width: 72%"></div></div>
              </div>
              <div class="mini-vdo-gauge vdo-surface-gauge" title="Stato Fondo Stradale e Temperatura Esterna">
                <div class="vdo-label">FONDO STRADALE</div>
                <div class="vdo-road-text" id="vdo-road-status" style="color: #22c55e;">ASFALTO 100%</div>
                <div class="vdo-ambient-temp" id="vdo-ext-temp">-12°C ARCTIC</div>
              </div>
            </div>
          </div>

          <!-- Dynamic Vehicle Cluster Main Row (Populated by setupVehicleDashboard) -->
          <div class="cluster-main-row" id="cluster-main-row">
            <!-- Will be dynamically injected by setupVehicleDashboard -->
          </div>

          <!-- Heavy Duty Cockpit Toggle Switch Deck -->
          <div class="heavy-switches-deck">
            <button class="cockpit-toggle-btn btn-engine" id="btn-ignition" title="Avvia/Spegni Motore">
              <div class="toggle-light-ring" id="led-ignition"></div>
              <span class="toggle-icon">⚡</span>
              <span class="toggle-title">ENGINE</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-lights" title="Fari Abbaglianti">
              <div class="toggle-light-ring on" id="led-lights"></div>
              <span class="toggle-icon">💡</span>
              <span class="toggle-title">LIGHTS</span>
            </button>

            <button class="cockpit-toggle-btn btn-mode-switch" id="btn-mode" title="Sali/Scendi dal Mezzo">
              <span class="toggle-icon" id="mode-icon">🚶</span>
              <span class="toggle-title" id="mode-text">DISMOUNT</span>
            </button>

            <button class="cockpit-toggle-btn btn-garage-switch" id="btn-garage" title="Garage & Parco Veicoli Classici">
              <span class="toggle-icon">🏎️</span>
              <span class="toggle-title">GARAGE</span>
            </button>

            <button class="cockpit-toggle-btn btn-repair-switch" id="btn-repair" title="Riparazione Guasti Sul Posto">
              <div class="toggle-light-ring" id="led-repair"></div>
              <span class="toggle-icon">🛠️</span>
              <span class="toggle-title" id="repair-text">REPAIR</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-inventory" title="Bagagliaio & Zaino">
              <span class="toggle-icon">🎒</span>
              <span class="toggle-title">CARGO</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-workshop" title="Officina Meccanica">
              <span class="toggle-icon">🔧</span>
              <span class="toggle-title">UPGRADE</span>
            </button>

            <button class="cockpit-toggle-btn" id="btn-atlas" title="Atlante del Meridiano & Log di Rotta">
              <span class="toggle-icon">🗺️</span>
              <span class="toggle-title">ATLAS</span>
            </button>

            <button class="cockpit-toggle-btn btn-diary-switch" id="btn-diary" title="Diario di Bordo & Missioni (Story)">
              <span class="toggle-icon">📖</span>
              <span class="toggle-title">STORY</span>
            </button>
          </div>
        </div>

        <!-- 3. Right Pod: Pedals & Transmission -->
        <div class="console-pod pod-right">
          <div class="pod-header">ACCELERATORE / FRENO</div>

          <div class="pod-aux-row">
            <div class="lighter-socket" title="Presa 12V Accendisigari"><div class="lighter-knob" id="lighter-knob">12V</div></div>
            <div class="glovebox-lock" title="Chiusura Vano Portaoggetti"><span class="lock-keyway"></span></div>
            <div class="gear-status-display" id="hud-gear-pedal-badge">DRIVE</div>
          </div>

          <div class="pedals-deck">
            <!-- Brake / Reverse Pedal -->
            <div class="cockpit-pedal pedal-brake" id="pedal-brake">
              <div class="pedal-ribs"></div>
              <span class="pedal-name">BRAKE / REV</span>
            </div>

            <!-- Throttle Pedal -->
            <div class="cockpit-pedal pedal-gas" id="pedal-gas">
              <div class="pedal-ribs"></div>
              <span class="pedal-name">THROTTLE</span>
            </div>
          </div>

          <!-- Handbrake Lever Bar -->
          <button class="handbrake-bar" id="btn-handbrake">
            <span class="hb-icon">🛑</span>
            <span class="hb-text">P - EMERGENCY PARK</span>
          </button>
        </div>
      </div>

      <!-- Scavenge / Proximity Action Floating Banner -->
      <div class="proximity-banner" id="proximity-banner" style="display: none;">
        <span class="banner-icon" id="prox-icon">⛽</span>
        <div class="banner-info">
          <div class="banner-title" id="prox-title">Stazione di Servizio</div>
          <div class="banner-subtitle">Avvicinati a piedi per recuperare rifornimenti</div>
        </div>
        <button class="banner-action-btn" id="btn-scavenge-action">ISPEZIONA</button>
      </div>

      <!-- Emergency Breakdown Diagnostic Alert Banner -->
      <div class="breakdown-alert-banner" id="breakdown-banner" style="display: none;">
        <div class="breakdown-icon-col">
          <span class="breakdown-pulsing-icon">⚠️</span>
        </div>
        <div class="breakdown-text-col">
          <div class="breakdown-title" id="breakdown-title">GUASTO CRITICO RILEVATO</div>
          <div class="breakdown-desc" id="breakdown-desc">Pneumatico squarciato. Sterzo compromesso.</div>
          <div class="breakdown-req" id="breakdown-req">Necessario: 1x Ruota di Scorta</div>
        </div>
        <div class="breakdown-action-col">
          <button class="breakdown-fix-btn" id="btn-breakdown-fix">RIPARA</button>
        </div>
      </div>

      <!-- Floating Incoming CB Radio Transmission Overlay -->
      <div class="cb-radio-dispatch-overlay" id="cb-radio-overlay" style="display: none;">
        <div class="cb-overlay-header">
          <div class="cb-live-indicator">
            <span class="cb-red-dot"></span>
            <span class="cb-rec-text">CB RX LIVE • 27.185 MHz</span>
          </div>
          <span class="cb-channel-badge">CH 19</span>
          <button class="cb-dismiss-btn" id="btn-dismiss-cb">✕ CHIUDI</button>
        </div>
        <div class="cb-overlay-body">
          <div class="cb-avatar-box" id="cb-avatar">🐻</div>
          <div class="cb-text-box">
            <div class="cb-speaker-line">
              <strong id="cb-speaker-name">SOFIA MARETTI (CAPO SPEDIZIONE)</strong>
              <span class="cb-callsign-tag" id="cb-callsign">TRANS-EARTH DISPATCH</span>
            </div>
            <p class="cb-message-text" id="cb-message">Messaggio in arrivo...</p>
          </div>
        </div>
      </div>

      <!-- Objective Completed Achievement Toast -->
      <div class="story-achievement-toast" id="story-toast" style="display: none;">
        <span class="toast-trophy">🏆</span>
        <div class="toast-body">
          <div class="toast-header">OBIETTIVO SPEDIZIONE COMPLETATO!</div>
          <div class="toast-desc" id="toast-desc">Descrizione obiettivo</div>
        </div>
      </div>
    `;

    this.container.appendChild(this.element);
    const initialConfig = (this.vehicle && this.vehicle.getCurrentModelConfig) ? this.vehicle.getCurrentModelConfig() : (typeof CONFIG !== 'undefined' ? CONFIG.VEHICLES_CATALOG.panda_4x4 : null);
    this.setupVehicleDashboard(initialConfig);
    this.bindEvents();
  }

  bindEvents() {
    // 1. Ignition toggle
    const btnIgnition = this.element.querySelector('#btn-ignition');
    btnIgnition.addEventListener('click', () => {
      this.vehicle.isEngineOn = !this.vehicle.isEngineOn;
      if (this.vehicle.isEngineOn) {
        this.audioEngine.startEngine();
      } else {
        this.audioEngine.stopEngine();
      }
      this.updateSwitchesVisuals();
    });
    if (this.touchInput) {
      this.touchInput.onToggleIgnition = () => btnIgnition.click();
    }

    // 2. Lights toggle
    const btnLights = this.element.querySelector('#btn-lights');
    btnLights.addEventListener('click', () => {
      this.vehicle.toggleLights();
      this.updateSwitchesVisuals();
    });

    // 3. Mode switch (Drive vs Foot)
    const btnMode = this.element.querySelector('#btn-mode');
    btnMode.addEventListener('click', () => {
      if (this.onToggleMode) this.onToggleMode();
    });

    // 4. Inventory button
    const btnInv = this.element.querySelector('#btn-inventory');
    btnInv.addEventListener('click', () => {
      if (this.onOpenInventory) this.onOpenInventory();
    });

    // 4b. Quick Repair & Breakdown Fix buttons
    const btnRepair = this.element.querySelector('#btn-repair');
    if (btnRepair) {
      btnRepair.addEventListener('click', () => {
        this.executeEmergencyRepair();
      });
    }

    const btnBreakdownFix = this.element.querySelector('#btn-breakdown-fix');
    if (btnBreakdownFix) {
      btnBreakdownFix.addEventListener('click', () => {
        this.executeEmergencyRepair();
      });
    }

    // 5. Workshop & Garage buttons
    const btnWorkshop = this.element.querySelector('#btn-workshop');
    btnWorkshop.addEventListener('click', () => {
      if (this.onOpenWorkshop) this.onOpenWorkshop('upgrades');
    });

    const btnGarage = this.element.querySelector('#btn-garage');
    if (btnGarage) {
      btnGarage.addEventListener('click', () => {
        if (this.onOpenGarage) this.onOpenGarage();
        else if (this.onOpenWorkshop) this.onOpenWorkshop('garage');
      });
    }

    // 5b. Atlas Route Log button
    const btnAtlas = this.element.querySelector('#btn-atlas');
    if (btnAtlas) {
      btnAtlas.addEventListener('click', () => {
        if (this.onOpenAtlas) this.onOpenAtlas();
      });
    }

    // 5c. Story Logbook & Objective Banner buttons
    const btnDiary = this.element.querySelector('#btn-diary');
    if (btnDiary) {
      btnDiary.addEventListener('click', () => {
        if (this.onOpenStoryDiary) this.onOpenStoryDiary();
      });
    }

    const storyBanner = this.element.querySelector('#story-objective-banner');
    if (storyBanner) {
      storyBanner.addEventListener('click', () => {
        if (this.onOpenStoryDiary) this.onOpenStoryDiary();
      });
    }

    const btnDismissCb = this.element.querySelector('#btn-dismiss-cb');
    if (btnDismissCb) {
      btnDismissCb.addEventListener('click', () => {
        const overlay = this.element.querySelector('#cb-radio-overlay');
        if (overlay) overlay.style.display = 'none';
        if (this.storyDirector) this.storyDirector.dismissRadioMessage();
      });
    }

    // 6. Proximity scavenge action
    const btnScavenge = this.element.querySelector('#btn-scavenge-action');
    btnScavenge.addEventListener('click', () => {
      if (this.onScavenge) this.onScavenge();
    });

    // 7. Touch Steer Track & Wheel Rotation
    const track = this.element.querySelector('#steering-track');
    const knob = this.element.querySelector('#steering-knob');
    const wheel = this.element.querySelector('#steering-wheel');
    let isSteering = false;

    const handleSteerMove = (clientX) => {
      const rect = track.getBoundingClientRect();
      const relX = clientX - rect.left;
      const normalized = (relX / rect.width) * 2 - 1;
      const clamped = Math.max(-1, Math.min(1, normalized));
      this.touchInput.setTouchSteer(clamped, true);
      knob.style.transform = `translateX(${clamped * (rect.width * 0.42)}px)`;
      if (wheel) {
        wheel.style.transform = `rotate(${clamped * 65}deg)`;
      }
    };

    track.addEventListener('pointerdown', (e) => {
      isSteering = true;
      track.setPointerCapture(e.pointerId);
      handleSteerMove(e.clientX);
    });

    track.addEventListener('pointermove', (e) => {
      if (isSteering) handleSteerMove(e.clientX);
    });

    const resetSteer = (e) => {
      isSteering = false;
      this.touchInput.setTouchSteer(0, false);
      knob.style.transform = `translateX(0px)`;
      if (wheel) wheel.style.transform = `rotate(0deg)`;
      if (e && e.pointerId && track.hasPointerCapture && track.hasPointerCapture(e.pointerId)) {
        track.releasePointerCapture(e.pointerId);
      }
    };
    track.addEventListener('pointerup', resetSteer);
    track.addEventListener('pointercancel', resetSteer);

    // 7b. Steering Wheel Center Hub (Horn / Clacson)
    const wheelHub = this.element.querySelector('#wheel-hub') || this.element.querySelector('.wheel-hub');
    if (wheelHub) {
      wheelHub.style.cursor = 'pointer';
      wheelHub.addEventListener('pointerdown', (e) => {
        e.stopPropagation();
        if (this.vehicle && this.vehicle.honkHorn) {
          this.vehicle.honkHorn();
        }
        wheelHub.classList.add('hub-pressed');
        setTimeout(() => wheelHub.classList.remove('hub-pressed'), 350);
      });
    }

    // 8. Throttle Pedal
    const pedalGas = this.element.querySelector('#pedal-gas');
    pedalGas.addEventListener('pointerdown', (e) => {
      pedalGas.classList.add('pressed');
      this.touchInput.setTouchThrottle(1.0, true);
      if (e.pointerId && pedalGas.setPointerCapture) pedalGas.setPointerCapture(e.pointerId);
    });
    const releaseGas = (e) => {
      pedalGas.classList.remove('pressed');
      this.touchInput.setTouchThrottle(0.0, false);
      if (e && e.pointerId && pedalGas.hasPointerCapture && pedalGas.hasPointerCapture(e.pointerId)) {
        pedalGas.releasePointerCapture(e.pointerId);
      }
    };
    pedalGas.addEventListener('pointerup', releaseGas);
    pedalGas.addEventListener('pointercancel', releaseGas);
    pedalGas.addEventListener('pointerleave', releaseGas);

    // 9. Brake Pedal
    const pedalBrake = this.element.querySelector('#pedal-brake');
    pedalBrake.addEventListener('pointerdown', (e) => {
      pedalBrake.classList.add('pressed');
      this.touchInput.setTouchBrake(1.0, true);
      if (e.pointerId && pedalBrake.setPointerCapture) pedalBrake.setPointerCapture(e.pointerId);
    });
    const releaseBrake = (e) => {
      pedalBrake.classList.remove('pressed');
      this.touchInput.setTouchBrake(0.0, false);
      if (e && e.pointerId && pedalBrake.hasPointerCapture && pedalBrake.hasPointerCapture(e.pointerId)) {
        pedalBrake.releasePointerCapture(e.pointerId);
      }
    };
    pedalBrake.addEventListener('pointerup', releaseBrake);
    pedalBrake.addEventListener('pointercancel', releaseBrake);
    pedalBrake.addEventListener('pointerleave', releaseBrake);

    // 10. Handbrake
    const btnHb = this.element.querySelector('#btn-handbrake');
    btnHb.addEventListener('pointerdown', () => {
      btnHb.classList.add('active');
      this.touchInput.setTouchHandbrake(true);
    });
    const releaseHb = () => {
      btnHb.classList.remove('active');
      this.touchInput.setTouchHandbrake(false);
    };
    btnHb.addEventListener('pointerup', releaseHb);
    btnHb.addEventListener('pointercancel', releaseHb);

    // 11. Hazard Light Toggle (4 Frecce)
    const btnHazard = this.element.querySelector('#btn-hazard');
    if (btnHazard) {
      btnHazard.addEventListener('click', () => {
        this.hazardActive = !this.hazardActive;
        btnHazard.classList.toggle('active', this.hazardActive);
        if (this.audioEngine && this.audioEngine.playSwitchClick) {
          this.audioEngine.playSwitchClick(this.hazardActive);
        }
      });
    }

    // 12. 12V Cigarette Lighter
    const lighterKnob = this.element.querySelector('#lighter-knob');
    if (lighterKnob) {
      lighterKnob.addEventListener('click', () => {
        lighterKnob.classList.add('pushed');
        if (this.audioEngine && this.audioEngine.playSwitchClick) {
          this.audioEngine.playSwitchClick(true);
        }
        setTimeout(() => {
          lighterKnob.classList.remove('pushed');
          if (this.audioEngine && this.audioEngine.playSwitchClick) {
            this.audioEngine.playSwitchClick(false);
          }
        }, 3000);
      });
    }

    // 13. Blower Fan Speed Selector
    const fanKnob = this.element.querySelector('#fan-knob');
    if (fanKnob) {
      const speeds = ['OFF', 'FAN I', 'FAN II', 'FAN III', 'FAN IV'];
      let speedIdx = 2;
      fanKnob.addEventListener('click', () => {
        speedIdx = (speedIdx + 1) % speeds.length;
        fanKnob.textContent = speeds[speedIdx];
        if (this.audioEngine && this.audioEngine.playSwitchClick) {
          this.audioEngine.playSwitchClick(speedIdx > 0);
        }
      });
    }
  }

  updateSwitchesVisuals() {
    const ledIgnition = this.element.querySelector('#led-ignition');
    const ledLights = this.element.querySelector('#led-lights');

    if (ledIgnition) {
      ledIgnition.className = `toggle-light-ring ${this.vehicle.isEngineOn ? 'on active-engine' : ''}`;
    }
    if (ledLights) {
      ledLights.className = `toggle-light-ring ${this.vehicle.isLightsOn ? 'on' : ''}`;
    }
  }

  setModeVisual(isOnFoot) {
    const modeIcon = this.element.querySelector('#mode-icon');
    const modeText = this.element.querySelector('#mode-text');
    if (isOnFoot) {
      modeIcon.textContent = '🚗';
      modeText.textContent = 'ENTER CAR';
    } else {
      modeIcon.textContent = '🚶';
      modeText.textContent = 'DISMOUNT';
    }
  }

  showNearbyPOI(poi) {
    const banner = this.element.querySelector('#proximity-banner');
    if (!poi || poi.scavenged) {
      banner.style.display = 'none';
      return;
    }
    banner.style.display = 'flex';
    this.element.querySelector('#prox-icon').textContent = poi.config.icon || (poi.isSettlement ? '🏛️' : '📍');
    this.element.querySelector('#prox-title').textContent = poi.config.name;

    const sub = this.element.querySelector('.banner-subtitle');
    const actBtn = this.element.querySelector('#btn-scavenge-action');
    if (poi.isSettlement) {
      if (sub) sub.textContent = 'COMUNITÀ POPOLATA — COMMERCIO, STORIA & RIFORNIMENTI';
      if (actBtn) actBtn.textContent = 'ACCEDI ALL\'HUB';
      banner.className = 'proximity-banner settlement-banner-active';
    } else {
      if (sub) sub.textContent = 'SITO STRUTTURALE — RECUPERA MATERIALI E RISORSE';
      if (actBtn) actBtn.textContent = 'ISPEZIONA';
      banner.className = 'proximity-banner';
    }
  }

  setupVehicleDashboard(cur) {
    if (!cur) return;
    this.currentModelId = cur.id;

    // 1. Remove previous dash themes and apply current car theme
    this.element.className = this.element.className.replace(/\bdash-theme-\S+/g, '').trim();
    this.element.classList.add(`dash-theme-${cur.id}`);

    // 2. Custom Steering Wheel per manufacturer & model
    const wheelRim = this.element.querySelector('#steering-wheel .wheel-rim');
    const hubLogo = this.element.querySelector('#steering-wheel .hub-logo');
    if (wheelRim) {
      wheelRim.classList.remove('wheel-alfa', 'wheel-delta', 'wheel-bmw', 'wheel-mercedes');
      if (cur.id === 'alfa_giulia') wheelRim.classList.add('wheel-alfa');
      else if (cur.id === 'delta_integrale') wheelRim.classList.add('wheel-delta');
      else if (cur.id === 'bmw_e30_ix') wheelRim.classList.add('wheel-bmw');
      else if (cur.id.startsWith('mercedes')) wheelRim.classList.add('wheel-mercedes');
    }
    if (hubLogo) {
      if (cur.id === 'alfa_giulia') hubLogo.textContent = 'ALFA';
      else if (cur.id === 'delta_integrale') hubLogo.textContent = 'HF';
      else if (cur.id === 'bmw_e30_ix') hubLogo.textContent = '///M';
      else if (cur.id.startsWith('mercedes')) hubLogo.textContent = 'BENZ';
      else if (cur.id === 'volvo_245') hubLogo.textContent = 'VOLVO';
      else if (cur.id === 'defender_110') hubLogo.textContent = 'LAND';
      else if (cur.id === 'audi_quattro') hubLogo.textContent = 'QUATTRO';
      else if (cur.id === 'peugeot_504_dangel') hubLogo.textContent = 'DANGEL';
      else if (cur.id === 'golf_country') hubLogo.textContent = 'SYNCRO';
      else hubLogo.textContent = 'FIAT';
    }

    // 3. Cluster Headers
    const brandEl = this.element.querySelector('#hud-cluster-brand');
    if (brandEl) brandEl.textContent = `${cur.dashTheme.clusterName} — ${cur.maker.toUpperCase()} ${cur.name.toUpperCase()}`;
    const driveEl = this.element.querySelector('#hud-drivetrain-badge');
    if (driveEl) driveEl.textContent = cur.drivetrainBadge;

    // 4. Construct cluster row HTML
    const clusterRow = this.element.querySelector('#cluster-main-row');
    if (!clusterRow) return;

    const maxSpeed = cur.dashTheme.speedoMax || 160;
    const speedTicksSvg = this.generateSpeedoTicks(maxSpeed, cur.dashTheme.tickColor || '#94a3b8');

    // 1. Dial 1: Speedometer (KM/H)
    const speedoHtml = `
      <div class="dial-housing" title="Tachimetro Stradale (KM/H)">
        <div class="gauge-dial">
          <svg class="gauge-svg" viewBox="0 0 120 120">
            <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
            <circle cx="60" cy="60" r="48" class="dial-track-groove" />
            ${speedTicksSvg}
            <line id="speed-needle" class="gauge-needle" x1="60" y1="60" x2="60" y2="22" stroke="${cur.dashTheme.needleColor || '#ef4444'}" />
            <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
            <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
          </svg>
          <div class="dial-digital-box">
            <span class="dial-val" id="dial-speed-val">0</span>
            <span class="dial-unit">KM/H</span>
          </div>
        </div>
      </div>
    `;

    // 2. Dial 2: Tachometer / Contagiri Motore (RPM x1000)
    const redline = cur.dashTheme.redlineRpm || 6000;
    const maxRpm = Math.ceil(redline / 1000) * 1000 + 1000;
    const tachTicksSvg = this.generateTachTicks(redline, maxRpm, cur.dashTheme.tickColor || '#94a3b8');
    const tachHtml = `
      <div class="dial-housing" title="Contagiri Motore (RPM x1000)">
        <div class="gauge-dial">
          <svg class="gauge-svg" viewBox="0 0 120 120">
            <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
            <circle cx="60" cy="60" r="48" class="dial-track-groove" />
            ${tachTicksSvg}
            <line id="rpm-needle" class="gauge-needle" x1="60" y1="60" x2="60" y2="22" stroke="${cur.dashTheme.needleColor || '#ef4444'}" />
            <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
            <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
          </svg>
          <div class="dial-digital-box">
            <span class="dial-val" id="dial-rpm-val">0.8</span>
            <span class="dial-unit">RPM x1000</span>
          </div>
        </div>
      </div>
    `;

    // 3. Center MFD with Vitals, Annunciators, and Model-Specific Aux Instrument
    const auxInstrumentHtml = this.generateCustomAuxWidgetHtml(cur);

    const mfdHtml = `
      <div class="mfd-screen">
        <div class="mfd-vitals-stack">
          <div class="mfd-row">
            <span class="mfd-icon">⛽</span>
            <span class="mfd-label">FUEL</span>
            <div class="mfd-bar-track">
              <div class="mfd-bar-fill fuel-bar" id="hud-fuel-fill" style="width: 100%"></div>
            </div>
            <span class="mfd-val" id="hud-fuel-num">--L</span>
          </div>
          <div class="mfd-row">
            <span class="mfd-icon">🛡️</span>
            <span class="mfd-label">HULL</span>
            <div class="mfd-bar-track">
              <div class="mfd-bar-fill hull-bar" id="hud-hull-fill" style="width: 100%"></div>
            </div>
            <span class="mfd-val" id="hud-hull-num">100%</span>
          </div>
          <div class="mfd-row">
            <span class="mfd-icon">🌡️</span>
            <span class="mfd-label">COOLANT</span>
            <div class="mfd-bar-track">
              <div class="mfd-bar-fill temp-bar" id="hud-temp-fill" style="width: 40%"></div>
            </div>
            <span class="mfd-val" id="hud-temp-num">80°C</span>
          </div>
        </div>

        <div class="annunciator-panel">
          <div class="ann-lamp" id="lamp-tire"><span class="ann-dot"></span> TIRE</div>
          <div class="ann-lamp" id="lamp-leak"><span class="ann-dot"></span> RAD</div>
          <div class="ann-lamp" id="lamp-elec"><span class="ann-dot"></span> ELEC</div>
          <div class="ann-lamp" id="lamp-fuel"><span class="ann-dot"></span> PUMP</div>
          <div class="ann-lamp ann-glow" id="lamp-glow" style="${cur.isDiesel ? '' : 'display: none;'}"><span class="ann-dot"></span> GLOW</div>
        </div>

        <div class="survivor-pills-row">
          <div class="pill-box"><span class="pill-title">HP</span><strong id="hud-hp">100</strong></div>
          <div class="pill-box"><span class="pill-title">HUNGER</span><strong id="hud-hunger">100%</strong></div>
          <div class="pill-box"><span class="pill-title">THIRST</span><strong id="hud-thirst">100%</strong></div>
          <div class="pill-box"><span class="pill-title">BODY</span><strong id="hud-temp">37.0°C</strong></div>
        </div>

        <!-- Live Terrain & Surface Telemetry Bar -->
        <div class="terrain-radar-strip" id="hud-terrain-strip">
          <span class="terrain-icon" id="hud-terrain-icon">🛣️</span>
          <span class="terrain-text" id="hud-terrain-text">ASFALTO (CARREGGIATA)</span>
          <span class="terrain-badge" id="hud-terrain-badge" style="background: rgba(34, 197, 94, 0.2); color: #22c55e;">GRIP 100%</span>
        </div>

        <!-- Dedicated Vehicle-Specific Instrument Console -->
        ${auxInstrumentHtml}
      </div>
    `;

    // 4. Dial 4: Clinometro 4x4 Inclinometro Off-Road (Pendenza & Rollio)
    const inclinometerHtml = `
      <div class="dial-housing" title="Clinometro & Inclinometro 4x4 (Pendenza Salita/Discesa e Rollio Laterale)">
        <div class="gauge-dial">
          <svg class="gauge-svg" viewBox="0 0 120 120">
            <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
            <circle cx="60" cy="60" r="48" class="dial-track-groove" />
            <!-- Pitch scale lines -->
            <line x1="28" y1="46" x2="42" y2="46" stroke="#64748b" stroke-width="1.8" />
            <line x1="78" y1="46" x2="92" y2="46" stroke="#64748b" stroke-width="1.8" />
            <line x1="24" y1="60" x2="44" y2="60" stroke="#38bdf8" stroke-width="2.4" />
            <line x1="76" y1="60" x2="96" y2="60" stroke="#38bdf8" stroke-width="2.4" />
            <line x1="28" y1="74" x2="42" y2="74" stroke="#64748b" stroke-width="1.8" />
            <line x1="78" y1="74" x2="92" y2="74" stroke="#64748b" stroke-width="1.8" />
            <g id="incline-horizon-group" transform="translate(60,60)">
              <line id="incline-horizon-line" x1="-32" y1="0" x2="32" y2="0" stroke="#fbbf24" stroke-width="2.5" />
              <polygon points="0,-4 -4,4 4,4" fill="#ef4444" />
            </g>
            <circle cx="60" cy="60" r="14" fill="none" stroke="#475569" stroke-width="1.5" stroke-dasharray="3,2" />
            <!-- 4x4 Vehicle Center Indicator -->
            <rect x="52" y="58" width="16" height="5" rx="1.5" fill="#94a3b8" />
            <circle cx="54" cy="63" r="1.8" fill="#38bdf8" />
            <circle cx="66" cy="63" r="1.8" fill="#38bdf8" />
            <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
          </svg>
          <div class="dial-digital-box" style="margin-top: 40px;">
            <span class="dial-val" id="dial-incline-val" style="font-size: 14px; color: #fbbf24; font-family: var(--font-tech);">0°</span>
            <span class="dial-unit" style="font-size: 9px; letter-spacing: 0.5px;">CLINOMETRO</span>
          </div>
        </div>
      </div>
    `;

    // 5. Dial 5: Veglia Borletti Quartz Clock or Turbo/Econometer
    let rightDialHtml = '';
    if (cur.id === 'panda_4x4') {
      const clockTicksSvg = this.generateClockTicks();
      rightDialHtml = `
        <div class="dial-housing" title="Orologio Analogico Veglia Borletti Quartz">
          <div class="gauge-dial">
            <svg class="gauge-svg" viewBox="0 0 120 120">
              <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
              <circle cx="60" cy="60" r="48" class="dial-track-groove" />
              ${clockTicksSvg}
              <line id="clock-hour-needle" class="gauge-needle clock-needle-hour" x1="60" y1="60" x2="60" y2="34" />
              <line id="clock-min-needle" class="gauge-needle clock-needle-min" x1="60" y1="60" x2="60" y2="20" />
              <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
              <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
            </svg>
            <div class="dial-digital-box">
              <span class="dial-val" id="dial-clock-val" style="font-size:12px;letter-spacing:1px;color:#38bdf8;">VEGLIA</span>
              <span class="dial-unit">QUARTZ</span>
            </div>
          </div>
        </div>
      `;
    } else {
      let subGaugeHtml = '';
      if (cur.hasTurbo) {
        const maxBoost = cur.turboBoostMaxBar || 1.5;
        const turboTicksSvg = this.generateTurboTicks(maxBoost);
        subGaugeHtml = `
          <div class="turbo-mini-gauge" id="turbo-dial-housing" title="Manometro Sovralimentazione Turbo (Bar)">
            <svg class="gauge-svg" viewBox="0 0 120 120">
              <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="#080b0e" />
              ${turboTicksSvg}
              <line id="turbo-needle" class="gauge-needle" x1="60" y1="60" x2="60" y2="24" stroke="${cur.dashTheme.needleColor || '#ef4444'}" />
              <circle cx="60" cy="60" r="6" class="gauge-center-bezel" />
            </svg>
            <span class="turbo-mini-val" id="dial-turbo-val">0.0</span>
            <span class="turbo-mini-unit">BAR</span>
          </div>
        `;
      }
      const clockTicksSvg = this.generateClockTicks();
      rightDialHtml = `
        <div style="display:flex;flex-direction:column;align-items:center;">
          <div class="dial-housing" title="Orologio di Bordo">
            <div class="gauge-dial">
              <svg class="gauge-svg" viewBox="0 0 120 120">
                <circle cx="60" cy="60" r="54" class="dial-bg-plate" fill="${cur.dashTheme.dialBg || '#10141a'}" />
                <circle cx="60" cy="60" r="48" class="dial-track-groove" />
                ${clockTicksSvg}
                <line id="clock-hour-needle" class="gauge-needle clock-needle-hour" x1="60" y1="60" x2="60" y2="34" />
                <line id="clock-min-needle" class="gauge-needle clock-needle-min" x1="60" y1="60" x2="60" y2="20" />
                <circle cx="60" cy="60" r="7" class="gauge-center-bezel" />
                <circle cx="60" cy="60" r="3" class="gauge-center-screw" />
              </svg>
              <div class="dial-digital-box">
                <span class="dial-val" id="dial-clock-val" style="font-size:12px;letter-spacing:1px;color:#38bdf8;">TIME</span>
                <span class="dial-unit">CHRONO</span>
              </div>
            </div>
          </div>
          ${subGaugeHtml}
        </div>
      `;
    }

    // Symmetric 5-Element Center Binnacle: Speedo | Tach | MFD | Clinometer | Clock/Turbo
    clusterRow.innerHTML = speedoHtml + tachHtml + mfdHtml + inclinometerHtml + rightDialHtml;

    // Interactive Model Controls (Steyr 4WD Lever, Primina, etc.)
    const steyrConsole = this.element.querySelector('.steyr-lever-console');
    if (steyrConsole) {
      steyrConsole.style.cursor = 'pointer';
      steyrConsole.title = 'Leva Trazione Steyr-Puch: Clicca per inserire/disinserire 4WD (Tasto X)';
      steyrConsole.onclick = () => {
        if (this.vehicle && this.vehicle.toggle4WD) {
          const res = this.vehicle.toggle4WD();
          if (res) this.showToast(res.message);
        }
      };
    }
    const priminaLamp = this.element.querySelector('#lamp-primina');
    if (priminaLamp) {
      priminaLamp.style.cursor = 'pointer';
      priminaLamp.title = 'Primina Ridotta: Clicca per inserire/disinserire marcia ridotta (Tasto P)';
      priminaLamp.onclick = () => {
        if (this.vehicle && this.vehicle.togglePrimina) {
          const res = this.vehicle.togglePrimina();
          if (res) this.showToast(res.message);
        }
      };
    }
  }

  generateCustomAuxWidgetHtml(cur) {
    switch (cur.id) {
      case 'panda_4x4':
        return `
          <div class="steyr-lever-console">
            <div class="steyr-lever-graphic">
              <div class="steyr-boot"><div class="steyr-knob" id="steyr-knob-pos"></div></div>
              <span style="font-size:8px;font-family:var(--font-tech);color:#94a3b8;">STEYR-PUCH</span>
            </div>
            <div class="steyr-indicators">
              <div class="steyr-lamp active-steyr" id="lamp-4wd-steyr"><span class="ann-dot" style="background:#22c55e;"></span> 4WD INSERITA</div>
              <div class="steyr-lamp" id="lamp-primina"><span class="ann-dot" style="background:#eab308;"></span> PRIMINA CRAWLER</div>
            </div>
          </div>
        `;
      case 'delta_integrale':
        return `
          <div class="torsen-split-widget">
            <div class="torsen-header"><span>TORSEN AWD RIPARTIZIONE</span><span id="torsen-split-text">47% ANT / 53% POST</span></div>
            <div class="torsen-bar-housing"><div class="torsen-front-fill" id="torsen-front-bar" style="width:47%;"></div><div class="torsen-rear-fill"></div><div class="torsen-center-mark"></div></div>
          </div>
        `;
      case 'mercedes_w123':
        return `
          <div class="bosch-glow-widget">
            <div class="glow-coil-graphic" id="bosch-coil-box"><div class="glow-coil-filament"></div></div>
            <div style="font-family:var(--font-tech);font-size:8px;color:#fdba74;">BOSCH GLÜHZEIT<br><strong id="bosch-glow-status" style="color:#f97316;">VORGELÜHT</strong></div>
            <div style="font-family:var(--font-tech);font-size:8px;color:#cbd5e1;text-align:right;">ÖLDRUCK<br><strong id="w123-oil-val" style="font-size:11px;color:#fb923c;">3.0 BAR</strong></div>
          </div>
        `;
      case 'mercedes_gwagen':
        return `
          <div class="gwagen-diff-locks">
            <div class="diff-lock-lever diff-lock-engaged"><span style="color:#ef4444;">REAR</span><div class="diff-switch-body"><div class="diff-switch-toggle"></div></div><div class="diff-lock-led"></div></div>
            <div class="diff-lock-lever diff-lock-engaged"><span style="color:#ef4444;">CENTER</span><div class="diff-switch-body"><div class="diff-switch-toggle"></div></div><div class="diff-lock-led"></div></div>
            <div class="diff-lock-lever"><span style="color:#94a3b8;">FRONT</span><div class="diff-switch-body"><div class="diff-switch-toggle"></div></div><div class="diff-lock-led"></div></div>
          </div>
          <div class="inclinometer-widget">
            <div class="incline-dial"><div class="incline-horizon" id="incline-horizon-bar"></div><div class="incline-car-silhouette"></div></div>
            <div class="incline-values"><span>ROLL: <strong id="incline-roll-val">0.0°</strong></span><span>PITCH: <strong id="incline-pitch-val">0.0°</strong></span></div>
          </div>
        `;
      case 'defender_110':
        return `
          <div class="defender-volts-widget">
            <span class="volts-label">SMITHS DUAL BATTERY / WINCH</span>
            <span class="volts-val" id="defender-volts-num">14.2 V</span>
          </div>
          <div class="lt230-transfer-schematic">
            <span class="lt230-chip active-hi">HIGH RATIO</span>
            <span class="lt230-chip active-lock">DIFF-LOCK ENGAGED</span>
          </div>
        `;
      case 'volvo_245':
        return `
          <div class="volvo-safety-widget">
            <div class="volvo-lamp-chip active-lambda" id="volvo-lambda"><span class="ann-dot" style="background:#f59e0b;"></span> LAMBDASOND (λ)</div>
            <div class="volvo-lamp-chip" id="volvo-frost"><span class="ann-dot" style="background:#38bdf8;"></span> FROST ALERT ❄️</div>
          </div>
        `;
      case 'audi_quattro':
        return `
          <div class="quattro-schematic-widget">
            <svg class="quattro-chassis-svg" viewBox="0 0 50 30"><rect x="5" y="4" width="8" height="6" fill="#38bdf8"/><rect x="37" y="4" width="8" height="6" fill="#38bdf8"/><rect x="5" y="20" width="8" height="6" fill="#ef4444"/><rect x="37" y="20" width="8" height="6" fill="#ef4444"/><line x1="25" y1="7" x2="25" y2="23" stroke="#e2e8f0" stroke-width="2"/><circle cx="25" cy="15" r="4" fill="#ef4444"/></svg>
            <div class="quattro-status-text">QUATTRO PERMANENT AWD<br><strong style="color:#ef4444;">TORQUE SENSING ACTIVE</strong></div>
          </div>
        `;
      case 'bmw_e30_ix':
        return `
          <div class="bmw-si-widget">
            <span class="si-title">SI-BOARD</span>
            <div class="si-leds-track" id="bmw-si-leds">
              <div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led green lit"></div><div class="si-led yellow"></div><div class="si-led red"></div>
            </div>
            <span style="font-size:7px;color:#94a3b8;">SERVICE</span>
          </div>
        `;
      case 'alfa_giulia':
        return `
          <div class="alfa-vintage-aux-widget">
            <div><span class="alfa-oil-label">PRESSIONE OLIO (KG/CM²)</span><br><span class="alfa-oil-num" id="alfa-oil-val">4.5</span></div>
            <div class="alfa-choke-knob"><div class="choke-handle"></div><span>STARTER (ARIA)</span></div>
          </div>
        `;
      case 'peugeot_504_dangel':
        return `
          <div class="safari-compass-widget">
            <div class="compass-rose" id="safari-compass-rose"><div class="compass-needle"></div><span style="font-size:6px;position:absolute;top:1px;color:#ef4444;font-weight:bold;">N</span></div>
            <div style="display:flex;flex-direction:column;gap:1px;"><span style="font-size:7px;color:#94a3b8;">RORETTE EXPEDITION</span><span class="compass-cardinal" id="compass-heading-text">N 012°</span></div>
          </div>
        `;
      case 'golf_country':
      default:
        return `
          <div class="golf-syncro-widget">
            <div class="syncro-slip-lamp" id="golf-syncro-slip"><span class="ann-dot" style="background:#4ade80;"></span> SYNCRO VISCOUS AWD</div>
            <div class="golf-bullbar-toggle"><div class="bullbar-led"></div><span>HELLA RALLYE</span></div>
          </div>
        `;
    }
  }

  generateSpeedoTicks(maxSpeed, tickColor) {
    let svg = '';
    const step = maxSpeed >= 240 ? 40 : 20;
    const numSteps = Math.floor(maxSpeed / step);
    for (let i = 0; i <= numSteps; i++) {
      const spd = i * step;
      const pct = spd / maxSpeed;
      const angleDeg = -135 + pct * 270;
      const rad = (angleDeg * Math.PI) / 180;
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + 40 * Math.sin(rad)).toFixed(1);
      const y2 = (60 - 40 * Math.cos(rad)).toFixed(1);
      const tx = (60 + 30 * Math.sin(rad)).toFixed(1);
      const ty = (60 - 30 * Math.cos(rad) + 3.5).toFixed(1);
      svg += `<line class="tick major" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${tickColor}" stroke-width="2.2" />`;
      svg += `<text x="${tx}" y="${ty}" font-family="monospace" font-size="9" fill="${tickColor}" text-anchor="middle" font-weight="900">${spd}</text>`;
      if (i < numSteps) {
        const halfPct = (spd + step / 2) / maxSpeed;
        const halfAngle = -135 + halfPct * 270;
        const halfRad = (halfAngle * Math.PI) / 180;
        const mx1 = (60 + 48 * Math.sin(halfRad)).toFixed(1);
        const my1 = (60 - 48 * Math.cos(halfRad)).toFixed(1);
        const mx2 = (60 + 44 * Math.sin(halfRad)).toFixed(1);
        const my2 = (60 - 44 * Math.cos(halfRad)).toFixed(1);
        svg += `<line class="tick minor" x1="${mx1}" y1="${my1}" x2="${mx2}" y2="${my2}" stroke="${tickColor}" stroke-width="1.2" opacity="0.65" />`;
      }
    }
    return svg;
  }

  generateTachTicks(redlineRpm, maxRpm, tickColor) {
    let svg = '';
    const maxK = Math.floor(maxRpm / 1000);
    const redlineK = redlineRpm / 1000;
    for (let k = 0; k <= maxK; k++) {
      const pct = (k * 1000) / maxRpm;
      const angleDeg = -135 + pct * 270;
      const rad = (angleDeg * Math.PI) / 180;
      const isRedline = k >= redlineK;
      const col = isRedline ? '#ef4444' : tickColor;
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + 40 * Math.sin(rad)).toFixed(1);
      const y2 = (60 - 40 * Math.cos(rad)).toFixed(1);
      const tx = (60 + 30 * Math.sin(rad)).toFixed(1);
      const ty = (60 - 30 * Math.cos(rad) + 3.5).toFixed(1);
      svg += `<line class="tick ${isRedline ? 'redline' : 'major'}" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${col}" stroke-width="2.4" />`;
      svg += `<text x="${tx}" y="${ty}" font-family="monospace" font-size="9.5" fill="${col}" text-anchor="middle" font-weight="900">${k}</text>`;
      if (k < maxK) {
        const halfPct = ((k + 0.5) * 1000) / maxRpm;
        const halfAngle = -135 + halfPct * 270;
        const halfRad = (halfAngle * Math.PI) / 180;
        const isHalfRed = (k + 0.5) >= redlineK;
        const hCol = isHalfRed ? '#ef4444' : tickColor;
        const mx1 = (60 + 48 * Math.sin(halfRad)).toFixed(1);
        const my1 = (60 - 48 * Math.cos(halfRad)).toFixed(1);
        const mx2 = (60 + 44 * Math.sin(halfRad)).toFixed(1);
        const my2 = (60 - 44 * Math.cos(halfRad)).toFixed(1);
        svg += `<line class="tick minor" x1="${mx1}" y1="${my1}" x2="${mx2}" y2="${my2}" stroke="${hCol}" stroke-width="1.3" opacity="0.65" />`;
      }
    }
    return svg;
  }

  generateClockTicks() {
    let svg = '';
    for (let h = 1; h <= 12; h++) {
      const angleDeg = h * 30;
      const rad = (angleDeg * Math.PI) / 180;
      const isMajor = (h % 3 === 0);
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + (isMajor ? 38 : 43) * Math.sin(rad)).toFixed(1);
      const y2 = (60 - (isMajor ? 38 : 43) * Math.cos(rad)).toFixed(1);
      svg += `<line class="tick major" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="#cbd5e1" stroke-width="${isMajor ? 2.5 : 1.5}" />`;
      if (isMajor) {
        const tx = (60 + 28 * Math.sin(rad)).toFixed(1);
        const ty = (60 - 28 * Math.cos(rad) + 3.5).toFixed(1);
        svg += `<text x="${tx}" y="${ty}" font-family="sans-serif" font-size="10" fill="#e2e8f0" text-anchor="middle" font-weight="900">${h}</text>`;
      }
    }
    return svg;
  }

  generateTurboTicks(maxBoost) {
    let svg = '';
    const steps = [0, 0.5, 1.0, 1.5, 2.0].filter(v => v <= maxBoost + 0.1);
    steps.forEach(b => {
      const pct = Math.min(1.0, b / maxBoost);
      const angleDeg = -135 + pct * 270;
      const rad = (angleDeg * Math.PI) / 180;
      const x1 = (60 + 48 * Math.sin(rad)).toFixed(1);
      const y1 = (60 - 48 * Math.cos(rad)).toFixed(1);
      const x2 = (60 + 40 * Math.sin(rad)).toFixed(1);
      const y2 = (60 - 40 * Math.cos(rad)).toFixed(1);
      const tx = (60 + 30 * Math.sin(rad)).toFixed(1);
      const ty = (60 - 30 * Math.cos(rad) + 3.5).toFixed(1);
      const col = b > 1.2 ? '#ef4444' : '#eab308';
      svg += `<line class="tick" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${col}" stroke-width="2" />`;
      svg += `<text x="${tx}" y="${ty}" font-family="monospace" font-size="9" fill="${col}" text-anchor="middle" font-weight="900">${b.toFixed(1)}</text>`;
    });
    return svg;
  }

  update(currentBiome, activePOI, weatherDirector = null) {
    // Header telemetry
    const biomeEl = this.element.querySelector('#hud-biome-name');
    if (biomeEl && currentBiome) biomeEl.textContent = currentBiome.name.toUpperCase();
    const km = (this.survivalState.distanceTraveledMeters / 1000).toFixed(1);
    const odoEl = this.element.querySelector('#hud-odometer');
    if (odoEl) odoEl.textContent = km.padStart(6, '0');

    const hrs = Math.floor(this.survivalState.timeOfDay).toString().padStart(2, '0');
    const mins = Math.floor((this.survivalState.timeOfDay % 1) * 60).toString().padStart(2, '0');
    const timeEl = this.element.querySelector('#hud-time');
    if (timeEl) timeEl.textContent = `${hrs}:${mins}`;

    // Turn signal flashers & Hazard simulation
    const blinkPhase = Math.floor(Date.now() / 320) % 2 === 0;
    const isSteerL = (this.vehicle && this.vehicle.steerAngle > 0.035) || this.hazardActive;
    const isSteerR = (this.vehicle && this.vehicle.steerAngle < -0.035) || this.hazardActive;
    const blinkerL = this.element.querySelector('#blinker-l');
    const blinkerR = this.element.querySelector('#blinker-r');
    if (blinkerL) blinkerL.classList.toggle('active', !!(isSteerL && blinkPhase));
    if (blinkerR) blinkerR.classList.toggle('active', !!(isSteerR && blinkPhase));

    // Steering rack angle degree readout
    const rackAngleEl = this.element.querySelector('#rack-angle-val');
    if (rackAngleEl && this.vehicle) {
      const deg = (-this.vehicle.steerAngle * (180 / Math.PI)).toFixed(1);
      rackAngleEl.textContent = `${deg > 0 ? '+' : ''}${deg}°`;
    }

    // Vintage Upper Aux Rack Gauges
    const vdoVolts = this.element.querySelector('#vdo-volts');
    const vdoVoltsFill = this.element.querySelector('#vdo-volts-fill');
    if (vdoVolts) {
      const volts = this.vehicle.isEngineOn ? 14.2 : 12.3;
      vdoVolts.textContent = `${volts}V`;
      if (vdoVoltsFill) vdoVoltsFill.style.width = `${((volts - 10) / 5) * 100}%`;
    }

    const vdoOil = this.element.querySelector('#vdo-oil');
    const vdoOilFill = this.element.querySelector('#vdo-oil-fill');
    if (vdoOil) {
      const oilPress = this.vehicle.isEngineOn ? (2.0 + this.vehicle.rpm * 2.4).toFixed(1) : '0.0';
      vdoOil.textContent = `${oilPress} BAR`;
      if (vdoOilFill) vdoOilFill.style.width = `${Math.min(100, (parseFloat(oilPress) / 5.0) * 100)}%`;
    }

    const roadImpact = weatherDirector ? weatherDirector.getRoadImpact() : null;
    const vdoRoadStatus = this.element.querySelector('#vdo-road-status');
    const vdoExtTemp = this.element.querySelector('#vdo-ext-temp');
    if (vdoRoadStatus) {
      if (this.vehicle && this.vehicle.terrainZone && this.vehicle.terrainZone !== 'PAVED') {
        vdoRoadStatus.textContent = this.vehicle.terrainStatusText;
        vdoRoadStatus.style.color = this.vehicle.terrainStatusColor;
      } else if (roadImpact) {
        vdoRoadStatus.textContent = `${roadImpact.statusLabel} • ${roadImpact.statusBadge}`;
        vdoRoadStatus.style.color = roadImpact.statusColor;
      } else {
        vdoRoadStatus.textContent = 'ASFALTO 100%';
        vdoRoadStatus.style.color = '#22c55e';
      }
    }
    if (vdoExtTemp && currentBiome) {
      const baseTemp = currentBiome.coldDanger ? -18 : (currentBiome.id === 'flooded_marshland' ? 12 : 2);
      const isNight = this.survivalState.timeOfDay < 6 || this.survivalState.timeOfDay > 20;
      const curTemp = isNight ? baseTemp - 8 : baseTemp;
      vdoExtTemp.textContent = `${curTemp}°C • ${currentBiome.name.toUpperCase()}`;
    }

    // Live Terrain Radar Strip in MFD
    const terrainStrip = this.element.querySelector('#hud-terrain-strip');
    const terrainText = this.element.querySelector('#hud-terrain-text');
    const terrainBadge = this.element.querySelector('#hud-terrain-badge');
    const terrainIcon = this.element.querySelector('#hud-terrain-icon');
    if (terrainStrip && terrainText && this.vehicle) {
      terrainText.textContent = this.vehicle.terrainStatusText || 'ASFALTO (CARREGGIATA)';
      if (this.vehicle.terrainZone === 'SHOULDER') {
        if (terrainIcon) terrainIcon.textContent = '🪨';
        if (terrainBadge) {
          terrainBadge.textContent = 'BANCHINA';
          terrainBadge.style.color = '#38bdf8';
          terrainBadge.style.background = 'rgba(56, 189, 248, 0.2)';
        }
      } else if (this.vehicle.terrainZone === 'OFFROAD_SAFE') {
        if (terrainIcon) terrainIcon.textContent = '🌲';
        if (terrainBadge) {
          terrainBadge.textContent = '4x4 NATIVO';
          terrainBadge.style.color = '#10b981';
          terrainBadge.style.background = 'rgba(16, 185, 129, 0.2)';
        }
      } else if (this.vehicle.terrainZone === 'OFFROAD_CRAWL') {
        if (terrainIcon) terrainIcon.textContent = '⚠️';
        if (terrainBadge) {
          terrainBadge.textContent = 'CRAWL LENTO';
          terrainBadge.style.color = '#f59e0b';
          terrainBadge.style.background = 'rgba(245, 158, 11, 0.2)';
        }
      } else if (this.vehicle.terrainZone === 'OFFROAD_HAZARD') {
        if (terrainIcon) terrainIcon.textContent = '💥';
        if (terrainBadge) {
          terrainBadge.textContent = 'RISCHIO DANNO!';
          terrainBadge.style.color = '#ef4444';
          terrainBadge.style.background = 'rgba(239, 68, 68, 0.25)';
        }
      } else {
        if (terrainIcon) terrainIcon.textContent = '🛣️';
        if (terrainBadge) {
          terrainBadge.textContent = roadImpact ? roadImpact.statusBadge : 'GRIP 100%';
          terrainBadge.style.color = roadImpact ? roadImpact.statusColor : '#22c55e';
          terrainBadge.style.background = 'rgba(34, 197, 94, 0.2)';
        }
      }
    }

    // Right Pod: Pedal console gear badge
    const gearPedalBadge = this.element.querySelector('#hud-gear-pedal-badge');
    if (gearPedalBadge && this.vehicle) {
      gearPedalBadge.textContent = this.vehicle.gearState === 'REVERSE' ? 'REV [R]' : `DRIVE (D${this.vehicle.gear || 1})`;
      gearPedalBadge.style.color = this.vehicle.gearState === 'REVERSE' ? '#ef4444' : '#22c55e';
    }

    // Model-Specific Dashboard Instrument Scaling
    const cur = (this.vehicle && this.vehicle.getCurrentModelConfig) ? this.vehicle.getCurrentModelConfig() : (typeof CONFIG !== 'undefined' ? CONFIG.VEHICLES_CATALOG.panda_4x4 : null);
    if (!cur) return;

    if (this.currentModelId !== cur.id) {
      this.setupVehicleDashboard(cur);
    }

    const brandEl = this.element.querySelector('#hud-cluster-brand');
    if (brandEl) brandEl.textContent = `${cur.dashTheme.clusterName} — ${cur.maker.toUpperCase()} ${cur.name.toUpperCase()}`;

    const driveEl = this.element.querySelector('#hud-drivetrain-badge');
    if (driveEl) driveEl.textContent = cur.drivetrainBadge;

    // Live Transmission & Gear Interlock Telemetry Display
    const gearBadge = this.element.querySelector('#hud-gear-badge');
    if (gearBadge && this.vehicle) {
      if (this.vehicle.gearState === 'REVERSE') {
        gearBadge.textContent = '◀ RETROMARCIA [R]';
        gearBadge.className = 'cluster-gear-badge gear-reverse';
      } else if (Math.abs(this.vehicle.forwardSpeed) <= 0.15) {
        if (this.vehicle.standstillTimer >= 1.0 || this.vehicle.reverseArmed) {
          gearBadge.textContent = '[ PREMI FRENO ➔ RETRO ]';
          gearBadge.className = 'cluster-gear-badge gear-ready-reverse';
        } else {
          const waitTime = Math.max(0, 1.0 - this.vehicle.standstillTimer).toFixed(1);
          gearBadge.textContent = `[ ATTENDI STOP ${waitTime}s ]`;
          gearBadge.className = 'cluster-gear-badge gear-neutral';
        }
      } else {
        gearBadge.textContent = `▶ DRIVE (D${this.vehicle.gear || 1})`;
        gearBadge.className = 'cluster-gear-badge gear-drive';
      }
    }

    // 1. Speedometer Needle & Text
    const speed = this.vehicle.speedKmh;
    const speedValEl = this.element.querySelector('#dial-speed-val');
    if (speedValEl) speedValEl.textContent = speed;
    const maxSpeed = cur.dashTheme.speedoMax || 160;
    const speedDeg = -135 + Math.min(1.0, speed / maxSpeed) * 270;
    const speedNeedle = this.element.querySelector('#speed-needle');
    if (speedNeedle) {
      speedNeedle.style.transform = `rotate(${speedDeg}deg)`;
      if (cur.dashTheme.needleColor) speedNeedle.style.stroke = cur.dashTheme.needleColor;
    }

    // 2. Tachometer / Contagiri Motore (RPM)
    const maxRpm = Math.ceil((cur.dashTheme.redlineRpm || 6000) / 1000) * 1000 + 1000;
    const actualRpm = this.vehicle.engineRpmActual || Math.round(cur.idleRpm + this.vehicle.rpm * ((cur.dashTheme.redlineRpm || 6000) - cur.idleRpm));
    const rpmValEl = this.element.querySelector('#dial-rpm-val');
    if (rpmValEl) rpmValEl.textContent = (actualRpm / 1000).toFixed(1);
    const rpmDeg = -135 + Math.min(1.0, actualRpm / maxRpm) * 270;
    const rpmNeedle = this.element.querySelector('#rpm-needle');
    if (rpmNeedle) {
      rpmNeedle.style.transform = `rotate(${rpmDeg}deg)`;
      if (cur.dashTheme.needleColor) rpmNeedle.style.stroke = cur.dashTheme.needleColor;
    }

    // 3. Clinometro & Inclinometro 4x4 Off-Road
    const pitchRad = this.vehicle.mesh ? this.vehicle.mesh.rotation.x : 0;
    const rollRad = this.vehicle.mesh ? this.vehicle.mesh.rotation.z : 0;
    const pitchDeg = Math.round(pitchRad * (180 / Math.PI));
    const rollDeg = Math.round(rollRad * (180 / Math.PI));
    const inclineHorizonGroup = this.element.querySelector('#incline-horizon-group');
    if (inclineHorizonGroup) {
      const translateY = Math.max(-18, Math.min(18, pitchDeg * 0.8));
      inclineHorizonGroup.setAttribute('transform', `translate(60, ${60 + translateY}) rotate(${-rollDeg})`);
    }
    const dialInclineVal = this.element.querySelector('#dial-incline-val');
    if (dialInclineVal) {
      dialInclineVal.textContent = `${pitchDeg >= 0 ? '+' : ''}${pitchDeg}°`;
    }

    // 4. Analog Clock / Veglia Quartz Needles
    const hNeedle = this.element.querySelector('#clock-hour-needle');
    const mNeedle = this.element.querySelector('#clock-min-needle');
    if (hNeedle && mNeedle) {
      const rawHrs = this.survivalState.timeOfDay || 8.5;
      const rawMins = (rawHrs % 1) * 60;
      const hrDeg = ((rawHrs % 12) + (rawMins / 60)) * 30;
      const minDeg = rawMins * 6;
      hNeedle.style.transform = `rotate(${hrDeg}deg)`;
      mNeedle.style.transform = `rotate(${minDeg}deg)`;
    }

    // Instrument Cluster Night Backlighting (Glows when headlights ON)
    this.element.classList.toggle('dials-night-backlit', !!this.vehicle.isLightsOn);

    const lampPrimina = this.element.querySelector('#lamp-primina');
    if (lampPrimina) {
      const isPrimina = speed < 22 && (this.touchInput.throttle > 0.1 || this.vehicle.speedKmh > 1);
      lampPrimina.className = `steyr-lamp ${isPrimina ? 'active-primina' : ''}`;
    }

    // 5. Dedicated Turbo Boost Manometer (Bar)
    const turboHousing = this.element.querySelector('#turbo-dial-housing');
    if (turboHousing && cur.hasTurbo) {
      const boost = this.vehicle.boostBar || 0;
      const turboVal = this.element.querySelector('#dial-turbo-val');
      if (turboVal) turboVal.textContent = boost.toFixed(2);
      const maxBoost = cur.turboBoostMaxBar || 1.5;
      const boostDeg = -135 + Math.min(1.0, boost / maxBoost) * 270;
      const turboNeedle = this.element.querySelector('#turbo-needle');
      if (turboNeedle) {
        turboNeedle.style.transform = `rotate(${boostDeg}deg)`;
        if (cur.dashTheme.needleColor) turboNeedle.style.stroke = cur.dashTheme.needleColor;
      }
    }

    // 4. Car-Specific Auxiliary Widgets
    if (cur.id === 'panda_4x4') {
      const lamp4wd = this.element.querySelector('#lamp-4wd-steyr');
      const lampPrimina = this.element.querySelector('#lamp-primina');
      const steyrKnob = this.element.querySelector('#steyr-knob-pos');

      const is4wd = this.vehicle.is4WDEngaged !== undefined ? this.vehicle.is4WDEngaged : true;
      const isPrimina = !!this.vehicle.priminaCrawlerActive;

      if (lamp4wd) {
        lamp4wd.className = `steyr-lamp ${is4wd ? 'active-steyr' : ''}`;
        const dot = lamp4wd.querySelector('.ann-dot');
        if (dot) dot.style.background = is4wd ? '#22c55e' : '#475569';
      }
      if (lampPrimina) {
        lampPrimina.className = `steyr-lamp ${isPrimina ? 'active-primina' : ''}`;
        const dot = lampPrimina.querySelector('.ann-dot');
        if (dot) dot.style.background = isPrimina ? '#eab308' : '#475569';
      }
      if (steyrKnob) {
        steyrKnob.style.transform = is4wd ? 'translateY(-8px)' : 'translateY(4px)';
        steyrKnob.style.boxShadow = is4wd ? '0 0 8px rgba(34, 197, 94, 0.7)' : 'none';
      }

      const driveEl = this.element.querySelector('#hud-drivetrain-badge');
      if (driveEl) {
        if (is4wd) {
          driveEl.textContent = isPrimina ? '4WD STEYR + PRIMINA CRAWLER' : '4WD STEYR INSERITA [50:50]';
          driveEl.style.color = isPrimina ? '#eab308' : '#22c55e';
        } else {
          driveEl.textContent = '2WD TRAZIONE ANTERIORE [100:0]';
          driveEl.style.color = '#94a3b8';
        }
      }
    } else if (cur.id === 'delta_integrale') {
      const torsenBar = this.element.querySelector('#torsen-front-bar');
      const torsenText = this.element.querySelector('#torsen-split-text');
      if (torsenBar && torsenText) {
        let frontPct = 47 - (this.touchInput.throttle * 7) + (this.touchInput.brake * 8);
        frontPct = Math.max(38, Math.min(58, Math.round(frontPct)));
        const rearPct = 100 - frontPct;
        torsenBar.style.width = `${frontPct}%`;
        torsenText.textContent = `${frontPct}% ANT / ${rearPct}% POST`;
      }
    } else if (cur.id === 'mercedes_w123') {
      const w123Oil = this.element.querySelector('#w123-oil-val');
      if (w123Oil) {
        const oilBar = this.vehicle.isEngineOn ? (1.5 + (actualRpm / 4500) * 1.5).toFixed(1) : '0.0';
        w123Oil.textContent = `${oilBar} BAR`;
      }
      const boschBox = this.element.querySelector('#bosch-coil-box');
      const boschStatus = this.element.querySelector('#bosch-glow-status');
      if (boschBox && boschStatus) {
        if (!this.vehicle.isEngineOn) {
          boschBox.classList.add('glow-coil-active');
          boschStatus.textContent = 'VORGELÜHT';
          boschStatus.style.color = '#f97316';
        } else {
          boschBox.classList.remove('glow-coil-active');
          boschStatus.textContent = 'BETRIEB';
          boschStatus.style.color = '#22c55e';
        }
      }
    } else if (cur.id === 'mercedes_gwagen') {
      const horizon = this.element.querySelector('#incline-horizon-bar');
      const rollEl = this.element.querySelector('#incline-roll-val');
      const pitchEl = this.element.querySelector('#incline-pitch-val');
      if (horizon && rollEl && pitchEl) {
        const steer = (this.vehicle && this.vehicle.filteredSteer !== undefined) ? this.vehicle.filteredSteer : this.touchInput.steer;
        const rollDeg = (steer * -18).toFixed(1);
        const pitchDeg = (this.touchInput.throttle * 5 - this.touchInput.brake * 8).toFixed(1);
        horizon.style.transform = `rotate(${rollDeg}deg) translateY(${pitchDeg * 1.5}px)`;
        rollEl.textContent = `${Math.abs(rollDeg)}° ${rollDeg > 0 ? 'R' : 'L'}`;
        pitchEl.textContent = `${pitchDeg >= 0 ? '+' : ''}${pitchDeg}°`;
      }
    } else if (cur.id === 'defender_110') {
      const voltEl = this.element.querySelector('#defender-volts-num');
      if (voltEl) {
        const volts = this.vehicle.isEngineOn ? (13.8 + (actualRpm / 5000) * 0.6).toFixed(1) : '12.4';
        voltEl.textContent = `${volts} V`;
      }
    } else if (cur.id === 'volvo_245') {
      const lambdaEl = this.element.querySelector('#volvo-lambda');
      const frostEl = this.element.querySelector('#volvo-frost');
      if (lambdaEl) {
        lambdaEl.className = `volvo-lamp-chip ${this.vehicle.isEngineOn ? 'active-lambda' : ''}`;
      }
      if (frostEl) {
        const isFreezing = (this.survivalState.timeOfDay < 7 || this.survivalState.timeOfDay > 20);
        frostEl.className = `volvo-lamp-chip ${isFreezing ? 'active-frost' : ''}`;
      }
    } else if (cur.id === 'bmw_e30_ix') {
      const econBar = this.element.querySelector('#bmw-econ-bar');
      if (econBar) {
        let econ = 0;
        if (this.vehicle.isEngineOn) {
          if (speed < 5) econ = this.touchInput.throttle > 0 ? 30 : 0;
          else econ = Math.min(30, (this.touchInput.throttle * actualRpm * 0.008) / (speed * 0.01));
        }
        econBar.style.width = `${Math.min(100, (econ / 30) * 100)}%`;
      }
    } else if (cur.id === 'alfa_giulia') {
      const alfaOil = this.element.querySelector('#alfa-oil-val');
      if (alfaOil) {
        const press = this.vehicle.isEngineOn ? (2.2 + (actualRpm / 7000) * 4.3).toFixed(1) : '0.0';
        alfaOil.textContent = press;
      }
    } else if (cur.id === 'peugeot_504_dangel') {
      const compassRose = this.element.querySelector('#safari-compass-rose');
      const compassText = this.element.querySelector('#compass-heading-text');
      if (compassRose && compassText) {
        const steer = (this.vehicle && this.vehicle.filteredSteer !== undefined) ? this.vehicle.filteredSteer : this.touchInput.steer;
        const headingDeg = Math.round(((steer * 45) + 360) % 360);
        compassRose.style.transform = `rotate(${-headingDeg}deg)`;
        const cardinals = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
        const card = cardinals[Math.floor(((headingDeg + 22.5) % 360) / 45)];
        compassText.textContent = `${card} ${headingDeg.toString().padStart(3, '0')}°`;
      }
    } else if (cur.id === 'golf_country') {
      const golfSlip = this.element.querySelector('#golf-syncro-slip');
      if (golfSlip) {
        const isSlipping = this.vehicle.isEngineOn && this.touchInput.throttle > 0.5 && speed < 35;
        golfSlip.className = `syncro-slip-lamp ${isSlipping ? 'slip-active' : ''}`;
      }
    }

    // Glow Plug Pre-Heat Indicator for Diesel Engines
    const lampGlow = this.element.querySelector('#lamp-glow');
    if (lampGlow) {
      if (cur.isDiesel) {
        lampGlow.style.display = 'flex';
        lampGlow.className = `ann-lamp ann-glow ${!this.vehicle.isEngineOn ? 'active-glow' : ''}`;
      } else {
        lampGlow.style.display = 'none';
      }
    }

    // Vitals in MFD
    const fuelPct = (this.vehicle.fuel / this.vehicle.maxFuel) * 100;
    const fuelFill = this.element.querySelector('#hud-fuel-fill');
    if (fuelFill) fuelFill.style.width = `${fuelPct}%`;
    const fuelNum = this.element.querySelector('#hud-fuel-num');
    if (fuelNum) fuelNum.textContent = `${Math.round(this.vehicle.fuel)}L`;

    const hullFill = this.element.querySelector('#hud-hull-fill');
    if (hullFill) hullFill.style.width = `${this.vehicle.hull}%`;
    const hullNum = this.element.querySelector('#hud-hull-num');
    if (hullNum) hullNum.textContent = `${Math.round(this.vehicle.hull)}%`;

    const tempNorm = Math.min(100, Math.max(0, (this.vehicle.engineTemp - 50) / 70 * 100));
    const tempFill = this.element.querySelector('#hud-temp-fill');
    if (tempFill) tempFill.style.width = `${tempNorm}%`;
    const tempNum = this.element.querySelector('#hud-temp-num');
    if (tempNum) tempNum.textContent = `${Math.round(this.vehicle.engineTemp)}°C`;

    // Survivor Vitals
    const hpEl = this.element.querySelector('#hud-hp');
    if (hpEl) hpEl.textContent = Math.round(this.survivalState.health);
    const hgEl = this.element.querySelector('#hud-hunger');
    if (hgEl) hgEl.textContent = `${Math.round(this.survivalState.hunger)}%`;
    const thEl = this.element.querySelector('#hud-thirst');
    if (thEl) thEl.textContent = `${Math.round(this.survivalState.thirst)}%`;
    const tpEl = this.element.querySelector('#hud-temp');
    if (tpEl) tpEl.textContent = `${this.survivalState.bodyTemp.toFixed(1)}°C`;

    // Proximity POI
    this.showNearbyPOI(activePOI);

    // Sync tactile steering wheel and knob visual with smoothed rack angle
    if (!this.touchInput.touchSteerActive) {
      const displaySteer = (this.vehicle && this.vehicle.filteredSteer !== undefined) ? this.vehicle.filteredSteer : this.touchInput.steer;
      const track = this.element.querySelector('#steering-track');
      const knob = this.element.querySelector('#steering-knob');
      const wheel = this.element.querySelector('#steering-wheel');
      if (track && knob) {
        const rect = track.getBoundingClientRect();
        const travel = (rect.width > 0 ? rect.width : 150) * 0.40;
        knob.style.transform = `translateX(${displaySteer * travel}px)`;
      }
      if (wheel) {
        wheel.style.transform = `rotate(${displaySteer * 60}deg)`;
      }
    }

    // Sync pedal pressed state visuals for keyboard
    const pedalGas = this.element.querySelector('#pedal-gas');
    if (pedalGas && !this.touchInput.touchThrottleActive) {
      if (this.touchInput.throttle > 0) pedalGas.classList.add('pressed');
      else pedalGas.classList.remove('pressed');
    }
    const pedalBrake = this.element.querySelector('#pedal-brake');
    if (pedalBrake && !this.touchInput.touchBrakeActive) {
      if (this.touchInput.brake > 0) pedalBrake.classList.add('pressed');
      else pedalBrake.classList.remove('pressed');
    }

    // Malfunction Annunciator Lamps & Emergency Diagnostic Banner
    if (this.malfunctionManager) {
      const f = this.malfunctionManager.faults;
      const lampTire = this.element.querySelector('#lamp-tire');
      const lampLeak = this.element.querySelector('#lamp-leak');
      const lampElec = this.element.querySelector('#lamp-elec');
      const lampFuel = this.element.querySelector('#lamp-fuel');
      const ledRepair = this.element.querySelector('#led-repair');
      const repairText = this.element.querySelector('#repair-text');

      if (lampTire) lampTire.className = `ann-lamp ${f.flat_tire ? 'active-alarm' : ''}`;
      if (lampLeak) lampLeak.className = `ann-lamp ${f.radiator_leak ? 'active-alarm' : ''}`;
      if (lampElec) lampElec.className = `ann-lamp ${f.electrical_short ? 'active-alarm' : ''}`;
      if (lampFuel) lampFuel.className = `ann-lamp ${f.fuel_leak ? 'active-alarm' : ''}`;

      const activeFaults = this.malfunctionManager.getActiveFaultSummaries();
      const hasFault = activeFaults.length > 0;

      if (ledRepair) {
        ledRepair.className = `toggle-light-ring ${hasFault ? 'on active-alarm-led' : ''}`;
      }
      if (repairText) {
        repairText.textContent = hasFault ? 'FIX FAULT' : 'REPAIR';
      }

      // Update Breakdown Alert Banner
      const breakdownBanner = this.element.querySelector('#breakdown-banner');
      if (breakdownBanner) {
        if (hasFault) {
          const current = activeFaults[0];
          breakdownBanner.style.display = 'flex';
          this.element.querySelector('#breakdown-title').textContent = current.title;
          this.element.querySelector('#breakdown-desc').textContent = current.effect;
          this.element.querySelector('#breakdown-req').textContent = `Richiesto: ${current.needed}`;

          const fixBtn = this.element.querySelector('#btn-breakdown-fix');
          if (fixBtn) {
            fixBtn.textContent = current.canRepair ? 'RIPARA ORA' : 'MANCA PEZZO';
            fixBtn.className = `breakdown-fix-btn ${current.canRepair ? 'can-repair' : 'missing-supplies'}`;
          }
        } else {
          breakdownBanner.style.display = 'none';
        }
      }
    }

    // Story Director Integration (Pinned Objective & CB Radio LCD update)
    if (this.storyDirector) {
      const activeCh = this.storyDirector.getActiveChapter();
      const activeObj = this.storyDirector.getActiveObjective();

      const chBadge = this.element.querySelector('#story-ch-badge');
      if (chBadge && activeCh) {
        chBadge.textContent = `CAPITOLO ${activeCh.number}`;
      }

      const objText = this.element.querySelector('#story-obj-text');
      if (objText && activeObj) {
        objText.textContent = activeObj.text;
      }

      // Midland Alan 48 CB Radio Display Sync
      const cbDisplay = this.element.querySelector('#cb-display-text');
      const cbSignal = this.element.querySelector('#cb-signal-fill');
      if (cbDisplay) {
        if (this.storyDirector.activeRadioDispatch) {
          const spk = this.storyDirector.activeRadioDispatch.speaker;
          cbDisplay.textContent = `CH 19 [ RX: ${spk.substring(0, 16)} ] 27.185 MHz`;
          cbDisplay.style.color = '#4ade80';
          cbDisplay.style.textShadow = '0 0 10px #22c55e';
          if (cbSignal) cbSignal.style.width = '100%';
        } else {
          cbDisplay.textContent = 'CH 19 [ MERIDIAN CONVOY • EMGCY ] 27.185 MHz';
          cbDisplay.style.color = '#22c55e';
          cbDisplay.style.textShadow = '0 0 6px #22c55e';
          if (cbSignal) cbSignal.style.width = '75%';
        }
      }
    }
  }

  setStoryDirector(storyDirector) {
    this.storyDirector = storyDirector;
  }

  handleRadioDispatch(tx) {
    const overlay = this.element.querySelector('#cb-radio-overlay');
    if (!overlay) return;

    if (!tx) {
      overlay.style.display = 'none';
      return;
    }

    overlay.style.display = 'flex';
    const avatar = this.element.querySelector('#cb-avatar');
    if (avatar) avatar.textContent = tx.avatar || '📻';

    const spkName = this.element.querySelector('#cb-speaker-name');
    if (spkName) spkName.textContent = tx.speaker;

    const callsign = this.element.querySelector('#cb-callsign');
    if (callsign) callsign.textContent = tx.callsign || 'CH 19 DISPATCH';

    const msg = this.element.querySelector('#cb-message');
    if (msg) msg.textContent = `"${tx.text}"`;
  }

  handleObjectiveCompleted(obj) {
    const toast = this.element.querySelector('#story-toast');
    if (!toast) return;

    const desc = this.element.querySelector('#toast-desc');
    if (desc) desc.textContent = obj.text;

    toast.style.display = 'flex';
    toast.style.opacity = '1';

    setTimeout(() => {
      toast.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
      toast.style.opacity = '0';
      toast.style.transform = 'translate(-50%, -20px)';
      setTimeout(() => {
        toast.style.display = 'none';
        toast.style.transform = 'translateX(-50%)';
      }, 500);
    }, 4500);
  }

  executeEmergencyRepair() {
    if (!this.malfunctionManager) return;
    const summaries = this.malfunctionManager.getActiveFaultSummaries();
    if (summaries.length === 0) {
      this.showToast('Nessun guasto meccanico rilevato sul veicolo.');
      return;
    }
    const current = summaries[0];
    const res = this.malfunctionManager.repairFault(current.type);
    if (res.success) {
      this.showToast(`🔧 RIPARATO: ${current.title}`);
    } else {
      this.showToast(`⚠️ ${res.reason || 'Materiali insufficienti nel bagagliaio!'}`);
    }
  }

  showToast(msg) {
    const toast = document.createElement('div');
    toast.className = 'hud-quick-toast';
    toast.textContent = msg;
    this.element.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translate(-50%, -15px)';
      setTimeout(() => toast.remove(), 400);
    }, 3200);
  }
}


// --- FILE: src/ui/InventoryModal.js ---
/**
 * THE LONG MERIDIAN - Inventory & Cargo Management Modal
 * Responsive touch UI for managing vehicle trunk cargo and player backpack.
 */

class InventoryModal {
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


// --- FILE: src/ui/ScavengeModal.js ---
/**
 * THE LONG MERIDIAN - Territorial Settlement & Scavenging Modal
 * Handles lore dossiers, community barter trade, vehicle refuel/repairs, roadside diner, and structured site scavenging.
 */

class ScavengeModal {
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


// --- FILE: src/ui/UpgradeModal.js ---
/**
 * THE LONG MERIDIAN - Fleet Restoration Hub & Modular Engineering Workshop
 * Manages Dalton Highway Barn Finds, derelict restorations, vehicle fleet switching,
 * cargo stash logistics, and 14 modular engineering upgrades across 4 branches.
 */

class UpgradeModal {
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


// --- FILE: src/ui/MeridianAtlasModal.js ---
/**
 * THE LONG MERIDIAN - Tactical Route Atlas & Regional Lore Gazetteer
 * Interactive navigation encyclopedia mapping biomes, settlements, lore histories, and economic matrices.
 */

class MeridianAtlasModal {
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


// --- FILE: src/ui/StoryDiaryModal.js ---
/**
 * THE LONG MERIDIAN - Story & Mission Diary Modal ("Diario di Bordo & Logbook")
 * Fullscreen tactical journal tracking the 6 expedition chapters, CB radio transcripts,
 * real-time objectives checklist, rewards claiming, and Paolo's engineering notes.
 */

class StoryDiaryModal {
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
              <p>Osservazioni tecniche su cinematica dei terreni, dissipazione termica dei freni e segreti dei relitti lungo il Grande Meridiano.</p>
            </div>
            <div class="engineer-notes-grid" id="engineer-notes-grid"></div>
          </div>
        </div>

        <div class="modal-footer diary-footer">
          <div class="diary-status-motto">SPEDIZIONE IL GRANDE MERIDIANO • ATTRAVERSO GLI 8 BIOMI NATURALI DELLA TERRA</div>
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
            ${isCompleted ? 'COMPLETATO' : isCurrent ? 'ATTIVO SULLA ROTTA' : 'NON ANCORA RAGGIUNTO'}
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
          <div class="empty-text">Nessuna trasmissione ricevuta. Accendi il motore e mettiti in marcia lungo il Grande Meridiano per captare i segnali sul Canale 19!</div>
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


// --- FILE: src/main.js ---
/**
 * THE LONG MERIDIAN - Main Game Application Coordinator
 * Boots all subsystems, manages loop and transitions between driving and foot scavenging.
 */

class Game {
  constructor() {
    this.container = document.getElementById('app');
    this.canvasContainer = document.getElementById('canvas-container');

    // State
    this.isFootMode = false;
    this.lastTime = performance.now();
    this.isRunning = false;

    // Toast element
    this.biomeToast = null;

    this.init();
  }

  init() {
    // 1. Audio & Input
    this.audioEngine = new WebAudioEngine();
    this.touchInput = new TouchInput();

    // 2. Rendering & Camera
    this.renderer = new Renderer(this.canvasContainer);
    this.renderer.setAudioEngine(this.audioEngine);
    this.cameraController = new CameraController(this.renderer.camera);

    // 3. World Systems
    this.biomeManager = new BiomeManager(this.renderer, this.audioEngine);
    this.roadGenerator = new RoadGenerator(this.renderer.scene, this.biomeManager);
    this.scenerySpawner = new ScenerySpawner(this.renderer.scene, this.roadGenerator, this.biomeManager);
    this.poiManager = new POIManager(this.renderer.scene, this.roadGenerator);
    this.landscapeManager = new LandscapeManager(this.renderer.scene, this.roadGenerator);

    // 4. Entities
    this.vehicle = new Vehicle(this.renderer.scene, this.audioEngine);
    this.playerCharacter = new PlayerCharacter(this.renderer.scene, this.audioEngine);
    this.hazards = new Hazards(this.renderer.scene, this.roadGenerator, this.audioEngine, this.cameraController);

    // 5. Survival, Progression & Malfunctions
    this.survivalState = new SurvivalState(this.audioEngine);
    this.inventorySystem = new InventorySystem(this.vehicle, this.survivalState, this.audioEngine);
    this.weatherDirector = new WeatherDirector(this.renderer, this.audioEngine, this.biomeManager);
    this.upgradeSystem = new UpgradeSystem(this.vehicle, this.inventorySystem, this.audioEngine);
    this.malfunctionManager = new MalfunctionManager(this.vehicle, this.inventorySystem, this.audioEngine);
    this.storyDirector = new StoryDirector(this.vehicle, this.survivalState, this.inventorySystem, this.audioEngine, this.poiManager);

    // 6. UI Layer
    this.dashboardHUD = new DashboardHUD(
      this.container,
      this.vehicle,
      this.survivalState,
      this.touchInput,
      this.audioEngine,
      this.malfunctionManager
    );
    this.dashboardHUD.setStoryDirector(this.storyDirector);

    this.inventoryModal = new InventoryModal(this.container, this.inventorySystem, this.audioEngine);
    this.scavengeModal = new ScavengeModal(this.container, this.inventorySystem, this.audioEngine);
    this.upgradeModal = new UpgradeModal(this.container, this.vehicle, this.upgradeSystem, this.audioEngine, this.inventorySystem);
    this.meridianAtlasModal = new MeridianAtlasModal(this.container, this.audioEngine);
    this.storyDiaryModal = new StoryDiaryModal(this.container, this.storyDirector, this.audioEngine);

    // Setup Toasts
    this.setupToast();
    this.setupDerelictToast();

    // Setup UI Callbacks
    this.bindCallbacks();

    // Start Loop
    this.isRunning = true;
    requestAnimationFrame((t) => this.loop(t));

    // Show initial welcome toast
    this.showBiomeToast(this.biomeManager.currentBiome);
  }

  setupToast() {
    this.biomeToast = document.createElement('div');
    this.biomeToast.className = 'biome-toast';
    this.biomeToast.innerHTML = `
      <div class="toast-accent-strip"></div>
      <div class="toast-content">
        <h2 id="toast-title">CORRIDOIO NORDICO</h2>
        <p id="toast-sub">Inizio Spedizione</p>
        <div class="toast-extra" id="toast-extra">Caricamento coordinate...</div>
      </div>
    `;
    this.canvasContainer.appendChild(this.biomeToast);
  }

  setupDerelictToast() {
    this.derelictToast = document.createElement('div');
    this.derelictToast.className = 'derelict-toast';
    this.derelictToast.style.cssText = `
      position: absolute;
      top: 90px;
      left: 50%;
      transform: translateX(-50%) translateY(-15px);
      background: rgba(14, 18, 24, 0.96);
      border: 1px solid rgba(255, 179, 0, 0.65);
      box-shadow: 0 8px 32px rgba(0,0,0,0.85), 0 0 25px rgba(255, 179, 0, 0.25);
      border-radius: 8px;
      padding: 10px 18px;
      display: flex;
      align-items: center;
      gap: 12px;
      z-index: 1200;
      opacity: 0;
      pointer-events: none;
      transition: opacity 0.4s ease, transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    `;
    this.derelictToast.innerHTML = `
      <div style="font-size: 26px; line-height: 1;">📻</div>
      <div>
        <div style="font-size: 10px; font-weight: 800; letter-spacing: 0.15em; color: #ffb300; text-transform: uppercase;">SEGNALE CB ALASKA • RELITTO INDIVIDUATO</div>
        <div id="derelict-toast-title" style="font-size: 14px; font-weight: 700; color: #fff; margin-top: 2px;">Fiat Panda 4x4 Steyr-Puch</div>
        <div id="derelict-toast-desc" style="font-size: 11px; color: rgba(255,255,255,0.7); margin-top: 1px;">Coordinate registrate nel Dalton Registry. Apri Garage (G) per il restauro.</div>
      </div>
    `;
    this.canvasContainer.appendChild(this.derelictToast);
  }

  showDerelictToast(car) {
    if (!this.derelictToast) return;
    const titleEl = this.derelictToast.querySelector('#derelict-toast-title');
    const descEl = this.derelictToast.querySelector('#derelict-toast-desc');
    if (titleEl) titleEl.textContent = `${car.name} (${car.year})`;
    if (descEl) descEl.textContent = `📍 ${car.discoveryLocation || 'Lungo la Dalton'} • Apri il Garage (G) per ispezionare il restauro`;
    
    this.derelictToast.style.opacity = '1';
    this.derelictToast.style.transform = 'translateX(-50%) translateY(0)';
    if (this.audioEngine && this.audioEngine.playSwitchClick) {
      this.audioEngine.playSwitchClick(true);
    }

    setTimeout(() => {
      if (this.derelictToast) {
        this.derelictToast.style.opacity = '0';
        this.derelictToast.style.transform = 'translateX(-50%) translateY(-10px)';
      }
    }, 6000);
  }

  showBiomeToast(biome) {
    this.biomeToast.querySelector('#toast-title').textContent = biome.name.toUpperCase();
    this.biomeToast.querySelector('#toast-sub').textContent = `${biome.subname} — HUB: ${biome.settlementName}`;
    const extra = this.biomeToast.querySelector('#toast-extra');
    if (extra) {
      extra.textContent = `⚠️ PERICOLO: ${biome.environmentalThreat || 'Attenzione al fondo stradale'}`;
    }
    this.biomeToast.style.opacity = '1';
    this.biomeToast.style.transform = 'translateX(-50%) translateY(0)';

    setTimeout(() => {
      this.biomeToast.style.opacity = '0';
      this.biomeToast.style.transform = 'translateX(-50%) translateY(-10px)';
    }, 5500);
  }

  bindCallbacks() {
    // Mode switch: Drive <-> Foot
    this.dashboardHUD.onToggleMode = () => {
      this.toggleMode();
    };

    // Inventory modal
    this.dashboardHUD.onOpenInventory = () => {
      this.inventoryModal.toggle();
    };

    // Workshop & Garage modals
    this.dashboardHUD.onOpenWorkshop = (tab = 'upgrades') => {
      this.upgradeModal.toggle(tab);
    };

    this.dashboardHUD.onOpenGarage = () => {
      this.upgradeModal.toggle('garage');
    };

    // Atlas Route Log modal
    this.dashboardHUD.onOpenAtlas = () => {
      this.meridianAtlasModal.toggle(this.biomeManager.currentBiome.id);
    };

    // Story Diary & Campaign Logbook modal
    this.dashboardHUD.onOpenStoryDiary = () => {
      this.storyDiaryModal.toggle();
    };
    if (this.touchInput) {
      this.touchInput.onOpenJournal = () => {
        this.storyDiaryModal.toggle();
      };
      this.touchInput.onHonkHorn = () => {
        if (!this.isFootMode && this.vehicle && this.vehicle.honkHorn) {
          this.vehicle.honkHorn();
        }
      };
      this.touchInput.onToggle4WD = () => {
        if (!this.isFootMode && this.vehicle && this.vehicle.toggle4WD) {
          const res = this.vehicle.toggle4WD();
          if (res) this.dashboardHUD.showToast(res.message);
        }
      };
      this.touchInput.onTogglePrimina = () => {
        if (!this.isFootMode && this.vehicle && this.vehicle.togglePrimina) {
          const res = this.vehicle.togglePrimina();
          if (res) this.dashboardHUD.showToast(res.message);
        }
      };
    }

    // Story Director callbacks
    this.storyDirector.onRadioDispatch = (tx) => {
      this.dashboardHUD.handleRadioDispatch(tx);
    };

    this.storyDirector.onObjectiveCompleted = (obj, ch) => {
      this.dashboardHUD.handleObjectiveCompleted(obj);
    };

    this.storyDirector.onChapterCompleted = (ch) => {
      this.showBiomeToast({
        name: `CAPITOLO ${ch.number} COMPLETATO!`,
        subname: ch.title,
        settlementName: 'Ricompense Disponibili',
        environmentalThreat: 'Apri il Diario di Bordo (STORY) per riscuotere scorte e sblocchi!'
      });
    };

    // Scavenge / Settlement action
    this.dashboardHUD.onScavenge = () => {
      const activePOI = this.poiManager.activeNearbyPOI;
      if (activePOI && !activePOI.scavenged) {
        this.scavengeModal.openWithPOI(activePOI);
      }
    };

    // Biome change toast callback
    this.biomeManager.onBiomeChangeCallback = (newBiome) => {
      this.showBiomeToast(newBiome);
    };

    // Fleet derelict discovery callback
    this.upgradeSystem.onDerelictDiscovered = (car) => {
      this.showDerelictToast(car);
    };

    // User gesture to resume WebAudio
    window.addEventListener('pointerdown', () => {
      this.audioEngine.ensureContext();
    }, { once: true });
  }

  toggleMode() {
    if (this.isFootMode) {
      // Re-enter vehicle from anywhere
      this.isFootMode = false;
      this.playerCharacter.despawn();
      this.dashboardHUD.setModeVisual(false);
      this.dashboardHUD.showToast('🚗 Risalito a bordo del veicolo');
      if (this.audioEngine && this.audioEngine.playSwitchClick) {
        this.audioEngine.playSwitchClick(true);
      }
    } else {
      // Dismount vehicle
      if (this.vehicle.speedKmh > 15) {
        this.dashboardHUD.showToast('⚠️ Frena prima di scendere dal veicolo!');
        return;
      }
      this.isFootMode = true;
      // Spawn player on left side of vehicle
      const spawnPos = this.vehicle.position.clone().add(new THREE.Vector3(-1.8, 0, 0));
      this.playerCharacter.spawnAt(spawnPos);
      this.dashboardHUD.setModeVisual(true);
      this.dashboardHUD.showToast('🚶 Sei a piedi. Premi [E] o [ENTER CAR] per risalire');
    }
  }

  loop(currentTime) {
    if (!this.isRunning) return;
    const delta = Math.min((currentTime - this.lastTime) / 1000, 0.1);
    this.lastTime = currentTime;

    // 1. Process Input
    this.touchInput.update();

    // 2. Active target (Vehicle or Foot)
    const activeTarget = this.isFootMode ? this.playerCharacter : this.vehicle;
    const activePos = activeTarget.position;

    // 3. Query Road Info at active Z
    const roadInfo = this.roadGenerator.getRoadInfoAt(activePos.z);
    const roadImpact = this.weatherDirector.getRoadImpact();

    // 4. Update Entities
    if (this.isFootMode) {
      this.playerCharacter.update(delta, this.touchInput, roadInfo);
      this.vehicle.update(delta, { throttle: 0, brake: 1.0, steer: 0 }, roadInfo, this.renderer, roadImpact);
    } else {
      this.vehicle.update(delta, this.touchInput, roadInfo, this.renderer, roadImpact);
    }

    // Update exhaust particles
    this.renderer.updateExhaust(delta);

    // Update Malfunctions
    this.malfunctionManager.update(delta, this.touchInput, this.renderer);

    // 5. Update Hazards & Collisions
    this.hazards.update(activePos.z, this.vehicle, this.playerCharacter, delta, this.malfunctionManager, this.renderer);

    // 6. Update World Systems & Landscapes
    this.biomeManager.update(activePos.z);
    this.roadGenerator.update(activePos.z);
    this.scenerySpawner.update(activePos.z);
    this.poiManager.update(activePos);
    this.landscapeManager.update(activePos.z, delta, this.biomeManager.currentBiome);
    this.weatherDirector.update(delta, activePos.z, this.roadGenerator);
    this.upgradeSystem.update(activePos.z);
    this.storyDirector.update(delta);

    // 7. Update Survival State
    this.survivalState.update(delta, activePos.z, this.biomeManager.currentBiome, !this.isFootMode);

    // 8. Update Camera & Dynamic Celestial Day/Night Lighting
    const forwardVel = this.isFootMode ? this.playerCharacter.walkSpeed * 0.5 : this.vehicle.forwardSpeed;
    const targetHeading = this.isFootMode ? (this.playerCharacter.rotationY || 0) : (this.vehicle.rotation ? this.vehicle.rotation.y : 0);
    const roadHeading = (roadInfo && roadInfo.roadAngle !== undefined) ? roadInfo.roadAngle : 0;
    this.cameraController.update(delta, activePos, forwardVel, targetHeading, roadHeading);

    this.renderer.updateDayNightLighting(
      this.survivalState.timeOfDay,
      this.weatherDirector.currentWeather,
      this.biomeManager.currentBiome,
      this.vehicle.isLightsOn,
      delta
    );
    this.renderer.updateLightFollow(activePos);

    // 9. Update Cockpit Dashboard HUD
    this.dashboardHUD.update(this.biomeManager.currentBiome, this.poiManager.activeNearbyPOI, this.weatherDirector);

    // 10. Render 3D Scene
    this.renderer.render();

    requestAnimationFrame((t) => this.loop(t));
  }
}

// Safe initialization handling both pre and post DOMContentLoaded
function bootGame() {
  if (!window.game) {
    window.game = new Game();
  }
}

if (document.readyState === 'loading') {
  window.addEventListener('DOMContentLoaded', bootGame);
} else {
  bootGame();
}


})();

