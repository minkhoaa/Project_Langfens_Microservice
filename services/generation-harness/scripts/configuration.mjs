// Native-settings adapter only: never creates a model runtime, session, or extension loader.
import { existsSync, lstatSync, mkdirSync, readFileSync, realpathSync, renameSync, unlinkSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve, sep } from 'node:path';
import { randomUUID } from 'node:crypto';
import { Value } from 'typebox/value';
import { SettingsManager } from 'generation-harness-core';
import { harnessRoot } from './runtime.mjs';
const schemaPath=join(harnessRoot,'packages/generation-harness-core/schemas/settings.schema.json');
const schema=JSON.parse(readFileSync(schemaPath,'utf8'));
export const preferences=[
  {key:'defaultProvider',label:'Default provider',method:'getDefaultProvider'},
  {key:'defaultModel',label:'Default model ID',method:'getDefaultModel'},
  {key:'defaultThinkingLevel',label:'Thinking level',method:'getDefaultThinkingLevel',fallback:'medium',values:['off','minimal','low','medium','high','xhigh','max']},
  {key:'theme',label:'Theme',method:'getTheme',fallback:'system',values:['system','dark','light']},
  {key:'hideThinkingBlock',label:'Hide thinking',method:'getHideThinkingBlock',values:['false','true']},
  {key:'quietStartup',label:'Quiet startup',method:'getQuietStartup',values:['false','header','true']},
  {key:'transport',label:'Provider transport',method:'getTransport',values:['auto','sse','websocket','websocket-cached']},
  {key:'compaction.enabled',label:'Auto compaction',method:'getCompactionEnabled',values:['false','true']},
  {key:'cacheWarming',label:'Cache warming',method:'getCacheWarmingMode',values:['off','streaming','idle']},
  {key:'retry.enabled',label:'Agent retry',method:'getRetryEnabled',values:['false','true']},
  {key:'tuiMode',label:'TUI mode',method:'getTuiMode',fallback:'fullscreen',values:['fullscreen','regular']},
  {key:'fullscreenCopyOnSelect',label:'Copy on mouse select',method:'getFullscreenCopyOnSelect',fallback:'true',values:['true','false']},
];
const editable=new Set([...preferences.map(p=>p.key),'compaction.reserveTokens','compaction.keepRecentTokens','retry.maxRetries','retry.provider.maxRetries']);
const get=(object,key)=>key.split('.').reduce((v,k)=>v?.[k],object);
const safeText=value=>String(value).replace(/[\u0000-\u001f\u007f-\u009f]/g,'');
function checkFile(path,root) {
  // Never follow a settings symlink into another configuration/credential tree.
  let existing=path;
  while(!existsSync(existing)) {const parent=dirname(existing);if(parent===existing) break;existing=parent;}
  if(existsSync(root)) {
    const base=realpathSync(root), actual=realpathSync(existing);
    if(actual!==base && !actual.startsWith(base+sep)) throw new Error('Configuration path escapes its selected root');
  }
  if(existsSync(path) && lstatSync(path).isSymbolicLink()) throw new Error('Settings symlinks are not supported');
}
function load(path,root) {
  checkFile(path,root);
  if(!existsSync(path)) return {};
  const data=JSON.parse(readFileSync(path,'utf8').replace(/^\uFEFF/,''));
  if(!Value.Check(schema,data)) throw new Error(`Invalid native settings schema: ${path}`);
  return data;
}
export function configuration({root=harnessRoot,env=process.env,scope='user'}={}) {
  if(!['project','user'].includes(scope)) throw new Error('Scope must be project or user');
  root=realpathSync(root);
  const runtime=resolve(env.GENERATION_HARNESS_RUNTIME_DIR || join(root,'.runtime'));
  if(existsSync(runtime) && lstatSync(runtime).isSymbolicLink()) throw new Error('Runtime root must not be a symlink');
  const authPath = join(runtime, 'agent/auth.json');
  const modelsStorePath = join(runtime, 'agent/models-store.json');

  const paths = {
    project: join(root, '.generation/settings.json'),
    user: join(runtime, 'agent/settings.json'),
    auth: authPath,
    models: join(runtime, 'agent/models.json'),
    modelsStore: modelsStorePath,
    modelsExample: join(root, '.generation/config/models.example.json'),
    settingsSchema: schemaPath,
    modelsSchema: join(harnessRoot, 'packages/generation-harness-core/schemas/models.schema.json'),
    rubric: join(root, '.generation/evaluation/rubric.json')
  };
  const target=paths[scope], targetRoot=scope==='project'?root:runtime;

  function inspectAuthFile(filePath) {
    if (!filePath || !existsSync(filePath)) return [];
    try {
      const raw = readFileSync(filePath, 'utf8');
      const data = JSON.parse(raw);
      if (!data || typeof data !== 'object' || Array.isArray(data)) return [];
      return Object.entries(data).map(([provider, val]) => ({
        provider,
        type: typeof val === 'object' && val?.type ? val.type : 'unknown',
        status: 'configured'
      }));
    } catch {
      return [];
    }
  }

  function getAuthProviders() {
    return inspectAuthFile(authPath);
  }

  const KNOWN_ENV_PROVIDERS = [
    { key: 'OPENAI_API_KEY', provider: 'openai' },
    { key: 'ANTHROPIC_API_KEY', provider: 'anthropic' },
    { key: 'GEMINI_API_KEY', provider: 'google' },
    { key: 'MINIMAX_API_KEY', provider: 'minimax' },
    { key: 'MISTRAL_API_KEY', provider: 'mistral' },
    { key: 'GROQ_API_KEY', provider: 'groq' },
    { key: 'DEEPSEEK_API_KEY', provider: 'deepseek' },
    { key: 'COHERE_API_KEY', provider: 'cohere' },
  ];

  function getEnvironmentProviders() {
    const list = [];
    for (const item of KNOWN_ENV_PROVIDERS) {
      if (env[item.key]) list.push({ provider: item.provider, envVar: item.key, status: 'configured' });
    }
    return list;
  }

  function setProviderApiKey(provider, apiKey) {
    if (!provider || typeof provider !== 'string' || !provider.trim()) {
      throw new Error('Provider name is required');
    }
    if (!apiKey || typeof apiKey !== 'string' || !apiKey.trim()) {
      throw new Error('API key is required');
    }
    const cleanProvider = safeText(provider.trim().toLowerCase());
    const cleanKey = apiKey.trim();

    let currentAuth = {};
    if (existsSync(authPath)) {
      try {
        currentAuth = JSON.parse(readFileSync(authPath, 'utf8'));
      } catch {
        currentAuth = {};
      }
    }
    currentAuth[cleanProvider] = {
      type: 'api_key',
      key: cleanKey
    };
    mkdirSync(dirname(authPath), { recursive: true, mode: 0o700 });
    writeFileSync(authPath, JSON.stringify(currentAuth, null, 2) + '\n', { mode: 0o600 });
    return {
      provider: cleanProvider,
      status: 'configured',
      authPath
    };
  }

  function removeProviderApiKey(provider) {
    if (!provider || typeof provider !== 'string' || !provider.trim()) {
      throw new Error('Provider name is required');
    }
    const cleanProvider = safeText(provider.trim().toLowerCase());
    if (!existsSync(authPath)) return { removed: false };
    let currentAuth = {};
    try {
      currentAuth = JSON.parse(readFileSync(authPath, 'utf8'));
    } catch {
      return { removed: false };
    }
    if (!(cleanProvider in currentAuth)) return { removed: false };
    delete currentAuth[cleanProvider];
    writeFileSync(authPath, JSON.stringify(currentAuth, null, 2) + '\n', { mode: 0o600 });
    return { removed: true, provider: cleanProvider };
  }
  function snapshot() {
    const user=load(paths.user,runtime),project=load(paths.project,root);
    const manager=SettingsManager.inMemory(user);manager.applyOverrides(project);
    return {user,project,manager};
  }
  function show() {
    const {manager,user,project}=snapshot();
    const localCreds = getAuthProviders();
    const envCreds = getEnvironmentProviders();
    return {
      scope,
      paths,
      projectSettingsApplyTo:'Trusted project cwd, e.g. npm run start:reading; default npm start uses the scratch workspace',
      precedence:['CLI (when launching)','trusted project settings','isolated user settings','native defaults'],
      preferences:Object.fromEntries(preferences.map(p=>[p.key,{value:manager[p.method]()??p.fallback??null,source:get(project,p.key)!==undefined?'project':get(user,p.key)!==undefined?'user':'native default'}])),
      credentials: {
        storagePath: authPath,
        isolation: "PROJECT_LOCAL_ONLY",
        configuredProviders: localCreds,
        environmentProviders: envCreds
      },
      offlineEvaluationOnly:true,
      authorizesLivePilot:false
    };
  }
  function editSettings(mutator) {
    const current=load(target,targetRoot),previous=existsSync(target)?readFileSync(target,'utf8'):null;
    mutator(current);
    if(!Value.Check(schema,current)) throw new Error('Invalid native settings schema after edit');
    checkFile(target,targetRoot);
    mkdirSync(dirname(target),{recursive:true,mode:0o700});
    const temp=join(dirname(target),`.settings-${randomUUID()}.tmp`);
    try {
      writeFileSync(temp,JSON.stringify(current,null,2)+'\n',{mode:0o600,flag:'wx'});
      if((existsSync(target)?readFileSync(target,'utf8'):null)!==previous) throw new Error('Settings changed concurrently; retry the edit');
      renameSync(temp,target);
    } finally {if(existsSync(temp)) unlinkSync(temp);}
    return show();
  }
  function update(key,raw,remove=false) {
    if(!editable.has(key)) throw new Error(`Unsupported preference: ${key}`);
    let value=raw;
    if(!remove) {
      try {value=JSON.parse(raw);} catch {value=raw;}
      if(typeof value==='string' && (value!==safeText(value) || !value.trim())) throw new Error('Use nonempty text without terminal control characters');
    }
    if(['compaction.reserveTokens','compaction.keepRecentTokens','retry.maxRetries','retry.provider.maxRetries'].includes(key) && !remove && (!Number.isSafeInteger(value) || value<0)) throw new Error('Expected a nonnegative safe integer');
    return editSettings(current=>{
      const parts=key.split('.');let parent=current;
      for(const part of parts.slice(0,-1)) parent=parent[part]??={};
      if(remove) delete parent[parts.at(-1)];else parent[parts.at(-1)]=value;
    });
  }
  const forScope=next=>configuration({root,env,scope:next});
  return {
    root,
    runtime,
    scope,
    paths,
    target,
    show,
    update,
    editSettings,
    forScope,
    snapshot,
    safeText,
    getAuthProviders,
    getEnvironmentProviders,
    setProviderApiKey,
    removeProviderApiKey
  };
}
