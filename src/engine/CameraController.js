/**
 * THE LONG MERIDIAN - Adaptive Dynamic Follow & Highway Sweeping Camera Controller
 * Smoothly follows vehicle/player along highway curves, prevents camera from lagging or losing vehicle,
 * applies speed-based lookahead and trauma screen shake.
 */

export class CameraController {
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
