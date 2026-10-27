import * as bundledHarnessAgentCore from "langfens-agent-core";
import * as bundledHarnessAiCompat from "langfens-ai/compat";
import * as bundledHarnessAiModels from "langfens-ai/models";
import * as bundledHarnessAiOauth from "langfens-ai/oauth";
import * as bundledHarnessAiProviders from "langfens-ai/providers/all";
import * as bundledHarnessTui from "langfens-tui";
import * as bundledTypebox from "typebox";
import * as bundledTypeboxCompile from "typebox/compile";
import * as bundledTypeboxValue from "typebox/value";
// This import is safe because loader.ts exports are not re-exported from index.ts.
// Extensions can therefore import from langfens-harness-core.
import * as bundledHarnessCodingAgent from "../../index.ts";

/** Modules available to extensions in source and compiled binary runtimes. */
export const VIRTUAL_MODULES: Record<string, unknown> = {
	typebox: bundledTypebox,
	"typebox/compile": bundledTypeboxCompile,
	"typebox/value": bundledTypeboxValue,
	"@sinclair/typebox": bundledTypebox,
	"@sinclair/typebox/compile": bundledTypeboxCompile,
	"@sinclair/typebox/value": bundledTypeboxValue,
	"langfens-agent-core": bundledHarnessAgentCore,
	"langfens-tui": bundledHarnessTui,
	// Extensions resolve the pi-ai root to the compat entrypoint (a strict
	// superset of the core entrypoint): existing extensions using the old
	// global API keep working at runtime until compat is removed.
	"langfens-ai": bundledHarnessAiCompat,
	"langfens-ai/compat": bundledHarnessAiCompat,
	"langfens-ai/models": bundledHarnessAiModels,
	"langfens-ai/oauth": bundledHarnessAiOauth,
	"langfens-ai/providers/all": bundledHarnessAiProviders,
	"langfens-harness-core": bundledHarnessCodingAgent,
};
