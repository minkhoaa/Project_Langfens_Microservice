import * as bundledPiAgentCore from "generation-agent-core";
import * as bundledPiAiCompat from "generation-ai/compat";
import * as bundledPiAiModels from "generation-ai/models";
import * as bundledPiAiOauth from "generation-ai/oauth";
import * as bundledPiAiProviders from "generation-ai/providers/all";
import * as bundledPiTui from "generation-tui";
import * as bundledTypebox from "typebox";
import * as bundledTypeboxCompile from "typebox/compile";
import * as bundledTypeboxValue from "typebox/value";
// This import is safe because loader.ts exports are not re-exported from index.ts.
// Extensions can therefore import from generation-harness-core.
import * as bundledPiCodingAgent from "../../index.ts";

/** Modules available to extensions in source and compiled binary runtimes. */
export const VIRTUAL_MODULES: Record<string, unknown> = {
	typebox: bundledTypebox,
	"typebox/compile": bundledTypeboxCompile,
	"typebox/value": bundledTypeboxValue,
	"@sinclair/typebox": bundledTypebox,
	"@sinclair/typebox/compile": bundledTypeboxCompile,
	"@sinclair/typebox/value": bundledTypeboxValue,
	"generation-agent-core": bundledPiAgentCore,
	"generation-tui": bundledPiTui,
	// Extensions resolve the pi-ai root to the compat entrypoint (a strict
	// superset of the core entrypoint): existing extensions using the old
	// global API keep working at runtime until compat is removed.
	"generation-ai": bundledPiAiCompat,
	"generation-ai/compat": bundledPiAiCompat,
	"generation-ai/models": bundledPiAiModels,
	"generation-ai/oauth": bundledPiAiOauth,
	"generation-ai/providers/all": bundledPiAiProviders,
	"generation-harness-core": bundledPiCodingAgent,
	"@mariozechner/pi-agent-core": bundledPiAgentCore,
	"@mariozechner/pi-tui": bundledPiTui,
	"@mariozechner/pi-ai": bundledPiAiCompat,
	"@mariozechner/pi-ai/compat": bundledPiAiCompat,
	"@mariozechner/pi-ai/models": bundledPiAiModels,
	"@mariozechner/pi-ai/oauth": bundledPiAiOauth,
	"@mariozechner/pi-ai/providers/all": bundledPiAiProviders,
	"@mariozechner/pi-coding-agent": bundledPiCodingAgent,
};
