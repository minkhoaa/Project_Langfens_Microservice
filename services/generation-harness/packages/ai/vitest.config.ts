import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

const telemetrySrcIndex = fileURLToPath(new URL("../telemetry/src/index.ts", import.meta.url));
const offlineSetup = fileURLToPath(new URL("../../test/offline.mjs", import.meta.url));

export default defineConfig({
	test: {
		globals: true,
		environment: "node",
		testTimeout: 30000,
		reporters: process.env.GITHUB_ACTIONS ? ["dot", "github-actions"] : ["dot"],
		silent: "passed-only",
		setupFiles: [offlineSetup],
		exclude: [
			"**/*e2e*.test.ts",
			"**/*live*.test.ts",
			"**/stream.test.ts",
			"**/abort.test.ts",
			"**/empty.test.ts",
			"**/image-tool-result.test.ts",
			"**/tokens.test.ts",
			"**/tool-call-without-result.test.ts",
			"**/total-tokens.test.ts",
			"**/unicode-surrogate.test.ts",
			"**/context-overflow.test.ts",
			"**/cross-provider-handoff.test.ts",
			"**/responseid.test.ts",
			"**/openai-responses-tool-result-images.test.ts",
			"**/anthropic-tool-name-normalization.test.ts",
			"**/anthropic-opus-4-8-smoke.test.ts",
			"**/openai-codex-stream.test.ts",
			"**/zen.test.ts",
			"**/node_modules/**",
			"**/dist/**",
		],
	},
	resolve: {
		alias: [{ find: /^generation-telemetry$/, replacement: telemetrySrcIndex }],
	},
});
