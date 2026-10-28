import * as bundledGenerationAgentCore from "generation-agent-core";
import * as bundledGenerationAi from "generation-ai";
import * as bundledGenerationAiModels from "generation-ai/models";
import * as bundledGenerationAiOauth from "generation-ai/oauth";
import * as bundledGenerationAiProviders from "generation-ai/providers/all";
import * as bundledGenerationTui from "generation-tui";
import * as bundledTypebox from "typebox";
import * as bundledTypeboxCompile from "typebox/compile";
import * as bundledTypeboxValue from "typebox/value";
// This import is safe because loader.ts exports are not re-exported from index.ts.
// Extensions can therefore import from generation-harness-core.
import * as bundledGenerationCodingAgent from "../../index.ts";

/** Modules available to extensions in source and compiled binary runtimes. */
export const VIRTUAL_MODULES: Record<string, unknown> = {
	typebox: bundledTypebox,
	"typebox/compile": bundledTypeboxCompile,
	"typebox/value": bundledTypeboxValue,
	"@sinclair/typebox": bundledTypebox,
	"@sinclair/typebox/compile": bundledTypeboxCompile,
	"@sinclair/typebox/value": bundledTypeboxValue,
	"generation-agent-core": bundledGenerationAgentCore,
	"generation-tui": bundledGenerationTui,
	"generation-ai": bundledGenerationAi,
	"generation-ai/models": bundledGenerationAiModels,
	"generation-ai/oauth": bundledGenerationAiOauth,
	"generation-ai/providers/all": bundledGenerationAiProviders,
	"generation-harness-core": bundledGenerationCodingAgent,
};
