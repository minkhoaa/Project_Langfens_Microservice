export type ModifierKey = "shift" | "command" | "control" | "option";

export interface NativeClipboard {
	getText(): Promise<string | null | undefined>;
	getImage(): Promise<Uint8Array | null | undefined>;
	getFilePaths?(): Promise<string[] | null | undefined>;
	setText?(text: string): Promise<void>;
}

export interface NativePlatformHelper extends NativeClipboard {
	enableVirtualTerminalInput?: () => boolean;
	isModifierPressed?: (name: ModifierKey) => boolean;
}

/** This Node distribution has no native addons; terminal clipboard fallbacks remain available. */
export function getNativePlatformHelper(): NativePlatformHelper | undefined {
	return undefined;
}

/** Clipboard helpers are optional; callers fall back to platform command-line integrations. */
export function getNativeClipboard(): NativeClipboard | undefined {
	return undefined;
}
