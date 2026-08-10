import { readFileSync, existsSync, statSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import Module from 'node:module';
import ts from 'typescript';

const moduleCache = new Map();
const nativeRequire = Module.createRequire(import.meta.url);
const projectRoot = path.resolve(fileURLToPath(new URL('../../', import.meta.url)));

const extensions = ['', '.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs'];

function tryResolve(basePath) {
  if (existsSync(basePath) && statSync(basePath).isFile()) {
    return basePath;
  }

  for (const ext of extensions) {
    const candidate = basePath.endsWith(ext) ? basePath : `${basePath}${ext}`;
    if (existsSync(candidate) && statSync(candidate).isFile()) {
      return candidate;
    }
  }

  if (existsSync(basePath) && statSync(basePath).isDirectory()) {
    for (const ext of extensions) {
      const candidate = path.join(basePath, `index${ext}`);
      if (existsSync(candidate) && statSync(candidate).isFile()) {
        return candidate;
      }
    }
  }

  return null;
}

function resolveSpecifier(fromFile, specifier) {
  if (specifier.startsWith('@/')) {
    const base = path.join(projectRoot, 'src', specifier.slice(2));
    const resolved = tryResolve(base);
    if (!resolved) {
      throw new Error(`Cannot resolve module ${specifier} from ${fromFile}`);
    }
    return resolved;
  }

  if (specifier.startsWith('./') || specifier.startsWith('../')) {
    const base = path.resolve(path.dirname(fromFile), specifier);
    const resolved = tryResolve(base);
    if (!resolved) {
      throw new Error(`Cannot resolve module ${specifier} from ${fromFile}`);
    }
    return resolved;
  }

  return null;
}

function loadModule(absolutePath) {
  if (moduleCache.has(absolutePath)) {
    return moduleCache.get(absolutePath);
  }

  const ext = path.extname(absolutePath);
  if (ext === '.js' || ext === '.mjs' || ext === '.cjs') {
    const exports = nativeRequire(absolutePath);
    moduleCache.set(absolutePath, exports);
    return exports;
  }

  const source = readFileSync(absolutePath, 'utf8');
  const { outputText } = ts.transpileModule(source, {
    compilerOptions: {
      module: ts.ModuleKind.CommonJS,
      jsx: ts.JsxEmit.ReactJSX,
      esModuleInterop: true,
      target: ts.ScriptTarget.ES2020,
    },
    fileName: absolutePath,
  });

  const module = { exports: {} };
  const customRequire = (specifier) => {
    const resolved = resolveSpecifier(absolutePath, specifier);
    if (resolved) {
      return loadModule(resolved);
    }
    return nativeRequire(specifier);
  };

  const fn = new Function('require', 'module', 'exports', '__filename', '__dirname', outputText);
  fn(customRequire, module, module.exports, absolutePath, path.dirname(absolutePath));

  moduleCache.set(absolutePath, module.exports);
  return module.exports;
}

export const loadTsModule = (relativePath) => {
  const absolutePath = path.resolve(projectRoot, relativePath);
  return loadModule(absolutePath);
};

export { projectRoot };
