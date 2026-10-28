import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import type { AgentDefinition } from "../types.ts";
import { parseFrontmatter, parseUnquotedList } from "./frontmatter.js";

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
		if (agent.thinking !== undefined && !["off", "minimal", "low", "medium", "high", "xhigh", "max"].includes(agent.thinking)) throw new Error(`Invalid thinking for agent ${name}`);
		for (const field of ["tools", "excludeTools", "extensions", "subagentOnlyExtensions"] as const) {
			const values = agent[field];
			if (values !== undefined && (!Array.isArray(values) || values.some(value => typeof value !== "string" || !value.trim()))) throw new Error(`Invalid ${field} for agent ${name}`);
		}
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
				const relative = (entries: string[] | undefined) => entries?.map(entry => entry === "." || entry === ".." || entry.startsWith("./") || entry.startsWith("../") ? resolve(dirname(path), entry) : entry);
				agents.push({ name: frontmatter.name, model: frontmatter.model, thinking: frontmatter.thinking as AgentDefinition["thinking"], tools: relative(parseUnquotedList(tools)), excludeTools: parseUnquotedList(frontmatter.excludeTools), extensions: relative(parseUnquotedList(frontmatter.extensions)), subagentOnlyExtensions: relative(parseUnquotedList(frontmatter.subagentOnlyExtensions)), systemPrompt: body });
			} catch (cause) {
				throw new Error(`Invalid agent file ${path}: ${cause instanceof Error ? cause.message : String(cause)}`, { cause });
			}
		}
	}
	return validateAgentDefinitions(agents);
}
