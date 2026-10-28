import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, readdirSync, rmSync, symlinkSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const packageRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const workspaceModules = resolve(packageRoot, "../../node_modules");

test("clean package exposes every public subpath and executes its packaged workflow worker and detached runner offline", { timeout: 45000 }, t => {
	const npmExecPath = process.env.npm_execpath || [
		resolve(dirname(process.execPath), "../lib/node_modules/npm/bin/npm-cli.js"),
		resolve(dirname(process.execPath), "node_modules/npm/bin/npm-cli.js"),
	].find(p => existsSync(p));
	assert.ok(npmExecPath, "Run this dev-tool scenario through npm or with an accessible Node npm-cli.js installation");
	const root = mkdtempSync(join(tmpdir(), "generation-package-install-"));
	t.after(() => rmSync(root, { recursive: true, force: true }));
	const pack = JSON.parse(execFileSync(process.execPath, [npmExecPath, "pack", "--offline", "--ignore-scripts", "--json", "--pack-destination", root], { cwd: packageRoot, env: process.env, encoding: "utf8", timeout: 15000 }));
	const modules = join(root, "node_modules"); const installed = join(modules, "generation-subagents");
	mkdirSync(installed, { recursive: true });
	execFileSync("tar", ["-xzf", join(root, pack[0].filename), "--strip-components=1", "-C", installed]);
	// Explicit local workspace peers/dependencies only; never install or discover
	// global modules, and never use the reference checkout as a runtime dependency.
	for (const entry of readdirSync(workspaceModules)) {
		if (entry === "generation-subagents" || entry === ".bin" || entry === ".package-lock.json") continue;
		symlinkSync(join(workspaceModules, entry), join(modules, entry), "dir");
	}
	const manifest = JSON.parse(readFileSync(join(installed, "package.json"), "utf8"));
	assert.equal(manifest.upstream.commit, "312082429bda07714fe0fe7729fe8d4935de4c5a");
	assert.equal(Object.keys(manifest.exports).length, 15);
	const script = join(root, "verify.mjs");
	writeFileSync(script, `import assert from "node:assert/strict";import {mkdirSync,writeFileSync,readFileSync} from "node:fs";import {join} from "node:path";
		import {createAgentSession,DefaultResourceLoader,ModelRuntime,SettingsManager,SessionManager} from "generation-harness-core";
		import {InMemoryCredentialStore,fauxProvider,fauxAssistantMessage,fauxToolCall} from "generation-ai";
		import registerExtension from "generation-subagents";
		const cwd=${JSON.stringify(root)},agentDir=process.env.GENERATION_HARNESS_AGENT_DIR;
		for(const subpath of ${JSON.stringify(Object.keys(manifest.exports).filter(key => key !== "."))})await import("generation-subagents"+subpath.slice(1));
		const extension=join(cwd,"provider.mjs");writeFileSync(extension,\`import {fauxProvider,fauxAssistantMessage,fauxToolCall} from "generation-ai";export default api=>{const fake=fauxProvider({provider:"packaged",models:[{id:"model"}]});fake.setResponses([fauxAssistantMessage(fauxToolCall("write",{path:"packaged-marker",content:"packaged-tool-called"}),{stopReason:"toolUse"}),fauxAssistantMessage("PACKAGED-CHILD-DONE")]);api.registerProvider(fake.provider)};\`);
		mkdirSync(join(cwd,".generation","agents"),{recursive:true});writeFileSync(join(cwd,".generation","agents","packaged.md"),"---\\nname: packaged\\ndescription: Packaged offline child\\nmodel: packaged/model\\ntools: write\\nsubagentOnlyExtensions: "+extension+"\\ninheritSkills: false\\ninheritProjectContext: false\\n---\\nComplete the offline task.");
		mkdirSync(join(agentDir,"extensions","subagent"),{recursive:true});writeFileSync(join(agentDir,"extensions","subagent","config.json"),JSON.stringify({toolActivation:"eager",defaultSubagentContext:"fresh"}));
		const workflow=join(cwd,"workflow.js");writeFileSync(workflow,'const child=await runs.run("pack-child",{agent:"packaged",task:"packaged native tool"});return child.output;');
		const runtime=await ModelRuntime.create({credentials:new InMemoryCredentialStore(),modelsPath:null,refreshOnCreate:false});const fake=fauxProvider({models:[{id:"parent"}]});runtime.registerNativeProvider(fake.provider);runtime.registerNativeProvider(fauxProvider({provider:"packaged",models:[{id:"model"}]}).provider);
		const settingsManager=SettingsManager.inMemory({cacheWarming:"off",retry:{enabled:false},compaction:{enabled:false},packages:[{source:${JSON.stringify(installed)}}]});const loader=new DefaultResourceLoader({cwd,agentDir,settingsManager,noThemes:true,noContextFiles:true});await loader.reload();assert.deepEqual(loader.getExtensions().errors,[]);assert.ok(loader.getSkills().skills.some(skill=>skill.name==="generation-subagents"));assert.ok(loader.getPrompts().prompts.length>0);
		const {session}=await createAgentSession({cwd,agentDir,modelRuntime:runtime,model:fake.getModel("parent"),settingsManager,resourceLoader:loader,sessionManager:SessionManager.create(cwd,join(cwd,"sessions"))});
		try{await session.bindExtensions({mode:"print"});fake.setResponses([fauxAssistantMessage(fauxToolCall("subagent",{workflow,async:false}),{stopReason:"toolUse"}),fauxAssistantMessage("DONE")]);await session.prompt("Run packaged workflow");const result=session.messages.find(m=>m.role==="toolResult"&&m.toolName==="subagent");assert.ok(result&&!result.isError,JSON.stringify(result));assert.match(JSON.stringify(result),/PACKAGED-CHILD-DONE/);assert.equal(readFileSync(join(cwd,"packaged-marker"),"utf8"),"packaged-tool-called");console.log("PACKAGED-PASS");}finally{try{await session.extensionRunner.emit({type:"session_shutdown",reason:"quit"})}finally{session.dispose()}}`);
	const runtime = join(root, "runtime");
	const result = spawnSync(process.execPath, [script], { cwd: root, encoding: "utf8", timeout: 25000, env: {
		...process.env, HOME: join(runtime, "home"), USERPROFILE: join(runtime, "home"), XDG_CONFIG_HOME: join(runtime, "home", "config"),
		GENERATION_HARNESS_RUNTIME_DIR: runtime, GENERATION_HARNESS_AGENT_DIR: join(runtime, "agent"),
		GENERATION_HARNESS_SESSION_DIR: join(runtime, "sessions"), GENERATION_SUBAGENTS_TEMP_ROOT: join(runtime, "tmp"),
	} });
	assert.equal(result.status, 0, `${result.error ?? ""}\n${result.stderr}\n${result.stdout}`);
	assert.match(result.stdout, /PACKAGED-PASS/);
});
