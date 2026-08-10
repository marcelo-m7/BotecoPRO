import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const cssPath = join(__dirname, '..', 'src', 'globals.css');
const css = readFileSync(cssPath, 'utf8');

const expectedHex = {
  'boteco-wine-500': '#8b1e3f',
  'boteco-mustard-500': '#b3701a',
  'boteco-beige-400': '#f1ddad',
  'boteco-brown-500': '#4f3222',
  'boteco-neutral-50': '#fcfbf9',
  'boteco-neutral-900': '#302d29',
};

const variablePattern = /--([a-z0-9-]+):\s*([0-9.]+)\s+([0-9.]+)%\s+([0-9.]+)%/gi;
const parsedVariables = new Map();

let match;
while ((match = variablePattern.exec(css)) !== null) {
  const [, name, h, s, l] = match;
  parsedVariables.set(name, {
    h: Number(h),
    s: Number(s),
    l: Number(l),
  });
}

function hslToHex(h, s, l) {
  const hue = (h % 360) / 360;
  const saturation = s / 100;
  const lightness = l / 100;

  const q = lightness < 0.5
    ? lightness * (1 + saturation)
    : lightness + saturation - lightness * saturation;
  const p = 2 * lightness - q;

  const channels = [hue + 1 / 3, hue, hue - 1 / 3].map((channel) => {
    let c = channel;
    if (c < 0) c += 1;
    if (c > 1) c -= 1;
    if (c < 1 / 6) return p + (q - p) * 6 * c;
    if (c < 1 / 2) return q;
    if (c < 2 / 3) return p + (q - p) * (2 / 3 - c) * 6;
    return p;
  });

  return `#${channels
    .map((value) => Math.round(value * 255)
      .toString(16)
      .padStart(2, '0'))
    .join('')}`;
}

for (const [variable, hex] of Object.entries(expectedHex)) {
  test(`CSS token ${variable} resolves to ${hex}`, () => {
    const entry = parsedVariables.get(variable);
    assert.ok(entry, `Variable ${variable} not found in globals.css`);
    const computed = hslToHex(entry.h, entry.s, entry.l);
    assert.strictEqual(computed, hex);
  });
}
