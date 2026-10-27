import { compare, valid } from "semver";

export interface LatestHarnessRelease {
	version: string;
	packageName?: string;
	note?: string;
}

export function formatVersionCheckError(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}

export function comparePackageVersions(leftVersion: string, rightVersion: string): number | undefined {
	const left = valid(leftVersion.trim());
	const right = valid(rightVersion.trim());
	return left && right ? compare(left, right) : undefined;
}

export function isNewerPackageVersion(candidateVersion: string, currentVersion: string): boolean {
	const comparison = comparePackageVersions(candidateVersion, currentVersion);
	return comparison === undefined ? candidateVersion.trim() !== currentVersion.trim() : comparison > 0;
}

/** Updates belong to the source checkout/npm lockfile, never an upstream service. */
export async function getLatestHarnessRelease(
	_currentVersion: string,
	_options: { timeoutMs?: number; retry?: boolean } = {},
): Promise<LatestHarnessRelease | undefined> {
	return undefined;
}

export async function getLatestHarnessVersion(
	_currentVersion: string,
	_options: { timeoutMs?: number; retry?: boolean } = {},
): Promise<string | undefined> {
	return undefined;
}

export async function checkForNewHarnessVersion(_currentVersion: string): Promise<LatestHarnessRelease | undefined> {
	return undefined;
}
