#!/usr/bin/env node
'use strict';

const readline = require('readline');
const { spawnSync } = require('child_process');

const [SERVER] = require('./servers.json');

// Written by installer 1.x (four servers, X-API-Key). Offered for removal so stale entries don't linger.
const LEGACY_SERVERS = [
  'mercury-market-data',
  'mercury-darth-feedor',
  'mercury-econ-data',
  'mercury-pubfinance',
];

const DRY_RUN = process.argv.includes('--dry-run');

// ── Terminal helpers ──────────────────────────────────────────────────────────

const dim    = (s) => `\x1b[2m${s}\x1b[0m`;
const bold   = (s) => `\x1b[1m${s}\x1b[0m`;
const green  = (s) => `\x1b[32m${s}\x1b[0m`;
const yellow = (s) => `\x1b[33m${s}\x1b[0m`;
const red    = (s) => `\x1b[31m${s}\x1b[0m`;
const cyan   = (s) => `\x1b[36m${s}\x1b[0m`;

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const prompt = (question) => new Promise((resolve) => rl.question(question, (a) => resolve(a.trim())));

// ── Claude Code CLI helpers ───────────────────────────────────────────────────

function claude(args) {
  if (DRY_RUN) {
    console.log(dim('    [dry-run] ') + ['claude', ...args.map(quote)].join(' '));
    return { ok: true };
  }
  const result = spawnSync('claude', args, { encoding: 'utf8', stdio: 'pipe' });
  return result.status === 0
    ? { ok: true }
    : { ok: false, error: (result.error?.message || result.stderr || result.stdout || '').trim() };
}

function quote(arg) {
  return /^[\w@%+=:,./-]+$/.test(arg) ? arg : `'${arg.replace(/'/g, `'\\''`)}'`;
}

function serverExists(name) {
  if (DRY_RUN) return false;
  return spawnSync('claude', ['mcp', 'get', name], { stdio: 'pipe' }).status === 0;
}

function removeServer(name) {
  for (const scope of ['project', 'user', 'local']) {
    claude(['mcp', 'remove', '-s', scope, name]);
  }
}

// OAuth only: the client signs in and keeps its own tokens. Nothing secret is written here.
function serverConfig() {
  return JSON.stringify({ type: SERVER.transport, url: SERVER.url, oauth: SERVER.oauth });
}

// ── Claude Desktop ────────────────────────────────────────────────────────────

function showDesktopSteps() {
  console.log(bold('  Claude Desktop connects to Mercury as a custom connector:'));
  console.log();
  console.log(`    ${cyan('1')}  Open ${bold('Settings → Connectors')} and choose ${bold('Add custom connector')}.`);
  console.log(`    ${cyan('2')}  Name it ${bold('Mercury')} and paste ${bold(SERVER.url)}`);
  console.log(`    ${cyan('3')}  Click ${bold('Connect')} and sign in with your Mercury account.`);
  console.log();
}

// ── Claude Code ───────────────────────────────────────────────────────────────

async function installClaudeCode() {
  console.log(bold('  Install scope:'));
  console.log();
  console.log(`    ${cyan('1')}  user    ${dim('— all Claude Code sessions')}`);
  console.log(`    ${cyan('2')}  project ${dim('— this repo only (.mcp.json)')}`);
  console.log();

  const scope = (await prompt('  Choose [1]: ')) === '2' ? 'project' : 'user';
  console.log(`  ${dim('Scope:')} ${scope}`);
  console.log();

  const legacy = LEGACY_SERVERS.filter(serverExists);
  if (legacy.length > 0) {
    console.log(yellow('  Found servers from the old four-server setup:'));
    legacy.forEach((name) => console.log(`    ${yellow('!')} ${name}`));
    console.log(dim(`  ${SERVER.name} replaces all of them.`));
    if ((await prompt('  Remove them? [Y/n]: ')).toLowerCase() !== 'n') {
      legacy.forEach(removeServer);
    }
    console.log();
  }

  if (serverExists(SERVER.name)) {
    if ((await prompt(`  ${SERVER.name} is already installed. Reinstall? [y/N]: `)).toLowerCase() !== 'y') {
      console.log(dim('\n  Nothing to install. Exiting.\n'));
      return;
    }
    removeServer(SERVER.name);
    console.log();
  }

  const { ok, error } = claude(['mcp', 'add-json', '-s', scope, SERVER.name, serverConfig()]);
  if (!ok) {
    console.log(`    ${red('✗')} ${SERVER.name}  ${dim(error || 'unknown error')}`);
    console.log();
    process.exit(1);
  }

  console.log(`    ${green('✓')} ${SERVER.name}  ${dim(SERVER.url)}`);
  console.log();
  console.log(bold('  Next:'));
  console.log(`    Start ${bold('claude')}, run ${bold('/mcp')}, select ${bold(SERVER.name)} and choose ${bold('Authenticate')}.`);
  console.log('    Your browser opens the Mercury sign-in; Claude Code stores the session itself.');
  console.log();
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  console.log();
  console.log(bold('  Mercury MCP Installer'));
  console.log(dim('  ─────────────────────────────────────────────'));
  console.log(dim(`  One server, ${SERVER.url}, signed in with OAuth.`));
  console.log();
  console.log(bold('  Set up:'));
  console.log();
  console.log(`    ${cyan('1')}  Claude Code     ${dim('— adds the server via the claude CLI')}`);
  console.log(`    ${cyan('2')}  Claude Desktop  ${dim('— shows the custom connector steps')}`);
  console.log();

  const target = await prompt('  Choose [1]: ');
  console.log();

  if (target === '2') {
    showDesktopSteps();
    return;
  }
  await installClaudeCode();
}

main()
  .catch((err) => {
    console.error(red(`\n  Error: ${err.message}`));
    process.exitCode = 1;
  })
  .finally(() => rl.close());
