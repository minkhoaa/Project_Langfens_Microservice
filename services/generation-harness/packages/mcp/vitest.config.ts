import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

const offlineSetup = fileURLToPath(new URL("../../test/offline.mjs", import.meta.url));

export default defineConfig({
	test: {
		globals: true,
		environment: "node",
		reporters: process.env.GITHUB_ACTIONS ? ["dot", "github-actions"] : ["dot"],
		setupFiles: [offlineSetup],
	},
	resolve: { conditions: ["source"] },
	ssr: { resolve: { conditions: ["source"] } },
});
