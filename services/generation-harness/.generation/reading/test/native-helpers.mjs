import '../../../test/offline.mjs';
import { mkdtempSync,mkdirSync,writeFileSync,rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createAgentSession,DefaultResourceLoader,ModelRuntime,SessionManager,SettingsManager } from 'generation-harness-core';
import { InMemoryCredentialStore,fauxAssistantMessage,fauxProvider,fauxToolCall } from 'generation-ai';
import reading from '../../extensions/reading.ts';
import * as subagents from 'generation-subagents';
export const entry=fileURLToPath(new URL('../../extensions/reading.ts',import.meta.url));
export async function createNativeFixture(t,{loading='factory',withReading=true}={}) {
 const cwd=mkdtempSync(join(tmpdir(),'reading-native-')),agentDir=join(cwd,'agent');
 t.after(()=>rmSync(cwd,{recursive:true,force:true}));
 mkdirSync(join(cwd,'.generation','agents'),{recursive:true});
 writeFileSync(join(cwd,'.generation','agents','fixture-reader.md'),'---\nname: fixture-reader\ntools: [read]\n---\nUse public task inputs only.');
 const agents=subagents.discoverAgents(cwd,agentDir);
 if(loading==='discovery'||loading==='both'){
  mkdirSync(join(cwd,'.generation','extensions'),{recursive:true});
  writeFileSync(join(cwd,'.generation','extensions','reading.ts'),`export {default} from ${JSON.stringify(new URL('../../extensions/reading.ts',import.meta.url).href)};`);
 }
 const modelRuntime=await ModelRuntime.create({credentials:new InMemoryCredentialStore(),modelsPath:null,refreshOnCreate:false});
 const faux=fauxProvider({models:[{id:'parent'}]});modelRuntime.registerNativeProvider(faux.provider);
 const settingsManager=SettingsManager.inMemory({cacheWarming:'off',retry:{enabled:false},compaction:{enabled:false}});
 const loader=new DefaultResourceLoader({cwd,agentDir,settingsManager,noExtensions:loading==='factory',noSkills:true,noThemes:true,noPromptTemplates:true,noContextFiles:true,
  ...(loading==='explicit'?{additionalExtensionPaths:[entry]}:loading==='both'?{additionalExtensionPaths:[join(cwd,'.generation','extensions','reading.ts')]}:{}),
  extensionFactories:withReading&&loading==='factory'?[reading]:[]});
 await loader.reload();
 const {session}=await createAgentSession({cwd,agentDir,modelRuntime,model:faux.getModel('parent'),resourceLoader:loader,settingsManager,sessionManager:SessionManager.inMemory(cwd)});
 t.after(async()=>{try{await session.extensionRunner.emit({type:'session_shutdown',reason:'quit'});}finally{session.dispose();}});
 await session.bindExtensions({mode:'rpc'});
 const childContext={cwd,agentDir,sessionDir:join(cwd,'children'),parentSessionId:'parent-private-history',modelRuntime,parentModel:faux.getModel('parent'),agents};
 async function invoke(name,args){let result;
  // Native execution events retain structuredContent; transcript messages intentionally do not.
  const unsubscribe=session.subscribe(e=>{if(e.type==='tool_execution_end'&&e.toolName===name)result=e.result;});
  faux.setResponses([fauxAssistantMessage(fauxToolCall(name,args),{stopReason:'toolUse'}),fauxAssistantMessage('done')]);
  try{await session.prompt('Run the requested offline tool call.');if(!result)throw Error('No native tool result');return result;}finally{unsubscribe();}
 }
 return {cwd,agentDir,session,faux,loader,subagents,childContext,definitions:session.getAllTools().filter(d=>!['read','bash','edit','write'].includes(d.name)),invoke};
}
