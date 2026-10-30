#!/usr/bin/env node
import { configuration } from './configuration.mjs';
const help=`Langfens Harness configuration (no inference)

  npm run config                           Global Resources TUI (Tab: Project; F2: Settings)
  npm run config -- --set-key PROVIDER KEY    Save an API key for a project model provider
  npm run config -- --unset-key PROVIDER      Remove a model provider credential
  npm run config -- --creds                   Show project model credentials and storage path
  npm run config -- --settings                Open the separate preferences panel
  npm run config -- --resources             Inspect native resource metadata as JSON
  npm run config -- --show                  Show preferences plus resource inventory
  npm run config -- --local                 Start in Project Resources
  npm run config -- --paths                 Show exact local configuration locations
  npm run config -- --validate              Validate native user/project settings
  npm run config -- --set KEY VALUE         Save a native preference
  npm run config -- --unset KEY             Remove override, restore inheritance
  npm run config -- --scope project --show  Project overrides (default scope: user)

Examples:
  npm run config -- --set defaultProvider openai
  npm run config -- --set defaultModel YOUR_EXACT_MODEL_ID
  npm run config -- --set defaultThinkingLevel high
  npm run config -- --set retry.enabled false

Project: .generation/settings.json
User: .runtime/agent/settings.json (or GENERATION_HARNESS_RUNTIME_DIR/agent/settings.json)
Models/endpoints: isolated agent/models.json. Credential views read only project runtime provider metadata, never print keys.
Model IDs are entered, not discovered or tested. No new live permission is granted.
See .generation/config/README.md. The frozen Core's CLI 'config' is not re-enabled.
`;
try {
  const args=process.argv.slice(2);let scope='user',action,operands=[];
  for(let i=0;i<args.length;i++) {
    const arg=args[i];
    if(arg==='--local' || arg==='-l') scope='project';
    else if(arg==='--scope') {scope=args[++i];if(!scope) throw new Error('--scope requires project or user');}
    else if(['--show','--settings','--resources','--paths','--validate','--help','--set','--unset','--creds','--set-key','--unset-key'].includes(arg)) {
      if(action) throw new Error('Choose one configuration action');action=arg;
      const count=arg==='--set'?2:arg==='--set-key'?2:arg==='--unset'?1:arg==='--unset-key'?1:0;
      operands=args.slice(i+1,i+1+count);
      if(operands.length!==count || operands.some(v=>v.startsWith('--'))) throw new Error(`${arg} requires ${count} argument(s)`);
      i+=count;
    } else throw new Error(`Unknown configuration option: ${arg}`);
  }
  if(action==='--help') console.log(help);
  else {
    const controller=configuration({scope});let output;
    if(action==='--paths') output={scope,paths:controller.paths};
    else if(action==='--set-key') output=controller.setProviderApiKey(...operands);
    else if(action==='--unset-key') output=controller.removeProviderApiKey(operands[0]);
    else if(action==='--creds') output={credentials:controller.show().credentials};
    else if(action==='--set') output=controller.update(...operands);
    else if(action==='--unset') output=controller.update(operands[0],undefined,true);
    else if(action==='--validate') {controller.snapshot();output={settings:'PASS',catalogCredentialsAndEndpoints:'NOT_ACCESSED',authorizesLivePilot:false};}
    else if(action==='--resources' || action==='--show' || !process.stdin.isTTY || !process.stdout.isTTY) {
      output=controller.show();
      if(action!=='--settings') {
        const {inspectResources}=await import('./configuration-resources.mjs');
        output.resources=await inspectResources(controller);
      }
      if(action==='--show') {
        const {getHarnessRoles,getHarnessAgents,getHarnessTools}=await import('./configuration-harness-info.mjs');
        output.roles=getHarnessRoles();
        output.agents=getHarnessAgents(controller.root,controller.runtime);
        output.tools=getHarnessTools(controller.root);
      }
    } else {
      const {openConfiguration}=await import('./configuration-ui.mjs');
      await openConfiguration(controller,{view:action==='--settings'?'settings':'resources'});
    }
    if(output) console.log(JSON.stringify(output,null,2));
  }
} catch(error) {console.error(error.message);process.exitCode=1;}
