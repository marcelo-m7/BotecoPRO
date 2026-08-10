import { writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';

import { loadTsModule } from './utils/ts-loader.mjs';

const designModule = loadTsModule('src/components/design/index.ts');
const { DepthSurface, DepthStack, DepthSpotlight, depthLevels } = designModule;

const normalize = (markup) => markup.replace(/\s+/g, ' ').replace(/>\s+</g, '><').trim();

const snapshots = {
  DepthSurface: {},
  DepthStack: {},
  DepthSpotlight: {},
};

for (const level of depthLevels) {
  snapshots.DepthSurface[level] = normalize(
    renderToStaticMarkup(
      React.createElement(
        DepthSurface,
        { depth: level, interactive: true },
        React.createElement('div', { className: 'px-4 py-2' }, `Depth ${level}`),
      ),
    ),
  );

  snapshots.DepthStack[level] = normalize(
    renderToStaticMarkup(
      React.createElement(
        DepthStack,
        { depth: level, layers: 3, layerOffset: 4 },
        React.createElement('div', { className: 'px-4 py-2' }, `Stack ${level}`),
      ),
    ),
  );

  snapshots.DepthSpotlight[level] = normalize(
    renderToStaticMarkup(
      React.createElement(
        DepthSpotlight,
        { depth: level, spotlightOpacity: 0.18 },
        React.createElement('div', { className: 'px-4 py-2' }, `Spotlight ${level}`),
      ),
    ),
  );
}

const __dirname = dirname(fileURLToPath(import.meta.url));
writeFileSync(
  join(__dirname, '__snapshots__', 'depth.json'),
  `${JSON.stringify(snapshots, null, 2)}\n`,
);
