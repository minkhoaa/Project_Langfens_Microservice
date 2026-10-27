import './offline.mjs';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import { runtimeLaunch } from '../scripts/runtime.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

test('workspace installation exposes Langfens packages and the local harness command', () => {
  const manifests = readdirSync(join(root, 'packages')).filter(name => existsSync(join(root, 'packages', name, 'package.json')))
    .map(name => JSON.parse(readFileSync(join(root, 'packages', name, 'package.json'), 'utf8')));
  assert.ok(manifests.some(pkg => pkg.name === 'langfens-harness-core'));
  assert.ok(manifests.every(pkg => pkg.name.startsWith('langfens-')));
  const core = manifests.find(pkg => pkg.name === 'langfens-harness-core');
  assert.deepEqual(core.bin, { 'langfens-harness': 'bin/langfens-harness.mjs' });
  assert.equal(core.langfensConfig.configDir, '.langfens');
});

test('local CLI identifies itself without global executable or configuration', () => {
  const launch = runtimeLaunch(['--source', '--help']);
  const help = execFileSync(launch.command, launch.args, { cwd: launch.cwd, env: launch.env, encoding: 'utf8', timeout: 20000 });
  assert.match(help, /langfens-harness/);
  assert.doesNotMatch(help, /@(?:earendil-works|mariozechner)\/pi-|~\/\.pi\b/);
  assert.equal(launch.env.LANGFENS_HARNESS_AGENT_DIR, join(launch.runtime, 'agent'));
  assert.ok(Object.keys(launch.env).every(key => !key.startsWith('PI_')));
});
