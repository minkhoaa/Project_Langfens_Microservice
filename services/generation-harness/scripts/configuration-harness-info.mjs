// Metadata only: use public native discovery/declarations, never execute tool handlers.
import { join } from 'node:path';
import { createAllToolDefinitions } from 'generation-harness-core/tools';
import { discoverAgents,createSubagentExtension } from 'generation-subagents';
import { createReadingTools } from '../.generation/reading/tools.ts';
import { harnessRoot } from './runtime.mjs';

export function getHarnessRoles() {
  return [{id:'reading',name:'IELTS Reading Tools',status:'Available',scope:'Seven independent domain tools; no prescribed workflow or fixed Question count',description:'Canonical validation, evidence mechanics, serialization checks and public projection. Generation and delegation remain model-directed.',contracts:'Canonical v1; actual consumer parity, semantic quality and independent blindness remain UNVERIFIED.'}];
}

export function getHarnessAgents(root=harnessRoot,runtime=join(root,'.runtime')) {
  return discoverAgents(root,join(runtime,'agent')).map(agent=>({
    ...agent,description:'Discovered native agent definition',file:'Native project/runtime discovery',
    tools:agent.tools??[],excludeTools:agent.excludeTools??[],context:'Native fresh child session (not filesystem isolation)',
    promptMode:'native',summary:(agent.systemPrompt??'').trim().split(/\n\s*\n/)[0].replace(/\r?\n/g,' '),
  }));
}

function describe(definition,scope,policy) {
  return {name:definition.name,scope,description:definition.description,
    parameters:JSON.stringify(definition.parameters??{}),policy};
}

export function getHarnessTools(root=harnessRoot,{runtimeTools,activeTools=[]}={}) {
  const core=Object.values(createAllToolDefinitions(root)).map(tool=>describe(tool,'Built-in','Native tool behavior; CWD separation is not a filesystem sandbox.'));
  const reading=createReadingTools().map(tool=>describe(tool,'Reading extension (available; requires loading)','Deterministic canonical checks; unsupported consumer/semantic capabilities remain UNVERIFIED.'));
  // Public foreground SDK declarations are safe to inspect without invoking a child.
  const delegation=[];
  createSubagentExtension({agents:[],disabledFeatures:['workflow-scripts']})({on(){},registerTool(tool){delegation.push(describe(tool,'Native foreground SDK declaration','Runtime native Subagents may expose additional tools; no agent is launched by this inventory.'));}});
  const categories=[{category:'Built-in Core Tools',items:core},{category:'Subagents Substrate Tools',items:delegation},{category:'IELTS Reading Domain Tools',items:reading}];
  if(runtimeTools){
    const active=new Set(activeTools);
    categories.unshift({category:'Current Native Session Tools',items:runtimeTools.map(tool=>({...describe(tool,active.has(tool.name)?'Active in this session':'Registered but inactive','Native runtime inventory; not a consumer compatibility or isolation claim.')}))});
  }
  return categories;
}
