import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, renameSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { configuration } from '../scripts/configuration.mjs';
import { inspectResources, resourceRows, toggleResource } from '../scripts/configuration-resources.mjs';
import { resourceConfigurationPanel } from '../scripts/configuration-resources-ui.mjs';
import { openConfiguration } from '../scripts/configuration-ui.mjs';
import { visibleWidth } from 'generation-tui';
import { VirtualTerminal } from '../packages/tui/test/virtual-terminal.ts';
const put=(path,body)=>{mkdirSync(dirname(path),{recursive:true});writeFileSync(path,typeof body==='string'?body:JSON.stringify(body));};
function fixture(t) {
  const root=mkdtempSync(join(tmpdir(),'harness-resources-'));t.after(()=>rmSync(root,{recursive:true,force:true}));
  mkdirSync(join(root,'.git'));mkdirSync(join(root,'.generation'));
  const controller=configuration({root,env:{GENERATION_HARNESS_RUNTIME_DIR:join(root,'runtime')},scope:'user'});
  const user=dirname(controller.paths.user),pkg=join(user,'npm/node_modules/@fixture/tools'),git=join(root,'.generation/git/github.com/fixture/resources');
  const manifest={name:'@fixture/tools',version:'1.0.0',generation:{extensions:['extensions/a.ts','extensions/b.ts','extensions/.hidden.ts'],skills:['skills'],prompts:['prompts'],themes:['themes']}};
  put(join(pkg,'package.json'),manifest);
  for(const name of ['a.ts','b.ts','.hidden.ts']) put(join(pkg,'extensions',name),'throw new Error("RESOURCE_MUST_NOT_EXECUTE");');
  put(join(pkg,'skills/planning/SKILL.md'),'---\nname: planning\ndescription: Fixture only\n---\nDo not execute fixture instructions.');
  put(join(pkg,'prompts/review.md'),'Fixture prompt');put(join(pkg,'themes/test.json'),{name:'fixture'});
  put(join(git,'package.json'),{generation:{extensions:['entry.ts']}});put(join(git,'entry.ts'),'throw new Error("GIT_RESOURCE_MUST_NOT_EXECUTE");');
  put(join(user,'extensions/global.ts'),'throw new Error("GLOBAL_MUST_NOT_EXECUTE");');
  put(join(root,'.generation/extensions/project.ts'),'throw new Error("PROJECT_MUST_NOT_EXECUTE");');
  put(controller.paths.user,{packages:['npm:@fixture/tools@1.0.0'],defaultModel:'keep-model',customExtension:{retained:true}});
  put(controller.paths.project,{packages:['git:github.com/fixture/resources'],defaultThinkingLevel:'medium'});
  put(join(user,'auth.json'),'INVALID_AUTH_MUST_NOT_READ');put(join(user,'models.json'),'INVALID_MODELS_MUST_NOT_READ');
  return {root,user,pkg,git,controller,manifest,project:controller.forScope('project')};
}
const find=(controller,catalog,name,scope=controller.scope)=>resourceRows(controller,catalog,scope).find(row=>row.name===name);
async function toggle(controller,name) {
  const catalog=await inspectResources(controller),row=find(controller,catalog,name);assert.ok(row,name);
  toggleResource(controller,catalog,row);const after=await inspectResources(controller);return find(controller,after,name);
}
test('native resolver lists grouped installed npm/git packages and four resource types without execution',async t=>{
  const {controller}=fixture(t),catalog=await inspectResources(controller);
  for(const [type,name] of [['extensions','extensions/a.ts'],['skills','planning'],['prompts','prompts/review.md'],['themes','themes/test.json']]) assert.ok(resourceRows(controller,catalog).some(row=>row.type===type && row.name===name));
  assert.equal(find(controller,catalog,'entry.ts'),undefined);
  assert.ok(find(controller,catalog,'entry.ts','project').group.includes('git:github.com/fixture/resources (project)'));
  assert.ok(find(controller,catalog,'extensions/a.ts').group.includes('npm:@fixture/tools@1.0.0 (user)'));
  assert.equal(catalog.inspection,'NATIVE_DISCOVERY_ONLY_NOT_EXECUTED');assert.equal(catalog.authorizesLivePilot,false);
});
test('user package toggle preserves pins, other types, settings and siblings',async t=>{
  const {controller}=fixture(t);assert.equal((await toggle(controller,'extensions/a.ts')).enabled,false);
  const stored=JSON.parse(readFileSync(controller.paths.user,'utf8'));
  assert.equal(stored.packages[0].source,'npm:@fixture/tools@1.0.0');assert.deepEqual(stored.customExtension,{retained:true});assert.equal(stored.defaultModel,'keep-model');
  const catalog=await inspectResources(controller);assert.equal(find(controller,catalog,'extensions/b.ts').enabled,true);assert.equal(find(controller,catalog,'planning').enabled,true);
  assert.equal((await toggle(controller,'extensions/a.ts')).enabled,true);
});
test('managed runtime npm symlinks keep native filter paths and precedence correct',async t=>{
  const {controller,root,user}=fixture(t),managed=join(root,'runtime/packages/npm');mkdirSync(dirname(managed),{recursive:true});
  renameSync(join(user,'npm'),managed);symlinkSync(managed,join(user,'npm'),'dir');
  assert.equal((await toggle(controller,'extensions/a.ts')).enabled,false);
  assert.equal(find(controller,await inspectResources(controller),'extensions/b.ts').enabled,true);
});
test('fixed CLI resources cannot expose misleading writable checkboxes',async t=>{
  const {controller}=fixture(t),catalog=await inspectResources(controller),original=find(controller,catalog,'global.ts'),before=readFileSync(controller.paths.user,'utf8');
  catalog.launcher=[{...original,locked:true,enabled:true,metadata:{source:'launcher',scope:'user',origin:'launcher'},name:'global.ts (CLI override)'}];
  const rows=resourceRows(controller,catalog).filter(row=>row.id===original.id);assert.equal(rows.length,1);assert.equal(rows[0].locked,true);
  assert.throws(()=>toggleResource(controller,catalog,rows[0]),/CLI override/);assert.equal(readFileSync(controller.paths.user,'utf8'),before);
});
test('explicit empty package arrays keep siblings, including hidden entries, disabled when one is enabled',async t=>{
  const {controller}=fixture(t);controller.editSettings(settings=>{settings.packages=[{source:'npm:@fixture/tools@1.0.0',extensions:[]}];});
  const row=await toggle(controller,'extensions/a.ts');assert.equal(row.enabled,true);
  const catalog=await inspectResources(controller);assert.equal(find(controller,catalog,'extensions/b.ts').enabled,false);assert.equal(find(controller,catalog,'extensions/.hidden.ts').enabled,false);
});
test('package include filters remain intact when toggling an excluded resource',async t=>{
  const {controller}=fixture(t);controller.editSettings(settings=>{settings.packages=[{source:'npm:@fixture/tools@1.0.0',extensions:['extensions/a.ts']}];});
  assert.equal((await toggle(controller,'extensions/b.ts')).enabled,true);
  const catalog=await inspectResources(controller);assert.equal(find(controller,catalog,'extensions/a.ts').enabled,true);assert.equal(find(controller,catalog,'extensions/.hidden.ts').enabled,false);
});
test('project-owned auto resources cycle inherit, unload, load and inherit',async t=>{
  const {project}=fixture(t);
  let row=await toggle(project,'project.ts');assert.equal(row.state,'unload');assert.equal(row.enabled,false);
  row=await toggle(project,'project.ts');assert.equal(row.state,'load');assert.equal(row.enabled,true);
  row=await toggle(project,'project.ts');assert.equal(row.state,'inherit');assert.equal(row.enabled,true);
});
test('project override of global top-level resource never changes user settings',async t=>{
  const {project,controller}=fixture(t),before=readFileSync(controller.paths.user,'utf8');
  assert.equal((await toggle(project,'global.ts')).enabled,false);
  assert.equal(find(controller,await inspectResources(controller),'global.ts').enabled,true);
  assert.equal((await toggle(project,'global.ts')).enabled,true);
  assert.equal((await toggle(project,'global.ts')).state,'inherit');
  assert.equal(readFileSync(controller.paths.user,'utf8'),before);
});
test('project package overrides use native autoload deltas and preserve inherited sibling state',async t=>{
  const {project,controller}=fixture(t),before=readFileSync(controller.paths.user,'utf8');
  let row=await toggle(project,'extensions/a.ts');assert.equal(row.enabled,false);assert.equal(row.state,'unload');
  const settings=JSON.parse(readFileSync(project.paths.project,'utf8'));assert.ok(settings.packages.some(pkg=>pkg.autoload===false && pkg.source==='npm:@fixture/tools@1.0.0'));
  assert.equal(find(project,await inspectResources(project),'extensions/b.ts').enabled,true);
  row=await toggle(project,'extensions/a.ts');assert.equal(row.state,'load');assert.equal(row.enabled,true);
  row=await toggle(project,'extensions/a.ts');assert.equal(row.state,'inherit');assert.equal(row.enabled,true);
  assert.equal(readFileSync(controller.paths.user,'utf8'),before);
});
test('inherited local-package filters keep the correct user-relative package identity',async t=>{
  const {controller,project,root}=fixture(t),local=join(root,'shared-local');
  put(join(local,'package.json'),{generation:{extensions:['local-entry.ts']}});put(join(local,'local-entry.ts'),'throw new Error("LOCAL_MUST_NOT_EXECUTE");');
  controller.editSettings(settings=>settings.packages.push('../../shared-local'));
  const before=readFileSync(controller.paths.user,'utf8');
  let row=await toggle(project,'local-entry.ts');assert.equal(row.enabled,false);
  row=await toggle(project,'local-entry.ts');assert.equal(row.enabled,true);
  row=await toggle(project,'local-entry.ts');assert.equal(row.state,'inherit');assert.equal(row.enabled,true);
  assert.equal(readFileSync(controller.paths.user,'utf8'),before);
});
test('skill, prompt and theme checkboxes persist native filters, not just extension filters',async t=>{
  const {controller}=fixture(t);
  for(const name of ['planning','prompts/review.md','themes/test.json']) assert.equal((await toggle(controller,name)).enabled,false);
  const catalog=await inspectResources(controller);assert.equal(find(controller,catalog,'extensions/a.ts').enabled,true);
  const stored=JSON.parse(readFileSync(controller.paths.user,'utf8'));for(const type of ['skills','prompts','themes']) assert.ok(stored.packages[0][type][0].startsWith('-'));
});
test('initially disabled global resources cycle project load, unload, inherit',async t=>{
  const {project,controller}=fixture(t);await toggle(controller,'global.ts');
  let row=await toggle(project,'global.ts');assert.equal(row.state,'load');assert.equal(row.enabled,true);
  row=await toggle(project,'global.ts');assert.equal(row.state,'unload');assert.equal(row.enabled,false);
  row=await toggle(project,'global.ts');assert.equal(row.state,'inherit');assert.equal(row.enabled,false);
});
test('missing npm packages cannot trigger global npm discovery, user npmCommand, installation or auth',async t=>{
  const {controller,root}=fixture(t),marker=join(root,'EXECUTED');
  controller.editSettings(settings=>{settings.packages=['npm:missing-fixture-package@1.0.0'];settings.npmCommand=[process.execPath,'-e',`require("fs").writeFileSync(${JSON.stringify(marker)},"bad")`];});
  const catalog=await inspectResources(controller);assert.equal(catalog.packages[0].installedPath,undefined);assert.equal(existsSync(marker),false);
  assert.equal(existsSync(join(dirname(controller.paths.user),'npm/node_modules/missing-fixture-package')),false);
});
test('all unavailable package declarations remain searchable without false enabled checkboxes',async t=>{
  const {controller}=fixture(t);controller.editSettings(settings=>{settings.packages=Array.from({length:4},(_,i)=>`npm:missing-fixture-${i}@1.0.0`);});
  const before=readFileSync(controller.paths.user,'utf8'),panel=await resourceConfigurationPanel(controller);
  panel.handleInput('missing-fixture-3');const text=panel.render(120).join('\n');assert.match(text,/missing-fixture-3/);assert.match(text,/\[\?\].*Not installed/);
  panel.handleInput(' ');await panel.whenIdle();assert.equal(readFileSync(controller.paths.user,'utf8'),before);
});
test('filesystem permission boundary blocks external/symlink resource reads',async t=>{
  const {controller,root}=fixture(t),outside=mkdtempSync(join(tmpdir(),'harness-outside-'));t.after(()=>rmSync(outside,{recursive:true,force:true}));
  const secret=join(outside,'untrusted.ts');put(secret,'DO_NOT_READ_OR_EXECUTE');
  controller.editSettings(settings=>{settings.extensions=[secret];});
  symlinkSync(outside,join(root,'.generation/extensions/escape'),'dir');
  const catalog=await inspectResources(controller);assert.equal(resourceRows(controller,catalog,'project').some(row=>row.path===secret),false);assert.ok(catalog.blockedProbes>0);
});
test('resource TUI groups, filters, toggles, switches Global/Project and keeps Settings separate',async t=>{
  const {controller}=fixture(t);let closed=false;
  const panel=await resourceConfigurationPanel(controller,{onClose:()=>{closed=true;},height:30});
  assert.match(panel.render(120).join('\n'),/Global Resources/);assert.match(panel.render(120).join('\n'),/Extensions/);
  const text=panel.render(120).join('\n');assert.ok(text.indexOf('npm:@fixture/tools')<text.indexOf('Extensions'));
  panel.handleInput('extensions/a.ts');assert.match(panel.render(120).join('\n'),/\(1\/1\)/);
  panel.handleInput(' ');await panel.whenIdle();assert.equal(find(controller,await inspectResources(controller),'extensions/a.ts').enabled,false);
  panel.handleInput('\t');await panel.whenIdle();assert.equal(panel.currentScope(),'project');assert.match(panel.render(120).join('\n'),/Project Resources/);
  panel.handleInput('\x1bOQ');assert.match(panel.render(120).join('\n'),/^Settings/);
  panel.handleInput('\x1b');assert.match(panel.render(120).join('\n'),/Project Resources/);
  for(const width of [20,40,80]) assert.ok(panel.render(width).every(line=>visibleWidth(line)<=width));
  panel.handleInput('\x1b');assert.equal(closed,true);
});
test('native TUI defaults to resource manager and closes cleanly without a model session',async t=>{
  const {controller}=fixture(t),terminal=new VirtualTerminal(120,30);let ready;
  const readyPromise=new Promise(resolve=>{ready=resolve;});
  const opening=openConfiguration(controller,{terminal,onReady:ready});const panel=await readyPromise;await terminal.waitForRender();
  assert.match(terminal.getViewport().join('\n'),/Global Resources/);
  terminal.sendInput('\t');await panel.whenIdle();await terminal.waitForRender();assert.match(terminal.getViewport().join('\n'),/Project Resources/);
  terminal.resize(60,18);await terminal.waitForRender();assert.ok(terminal.getViewport().every(line=>visibleWidth(line)<=60));
  terminal.sendInput('\x1b');await opening;
});
test('config TUI navigates roles, agents, tools tabs with rounded borders and clean escape',async t=>{
  const {controller}=fixture(t);let closed=false;
  const panel=await resourceConfigurationPanel(controller,{onClose:()=>{closed=true;},height:30});
  
  // Verify rounded borders in initial view
  const initialText=panel.render(120).join('\n');
  assert.match(initialText,/╭─/);assert.match(initialText,/╰─/);
  assert.match(initialText,/F1: Resources/);assert.match(initialText,/F3: Roles & Agents/);assert.match(initialText,/F4: Tools/);

  // Switch to Roles & Agents via F3
  panel.handleInput('\x1bOR');
  const rolesText=panel.render(120).join('\n');
  assert.match(rolesText,/Roles & Agents/);
  assert.match(rolesText,/IELTS Reading Generator/);
  assert.match(rolesText,/reading-generator/);
  assert.match(rolesText,/blind-solver/);
  panel.handleInput('\x1b[B'); // Down arrow scroll
  panel.handleInput('\x1b[5~'); // PageUp
  for(const width of [20,40,80,120]) assert.ok(panel.render(width).every(line=>visibleWidth(line)<=width));

  // Esc from Roles returns to Resources
  panel.handleInput('\x1b');
  assert.match(panel.render(120).join('\n'),/Global Resources/);

  // Switch to Tools via F4
  panel.handleInput('\x1bOS');
  const toolsText=panel.render(120).join('\n');
  assert.match(toolsText,/Tools/);
  assert.match(toolsText,/Built-in Core Tools/);
  assert.match(toolsText,/read/);
  assert.match(toolsText,/validate_question/);
  assert.match(toolsText,/get_question_spec/);
  panel.handleInput('\x1b[B'); // Down arrow scroll
  for(const width of [20,40,80,120]) assert.ok(panel.render(width).every(line=>visibleWidth(line)<=width));

  // Esc from Tools returns to Resources
  panel.handleInput('\x1b');
  assert.match(panel.render(120).join('\n'),/Global Resources/);

  // Switch back via F1
  panel.handleInput('\x1bOP');
  assert.match(panel.render(120).join('\n'),/Global Resources/);

  // Final Esc closes panel
  panel.handleInput('\x1b');
  assert.equal(closed,true);
});
test('config TUI supports mouse clicks, mouse wheel, WASD keys, and arrow navigation',async t=>{
  const {controller}=fixture(t);
  const panel=await resourceConfigurationPanel(controller,{onClose:()=>{},height:30});
  panel.render(120);

  // 1. Mouse click on F3 (Roles & Agents tab)
  panel.handleMouse({type:'click',x:55,y:3,width:120,height:30});
  assert.match(panel.render(120).join('\n'),/Roles & Agents/);

  // 2. WASD navigation: 'a' goes to previous tab (Settings)
  panel.handleInput('a');
  assert.match(panel.render(120).join('\n'),/^Settings/);

  // 3. WASD navigation: 'd' goes to next tab (Roles)
  panel.handleInput('d');
  assert.match(panel.render(120).join('\n'),/Roles & Agents/);

  // 4. WASD navigation: 'd' again goes to next tab (Tools)
  panel.handleInput('d');
  assert.match(panel.render(120).join('\n'),/Tools/);

  // 5. WASD scroll: 's' scrolls down, 'w' scrolls up
  panel.handleInput('s');
  panel.handleInput('w');

  // 6. Mouse click on F1 (Resources tab)
  panel.handleMouse({type:'click',x:8,y:3,width:120,height:30});
  assert.match(panel.render(120).join('\n'),/Global Resources/);

  // 7. Mouse wheel scrolling in Resources
  panel.handleMouse({type:'wheel',wheelDelta:1,x:10,y:10,width:120,height:30});
  panel.handleMouse({type:'wheel',wheelDelta:-1,x:10,y:10,width:120,height:30});

  // 8. SGR mouse sequence in handleInput (terminal mouse escape code)
  panel.handleInput('\x1b[<0;55;4M'); // click at col 55, row 4 (F3 Roles tab)
  assert.match(panel.render(120).join('\n'),/Roles & Agents/);

  // 9. Arrow keys: Left/Right to switch tabs
  panel.handleInput('\x1b[D'); // Left to Settings
  assert.match(panel.render(120).join('\n'),/^Settings/);
  panel.handleInput('\x1b[C'); // Right to Roles
  assert.match(panel.render(120).join('\n'),/Roles & Agents/);
});
test('configExtension registers /config slash command and launches custom UI overlay',async t=>{
  const {controller}=fixture(t);
  const {default:configExtension}=await import('../scripts/config-extension.mjs');
  
  let registeredName,registeredOpts;
  const api={
    registerCommand(name,opts){
      registeredName=name;
      registeredOpts=opts;
    }
  };
  configExtension(api);
  assert.equal(registeredName,'config');
  assert.ok(registeredOpts.description.includes('Configuration TUI'));

  // Test non-TUI mode notification and message
  let notification, sentMessage;
  api.sendMessage = msg => { sentMessage = msg; };
  await registeredOpts.handler('',{
    mode:'rpc',
    hasUI:false,
    cwd:controller.root,
    ui:{notify:(msg)=>{notification=msg;}}
  });
  assert.match(notification,/Printed full configuration summary/);
  assert.match(sentMessage.content,/Full Configuration/);
  assert.match(sentMessage.content,/IELTS Generation Roles/);
  assert.match(sentMessage.content,/Complete Tools Inventory/);

  // Test /config full command
  sentMessage = null;
  await registeredOpts.handler('full',{
    mode:'tui',
    hasUI:true,
    cwd:controller.root,
    ui:{}
  });
  assert.match(sentMessage.content,/Full Configuration/);

  // Test argument completions
  const completions = registeredOpts.getArgumentCompletions('fu');
  assert.equal(completions.length, 1);
  assert.equal(completions[0].value, 'full');

  // Test TUI mode: opens custom overlay
  let customOpened=false;
  await registeredOpts.handler('',{
    mode:'tui',
    hasUI:true,
    cwd:controller.root,
    ui:{
      async custom(factory,options){
        customOpened=true;
        assert.equal(options.overlay,true);
        const comp=await factory({terminal:{rows:30},requestRender:()=>{}},{},{},()=>{});
        assert.ok(comp.render);
        const rendered=comp.render(120).join('\n');
        assert.match(rendered,/Global Resources/);
      }
    }
  });
  assert.equal(customOpened,true);
});
