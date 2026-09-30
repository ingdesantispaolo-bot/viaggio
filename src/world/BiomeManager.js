/**
 * THE LONG MERIDIAN - Biome Progression Manager
 * Handles procedural biome shifts, environment parameters, and atmospheric transitions.
 */

import { CONFIG } from '../config.js';

export class BiomeManager {
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
