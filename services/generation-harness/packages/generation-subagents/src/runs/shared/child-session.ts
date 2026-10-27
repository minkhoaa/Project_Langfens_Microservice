import type { AgentSession } from "generation-harness-core";
import type { Model } from "generation-harness-core/ai";
import type { AgentDefinition, SubagentExecutionContext } from "../../types.ts";
import { loadHostHarnessCore } from "./harness-spawn.ts";

export interface ChildSession {
	session: AgentSession;
	dispose(): Promise<void>;
}

/** Adapted from the pinned native factory: independent session/loader, no process-wide env patching. */
export function createDefaultChildSessionFactory(context: SubagentExecutionContext) {
	const live = new Set<ChildSession>();
	let disposed = false;
	return {
		async create(agent: AgentDefinition, model: Model<any>): Promise<ChildSession> {
			if (disposed) throw new Error("Child session factory is disposed");
			const core = await loadHostHarnessCore();
			const configuration = core.SettingsManager.create(context.cwd, context.agentDir);
			const settingsManager = core.SettingsManager.inMemory({
				...configuration.getGlobalSettings(), ...configuration.getProjectSettings(),
				cacheWarming: "off", retry: { enabled: false },
			});
			const loader = new core.DefaultResourceLoader({
				cwd: context.cwd, agentDir: context.agentDir, settingsManager,
				noExtensions: true, noSkills: true, noPromptTemplates: true, noThemes: true, noContextFiles: true,
				systemPrompt: agent.systemPrompt, appendSystemPrompt: [],
			});
			await loader.reload();
			const sessionManager = core.SessionManager.create(context.cwd, context.sessionDir);
			const { session } = await core.createAgentSession({
				cwd: context.cwd, agentDir: context.agentDir, modelRuntime: context.modelRuntime,
				model, tools: agent.tools ?? ["read", "bash", "edit", "write"],
				resourceLoader: loader, sessionManager, settingsManager,
			});
			try {
				await session.bindExtensions({ mode: "print" });
				if (disposed) throw new Error("Child session factory disposed during launch");
			} catch (error) { session.dispose(); throw error; }
			let closing: Promise<void> | undefined;
			const child: ChildSession = {
				session,
				dispose() {
					closing ??= (async () => {
						try {
							await session.abort();
							await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" });
						} finally { live.delete(child); session.dispose(); }
					})();
					return closing;
				},
			};
			live.add(child);
			return child;
		},
		async dispose(): Promise<void> {
			disposed = true;
			await Promise.all([...live].map(child => child.dispose()));
		},
	};
}
