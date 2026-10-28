import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

const offlineSetup = fileURLToPath(new URL("./test/offline.mjs", import.meta.url));

export const workspaceSourcePaths = {
	telemetryIndex: fileURLToPath(new URL("./packages/telemetry/src/index.ts", import.meta.url)),
	telemetryTesting: fileURLToPath(new URL("./packages/telemetry/src/testing/index.ts", import.meta.url)),
	mcpIndex: fileURLToPath(new URL("./packages/mcp/src/index.ts", import.meta.url)),
	mcpOAuth: fileURLToPath(new URL("./packages/mcp/src/oauth/index.ts", import.meta.url)),
	mcpTesting: fileURLToPath(new URL("./packages/mcp/src/testing/index.ts", import.meta.url)),
	aiIndex: fileURLToPath(new URL("./packages/ai/src/index.ts", import.meta.url)),
	aiCompat: fileURLToPath(new URL("./packages/ai/src/compat.ts", import.meta.url)),
	aiModels: fileURLToPath(new URL("./packages/ai/src/models.ts", import.meta.url)),
	aiOAuth: fileURLToPath(new URL("./packages/ai/src/oauth.ts", import.meta.url)),
	aiApi: fileURLToPath(new URL("./packages/ai/src/api", import.meta.url)),
	aiProviders: fileURLToPath(new URL("./packages/ai/src/providers", import.meta.url)),
	aiUtils: fileURLToPath(new URL("./packages/ai/src/utils", import.meta.url)),
	agentIndex: fileURLToPath(new URL("./packages/agent/src/index.ts", import.meta.url)),
	codemodeIndex: fileURLToPath(new URL("./packages/codemode/src/index.ts", import.meta.url)),
	codemodeDeclarations: fileURLToPath(new URL("./packages/codemode/src/declarations.ts", import.meta.url)),
	codemodeSource: fileURLToPath(new URL("./packages/codemode/src/source.ts", import.meta.url)),
	coreIndex: fileURLToPath(new URL("./packages/generation-harness-core/src/index.ts", import.meta.url)),
	tuiIndex: fileURLToPath(new URL("./packages/tui/src/index.ts", import.meta.url)),
} as const;

export default defineConfig({
	test: {
		setupFiles: [offlineSetup],
	},
	resolve: {
		alias: [
			{ find: /^generation-telemetry$/, replacement: workspaceSourcePaths.telemetryIndex },
			{ find: /^generation-telemetry\/testing$/, replacement: workspaceSourcePaths.telemetryTesting },
			{ find: /^generation-mcp$/, replacement: workspaceSourcePaths.mcpIndex },
			{ find: /^generation-mcp\/oauth$/, replacement: workspaceSourcePaths.mcpOAuth },
			{ find: /^generation-mcp\/testing$/, replacement: workspaceSourcePaths.mcpTesting },
			{ find: /^generation-ai$/, replacement: workspaceSourcePaths.aiIndex },
			{ find: /^generation-ai\/compat$/, replacement: workspaceSourcePaths.aiCompat },
			{ find: /^generation-ai\/models$/, replacement: workspaceSourcePaths.aiModels },
			{ find: /^generation-ai\/oauth$/, replacement: workspaceSourcePaths.aiOAuth },
			{
				find: /^generation-ai\/utils\/(.+)$/,
				replacement: `${workspaceSourcePaths.aiUtils}/$1.ts`,
			},
			{
				find: /^generation-ai\/api\/(.+)$/,
				replacement: `${workspaceSourcePaths.aiApi}/$1.ts`,
			},
			{
				find: /^generation-ai\/providers\/(.+)$/,
				replacement: `${workspaceSourcePaths.aiProviders}/$1.ts`,
			},
			{ find: /^generation-agent-core$/, replacement: workspaceSourcePaths.agentIndex },
			{ find: /^generation-codemode$/, replacement: workspaceSourcePaths.codemodeIndex },
			{ find: /^generation-codemode\/declarations$/, replacement: workspaceSourcePaths.codemodeDeclarations },
			{ find: /^generation-codemode\/source$/, replacement: workspaceSourcePaths.codemodeSource },
			{ find: /^generation-harness-core$/, replacement: workspaceSourcePaths.coreIndex },
			{ find: /^generation-tui$/, replacement: workspaceSourcePaths.tuiIndex },
		],
	},
});
