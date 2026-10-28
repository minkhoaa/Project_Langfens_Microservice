import type { InlineExtension } from "../core/extensions/types.ts";
import codemodeExtension from "./codemode/index.ts";
import llamaExtension from "./llama/index.ts";
import mcpExtension from "./mcp/index.ts";
import toolSearchExtension from "./tool-search/index.ts";

/**
 * Optional auxiliary integrations (llama.cpp, codemode, tool-search, mcp).
 * Retained for optional SDK compatibility, but strictly opt-in.
 */
export const auxiliaryExtensions: InlineExtension[] = [
	{ name: "llama.cpp", factory: llamaExtension, builtin: true },
	// Replaceable: an extension that registers `codemode`, `tool_search`, or `/mcp` (such as a third-party
	// MCP extension) takes over instead of running alongside the built-in one.
	{ name: "codemode", factory: codemodeExtension, replaceable: true, builtin: true },
	{ name: "tool-search", factory: toolSearchExtension, replaceable: true, builtin: true },
	{ name: "mcp", factory: mcpExtension, replaceable: true, builtin: true },
];

/**
 * Default built-in extension list is strictly empty to preserve the
 * 4 built-in tools rule (read, bash, edit, write) without auxiliary tool/provider pollution.
 */
export const builtInExtensions: InlineExtension[] = [];
