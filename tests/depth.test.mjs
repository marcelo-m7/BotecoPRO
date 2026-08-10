import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, it } from 'node:test';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';

import { loadTsModule } from './utils/ts-loader.mjs';

const designModule = loadTsModule('src/components/design/index.ts');
const { DepthSurface, DepthStack, DepthSpotlight, depthLevels } = designModule;

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const snapshots = JSON.parse(
  readFileSync(join(__dirname, '__snapshots__', 'depth.json'), 'utf8'),
);

const normalize = (markup) => markup.replace(/\s+/g, ' ').replace(/>\s+</g, '><').trim();

describe('DepthSurface', () => {
  for (const level of depthLevels) {
    it(`matches snapshot for depth-${level}`, () => {
      const markup = renderToStaticMarkup(
        React.createElement(
          DepthSurface,
          { depth: level, interactive: true },
          React.createElement('div', { className: 'px-4 py-2' }, `Depth ${level}`),
        ),
      );

      assert.strictEqual(normalize(markup), snapshots.DepthSurface[String(level)]);
    });
  }
});

describe('DepthStack', () => {
  for (const level of depthLevels) {
    it(`matches snapshot for stack depth-${level}`, () => {
      const markup = renderToStaticMarkup(
        React.createElement(
          DepthStack,
          { depth: level, layers: 3, layerOffset: 4 },
          React.createElement('div', { className: 'px-4 py-2' }, `Stack ${level}`),
        ),
      );

      assert.strictEqual(normalize(markup), snapshots.DepthStack[String(level)]);
    });
  }
});

describe('DepthSpotlight', () => {
  for (const level of depthLevels) {
    it(`matches snapshot for spotlight depth-${level}`, () => {
      const markup = renderToStaticMarkup(
        React.createElement(
          DepthSpotlight,
          { depth: level, spotlightOpacity: 0.18 },
          React.createElement('div', { className: 'px-4 py-2' }, `Spotlight ${level}`),
        ),
      );

      assert.strictEqual(normalize(markup), snapshots.DepthSpotlight[String(level)]);
    });
  }
});
