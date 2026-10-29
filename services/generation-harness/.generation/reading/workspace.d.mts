export function readingConfiguration(args: string[], runtime: { runtime: string; env: NodeJS.ProcessEnv }): { workspace: string; args: string[] };
export function readingPrompt(workspace: string): string;
export function nextReadingConfiguration(previousRun: string, inherited?: NodeJS.ProcessEnv): { workspace: string; args: string[]; env: NodeJS.ProcessEnv };
