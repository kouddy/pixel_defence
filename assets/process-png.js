#!/usr/bin/env node
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const SOURCE_DIR = path.join(__dirname, 'source');
const OUTPUT_DIR = __dirname;
const TARGET_SIZE = 512;
const WHITE_THRESHOLD = 245;
const MIN_ARTIFACT_PIXELS = 100;

function findLargestComponent(mask, width, height) {
  const visited = new Uint8Array(width * height);
  const labels = new Int32Array(width * height).fill(-1);
  let currentLabel = 0;
  const componentSizes = [];

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const idx = y * width + x;
      if (mask[idx] === 0 || visited[idx]) continue;

      let size = 0;
      const stack = [idx];
      visited[idx] = 1;

      while (stack.length > 0) {
        const cur = stack.pop();
        labels[cur] = currentLabel;
        size++;

        const cx = cur % width;
        const cy = (cur - cx) / width;

        for (const [dx, dy] of [[-1,0],[1,0],[0,-1],[0,1]]) {
          const nx = cx + dx;
          const ny = cy + dy;
          if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
          const ni = ny * width + nx;
          if (!visited[ni] && mask[ni]) {
            visited[ni] = 1;
            stack.push(ni);
          }
        }
      }

      componentSizes.push({ label: currentLabel, size });
      currentLabel++;
    }
  }

  if (componentSizes.length === 0) return null;

  componentSizes.sort((a, b) => b.size - a.size);
  const largestLabel = componentSizes[0].label;

  let minX = width, maxX = 0, minY = height, maxY = 0;
  for (let i = 0; i < labels.length; i++) {
    if (labels[i] === largestLabel) {
      const x = i % width;
      const y = (i - x) / width;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }

  return { x: minX, y: minY, w: maxX - minX + 1, h: maxY - minY + 1 };
}

async function processImage(filePath) {
  const fileName = path.basename(filePath);
  const outputPath = path.join(OUTPUT_DIR, fileName);

  try {
    const image = sharp(filePath);
    const metadata = await image.metadata();
    const { width, height } = metadata;

    const { data } = await image
      .ensureAlpha()
      .raw()
      .toBuffer({ resolveWithObject: true });

    const mask = new Uint8Array(width * height);
    for (let i = 0; i < mask.length; i++) {
      const r = data[i * 4];
      const g = data[i * 4 + 1];
      const b = data[i * 4 + 2];
      mask[i] = (r < WHITE_THRESHOLD || g < WHITE_THRESHOLD || b < WHITE_THRESHOLD) ? 1 : 0;
    }

    const bounds = findLargestComponent(mask, width, height);
    if (!bounds) {
      console.error(`No character found in ${fileName}`);
      return;
    }

    // Scale so the character's longer edge becomes TARGET_SIZE, preserving
    // aspect ratio. The output is sized to the character itself (no padding to
    // a square), so nothing is clipped and there are no empty margins. Using
    // only the height (the old behaviour) overflowed horizontally for wide
    // characters, producing a negative offset that clipped the left/right edges.
    const scale = Math.min(TARGET_SIZE / bounds.w, TARGET_SIZE / bounds.h);
    const newW = Math.round(bounds.w * scale);
    const newH = Math.round(bounds.h * scale);

    const croppedW = Math.min(bounds.w, width - bounds.x);
    const croppedH = Math.min(bounds.h, height - bounds.y);

    const croppedBuffer = await sharp(filePath)
      .extract({
        left: bounds.x,
        top: bounds.y,
        width: croppedW,
        height: croppedH
      })
      .resize({
        width: newW,
        height: newH,
        fit: 'contain',
        kernel: 'nearest'
      })
      .ensureAlpha()
      .raw()
      .toBuffer({ resolveWithObject: true });

    const resizedW = croppedBuffer.info.width;
    const resizedH = croppedBuffer.info.height;

    // Canvas is sized exactly to the resized character: no centre offset, no
    // square padding, so no clipping and no empty margins.
    const canvas = Buffer.alloc(resizedW * resizedH * 4, 0);

    for (let y = 0; y < resizedH; y++) {
      for (let x = 0; x < resizedW; x++) {
        const idx = (y * resizedW + x) * 4;
        const r = croppedBuffer.data[idx];
        const g = croppedBuffer.data[idx + 1];
        const b = croppedBuffer.data[idx + 2];

        if (r < WHITE_THRESHOLD || g < WHITE_THRESHOLD || b < WHITE_THRESHOLD) {
          canvas[idx] = r;
          canvas[idx + 1] = g;
          canvas[idx + 2] = b;
          canvas[idx + 3] = 255;
        }
      }
    }

    await sharp(canvas, {
      raw: { width: resizedW, height: resizedH, channels: 4 }
    }).png().toFile(outputPath);

    console.log(`Processed: ${fileName} (char: ${croppedW}x${croppedH} -> ${resizedW}x${resizedH})`);
  } catch (err) {
    console.error(`Error processing ${fileName}:`, err.message);
  }
}

async function main() {
  if (!fs.existsSync(SOURCE_DIR)) {
    console.error('Source directory not found:', SOURCE_DIR);
    process.exit(1);
  }

  // Process specific files if given as CLI args, otherwise the whole folder.
  const files = process.argv.slice(2).length > 0
    ? process.argv.slice(2)
    : fs.readdirSync(SOURCE_DIR).filter(f => f.endsWith('.png'));

  if (files.length === 0) {
    console.log('No PNG files found in source directory.');
    return;
  }

  console.log(`Processing ${files.length} images...`);

  for (const file of files) {
    await processImage(path.join(SOURCE_DIR, file));
  }

  console.log('Done!');
}

main();
