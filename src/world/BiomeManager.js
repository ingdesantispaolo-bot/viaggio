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
      CONFIG.BIOMES.RUSTY_PERIPHERY,
      CONFIG.BIOMES.BLACK_PINE_WOODS,
      CONFIG.BIOMES.FLOODED_MARSHLAND,
      CONFIG.BIOMES.GLASS_CRATER,
      CONFIG.BIOMES.IRON_GORGE,
      CONFIG.BIOMES.PERMAFROST_HIGHLANDS
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
    // Choose surface based on current biome
    const biome = this.currentBiome;
    if (biome.id === 'rusty_periphery') {
      return Math.random() < 0.3 ? CONFIG.SURFACES.GRAVEL : CONFIG.SURFACES.ASPHALT;
    } else if (biome.id === 'black_pine_woods') {
      return Math.random() < 0.6 ? CONFIG.SURFACES.DIRT : CONFIG.SURFACES.ASPHALT;
    } else if (biome.id === 'flooded_marshland') {
      return Math.random() < 0.4 ? CONFIG.SURFACES.STEEL_BRIDGE : CONFIG.SURFACES.SLUDGE;
    } else if (biome.id === 'glass_crater') {
      return Math.random() < 0.5 ? CONFIG.SURFACES.SLUDGE : CONFIG.SURFACES.ASPHALT;
    } else if (biome.id === 'iron_gorge') {
      return Math.random() < 0.5 ? CONFIG.SURFACES.GRAVEL : CONFIG.SURFACES.ASPHALT;
    } else if (biome.id === 'permafrost_highlands') {
      return Math.random() < 0.65 ? CONFIG.SURFACES.ICE : CONFIG.SURFACES.ASPHALT;
    }
    return CONFIG.SURFACES.ASPHALT;
  }
}
