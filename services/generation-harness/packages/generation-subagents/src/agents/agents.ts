import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import type { AgentDefinition, CoreToolName } from "../types.ts";
import { parseFrontmatter, parseUnquotedList } from "./frontmatter.js";

const coreTools = new Set(["read", "bash", "edit", "write"]);

export function validateAgentDefinitions(agents: AgentDefinition[]): AgentDefinition[] {
	if (!Array.isArray(agents)) throw new Error("Agent definitions must be an array");
	const seen = new Set<string>();
	return agents.map(agent => {
		if (!agent || typeof agent.name !== "string" || !agent.name.trim()) throw new Error("Agent name is required");
		const name = agent.name.trim();
		if (seen.has(name)) throw new Error(`Duplicate agent definition: ${name}`);
		seen.add(name);
		if (agent.model !== undefined && (typeof agent.model !== "string" || !agent.model.trim())) throw new Error(`Invalid model for agent ${name}`);
		if (agent.systemPrompt !== undefined && typeof agent.systemPrompt !== "string") throw new Error(`Invalid system prompt for agent ${name}`);
		if (agent.tools !== undefined && (!Array.isArray(agent.tools) || agent.tools.some(tool => !coreTools.has(tool)))) throw new Error(`Invalid tools for agent ${name}`);
		return { ...agent, name, tools: agent.tools ? [...agent.tools] : undefined };
	});
}

/** Langfens-owned roots only: no npm/global presets or ambient skills. */
export function discoverAgents(cwd: string, agentDir: string, explicit?: AgentDefinition[]): AgentDefinition[] {
	if (explicit !== undefined) return validateAgentDefinitions(explicit);
	const agents: AgentDefinition[] = [];
	for (const directory of new Set([join(agentDir, "agents"), join(cwd, ".generation", "agents")])) {
		if (!existsSync(directory)) continue;
		for (const file of readdirSync(directory, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
			if (!file.isFile() || !file.name.endsWith(".md")) continue;
			const path = join(directory, file.name);
			try {
				const content = readFileSync(path, "utf8").replace(/\r\n/g, "\n");
				if (!content.startsWith("---\n") || !content.includes("\n---", 4)) throw new Error("Missing agent frontmatter");
				const { frontmatter, body } = parseFrontmatter(content);
				let tools = frontmatter.tools;
				if (tools?.startsWith("[") && tools.endsWith("]")) tools = tools.slice(1, -1);
				agents.push({ name: frontmatter.name, model: frontmatter.model, tools: parseUnquotedList(tools) as CoreToolName[] | undefined, systemPrompt: body });
			} catch (cause) {
				throw new Error(`Invalid agent file ${path}: ${cause instanceof Error ? cause.message : String(cause)}`, { cause });
			}
		}
	}
	return validateAgentDefinitions(agents);
}
