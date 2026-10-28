import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

const telemetrySrcIndex = fileURLToPath(new URL("../telemetry/src/index.ts", import.meta.url));
const aiSrcIndex = fileURLToPath(new URL("../ai/src/index.ts", import.meta.url));
const aiSrcCompat = fileURLToPath(new URL("../ai/src/compat.ts", import.meta.url));
const agentSrcIndex = fileURLToPath(new URL("./src/index.ts", import.meta.url));
const offlineSetup = fileURLToPath(new URL("../../test/offline.mjs", import.meta.url));

export default defineConfig({
	test: {
		globals: true,
		environment: "node",
		testTimeout: 30000,
		reporters: process.env.GITHUB_ACTIONS ? ["dot", "github-actions"] : ["dot"],
		silent: "passed-only",
		setupFiles: [offlineSetup],
	},
	resolve: {
		conditions: ["source"],
		alias: [
			{ find: /^generation-telemetry$/, replacement: telemetrySrcIndex },
			{ find: /^generation-agent-core$/, replacement: agentSrcIndex },
			{ find: /^generation-ai$/, replacement: aiSrcIndex },
			{ find: /^generation-ai\/compat$/, replacement: aiSrcCompat },
		],
	},
	ssr: { resolve: { conditions: ["source"] } },
});
