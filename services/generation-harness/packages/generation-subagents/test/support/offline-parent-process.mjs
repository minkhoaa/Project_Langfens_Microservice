import { writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { ModelRuntime, DefaultResourceLoader, SettingsManager, SessionManager, createAgentSession } from "generation-harness-core";
import { InMemoryCredentialStore, fauxProvider, fauxAssistantMessage, fauxToolCall } from "generation-ai";
import { createSubagentExtension } from "../../dist/index.js";
const [cwd, report] = process.argv.slice(2);
if (!cwd || !report || process.env.GENERATION_HARNESS_OFFLINE !== "1") throw Error("An explicit offline fixture scope is required");
const agentDir = process.env.GENERATION_HARNESS_AGENT_DIR;
const runtime = await ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false });
const fake = fauxProvider({ models: [{ id: "parent" }] }); runtime.registerNativeProvider(fake.provider);
runtime.registerNativeProvider(fauxProvider({ provider: "offline", models: [{ id: "model" }] }).provider);
const settingsManager = SettingsManager.inMemory({ cacheWarming: "off", retry: { enabled: false }, compaction: { enabled: false } });
const loader = new DefaultResourceLoader({ cwd, agentDir, settingsManager, noExtensions: true, noSkills: true, noThemes: true, noPromptTemplates: true, noContextFiles: true, extensionFactories: [createSubagentExtension()] });
await loader.reload();
const { session } = await createAgentSession({ cwd, agentDir, modelRuntime: runtime, model: fake.getModel("parent"), resourceLoader: loader, settingsManager, sessionManager: SessionManager.create(cwd, join(cwd, "process-parent-sessions")) });
try {
	await session.bindExtensions({ mode: "rpc", uiContext: { ...session.extensionRunner.getUIContext() } });
	fake.setResponses([fauxAssistantMessage(fauxToolCall("subagent", { agent: "offline", task: "parent-exit", async: true }), { stopReason: "toolUse" }), fauxAssistantMessage("PARENT-DONE")]);
	await session.prompt("Launch offline child then exit");
	const launched = session.messages.find(message => message.role === "toolResult" && message.toolName === "subagent");
	if (launched?.isError || !launched?.details?.asyncId) throw Error(JSON.stringify(launched));
	mkdirSync(join(cwd, "reports"), { recursive: true });
	writeFileSync(report, JSON.stringify({ ...launched.details, parentFile: session.sessionFile }));
} finally {
	try { await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" }); }
	finally { session.dispose(); }
}
