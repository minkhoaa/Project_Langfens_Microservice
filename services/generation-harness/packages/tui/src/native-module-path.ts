/** Native addon lookup is intentionally unsupported in the Node-only distribution. */
export interface NativeModuleCandidateOptions {}

export function getNativeModuleCandidates(_nativePath: string, _options: NativeModuleCandidateOptions = {}): string[] {
	return [];
}
