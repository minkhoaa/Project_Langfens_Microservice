import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { createJiti } from "jiti";
import * as piCore from "generation-agent-core";
import * as piAi from "generation-ai/compat";
import * as piTui from "generation-tui";
import * as sdk from "generation-harness-core";
import * as typebox from "typebox";
import * as typeboxCompile from "typebox/compile";
import * as typeboxValue from "typebox/value";
import { installRunnerHttpDispatcher } from "./runner-http-dispatcher.ts";
import { resolveRuntimeModuleExtension } from "../../shared/runtime-module-path.ts";
import { runConfiguredSubagent, validateSubagentRunConfig } from "./subagent-runner-bootstrap.ts";
import { getAgentDir } from "../../shared/utils.ts";

/**
 * Pi's extension loader supplies the embedded SDK. Bare Bun/Node cannot replace
 * it: an apparent import success can be an auto-installed, different SDK.
 * Await the configured runner inside extension initialization so the outer Pi
 * session/RPC loop never starts. Exit only after shared disposal/lease release.
 * Derived from xz-dev's PR #2049, commit 910807bfefcf9ee41d73fa25ec86dcd75ab8f4b2.
 */
export default async function runBinaryBootstrap(): Promise<never> {
	const configPath = process.env.GENERATION_SUBAGENT_RUNNER_CONFIG;
	delete process.env.GENERATION_SUBAGENT_RUNNER_CONFIG;
	try {
		if (!configPath || !path.isAbsolute(configPath)) throw new Error("Missing absolute PI_SUBAGENT_RUNNER_CONFIG path");
		const rawConfig: unknown = JSON.parse(fs.readFileSync(configPath, "utf8"));
		validateSubagentRunConfig(rawConfig);
		const config = rawConfig;
		try {
			fs.unlinkSync(configPath);
		} catch {
			// Temp-config cleanup is best effort, as in the Node entrypoint.
		}
		// Pi applies httpIdleTimeoutMs to its dispatcher only after extension
		// factories return; this factory never does, so install the runner's own.
		installRunnerHttpDispatcher({ agentDir: getAgentDir(), cwd: process.cwd() });
		await runConfiguredSubagent(config, {
			loadPiCodingAgent: async () => sdk,
			loadExecutionModule: async () => {
				// Native Bun imports bypass Pi's Jiti virtual peers in the compiled host.
				const jiti = createJiti(import.meta.url, {
					tryNative: false,
					moduleCache: false,
					virtualModules: {
						"generation-agent-core": piCore,
						"generation-ai": piAi,
						"generation-ai/compat": piAi,
						"generation-tui": piTui,
						"generation-harness-core": sdk,
						typebox,
						"typebox/compile": typeboxCompile,
						"typebox/value": typeboxValue,
					},
				});
				const runner = `./subagent-runner${resolveRuntimeModuleExtension(path.dirname(fileURLToPath(import.meta.url)), "subagent-runner")}`;
				return jiti.import<typeof import("./subagent-runner.ts")>(runner);
			},
		});
		process.exit(0);
	} catch (error) {
		console.error("Subagent binary runner error:", error);
		process.exit(1);
	}
}
