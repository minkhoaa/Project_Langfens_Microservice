// Resource metadata and native settings filters; never imports or executes a resource.
import { execFile } from 'node:child_process';
import { dirname, basename, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { harnessRoot, ownedSubagentEntry } from './runtime.mjs';
export const resourceTypes=['extensions','skills','prompts','themes'];
const remote=source=>/^(npm:|git:|https?:\/\/|ssh:\/\/|git@)/.test(source);
const strip=entry=>/^[!+-]/.test(entry)?entry.slice(1):entry;
const slash=path=>path.split(sep).join('/');
const source=pkg=>typeof pkg==='string'?pkg:pkg.source;
const resourceId=row=>`${row.type}:${row.path}`;
function localPath(controller,text,scope) {
  if(text.startsWith('~/')) return resolve(controller.runtime,'home',text.slice(2));
  return resolve(dirname(controller.paths[scope]),text);
}
function packageIndex(controller,packages,row,scope) {
  return packages.findIndex(pkg=>source(pkg)===row.metadata.source || (!remote(source(pkg)) && localPath(controller,source(pkg),scope)===row.metadata.packageRoot));
}
function aliases(controller,row,scope) {
  return new Set([row.path,slash(relative(dirname(controller.paths[scope]),row.path)),...(row.metadata.baseDir?[slash(relative(row.metadata.baseDir,row.path))]:[])]);
}
function exactState(entries,patterns,emptyIsUnload=false) {
  if(entries?.length===0 && emptyIsUnload) return 'unload';
  // Native exact '-' exclusion wins over '+' regardless of entry order.
  if(entries?.some(e=>e.startsWith('-') && patterns.has(strip(e)))) return 'unload';
  if(entries?.some(e=>e.startsWith('+') && patterns.has(strip(e)))) return 'load';
  return 'inherit';
}
export async function inspectResources(controller) {
  const {user,project}=controller.snapshot();
  const worker=fileURLToPath(new URL('./configuration-resolver.mjs',import.meta.url));
  const allowed=new Set([harnessRoot,controller.root,controller.runtime]);
  if(controller.root===harnessRoot) allowed.add(resolve(harnessRoot,'../..'));
  const args=['--permission'];
  for(const root of allowed) {
    if(root.includes('*')) throw new Error('Wildcard configuration roots are unsupported');
    args.push(`--allow-fs-read=${root}`,`--allow-fs-read=${root}${sep}*`);
  }
  if(globalThis.__GENERATION_NETWORK_GUARD_INSTALLED__) args.push('--import',join(harnessRoot,'test/offline.mjs'));
  args.push(worker);
  // Do not inherit provider keys, Pi/XDG config, NODE preloads/extra CAs, cloud
  // credential paths, npm options, or host PATH into metadata inspection.
  const env={PATH:''};
  for(const key of ['SystemRoot','WINDIR','LANG','LC_ALL','TZ']) if(process.env[key]) env[key]=process.env[key];
  const home=join(controller.runtime,'home');
  Object.assign(env,{HOME:home,USERPROFILE:home,XDG_CONFIG_HOME:join(home,'.config'),XDG_CACHE_HOME:join(home,'.cache'),XDG_DATA_HOME:join(home,'.local/share'),GENERATION_HARNESS_AGENT_DIR:dirname(controller.paths.user),GENERATION_HARNESS_OFFLINE:'1',GENERATION_HARNESS_TELEMETRY:'0',GENERATION_HARNESS_SKIP_VERSION_CHECK:'1',npm_config_prefix:join(controller.runtime,'packages/npm'),npm_config_cache:join(controller.runtime,'packages/.npm-cache')});
  const catalog=await new Promise((accept,reject)=>{
    const child=execFile(process.execPath,args,{cwd:controller.root,env,encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024},(error,stdout)=>{
      if(error) {reject(new Error('Native resource inspection failed; no resources were executed or installed'));return;}
      try {accept(JSON.parse(stdout));} catch {reject(new Error('Invalid native resource inventory'));}
    });
    child.stdin.on('error',()=>{});
    child.stdin.end(JSON.stringify({root:controller.root,agentDir:dirname(controller.paths.user),user,project}));
  });
  catalog.launcher=controller.root===harnessRoot?[{type:'extensions',path:ownedSubagentEntry(),enabled:true,locked:true,name:'generation-subagents (CLI --extension; fixed)',metadata:{source:'launcher',scope:'user',origin:'launcher'}}]:[];
  return catalog;
}
export function resourceRows(controller,catalog,scope=controller.scope) {
  const settings=controller.snapshot().project;
  const rows=[...resourceTypes.flatMap(type=>(catalog[scope==='user'?'global':'project'][type]??[]).map(item=>{
    const row={...item,type};row.id=resourceId(row);
    row.name=type==='skills' && basename(item.path)==='SKILL.md'?basename(dirname(item.path)):item.metadata.packageRoot?slash(relative(item.metadata.packageRoot,item.path)):basename(item.path);
    row.group=item.metadata.origin==='package'?`${item.metadata.source} (${item.metadata.scope})`:item.metadata.source==='auto'?`${item.metadata.scope==='user'?'User':'Project'} (${item.metadata.baseDir})`:`${item.metadata.scope==='user'?'User':'Project'} settings`;
    row.state='inherit';
    if(scope==='project') {
      if(item.metadata.origin==='package') {
        const index=packageIndex(controller,settings.packages??[],row,'project'),pkg=settings.packages?.[index];
        if(typeof pkg==='object') row.state=exactState(pkg[type],new Set([slash(relative(item.metadata.packageRoot,item.path))]),pkg.autoload!==false);
      } else row.state=exactState(settings[type],aliases(controller,row,'project'));
    }
    return row;
  })),...catalog.launcher.map(row=>({...row,id:resourceId(row),state:'inherit',group:'Launcher (always loaded unless --no-extensions)'}))];
  const fixed=new Set(catalog.launcher.map(resourceId));
  const rank=row=>row.metadata.origin==='package'?0:row.locked?2:1;
  return rows.filter(row=>row.locked || !fixed.has(row.id)).sort((a,b)=>rank(a)-rank(b) || (a.group<b.group?-1:a.group>b.group?1:0) || resourceTypes.indexOf(a.type)-resourceTypes.indexOf(b.type) || (a.name<b.name?-1:a.name>b.name?1:0));
}
export function toggleResource(controller,catalog,row) {
  const current=resourceRows(controller,catalog).find(r=>r.id===row.id);
  if(!current || current.locked) throw new Error('This resource is not configurable in settings (CLI override)');
  row=current;
  const inherited=resourceTypes.flatMap(type=>(catalog.global[type]??[]).map(item=>({type,...item}))).find(item=>resourceId(item)===row.id)?.enabled??true;
  const state=controller.scope==='user'?row.enabled?'unload':'load':row.state==='inherit'?inherited?'unload':'load':row.state==='unload'?inherited?'load':'inherit':inherited?'inherit':'unload';
  controller.editSettings(settings=>{
    if(row.metadata.origin==='package') {
      const packages=settings.packages??=[],index=packageIndex(controller,packages,row,controller.scope);
      let pkg=index<0?null:packages[index];
      if(!pkg) {
        if(controller.scope!=='project') throw new Error('Resource package declaration changed; refresh config');
        pkg={source:remote(row.metadata.source)?row.metadata.source:slash(relative(dirname(controller.paths.project),row.metadata.packageRoot))||'.',autoload:false};packages.push(pkg);
      } else if(typeof pkg==='string') {pkg={source:pkg};packages[index]=pkg;}
      const pattern=slash(relative(row.metadata.packageRoot,row.path)),prior=pkg[row.type];
      let entries=(prior??[]).filter(entry=>strip(entry)!==pattern);
      // [] means ALL disabled in the native package contract. Preserve that baseline
      // when enabling one item; '+one' alone would unexpectedly enable siblings.
      if(prior?.length===0 && pkg.autoload!==false) entries=['!*','!.*'];
      if(state!=='inherit') entries.push(`${state==='load'?'+':'-'}${pattern}`);
      if(entries.length) pkg[row.type]=entries;else delete pkg[row.type];
      if(!resourceTypes.some(type=>pkg[type]!==undefined)) {
        const at=packages.indexOf(pkg);
        if(pkg.autoload===false) packages.splice(at,1);else packages[at]=pkg.source;
      }
      settings.packages=packages;
    } else {
      const patterns=aliases(controller,row,controller.scope),pattern=row.path;
      let entries=(settings[row.type]??[]).filter(entry=>!(/^[!+-]/.test(entry) && patterns.has(strip(entry))));
      const inheritedItem=!!resourceTypes.flatMap(type=>(catalog.global[type]??[]).map(item=>({type,...item}))).find(item=>resourceId(item)===row.id);
      if(controller.scope==='project' && inheritedItem) entries=entries.filter(entry=>entry!==pattern);
      if(state!=='inherit') {
        if(controller.scope==='project' && inheritedItem && !entries.includes(pattern)) entries.push(pattern);
        entries.push(`${state==='load'?'+':'-'}${pattern}`);
      }
      settings[row.type]=entries;
    }
  });
  return state;
}
