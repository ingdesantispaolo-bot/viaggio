/**
 * THE LONG MERIDIAN - Procedural Canvas Texture Generator
 * Generates crisp, realistic textures at runtime without external image files.
 */

export class TextureGenerator {
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
