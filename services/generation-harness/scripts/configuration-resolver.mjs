// Read-only metadata worker. The caller starts Node with filesystem permissions,
// no child-process permission, isolated HOME, and offline package resolution.
import fs from 'node:fs';
import { syncBuiltinESMExports } from 'node:module';
import { DefaultPackageManager, SettingsManager } from 'generation-harness-core';
const payload=JSON.parse(fs.readFileSync(0,'utf8'));
let blockedProbes=0;
const exists=fs.existsSync;
fs.existsSync=function(path) {
  try {return exists(path);} catch(error) {
    if(error.code!=='ERR_ACCESS_DENIED') throw error;
    blockedProbes++;return false;
  }
};
syncBuiltinESMExports();
async function resolve(projectTrusted) {
  const settingsManager=SettingsManager.fromStorage({withLock(scope,callback) {
    const result=callback(JSON.stringify(scope==='global'?payload.user:payload.project));
    if(result!==undefined) throw new Error('Read-only settings storage');
  }},{projectTrusted});
  // Even native legacy-global npm fallback cannot execute a user command here:
  // Node's child-process permission is deliberately not granted.
  const manager=new DefaultPackageManager({cwd:payload.root,agentDir:payload.agentDir,settingsManager});
  const paths=await manager.resolve(async()=> 'skip');
  return {paths,packages:manager.listConfiguredPackages()};
}
try {
  const global=await resolve(false),project=await resolve(true);
  console.log(JSON.stringify({global:global.paths,project:project.paths,packages:project.packages,blockedProbes,inspection:'NATIVE_DISCOVERY_ONLY_NOT_EXECUTED',authorizesLivePilot:false}));
} catch(error) {console.error(`Resource inspection failed: ${error.code??error.message}`);process.exitCode=1;}
