import type { ExtensionAPI } from 'generation-harness-core';
import { createReadingTools } from '../reading/tools.ts';

export default function reading(api: ExtensionAPI): void {
  for (const tool of createReadingTools()) api.registerTool(tool);
}
