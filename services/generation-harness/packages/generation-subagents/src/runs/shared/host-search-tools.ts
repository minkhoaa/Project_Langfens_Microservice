import type { AgentTool } from "generation-agent-core";
import {
	createFindToolDefinition, createGrepToolDefinition, createLsToolDefinition,
	createReadOnlyTools, type InlineExtension, type ToolDefinition,
} from "generation-harness-core";

/** Core keeps four default builtins, but publicly exposes the native search
 * definitions. Supply those unchanged as child-only extension tools when a Pi
 * agent explicitly selects them; never widen the parent's default tool set. */
export function hostSearchDefinitions(cwd: string): ToolDefinition<any, any>[] {
	return [createGrepToolDefinition(cwd), createFindToolDefinition(cwd), createLsToolDefinition(cwd)];
}

export function childSearchExtensions(cwd: string, selected: string[] | undefined, excluded: string[] = []): InlineExtension[] {
	return hostSearchDefinitions(cwd)
		.filter(definition => selected?.includes(definition.name) && !excluded.includes(definition.name))
		.map(definition => ({ name: `generation-subagents:search:${definition.name}`, replaceable: true, factory: api => api.registerTool(definition) }));
}

/** Watchdog uses the host's same native definitions in its existing Agent. */
export function hostReadOnlyTools(cwd: string): AgentTool[] {
	const tools = createReadOnlyTools(cwd);
	const names = new Set(tools.map(tool => tool.name));
	for (const definition of hostSearchDefinitions(cwd)) {
		if (names.has(definition.name)) continue;
		tools.push({
			name: definition.name, label: definition.label, description: definition.description, parameters: definition.parameters,
			// These native definitions accept an absent SDK context and use cwd,
			// exactly as Core's own AgentTool wrappers do for standalone Agents.
			execute: (id, args, signal, onUpdate) => definition.execute(id, args, signal, onUpdate, undefined!),
		});
	}
	return tools;
}
