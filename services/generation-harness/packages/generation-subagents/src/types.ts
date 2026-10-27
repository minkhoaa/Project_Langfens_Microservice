import type { ModelRuntime } from "generation-harness-core";
import type { Model, Usage } from "generation-harness-core/ai";

export type CoreToolName = "read" | "bash" | "edit" | "write";
export interface AgentDefinition {
	name: string;
	systemPrompt?: string;
	model?: string;
	tools?: CoreToolName[];
}
export interface ChildTask { agent: string; task: string; model?: string }
export type SubagentInput = ChildTask | { task?: string; chain: ChildTask[] };
export type RunStatus = "completed" | "failed" | "cancelled";
export interface ChildResult {
	agent: string;
	model: string;
	sessionId: string;
	sessionFile?: string;
	output: string;
	usage: Usage;
	status: RunStatus;
	error?: string;
}
export interface SubagentRunResult { status: RunStatus; results: ChildResult[]; error?: string }
export interface SubagentProgress {
	index: number;
	agent: string;
	status: "running" | RunStatus;
	model?: string;
	sessionId?: string;
	output?: string;
	tool?: string;
	usage?: Usage;
	error?: string;
}
export interface SubagentExecutionContext {
	cwd: string;
	agentDir: string;
	sessionDir: string;
	parentSessionId?: string;
	modelRuntime: ModelRuntime;
	parentModel?: Model<any>;
	agents: AgentDefinition[];
	signal?: AbortSignal;
	onProgress?: (event: SubagentProgress) => void;
}
export interface SubagentExtensionOptions { agents?: AgentDefinition[] }
