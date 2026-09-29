/**
 * THE LONG MERIDIAN - Player Character (On-Foot Scavenging Mode)
 * Controls player avatar when dismounting vehicle, with flashlight spotlight, stamina and interaction.
 */

import { CONFIG } from '../config.js';

export class PlayerCharacter {
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
