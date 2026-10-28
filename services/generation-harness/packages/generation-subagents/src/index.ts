import type { ExtensionFactory } from "generation-harness-core";
import registerNativeExtension from "./extension/index.ts";
import { createSubagentExtension as createConfiguredExtension } from "./compat/index.ts";
import type { SubagentExtensionOptions } from "./compat/types.ts";
import { loadedPackageVersion, readInstalledPackageVersion } from "./shared/package-version.ts";

// Preserve the existing programmatic foreground API while the default package
// entry point uses the complete pinned upstream extension and its native APIs.
export * from "./compat/types.ts";
export { executeSubagent } from "./compat/runs/foreground/subagent-executor.ts";
export { discoverAgents } from "./compat/agents/agents.ts";
export { loadHostHarnessCore } from "./runs/shared/harness-spawn.ts";

export function createSubagentExtension(options?: SubagentExtensionOptions): ExtensionFactory {
	return options?.agents !== undefined || options?.disabledFeatures !== undefined
		? createConfiguredExtension(options)
		: api => {
			if (readInstalledPackageVersion() !== loadedPackageVersion) throw new Error("Generation Subagents was updated in this process; restart the harness to load the installed version.");
			if (process.env.GENERATION_SUBAGENT_CHILD !== "1") registerNativeExtension(api);
		};
}

export default createSubagentExtension();
