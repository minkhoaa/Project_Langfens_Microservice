import type { ExtensionAPI } from 'generation-harness-core';
import { createReadingTools } from '../reading/tools.ts';
import { createCreationTools } from '../reading/creation.ts';

export default function reading(api: ExtensionAPI): void {
  for (const tool of [...createReadingTools(), ...createCreationTools()]) api.registerTool(tool);
}
