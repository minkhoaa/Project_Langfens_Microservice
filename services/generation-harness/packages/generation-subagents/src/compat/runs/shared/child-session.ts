import type { AgentSession } from "generation-harness-core";
import { InMemoryCredentialStore } from "generation-ai";
import { join } from "node:path";
import type { AgentDefinition, SubagentExecutionContext } from "../../types.ts";
import { createDefaultChildSessionFactory as createNativeFactory } from "../../../runs/shared/child-session.ts";
import { buildInProcessChildLaunch } from "../../../runs/shared/child-launch.ts";
import { loadHostHarnessCore } from "./harness-spawn.ts";

export interface ChildSession { session: AgentSession; dispose(): Promise<void> }

/** Existing SDK result shape over the pinned upstream's native child lifecycle. */
export function createDefaultChildSessionFactory(context: SubagentExecutionContext) {
	const factory = createNativeFactory({
		loadPiCodingAgent: loadHostHarnessCore,
		agentDir: context.agentDir,
		failOnExtensionLoadError: true,
		createModelRuntime: core => core.ModelRuntime.create({
			...(process.env.GENERATION_HARNESS_OFFLINE === "1" ? { credentials: new InMemoryCredentialStore(), modelsPath: null } : {
				authPath: join(context.agentDir, "auth.json"), modelsPath: join(context.agentDir, "models.json"),
			}), refreshOnCreate: false,
		}),
	});
	return {
		async create(agent: AgentDefinition, model: string): Promise<ChildSession> {
			const launch = buildInProcessChildLaunch({
				cwd: context.cwd, host: "parent", childAgentName: agent.name, childIndex: 0,
				parentSessionId: context.parentSessionId, sessionEnabled: true, sessionDir: context.sessionDir,
				model, tools: agent.tools ?? ["read", "bash", "edit", "write"], excludeTools: agent.excludeTools,
				extensions: agent.extensions, subagentOnlyExtensions: agent.subagentOnlyExtensions,
				systemPrompt: agent.systemPrompt, systemPromptMode: "replace",
				inheritProjectContext: false, inheritGlobalContext: false, inheritSkills: false,
			});
			const child = await factory.create({ ...launch.session, parentProviderRegistry: context.modelRuntime, signal: context.signal });
			const session = child.nativeSession!;
			const active = new Set(session.getActiveToolNames());
			const missing = launch.toolPlan.requiredChildTools.filter(name => !active.has(name));
			if (missing.length) {
				await child.dispose();
				throw new Error(`Child tools unavailable: ${missing.join(", ")}; configure extensions or subagentOnlyExtensions.`);
			}
			return { session, dispose: () => child.dispose() };
		},
		dispose: () => factory.dispose(),
	};
}
