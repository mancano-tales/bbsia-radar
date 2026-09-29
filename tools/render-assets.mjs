#!/usr/bin/env node
// Gera somente ativos estáticos. Não lê dados do radar nem aciona Quarto/Pages.
import { existsSync, mkdtempSync, readFileSync, renameSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const assets = join(root, 'report', 'assets');
const options = process.argv.slice(2);
const checkOnly = options.includes('--check');
if (options.some(arg => arg !== '--check')) {
  console.error('Uso: node tools/render-assets.mjs [--check]');
  process.exit(2);
}

const variants = [
  { file: 'bbsia-logo-512.png', svg: 'bbsia-logo.svg', width: 512, height: 512 },
  { file: 'bbsia-logo-1024.png', svg: 'bbsia-logo.svg', width: 1024, height: 1024 },
  { file: 'apple-touch-icon.png', svg: 'bbsia-logo.svg', width: 180, height: 180 },
  { file: 'favicon-32x32.png', svg: 'bbsia-logo.svg', width: 32, height: 32 },
  { file: 'bbsia-radar-horizontal.png', svg: 'bbsia-radar-horizontal.svg', width: 640, height: 160 },
  { file: 'og-image.png', svg: 'bbsia-radar-horizontal.svg', width: 1200, height: 630, og: true },
];

function pngDimensions(file) {
  const data = readFileSync(file);
  if (data.length < 33 || !data.subarray(0, 8).equals(Buffer.from('89504e470d0a1a0a', 'hex')) || data.toString('ascii', 12, 16) !== 'IHDR') {
    throw new Error(`${file}: assinatura PNG ou IHDR inválido`);
  }
  return { width: data.readUInt32BE(16), height: data.readUInt32BE(20) };
}

function validate(file, width, height) {
  const found = pngDimensions(file);
  if (found.width !== width || found.height !== height) {
    throw new Error(`${file}: esperado ${width}x${height}, recebido ${found.width}x${found.height}`);
  }
  if (statSync(file).size < 100) throw new Error(`${file}: arquivo vazio ou truncado`);
}

function browserCandidates() {
  if (process.env.BBSIA_BROWSER) return [process.env.BBSIA_BROWSER];
  const locations = [];
  if (process.platform === 'win32') {
    for (const base of [process.env['ProgramFiles(x86)'], process.env.ProgramFiles, process.env.LOCALAPPDATA].filter(Boolean)) {
      locations.push(join(base, 'Microsoft', 'Edge', 'Application', 'msedge.exe'));
      locations.push(join(base, 'Google', 'Chrome', 'Application', 'chrome.exe'));
    }
    locations.push('msedge.exe', 'chrome.exe');
  } else {
    locations.push('chromium', 'chromium-browser', 'google-chrome', 'microsoft-edge');
  }
  return locations.filter((candidate, index) => locations.indexOf(candidate) === index);
}

function htmlFor(variant) {
  const svg = readFileSync(join(assets, variant.svg), 'utf8');
  const art = variant.og
    ? `<main><div class="banner">${svg}</div><div class="rule"></div></main>`
    : svg;
  const css = variant.og
    ? `html,body{margin:0;width:1200px;height:630px;overflow:hidden}main{position:relative;width:1200px;height:630px;background:#eef5f9}.banner{position:absolute;left:100px;top:165px;width:1000px;height:250px}.banner svg{display:block;width:100%;height:100%}.rule{position:absolute;bottom:0;width:100%;height:16px;background:linear-gradient(90deg,#356CAF,#019480)}`
    : `html,body{margin:0;width:${variant.width}px;height:${variant.height}px;overflow:hidden}svg{display:block;width:${variant.width}px;height:${variant.height}px}`;
  return `<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><style>${css}</style></head><body>${art}</body></html>`;
}

function renderWith(browser, variant, workspace) {
  const html = join(workspace, `${variant.file}.html`);
  const screenshot = join(workspace, variant.file);
  const profile = join(workspace, `profile-${variant.file}`);
  writeFileSync(html, htmlFor(variant), 'utf8');
  const args = [
    '--headless=new', '--disable-gpu', '--disable-extensions', '--hide-scrollbars',
    '--no-first-run', '--no-default-browser-check', '--force-device-scale-factor=1',
    `--user-data-dir=${profile}`, `--window-size=${variant.width},${variant.height}`,
    `--screenshot=${screenshot}`, pathToFileURL(html).href,
  ];
  const run = spawnSync(browser, args, { encoding: 'utf8', timeout: 45000, windowsHide: true });
  if (run.error || run.status !== 0 || !existsSync(screenshot)) {
    const diagnostic = (run.stderr || run.error?.message || `exit ${run.status}`).trim().split(/\r?\n/).slice(-2).join(' | ');
    throw new Error(`${browser}: ${diagnostic || 'captura não produzida'}`);
  }
  validate(screenshot, variant.width, variant.height);
  return screenshot;
}

let workspace;
try {
  if (!checkOnly) {
    workspace = mkdtempSync(join(tmpdir(), 'bbsia-assets-'));
    let chosen;
    const generated = [];
    for (const variant of variants) {
      let result;
      const errors = [];
      const candidates = browserCandidates();
      for (const browser of chosen ? [chosen, ...candidates.filter(item => item !== chosen)] : candidates) {
        try {
          result = renderWith(browser, variant, workspace);
          chosen = browser;
          break;
        } catch (error) {
          errors.push(error.message);
        }
      }
      if (!result) throw new Error(`Falha ao gerar ${variant.file}:\n${errors.join('\n')}`);
      generated.push({ variant, result });
    }
    const svgNames = ['bbsia-source-icon.svg', 'bbsia-logo.svg', 'bbsia-logo-transparent.svg', 'bbsia-radar-horizontal.svg'];
    const pendingBytes = svgNames.reduce((sum, name) => sum + statSync(join(assets, name)).size, 0)
      + generated.reduce((sum, item) => sum + statSync(item.result).size, 0);
    if (pendingBytes >= 500000) throw new Error(`pacote excede 500 KB: ${pendingBytes} bytes`);
    for (const { variant, result } of generated) {
      renameSync(result, join(assets, variant.file));
      console.log(`gerado ${variant.file} (${variant.width}x${variant.height})`);
    }
    console.log(`navegador: ${chosen}`);
  }
  for (const variant of variants) validate(join(assets, variant.file), variant.width, variant.height);
  const names = ['bbsia-source-icon.svg', 'bbsia-logo.svg', 'bbsia-logo-transparent.svg', 'bbsia-radar-horizontal.svg', ...variants.map(v => v.file)];
  const bytes = names.reduce((sum, name) => sum + statSync(join(assets, name)).size, 0);
  if (bytes >= 500000) throw new Error(`pacote excede 500 KB: ${bytes} bytes`);
  console.log(`verificado: ${variants.length} PNGs, pacote ${bytes} bytes`);
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
} finally {
  if (workspace) rmSync(workspace, { recursive: true, force: true });
}
